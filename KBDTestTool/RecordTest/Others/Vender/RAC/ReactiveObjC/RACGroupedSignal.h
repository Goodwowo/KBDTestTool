
#import "RACSubject.h"

NS_ASSUME_NONNULL_BEGIN

/// A grouped signal is used by -[RACSignal groupBy:transform:].
@interface RACGroupedSignal : RACSubject

/// The key shared by the group.
@property (nonatomic, readonly, copy) id<NSCopying> key;

+ (instancetype)signalWithKey:(id<NSCopying>)key;

@end

NS_ASSUME_NONNULL_END
