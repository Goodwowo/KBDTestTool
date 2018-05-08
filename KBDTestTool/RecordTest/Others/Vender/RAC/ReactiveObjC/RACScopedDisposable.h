
#import "RACDisposable.h"

NS_ASSUME_NONNULL_BEGIN

/// A disposable that calls its own -dispose when it is dealloc'd.
@interface RACScopedDisposable : RACDisposable

/// Creates a new scoped disposable that will also dispose of the given
/// disposable when it is dealloc'd.
+ (instancetype)scopedDisposableWithDisposable:(RACDisposable *)disposable;

@end

NS_ASSUME_NONNULL_END
