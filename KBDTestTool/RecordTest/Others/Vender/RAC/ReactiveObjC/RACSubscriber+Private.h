
#import "RACSubscriber.h"

// A simple block-based subscriber.
@interface RACSubscriber : NSObject <RACSubscriber>

// Creates a new subscriber with the given blocks.
+ (instancetype)subscriberWithNext:(void (^)(id x))next error:(void (^)(NSError *error))error completed:(void (^)(void))completed;

@end
