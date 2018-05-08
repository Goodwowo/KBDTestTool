//
//  UIScrollView+AutoScroll.m
//  MaiXiang
//
//  Created by mac on 2017/10/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIScrollView+AutoScroll.h"
#import "UIView+AutoTestExt.h"
#import "AutoTestHeader.h"

@implementation UIScrollView (AutoScroll)

- (BOOL)isCanScroll{
    if([self canVerScroll]||[self canHorScroll]){
        return YES;
    }
    return NO;
}

- (BOOL)canVerScroll{
    if ([super isRotationLeftOrRight]) {
        BOOL canHorScroll=self.contentSize.width>self.size.width;//是否可以横向滑动
        return canHorScroll;
        
    }
    BOOL canVerScroll=self.contentSize.height>self.size.height;//是否可以纵向滑动
    return canVerScroll;
}

- (BOOL)canHorScroll{
    if ([super isRotationLeftOrRight]) {
        BOOL canVerScroll=self.contentSize.height>self.size.height;//是否可以纵向滑动
        return canVerScroll;
    }
    BOOL canHorScroll=self.contentSize.width>self.size.width;//是否可以横向滑动
    return canHorScroll;
}

- (NSInteger)autoScroll{
    if (!DebugScroll) return 1;
    
    //先判断ScrollView的滑动方向
    BOOL canVerScroll=self.contentSize.height>self.size.height;//是否可以纵向滑动
    BOOL canHorScroll=self.contentSize.width>self.size.width;//是否可以横向滑动
    
    //随机选择左右滑或者上下滑
    if(canVerScroll&&canHorScroll){
        if (arc4random()%2==0) canVerScroll=NO;
        else canHorScroll=NO;
    }
    
    CGFloat verScrollOffsetY=0,horScrollOffsetX=0;
    if (self.isPagingEnabled) {
        if (canVerScroll) {
            if (arc4random()%2==0) {
                if (self.contentOffset.y+self.size.height<self.contentSize.height) {
                    verScrollOffsetY=self.size.height;
                }else if(self.contentOffset.y-self.size.height>0){
                    verScrollOffsetY=-self.size.height;
                }
            }else{
                if(self.contentOffset.y-self.size.height>0){
                    verScrollOffsetY=-self.size.height;
                }else if (self.contentOffset.y+self.size.height<self.contentSize.height) {
                    verScrollOffsetY=self.size.height;
                }
            }
        }
        if (canHorScroll) {
            if (arc4random()%2==0) {
                if (self.contentOffset.x+self.size.width<self.contentSize.width) {
                    horScrollOffsetX=self.size.width;
                }else if(self.contentOffset.x-self.size.width>0){
                    horScrollOffsetX=-self.size.width;
                }
            }else{
                if(self.contentOffset.x-self.size.width>0){
                    horScrollOffsetX=-self.size.width;
                }else if (self.contentOffset.x+self.size.width<self.contentSize.width) {
                    horScrollOffsetX=self.size.width;
                }
            }
        }
    }
    
    if (canVerScroll) {
        if (verScrollOffsetY==0) {
            NSInteger mod=(NSInteger)(self.contentSize.height-self.size.height);
            if (mod!=0) {
                NSInteger randomOffsetY=arc4random()%mod;
                verScrollOffsetY=randomOffsetY-self.contentOffset.y;
            }
        }
    }
    if (canHorScroll) {
        if (horScrollOffsetX==0) {
            NSInteger mod=(NSInteger)(self.contentSize.width-self.size.width);
            if (mod!=0) {
                NSInteger randomOffsetX=arc4random()%mod;
                horScrollOffsetX=randomOffsetX-self.contentOffset.x;
            }
        }
    }
    
    //防止越界
    if(self.contentOffset.x+horScrollOffsetX>self.contentSize.width-self.width){
        horScrollOffsetX = self.contentSize.width - self.width - self.contentOffset.x;
    }
    if(self.contentOffset.y+verScrollOffsetY>self.contentSize.height-self.height){
        verScrollOffsetY = self.contentSize.height - self.height - self.contentOffset.y;
    }
    if(self.contentOffset.x+horScrollOffsetX < 0){
        horScrollOffsetX = - self.contentOffset.x;
    }
    if(self.contentOffset.y+verScrollOffsetY < 0){
        verScrollOffsetY = - self.contentOffset.y;
    }
    
    if (self.delegate) {
        if([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
            [self.delegate scrollViewWillBeginDragging:self];
        if([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
            [self.delegate scrollViewWillBeginDecelerating:self];
    }
    
    [self setContentOffset:CGPointMake(self.contentOffset.x+horScrollOffsetX, self.contentOffset.y+verScrollOffsetY) animated:YES];
    
    if (self.delegate) {
        if([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
            [self.delegate scrollViewDidScroll:self];
        if([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
            [self.delegate scrollViewDidEndDragging:self willDecelerate:YES];
        if([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
            [self.delegate scrollViewDidEndDecelerating:self];
        if([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
            [self.delegate scrollViewDidEndScrollingAnimation:self];
    }
    
    NSInteger direction=0;//direction 1左 2上 3右 4下
    if (horScrollOffsetX>0) direction=3;
    else if (horScrollOffsetX<0) direction=1;
    
    if (verScrollOffsetY>0) direction=4;
    else if (verScrollOffsetY<0) direction=2;
    
    return [super isTransformDirection:direction];
}

@end
