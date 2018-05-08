//
//  UIView+Frame.h
//  CJOL
//
//  Created by mac on 2018/3/18.
//  Copyright © 2018年 SuDream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;
@property (assign, nonatomic,readonly)CGFloat minX;
@property (assign, nonatomic,readonly)CGFloat minY;
@property (assign, nonatomic,readonly)CGFloat maxX;
@property (assign, nonatomic,readonly)CGFloat maxY;

- (UIWindow *)getWindow;
- (CGRect)frameInWindow;
- (CGPoint)centerInWindow;
- (CGRect)rectIntersectionInWindow;
- (CGRect)frameInSuperView;
- (CGRect)rectIntersectionInSuperView;
/**在桌面上的显示区域-递归*/
- (CGRect)canShowFrameRecursive;
/**在桌面上的显示区域*/
- (CGRect)canShowFrame;
/**在桌面上的显示区域-递归*/
- (BOOL)canShow;
- (CGRect)canTouchFrame;
- (BOOL)isHitTest;


/**给控件设置成圆角*/
- (void)cornerRadius;

- (void)cornerRadiusWithFloat:(CGFloat)vaule;

- (void)cornerRadiusWithBorderColor:(UIColor *)color borderWidth:(CGFloat)width;

- (void)cornerRadiusWithFloat:(CGFloat)vaule borderColor:(UIColor *)color borderWidth:(CGFloat)width;

/**为view添加点击手势*/
- (UITapGestureRecognizer *)addUITapGestureRecognizerWithTarget:(id)target withAction:(SEL)action;
@end
