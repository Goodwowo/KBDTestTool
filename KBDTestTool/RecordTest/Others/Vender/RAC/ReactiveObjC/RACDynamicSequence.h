
#import "RACSequence.h"

// Private class that implements a sequence dynamically using blocks.
@interface RACDynamicSequence : RACSequence

// Returns a sequence which evaluates `dependencyBlock` only once, the first
// time either `headBlock` or `tailBlock` is evaluated. The result of
// `dependencyBlock` will be passed into `headBlock` and `tailBlock` when
// invoked.
+ (RACSequence *)sequenceWithLazyDependency:(id (^)(void))dependencyBlock headBlock:(id (^)(id dependency))headBlock tailBlock:(RACSequence *(^)(id dependency))tailBlock;

@end
