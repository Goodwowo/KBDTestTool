
#import <UIKit/UIKit.h>

@class DXAlertView;

@protocol DXAlertViewDelegate <NSObject>
@optional
- (void)dxAlertView:(DXAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end;

@interface DXAlertView : UIView

@property (nonatomic,copy)void (^block)(NSInteger index);
@property (nonatomic,weak)id<DXAlertViewDelegate>delegate;

/**
 初始化Alertview

 @param title 标题
 @param message 内容
 @param cancelTitle 取消按钮
 @param otherBtnTitle 确定按钮
 */
-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelBtnTitle:(NSString *)cancelTitle otherBtnTitle:(NSString *)otherBtnTitle;

-(void)show;

@end
