//
//  UITableView+AutoScroll.m
//  CJOL
//
//  Created by mac on 2018/3/18.
//  Copyright © 2018年 SuDream. All rights reserved.
//

#import "UITableView+AutoScroll.h"
#import "UIScrollView+AutoScroll.h"
#import "AutoTestHeader.h"

@implementation UITableView (AutoScroll)

- (NSInteger)autoScroll{
    NSArray *cells = [self visibleCells];
    CGFloat verScrollOffsetY=self.contentOffset.y,horScrollOffsetX=self.contentOffset.x;
    CGFloat oldVerScrollOffsetY=self.contentOffset.y,oldHorScrollOffsetX=self.contentOffset.x;
    if (cells.count>0) {
        
        if (self.dataSource) {
            NSInteger numberOfSections = 1;
            NSInteger rows = 0;
            if([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]){
                numberOfSections = [self.dataSource numberOfSectionsInTableView:self];
            }
            if([self.dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]){
                numberOfSections = arc4random()%numberOfSections;
                rows = [self.dataSource tableView:self numberOfRowsInSection:numberOfSections];
            }
            if (rows > 0) {
                NSInteger row = arc4random()%rows;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:numberOfSections];
                NSArray *scrollPositions = @[@(UITableViewScrollPositionTop),@(UITableViewScrollPositionMiddle),@(UITableViewScrollPositionBottom)];
                NSInteger scrollPosition = [[scrollPositions randomObject] integerValue];
                
                if (self.delegate) {
                    if([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
                        [self.delegate scrollViewWillBeginDragging:self];
                    if([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
                        [self.delegate scrollViewWillBeginDecelerating:self];
                }
                
                [self scrollToRowAtIndexPath:indexPath atScrollPosition:(scrollPosition) animated:NO];
                
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
                
                verScrollOffsetY=self.contentOffset.y-verScrollOffsetY;
                horScrollOffsetX=self.contentOffset.x-horScrollOffsetX;
                [self setContentOffset:CGPointMake(oldHorScrollOffsetX, oldVerScrollOffsetY) animated:NO];
                [self scrollToRowAtIndexPath:indexPath atScrollPosition:(scrollPosition) animated:YES];
            }
        }
    }
    
    NSInteger direction=0;//direction 1左 2上 3右 4下
    if (horScrollOffsetX>0) direction=3;
    else if (horScrollOffsetX<0) direction=1;
    
    if (verScrollOffsetY>0) direction=4;
    else if (verScrollOffsetY<0) direction=2;
    
    return [super isTransformDirection:direction];
}

@end
