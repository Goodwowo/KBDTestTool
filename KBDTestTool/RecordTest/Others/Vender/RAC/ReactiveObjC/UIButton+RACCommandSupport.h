
#import <UIKit/UIKit.h>

@class RACCommand<__contravariant InputType, __covariant ValueType>;

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (RACCommandSupport)

/// Sets the button's command. When the button is clicked, the command is
/// executed with the sender of the event. The button's enabledness is bound
/// to the command's `canExecute`.
@property (nonatomic, strong, nullable) RACCommand<__kindof UIButton *, id> *rac_command;

@end

NS_ASSUME_NONNULL_END
