
#import "UINavigationController+Swizzle.h"
#import "NSObject+Swizzle.h"
#import "AutoTestHeader.h"

@implementation UINavigationController (Swizzle)

+ (void)load{
    [super load];
    if (AutoTest) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self swizzleInstanceMethod:@selector(pushViewController:animated:) with:@selector(custom_pushViewController:animated:)];
            [self swizzleInstanceMethod:@selector(popViewControllerAnimated:) with:@selector(custom_popViewControllerAnimated:)];
        });
    }
}

- (void)custom_pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [self custom_pushViewController:viewController animated:Push_Pop_Present_Dismiss_Animation];
}

- (UIViewController *)custom_popViewControllerAnimated:(BOOL)animated{
    return [self custom_popViewControllerAnimated:Push_Pop_Present_Dismiss_Animation];
}

@end
