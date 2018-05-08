
#import "UISegmentedControl+KVO.h"
#import "RecordTestHeader.h"

@implementation UISegmentedControl (KVO)

- (void)kvo{
    if (self.isKVO) {
        return;
    }
    if (KVO_Event) {
        NSSet *allTargets=[self allTargets];
        if (allTargets.count>0) {
            for (id target in allTargets) {
                NSArray *actions = [self actionsForTarget:target forControlEvent:(UIControlEventValueChanged)];
                if (actions.count > 0) {
                    NSString *action = actions[0];
                    SEL sel = NSSelectorFromString(action);
                    if (target && [target respondsToSelector:sel]) {
                        __weak typeof(self)weakSelf=self;
                        [target aspect_hookSelector:sel withOptions:AspectPositionAfter usingBlock:^{
                        } before:^(id target, SEL sel, NSArray *args, int deep) {
                            UIView *view = weakSelf;
                            NSInteger selectedSegmentIndex = 0;
                            if (args.count>0) {
                                id obj = args[0];
                                if([obj isKindOfClass:[UISegmentedControl class]]){
                                    UISegmentedControl * segment = (UISegmentedControl *)obj;
                                    selectedSegmentIndex = segment.selectedSegmentIndex;
                                }
                            }
//                            NSLog(@"%@ - %@ : %@",@"👌Control evevnt",target,NSStringFromSelector(sel));
                            [RTOperationQueue addOperation:view type:(RTOperationQueueTypeEvent) parameters:@[NSStringFromSelector(sel),@(selectedSegmentIndex)] repeat:YES];
                        } after:nil error:nil];
                    }
                }
            }
        }else{
            if (KVO_Super) {
                [super kvo];
            }
        }
    }
    self.isKVO = YES;
}

- (BOOL)runOperation:(RTOperationQueueModel *)model{
    BOOL result = NO;
    if (model) {
        if (model.viewId.length == self.layerDirector.length) {
            if ([model.viewId isEqualToString:self.layerDirector]) {
                if (model.type == RTOperationQueueTypeEvent) {
                    NSString *selString = model.parameters[0];
                    NSInteger selectedSegmentIndex = [model.parameters[1] integerValue];
                    self.selectedSegmentIndex = selectedSegmentIndex;
//                    NSLog(@"selString = %@",selString);
                    SEL ori_sel = NSSelectorFromString(selString);
                    NSSet *allTargets=[self allTargets];
                    if (allTargets.count>0) {
                        for (id target in allTargets) {
                            if (target && [target respondsToSelector:ori_sel]) {
                                [self sendActionsForControlEvents:UIControlEventAllEvents];
                                result = YES;
                                break;
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

@end
