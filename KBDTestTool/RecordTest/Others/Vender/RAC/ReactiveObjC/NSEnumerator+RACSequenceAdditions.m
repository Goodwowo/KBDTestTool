
#import "NSEnumerator+RACSequenceAdditions.h"
#import "RACSequence.h"

@implementation NSEnumerator (RACSequenceAdditions)

- (RACSequence *)rac_sequence {
	return [RACSequence sequenceWithHeadBlock:^{
		return [self nextObject];
	} tailBlock:^{
		return self.rac_sequence;
	}];
}

@end
