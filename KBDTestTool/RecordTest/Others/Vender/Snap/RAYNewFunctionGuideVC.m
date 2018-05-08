
#import "RAYNewFunctionGuideVC.h"
#import "UIView+Frame.h"

#define WINSIZE [UIScreen mainScreen].bounds.size
#define AlphaBackcolor 0.65


@interface RAYNewFunctionGuideVC ()
/// 上方的黑色透明背景View
@property (nonatomic, strong) UIView *topView;
/// 左方的黑色透明背景View
@property (nonatomic, strong) UIView *leftView;
/// 右方的黑色透明背景View
@property (nonatomic, strong) UIView *rightView;
/// 下方的黑色透明背景View
@property (nonatomic, strong) UIView *bottomView;
/// 中间的透明圆角View
@property (nonatomic, strong) UIView *midView;

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation RAYNewFunctionGuideVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resetBtnFrame];
}
- (void)resetBtnFrame{
    if (self.titleGuide.length>0) {
        CGRect rect = self.frameGuide;
        self.midView.left = rect.origin.x;
        self.midView.top = rect.origin.y;
        if (rect.size.width>0) {
            self.midView.width = rect.size.width;
        }else{
            self.midView.width = WINSIZE.width/375*120;
        }
        if (rect.size.height>0) {
            self.midView.height = rect.size.height;
        }
        [self.view layoutIfNeeded];
        self.titleLab.text = self.titleGuide;
        [self resetSubViewsFrameWithBtnFrame:self.midView.frame];
        [self lineDashBorder:self.midView];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetSubViewsFrameWithBtnFrame:(CGRect)frame{

    CGFloat btnX = frame.origin.x;
    CGFloat btnY = frame.origin.y;
    CGFloat btnW = frame.size.width;
    CGFloat btnH = frame.size.height;
    
    self.topView.frame = CGRectMake(0, 0, WINSIZE.width, btnY);
    self.leftView.frame = CGRectMake(0, btnY, btnX, btnH);
    self.rightView.frame = CGRectMake(btnX+btnW, btnY, WINSIZE.width - (btnX+btnW), btnH);
    self.bottomView.frame = CGRectMake(0, btnY+btnH, WINSIZE.width, WINSIZE.height - (btnY+btnH));
    
    self.titleLab.frame = CGRectMake(0, 0, WINSIZE.width - 40, WINSIZE.height - 40);
    self.titleLab.center = self.view.center;
    [self.view addSubview:self.titleLab];
    [self.view layoutIfNeeded];
}

-(UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab =[[UILabel alloc]init];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.numberOfLines = 0;
        _titleLab.font = [UIFont systemFontOfSize:24];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.shadowColor = [UIColor blackColor];
        _titleLab.shadowOffset = CGSizeMake(1, 1);
    }
    return _titleLab;
}

#pragma mark - # Getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:AlphaBackcolor];
        [self.view addSubview:_topView];
    }
    return _topView;
}

- (UIView *)leftView {
    if (!_leftView) {
        _leftView = [[UIView alloc] init];
        _leftView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:AlphaBackcolor];
        [self.view addSubview:_leftView];
    }
    return _leftView;
}

- (UIView *)rightView {
    if (!_rightView) {
        _rightView = [[UIView alloc] init];
        _rightView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:AlphaBackcolor];
        [self.view addSubview:_rightView];
    }
    return _rightView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:AlphaBackcolor];
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIView *)midView {
    if (!_midView) {
        _midView = [[UIView alloc] init];
        [self.view addSubview:_midView];
    }
    return _midView;
}

- (void)lineDashBorder:(UIView *)view{
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.bounds = view.bounds;//虚线框的大小
    borderLayer.position = CGPointMake(CGRectGetMidX(view.bounds),CGRectGetMidY(view.bounds));//虚线框锚点
    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:10].CGPath;//矩形路径
    borderLayer.lineWidth = 5. / [[UIScreen mainScreen] scale];//虚线宽度
    
    //虚线边框
    borderLayer.lineDashPattern = @[@5, @5];
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = [UIColor redColor].CGColor;
    [view.layer addSublayer:borderLayer];
}

@end
