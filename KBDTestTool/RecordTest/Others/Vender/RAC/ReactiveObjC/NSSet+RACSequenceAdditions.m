
#import "NSSet+RACSequenceAdditions.h"
#import "NSArray+RACSequenceAdditions.h"

@implementation NSSet (RACSequenceAdditions)

- (RACSequence *)rac_sequence {
	// TODO: First class support for set sequences.
	return self.allObjects.rac_sequence;
}

@end
