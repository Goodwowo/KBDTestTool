
#import "RACGroupedSignal.h"

@interface RACGroupedSignal ()
@property (nonatomic, copy) id<NSCopying> key;
@end

@implementation RACGroupedSignal

#pragma mark API

+ (instancetype)signalWithKey:(id<NSCopying>)key {
	RACGroupedSignal *subject = [self subject];
	subject.key = key;
	return subject;
}

@end
