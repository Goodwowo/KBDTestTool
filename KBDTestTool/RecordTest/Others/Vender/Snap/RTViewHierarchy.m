
#import "RTViewHierarchy.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "UIView+Frame.h"
#import "SuspendBall.h"
#import "RTCommandList.h"
#import "RAYNewFunctionGuideVC.h"
#import "SuspendBall.h"
#import "UIView+RT.h"

#if !__has_feature(objc_arc)
#error add -fobjc-arc to compiler flags
#endif

@interface RTViewImageHolder : NSObject
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) CGRect rect;
@end

@implementation RTViewImageHolder
@synthesize image = _image;
@synthesize rect = _rect;
@end

@interface RTViewHierarchy ()
@property (nonatomic, retain) NSMutableArray *holders;
@end

@implementation RTViewHierarchy
@synthesize holders = _holders;

- (UIImage *)renderImageFromView:(UIView *)view{
    UIImage *img;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    @try {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    } @catch (NSException *exception) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) [view.layer renderInContext:context];
    } @finally {
    }
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)snap:(UIView *)highlightView type:(RTOperationQueueType)type{
    UIView *backView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.holders = nil;
    self.holders = [NSMutableArray arrayWithCapacity:100];
    
    for (int i = 0; i < [UIApplication sharedApplication].windows.count; i++) {
        UIWindow *window = [UIApplication sharedApplication].windows[i];
        if (window.subviews.count > 0) {
            [self dumpView:window hide:YES];
            [self renderImageFromWindow:window];
            [self dumpView:window hide:NO];
        }
    }
    
    for (RTViewImageHolder *h in _holders) {
        UIImageView *imgV = [[UIImageView alloc] initWithImage:h.image];
        imgV.contentMode = UIViewContentModeTopLeft;
        imgV.frame = h.rect;
        imgV.clipsToBounds = YES;
        [backView addSubview:imgV];
        CGRect r = imgV.frame;
        CGRect scr = [UIScreen mainScreen].bounds;
        imgV.layer.anchorPoint = CGPointMake((scr.size.width / 2 - imgV.frame.origin.x) / imgV.frame.size.width,
                                             (scr.size.height / 2 - imgV.frame.origin.y) / imgV.frame.size.height);
        imgV.frame = r;
        imgV.layer.backgroundColor = [UIColor clearColor].CGColor;
    }
    if (highlightView) {
        CGRect rect = [highlightView rectIntersectionInWindow];// 获取 该view与window 交叉的 Rect
        if (!(CGRectIsEmpty(rect) || CGRectIsNull(rect))) {
            RAYNewFunctionGuideVC *vc = [RAYNewFunctionGuideVC new];
            vc.titleGuide = [self typeString:type];
            vc.frameGuide = rect;
            vc.view.frame = backView.bounds;
            [backView addSubview:vc.view];
        }
    }
    UIImage *snapImage = [self renderImageFromView:backView];
    return snapImage;
}

- (NSString *)typeString:(RTOperationQueueType)type{
    switch (type) {
        case RTOperationQueueTypeEvent:
            return @"Click";
            break;
        case RTOperationQueueTypeScroll:
            return @"Scroll";
            break;
        case RTOperationQueueTypeTap:
            return @"Tap";
            break;
        case RTOperationQueueTypeTableViewCellTap:
            return @"CellTap";
            break;
        case RTOperationQueueTypeCollectionViewCellTap:
            return @"CellTap";
            break;
        case RTOperationQueueTypePickerViewItemTap:
            return @"PickerViewItemTap";
            break;
        case RTOperationQueueTypeTextChange:
            return @"TextChange";
            break;
        case RTOperationQueueTypeTextFieldDidReturn:
            return @"textFieldDidReturn";
            break;
        case RTOperationQueueTypeSlide:
            return @"Slide";
            break;
        default:
            break;
    }
    return @"unknow";
}

- (void)renderImageFromWindow:(UIView *)aView{
    RTViewImageHolder *holder = [[RTViewImageHolder alloc] init];
    holder.image = [self renderImageFromView:aView];
    holder.rect = [aView rectIntersectionInWindow];// 获取 该view与window 交叉的 Rect
    [_holders addObject:holder];
}

- (void)dumpView:(UIView *)aView hide:(BOOL)hide{
    if (aView.isNoNeedSnap) {
        aView.hidden = hide;
        return;
    }
    //继续递归遍历
    for (UIView *view in [aView subviews]){
        [self dumpView:view hide:hide];
    }
}

@end
