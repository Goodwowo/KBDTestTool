
#import "RTTcping.h"
#import "RTBaseLib.h"
#include <mach/mach.h>

@implementation RTTcping

static const int ping_default_time = 2000; //ms

+ (RTTcping *)sharedObj {
    static dispatch_once_t pred = 0;
    __strong static RTTcping * _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTTcping alloc] init];
    });
    return _sharedObject;
}

+ (NSString *)getDefaultPingAddress{
    NSMutableString *pingAddressStrM = [[NSMutableString alloc] init];
    [pingAddressStrM appendString:@"http://"];
    [pingAddressStrM appendString:@"www."];
    [pingAddressStrM appendString:@"baidu."];
    [pingAddressStrM appendString:@"com"];
    [pingAddressStrM appendString:@":80"];
    return pingAddressStrM;
}

- (int)tcpingDefaultHost {
    
    //500毫秒以内不重复取值
    static uint32_t ppi_time = 0;
    static int ms = 0;
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    uint32_t now = mach_absolute_time() * timebase.numer / timebase.denom /1e6;
    if (ppi_time == 0 || (now - ppi_time) > 2000) {
        
        NSString *url = [RTTcping getDefaultPingAddress];
        NSURL * nsurl = [NSURL URLWithString:url];
        if ( !nsurl && [nsurl host] && [nsurl port]) {
            return ping_default_time;
        }
        int timeout = ping_default_time;
        ms = [self tcpingWithHost:[nsurl host]
                                 port:[[nsurl port] intValue]
                              timeout:ping_default_time];
        //如果超时则 再ping 一次，避免网络偶尔抖动的误报
        if(ms >= timeout){
            int ms2 = [self tcpingWithHost:[nsurl host]
                                      port:[[nsurl port] intValue]
                                   timeout:timeout];
            
            if(ms2 < ms) {//ping 两次，取最短时间的那次
                ms = ms2;
            }
        }
        if (ms > timeout) {
            ms = timeout;
        }
        
        ppi_time = now;
    }
    
    return ms;
}

/**ping主机,参数timeout单位为ms*/
- (int) tcpingWithHost:(NSString*)host port:(int)port timeout:(int)timeout {

    static struct rt_addr addr_storage = {0};
    static struct rt_addr addr6_storage = {0};

    struct rt_addr addr;
    //减少dns次数
    if (addr_storage.addr_veriosn == rt_addr_IPV4 &&
        rt_ipv6works() == rt_addr_IPV4) {
        addr = addr_storage;
    } else if (addr6_storage.addr_veriosn == rt_addr_IPV6 &&
               rt_ipv6works() == rt_addr_IPV6) {
        addr = addr6_storage;
    } else {
        addr = rt_hostToIp(host);
        if (addr.addr_veriosn == rt_addr_IPV4 &&
            addr_storage.addr_veriosn == rt_addr_NONE) {
            addr_storage = addr;
        } else if (addr.addr_veriosn == rt_addr_IPV6 &&
                   addr6_storage.addr_veriosn == rt_addr_NONE) {
            addr6_storage = addr;
        }
    }

    CFSocketRef cfsocket = NULL;
    CFDataRef address = NULL;

    if (addr.addr_veriosn == rt_addr_NONE) {
        return ping_default_time;
    }

    if (addr.addr_veriosn == rt_addr_IPV4) {
        //创建socket
        cfsocket = CFSocketCreate(kCFAllocatorDefault,
                                  PF_INET,
                                  SOCK_STREAM,
                                  IPPROTO_TCP,
                                  kCFSocketNoCallBack,
                                  NULL,
                                  NULL);
        if( cfsocket == NULL ) {
            return ping_default_time;
        }
        
        struct sockaddr_in addr4;
        memset(&addr4,0,sizeof(addr4));
        addr4.sin_len = sizeof(addr4);
        addr4.sin_family = AF_INET;
        addr4.sin_port = htons(port);
        addr4.sin_addr.s_addr = addr.in_addr.__u6_addr.__u6_addr32[3];
        address = CFDataCreate(kCFAllocatorDefault,
                                         (uint8_t*)&addr4,
                                         sizeof(addr4));
    } else if (addr.addr_veriosn == rt_addr_IPV6){
        //创建socket
        cfsocket = CFSocketCreate(kCFAllocatorDefault,
                                  PF_INET6,
                                  SOCK_STREAM,
                                  IPPROTO_TCP,
                                  kCFSocketNoCallBack,
                                  NULL,
                                  NULL);
        if( cfsocket == NULL ) {
            return ping_default_time;
        }
        
        struct sockaddr_in6 addr6;
        memset(&addr6,0,sizeof(addr6));
        addr6.sin6_len = sizeof(addr6);
        addr6.sin6_family = AF_INET6;
        addr6.sin6_port = htons(port);
        addr6.sin6_addr = addr.in_addr;
        address = CFDataCreate(kCFAllocatorDefault,
                               (uint8_t *)&addr6,
                               sizeof(addr6));
    }

    CFTimeInterval cftimeout = timeout/1000.0;

    if (NULL == address) {
        if (cfsocket) {
            CFSocketInvalidate(cfsocket);
            CFRelease(cfsocket);
            cfsocket = NULL;
        }
        return ping_default_time;
    }
    
    uint64_t beginTime = rt_cpu_time_ms();
    CFSocketError theErr = CFSocketConnectToAddress(cfsocket,
                                                    address,
                                                    cftimeout);
    uint64_t endTime = rt_cpu_time_ms();
    uint64_t cost = endTime - beginTime;
    if( theErr == kCFSocketSuccess ) {
//        NSLog(@"connect success cost:%llu ms!", cost);
    } else {
//        NSLog(@"connect faild cost:%llu ms", cost);
        cost = ping_default_time;
    }
    
    //释放资源
    //close(CFSocketGetNative(cfsocket));
    CFRelease(address);
    address = NULL;
    CFSocketInvalidate(cfsocket);
    CFRelease(cfsocket);
    cfsocket = NULL;
    
    return (int)cost;
}

@end

