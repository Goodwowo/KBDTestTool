
#import "NSString+RACSequenceAdditions.h"
#import "RACStringSequence.h"

@implementation NSString (RACSequenceAdditions)

- (RACSequence *)rac_sequence {
	return [RACStringSequence sequenceWithString:self offset:0];
}

@end
