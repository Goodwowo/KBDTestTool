#import <UIKit/UIKit.h>

//空(NULL)
typedef void (^MyblockWithNULL)(void);

//字符串(NSString)
typedef void (^MyblockWithNSString)(NSString *str1);

typedef void (^MyblockWithTwoNSString)(NSString *str1,NSString *str2);

typedef void (^MyblockWithThreeNSString)(NSString *str1,NSString *str2,NSString *str3);

//NSInteger
typedef void (^MyblockWithNSInteger)(NSInteger Integer);

typedef void (^MyblockWithTwoNSInteger)(NSInteger Integer1,NSInteger Integer2);

typedef void (^MyblockWithThreeNSInteger)(NSInteger Integer1,NSInteger Integer2,NSInteger Integer3);

//CGFloat
typedef void (^MyblockWithCGFloat)(CGFloat Float);

typedef void (^MyblockWithTwoCGFloat)(CGFloat Float1,CGFloat Float2);

typedef void (^MyblockWithThreeCGFloat)(CGFloat Float1,CGFloat Float2,CGFloat Float3);

//NSArray
typedef void (^MyblockWithNSArray)(NSArray *Array);

typedef void (^MyblockWithTwoNSArray)(NSArray *Array1,NSArray *Array2);

typedef void (^MyblockWithThreeNSArray)(NSArray *Array1,NSArray *Array2,NSArray *Array3);

//NSDictionary
typedef void (^MyblockWithNSDictionary)(NSDictionary *Dictionary);

typedef void (^MyblockWithTwoNSDictionary)(NSDictionary *Dictionary1,NSDictionary *Dictionary2);

typedef void (^MyblockWithThreeNSDictionary)(NSDictionary *Dictionary1,NSDictionary *Dictionary2,NSDictionary *Dictionary3);

@interface ZHBlockSingleCategroy : NSObject

+ (NSMutableDictionary *)defaultMyblock;

/**判断是否存在某个Block*/
+ (BOOL)exsitBlockWithIdentity:(NSString *)Identity;

//空(NULL)
+ (void)addBlockWithNULL:(MyblockWithNULL)block WithIdentity:(NSString *)Identity;

//字符串(NSString)
+ (void)addBlockWithNSString:(MyblockWithNSString)block WithIdentity:(NSString *)Identity;

+ (void)addBlockWithTwoNSString:(MyblockWithTwoNSString)block WithIdentity:(NSString *)Identity;

+ (void)addBlockWithThreeNSString:(MyblockWithThreeNSString)block WithIdentity:(NSString *)Identity;

//NSInteger
+ (void)addBlockWithNSInteger:(MyblockWithNSInteger)block WithIdentity:(NSString *)Identity;

+ (void)addBlockWithTwoNSInteger:(MyblockWithTwoNSInteger)block WithIdentity:(NSString *)Identity;

+ (void)addBlockWithThreeNSInteger:(MyblockWithThreeNSInteger)block WithIdentity:(NSString *)Identity;

//CGFloat
+ (void)addBlockWithCGFloat:(MyblockWithCGFloat)block WithIdentity:(NSString *)Identity;

+ (void)addBlockWithTwoCGFloat:(MyblockWithTwoCGFloat)block WithIdentity:(NSString *)Identity;

+ (void)addBlockWithThreeCGFloat:(MyblockWithThreeCGFloat)block WithIdentity:(NSString *)Identity;

//NSArray
+ (void)addBlockWithNSArray:(MyblockWithNSArray)block WithIdentity:(NSString *)Identity;

+ (void)addBlockWithTwoNSArray:(MyblockWithTwoNSArray)block WithIdentity:(NSString *)Identity;

+ (void)addBlockWithThreeNSArray:(MyblockWithThreeNSArray)block WithIdentity:(NSString *)Identity;

//NSDictionary
+ (void)addBlockWithNSDictionary:(MyblockWithNSDictionary)block WithIdentity:(NSString *)Identity;

+ (void)addBlockWithTwoNSDictionary:(MyblockWithTwoNSDictionary)block WithIdentity:(NSString *)Identity;

+ (void)addBlockWithThreeNSDictionary:(MyblockWithThreeNSDictionary)block WithIdentity:(NSString *)Identity;

//执行block 空(NULL)
+ (void)runBlockNULLIdentity:(NSString *)Identity;

//执行block 字符串(NSString)
+ (void)runBlockNSStringIdentity:(NSString *)Identity Str1:(NSString *)str1;

+ (void)runBlockTwoNSStringIdentity:(NSString *)Identity Str1:(NSString *)str1 Str2:(NSString *)str2;

+ (void)runBlockThreeNSStringIdentity:(NSString *)Identity Str1:(NSString *)str1 Str2:(NSString *)str2 Str3:(NSString *)str3;

//执行block NSInteger
+ (void)runBlockNSIntegerIdentity:(NSString *)Identity Intege1:(NSInteger)Intege1;

+ (void)runBlockTwoNSIntegerIdentity:(NSString *)Identity  Intege1:(NSInteger)Intege1 Intege2:(NSInteger)Intege2;

+ (void)runBlockThreeNSIntegerIdentity:(NSString *)Identity  Intege1:(NSInteger)Intege1 Intege2:(NSInteger)Intege2  Intege3:(NSInteger)Intege3;

//执行block CGFloat
+ (void)runBlockCGFloatIdentity:(NSString *)Identity Float1:(CGFloat)Float1;

+ (void)runBlockTwoCGFloatIdentity:(NSString *)Identity Float1:(CGFloat)Float1 Float2:(CGFloat)Float2;

+ (void)runBlockThreeCGFloatIdentity:(NSString *)Identity Float1:(CGFloat)Float1 Float2:(CGFloat)Float2  Float3:(CGFloat)Float3;

//执行block NSArray
+ (void)runBlockNSArrayIdentity:(NSString *)Identity Array1:(NSArray *)Array1;

+ (void)runBlockTwoNSArrayIdentity:(NSString *)Identity Array1:(NSArray *)Array1 Array2:(NSArray *)Array2;

+ (void)runBlockThreeNSArrayIdentity:(NSString *)Identity Array1:(NSArray *)Array1  Array2:(NSArray *)Array2 Array3:(NSArray *)Array3;

//NSDictionary
+ (void)runBlockNSDictionaryIdentity:(NSString *)Identity Dictionary1:(NSDictionary *)Dictionary1;

+ (void)runBlockTwoNSDictionaryIdentity:(NSString *)Identity Dictionary1:(NSDictionary *)Dictionary1 Dictionary2:(NSDictionary *)Dictionary2;

+ (void)runBlockThreeNSDictionaryIdentity:(NSString *)Identity  Dictionary1:(NSDictionary *)Dictionary1 Dictionary2:(NSDictionary *)Dictionary2 Dictionary3:(NSDictionary *)Dictionary3;

+ (void)removeBlockWithIdentity:(NSString *)Identity;

@end
