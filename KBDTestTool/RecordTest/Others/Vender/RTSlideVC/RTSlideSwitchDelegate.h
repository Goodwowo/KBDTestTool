
#import <Foundation/Foundation.h>

@protocol RTSlideSwitchDelegate <NSObject>
@optional
/**
 切换位置
 */
- (void)slideSwitchDidselectTab:(NSUInteger)index;

/*
 滑动到左边界时调用
 */
- (void)slideSwitchPanLeftEdge:(UIPanGestureRecognizer *)panParam;

/**
 滑动到右边界时调用
 */
- (void)slideSwitchPanRightEdge:(UIPanGestureRecognizer *)panParam;

@end
