
#import "RTReporter.h"
#import <dlfcn.h>

#define MAX_THREAD_FRAMES 512

#import <mach/mach.h>
#include <dlfcn.h>
#include <pthread.h>
#include <sys/types.h>
#include <limits.h>
#include <string.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>

#pragma -mark DEFINE MACRO FOR DIFFERENT CPU ARCHITECTURE
#if defined(__arm64__)
#define DETAG_INSTRUCTION_ADDRESS(A) ((A) & ~(3UL))
#define BS_THREAD_STATE_COUNT ARM_THREAD_STATE64_COUNT
#define BS_THREAD_STATE ARM_THREAD_STATE64
#define BS_FRAME_POINTER __fp
#define BS_STACK_POINTER __sp
#define BS_INSTRUCTION_ADDRESS __pc

#elif defined(__arm__)
#define DETAG_INSTRUCTION_ADDRESS(A) ((A) & ~(1UL))
#define BS_THREAD_STATE_COUNT ARM_THREAD_STATE_COUNT
#define BS_THREAD_STATE ARM_THREAD_STATE
#define BS_FRAME_POINTER __r[7]
#define BS_STACK_POINTER __sp
#define BS_INSTRUCTION_ADDRESS __pc

#elif defined(__x86_64__)
#define DETAG_INSTRUCTION_ADDRESS(A) (A)
#define BS_THREAD_STATE_COUNT x86_THREAD_STATE64_COUNT
#define BS_THREAD_STATE x86_THREAD_STATE64
#define BS_FRAME_POINTER __rbp
#define BS_STACK_POINTER __rsp
#define BS_INSTRUCTION_ADDRESS __rip

#elif defined(__i386__)
#define DETAG_INSTRUCTION_ADDRESS(A) (A)
#define BS_THREAD_STATE_COUNT x86_THREAD_STATE32_COUNT
#define BS_THREAD_STATE x86_THREAD_STATE32
#define BS_FRAME_POINTER __ebp
#define BS_STACK_POINTER __esp
#define BS_INSTRUCTION_ADDRESS __eip

#endif

#define CALL_INSTRUCTION_FROM_RETURN_ADDRESS(A) (DETAG_INSTRUCTION_ADDRESS((A)) - 1)

#if defined(__LP64__)
#define TRACE_FMT         "%-4d%-31s 0x%016lx %s + %lu"
#define POINTER_FMT       "0x%016lx"
#define POINTER_SHORT_FMT "0x%lx"
#define BS_NLIST struct nlist_64
#else
#define TRACE_FMT         "%-4d%-31s 0x%08lx %s + %lu"
#define POINTER_FMT       "0x%08lx"
#define POINTER_SHORT_FMT "0x%lx"
#define BS_NLIST struct nlist
#endif

static mach_port_t main_thread_id;

static NSException *exception;
static NSArray *arr;

typedef struct RTStackFrameEntry{
    const struct RTStackFrameEntry *const previous;
    const uintptr_t return_address;
} RTStackFrameEntry;

@implementation RTCrashReporter

#pragma -mark Implementation of interface
+ (RTCrashThreadInfo *)rt_backtraceOfNSThread:(NSThread *)thread {
    RTCrashThreadInfo *threadInfo = _rt_backtraceOfThread(rt_machThreadFromNSThread(thread));
    threadInfo.threadName = [thread name];
    return threadInfo;
}

+ (RTCrashThreadInfo *)rt_backtraceOfCurrentThread {
    
    RTCrashThreadInfo *threadInfo = NULL;
    NSLock *lock = [RTCrashReporter shareObject].crashLock;
    [lock lock];
    threadInfo = [self rt_backtraceOfNSThread:[NSThread currentThread]];
    [lock unlock];
    
    return threadInfo;
}

+ (RTCrashThreadInfo *)rt_backtraceOfMainThread {
    return [self rt_backtraceOfNSThread:[NSThread mainThread]];
}

+ (NSMutableArray<RTCrashThreadInfo *> *)rt_backtraceOfAllThread {
    thread_act_array_t threads;
    mach_msg_type_number_t thread_count = 0;
    const task_t this_task = mach_task_self();
    
    kern_return_t kr = task_threads(this_task, &threads, &thread_count);
    if(kr != KERN_SUCCESS) {
        return NULL;
    }
    
    thread_t crashThread = [RTCrashReporter shareObject].crashThread;
    NSLock *lock = [RTCrashReporter shareObject].crashLock;
    
    [lock lock];
    [[RTCrashReporter shareObject].otherThreadInfos removeAllObjects];
    for(int i = 0; i < thread_count; i++) {
        if (threads[i] == crashThread) {
            [RTCrashReporter shareObject].crashThreadInfo = _rt_backtraceOfThread(threads[i]);
        }else{
            [[RTCrashReporter shareObject].otherThreadInfos addObject:_rt_backtraceOfThread(threads[i])];
        }
    }
    [lock unlock];
    
    return [RTCrashReporter shareObject].otherThreadInfos;
}

