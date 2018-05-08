
#import <UIKit/UIKit.h>
#import "RTToolView.h"

@interface RTPickerView : UIPickerView

@property (nonatomic,copy)NSString *curTitle;
@property (nonatomic, strong) RTToolView *toolBar;
@property (nonatomic, strong) UIView *containerView;

- (void)showRTPickerViewWithDataArray:(NSArray *)array commitBlock:(void(^)(NSString *string))commitBlock cancelBlock:(void(^)(void))cancelBlock;

@end
