
#import "RACSignal.h"

// A private `RACSignal` subclass that synchronously sends an error to any
// subscriber.
@interface RACErrorSignal : RACSignal

+ (RACSignal *)error:(NSError *)error;

@end
