#import "RTPublicFooterButtonView.h"
#import "AutoTestHeader.h"
#import "RecordTestHeader.h"

@interface RTPublicFooterButtonView ()

@end

@implementation RTPublicFooterButtonView

- (UIButton *)button{
    if (!_button) {
        _button=[[UIButton alloc] initWithFrame:CGRectMake(25, (self.height -44)/2.0, self.width-50,44)];
        _button.backgroundColor=RGB(0, 78, 162);
        _button.layer.cornerRadius=3;
        _button.layer.masksToBounds=YES;
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self  addSubview:_button];
    }
    return _button;
}

- (UIButton *)leftButton{
    if (!_leftButton) {
        _leftButton=[[UIButton alloc] initWithFrame:CGRectMake(25, (self.height -44)/2.0, (self.width-50-20)/2.0,44)];
        _leftButton.backgroundColor=RGB(0, 78, 162);
        _leftButton.layer.cornerRadius=3;
        _leftButton.layer.masksToBounds=YES;
        [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self  addSubview:_leftButton];
    }
    return _leftButton;
}

- (UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton=[[UIButton alloc] initWithFrame:CGRectMake(self.width/2.0+10, (self.height -44)/2.0, (self.width-50-20)/2.0,44)];
        _rightButton.backgroundColor=RGB(0, 78, 162);
        _rightButton.layer.cornerRadius=3;
        _rightButton.layer.masksToBounds=YES;
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self  addSubview:_rightButton];
    }
    return _rightButton;
}


- (instancetype)publicFooterOneButtonViewWithFrame:(CGRect)frame withTitle:(NSString *)title withTarget:(id)target withSelector:(SEL)action{
    self.frame=frame;
    [self.button setTitle:title forState:UIControlStateNormal];
    if (target&&action) {
        [self.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    self.button.backgroundColor=[UIColor whiteColor];
    [self.button setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    return self;
}

- (instancetype)publicFooterTwoButtonViewWithFrame:(CGRect)frame withLeftTitle:(NSString *)leftTitle withRightTitle:(NSString *)rightTitle withTarget:(id)target withLeftSelector:(SEL)leftSelectorAction withRightSelector:(SEL)rightSelectorAction{
    self.frame=frame;
    [self.leftButton setTitle:leftTitle forState:UIControlStateNormal];
    if (target&&leftSelectorAction) {
        [self.leftButton addTarget:target action:leftSelectorAction forControlEvents:UIControlEventTouchUpInside];
    }
    [self.rightButton setTitle:rightTitle forState:UIControlStateNormal];
    if (target&&rightSelectorAction) {
        [self.rightButton addTarget:target action:rightSelectorAction forControlEvents:UIControlEventTouchUpInside];
    }
    [self.leftButton setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    self.leftButton.backgroundColor=[UIColor whiteColor];
    [self.rightButton setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    self.rightButton.backgroundColor=[UIColor whiteColor];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    return self;
}

@end
