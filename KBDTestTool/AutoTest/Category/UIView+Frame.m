
#import "UIView+Frame.h"
#import "AutoTestHeader.h"

@implementation UIView (Frame)

- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y{
    return self.frame.origin.y;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (CGFloat)minX{
    return CGRectGetMinX(self.frame);
}

- (CGFloat)minY{
    return CGRectGetMinY(self.frame);
}

- (CGFloat)maxX{
    return CGRectGetMaxX(self.frame);
}

-(CGFloat)maxY{
    return CGRectGetMaxY(self.frame);
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (UIWindow *)getWindow{
    if ([self isKindOfClass:[UIWindow class]]) return (UIWindow *)self;
    return [self.superview getWindow];
}
- (CGRect)frameInWindow{
    return [self convertRect:self.bounds toView:[self getWindow]];
}
- (CGPoint)centerInWindow{
    CGRect frameInWindow = [self frameInWindow];
    return CGPointMake(frameInWindow.origin.x + frameInWindow.size.width / 2.0, frameInWindow.origin.y + frameInWindow.size.height / 2.0);
}
- (CGRect)rectIntersectionInWindow{
    return CGRectIntersection([self frameInWindow], [UIScreen mainScreen].bounds);
}
- (CGRect)frameInSuperView{
    return [self convertRect:self.bounds toView:self.superview];
}
- (CGRect)rectIntersectionInSuperView{
    return CGRectIntersection([self frameInSuperView], self.superview.bounds);
}
/**在桌面上的显示区域-递归*/
- (CGRect)canShowFrameRecursive{
    if ([self.superview isKindOfClass:[UIWindow class]]) {
        if (!self.clipsToBounds) return [UIScreen mainScreen].bounds;
        return [self rectIntersectionInWindow];
    }
    CGRect superViewCanShowFrame = [self.superview canShowFrameRecursive];
    if (CGRectIsEmpty(superViewCanShowFrame) || CGRectIsNull(superViewCanShowFrame)){
        return CGRectNull;
    }
    if (CGRectEqualToRect(superViewCanShowFrame, [UIScreen mainScreen].bounds)) {
        if (!self.clipsToBounds) return [UIScreen mainScreen].bounds;
    }
    if (!CGAffineTransformEqualToTransform(self.transform, CGAffineTransformIdentity)) {
        return superViewCanShowFrame;
    }
    return CGRectIntersection([self frameInWindow], superViewCanShowFrame);
}
/**在桌面上的显示区域*/
- (CGRect)canShowFrame{
    CGRect canShowFrame = [self canShowFrameRecursive];
    if (CGRectEqualToRect(canShowFrame, [UIScreen mainScreen].bounds)) {
        return [self rectIntersectionInWindow];
    }
    return canShowFrame;
}
/**在桌面上的显示区域-递归*/
- (BOOL)canShow{
    CGRect canShowFrame = [self canShowFrameRecursive];
    if (CGRectIsEmpty(canShowFrame) || CGRectIsNull(canShowFrame)){
        return NO;
    }
    return YES;
}
- (CGRect)canTouchFrame{
    if ([self.superview isKindOfClass:[UIWindow class]]) {
        return [self rectIntersectionInWindow];
    }
    CGRect superViewTouchFrame = [self.superview canTouchFrame];
    if (CGRectIsEmpty(superViewTouchFrame) || CGRectIsNull(superViewTouchFrame)){
        return CGRectNull;
    }
    return CGRectIntersection([self frameInWindow], superViewTouchFrame);
}

- (BOOL)isHitTest{
    UIView *superView = self.superview;
    if (self == nil || superView == nil) return NO;
    
    //如果这个控件不在父控件的显示范围内,并且 - (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event 也点击不到
    CGRect intersectionRect = [self rectIntersectionInSuperView];
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        if ([superView respondsToSelector:@selector(hitTest:withEvent:)]) {
            UIView *responeView = [superView hitTest:CGPointMake(self.width/2.0+self.left, self.height/2.0+self.top) withEvent:nil];
            if (!responeView) {
                return NO;
            }else if(responeView != self){
                return NO;
            }
        }
    }
    return YES;
}


- (void)cornerRadius{
    [self cornerRadiusWithFloat:-1 borderColor:nil borderWidth:0];
}
- (void)cornerRadiusWithFloat:(CGFloat)vaule{
    [self cornerRadiusWithFloat:vaule borderColor:nil borderWidth:0];
}
- (void)cornerRadiusWithBorderColor:(UIColor *)color borderWidth:(CGFloat)width{
    [self cornerRadiusWithFloat:-1 borderColor:color borderWidth:width];
}
- (void)cornerRadiusWithFloat:(CGFloat)vaule borderColor:(UIColor *)color borderWidth:(CGFloat)width{
    if (vaule==-1) {
        if(self.frame.size.height==0||self.frame.size.width==0){
        }else if(self.frame.size.height==self.frame.size.width){
            self.layer.cornerRadius=self.frame.size.height/2.0;
        }
    }else{
        self.layer.cornerRadius=vaule;
    }
    
    if (color!=nil) {
        self.layer.borderColor=[color CGColor];
    }
    
    if(width!=0){
        self.layer.borderWidth=width;
    }
    
    self.layer.masksToBounds=YES;
}

//为view添加点击手势
- (UITapGestureRecognizer *)addUITapGestureRecognizerWithTarget:(id)target withAction:(SEL)action{
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled=YES;
    return tap;
}
@end
