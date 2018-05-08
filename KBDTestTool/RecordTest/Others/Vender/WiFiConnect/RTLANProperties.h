
#import <Foundation/Foundation.h>

@class RTDeviceModel;

@interface RTLANProperties : NSObject

+ (RTDeviceModel*)localIPAddress;

+ (NSString*)getHostFromIPAddress:(NSString*)ipAddress;

+ (NSArray*)getAllHostsForIP:(NSString*)ipAddress andSubnet:(NSString*)subnetMask;

+ (NSString*)fetchSSIDInfo;

@end
