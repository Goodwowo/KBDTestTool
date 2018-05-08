
#include "RTCrashSignal.h"
#include <errno.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#import "RTReporter.h"
#import "RTCrashLag.h"
#import "RTOperationImage.h"
#import "RTViewHierarchy.h"
#import "RecordTestHeader.h"

static volatile sig_atomic_t g_installed = 0;
static stack_t g_signalStack = {0};
static struct sigaction* g_previousSignalHandlers = NULL;

//signal info struct
typedef struct {
    const int code;
    const char* const name;
} RTSignalCodeInfo;

typedef struct {
    const int sigNum;
    const char* const name;
    const RTSignalCodeInfo* const codes;
    const int numCodes;
} RTSignalInfo;

#define ENUM_NAME_MAPPING(A) {A, #A}

static const RTSignalCodeInfo g_sigIllCodes[] = {
    ENUM_NAME_MAPPING(ILL_NOOP),
    ENUM_NAME_MAPPING(ILL_ILLOPC),
    ENUM_NAME_MAPPING(ILL_ILLTRP),
    ENUM_NAME_MAPPING(ILL_PRVOPC),
    ENUM_NAME_MAPPING(ILL_ILLOPN),
    ENUM_NAME_MAPPING(ILL_ILLADR),
    ENUM_NAME_MAPPING(ILL_PRVREG),
    ENUM_NAME_MAPPING(ILL_COPROC),
    ENUM_NAME_MAPPING(ILL_BADSTK),
};

static const RTSignalCodeInfo g_sigTrapCodes[] = {
    ENUM_NAME_MAPPING(0),
    ENUM_NAME_MAPPING(TRAP_BRKPT),
    ENUM_NAME_MAPPING(TRAP_TRACE),
};

static const RTSignalCodeInfo g_sigFPECodes[] = {
    ENUM_NAME_MAPPING(FPE_NOOP),
    ENUM_NAME_MAPPING(FPE_FLTDIV),
    ENUM_NAME_MAPPING(FPE_FLTOVF),
    ENUM_NAME_MAPPING(FPE_FLTUND),
    ENUM_NAME_MAPPING(FPE_FLTRES),
    ENUM_NAME_MAPPING(FPE_FLTINV),
    ENUM_NAME_MAPPING(FPE_FLTSUB),
    ENUM_NAME_MAPPING(FPE_INTDIV),
    ENUM_NAME_MAPPING(FPE_INTOVF),
};

static const RTSignalCodeInfo g_sigBusCodes[] = {
    ENUM_NAME_MAPPING(BUS_NOOP),
    ENUM_NAME_MAPPING(BUS_ADRALN),
    ENUM_NAME_MAPPING(BUS_ADRERR),
    ENUM_NAME_MAPPING(BUS_OBJERR),
};

static const RTSignalCodeInfo g_sigSegVCodes[] = {
    ENUM_NAME_MAPPING(SEGV_NOOP),
    ENUM_NAME_MAPPING(SEGV_MAPERR),
    ENUM_NAME_MAPPING(SEGV_ACCERR),
};

#define SIGNAL_INFO(SIGNAL, CODES) {SIGNAL, #SIGNAL, CODES, sizeof(CODES) / sizeof(*CODES)}
#define SIGNAL_INFO_NOCODES(SIGNAL) {SIGNAL, #SIGNAL, 0, 0}

static const RTSignalInfo g_fatalSignalData[] = {
    SIGNAL_INFO_NOCODES(SIGABRT),
    SIGNAL_INFO(SIGBUS, g_sigBusCodes),
    SIGNAL_INFO(SIGFPE, g_sigFPECodes),
    SIGNAL_INFO(SIGILL, g_sigIllCodes),
    SIGNAL_INFO_NOCODES(SIGPIPE),
    SIGNAL_INFO(SIGSEGV, g_sigSegVCodes),
    SIGNAL_INFO_NOCODES(SIGSYS),
    SIGNAL_INFO(SIGTERM, g_sigTrapCodes),
};
static const int g_fatalSignalsCount = sizeof(g_fatalSignalData) / sizeof(*g_fatalSignalData);

static const int g_fatalSignals[] = {
    SIGABRT,
    SIGBUS,
    SIGFPE,
    SIGILL,
    SIGPIPE,
    SIGSEGV,
    SIGSYS,
    SIGTRAP,
};

