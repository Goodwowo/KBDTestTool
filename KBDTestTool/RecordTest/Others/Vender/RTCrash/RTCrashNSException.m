
#import "RTCrashNSException.h"
#import "RTCrash.h"
#include <execinfo.h>
#import "RTReporter.h"
#import <mach/mach_init.h>
#import "RTCrashLag.h"
#import "RTOperationImage.h"
#import "RTViewHierarchy.h"
#import "RecordTestHeader.h"

static NSUncaughtExceptionHandler * s_previousUncaughtExceptionHandle = NULL;//其他SDK注册过NSSetUncaughtExceptionHandler的回调函数

static void rt_NSExceptionhandler(NSException *exception) {
    rt_uninstallExceptionHandler();
    
    [RTCrashReporter shareObject].callStackAddressArr = [exception callStackReturnAddresses];
    [RTCrashReporter shareObject].crashThread = mach_thread_self();
    NSString *stack= NULL;
    
    [RTCrashReporter rt_backtraceOfAllThread];
    stack = [NSString stringWithFormat:@"callStackSymbols: {\n%@}\n",[[RTCrashReporter shareObject].crashThreadInfo stackTrace]];
    NSString *reason = [exception reason];
    NSString *exceptionName = [exception name];
    NSMutableString *lagM = [NSMutableString string];
    
    if(reason.length>0)[lagM appendFormat:@"causeBy = \n%@\n",reason];
    if(exceptionName.length>0)[lagM appendFormat:@"exceptionName = \n%@\n",exceptionName];
    [lagM appendFormat:@"\n(崩溃堆栈):\n%@",stack];
    
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
    
    //调回其他SDK注册的崩溃回调函数
    if (s_previousUncaughtExceptionHandle) {
        s_previousUncaughtExceptionHandle(exception);
        s_previousUncaughtExceptionHandle = NULL;
    }
}
             
void rt_installNSExceptionHandler() {
    NSUncaughtExceptionHandler * uncaughtExceptionHandle = NSGetUncaughtExceptionHandler();
    if (uncaughtExceptionHandle == &rt_NSExceptionhandler) return;
    s_previousUncaughtExceptionHandle = uncaughtExceptionHandle;
    NSSetUncaughtExceptionHandler(&rt_NSExceptionhandler);
}

void rt_uninstallNSExceptionHandler() {
    if (s_previousUncaughtExceptionHandle) {
        NSSetUncaughtExceptionHandler(s_previousUncaughtExceptionHandle);
        return;
    }
    NSSetUncaughtExceptionHandler(NULL);
}
