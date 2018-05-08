
#import "NSArray+RACSequenceAdditions.h"
#import "RACArraySequence.h"

@implementation NSArray (RACSequenceAdditions)

- (RACSequence *)rac_sequence {
	return [RACArraySequence sequenceWithArray:self offset:0];
}

@end
