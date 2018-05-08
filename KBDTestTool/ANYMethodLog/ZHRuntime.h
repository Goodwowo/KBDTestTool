#import <Foundation/Foundation.h>

@interface ZHRuntime : NSObject

// 获取所有的方法名 只拿set方法
+ (NSArray *)allMethodsFromClass:(Class)cls;

@end
