
#import "RACSignal.h"

// A private `RACSignal` subclasses that implements its subscription behavior
// using a block.
@interface RACDynamicSignal : RACSignal

+ (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe;

@end
