//
//  UIScrollView+AutoScroll.h
//  MaiXiang
//
//  Created by mac on 2017/10/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (AutoScroll)

/**
 让UIScrollView随机的滚动一下(如果可以的话),如果横向和竖向都可以滚动,随机滚动一个方向,如果isPagingEnabled是打开的,我们尽量去每次翻一页,翻不了还是随便滚动一点距离
 */
- (NSInteger)autoScroll;

@end
