//
//  UIViewController+RT.m
//  CJOL
//
//  Created by mac on 2018/3/25.
//  Copyright © 2018年 SuDream. All rights reserved.
//

#import "UIViewController+RT.h"

@implementation UIViewController (RT)

/**获取显示在window当前最顶部的viewController*/
+ (UIViewController *)getCurrentVC{
    
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if(!window)return nil;
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    id  nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    //    如果是present上来的appRootVC.presentedViewController 不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        if ([[window subviews] count]>0) {
            UIView *frontView = [[window subviews] objectAtIndex:0];
            nextResponder = [frontView nextResponder];
        }
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        NSInteger count=((UINavigationController *)tabbar).viewControllers.count;
        if (count>tabbar.selectedIndex) {
            UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
            if(!nav)return nil;
            result=nav.childViewControllers.lastObject;
        }
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    if (!result) {
        return [[UIApplication sharedApplication] keyWindow].rootViewController;
    }
    if ([result isKindOfClass:[UIWindow class]]) {
        UIWindow *window = (UIWindow *)result;
        return window.rootViewController;
    }
    return result;
}

+ (BOOL)popOrDismissViewController:(UIViewController *)viewController{
    
    UIViewController *curVC=[self getCurrentVC];
    if (curVC==viewController) {
        //说明curVC里面没有其他加进来的ChildViewControllers
    }else{
        viewController=curVC;
        //说明curVC里面有其他加进来的ChildViewControllers
    }
    
    NSArray *viewcontrollers=viewController.navigationController.viewControllers;
    if (viewcontrollers.count > 1){
        if ([viewcontrollers objectAtIndex:viewcontrollers.count - 1] == viewController){
            //push方式
            [viewController.navigationController popViewControllerAnimated:NO];
            return YES;
        }
    }else{
        UIViewController *currentVC = [UIViewController getCurrentVC];
        [viewController dismissViewControllerAnimated:NO completion:nil];
        if ([currentVC isEqual:[UIViewController getCurrentVC]]) {
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

@end
