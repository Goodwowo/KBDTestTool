
#import <UIKit/UIKit.h>

/**
 这个类的作用:
 当控件添加UIGestureRecognizer时,不像UIControl一样,可以直接获取target和action,所以我们需要hook这个UIGestureRecognizer添加过程,将其的target和action保存起来
 */
@interface UIGestureRecognizer (Ext)

- (NSMutableArray *)allGestureRecognizerTargetAndAction;

@end
