
#import "RTBaseLib.h"
#import <mach/mach_time.h>
#import <zlib.h>
#import <resolv.h>
#import <netdb.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netinet/in.h>
#import <dns_sd.h>

uint32_t rt_mach_time_to_ms(uint64_t time) {
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    return time * timebase.numer / timebase.denom /1e6;
}

uint32_t rt_cpu_time_ms() {
    return rt_mach_time_to_ms(mach_absolute_time());
}

unsigned char rt_ipv6works(void) {
    unsigned char ipv6_works = rt_addr_NONE;
    struct __res_state res = {0};
    
    int result = res_ninit(&res);
    if (result == 0) {
        if (res.nscount > 0) {
            union res_sockaddr_union addr_union = {0};
            res_getservers(&res, &addr_union, 1);
            
            if (addr_union.sin.sin_family == AF_INET) {
                ipv6_works = rt_addr_IPV4;
            } else if (addr_union.sin6.sin6_family == AF_INET6) {
                ipv6_works = rt_addr_IPV6;
            } else {
                ipv6_works = rt_addr_NONE;
            }
        }
    }
    res_ndestroy(&res);
    
    return ipv6_works;
}

struct rt_addr rt_hostToIp(NSString *hostname) {
    const char *hostN = [hostname UTF8String];
    struct hostent *phot;
    struct rt_addr addr = {0};
    
    if (rt_ipv6works() == rt_addr_IPV6) {
        addr.addr_veriosn = rt_addr_IPV6;
        @try {
            phot = gethostbyname2(hostN, AF_INET6);
        } @catch (NSException *exception) {
            addr.addr_veriosn = rt_addr_NONE;
            return addr;
        }
        if (phot && phot->h_addr_list) {
            memcpy(&(addr.in_addr), phot->h_addr_list[0], sizeof(struct in6_addr));
        }
    } else if (rt_ipv6works() == rt_addr_IPV4) {
        addr.addr_veriosn = rt_addr_IPV4;
        @try {
            phot = gethostbyname(hostN);
        } @catch (NSException *exception) {
            addr.addr_veriosn = rt_addr_NONE;
            return addr;
        }
        struct in_addr ip_addr;
        if (phot && phot->h_addr_list) {
            memcpy(&ip_addr, phot->h_addr_list[0], sizeof(struct in_addr));
        }
        addr.in_addr.__u6_addr.__u6_addr32[0] = 0;
        addr.in_addr.__u6_addr.__u6_addr32[1] = 0;
        addr.in_addr.__u6_addr.__u6_addr32[2] = 0;
        addr.in_addr.__u6_addr.__u6_addr32[3] = ip_addr.s_addr;
    } else if (rt_ipv6works() == rt_addr_NONE) {
        addr.addr_veriosn = rt_addr_NONE;
        return addr;
    }
    
    return addr;
}
