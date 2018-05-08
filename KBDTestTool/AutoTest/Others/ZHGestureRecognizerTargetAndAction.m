
#import "ZHGestureRecognizerTargetAndAction.h"

@implementation ZHGestureRecognizerTargetAndAction

- (instancetype)initWithAction:(SEL)action withTarget:(id)target{
    self = [super init];
    if (self) {
        _action = action;
        _target = target;
    }
    return self;
}

@end
