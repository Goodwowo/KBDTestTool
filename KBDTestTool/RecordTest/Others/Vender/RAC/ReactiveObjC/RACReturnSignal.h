
#import "RACSignal.h"

// A private `RACSignal` subclasses that synchronously sends a value to any
// subscribers, then completes.
@interface RACReturnSignal<__covariant ValueType> : RACSignal<ValueType>

+ (RACSignal<ValueType> *)return:(ValueType)value;

@end
