
#import "RACUnit.h"

@implementation RACUnit

#pragma mark API

+ (RACUnit *)defaultUnit {
	static dispatch_once_t onceToken;
	static RACUnit *defaultUnit = nil;
	dispatch_once(&onceToken, ^{
		defaultUnit = [[self alloc] init];
	});
	
	return defaultUnit;
}

@end
