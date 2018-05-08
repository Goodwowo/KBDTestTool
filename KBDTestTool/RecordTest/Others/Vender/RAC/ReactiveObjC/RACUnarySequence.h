
#import "RACSequence.h"

// Private class representing a sequence of exactly one value.
@interface RACUnarySequence : RACSequence

+ (RACUnarySequence *)return:(id)value;

@end
