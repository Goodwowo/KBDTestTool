//
//  DisPlayAllView.m
//  MaiXiang
//
//  Created by mac on 2017/10/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "DisPlayAllView.h"
#import "UIGestureRecognizer+Ext.h"
#import "AutoTestHeader.h"
#import "UIView+AutoTestExt.h"
#import "UIGestureRecognizer+YYKitAdd.h"
#import "RegionsTool.h"


@interface DisPlayAllView ()
@property (nonatomic, retain) NSMutableArray *holders;
@property (nonatomic,strong)NSMutableString *outstring;
@end

@implementation DisPlayAllView

- (void)addEventView:(ViewHolder *)holder atIndent:(NSInteger)indent {
    //如果需要收集事件
    if(self.holders) {
        if ([holder.view isEventView]) {
            ViewHolder *newHolder = [holder copyNew];
            newHolder.type = ViewHolderTypeEvent;
            [self.holders addObject:newHolder];
        }
        if ([holder.view isCanScroll]) {
            if ([holder.view canVerScroll]){
                ViewHolder *newHolder = [holder copyNew];
                newHolder.type |= ViewHolderTypeScroll;
                newHolder.type |= ViewHolderTypeScrollVer;
                [self.holders addObject:newHolder];
            }
            if ([holder.view canHorScroll]){
                ViewHolder *newHolder = [holder copyNew];
                newHolder.type |= ViewHolderTypeScroll;
                newHolder.type |= ViewHolderTypeScrollHor;
                [self.holders addObject:newHolder];
            }
        }
    }
    //如果需要打印,拼接Log打印
    if(ShouldLogAllView){
        for (int i = 0; i < indent; i++)
            [self.outstring appendString:@"--"];
        
        [self.outstring appendFormat:@"[%2ld] %@ %@ %@ %@ %@\n", (long)indent, [[holder.view class] description],[holder.view textDescription],NSStringFromCGRect(holder.rect),NSStringFromCGRect([holder.view canShowFrameRecursive]),NSStringFromClass([holder.view getViewController].class)];
    }
}

- (NSMutableArray *)allEventView{
    self.holders = nil;
    self.holders = [NSMutableArray arrayWithCapacity:100];
    self.outstring = [NSMutableString string];
    for (int i = 0; i < [UIApplication sharedApplication].windows.count; i++) {
        //每个window都要加上去,但是可能出现有时候手误加了一个透明的window在最上面,导致下面的被挡住
        UIWindow *window = [UIApplication sharedApplication].windows[i];
        if (window.subviews.count > 0) {
            [self    dumpView:window
                    superView:0
                   layerIndex:0
                      toArray:self.holders];
        }
    }
//    NSLog(@"筛选 前 事件个数:%@",@(_holders.count));
    
    NSMutableArray *events = [NSMutableArray array];
    for (ViewHolder *holder in _holders) {
        if(holder.type == ViewHolderTypeEvent)[events addObject:holder];
    }
    [_holders removeObjectsInArray:[RegionsTool removesEvent:events]];//被挡住的控件就不会点击
    
    [events removeAllObjects];
    for (ViewHolder *holder in _holders) {
        if(holder.type & ViewHolderTypeScrollHor){
            [events addObject:holder];
        }
    }
    [_holders removeObjectsInArray:[RegionsTool removesEvent:events]];//水平滚动的控件,被挡住的控件需要被筛选出去
    
    [events removeAllObjects];
    for (ViewHolder *holder in _holders) {
        if(holder.type & ViewHolderTypeScrollVer){
            [events addObject:holder];
        }
    }
    [_holders removeObjectsInArray:[RegionsTool removesEvent:events]];//垂直滚动的控件,被挡住的控件需要被筛选出去
    
//    NSLog(@"筛选 后 事件个数:%@",@(_holders.count));
    if (ShouldLogAllView) {
        NSLog(@"Log Window Director:\n%@",self.outstring);
    }
    return self.holders;
}

- (void) dumpView:(UIView *)aView
        superView:(UIView *)superView
       layerIndex:(NSInteger)layerIndex
          toArray:(NSMutableArray *)holders {
    //如果视图是隐藏不可见的,就忽略不计
    if (aView.hidden || aView.alpha <0.01 || aView.width <= 0 || aView.height <= 0) {
        return;
    }
    
    ViewHolder *holder = [[ViewHolder alloc] init];
    holder.view = aView;
    holder.layerIndex = layerIndex;
    holder.superView = (uint64_t)superView;
    holder.rect = [aView rectIntersectionInWindow];// 获取 该view与window 交叉的 Rect
    
    if (!(CGRectIsEmpty(holder.rect) || CGRectIsNull(holder.rect))) {
        CGRect canShowFrame = [aView canShowFrameRecursive];
        if (!(CGRectIsEmpty(canShowFrame) || CGRectIsNull(canShowFrame))){
            if (!CGRectEqualToRect(canShowFrame, [UIScreen mainScreen].bounds)) {
                holder.rect = canShowFrame;
            }
            if ([aView isHitTest]) {
                [self addEventView:holder atIndent:layerIndex];
            }
        }
    }
    
    for (int i = 0; i < aView.subviews.count; i++) {
        UIView *v = aView.subviews[i];
        [self dumpView:v superView:aView layerIndex:layerIndex+1 toArray:holders];
    }
}

@end
