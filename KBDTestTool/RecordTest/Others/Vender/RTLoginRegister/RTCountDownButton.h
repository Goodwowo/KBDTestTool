#import <UIKit/UIKit.h>

typedef void(^BeginBlock)();

@interface RTCountDownButton : UIButton

/** 验证码倒计时的时长 */
@property (nonatomic, assign) NSInteger durationOfCountDown;
//原始 字体颜色
@property (nonatomic,strong) UIColor *originalColor;
//倒计时 字体颜色
@property (nonatomic,strong) UIColor *processColor;
//开始倒计时触发事件
@property (nonatomic,copy) BeginBlock beginBlock;
//开始计时
- (void)startCountDown;

@end
