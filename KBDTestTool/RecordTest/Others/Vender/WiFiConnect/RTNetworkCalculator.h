
#import <Foundation/Foundation.h>

@interface RTNetworkCalculator : NSObject

+ (NSArray*)getAllHostsForIP:(NSString*)ipAddress andSubnet:(NSString*)subnetMask;

@end
