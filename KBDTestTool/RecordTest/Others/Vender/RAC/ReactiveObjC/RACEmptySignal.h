
#import "RACSignal.h"

// A private `RACSignal` subclasses that synchronously sends completed to any
// subscribers.
@interface RACEmptySignal<__covariant ValueType> : RACSignal<ValueType>

+ (RACSignal<ValueType> *)empty;

@end
