
#import <UIKit/UIKit.h>

@interface UIView (AutoTestExt)

/**获取其直接接收事件响应的最顶端控制器*/
- (UIViewController *)getViewController;

- (void)cornerRadiusBySelfWithColor:(UIColor *)color;

- (NSString *)textDescription;

@end
