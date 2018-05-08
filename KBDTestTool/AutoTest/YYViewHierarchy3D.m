
#import "YYViewHierarchy3D.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "RegionsTool.h"
#import "DisPlayAllView.h"

#if !__has_feature(objc_arc)
#error add -fobjc-arc to compiler flags
#endif

#ifndef DEGREES_TO_RADIANS
#define DEGREES_TO_RADIANS(d) ((d) * M_PI / 180)
#endif

#define clipInsert YES

@interface YYViewHierarchy3D () {
    float rotateX;
    float rotateY;
    float dist;
    BOOL isAnimatimg;
}
+ (YYViewHierarchy3D *)sharedInstance;
- (void)toggleShow;
@property (nonatomic, retain) NSMutableArray *holders;
@end


#pragma mark - Top Shortcut
@interface  YYViewHierarchy3DTop : UIWindow
+ (YYViewHierarchy3DTop *)sharedInstance;
@end

@implementation YYViewHierarchy3DTop

+ (YYViewHierarchy3DTop *)sharedInstance {
    static dispatch_once_t once;
    static YYViewHierarchy3DTop *singleton;
    dispatch_once(&once, ^{
        singleton = [[YYViewHierarchy3DTop alloc] init];
    });
    return singleton;
}

- (id)init {
    CGRect frame = CGRectMake(40, 40, 40, 40);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar + 100.0f;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.showsTouchWhenHighlighted = YES;
        btn.frame = CGRectMake(5, 5, 30, 30);
        btn.layer.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.900].CGColor;
        btn.layer.cornerRadius = 15;
        btn.layer.shadowOpacity = YES;
        btn.layer.shadowRadius = 4;
        btn.layer.shadowColor = [UIColor blackColor].CGColor;
        btn.layer.shadowOffset = CGSizeMake(0, 0);
        UIPanGestureRecognizer *g = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [btn addGestureRecognizer:g];
        [btn addTarget:[YYViewHierarchy3D sharedInstance] action:@selector(toggleShow) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}

- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer {
    static CGRect oldFrame;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        oldFrame = self.frame;
    }
    CGPoint change = [gestureRecognizer translationInView:self];
    CGRect newFrame = oldFrame;
    newFrame.origin.x += change.x;
    newFrame.origin.y += change.y;
    self.frame = newFrame;
}

@end







@implementation UIView (AutoTestExt)

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
- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
- (CGFloat)width{
    return self.frame.size.width;
}
- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
- (CGFloat)height{
    return self.frame.size.height;
}

- (UIWindow *)getWindow{
    if ([self isKindOfClass:[UIWindow class]]) return (UIWindow *)self;
    return [self.superview getWindow];
}
- (CGRect)frameInWindow{
    return [self convertRect:self.bounds toView:[self getWindow]];
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
            UIView *responeView = [superView hitTest:CGPointMake(self.width/2.0+self.x, self.height/2.0+self.y) withEvent:nil];
            if (!responeView) {
                return NO;
            }else if(responeView != self){
                return NO;
            }
        }
    }
    return YES;
}

@end







@interface ViewImageHolder : NSObject
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) float deep;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, retain) UIView *view;
@property (nonatomic, assign) NSInteger layerIndex;
@property (nonatomic, assign) uint64_t superView;

@end

@implementation ViewImageHolder
@synthesize image = _image;
@synthesize deep = _deep;
@synthesize rect = _rect;
@synthesize view = _view;
@end




@implementation YYViewHierarchy3D
@synthesize holders = _holders;
+ (YYViewHierarchy3D *)sharedInstance {
    static dispatch_once_t once;
    static YYViewHierarchy3D *singleton;
    dispatch_once(&once, ^{
        singleton = [[YYViewHierarchy3D alloc] init];
    });
    return singleton;
}

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = [UIScreen mainScreen].bounds;
        self.windowLevel = UIWindowLevelStatusBar + 99.0f;
//        dist = -0.5;
        dist = 0;
        UIPanGestureRecognizer *gPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        UIPinchGestureRecognizer *gPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [self addGestureRecognizer:gPan];
        [self addGestureRecognizer:gPinch];
    }
    return self;
}

- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer {
    static CGPoint oldPan;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        oldPan = CGPointMake(rotateX, rotateY);
    }
    CGPoint change = [gestureRecognizer translationInView:self];
    rotateX = oldPan.x + change.x;
    rotateY = oldPan.y - change.y;
    [self anime:0.1];
}

- (void)pinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    static float oldDist;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        oldDist = dist;
    }
    dist = oldDist + (gestureRecognizer.scale - 1);
    dist = dist < -5 ? -5 : dist > 0.5 ? 0.5 : dist;
    [self anime:0.1];
}

- (void)anime:(float)time {
    CATransform3D trans = CATransform3DIdentity;
    CATransform3D t = CATransform3DIdentity;
    t.m34 = -0.001;
    trans = CATransform3DMakeTranslation(0, 0, dist * 2000);
    trans = CATransform3DConcat(CATransform3DMakeRotation(DEGREES_TO_RADIANS(rotateX), 0, 1, 0), trans);
    trans = CATransform3DConcat(CATransform3DMakeRotation(DEGREES_TO_RADIANS(rotateY), 1, 0, 0), trans);
    trans = CATransform3DConcat(CATransform3DMakeRotation(DEGREES_TO_RADIANS(0), 0, 0, 1), trans);
    trans = CATransform3DConcat(trans, t);
    
    isAnimatimg = YES;
    [UIView animateWithDuration:time animations:^() {
        for (ViewImageHolder * holder in self.holders) {
            holder.view.layer.transform = trans;
        }
    } completion:^(BOOL finished) {
        isAnimatimg = NO;
    }];
}

+ (void)show {
    [YYViewHierarchy3DTop sharedInstance].hidden = NO;
    [YYViewHierarchy3D sharedInstance].hidden = YES;
}

+ (void)hide {
    [YYViewHierarchy3DTop sharedInstance].hidden = YES;
    [YYViewHierarchy3D sharedInstance].hidden = YES;
}

- (UIImage *)renderImageFromView:(UIView *)view {
    return [self renderImageFromView:view withRect:view.bounds];
}

- (UIImage *)renderImageFromView:(UIView *)view withRect:(CGRect)frame {
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) {
        return nil;
    }
    CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
    [view.layer renderInContext:context];
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return renderedImage;
}

- (UIImage *)renderImageForAntialiasing:(UIImage *)image {
    if (clipInsert) return [self renderImageForAntialiasing:image withInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    return [self renderImageForAntialiasing:image withInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (UIImage *)renderImageForAntialiasing:(UIImage *)image withInsets:(UIEdgeInsets)insets {
    CGSize imageSizeWithBorder = CGSizeMake([image size].width + insets.left + insets.right,
                                            [image size].height + insets.top + insets.bottom);
    
    UIGraphicsBeginImageContextWithOptions(imageSizeWithBorder,
                                           UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero), 0);
    
    [image drawInRect:(CGRect) {{ insets.left, insets.top }, [image size] }];
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return renderedImage;
}

- (void)startShow {
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    self.holders = nil;
    rotateX = 0;
    rotateY = 0;
    self.holders = [NSMutableArray arrayWithCapacity:100];
    
    for (int i = 0; i < [UIApplication sharedApplication].windows.count; i++) {
        if ([UIApplication sharedApplication].windows[i] == [YYViewHierarchy3DTop sharedInstance]) {
            continue;
        }
        //每个window都要加上去,但是可能出现有时候手误加了一个透明的window在最上面,导致下面的被挡住
        UIWindow *window = [UIApplication sharedApplication].windows[i];
        if (window.subviews.count > 0) {
            [self    dumpView:window
                    superView:0
                   layerIndex:0
                       atDeep:i * 5
                      toArray:_holders];
        }
    }
//    [_holders removeObjectsInArray:[RegionsTool removesEvent:_holders]];
    
    for (ViewImageHolder *h in _holders) {
        UIImageView *imgV = [[UIImageView alloc] initWithImage:h.image];
        imgV.contentMode = UIViewContentModeTopLeft;
        imgV.frame = h.rect;
        imgV.clipsToBounds = YES;
        [self addSubview:imgV];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeTap:)];
        imgV.userInteractionEnabled=YES;
        [imgV addGestureRecognizer:tapGes];
        h.view = imgV;
        CGRect r = imgV.frame;
        CGRect scr = [UIScreen mainScreen].bounds;
        imgV.layer.anchorPoint = CGPointMake((scr.size.width / 2 - imgV.frame.origin.x) / imgV.frame.size.width,
                                             (scr.size.height / 2 - imgV.frame.origin.y) / imgV.frame.size.height);
//        imgV.layer.anchorPointZ = (-h.deep + 3) * 50;
        
        imgV.frame = r;
        imgV.layer.opacity = 0.9;
        imgV.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    }
    [self anime:0.3];
}


