
#import "UIScrollView+KVO.h"
#import "RecordTestHeader.h"

@implementation UIScrollView (KVO)

- (void)kvo{
    if (self.isKVO) {
        return;
    }
    if (KVO_Scroll) {
        [[RACObserve(self, contentOffset) distinctUntilChanged] subscribeNext:^(id x) {
            [RTOperationQueue addOperation:self type:(RTOperationQueueTypeScroll) parameters:@[x] repeat:NO];
        }];
    }
    self.isKVO = YES;
}

- (BOOL)runOperation:(RTOperationQueueModel *)model{
    BOOL result = NO;
    if (model) {
        if (model.viewId.length == self.layerDirector.length) {
            if ([model.viewId isEqualToString:self.layerDirector]) {
                if (model.type == RTOperationQueueTypeScroll) {
                    CGPoint point = [model.parameters[0] CGPointValue];
                    if (!CGRectContainsPoint(CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), point)) {
//                        NSLog(@"%@",@"滚动的位置 超出 可滚动的区域");
                    }
                    CGFloat verScrollOffsetY=point.y-self.contentOffset.y,horScrollOffsetX=point.x-self.contentOffset.x;
                    NSInteger direction=0;//direction 1左 2上 3右 4下
                    if (horScrollOffsetX>0) direction=3;
                    else if (horScrollOffsetX<0) direction=1;
                    if (verScrollOffsetY>0) direction=4;
                    else if (verScrollOffsetY<0) direction=2;
                    if (NeedSimilationView) [SimulationView addSwipeSimulationView:self.centerInWindow direction:direction afterDismiss:1];
                    [self setContentOffset:point animated:YES];
                    result = YES;
                }
            }
        }
    }
    if ([super runOperation:model]) {
        result = YES;
    }
    return result;
}

@end
