
#import <Foundation/Foundation.h>

// A private block based transformer.
@interface RACValueTransformer : NSValueTransformer

+ (instancetype)transformerWithBlock:(id (^)(id value))block;

@end
