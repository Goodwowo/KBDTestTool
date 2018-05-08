
#import <UIKit/UIKit.h>

#define IOS_Version [[UIDevice currentDevice] systemVersion]
#define IOS_Version_FloatValue [IOS_Version floatValue]
#define IS_IOS(Version) (IOS_Version_FloatValue >= Version)

@interface RTURLProtocol : NSURLProtocol

@end
