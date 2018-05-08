
#import "RTNetResult.h"
#import "RTURLProtocol.h"
#import <objc/runtime.h>

/**交换方法：交换父类方法*/
static void rt_methodSwizzle(Class class, SEL originalSelector, SEL swizzledSelector, BOOL isInstanceMethod) {
    
    Method originalMethod=nil;
    Method swizzledMethod=nil;
    if (isInstanceMethod) {
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    }else{
        originalMethod= class_getClassMethod(class, originalSelector);
        swizzledMethod= class_getClassMethod(class, swizzledSelector);
    }
    method_exchangeImplementations(originalMethod, swizzledMethod);
}


#pragma mark - NetResult
@implementation NetResult

- (NSString *)description{
    NSMutableString *text = [NSMutableString string];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"请求地址",self.requestUrl];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"目标IP",self.targetIp];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"目标端口",self.targetPort];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@(us)\n",@"请求起始时刻",self.startTimeUs];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@(us)\n",@"dns查询时间",self.dnsTimeUs];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@(us)\n",@"tcp建连时间",self.connectTimeUs];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@(us)\n",@"SSL time",self.ssltimeUs];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@(us)\n",@"请求时间",self.requestTimeUs];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@(us)\n",@"响应时间",self.responseTimeUs];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@(us)\n",@"下载用时",self.downloadTimeUs];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"请求结束时刻",self.endTimeUs];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"请求头\n",self.requestHeader];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"请求数据大小",self.requestDataSize];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"响应头\n",self.responseHeader];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"实际接收数据大小",self.responseDataSize];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"HTTP响应码",self.errorId];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"是否后台请求",self.isBackground?@"后台":@"不是后台"];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"mimetype",self.mimetype];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"手机localDNS",self.dnsServerIp];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"是否Webview请求",self.isWebview?@"是":@"不是"];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"最后一个Cname",self.lastCname];
    if (self.requestUrl.length>0) [text appendFormat:@"%@:%@\n",@"网络类型",self.netType];
    
    return text;
}

@end


#pragma mark - NetResult
@interface RTNetResult ()

@property (nonatomic,strong)NSMutableArray *netResults;
@property (nonatomic,strong)dispatch_semaphore_t semaphoreLock;

@end

@implementation RTNetResult

+ (RTNetResult *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTNetResult *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTNetResult alloc] init];
        _sharedObject.netResults = [NSMutableArray array];
        _sharedObject.semaphoreLock = dispatch_semaphore_create(1);
    });
    return _sharedObject;
}

- (void)addNetResultSafe:(NetResult *)netResult{
    dispatch_semaphore_wait(self.semaphoreLock,DISPATCH_TIME_FOREVER);
    if(netResult) [self.netResults addObject:netResult];
    dispatch_semaphore_signal(self.semaphoreLock);
}

- (NSArray *)getNetResultsAndClear{
    NSArray *netResults = nil;
    dispatch_semaphore_wait(self.semaphoreLock,DISPATCH_TIME_FOREVER);
    netResults = [NSArray arrayWithArray:self.netResults];
    dispatch_semaphore_signal(self.semaphoreLock);
    return netResults;
}

//启动Http数据获取
- (void)startHttpHook{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (IS_IOS(10)){
            [RTNetResult hook_defaultSessionConfiguration];
            [RTNetResult hook_sessionWithConfiguration];
            [RTNetResult hook_sessionWithConfigurationDelegate];
        }
    });
    if (IS_IOS(10)){
        self.networkOn = YES;
        [NSURLProtocol registerClass:[RTURLProtocol class]];
    }
}

//停止数据获取
- (void)stopHook{
    if (IS_IOS(10)) [NSURLProtocol unregisterClass:[RTURLProtocol class]];
}

+ (void)hook_defaultSessionConfiguration{
    if (IS_IOS(10)){
        rt_methodSwizzle([NSURLSessionConfiguration class],@selector(defaultSessionConfiguration), NSSelectorFromString(@"rt_ios10_defaultSessionConfiguration"), NO);
    }
}

+ (void)hook_sessionWithConfiguration{
    if (IS_IOS(10)){
        rt_methodSwizzle([NSURLSession class], @selector(sessionWithConfiguration:), NSSelectorFromString(@"rt_ios10_sessionWithConfiguration:"), NO);
    }
}

+ (void)hook_sessionWithConfigurationDelegate{
    if (IS_IOS(10)){
        rt_methodSwizzle([NSURLSession class], @selector(sessionWithConfiguration:delegate:delegateQueue:), NSSelectorFromString(@"rt_ios10_sessionWithConfiguration:delegate:delegateQueue:"), NO);
    }
}

@end
