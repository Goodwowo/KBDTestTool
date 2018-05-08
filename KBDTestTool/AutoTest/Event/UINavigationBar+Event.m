//
//  UINavigationBar+Event.m
//  MaiXiang
//
//  Created by mac on 2018/3/19.
//  Copyright © 2018年 GD. All rights reserved.
//

#import "UINavigationBar+Event.h"
#import "AutoTestHeader.h"
#import "UIGestureRecognizer+YYKitAdd.h"

@implementation UINavigationBar (Event)

- (BOOL)isEventView{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"_UINavigationBarBackIndicatorView")]||[view isKindOfClass:NSClassFromString(@"UINavigationItemButtonView")]) {
            NSArray *gesArr = [view gestureRecognizers];
            BOOL isAddGes = NO;
            for (UIGestureRecognizer *ges in gesArr) {
                if([ges isKindOfClass:[UITapGestureRecognizer class]]){
                    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)ges;
                    if(tap.isYYKit)isAddGes = YES;
                    break;
                }
            }
            if(!isAddGes){
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithActionBlock:^(id sender) {
                    UINavigationController *nav = (UINavigationController *)[view getViewController];
                    if(![nav isKindOfClass:[UINavigationController class]])nav = nav.navigationController;
                    [nav popViewControllerAnimated:YES];
                }];
                tap.isYYKit = YES;
                [view addGestureRecognizer:tap];
            }
            
            [self cornerRadiusBySelfWithColor:AutoTest_UIControl_Action_Color];
        }
    }
    
    return [super isEventView];
}

@end
