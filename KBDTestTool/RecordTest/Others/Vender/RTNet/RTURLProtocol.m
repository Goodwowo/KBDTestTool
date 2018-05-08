
#import "RTURLProtocol.h"
#include <arpa/inet.h>
#import "RTNetResult.h"
#import <mach/mach_time.h>
#import <zlib.h>
#import <resolv.h>
#import <netdb.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netinet/in.h>
#import <dns_sd.h>
#import "RTDeviceDetailInfo.h"
#import "DateTools.h"

#define StringInt(value) [NSString stringWithFormat:@"%ld",(long)value]

static NSString *localIp(){
    struct ifaddrs *ifa, *ifa_tmp;
    char addr[50];
    
    if (getifaddrs(&ifa) == -1) {
        perror("getifaddrs failed");
        exit(1);
    }
    NSMutableDictionary *ips = [NSMutableDictionary dictionaryWithCapacity:2];
    NSString *address = nil;
    ifa_tmp = ifa;
    while (ifa_tmp) {
        if ((ifa_tmp->ifa_addr) && ((ifa_tmp->ifa_addr->sa_family == AF_INET) ||
                                    (ifa_tmp->ifa_addr->sa_family == AF_INET6))) {
            if (ifa_tmp->ifa_addr->sa_family == AF_INET) {
                struct sockaddr_in *in = (struct sockaddr_in*) ifa_tmp->ifa_addr;
                inet_ntop(AF_INET, &in->sin_addr, addr, sizeof(addr));
            } else {
                struct sockaddr_in6 *in6 = (struct sockaddr_in6*) ifa_tmp->ifa_addr;
                inet_ntop(AF_INET6, &in6->sin6_addr, addr, sizeof(addr));
            }
            NSString *name = [NSString stringWithFormat:@"%s",ifa_tmp->ifa_name];
            address = [NSString stringWithFormat:@"%s",addr];
            if ([name isEqualToString:@"en0"] || [name isEqualToString:@"pdp_ip0"]) {
                [ips setValue:address forKey:name];
            }
        }
        ifa_tmp = ifa_tmp->ifa_next;
    }
    if (ips[@"en0"]) return ips[@"en0"];//wifi Ip
    if (ips[@"pdp_ip0"]) return ips[@"pdp_ip0"];//蜂窝移动数据 Ip
    return nil;
}

static NSString *targetIp(NSString *urlString){
    NSURL* url = [NSURL URLWithString:urlString];
    struct hostent* hs;
    struct sockaddr_in server;
    static NSMutableDictionary *cache = nil;
    if(cache == nil) cache = [NSMutableDictionary dictionary];
    if (url.host.length > 0) {
        id ipCache = cache[url.host];
        if (ipCache) return ipCache;
        if ((hs = gethostbyname([url.host UTF8String])) != NULL) {
            server.sin_addr = *((struct in_addr*)hs->h_addr_list[0]);
            NSString *ip = [NSString stringWithUTF8String:inet_ntoa(server.sin_addr)];
            if (ip.length>0) {
                [cache setValue:ip forKey:url.host];
            }
            return ip;
        }
    }
    return @"";
}

static void queryCallback(DNSServiceRef sdRef,
                          DNSServiceFlags flags,
                          uint32_t interfaceIndex,
                          DNSServiceErrorType errorCode,
                          const char *fullname,
                          uint16_t rrtype,
                          uint16_t rrclass,
                          uint16_t rdlen,
                          const void *rdata,
                          uint32_t ttl,
                          void *context) {
    if (errorCode == kDNSServiceErr_NoError && rdlen > 1) {
        NSMutableData *txtData = [NSMutableData dataWithCapacity:rdlen];
        
        for (uint16_t i = 1; i < rdlen; i += 256) {
            [txtData appendBytes:rdata + i length:MIN(rdlen - i, 255)];
        }
        
        NSMutableString *lastCName = [NSMutableString string];
        NSString *theTXT = [[NSString alloc] initWithBytes:txtData.bytes length:txtData.length encoding:NSASCIIStringEncoding];
        for (NSInteger i=0; i<theTXT.length; i++) {
            char ch = [theTXT characterAtIndex:i];
            if (ch < 32 && ch != '\0'){
                [lastCName appendString:@"."];
            }else{
                [lastCName appendFormat:@"%c",ch];
            }
        }
        NetResult *netResult = (__bridge NetResult *)(context);
        netResult.lastCname = lastCName;
    }
}

