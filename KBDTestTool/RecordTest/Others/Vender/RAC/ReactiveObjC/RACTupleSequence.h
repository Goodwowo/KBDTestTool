
#import "RACSequence.h"

// Private class that adapts a RACTuple to the RACSequence interface.
@interface RACTupleSequence : RACSequence

// Returns a sequence for enumerating over the given backing array (from a
// RACTuple), starting from the given offset.
+ (RACSequence *)sequenceWithTupleBackingArray:(NSArray *)backingArray offset:(NSUInteger)offset;

@end
