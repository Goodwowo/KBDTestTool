
#import "RTDeviceDetailInfo.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <resolv.h>
#import <sys/ioctl.h>
#import "RTReachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation RTDeviceDetailInfo

+ (NSString *)phoneSystemVersion{
    return [[UIDevice currentDevice] systemVersion];
}

+ (BOOL)jailbrokenDevice{
    BOOL jailbroken = NO;
    NSString * cydiaPath = @"/Applications/Cydia.app";
    NSString * aptPath = @"/private/var/lib/apt";
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath] || [[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    return jailbroken;
}

+ (NSString*)wifiName{
    NSString* wifiName = @"当前没有连接Wifi";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary* dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiName = [dict valueForKey:@"SSID"];
        }
    }
    return wifiName;
}

+ (NSString*)deviceIpAddress{
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    NSMutableArray* ips = [NSMutableArray array];
    int BUFFERSIZE = 4096;
    struct ifconf ifc;
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifreq *ifr, ifrcopy;
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) >= 0) {
        for (ptr = buffer; ptr < buffer + ifc.ifc_len;) {
            ifr = (struct ifreq*)ptr;
            int len = sizeof(struct sockaddr);
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            ptr += sizeof(ifr->ifr_name) + len;
            if (ifr->ifr_addr.sa_family != AF_INET)
                continue;
            if ((cptr = (char*)strchr(ifr->ifr_name, ':')) != NULL)
                *cptr = 0;
            if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0)
                continue;
            
            memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
            ifrcopy = *ifr;
            ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
            
            if ((ifrcopy.ifr_flags & IFF_UP) == 0)
                continue;
            
            NSString* ip = [NSString stringWithFormat:@"%s", inet_ntoa(((struct sockaddr_in*)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    
    close(sockfd);
    NSString* deviceIP = @"";
    
    for (int i = 0; i < ips.count; i++) {
        if (ips.count > 0) {
            deviceIP = [NSString stringWithFormat:@"%@", ips.lastObject];
        }
    }
    return deviceIP;
}

+ (NSString*)localWifiIpAddress{
    BOOL success;
    struct ifaddrs* addrs;
    const struct ifaddrs* cursor;
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) {
                NSString* name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in*)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return @"当前没有连接Wifi";
}

+ (NSString*)domainNameSystemIp{
    res_state res = (res_state)malloc(sizeof(struct __res_state));
    __uint32_t dwDNSIP = 0;
    int result = res_ninit(res);
    if (result == 0) {
        dwDNSIP = res->nsaddr_list[0].sin_addr.s_addr;
    }
    free(res);
    NSString* dns = [NSString stringWithUTF8String:inet_ntoa(res->nsaddr_list[0].sin_addr)];
    return dns;
}

+ (NSString*)telephonyCarrier{
    CTTelephonyNetworkInfo* networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier* carrier = [networkInfo subscriberCellularProvider];
    if (!carrier.isoCountryCode) {
        return @"没有SIM卡--无运营商";
    }
    return [carrier carrierName];
}

+ (NSString*)networkType{
    NSString* netconnType = @"";
    RTReachability* reach = [RTReachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:{ // 没有网络
            netconnType = @"no network";
        } break;
        case ReachableViaWiFi: {
            netconnType = @"Wifi";
        } break;
        case ReachableViaWWAN: // 手机自带网络
        {
            // 获取手机网络类型
            CTTelephonyNetworkInfo* info = [[CTTelephonyNetworkInfo alloc] init];
            
            NSString* currentStatus = info.currentRadioAccessTechnology;
            
            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                
                netconnType = @"GPRS";
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                
                netconnType = @"2.75G EDGE";
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]) {
                
                netconnType = @"3G";
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]) {
                
                netconnType = @"3.5G HSDPA";
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]) {
                
                netconnType = @"3.5G HSUPA";
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]) {
                
                netconnType = @"2G";
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]) {
                
                netconnType = @"3G";
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]) {
                
                netconnType = @"3G";
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]) {
                
                netconnType = @"3G";
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]) {
                
                netconnType = @"HRPD";
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]) {
                
                netconnType = @"4G";
            }
        } break;
        default:
            break;
    }
    return netconnType;
}

+ (NSString*)applicationDisplayName{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
}

+ (NSString*)applicationVersion{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

@end
