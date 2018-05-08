//
//  AutoTestProject.m
//  MaiXiang
//
//  Created by mac on 2017/10/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "AutoTestProject.h"
#import "AutoTestHeader.h"

@implementation AutoTestProject

+ (AutoTestProject *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static AutoTestProject *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[AutoTestProject alloc] init];
        _sharedObject.isRuning=NO;
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];//保持APP常亮不会自动息屏和进入锁屏状态,这样可以整晚测试了
    });
    return _sharedObject;
}

- (void)autoTest{
    self.isRuning=YES;
    
    NSMutableArray *events=[[DisPlayAllView new] allEventView];
    [self atLeastRunOne:events];
}

/**随机触发事件,至少要触发一种事件成功*/
- (void)atLeastRunOne:(NSMutableArray *)events{
    [self randomClick:events];
}

/**触发随机点击*/
- (void)randomClick:(NSMutableArray *)events{
    
    ViewHolder *holder = [events randomObject];
    UIView *view = holder.view;
    if (holder.type & ViewHolderTypeScroll){
        NSInteger direction = [view autoScroll];
        [SimulationView addSwipeSimulationView:view.centerInWindow direction:direction afterDismiss:AutoTest_Interval];
    }else{
        [view happenEvent];
        [SimulationView addTouchSimulationView:view.centerInWindow afterDismiss:AutoTest_Interval];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self autoTest];
//        });
//        return;
    }

//    [view happenEvent];
//    if ([view isKindOfClass:NSClassFromString(@"_UINavigationBarBackIndicatorView")]){
//        NSLog(@"%@",@"呵呵哒");
//        [view happenEvent];
//    }else{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self autoTest];
//        });
//        return;
//    }
//
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AutoTest_Interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self autoTest];
    });
}

@end
