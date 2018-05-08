
#import "UIPickerView+KVO.h"
#import "RecordTestHeader.h"

@implementation UIPickerView (KVO)

- (void)kvo{
    if (self.isKVO) {
        return;
    }
    if (KVO_collectionView_didSelectRowAtIndexPath) {
        if (self.delegate) {
            id delegate= self.delegate;
            [delegate aspect_hookSelector:@selector(pickerView:didSelectRow:inComponent:) withOptions:AspectPositionAfter usingBlock:^{
                
            } before:^(id target, SEL sel, NSArray *args, int deep) {
                UIPickerView *pickerView = args[0];
                NSInteger row = [args[1] integerValue];
                NSInteger component = [args[2] integerValue];
                
                [RTOperationQueue addOperation:pickerView type:(RTOperationQueueTypePickerViewItemTap) parameters:@[@(row),@(component)] repeat:YES];
//                NSLog(@"%@",@"👌pickerView:didSelectRow:inComponent:");
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
                if (model.type == RTOperationQueueTypePickerViewItemTap) {
                    if (self.delegate) {
                        id delegate= self.delegate;
                        if ([delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
                            @try {
                                [delegate pickerView:self didSelectRow:[model.parameters[0] integerValue] inComponent:[model.parameters[1] integerValue]];
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
    if (model.type == RTOperationQueueTypePickerViewItemTap) {
        NSInteger row = [model.parameters[0] integerValue];
        NSInteger component = [model.parameters[1] integerValue];
        UIView *view = [self viewForRow:row forComponent:component];
        if (view) {
            if (NeedSimilationView) [SimulationView addTouchSimulationView:view.centerInWindow afterDismiss:1];
            return view;
        }
    }
    return self;
}

@end
