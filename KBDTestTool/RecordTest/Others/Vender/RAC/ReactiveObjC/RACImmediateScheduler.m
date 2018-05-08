
#import "RACImmediateScheduler.h"
#import "RACScheduler+Private.h"

@implementation RACImmediateScheduler

#pragma mark Lifecycle

- (instancetype)init {
	return [super initWithName:@"org.reactivecocoa.ReactiveObjC.RACScheduler.immediateScheduler"];
}

#pragma mark RACScheduler

- (RACDisposable *)schedule:(void (^)(void))block {
	NSCParameterAssert(block != NULL);

	block();
	return nil;
}

- (RACDisposable *)after:(NSDate *)date schedule:(void (^)(void))block {
	NSCParameterAssert(date != nil);
	NSCParameterAssert(block != NULL);

	[NSThread sleepUntilDate:date];
	block();

	return nil;
}

- (RACDisposable *)after:(NSDate *)date repeatingEvery:(NSTimeInterval)interval withLeeway:(NSTimeInterval)leeway schedule:(void (^)(void))block {
	NSCAssert(NO, @"+[RACScheduler immediateScheduler] does not support %@.", NSStringFromSelector(_cmd));
	return nil;
}

- (RACDisposable *)scheduleRecursiveBlock:(RACSchedulerRecursiveBlock)recursiveBlock {
	for (__block NSUInteger remaining = 1; remaining > 0; remaining--) {
		recursiveBlock(^{
			remaining++;
		});
	}

	return nil;
}

@end
