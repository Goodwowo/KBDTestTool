
#import <UIKit/UIKit.h>

@interface RTDeviceDetailInfo : NSObject

+ (NSString *)phoneSystemVersion;

+ (BOOL)jailbrokenDevice;

+ (NSString*)wifiName;

+ (NSString*)deviceIpAddress;

+ (NSString*)localWifiIpAddress;

+ (NSString*)domainNameSystemIp;

+ (NSString*)telephonyCarrier;

+ (NSString*)networkType;

+ (NSString*)applicationDisplayName;

+ (NSString*)applicationVersion;

@end
