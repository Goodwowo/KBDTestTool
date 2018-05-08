
#import <Foundation/Foundation.h>

@class RACSignal<__covariant ValueType>;

NS_ASSUME_NONNULL_BEGIN

@interface NSFileHandle (RACSupport)

// Read any available data in the background and send it. Completes when data
// length is <= 0.
- (RACSignal<NSData *> *)rac_readInBackground;

@end

NS_ASSUME_NONNULL_END