+ (BOOL)rt_storeLagMachineContext {
    _STRUCT_MCONTEXT machineContext;
    if (!rt_fillRTThreadStateIntoMachineContext([RTCrashReporter shareObject].mainThreadId, &machineContext)) {
        return NO;
    }else {
        [RTCrashReporter shareObject].lagMachineContext = machineContext;
        return YES;
    }
}

#pragma mark - set Thread name
void rt_setThreadName(thread_t thread, RTCrashThreadInfo *threadInfo) {
    static int num = 0;
    char *name = (char *)malloc(256);
    if (name != NULL) {
        memset(name, '\0', 256);
        pthread_t pt = pthread_from_mach_thread_np(thread);
        if (pt) {
            pthread_getname_np(pt, name, 255);
        }
        if (strlen(name)>0) {
            threadInfo.threadName = [NSString stringWithFormat:@"#%d %s",num,name];
        }else{
            threadInfo.threadName = [NSString stringWithFormat:@"#%d Thread",num];
        }
        free(name);
    }
    
    if ([RTCrashReporter shareObject].isLag == YES) {
        num = 0;
    }else {
        num ++;
    }
}

#pragma -mark Get call backtrace of a mach_thread
RTCrashThreadInfo *_rt_backtraceOfThread(thread_t thread) {
    uintptr_t backtraceBuffer[MAX_THREAD_FRAMES];
    int i = 0;
    RTCrashThreadInfo *threadInfo = [[RTCrashThreadInfo alloc] init];
    threadInfo.threadId = thread;
    
    rt_setThreadName(thread, threadInfo);
    
    _STRUCT_MCONTEXT machineContext;
    if ([RTCrashReporter shareObject].isLag) {
        machineContext = [RTCrashReporter shareObject].lagMachineContext;
    }else if(!rt_fillRTThreadStateIntoMachineContext(thread, &machineContext)) {
        threadInfo.errorCode = 101;
        return threadInfo;
    }
    
    const uintptr_t instructionAddress = rt_mach_instructionAddress(&machineContext);
    backtraceBuffer[i] = instructionAddress;
    ++i;

    uintptr_t linkRegister = rt_mach_linkRegister(&machineContext);
    if (linkRegister) {
        backtraceBuffer[i] = linkRegister;
        i++;
    }
    
    if(instructionAddress == 0) {
        threadInfo.errorCode = 102;
        return threadInfo;
    }
    
    RTStackFrameEntry frame = {0};
    const uintptr_t framePtr = rt_mach_framePointer(&machineContext);
    if(framePtr == 0 ||
       rt_mach_copyMem((void *)framePtr, &frame, sizeof(frame)) != KERN_SUCCESS) {
        threadInfo.errorCode = 103;
        return threadInfo;
    }
    
    //OC类型的崩溃则使用api进行崩溃堆栈的获取
    if ([[RTCrashReporter shareObject].callStackAddressArr count] &&
        [RTCrashReporter shareObject].crashThread == thread) {
        i = 0;
        threadInfo.isCrashThread = YES;
        NSArray *callStackAddresses = [[RTCrashReporter shareObject].callStackAddressArr mutableCopy];
        for(; i < MAX_THREAD_FRAMES && i < [callStackAddresses count]; i++) {
            backtraceBuffer[i] = [callStackAddresses[i] integerValue];
        }
    }else {
        for(; i < MAX_THREAD_FRAMES; i++) {
            backtraceBuffer[i] = frame.return_address;
            if(backtraceBuffer[i] == 0 ||
               frame.previous == 0 ||
               rt_mach_copyMem(frame.previous, &frame, sizeof(frame)) != KERN_SUCCESS) {
                break;
            }
        }
    }
    
    int backtraceLength = i;
    NSString *stackLine = NULL;
    
    Dl_info symbolicated[backtraceLength];
    rt_symbolicate(backtraceBuffer, symbolicated, backtraceLength, 0);
    for (int i = 0; i < backtraceLength; ++i) {
        stackLine = [NSString stringWithFormat:@"%-3d %@",i, rt_logBacktraceEntry(i, backtraceBuffer[i], &symbolicated[i])];
        [threadInfo.stackTrace appendString:stackLine];
    }
    return threadInfo;
}

