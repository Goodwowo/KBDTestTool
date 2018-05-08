
#import "RACMulticastConnection.h"

@class RACSubject;

@interface RACMulticastConnection<__covariant ValueType> ()

- (instancetype)initWithSourceSignal:(RACSignal<ValueType> *)source subject:(RACSubject *)subject;

@end
