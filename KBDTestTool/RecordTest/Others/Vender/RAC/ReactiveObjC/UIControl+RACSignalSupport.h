
#import <UIKit/UIKit.h>

@class RACSignal<__covariant ValueType>;

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (RACSignalSupport)

/// Creates and returns a signal that sends the sender of the control event
/// whenever one of the control events is triggered.
- (RACSignal<__kindof UIControl *> *)rac_signalForControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END
