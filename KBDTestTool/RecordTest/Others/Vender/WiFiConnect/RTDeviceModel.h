
#import <Foundation/Foundation.h>

@interface RTDeviceModel : NSObject

@property (nonatomic, strong) NSString* hostname;

@property (nonatomic, strong) NSString* ipAddress;

@property (nonatomic, strong) NSString* macAddress;

@property (nonatomic, strong) NSString* subnetMask;

@property (nonatomic, strong) NSString* brand;

- (NSString*)macAddressLabel;

@end
