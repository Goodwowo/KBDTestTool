
#import "UIView+AutoTestExt.h"
#import "AutoTestHeader.h"

@implementation UIView (AutoTestExt)

- (UIViewController *)getViewController{
    for (UIView *view = self.superview; view; view = view.superview) {
        UIResponder *responder = [view nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

/**判断是否被自己标志过边框*/
- (BOOL)isCornerRadiusBySelf{
    return self.layer.cornerRadius==AutoTest_CornerRadius&&self.layer.borderWidth==AutoTest_CornerBorderWidth;
}

/**判断是否可以标志过边框,因为一旦控件本身已经被切边框,这个时候,我们不应该私自修改边框大小*/
- (BOOL)canCornerRadiusBySelf{
    return self.layer.cornerRadius==AutoTest_CornerRadius;
}

- (void)cornerRadiusBySelfWithColor:(UIColor *)color{
    self.layer.borderColor=[color CGColor];
    if (![self isCornerRadiusBySelf]) {
        if ([self canCornerRadiusBySelf]) {
            self.layer.cornerRadius=AutoTest_CornerRadius;
        }
        self.layer.borderWidth=AutoTest_CornerBorderWidth;
    }
}

- (NSString *)textDescription{
    NSString *text = nil;
    if ([self isKindOfClass:[UILabel class]] || [self isKindOfClass:[UITextView class]] || [self isKindOfClass:[UITextField class]]) {
        id obj = self;
        text = [obj text];
    }
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self;
        text = button.currentTitle;
    }
    return text ?: @"";
}

@end
