//
//  UIView+AutoScroll.h
//  iosapp
//
//  Created by mac on 2018/3/20.
//  Copyright © 2018年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AutoScroll)

- (BOOL)isCanScroll;
- (BOOL)canVerScroll;
- (BOOL)canHorScroll;
- (NSInteger)autoScroll;
- (NSInteger)isTransformDirection:(NSInteger)direction;
- (BOOL)isRotationLeftOrRight;

@end
