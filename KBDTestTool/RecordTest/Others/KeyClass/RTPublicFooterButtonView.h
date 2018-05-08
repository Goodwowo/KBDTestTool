#import <UIKit/UIKit.h>

@interface RTPublicFooterButtonView : UIView

@property (nonatomic,strong)UIButton *button;
@property (nonatomic,strong)UIButton *leftButton;
@property (nonatomic,strong)UIButton *rightButton;

- (instancetype)publicFooterOneButtonViewWithFrame:(CGRect)frame withTitle:(NSString *)title withTarget:(id)target withSelector:(SEL)action;

- (instancetype)publicFooterTwoButtonViewWithFrame:(CGRect)frame withLeftTitle:(NSString *)leftTitle withRightTitle:(NSString *)rightTitle withTarget:(id)target withLeftSelector:(SEL)leftSelectorAction withRightSelector:(SEL)rightSelectorAction;

@end
