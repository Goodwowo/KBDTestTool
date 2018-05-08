
#import "RTGetTargetView.h"
#import "RecordTestHeader.h"

@implementation RTGetTargetView

- (UIView *)getTargetView:(NSString *)viewId{
    UIView *target = nil;
    for (int i = 0; i < [UIApplication sharedApplication].windows.count; i++) {
        UIWindow *window = [UIApplication sharedApplication].windows[i];
        if (window.subviews.count > 0) {
            target = [self dumpView:window viewId:viewId];
            if(target) return target;
        }
    }
    return target;
}

- (UIView *)dumpView:(UIView *)aView viewId:(NSString *)viewId{
    if (aView.layerDirector.length == viewId.length) {
        if ([aView.layerDirector isEqualToString:viewId]) {
            return aView;
        }
    }
    //继续递归遍历
    UIView *target = nil;
    for (UIView *view in [aView subviews]){
        target = [self dumpView:view viewId:viewId];
        if(target) return target;
    }
    return target;
}

@end
