
#import "RTThreadDeadlockMonitor.h"
#import "RTReporter.h"
#import <mach/mach_time.h>
#import "RTCrashReporter.h"
#import "RTCrashLag.h"
#import "ZHStatusBarNotification.h"
#import "RTOperationImage.h"
#import "RTViewHierarchy.h"
#import "RecordTestHeader.h"

typedef NS_ENUM(NSUInteger, RTThreadState) {
    NOT_STUCK,
    STUCK
};

static dispatch_semaphore_t mainThreadMonitorSemaphore;
static CFRunLoopActivity runLoopActivity;
static RTThreadState previousState;
static BOOL isRuning;
static uint64_t lastTrick = 0;

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void* info){
    runLoopActivity = activity;
    lastTrick = mach_absolute_time();
    dispatch_semaphore_signal(mainThreadMonitorSemaphore);
}

@implementation RTThreadDeadlockMonitor

+ (instancetype)shareObj{
    static RTThreadDeadlockMonitor* threadMonitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!threadMonitor) {
            threadMonitor = [[RTThreadDeadlockMonitor alloc] init];
            isRuning = YES;
            // app从后台进入前台都会调用这个方法
            [[NSNotificationCenter defaultCenter] addObserver:threadMonitor selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
            // 添加检测app进入后台的观察者
            [[NSNotificationCenter defaultCenter] addObserver:threadMonitor selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
        }
    });
    return threadMonitor;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationBecomeActive{
    if (!isRuning) {
        isRuning = YES;
    }
}

- (void)applicationEnterBackground{
    if (isRuning) {
        isRuning = NO;
    }
}

- (void)startThreadMonitor{

    //卡顿阀值，默认为5s
//    float __block lagInterval = 5;
    //前一次卡顿检测状态
    previousState = NOT_STUCK;
    //非交互性卡顿
    __block BOOL isNotEventStuck = NO;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainThreadMonitorSemaphore = dispatch_semaphore_create(0);
        CFRunLoopObserverContext context = { 0, NULL, NULL, NULL };
        CFRunLoopObserverRef runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,
            kCFRunLoopAllActivities,
            YES,
            0,
            &runLoopObserverCallBack,
            &context);
        CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            while (YES) {
                //将卡顿判断阀值缩小0.01s，防止卡顿结束了才获取堆栈信息，此时堆栈信息不能准确的反映卡顿的方法调用情况
                long hadStuck = dispatch_semaphore_wait(mainThreadMonitorSemaphore, dispatch_time(DISPATCH_TIME_NOW, ([RTConfigManager shareInstance].lagThreshold - 0.01) * NSEC_PER_SEC));
                uint64_t localLastTrick = lastTrick;

                //卡顿时长达到阀值并且agent处于运行状态、app未处于crash状态，则收集卡顿信息，否则不收集
                if (hadStuck) {

                    //判断卡顿状态是否已经解除，如果已经解除，此时获取的堆栈将不能准确定位卡顿位置，所以此时不计入该卡顿数据；如未解除，获取当前线程状态，用于后面的堆栈获取;
                    if (localLastTrick && localLastTrick == lastTrick) {
                        [RTCrashReporter rt_storeLagMachineContext];
                    } else {
                        continue;
                    }

                    //判断是否为非人机交互导致的卡顿
                    if (!CFRunLoopIsWaiting(CFRunLoopGetMain())) {
                        isNotEventStuck = YES;
                    }

                    //上一个状态处于未卡顿状态则收集数据，否则不收集，防止同一个卡顿收集并回传多次
                    if (isRuning && (runLoopActivity == kCFRunLoopBeforeSources || runLoopActivity == kCFRunLoopAfterWaiting || isNotEventStuck == YES) && previousState == NOT_STUCK) {

                        //设置卡顿状态
                        previousState = STUCK;

                        //重置非交互性卡顿标志
                        isNotEventStuck = NO;

                        NSString* stackTrace = [RTCrashReporter generateLiveReport:YES];
                        NSArray* callStacks = [stackTrace componentsSeparatedByString:@"\n"];
                        NSString* causeBy = ([callStacks firstObject] == NULL) ? @"unKnown reason" : [callStacks firstObject];
                        NSString* callStackStr = [NSString stringWithFormat:@"callStackSymbols: {\n%@}\n", stackTrace];
                        
                        NSMutableString *lagM = [NSMutableString string];
                        if (stackTrace && stackTrace.length>0) {
                            if(causeBy.length>0)[lagM appendFormat:@"causeBy = \n%@\n",causeBy];
                            if(callStackStr.length>0)[lagM appendFormat:@"callStackStr = \n%@\n",callStackStr];
                        }
                        RTCrashThreadInfo *mainThread = [RTCrashReporter rt_backtraceOfMainThread];
                        if (mainThread && mainThread.description.length>0) {
                            [lagM appendFormat:@"MainThread(线程):\n%@",mainThread];
                        }
                        for (RTCrashThreadInfo *info in [RTCrashReporter rt_backtraceOfAllThread]) {
                            [lagM appendFormat:@"\n\nThread(线程):\n%@",info];
                        }
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            RTLagModel *model = [RTLagModel new];
                            model.lagStack = lagM.copy;
                            model.vcStack = [[RTVCLearn shareInstance] traceString];
                            model.imagePath = [RTOperationImage saveLag:[[RTViewHierarchy new] snap:nil type:0]];
                            model.operationStack = [[RTSearchVCPath shareInstance] traceOperation];
                            [[RTCrashLag shareInstance] addLag:model];
                        });
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [ZHStatusBarNotification showWithStatus:@"发生卡顿" dismissAfter:1 styleName:JDStatusBarStyleError];
                        });
                    }
                } else {
                    //卡顿结束
                    if (previousState == STUCK) {
                        //do nothing
                    }
                    //重置卡顿状态
                    previousState = NOT_STUCK;
                }
            }
        });
    });
}

@end
