
#import "UIControl+Event.h"
#import "AutoTestHeader.h"

@implementation UIControl (Event)

- (void)happenEvent{
    [super happenEvent];
    
    if (self.userInteractionEnabled&&self.alpha>0.1&&(![self isHidden])) {
        [self sendActionsForControlEvents:UIControlEventAllEvents];
    }
}

- (BOOL)isEventView{
    NSSet *allTargets=[self allTargets];
    if (allTargets.count>0) {
        if (self.enabled && self.userInteractionEnabled&&self.alpha>0.1&&(![self isHidden])) {
            [self cornerRadiusBySelfWithColor:AutoTest_UIControl_Action_Color];
            return YES;
        }
    }
    return [super isEventView];
}

@end
