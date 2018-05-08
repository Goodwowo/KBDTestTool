
#import <Foundation/Foundation.h>
#import "RTCrashThreadInfo.h"
#import <mach/mach_types.h>
#import <mach-o/dyld.h>

#define RTLOG NSLog(@"%@",[RTCrashReporter rt_backtraceOfCurrentThread]);
#define RTLOG_MAIN NSLog(@"%@",[RTCrashReporter rt_backtraceOfMainThread]);
#define RTLOG_ALL NSLog(@"%@",[RTCrashReporter rt_backtraceOfAllThread]);

@interface RTCrashReporter : NSObject
//主线程id，用于卡顿监测，产生实时的堆栈信息
@property (nonatomic, assign) thread_t mainThreadId;
@property (nonatomic, copy) NSString *causeBy;
//是否为卡顿
@property (nonatomic, assign) BOOL isLag;
@property (nonatomic, copy) NSString *processName;
@property (nonatomic, copy) NSString *dSYMUUID;
@property (nonatomic, copy) NSString *baseAddress;
@property (nonatomic, strong) RTCrashThreadInfo *crashThreadInfo;
@property (nonatomic, strong) NSMutableArray<RTCrashThreadInfo *> *otherThreadInfos;
@property (nonatomic, copy) NSArray *callStackAddressArr;
@property (nonatomic, assign) const struct mach_header *imageHeader;
@property (atomic, strong) NSLock *crashLock;
@property (nonatomic, assign)_STRUCT_MCONTEXT lagMachineContext;
@property (nonatomic, assign) thread_t crashThread;

/**崩溃报告实例*/
+ (instancetype)shareObject;
/**产生实时的堆栈信息*/
+ (NSString *)generateLiveReport:(BOOL)isLiveReport;

+ (void)start;

+ (NSMutableArray<RTCrashThreadInfo *> *)rt_backtraceOfAllThread;
+ (RTCrashThreadInfo *)rt_backtraceOfMainThread;
+ (RTCrashThreadInfo *)rt_backtraceOfCurrentThread;
+ (BOOL)rt_storeLagMachineContext;
RTCrashThreadInfo *_rt_backtraceOfThread(thread_t thread);


- (NSString *)getDSYMUUID;
- (NSString *)getBaseAddress;

@end
