
#import <Foundation/Foundation.h>

@interface NetResult : NSObject

@property (nonatomic, copy) NSString* requestUrl;         //请求地址
@property (nonatomic, copy) NSString* localIp;           //本地IP
@property (nonatomic, copy) NSString* targetIp;          //目标IP
@property (nonatomic, copy) NSString* targetPort;        //目标端口
@property (nonatomic, copy) NSString* startTimeUs;       //请求起始时刻
@property (nonatomic, copy) NSString* dnsTimeUs;         //dns查询时间，需要确定有没有此项时间，0为没有
@property (nonatomic, copy) NSString* connectTimeUs;     //tcp建连时间，需要确定有没有此项时间
@property (nonatomic, copy) NSString* ssltimeUs;         //ssltime
@property (nonatomic, copy) NSString* requestTimeUs;     //请求时间
@property (nonatomic, copy) NSString* responseTimeUs;    //响应时间
@property (nonatomic, copy) NSString* downloadTimeUs;    //下载用时
@property (nonatomic, copy) NSString* endTimeUs;         //请求结束时刻
@property (nonatomic, copy) NSString* requestHeader;      //请求header
@property (nonatomic, copy) NSString* requestDataSize;   //请求数据大小
@property (nonatomic, copy) NSString* responseHeader;     //响应header
@property (nonatomic, copy) NSString* responseDataSize;  //响应数据大小（实际接收数据大小）
@property (nonatomic, copy) NSString* errorId;           //错误ID(标准HTTP响应码和自定义响应码)
@property (nonatomic, assign) BOOL isBackground;          //是否后台发生
@property (nonatomic, copy) NSString* mimetype;           //mimetype
@property (nonatomic, copy) NSString* dnsServerIp;       //手机localDNS的主DNS地址
@property (nonatomic, assign) BOOL isWebview;             //是否Webview
@property (nonatomic, copy) NSString* lastCname;          //最后一个Cname
@property (nonatomic, copy) NSString* netType;            //网络类型

@end

@interface RTNetResult : NSObject

+ (RTNetResult *)shareInstance;
- (void)addNetResultSafe:(NetResult *)netResult;
- (NSArray *)getNetResultsAndClear;
@property (nonatomic,assign)BOOL networkOn;
//启动Http数据获取
- (void)startHttpHook;
//停止数据获取
- (void)stopHook;

@end
