
#import "RTMacFinder.h"

#define BUFLEN (sizeof(struct rt_msghdr) + 512)
#define SEQ 9999
#define RTM_VERSION	5	
#define RTM_GET	0x4	
#define RTF_LLINFO	0x400	
#define RTF_IFSCOPE 0x1000000 
#define RTA_DST	0x1	

@implementation RTMacFinder

#if TARGET_IPHONE_SIMULATOR
+(NSString*)ip2mac: (NSString*)strIP{
    return @"";
}
#else

+(NSString*)ip2mac: (NSString*)strIP {
    
    const char *ip = [strIP UTF8String];
    
    int sockfd;
    unsigned char buf[BUFLEN];
    unsigned char buf2[BUFLEN];
    ssize_t n;
    struct rt_msghdr *rtm;
    struct sockaddr_in *sin;
    memset(buf,0,sizeof(buf));
    memset(buf2,0,sizeof(buf2));
    
    sockfd = socket(AF_ROUTE, SOCK_RAW, 0);
    rtm = (struct rt_msghdr *) buf;
    rtm->rtm_msglen = sizeof(struct rt_msghdr) + sizeof(struct sockaddr_in);
    rtm->rtm_version = RTM_VERSION;
    rtm->rtm_type = RTM_GET;
    rtm->rtm_addrs = RTA_DST;
    rtm->rtm_flags = RTF_LLINFO;
    rtm->rtm_pid = 1234;
    rtm->rtm_seq = SEQ;
    
    
    sin = (struct sockaddr_in *) (rtm + 1);
    sin->sin_len = sizeof(struct sockaddr_in);
    sin->sin_family = AF_INET;
    sin->sin_addr.s_addr = inet_addr(ip);
    write(sockfd, rtm, rtm->rtm_msglen);
    
    n = read(sockfd, buf2, BUFLEN);
    close(sockfd);
    
    if (n != 0) {
        int index =  sizeof(struct rt_msghdr) + sizeof(struct sockaddr_inarp) + 8;
        NSString *macAddress =[NSString stringWithFormat:@"%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x",buf2[index+0], buf2[index+1], buf2[index+2], buf2[index+3], buf2[index+4], buf2[index+5]];
        if ([macAddress isEqualToString:@"00:00:00:00:00:00"] ||[macAddress isEqualToString:@"08:00:00:00:00:00"] ) {
            return nil;
        }
        return macAddress;
    }
    return nil;
}

#endif
@end
