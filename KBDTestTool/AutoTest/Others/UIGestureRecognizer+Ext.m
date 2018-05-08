
#import "UIGestureRecognizer+Ext.h"
#import "NSObject+Swizzle.h"
#import "AutoTestHeader.h"
#import <objc/runtime.h>
#import "ZHGestureRecognizerTargetAndAction.h"

static const int block_key;

@implementation UIGestureRecognizer (Ext)

+ (void)load{
    [super load];
//    if (AutoTest) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self swizzleInstanceMethod:@selector(initWithTarget:action:) with:@selector(custom_initWithTarget:action:)];
            [self swizzleInstanceMethod:@selector(addTarget:action:) with:@selector(custom_addTarget:action:)];
            [self swizzleInstanceMethod:@selector(removeTarget:action:) with:@selector(custom_removeTarget:action:)];
        });
//    }
}

- (instancetype)custom_initWithTarget:(nullable id)target action:(nullable SEL)action{
    
    [self addToArrWithTarget:target action:action];
    return [self custom_initWithTarget:target action:action];
}

- (void)custom_addTarget:(id)target action:(SEL)action{
    
    [self addToArrWithTarget:target action:action];
    [self custom_addTarget:target action:action];
}

- (void)custom_removeTarget:(nullable id)target action:(nullable SEL)action{
    [self custom_removeTarget:target action:action];
}

- (void)addToArrWithTarget:(id)target action:(SEL)action{
    ZHGestureRecognizerTargetAndAction *targetTemp = [[ZHGestureRecognizerTargetAndAction alloc] initWithAction:action withTarget:target];
    NSMutableArray *targets = [self allGestureRecognizerTargetAndAction];
    [targets addObject:targetTemp];
}

- (void)removeFromArrWithTarget:(id)target action:(SEL)action{
    NSMutableArray *targets = [self allGestureRecognizerTargetAndAction];
    for (NSInteger i=0; i<targets.count; i++) {
        ZHGestureRecognizerTargetAndAction *targetTemp=[targets objectAtIndex:i];
        if ([targetTemp.target isEqual:target]&&sel_isEqual(targetTemp.action, action)) {
            [targets removeObjectAtIndex:i];
            i--;
        }
    }
}

- (NSMutableArray *)allGestureRecognizerTargetAndAction {
    NSMutableArray *targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