#pragma -mark Convert NSThread to Mach thread
thread_t rt_machThreadFromNSThread(NSThread *nsthread) {
    char name[256];
    mach_msg_type_number_t count;
    thread_act_array_t list;
    task_threads(mach_task_self(), &list, &count);
    
    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
    NSString *originName = [nsthread name];
    [nsthread setName:[NSString stringWithFormat:@"%f", currentTimestamp]];
    
    if ([nsthread isMainThread]) {
        return (thread_t)main_thread_id;
    }
    
    for (int i = 0; i < count; ++i) {
        pthread_t pt = pthread_from_mach_thread_np(list[i]);
        if ([nsthread isMainThread]) {
            if (list[i] == main_thread_id) {
                return list[i];
            }
        }
        if (pt) {
            name[0] = '\0';
            pthread_getname_np(pt, name, sizeof name);
            if (!strcmp(name, [nsthread name].UTF8String)) {
                [nsthread setName:originName];
                return list[i];
            }
        }
    }
    
    [nsthread setName:originName];
    return mach_thread_self();
}

#pragma -mark GenerateBacbsrackEnrty
NSString* rt_logBacktraceEntry(const int entryNum,
                               const uintptr_t address,
                               const Dl_info* const dlInfo) {
    char faddrBuff[20];
    char saddrBuff[20];
    
    const char* fname = rt_lastPathEntry(dlInfo->dli_fname);
    if(fname == NULL) {
        sprintf(faddrBuff, POINTER_FMT, (uintptr_t)dlInfo->dli_fbase);
        fname = faddrBuff;
    }
    
    uintptr_t offset = address - (uintptr_t)dlInfo->dli_saddr;
    const char* sname = dlInfo->dli_sname;
    if(sname == NULL || strcmp(sname, "<redacted>") == 0) {
        sprintf(saddrBuff, POINTER_FMT, (uintptr_t)dlInfo->dli_fbase);
        sname = saddrBuff;
        offset = address - (uintptr_t)dlInfo->dli_fbase;
    }
    return [NSString stringWithFormat:@"%-30s  0x%016" PRIxPTR " %s + %lu\n" ,fname, (uintptr_t)address, sname, offset];
}

const char* rt_lastPathEntry(const char* const path) {
    if(path == NULL) {
        return NULL;
    }
    
    char* lastFile = strrchr(path, '/');
    return lastFile == NULL ? path : lastFile + 1;
}

#pragma -mark HandleMachineContext
bool rt_fillRTThreadStateIntoMachineContext(thread_t thread, _STRUCT_MCONTEXT *machineContext) {
    mach_msg_type_number_t state_count = BS_THREAD_STATE_COUNT;
    kern_return_t kr = thread_get_state(thread, BS_THREAD_STATE, (thread_state_t)&machineContext->__ss, &state_count);
    return (kr == KERN_SUCCESS);
}

uintptr_t rt_mach_framePointer(mcontext_t const machineContext){
    return machineContext->__ss.BS_FRAME_POINTER;
}

uintptr_t rt_mach_stackPointer(mcontext_t const machineContext){
    return machineContext->__ss.BS_STACK_POINTER;
}

uintptr_t rt_mach_instructionAddress(mcontext_t const machineContext){
    return machineContext->__ss.BS_INSTRUCTION_ADDRESS;
}

uintptr_t rt_mach_linkRegister(mcontext_t const machineContext){
#if defined(__i386__) || defined(__x86_64__)
    return 0;
#else
    return machineContext->__ss.__lr;
#endif
}

kern_return_t rt_mach_copyMem(const void *const src, void *const dst, const size_t numBytes){
    vm_size_t bytesCopied = 0;
    return vm_read_overwrite(mach_task_self(), (vm_address_t)src, (vm_size_t)numBytes, (vm_address_t)dst, &bytesCopied);
}

#pragma -mark Symbolicate
void rt_symbolicate(const uintptr_t* const backtraceBuffer,
                    Dl_info* const symbolsBuffer,
                    const int numEntries,
                    const int skippedEntries){
    int i = 0;
    
    if(!skippedEntries && i < numEntries) {
        rt_dladdr(backtraceBuffer[i], &symbolsBuffer[i]);
        i++;
    }
    
    for(; i < numEntries; i++) {
        rt_dladdr(CALL_INSTRUCTION_FROM_RETURN_ADDRESS(backtraceBuffer[i]), &symbolsBuffer[i]);
    }
}

