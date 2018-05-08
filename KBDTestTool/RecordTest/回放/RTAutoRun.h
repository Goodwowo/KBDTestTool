
#import <Foundation/Foundation.h>

@interface RTAutoRun : NSObject

@property (nonatomic,strong)NSMutableArray *autoRunQueue;

+ (RTAutoRun *)shareInstance;
- (void)start;
- (void)stop;

@end
