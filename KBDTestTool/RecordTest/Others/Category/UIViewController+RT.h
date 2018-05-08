//
//  UIViewController+RT.h
//  CJOL
//
//  Created by mac on 2018/3/25.
//  Copyright © 2018年 SuDream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (RT)

/**获取显示在window当前最顶部的viewController*/
+ (UIViewController *)getCurrentVC;
/**退出显示在window当前最顶部的viewController*/
+ (BOOL)popOrDismissViewController:(UIViewController *)viewController;

@end