static const char* rt_signal_signalName(const int sigNum) {
    for(int i = 0; i < g_fatalSignalsCount; i++) {
        if(g_fatalSignalData[i].sigNum == sigNum) {
            return g_fatalSignalData[i].name;
        }
    }
    return NULL;
}

static void rt_signalHandler(int sigNum,siginfo_t* signalInfo,void* userContext) {
    if(g_installed) {
        
        NSMutableArray *stackArray = [NSMutableArray arrayWithArray:[[RTCrashReporter shareObject].crashThreadInfo.stackTrace componentsSeparatedByString:@"\n"]];
        if ([stackArray count] <= 2) {
            stackArray = [[NSThread callStackSymbols] mutableCopy];
        }
        NSString *stack=[NSString stringWithFormat:@"callStackSymbols: {\n%@}\n",[stackArray componentsJoinedByString:@"\n"]];
        NSMutableString *lagM = [NSMutableString string];
        [lagM appendFormat:@"\n(C 崩溃堆栈):\n%@",stack];
        
        if (![NSThread isMainThread]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                RTCrashModel *model = [RTCrashModel new];
                model.crashStack = lagM.copy;
                model.imagePath = [RTOperationImage saveCrash:[[RTViewHierarchy new] snap:nil type:0]];
                model.vcStack = [[RTVCLearn shareInstance] traceString];
                model.operationStack = [[RTSearchVCPath shareInstance] traceOperation];
                [[RTCrashLag shareInstance] addCrash:model];
            });
        }else{
            RTCrashModel *model = [RTCrashModel new];
            model.crashStack = lagM.copy;
            model.imagePath = [RTOperationImage saveCrash:[[RTViewHierarchy new] snap:nil type:0]];
            model.vcStack = [[RTVCLearn shareInstance] traceString];
            model.operationStack = [[RTSearchVCPath shareInstance] traceOperation];
            [[RTCrashLag shareInstance] addCrash:model];
        }
        
        rt_uninstallSignalHandler();//恢复其他SDK注册的信号量回调函数
    }
    raise(sigNum);//向自己再次发信号量
}

bool rt_installSignalHandler(void) {

    if(g_installed) {
        return true;
    }
    g_installed = 1;
    
    if(g_signalStack.ss_size == 0) {
        g_signalStack.ss_size = SIGSTKSZ;
        g_signalStack.ss_sp = malloc(g_signalStack.ss_size);
    }
    
    if(sigaltstack(&g_signalStack, NULL) != 0) {
        goto failed;
    }
    
    const int* fatalSignals = g_fatalSignals;
    int fatalSignalsCount = g_fatalSignalsCount;
    
    if(g_previousSignalHandlers == NULL) {
        g_previousSignalHandlers = malloc(sizeof(*g_previousSignalHandlers)
                                          * (unsigned)fatalSignalsCount);
    }
    
    struct sigaction action = {{0}};
    action.sa_flags = SA_SIGINFO | SA_ONSTACK;
#ifdef __LP64__
    action.sa_flags |= SA_64REGSET;
#endif
    sigemptyset(&action.sa_mask);
    action.sa_sigaction = &rt_signalHandler;
    
    for(int i = 0; i < fatalSignalsCount; i++) {
        if(sigaction(fatalSignals[i], &action, &g_previousSignalHandlers[i]) != 0) {
            char sigNameBuff[30];
            const char* sigName = rt_signal_signalName(fatalSignals[i]);
            if(sigName == NULL) {
                snprintf(sigNameBuff, sizeof(sigNameBuff), "%d", fatalSignals[i]);
            }
            for(i--;i >= 0; i--) {
                sigaction(fatalSignals[i], &g_previousSignalHandlers[i], NULL);
            }
            goto failed;
        }
    }
    return true;
    
failed:
    g_installed = 0;
    return false;
}

void rt_uninstallSignalHandler(void) {
    if(!g_installed) {
        return;
    }
    const int* fatalSignals = g_fatalSignals;
    int fatalSignalsCount = g_fatalSignalsCount;
    
    for(int i = 0; i < fatalSignalsCount; i++) {
        sigaction(fatalSignals[i], &g_previousSignalHandlers[i], NULL);
    }
    g_installed = 0;
}
