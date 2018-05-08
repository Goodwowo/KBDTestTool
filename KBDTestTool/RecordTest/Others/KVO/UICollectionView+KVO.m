
#import "UICollectionView+KVO.h"
#import "RecordTestHeader.h"

@implementation UICollectionView (KVO)

- (void)kvo{
    if (self.isKVO) {
        return;
    }
    if (KVO_collectionView_didSelectRowAtIndexPath) {
        if (self.delegate) {
            id delegate= self.delegate;
            [delegate aspect_hookSelector:@selector(collectionView:didSelectItemAtIndexPath:) withOptions:AspectPositionAfter usingBlock:^{
                
            } before:^(id target, SEL sel, NSArray *args, int deep) {
                UICollectionView *collectionView = args[0];
                NSIndexPath *indexPath = args[1];
                [RTOperationQueue addOperation:collectionView type:(RTOperationQueueTypeCollectionViewCellTap) parameters:@[@(indexPath.section),@(indexPath.row)] repeat:YES];
//                NSLog(@"%@",@"👌collectionView:didSelectRowAtIndexPath:");
            } after:nil error:nil];
        }
    }
    if (KVO_Super) {
        [super kvo];
    }
    self.isKVO = YES;
}

- (BOOL)runOperation:(RTOperationQueueModel *)model{
    BOOL result = NO;
    if (model) {
        if (model.viewId.length == self.layerDirector.length) {
            if ([model.viewId isEqualToString:self.layerDirector]) {
                if (model.type == RTOperationQueueTypeCollectionViewCellTap) {
                    if (self.delegate) {
                        id delegate= self.delegate;
                        if ([delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
                            @try {
                                [delegate collectionView:self didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:[model.parameters[1] integerValue] inSection:[model.parameters[0] integerValue]]];
                                result = YES;
                            } @catch (NSException *exception) {
                                //捕获异常
                            } @finally {
                                //这里一定执行，无论你异常与否
                            }
                        }
                    }
                }
            }
        }
    }
    if ([super runOperation:model]) {
        result = YES;
    }
    return result;
}

- (UIView *)targetViewWithOperation:(RTOperationQueueModel *)model{
    if (model.type == RTOperationQueueTypeCollectionViewCellTap) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[model.parameters[1] integerValue] inSection:[model.parameters[0] integerValue]];
        UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
        if (cell) {
            if (NeedSimilationView) [SimulationView addTouchSimulationView:cell.centerInWindow afterDismiss:1];
            return cell;
        }
    }
    return self;
}

@end
