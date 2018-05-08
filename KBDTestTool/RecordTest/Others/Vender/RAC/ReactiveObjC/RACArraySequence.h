
#import "RACSequence.h"

// Private class that adapts an array to the RACSequence interface.
@interface RACArraySequence : RACSequence

// Returns a sequence for enumerating over the given array, starting from the
// given offset. The array will be copied to prevent mutation.
+ (RACSequence *)sequenceWithArray:(NSArray *)array offset:(NSUInteger)offset;

@end
