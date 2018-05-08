
#import <Foundation/Foundation.h>

@interface RTInteraction : NSObject

+ (RTInteraction *)shareInstance;
- (void)startInteraction;

- (void)showAll;
- (void)hideAll;

@end
