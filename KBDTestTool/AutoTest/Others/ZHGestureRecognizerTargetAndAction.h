
#import <UIKit/UIKit.h>

@interface ZHGestureRecognizerTargetAndAction : NSObject

@property (nonatomic, assign) SEL action;
@property (nonatomic, weak) id target;

- (instancetype)initWithAction:(SEL)action withTarget:(id)target;

@end