bool rt_dladdr(const uintptr_t address, Dl_info* const info) {
    info->dli_fname = NULL;
    info->dli_fbase = NULL;
    info->dli_sname = NULL;
    info->dli_saddr = NULL;
    
    const uint32_t idx = rt_imageIndexContainingAddress(address);
    if(idx == UINT_MAX) {
        return false;
    }
    const struct mach_header* header = _dyld_get_image_header(idx);
    const uintptr_t imageVMAddrSlide = (uintptr_t)_dyld_get_image_vmaddr_slide(idx);
    const uintptr_t addressWithSlide = address - imageVMAddrSlide;
    const uintptr_t segmentBase = rt_segmentBaseOfImageIndex(idx) + imageVMAddrSlide;
    if(segmentBase == 0) {
        return false;
    }
    
    info->dli_fname = _dyld_get_image_name(idx);
    info->dli_fbase = (void*)header;
    
    const BS_NLIST* bestMatch = NULL;
    uintptr_t bestDistance = ULONG_MAX;
    uintptr_t cmdPtr = rt_firstCmdAfterHeader(header);
    if(cmdPtr == 0) {
        return false;
    }
    for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++) {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        if(loadCmd->cmd == LC_SYMTAB) {
            const struct symtab_command* symtabCmd = (struct symtab_command*)cmdPtr;
            const BS_NLIST* symbolTable = (BS_NLIST*)(segmentBase + symtabCmd->symoff);
            const uintptr_t stringTable = segmentBase + symtabCmd->stroff;
            
            for(uint32_t iSym = 0; iSym < symtabCmd->nsyms; iSym++) {
                if(symbolTable[iSym].n_value != 0) {
                    uintptr_t symbolBase = symbolTable[iSym].n_value;
                    uintptr_t currentDistance = addressWithSlide - symbolBase;
                    if((addressWithSlide >= symbolBase) &&
                       (currentDistance <= bestDistance)) {
                        bestMatch = symbolTable + iSym;
                        bestDistance = currentDistance;
                    }
                }
            }
            if(bestMatch != NULL) {
                info->dli_saddr = (void*)(bestMatch->n_value + imageVMAddrSlide);
                info->dli_sname = (char*)((intptr_t)stringTable + (intptr_t)bestMatch->n_un.n_strx);
                if(*info->dli_sname == '_') {
                    info->dli_sname++;
                }
                
                if(info->dli_saddr == info->dli_fbase && bestMatch->n_type == 3) {
                    info->dli_sname = NULL;
                }
                break;
            }
        }
        cmdPtr += loadCmd->cmdsize;
    }
    return true;
}

uintptr_t rt_firstCmdAfterHeader(const struct mach_header* const header) {
    switch(header->magic) {
        case MH_MAGIC:
        case MH_CIGAM:
            return (uintptr_t)(header + 1);
        case MH_MAGIC_64:
        case MH_CIGAM_64:
            return (uintptr_t)(((struct mach_header_64*)header) + 1);
        default:
            return 0;
    }
}

uint32_t rt_imageIndexContainingAddress(const uintptr_t address) {
    const uint32_t imageCount = _dyld_image_count();
    const struct mach_header* header = 0;
    
    for(uint32_t iImg = 0; iImg < imageCount; iImg++) {
        header = _dyld_get_image_header(iImg);
        if(header != NULL) {
            uintptr_t addressWSlide = address - (uintptr_t)_dyld_get_image_vmaddr_slide(iImg);
            uintptr_t cmdPtr = rt_firstCmdAfterHeader(header);
            if(cmdPtr == 0) {
                continue;
            }
            for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++) {
                const struct load_command* loadCmd = (struct load_command*)cmdPtr;
                if(loadCmd->cmd == LC_SEGMENT) {
                    const struct segment_command* segCmd = (struct segment_command*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr &&
                       addressWSlide < segCmd->vmaddr + segCmd->vmsize) {
                        return iImg;
                    }
                }
                else if(loadCmd->cmd == LC_SEGMENT_64) {
                    const struct segment_command_64* segCmd = (struct segment_command_64*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr &&
                       addressWSlide < segCmd->vmaddr + segCmd->vmsize) {
                        return iImg;
                    }
                }
                cmdPtr += loadCmd->cmdsize;
            }
        }
    }
    return UINT_MAX;
}

