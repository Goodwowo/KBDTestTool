
#import "RACScheduler.h"

NS_ASSUME_NONNULL_BEGIN

/// An abstract scheduler which asynchronously enqueues all its work to a Grand
/// Central Dispatch queue.
///
/// Because RACQueueScheduler is abstract, it should not be instantiated
/// directly. Create a subclass using the `RACQueueScheduler+Subclass.h`
/// interface and use that instead.
@interface RACQueueScheduler : RACScheduler
@end

NS_ASSUME_NONNULL_END
