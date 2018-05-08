
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    JohnTopAlertTypeSuccess  = 1,  //成功
    JohnTopAlertTypeError   = 0,  //失败
    JohnTopAlertTypeMessage = 2,  //普通提示消息
}JohnTopAlertType;
@interface JohnTopAlert : UIView

//提示框背景颜色，默认颜色3691D1  232，78，64
@property (nonatomic,weak) UIColor *alertBgColor;

//提示框显示时间，默认1.0s
@property (nonatomic,assign) CGFloat alertShowTime;

@property (nonatomic,strong) UIColor *textColor;

@property (nonatomic,assign) NSInteger statusStyle;

- (void)alertWithType:(JohnTopAlertType)type title:(NSString *)title;

- (void)show;

@end
