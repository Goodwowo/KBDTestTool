
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A unit represents an empty value.
///
/// It should never be necessary to create a unit yourself. Just use +defaultUnit.
@interface RACUnit : NSObject

/// A singleton instance.
+ (RACUnit *)defaultUnit;

@end

NS_ASSUME_NONNULL_END
