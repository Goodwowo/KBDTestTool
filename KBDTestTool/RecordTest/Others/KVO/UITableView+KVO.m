
#import "UITableView+KVO.h"
#import "RecordTestHeader.h"

@implementation UITableView (KVO)

- (void)kvo{
    if (self.isKVO) {
        return;
    }
    if (KVO_tableView_didSelectRowAtIndexPath) {
        if (self.delegate) {
            id delegate= self.delegate;
            [delegate aspect_hookSelector:@selector(tableView:didSelectRowAtIndexPath:) withOptions:AspectPositionAfter usingBlock:^{
                
            } before:^(id target, SEL sel, NSArray *args, int deep) {
                UITableView *tableView = args[0];
                NSIndexPath *indexPath = args[1];
                [RTOperationQueue addOperation:tableView type:(RTOperationQueueTypeTableViewCellTap) parameters:@[@(indexPath.section),@(indexPath.row)] repeat:YES];
//                NSLog(@"%@",@"👌tableView:didSelectRowAtIndexPath:");
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
                if (model.type == RTOperationQueueTypeTableViewCellTap) {
                    if (self.delegate) {
                        id delegate= self.delegate;
                        if ([delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                            @try {
                                [delegate tableView:self didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:[model.parameters[1] integerValue] inSection:[model.parameters[0] integerValue]]];
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
    if (model.type == RTOperationQueueTypeTableViewCellTap) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[model.parameters[1] integerValue] inSection:[model.parameters[0] integerValue]];
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        if (cell) {
            if (NeedSimilationView) [SimulationView addTouchSimulationView:cell.centerInWindow afterDismiss:1];
            return cell;
        }
    }
    return self;
}

@end