static void getCNAME(NSString *host,id obj) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DNSServiceRef serviceRef;
        DNSServiceErrorType error;
        void *temp = (__bridge void *)obj;
        error = DNSServiceQueryRecord(&serviceRef, 0, 0, [host UTF8String], kDNSServiceType_CNAME,kDNSServiceClass_IN, queryCallback, temp);
        if (error != kDNSServiceErr_NoError) NSLog(@"DNS Service error");
        DNSServiceProcessResult(serviceRef);
        DNSServiceRefDeallocate(serviceRef);
    });
}

static uint32_t dnsServerIp(){
    uint32_t ip = 0;
    struct __res_state res = {0};
    
    int result = res_ninit(&res);
    if (result == 0) {
        if (res.nscount > 0) {
            union res_sockaddr_union addr_union = {0};
            res_getservers(&res, &addr_union, 1);
            
            if (addr_union.sin.sin_family == AF_INET) {
                ip = addr_union.sin.sin_addr.s_addr;
            } else if (addr_union.sin6.sin6_family == AF_INET6) {
                //ipv6暂时不取
                ip = 0;
            } else {
                ip = 0;
            }
        }
    }
    res_ndestroy(&res);
    
    return ip;
}

/**用来区分用户发起的是那种请求*/
typedef NS_ENUM(NSUInteger, NSURLSessionTaskType) {
    NSURLSessionTaskTypeData     = 0,
    NSURLSessionTaskTypeUpload   = 1,
    NSURLSessionTaskTypeDownload = 2,
    NSURLSessionTaskTypeStream   = 3
};

static NSString *URLProtocolHandledKey = @"BRSURLProtocolHandled";
static NSString *RNCachingURLHeader = @"bonreeNetwork";

@interface RTURLProtocol () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionTask * task;
@property (nonatomic, assign) NSURLSessionTaskType sessionTaskType;//用来区分用户发起的是那种请求
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) NSString *startTimeUs;
@property (nonatomic, copy) NSString * endTimeUs;
@property (nonatomic, strong) NetResult *netResultModel;

@end

