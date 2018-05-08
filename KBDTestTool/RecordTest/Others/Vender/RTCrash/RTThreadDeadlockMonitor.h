
#import <Foundation/Foundation.h>

@interface RTThreadDeadlockMonitor : NSObject

- (void)startThreadMonitor;
+ (instancetype)shareObj;

@end
