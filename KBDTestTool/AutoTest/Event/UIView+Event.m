
#import "UIView+Event.h"
#import "AutoTestHeader.h"

@implementation UIView (Event)

- (void)happenEvent{
    NSArray *gestureRecognizers=self.gestureRecognizers;
    if (gestureRecognizers.count>0) {
        for (UIGestureRecognizer *ges in gestureRecognizers) {
            if ([ges isKindOfClass:[UITapGestureRecognizer class]]) {
                if (ges.view) {
                    
                    NSArray *allTargetAndAction=[ges allGestureRecognizerTargetAndAction];
                    for (ZHGestureRecognizerTargetAndAction *targetAndAction in allTargetAndAction) {
                        
                        if ([targetAndAction.target respondsToSelector:targetAndAction.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            [targetAndAction.target performSelector:targetAndAction.action withObject:ges];
#pragma clang diagnostic pop
                        }
                    }
                }
            }
        }
    }
}

- (BOOL)isEventView{
    NSArray *gestureRecognizers=self.gestureRecognizers;
    if (gestureRecognizers.count>0) {
        for (UIGestureRecognizer *ges in gestureRecognizers) {
            if ([ges isKindOfClass:[UITapGestureRecognizer class]]) {
                if (ges.view) {
                    NSArray *allTargetAndAction=[ges allGestureRecognizerTargetAndAction];
                    if (allTargetAndAction.count>0) {
                        [ges.view cornerRadiusBySelfWithColor:AutoTest_Ges_Tap_Color];
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

@end
