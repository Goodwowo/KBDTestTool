#import "ZHRuntime.h"
#import <objc/runtime.h>

@implementation ZHRuntime

//返回指定某个类的所有方法名 只拿set方法
+ (NSArray *)allMethodsFromClass:(Class)cls{
    NSMutableArray *methodArr=[NSMutableArray array];
    unsigned int outCount = 0;
    Method *methods = class_copyMethodList(cls, &outCount);
    for (int i = 0; i < outCount; ++i) {
        Method method = methods[i];
        // 获取方法名称，但是类型是一个SEL选择器类型
        SEL methodSEL = method_getName(method);
        // 需要获取C字符串
        const char *name = sel_getName(methodSEL);
        // 将方法名转换成OC字符串
        NSString *methodName = [NSString stringWithUTF8String:name];
        [methodArr addObject:methodName];
    }
    // 记得释放
    free(methods);
    return methodArr;
}

@end
