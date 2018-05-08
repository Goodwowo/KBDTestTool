
#import "RACSequence.h"

// Private class that adapts an array to the RACSequence interface.
@interface RACIndexSetSequence : RACSequence

+ (RACSequence *)sequenceWithIndexSet:(NSIndexSet *)indexSet;

@end
