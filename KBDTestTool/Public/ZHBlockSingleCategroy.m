#import "ZHBlockSingleCategroy.h"

static NSMutableDictionary *ZHBlocks;

@implementation ZHBlockSingleCategroy
+ (NSMutableDictionary *)defaultMyblock{
    //添加线程锁
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(ZHBlocks==nil){
            ZHBlocks=[NSMutableDictionary dictionary];
        }
    });
    return ZHBlocks;
}

+ (BOOL)exsitBlockWithIdentity:(NSString *)Identity{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]==nil)
        return NO;
    else
        return YES;
}

+ (void)addBlock:(id)block withIdentity:(NSString *)identity{
    [self removeBlockWithIdentity:identity];
    [[ZHBlockSingleCategroy defaultMyblock] setValue:block forKey:identity];
}

//空(NULL)
+ (void)addBlockWithNULL:(MyblockWithNULL)block WithIdentity:(NSString *)Identity{
    [self addBlock:block withIdentity:Identity];
}

//添加block 字符串(NSString)
+ (void)addBlockWithNSString:(MyblockWithNSString)block WithIdentity:(NSString *)Identity{
     [self addBlock:block withIdentity:Identity];
}
+ (void)addBlockWithTwoNSString:(MyblockWithTwoNSString)block WithIdentity:(NSString *)Identity{
     [self addBlock:block withIdentity:Identity];
}
+ (void)addBlockWithThreeNSString:(MyblockWithThreeNSString)block WithIdentity:(NSString *)Identity{
     [self addBlock:block withIdentity:Identity];
}

//添加block NSInteger
+ (void)addBlockWithNSInteger:(MyblockWithNSInteger)block WithIdentity:(NSString *)Identity{
     [self addBlock:block withIdentity:Identity];
}
+ (void)addBlockWithTwoNSInteger:(MyblockWithTwoNSInteger)block WithIdentity:(NSString *)Identity{
     [self addBlock:block withIdentity:Identity];
}
+ (void)addBlockWithThreeNSInteger:(MyblockWithThreeNSInteger)block WithIdentity:(NSString *)Identity{
    [self addBlock:block withIdentity:Identity];
}

//添加block CGFloat
+ (void)addBlockWithCGFloat:(MyblockWithCGFloat)block WithIdentity:(NSString *)Identity{
     [self addBlock:block withIdentity:Identity];
}
+ (void)addBlockWithTwoCGFloat:(MyblockWithTwoCGFloat)block WithIdentity:(NSString *)Identity{
     [self addBlock:block withIdentity:Identity];
}
+(void)addBlockWithThreeCGFloat:(MyblockWithThreeCGFloat)block WithIdentity:(NSString *)Identity{
    [self addBlock:block withIdentity:Identity];
}

//添加block NSArray
+ (void)addBlockWithNSArray:(MyblockWithNSArray)block WithIdentity:(NSString *)Identity{
     [self addBlock:block withIdentity:Identity];
}
+ (void)addBlockWithTwoNSArray:(MyblockWithTwoNSArray)block WithIdentity:(NSString *)Identity{
     [self addBlock:block withIdentity:Identity];
}
+ (void)addBlockWithThreeNSArray:(MyblockWithThreeNSArray)block WithIdentity:(NSString *)Identity{
    [self addBlock:block withIdentity:Identity];
}

//添加block NSDictionary
+ (void)addBlockWithNSDictionary:(MyblockWithNSDictionary)block WithIdentity:(NSString *)Identity{
     [self addBlock:block withIdentity:Identity];
}
+ (void)addBlockWithTwoNSDictionary:(MyblockWithTwoNSDictionary)block WithIdentity:(NSString *)Identity{
     [self addBlock:block withIdentity:Identity];
}
+(void)addBlockWithThreeNSDictionary:(MyblockWithThreeNSDictionary)block WithIdentity:(NSString *)Identity{
    [self addBlock:block withIdentity:Identity];
}

//执行block 空(NULL)
+ (void)runBlockNULLIdentity:(NSString *)Identity{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithNULL block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block();
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}