- (void)startHide {
    isAnimatimg = YES;
    [UIView animateWithDuration:0.3 animations:^() {
        for (ViewImageHolder * holder in self.holders) {
            holder.view.layer.transform = CATransform3DIdentity;
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^() {
            self.hidden = YES;
        } completion:^(BOOL finished) {
            for (ViewImageHolder * holder in self.holders) {
                [holder.view removeFromSuperview];
            }
            self.holders = nil;
            isAnimatimg = NO;
        }];
    }];
}

- (void)removeTap:(UITapGestureRecognizer *)ges{
    [ges.view removeFromSuperview];
}

- (void)toggleShow {
    if (isAnimatimg) {
        return;
    }
    if (self.hidden) {
        self.hidden = NO;
        self.frame = [UIScreen mainScreen].bounds;
        [self startShow];
        [UIView animateWithDuration:0.4 animations:^{
            self.backgroundColor = [UIColor grayColor];
        }];
    } else {
        [self startHide];
        [UIView animateWithDuration:0.4 animations:^{
            self.backgroundColor = [UIColor clearColor];
        }];
    }
}

#pragma mark - 核心逻辑

- (void) dumpView:(UIView *)aView
        superView:(UIView *)superView
       layerIndex:(NSInteger)layerIndex
           atDeep:(float)deep
          toArray:(NSMutableArray *)holders {
    //如果视图是隐藏不可见的,就忽略不计
    if (aView.hidden || aView.alpha <0.01 || aView.width <= 0 || aView.height <= 0) {
        return;
    }
    
    NSMutableArray *notHiddens = [NSMutableArray arrayWithCapacity:0];
    for (UIView *v in aView.subviews) {
        if (!v.hidden) {
            [notHiddens addObject:v];
            v.hidden = YES;
        }
    }
    UIImage *img = [self renderImageFromView:aView];
    for (UIView *v in notHiddens) {
        v.hidden = NO;
    }
    
    if (img) {
        ViewImageHolder *holder = [[ViewImageHolder alloc] init];
        holder.image = [self renderImageForAntialiasing:img];
        holder.deep = deep;
        holder.layerIndex = layerIndex;
        holder.superView = (uint64_t)superView;
        holder.rect = [aView rectIntersectionInWindow];// 获取 该view与window 交叉的 Rect
        
        if (!(CGRectIsEmpty(holder.rect) || CGRectIsNull(holder.rect))) {
            CGRect canShowFrame = [aView canShowFrameRecursive];
            if (!(CGRectIsEmpty(canShowFrame) || CGRectIsNull(canShowFrame))){
                if (!CGRectEqualToRect(canShowFrame, [UIScreen mainScreen].bounds)) {
                    holder.rect = canShowFrame;
                }
                if ([aView isHitTest]) {
                    [holders addObject:holder];
                }
            }
        }
    }
    
    for (int i = 0; i < aView.subviews.count; i++) {
        UIView *v = aView.subviews[i];
        float interval = i*2.0/aView.subviews.count;
        [self dumpView:v superView:aView layerIndex:layerIndex+1 atDeep:deep + 1 + interval toArray:holders];
    }
}

@end
