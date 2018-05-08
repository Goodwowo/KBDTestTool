
#import "JohnTopAlert.h"
#import "UIView+RT.h"
#import "UIColor+SDColor.h"

@interface JohnTopAlert ()

@property (nonatomic,strong) UILabel *alertLB;

@property (nonatomic,weak) UIImageView *pointIMGV;

@property (nonatomic,weak) UILabel *pointLB;

@end

@implementation JohnTopAlert

- (instancetype)init{
    if (self = [super init]) {
        self.frame = CGRectMake(0, -64,[UIScreen mainScreen].bounds.size.width, 64);
        self.userInteractionEnabled = YES;
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(removeAlert)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
        [self addGestureRecognizer:recognizer];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeAlert)];
        [self addGestureRecognizer:tap];
        
        
        self.alertShowTime = 3.f;
        [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:5.f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
             self.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2,32);
        } completion:^(BOOL finished) {
          [self performSelector:@selector(removeAlert) withObject:nil afterDelay:self.alertShowTime];
        }];
//        [UIView transitionWithView:self duration:0.25 options:0 animations:^{
//            self.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2,32);
//        } completion:^(BOOL finished) {
//            [self performSelector:@selector(removeAlert) withObject:nil afterDelay:self.alertShowTime];
//        }];
        
       [self createAlert];
    }
    return self;
}

#pragma mark - 基础设置
- (void)createAlert{
    self.isNoNeedKVO = self.isNoNeedSnap = YES;
    //设置提示图
    self.backgroundColor = [UIColor colorWithHexString:@"3691D1"];
    UIImageView *alertIMGV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 20 +(self.frame.size.height - 40)/ 2 , 20, 20)];
    [self addSubview:alertIMGV];
    self.pointIMGV = alertIMGV;
    
    //设置提示信息
    UILabel *alertMsg = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(alertIMGV.frame) + 10, 20 +(self.frame.size.height - 20 - 42) / 2, self.frame.size.width - CGRectGetMaxX(alertIMGV.frame) - 10 - 10 - 10, 42)];
    alertMsg.textColor = [UIColor whiteColor];
    alertMsg.textAlignment = NSTextAlignmentLeft;
    alertMsg.font = [UIFont systemFontOfSize:17.f];
    alertMsg.numberOfLines = 2;
    [self addSubview:alertMsg];
    self.pointLB = alertMsg;
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, .5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView];
    
}

#pragma mark - 根据外部调用个性化显示
- (void)setAlertBgColor:(UIColor *)alertBgColor{
    self.backgroundColor = alertBgColor;
}

- (void)alertWithType:(JohnTopAlertType)type title:(NSString *)title{
    self.pointLB.text = title;
    if (type == JohnTopAlertTypeSuccess) {
        self.pointIMGV.image = [UIImage imageNamed:@"bannertips_success_blue"];
    }
    if (type == JohnTopAlertTypeError) {
        self.pointIMGV.image = [UIImage imageNamed:@"bannertips_warning"];
    }
    
    if (type == JohnTopAlertTypeMessage) {
        self.pointIMGV.image = [UIImage imageNamed:@"bannertips_message"];
    }
}

- (void)setTextColor:(UIColor *)textColor{
    self.pointLB.textColor = textColor;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
}

#pragma mark -  展示提示框
- (void)show{
   UIWindow *window = [UIApplication sharedApplication].keyWindow;
   [window addSubview:self];
}

#pragma mark - 移除提示框
- (void)removeAlert{
    [UIView transitionWithView:self duration:0.25 options:0 animations:^{
        self.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2,-32);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
   
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
   
}

@end
