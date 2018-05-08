
#import <UIKit/UIKit.h>
#import "RTSlideSwitchDelegate.h"

@interface RTSegmentedSlideSwitch : UIView
/**
 代理
 */
@property (weak,nonatomic) id <RTSlideSwitchDelegate>delegate;

/**
 SegmentedControl
 */
@property (strong,nonatomic,readonly)  UISegmentedControl *segmentedControl;

/**
 需要显示的viewController集合
 */
@property (strong,nonatomic) NSMutableArray *viewControllers;

/**
 当前选中位置
 */
@property (assign,nonatomic) NSInteger selectedIndex;

/**
 Segmented高亮颜色
 */
@property (strong,nonatomic) UIColor *tintColor;

/**
 显示在某个VC的navbar上
 */
-(void)showsInNavBarOf:(UIViewController *)vc;

@end
