#import <Foundation/Foundation.h>

@interface NSObject (Swizzle)

#pragma mark - Swap method (Swizzling)
/**交换类的实例方法*/
+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;
/**交换类的类方法*/
+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;

+ (void)swizzleMethod:(SEL)originalSelector with:(SEL)swizzledSelector withClass:(Class)class isInstanceMethod:(BOOL)isInstanceMethod;

@end
