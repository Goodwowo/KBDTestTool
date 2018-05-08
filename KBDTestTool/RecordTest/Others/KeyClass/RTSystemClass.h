
#import <UIKit/UIKit.h>

@interface RTSystemClass : NSObject

+ (RTSystemClass *)shareInstance;
- (NSArray *)getNoSystemClass;
- (BOOL)isSystemClass:(Class)cls;

@end
