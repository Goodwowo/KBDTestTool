
#import <UIKit/UIKit.h>

@interface SimulationView : NSObject

/**添加一个模拟点击的一个图片,这样看起来更加友好*/
+ (void)addTouchSimulationView:(CGPoint)point afterDismiss:(NSInteger)time;

//direction 1左 2上 3右 4下
/**添加一个模拟滑动的一个图片,这样看起来更加友好*/
+ (void)addSwipeSimulationView:(CGPoint)point direction:(NSInteger)direction afterDismiss:(NSInteger)time;

@end
