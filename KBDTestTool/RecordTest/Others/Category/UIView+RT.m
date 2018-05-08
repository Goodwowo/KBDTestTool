
#import "UIView+RT.h"
#import <objc/runtime.h>

static const int is_KVO;
static const int is_NoNeedKVO;
static const int is_NoNeedSnap;

@implementation UIView (RT)

- (BOOL)isKVO{
    id num=objc_getAssociatedObject(self, &is_KVO);
    if (num) {
        return [num boolValue];
    }
    return NO;
}

- (void)setIsKVO:(BOOL)isKVO{
    objc_setAssociatedObject(self, &is_KVO, [NSNumber numberWithBool:isKVO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isNoNeedKVO{
    id num=objc_getAssociatedObject(self, &is_NoNeedKVO);
    if (num) {
        return [num boolValue];
    }
    return NO;
}

- (void)setIsNoNeedKVO:(BOOL)isNoNeedKVO{
    objc_setAssociatedObject(self, &is_NoNeedKVO, [NSNumber numberWithBool:isNoNeedKVO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isNoNeedSnap{
    id num=objc_getAssociatedObject(self, &is_NoNeedSnap);
    if (num) {
        return [num boolValue];
    }
    return NO;
}

- (void)setIsNoNeedSnap:(BOOL)isNoNeedSnap{
    objc_setAssociatedObject(self, &is_NoNeedSnap, [NSNumber numberWithBool:isNoNeedSnap], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
