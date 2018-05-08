
#import <Foundation/Foundation.h>

@interface RTTcping : NSObject

+ (RTTcping *)sharedObj;
- (int)tcpingDefaultHost;

@end
