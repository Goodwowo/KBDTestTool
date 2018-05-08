
#import "NSDictionary+RACSequenceAdditions.h"
#import "NSArray+RACSequenceAdditions.h"
#import "RACSequence.h"
#import "RACTuple.h"

@implementation NSDictionary (RACSequenceAdditions)

- (RACSequence *)rac_sequence {
	NSDictionary *immutableDict = [self copy];

	// TODO: First class support for dictionary sequences.
	return [immutableDict.allKeys.rac_sequence map:^(id key) {
		id value = immutableDict[key];
		return RACTuplePack(key, value);
	}];
}

- (RACSequence *)rac_keySequence {
	return self.allKeys.rac_sequence;
}

- (RACSequence *)rac_valueSequence {
	return self.allValues.rac_sequence;
}

@end
