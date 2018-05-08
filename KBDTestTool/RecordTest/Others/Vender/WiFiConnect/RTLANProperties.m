
#import "RTDeviceModel.h"
#import "RTLANProperties.h"
#import "RTNetworkCalculator.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <netdb.h>

@implementation RTLANProperties

#pragma mark - Public methods
+ (RTDeviceModel*)localIPAddress{

    RTDeviceModel* localDevice = [[RTDeviceModel alloc] init];

    localDevice.ipAddress = @"error";

    struct ifaddrs* interfaces = NULL;
    struct ifaddrs* temp_addr = NULL;
    int success = 0;

    success = getifaddrs(&interfaces);

    if (success == 0) {

        temp_addr = interfaces;

        while (temp_addr != NULL) {

            if (temp_addr->ifa_addr->sa_family == AF_INET) {

                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {

                    localDevice.ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in*)temp_addr->ifa_addr)->sin_addr)];
                    localDevice.subnetMask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in*)temp_addr->ifa_netmask)->sin_addr)];
                    localDevice.hostname = [self getHostFromIPAddress:localDevice.ipAddress];
                }
            }

            temp_addr = temp_addr->ifa_next;
        }
    }

    freeifaddrs(interfaces);

    if ([localDevice.ipAddress isEqualToString:@"error"]) {

        return nil;
    }

    return localDevice;
}

+ (NSString*)fetchSSIDInfo{

    NSArray* ifs = (__bridge_transfer NSArray*)CNCopySupportedInterfaces();

    NSDictionary* info;

    for (NSString* ifnam in ifs) {

        info = (__bridge_transfer NSDictionary*)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);

        if (info && [info count]) {

            return [info objectForKey:@"SSID"];
            break;
        }
    }

    return @"No WiFi Available";
}
+ (NSArray*)getAllHostsForIP:(NSString*)ipAddress andSubnet:(NSString*)subnetMask{
    return [RTNetworkCalculator getAllHostsForIP:ipAddress andSubnet:subnetMask];
}

#pragma mark - Get Host from IP
+ (NSString*)getHostFromIPAddress:(NSString*)ipAddress{
    struct addrinfo* result = NULL;
    struct addrinfo hints;

    memset(&hints, 0, sizeof(hints));
    hints.ai_flags = AI_NUMERICHOST;
    hints.ai_family = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = 0;

    int errorStatus = getaddrinfo([ipAddress cStringUsingEncoding:NSASCIIStringEncoding], NULL, &hints, &result);
    if (errorStatus != 0) {
        return nil;
    }

    CFDataRef addressRef = CFDataCreate(NULL, (UInt8*)result->ai_addr, result->ai_addrlen);
    if (addressRef == nil) {
        return nil;
    }
    freeaddrinfo(result);

    CFHostRef hostRef = CFHostCreateWithAddress(kCFAllocatorDefault, addressRef);
    if (hostRef == nil) {
        return nil;
    }
    CFRelease(addressRef);

    BOOL succeeded = CFHostStartInfoResolution(hostRef, kCFHostNames, NULL);
    if (!succeeded) {
        return nil;
    }

    NSMutableArray* hostnames = [NSMutableArray array];

    CFArrayRef hostnamesRef = CFHostGetNames(hostRef, NULL);
    for (int currentIndex = 0; currentIndex < [(__bridge NSArray*)hostnamesRef count]; currentIndex++) {
        [hostnames addObject:[(__bridge NSArray*)hostnamesRef objectAtIndex:currentIndex]];
    }

    return hostnames[0];
}

@end
