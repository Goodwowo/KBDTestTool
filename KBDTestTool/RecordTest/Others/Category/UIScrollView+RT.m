
#import "UIScrollView+RT.h"
#import <objc/runtime.h>

static const int UIScrollView_OrginalPoint;

@implementation UIScrollView (RT)

- (CGPoint)orginalPoint{
    id num=objc_getAssociatedObject(self, &UIScrollView_OrginalPoint);
    if (num) {
        return [num CGPointValue];
    }
    return CGPointZero;
}

- (void)setOrginalPoint:(CGPoint)orginalPoint{
    objc_setAssociatedObject(self, &UIScrollView_OrginalPoint, [NSValue valueWithCGPoint:orginalPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
