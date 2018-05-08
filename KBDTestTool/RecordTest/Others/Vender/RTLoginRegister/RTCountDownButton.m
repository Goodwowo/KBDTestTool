#import "RTCountDownButton.h"

//#import "MBProgressHUD.h"

@interface RTCountDownButton ()

/** 保存起始状态下的title */
@property (nonatomic, copy) NSString *originalTitle;
/** 保存倒计时的时长 */
@property (nonatomic, assign) NSInteger tempDurationOfCountDown;
/** 定时器对象 */
@property (nonatomic, strong) NSTimer *ccpCountDownTimer;
/** 避免开始计时时快速连续点击显示问题 */
@property (nonatomic,assign) int count;
@end

@implementation RTCountDownButton


/**
 *   注意事项:
 *  在XIB,SB,或者是在代码中创建Button的时候,Button的样式要设置成为 Custom 样式,否则在倒计时过程中 Button 的Tittle 会闪动.
 */
- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    // 倒计时过程中title的改变不更新originalTitle
    if (self.tempDurationOfCountDown == self.durationOfCountDown) {
        self.originalTitle = title;
        self.originalColor = self.titleLabel.textColor;
    }
}


- (void)setDurationOfCountDown:(NSInteger)durationOfCountDown {
    _durationOfCountDown = durationOfCountDown;
    self.tempDurationOfCountDown = _durationOfCountDown;
}

- (void)setOriginalColor:(UIColor *)originalColor {
    
    _originalColor = originalColor;
    
    [self setTitleColor:originalColor forState:UIControlStateNormal];
}

- (void)setProcessColor:(UIColor *)processColor {
    
    _processColor = processColor;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        if (self.originalColor) {
            
            [self setTitleColor:self.originalColor forState:UIControlStateNormal];
        } else {
            
            //默认颜色红色
            [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        
        self.count = 0;
        // 设置默认的倒计时时长为60秒
        self.durationOfCountDown = 60;
        // 设置button的默认标题为“获取验证码”
        [self setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
        if (self.originalColor) {
            [self setTitleColor:self.originalColor forState:UIControlStateNormal];
        } else {
            //默认颜色红色
            [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        
        self.count = 0;
        // 设置默认的倒计时时长为60秒
        self.durationOfCountDown = 60;
        // 设置button的默认标题为“获取验证码”
        [self setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
    return self;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.count ++;
    // 若正在倒计时，不响应点击事件
    if (self.tempDurationOfCountDown != self.durationOfCountDown||self.count != 1) {
        self.count = 0;
        self.enabled = NO;
        return NO;
    }
    // 若未开始倒计时，响应并传递点击事件，开始倒计时
    if (self.beginBlock) {
        self.beginBlock();
    }
    return [super beginTrackingWithTouch:touch withEvent:event];
}

//创建定时器，开始倒计时
- (void)startCountDown {
    
    // 创建定时器
    self.ccpCountDownTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateCCPCountDownButtonTitle) userInfo:nil repeats:YES];
    // 将定时器添加到当前的RunLoop中（自动开启定时器）
    [[NSRunLoop currentRunLoop] addTimer:self.ccpCountDownTimer forMode:NSRunLoopCommonModes];
}

//更新RTCountDownButton的title为倒计时剩余的时间
- (void)updateCCPCountDownButtonTitle {
    if (self.tempDurationOfCountDown == 0) {
        // 设置RTCountDownButton的title为开始倒计时前的title
        [self setTitle:self.originalTitle forState:UIControlStateNormal];
        [self setTitleColor:self.originalColor forState:UIControlStateNormal];
        // 恢复RTCountDownButton开始倒计时
        self.tempDurationOfCountDown = self.durationOfCountDown;
        self.ccpCountDownTimer.fireDate=[NSDate distantFuture];
        [self.ccpCountDownTimer invalidate];
        self.ccpCountDownTimer=nil;
        self.count = 0;
        self.enabled = YES;
    } else {
        // 设置RTCountDownButton的title为当前倒计时剩余的时间
        [self setTitle:[NSString stringWithFormat:@"重新发送(%zds)", self.tempDurationOfCountDown--] forState:UIControlStateNormal];
        if (self.processColor) {
            [self setTitleColor:self.processColor forState:UIControlStateNormal];
        } else {
            //默认颜色 蓝色
            [self setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }
    }
}

- (void)dealloc {
    [self.ccpCountDownTimer invalidate];
}


@end
