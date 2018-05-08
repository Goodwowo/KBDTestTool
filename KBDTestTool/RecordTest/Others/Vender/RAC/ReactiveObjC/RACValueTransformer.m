
#import "RACValueTransformer.h"

@interface RACValueTransformer ()
@property (nonatomic, copy) id (^transformBlock)(id value);
@end


@implementation RACValueTransformer


#pragma mark NSValueTransformer

+ (BOOL)allowsReverseTransformation {
	return NO;
}

- (id)transformedValue:(id)value {
    return self.transformBlock(value);
}


#pragma mark API

@synthesize transformBlock;

+ (instancetype)transformerWithBlock:(id (^)(id value))block {
	NSCParameterAssert(block != NULL);
	
	RACValueTransformer *transformer = [[self alloc] init];
	transformer.transformBlock = block;
	return transformer;
}

@end
