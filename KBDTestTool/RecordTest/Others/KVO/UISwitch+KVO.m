
#import "UISwitch+KVO.h"
#import "RecordTestHeader.h"

@implementation UISwitch (KVO)

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
                            if (args.count>0) {
                                id obj = args[0];
                                if([obj isKindOfClass:[UIView class]]){
                                    view = (UIView *)obj;
                                }
                            }
//                            NSLog(@"%@ - %@ : %@",@"👌Control evevnt",target,NSStringFromSelector(sel));
                            [RTOperationQueue addOperation:view type:(RTOperationQueueTypeEvent) parameters:@[NSStringFromSelector(sel)] repeat:YES];
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
//                    NSLog(@"selString = %@",selString);
                    SEL ori_sel = NSSelectorFromString(selString);
                    NSSet *allTargets=[self allTargets];
                    if (allTargets.count>0) {
                        for (id target in allTargets) {
                            if (target && [target respondsToSelector:ori_sel]) {
                                self.on = !self.on;
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