@implementation RTURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest*)request{
    //只处理iOS 10
    if (!IS_IOS(10)) return NO;
    //不抓获localhost性能数据
    NSString *requestUrl = request.URL.absoluteString;
    //简单排除一些异常url
    if (([requestUrl rangeOfString:@"http://"].location == NSNotFound
         && [requestUrl rangeOfString:@"https://"].location == NSNotFound)//不包含http://且不包含https://不做代理
        || ([requestUrl rangeOfString:@"."].location == NSNotFound) //一般带'.'
        || [requestUrl length] <= 10 //一般长度大于10
        ) {
        return NO;
    }
    NSString *host = request.URL.host;
    if ([host hasPrefix:@"localhost"] || [host hasPrefix:@"127.0.0.1"]) {
        return NO;
    }
    NSString *scheme = [[request URL] scheme];
    if((nil != scheme) && ([request valueForHTTPHeaderField:RNCachingURLHeader] != nil)){
        return NO;
    }
    //只处理http和https请求
    if (([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame || [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame)) {
        //防止死循环
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (instancetype)initWithTask:(NSURLSessionTask *)task cachedResponse:(nullable NSCachedURLResponse *)cachedResponse client:(nullable id <NSURLProtocolClient>)client{
    self = [super initWithTask:task cachedResponse:cachedResponse client:client];
    //获取到原来请求的类型,保存起来
    if (self != nil) {
        if ([task isKindOfClass:[NSURLSessionDataTask class]]) self.sessionTaskType = NSURLSessionTaskTypeData;
        if ([task isKindOfClass:[NSURLSessionUploadTask class]]) self.sessionTaskType = NSURLSessionTaskTypeUpload;
        if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) self.sessionTaskType = NSURLSessionTaskTypeDownload;
        if ([task isKindOfClass:[NSURLSessionStreamTask class]]) self.sessionTaskType = NSURLSessionTaskTypeStream;
    }
    return self;
}

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)request{
    return [request mutableCopy];
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest*)a toRequest:(NSURLRequest*)b{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading{
    
    self.netResultModel = [NetResult new];
    NSMutableURLRequest *requestM = [self.request mutableCopy];
    //标示改request已经处理过了，防止无限循环
    [NSURLProtocol setProperty:@(YES) forKey:URLProtocolHandledKey inRequest:requestM];
    NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    self.session = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:queue];
    
    //根据之前保存的类型,进行不同类型的请求(拦截后,重新发起请求,都用NSURLSession发起请求)
    switch (self.sessionTaskType) {
        case NSURLSessionTaskTypeData:self.task = [self.session dataTaskWithRequest:requestM]; break;
        case NSURLSessionTaskTypeUpload:self.task = [self.session uploadTaskWithStreamedRequest:requestM]; break;
        case NSURLSessionTaskTypeDownload:self.task = [self.session downloadTaskWithRequest:requestM]; break;
        case NSURLSessionTaskTypeStream:self.task = [self.session streamTaskWithHostName:self.request.URL.host port:[self.request.URL.port integerValue]]; break;
    }
    
    self.startTimeUs = [DateTools currentDate];
    [self.task resume];
}

- (void)stopLoading{
    
    [self.session invalidateAndCancel];
    self.session = nil;
    
    [self.task cancel];
    self.task = nil;
    
    [[RTNetResult shareInstance]addNetResultSafe:self.netResultModel];
}


#pragma mark -- NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error != nil) {
        [self.client URLProtocol:self didFailWithError:error];
        self.netResultModel.errorId = [NSString stringWithFormat:@"%ld",(long)error.code];//errorId 错误ID(标准HTTP响应码和自定义响应码)
    }else{
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    //通知URL Loading system；connection相关操作放在该方法之前完成
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler{
    completionHandler(proposedResponse);
}

//重定向相关
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler{
    
    NSMutableURLRequest * redirectRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:URLProtocolHandledKey inRequest:redirectRequest];
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
    
    [self.task cancel];
    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0)){
    
    self.endTimeUs = [DateTools currentDate];
    NetResult *netResultModel = self.netResultModel;
    netResultModel.requestUrl = task.currentRequest.URL.absoluteString;//requestUrl 请求地址
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    self.netResultModel.errorId = @"200";
    if (response.statusCode != 200) self.netResultModel.errorId = [NSString stringWithFormat:@"%zd",response.statusCode];
    
    NSDictionary *requestHeader = task.currentRequest.allHTTPHeaderFields;
    if(requestHeader){
        NSData *data = [NSJSONSerialization dataWithJSONObject:requestHeader options:0 error:NULL];
        NSUInteger urlLenth = [[NSString stringWithFormat:@"%@",task.currentRequest.URL] dataUsingEncoding:NSUTF8StringEncoding].length;
        netResultModel.requestDataSize = StringInt((int32_t)(task.countOfBytesSent + data.length + urlLenth));//requestHeader 请求数据大小
    }
    
    NSMutableString *requestHeaderStrM = [NSMutableString string];
    NSString *host = [NSString stringWithFormat:@"%@",task.currentRequest.URL.host];
    NSString *sourcePath = [netResultModel.requestUrl substringFromIndex:[netResultModel.requestUrl rangeOfString:host].location + host.length];
    [requestHeaderStrM appendFormat:@"%@ %@ %@\n",task.currentRequest.HTTPMethod,sourcePath,@"HTTP/1.1"];
    [requestHeaderStrM appendFormat:@"Host: %@",host];
    for(NSString *key in requestHeader){
        NSString *value = requestHeader[key];
        if(value.length>0){
            [requestHeaderStrM appendFormat:@"\n%@: %@",key,value];
        }
    }
    netResultModel.requestHeader = requestHeaderStrM;
    
    NSDictionary *responseHeader = [response allHeaderFields];
    if(responseHeader){
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseHeader options:0 error:NULL];
        netResultModel.responseDataSize = StringInt((int32_t)(task.countOfBytesReceived + data.length));//responseDataSize 响应数据大小
        netResultModel.mimetype = [(NSHTTPURLResponse *)task.response MIMEType];//mimetype (2015.11.3新增)
    }
    
    NSMutableString *responseHeaderStrM = [NSMutableString string];
    //当响应码为200,表示请求正常,末尾不需要增加reason
    NSString *reason = response.statusCode == 200?@"":[[NSHTTPURLResponse localizedStringForStatusCode:response.statusCode] uppercaseString];
    [responseHeaderStrM appendFormat:@"%@ %zd %@",@"HTTP/1.1",response.statusCode,reason];
    for(NSString *key in responseHeader){
        NSString *value = responseHeader[key];
        if(value.length>0){
            [responseHeaderStrM appendFormat:@"\n%@: %@",key,value];
            if ([key isEqualToString:@"Content-Type"]) self.netResultModel.mimetype = value;
        }
    }
    netResultModel.responseHeader = responseHeaderStrM;

    if(task.currentRequest.URL.port){
        NSInteger port = [task.currentRequest.URL.port integerValue];
        netResultModel.targetPort = StringInt((int32_t)port);
    }
    if(netResultModel.targetPort == 0){
        netResultModel.targetPort = StringInt(([task.currentRequest.URL.scheme hasSuffix:@"s"] ? 443 : 80));//https: 443 , http: 80
    }
    
    if (task.currentRequest.mainDocumentURL != NULL) {
        netResultModel.isWebview = YES;//isWebview 是否Webview
    }
    
    if(![[NSThread currentThread] isMainThread]){
        netResultModel.isBackground = YES;//是否后台发生
    }
    netResultModel.targetIp   = targetIp(netResultModel.requestUrl);   //目标IP
    netResultModel.localIp    = localIp();   //本地IP
    
    netResultModel.lastCname  = @""; //暂时获取不到
    getCNAME(task.currentRequest.URL.host,netResultModel);
    
    netResultModel.netType      = [RTDeviceDetailInfo networkType];    //netType 网络类型
    netResultModel.dnsServerIp  = StringInt(dnsServerIp());             //dnsServerIp 手机localDNS的主DNS地址(2015.12.16新增聚美优品需求)

    netResultModel.startTimeUs = self.startTimeUs; //startTimeUs 请求起始时刻
    netResultModel.endTimeUs = self.endTimeUs; //endTimeUs 请求结束时刻
    
    for(NSURLSessionTaskTransactionMetrics *transactionMetrics in metrics.transactionMetrics){

        uint64_t requestStartDate  = floor([transactionMetrics.requestStartDate timeIntervalSince1970]*1000*1000);
        uint64_t requestEndDate    = floor([transactionMetrics.requestEndDate timeIntervalSince1970]*1000*1000);
        uint64_t responseStartDate = floor([transactionMetrics.responseStartDate timeIntervalSince1970]*1000*1000);
        uint64_t responseEndTime   = floor([transactionMetrics.responseEndDate timeIntervalSince1970]*1000*1000);
        uint64_t connectStartDate  = floor([transactionMetrics.connectStartDate timeIntervalSince1970]*1000*1000);
        uint64_t connectEndDate    = floor([transactionMetrics.connectEndDate timeIntervalSince1970]*1000*1000);
        uint64_t secureConnectionStartDate = floor([transactionMetrics.secureConnectionStartDate timeIntervalSince1970]*1000*1000);
        uint64_t secureConnectionEndDate   = floor([transactionMetrics.secureConnectionEndDate timeIntervalSince1970]*1000*1000);
        uint64_t domainLookupStartDate     = floor([transactionMetrics.domainLookupStartDate timeIntervalSince1970]*1000*1000);
        uint64_t domainLookupEndDate       = floor([transactionMetrics.domainLookupEndDate timeIntervalSince1970]*1000*1000);
        
        if (requestEndDate != 0 && requestStartDate != 0 && requestEndDate >= requestStartDate) {
            netResultModel.requestTimeUs = StringInt((int32_t)(requestEndDate - requestStartDate)); //requestTimeUs 请求时间
        }
        if (responseStartDate != 0 && requestEndDate != 0 && responseStartDate >= requestEndDate) {
            netResultModel.responseTimeUs = StringInt((int32_t)(responseStartDate - requestEndDate)); //responseTimeUs 响应时间
        }
        
        /*响应开始是首包结束时间，所以如果一个响应只有一个包，那么下载时间可能算出来为0
         这种情况设置下载时间为999us*/
        if ((responseEndTime == responseStartDate) && ((int32_t)(task.countOfBytesSent != 0))) {
            netResultModel.downloadTimeUs = StringInt(999);
        } else {
            netResultModel.downloadTimeUs = StringInt((int32_t)(responseEndTime - responseStartDate));
        }
        
        //connect time
        if (connectEndDate != 0 && connectStartDate != 0 && connectEndDate >= connectStartDate) {
            netResultModel.connectTimeUs = StringInt((uint32_t)(connectEndDate - connectStartDate)); //connectTimeUs tcp建连时间，需要确定有没有此项时间
        }
        //connect time异常时赋值为999us
        if ([netResultModel.connectTimeUs integerValue] >= 30000000 || netResultModel.connectTimeUs <= 0) {
            netResultModel.connectTimeUs = StringInt(999);
        }
        
        netResultModel.dnsTimeUs = StringInt((uint32_t)(domainLookupEndDate - domainLookupStartDate)); //dnsTimeUs dns查询时间，需要确定有没有此项时间，0为没有
        netResultModel.ssltimeUs = StringInt((uint32_t)(secureConnectionEndDate - secureConnectionStartDate)); //ssltime
    }
}

