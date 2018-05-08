
#import <Foundation/Foundation.h>

@interface RTAutoJump : NSObject

+ (RTAutoJump *)shareInstance;
- (void)gotoVC:(NSString *)vc;
@property (nonatomic,assign)BOOL isJump;
@property (nonatomic,assign)BOOL canotJump;

@end
