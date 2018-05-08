
#import "NSIndexSet+RACSequenceAdditions.h"
#import "RACIndexSetSequence.h"

@implementation NSIndexSet (RACSequenceAdditions)

- (RACSequence *)rac_sequence {
	return [RACIndexSetSequence sequenceWithIndexSet:self];
}

@end