@end

//给defaultSessionConfiguration设置bonree的NSURLProtocol,目的是解决AFNetworking库不能被这个RTURLProtocol拦劫的问题
@implementation NSURLSessionConfiguration (rt_hook_ios10)

+ (NSURLSessionConfiguration *)rt_ios10_defaultSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration rt_ios10_defaultSessionConfiguration];
    
    NSMutableArray *protocolClasses = [NSMutableArray arrayWithArray:configuration.protocolClasses];
    [protocolClasses insertObject:[RTURLProtocol class] atIndex:0];
    configuration.protocolClasses = protocolClasses;
    
    return configuration;
}

@end

//给NSURLSession的sessionWithConfiguration方法设置bonree的NSURLProtocol,目的是解决AFNetworking库不能被这个RTURLProtocol拦劫的问题
@implementation NSURLSession (rt_hook_ios10)

+ (void)addProtocolForConfiguration_rt:(NSURLSessionConfiguration *)configuration{
    NSMutableArray *protocolClasses = [NSMutableArray arrayWithArray:configuration.protocolClasses];
    
    bool hasBonreeURLProtol = NO;
    id protocolClassTarget = nil;
    for (id protocolClass in protocolClasses) {
        if (protocolClass == [RTURLProtocol class]) {
            hasBonreeURLProtol = YES;
            protocolClassTarget = protocolClass;
            break;
        }
    }
    if (!hasBonreeURLProtol && [RTNetResult shareInstance].networkOn) {
        [protocolClasses insertObject:[RTURLProtocol class] atIndex:0];
    }else{
        if (![RTNetResult shareInstance].networkOn) {
            [protocolClasses removeObject:protocolClassTarget];
        }
    }
    configuration.protocolClasses = protocolClasses;
}

+ (NSURLSession *)rt_ios10_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration {
    [self addProtocolForConfiguration_rt:configuration];
    return [NSURLSession rt_ios10_sessionWithConfiguration:configuration];
}

+ (NSURLSession *)rt_ios10_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue {
    [self addProtocolForConfiguration_rt:configuration];
    return [NSURLSession rt_ios10_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

@end