uintptr_t rt_segmentBaseOfImageIndex(const uint32_t idx) {
    const struct mach_header* header = _dyld_get_image_header(idx);
    uintptr_t cmdPtr = rt_firstCmdAfterHeader(header);
    if(cmdPtr == 0) {
        return 0;
    }
    for(uint32_t i = 0;i < header->ncmds; i++) {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        if(loadCmd->cmd == LC_SEGMENT) {
            const struct segment_command* segmentCmd = (struct segment_command*)cmdPtr;
            if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0) {
                return segmentCmd->vmaddr - segmentCmd->fileoff;
            }
        }
        else if(loadCmd->cmd == LC_SEGMENT_64) {
            const struct segment_command_64* segmentCmd = (struct segment_command_64*)cmdPtr;
            if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0) {
                return (uintptr_t)(segmentCmd->vmaddr - segmentCmd->fileoff);
            }
        }
        cmdPtr += loadCmd->cmdsize;
    }
    return 0;
}

+ (void)initialize{
    if (![[self class] isEqual:[RTCrashReporter class]]) {
        return;
    }
}


+(instancetype)shareObject{
    static RTCrashReporter * reporter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (reporter == nil) {
            reporter = [[RTCrashReporter alloc] init];
        }
        //进程名
        reporter.processName = [NSString stringWithFormat:@"%s",getprogname()];
        //堆栈信息
        reporter.crashThreadInfo = [[RTCrashThreadInfo alloc] init];
        //崩溃地址
        reporter.callStackAddressArr = [[NSMutableArray alloc] init];
        //其他线程信息
        reporter.otherThreadInfos = [[NSMutableArray alloc] init];
        //是否为卡顿
        reporter.isLag = NO;
        //image头
        reporter.imageHeader = [reporter getTheImageHeader];
        reporter.crashLock = [[NSLock alloc] init];
    });
    return reporter;
}

- (const struct mach_header *)getTheImageHeader {
    uint32_t count = _dyld_image_count();
    for(uint32_t i = 0; i < count; i++) {
        const struct mach_header *idx = _dyld_get_image_header(i);
        if (idx->filetype == MH_EXECUTE) {
            return idx;
        }
    }
    return NULL;
}

- (NSString *)getDSYMUUID{
    if ([_dSYMUUID length] <= 0) {
        //dSYM文件uuid(模块加载地址获取也包含在里面)
        if (!_imageHeader)
            return nil;
        
        BOOL is64bit = _imageHeader->magic == MH_MAGIC_64 || _imageHeader->magic == MH_CIGAM_64;
        uintptr_t cursor = (uintptr_t)_imageHeader + (is64bit ? sizeof(struct mach_header_64) : sizeof(struct mach_header));
        const struct segment_command *segmentCommand = NULL;
        for (uint32_t i = 0; i < _imageHeader->ncmds; i++, cursor += segmentCommand->cmdsize)
        {
            segmentCommand = (struct segment_command *)cursor;
            if (segmentCommand->cmd == LC_UUID)
            {
                const struct uuid_command *uuidCommand = (const struct uuid_command *)segmentCommand;
                NSString *temp = [[[[NSUUID alloc] initWithUUIDBytes:uuidCommand->uuid] UUIDString] lowercaseString];
                
                _dSYMUUID = [temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
                break;
            }
        }
    }
    return _dSYMUUID;
}

- (NSString *)getBaseAddress {
    if ([_baseAddress length] <= 0) {
        _baseAddress = [NSString stringWithFormat:@"0x%016lx",(intptr_t)self.imageHeader];
    }
    return _baseAddress;
}

+ (NSString *)generateLiveReport:(BOOL)isLiveReport{
    
    NSString *stackTrace = NULL;
    NSLock *lock = [RTCrashReporter shareObject].crashLock;
    [RTCrashReporter shareObject].isLag = YES;
    if (lock == NULL) {
        [RTCrashReporter shareObject].crashLock = [[NSLock alloc] init];
        lock = [RTCrashReporter shareObject].crashLock;
    }
    [lock lock];
    RTCrashThreadInfo *mainThreadInfo = [RTCrashReporter rt_backtraceOfMainThread];
    stackTrace = mainThreadInfo.stackTrace;
    [RTCrashReporter shareObject].isLag = NO;
    [lock unlock];
    
    return [stackTrace copy];
}

+ (void)start{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //获取主线程id
        if ([NSThread isMainThread] == YES) {
            [RTCrashReporter shareObject].mainThreadId = mach_thread_self();
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [RTCrashReporter shareObject].mainThreadId = mach_thread_self();
            });
        }
        main_thread_id = [RTCrashReporter shareObject].mainThreadId;
    });
}

@end
