
#import "ZHStatusBarLayoutMarginHelper.h"

UIEdgeInsets JDStatusBarRootVCLayoutMargin(void)
{
    UIEdgeInsets layoutMargins = [[[[[UIApplication sharedApplication] keyWindow] rootViewController] view] layoutMargins];
    if (layoutMargins.top > 8 && layoutMargins.bottom > 8) {
        return layoutMargins;
    } else {
        return UIEdgeInsetsZero;  // ignore default margins
    }
}