//执行block 字符串(NSString)
+ (void)runBlockNSStringIdentity:(NSString *)Identity Str1:(NSString *)str1{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithNSString block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(str1);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}
+ (void)runBlockTwoNSStringIdentity:(NSString *)Identity Str1:(NSString *)str1 Str2:(NSString *)str2{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithTwoNSString block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(str1,str2);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}
+ (void)runBlockThreeNSStringIdentity:(NSString *)Identity Str1:(NSString *)str1 Str2:(NSString *)str2 Str3:(NSString *)str3{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithThreeNSString block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(str1,str2,str3);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}

//执行block NSInteger
+ (void)runBlockNSIntegerIdentity:(NSString *)Identity Intege1:(NSInteger)Intege1{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithNSInteger block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(Intege1);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}
+ (void)runBlockTwoNSIntegerIdentity:(NSString *)Identity  Intege1:(NSInteger)Intege1 Intege2:(NSInteger)Intege2{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithTwoNSInteger block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(Intege1,Intege2);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}
+ (void)runBlockThreeNSIntegerIdentity:(NSString *)Identity  Intege1:(NSInteger)Intege1 Intege2:(NSInteger)Intege2  Intege3:(NSInteger)Intege3{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithThreeNSInteger block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(Intege1,Intege2,Intege3);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}

//执行block CGFloat
+ (void)runBlockCGFloatIdentity:(NSString *)Identity Float1:(CGFloat)Float1{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithCGFloat block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(Float1);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}
+ (void)runBlockTwoCGFloatIdentity:(NSString *)Identity Float1:(CGFloat)Float1 Float2:(CGFloat)Float2{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithTwoCGFloat block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(Float1,Float2);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}
+ (void)runBlockThreeCGFloatIdentity:(NSString *)Identity Float1:(CGFloat)Float1 Float2:(CGFloat)Float2  Float3:(CGFloat)Float3{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithThreeCGFloat block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(Float1,Float2,Float3);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}

//执行block NSArray
+ (void)runBlockNSArrayIdentity:(NSString *)Identity Array1:(NSArray *)Array1{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithNSArray block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(Array1);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}
+ (void)runBlockTwoNSArrayIdentity:(NSString *)Identity Array1:(NSArray *)Array1 Array2:(NSArray *)Array2{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithTwoNSArray block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(Array1,Array2);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}
+ (void)runBlockThreeNSArrayIdentity:(NSString *)Identity Array1:(NSArray *)Array1  Array2:(NSArray *)Array2 Array3:(NSArray *)Array3{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithThreeNSArray block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(Array1,Array2,Array3);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}

//NSDictionary
+ (void)runBlockNSDictionaryIdentity:(NSString *)Identity Dictionary1:(NSDictionary *)Dictionary1{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithNSDictionary block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(Dictionary1);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}
+ (void)runBlockTwoNSDictionaryIdentity:(NSString *)Identity Dictionary1:(NSDictionary *)Dictionary1 Dictionary2:(NSDictionary *)Dictionary2{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithTwoNSDictionary block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(Dictionary1,Dictionary2);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}
+ (void)runBlockThreeNSDictionaryIdentity:(NSString *)Identity  Dictionary1:(NSDictionary *)Dictionary1 Dictionary2:(NSDictionary *)Dictionary2 Dictionary3:(NSDictionary *)Dictionary3{
    if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){
        MyblockWithThreeNSDictionary block=[ZHBlockSingleCategroy defaultMyblock][Identity];
        block(Dictionary1,Dictionary2,Dictionary3);
    }else{
        [self AlertMessageWithIdentity:Identity];
    }
}


+ (void)removeBlockWithIdentity:(NSString *)Identity{
    [[ZHBlockSingleCategroy defaultMyblock] removeObjectForKey:Identity];
}
+ (void)AlertMessageWithIdentity:(NSString *)Identity{
//    NSLog(@"%@",[Identity stringByAppendingString:@" 的block已经移除或者还未创建!"]);
}

@end
