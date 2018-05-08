//
//  UIView+AutoScroll.m
//  iosapp
//
//  Created by mac on 2018/3/20.
//  Copyright © 2018年 oschina. All rights reserved.
//

#import "UIView+AutoScroll.h"

@implementation UIView (AutoScroll)

- (BOOL)isCanScroll{
    return NO;
}

- (NSInteger)autoScroll{
    return 0;
}

- (BOOL)canVerScroll{
    return NO;
}

- (BOOL)canHorScroll{
    return NO;
}

- (NSInteger)isTransformDirection:(NSInteger)direction{
    
    if (CGAffineTransformIsIdentity(self.transform)) {
        return direction;
    }
    
    CGFloat value = 0;
    if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeRotation(M_PI/2.0))) value = M_PI/2.0;
    else if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeRotation(M_PI))) value = M_PI;
    else if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeRotation(M_PI*1.5))) value = M_PI*1.5;
    else if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeRotation(M_PI*2))) value = M_PI*2;
    else if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeRotation(-M_PI/2.0))) value = -M_PI/2.0;
    else if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeRotation(-M_PI))) value = -M_PI;
    else if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeRotation(-M_PI*1.5))) value = -M_PI*1.5;
    else if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeRotation(-M_PI*2))) value = -M_PI*2;
    
    //direction 1左 2上 3右 4下
    if(value == M_PI/2.0 || -M_PI*1.5){// 向右旋转
        if(direction == 1)return 4;
        if(direction == 2)return 1;
        if(direction == 3)return 2;
        if(direction == 4)return 3;
    }
    if(value == -M_PI/2.0 || M_PI*1.5){// 向左旋转
        if(direction == 1)return 2;
        if(direction == 2)return 3;
        if(direction == 3)return 4;
        if(direction == 4)return 1;
    }
    if(value == -M_PI || M_PI){// 向下旋转
        if(direction == 1)return 3;
        if(direction == 2)return 4;
        if(direction == 3)return 1;
        if(direction == 4)return 2;
    }
    if(value == -M_PI*2 || M_PI*2){// 旋转一圈又回来了
        return direction;
    }
    return direction;
}

- (BOOL)isRotationLeftOrRight{
    if (CGAffineTransformIsIdentity(self.transform)) {
        return NO;
    }
    if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeRotation(M_PI/2.0))) return YES;
    else if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeRotation(M_PI*1.5))) return YES;
    else if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeRotation(-M_PI/2.0))) return YES;
    else if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeRotation(-M_PI*1.5))) return YES;
    return NO;
}

@end
