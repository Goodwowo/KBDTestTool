//
//  ANYMethodLog.m
//  ANYMethodLog
//
//  Created by qiuhaodong on 2017/1/14.
//  Copyright © 2017年 qiuhaodong. All rights reserved.
//
//  https://github.com/qhd/ANYMethodLog.git
//

#import "ANYMethodLog.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import "ZHRepearDictionary.h"
#import "ZHSingleMethodDic.h"
#import "ZHClassTree.h"

#pragma mark - deep

//调用层次
static int deep = -1;
static NSString *const ANYForwardInvocationSelectorName = @"any__original_forwardInvocation:";

#pragma mark - Func Define

BOOL qhd_isInBlackList(NSString *methodName);
NSDictionary *qhd_canHandleTypeDic(void);
BOOL qhd_isCanHandle(NSString *typeEncode);
SEL qhd_createNewSelector(SEL originalSelector);
BOOL qhd_isStructType(const char *argumentType);
NSString *qhd_structName(const char *argumentType);
BOOL isCGRect           (const char *type);
BOOL isCGPoint          (const char *type);
BOOL isCGSize           (const char *type);
BOOL isCGVector         (const char *type);
BOOL isUIOffset         (const char *type);
BOOL isUIEdgeInsets     (const char *type);
BOOL isCGAffineTransform(const char *type);
BOOL qhd_isCanHook(Method method, const char *returnType);
id getReturnValue(NSInvocation *invocation);
NSArray *qhd_method_arguments(NSInvocation *invocation);
void qhd_forwardInvocation(id target, SEL selector, NSInvocation *invocation);
BOOL qhd_replaceMethod(Class cls, SEL originSelector, char *returnType);
void qhd_logMethod(Class aClass, BOOL(^condition)(SEL sel));

#pragma mark - AMLBlock

@interface AMLBlock : NSObject

@property (strong, nonatomic) NSString *targetClassName;
@property (copy, nonatomic) ConditionBlock condition;
@property (copy, nonatomic) BeforeBlock before;
@property (copy, nonatomic) AfterBlock  after;

@end

@implementation AMLBlock

- (BOOL)runCondition:(SEL)sel {
    if (self.condition) {
        return self.condition(sel);
    } else {
        return YES;
    }
}

- (void)rundBefore:(id)target sel:(SEL)sel args:(NSArray *)args deep:(int) deep{
    if (self.before) {
        self.before(target, sel, args, deep);
    }
}

- (void)rundAfter:(id)target sel:(SEL)sel args:(NSArray *)args interval:(NSTimeInterval)interval deep:(int)deep retValue:(id)retValue{
    if (self.after) {
        self.after(target, sel, args, interval, deep, retValue);
    }
}

@end


#pragma mark - ANYMethodLog private interface

@interface ANYMethodLog()

@property (strong, nonatomic) NSMutableDictionary *blockCache;

+ (instancetype)sharedANYMethodLog;

- (void)setAMLBlock:(AMLBlock *)block forKey:(NSString *)aKey;

- (AMLBlock *)blockWithTarget:(id)target;

@end


#pragma mark - C function

#define SHARED_ANYMETHODLOG [ANYMethodLog sharedANYMethodLog]

//#define OPEN_TARGET_LOG

#ifdef OPEN_TARGET_LOG
#define TARGET_LOG(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define TARGET_LOG(format, ...)
#endif


#define OPEN_DEV_LOG

#ifdef OPEN_DEV_LOG
#define DEV_LOG(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define DEV_LOG(format, ...)
#endif

#define OPEN_Waring_LOG

#ifdef OPEN_Waring_LOG
#define Waring_LOG(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define Waring_LOG(format, ...)
#endif

#define OPEN_Hint_LOG

#ifdef OPEN_Hint_LOG
#define Hint_LOG(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define Hint_LOG(format, ...)
#endif

//是否在默认的黑名单中
BOOL qhd_isInBlackList(NSString *methodName) {
    static NSArray *defaultBlackList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultBlackList = @[/*UIViewController的:*/@".cxx_destruct", @"dealloc", @"_isDeallocating", @"release", @"autorelease", @"retain", @"Retain", @"_tryRetain", @"copy", /*UIView的:*/ @"nsis_descriptionOfVariable:", /*NSObject的:*/@"respondsToSelector:", @"class", @"methodSignatureForSelector:", @"allowsWeakReference", @"retainWeakReference", @"init", @"forwardInvocation:"];
    });
    return ([defaultBlackList containsObject:methodName]);
}

/*reference: https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
 经实践发现与文档有差别
 1.在64位时@encode(long)跟@encode(long long)的值一样;
 2.在64位时@encode(unsigned long)跟@encode(unsigned long long)的值一样；
 3.在32位时@encode(BOOL)跟@encode(char)一样。
 +--------------------+-----------+-----------+
 | type               |code(32bit)|code(64bit)|
 |--------------------|-----------|-----------|
 | BOOL               |     c     |    B      |
 |--------------------|-----------|-----------|
 | char               |     c     |    c      |
 |--------------------|-----------|-----------|
 | long               |     l     |    q      |
 |--------------------|-----------|-----------|
 | long long          |     q     |    q      |
 |--------------------|-----------|-----------|
 | unsigned long      |     L     |    Q      |
 |--------------------|-----------|-----------|
 | unsigned long long |     Q     |    Q      |
 +--------------------+-----------+-----------+
 */
NSDictionary *qhd_canHandleTypeDic() {
    static NSDictionary *dic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{[NSString stringWithUTF8String:@encode(char)] : @"(char)",
                [NSString stringWithUTF8String:@encode(int)] : @"(int)",
                [NSString stringWithUTF8String:@encode(short)] : @"(short)",
                [NSString stringWithUTF8String:@encode(long)] : @"(long)",
                [NSString stringWithUTF8String:@encode(long long)] : @"(long long)",
                [NSString stringWithUTF8String:@encode(unsigned char)] : @"(unsigned char))",
                [NSString stringWithUTF8String:@encode(unsigned int)] : @"(unsigned int)",
                [NSString stringWithUTF8String:@encode(unsigned short)] : @"(unsigned short)",
                [NSString stringWithUTF8String:@encode(unsigned long)] : @"(unsigned long)",
                [NSString stringWithUTF8String:@encode(unsigned long long)] : @"(unsigned long long)",
                [NSString stringWithUTF8String:@encode(float)] : @"(float)",
                [NSString stringWithUTF8String:@encode(double)] : @"(double)",
                [NSString stringWithUTF8String:@encode(BOOL)] : @"(BOOL)",
                [NSString stringWithUTF8String:@encode(void)] : @"(void)",
                [NSString stringWithUTF8String:@encode(char *)] : @"(char *)",
                [NSString stringWithUTF8String:@encode(id)] : @"(id)",
                [NSString stringWithUTF8String:@encode(Class)] : @"(Class)",
                [NSString stringWithUTF8String:@encode(SEL)] : @"(SEL)",
                [NSString stringWithUTF8String:@encode(CGRect)] : @"(CGRect)",
                [NSString stringWithUTF8String:@encode(CGPoint)] : @"(CGPoint)",
                [NSString stringWithUTF8String:@encode(CGSize)] : @"(CGSize)",
                [NSString stringWithUTF8String:@encode(CGVector)] : @"(CGVector)",
                [NSString stringWithUTF8String:@encode(CGAffineTransform)] : @"(CGAffineTransform)",
                [NSString stringWithUTF8String:@encode(UIOffset)] : @"(UIOffset)",
                [NSString stringWithUTF8String:@encode(UIEdgeInsets)] : @"(UIEdgeInsets)",
                @"@?":@"(block)" // block类型
                };//TODO:添加其他类型
    });
    return dic;
}

//根据定义的类型的判断是否能处理
BOOL qhd_isCanHandle(NSString *typeEncode) {
    return [qhd_canHandleTypeDic().allKeys containsObject:typeEncode];
}

//是否struct类型
BOOL qhd_isStructType(const char *argumentType) {
    NSString *typeString = [NSString stringWithUTF8String:argumentType];
    return ([typeString hasPrefix:@"{"] && [typeString hasSuffix:@"}"]);
}

//struct类型名
NSString *qhd_structName(const char *argumentType) {
    NSString *typeString = [NSString stringWithUTF8String:argumentType];
    NSUInteger start = [typeString rangeOfString:@"{"].location;
    NSUInteger end = [typeString rangeOfString:@"="].location;
    if (end > start) {
        return [typeString substringWithRange:NSMakeRange(start + 1, end - start - 1)];
    } else {
        return nil;
    }
}

BOOL isCGRect           (const char *type) {return [qhd_structName(type) isEqualToString:@"CGRect"];}
BOOL isCGPoint          (const char *type) {return [qhd_structName(type) isEqualToString:@"CGPoint"];}
BOOL isCGSize           (const char *type) {return [qhd_structName(type) isEqualToString:@"CGSize"];}
BOOL isCGVector         (const char *type) {return [qhd_structName(type) isEqualToString:@"CGVector"];}
BOOL isUIOffset         (const char *type) {return [qhd_structName(type) isEqualToString:@"UIOffset"];}
BOOL isUIEdgeInsets     (const char *type) {return [qhd_structName(type) isEqualToString:@"UIEdgeInsets"];}
BOOL isCGAffineTransform(const char *type) {return [qhd_structName(type) isEqualToString:@"CGAffineTransform"];}

//检查是否能处理
BOOL qhd_isCanHook(Method method, const char *returnType) {
    
    //若在黑名单中则不处理
    NSString *selectorName = NSStringFromSelector(method_getName(method));
    if (qhd_isInBlackList(selectorName)) {
        return NO;
    }
    
    if ([selectorName rangeOfString:@"qhd_"].location != NSNotFound) {
        return NO;
    }
    
    NSString *returnTypeString = [NSString stringWithUTF8String:returnType];
    
    BOOL isCanHook = YES;
    if (!qhd_isCanHandle(returnTypeString)) {
        isCanHook = NO;
    }
    for(int k = 2 ; k < method_getNumberOfArguments(method); k ++) {
        char argument[250];
        memset(argument, 0, sizeof(argument));
        method_getArgumentType(method, k, argument, sizeof(argument));
        NSString *argumentString = [NSString stringWithUTF8String:argument];
        if (!qhd_isCanHandle(argumentString)) {
            isCanHook = NO;
            break;
        }
    }
    return isCanHook;
}

//获取方法返回值
id getReturnValue(NSInvocation *invocation){
    const char *returnType = invocation.methodSignature.methodReturnType;
    if (returnType[0] == 'r') {
        returnType++;
    }
    #define WRAP_GET_VALUE(type) \
    do { \
        type val = 0; \
        [invocation getReturnValue:&val]; \
        return @(val); \
    } while (0)
    if (strcmp(returnType, @encode(id)) == 0 || strcmp(returnType, @encode(Class)) == 0 || strcmp(returnType, @encode(void (^)(void))) == 0) {
        __autoreleasing id returnObj;
        [invocation getReturnValue:&returnObj];
        return returnObj;
    } else if (strcmp(returnType, @encode(char)) == 0) {
        WRAP_GET_VALUE(char);
    } else if (strcmp(returnType, @encode(int)) == 0) {
        WRAP_GET_VALUE(int);
    } else if (strcmp(returnType, @encode(short)) == 0) {
        WRAP_GET_VALUE(short);
    } else if (strcmp(returnType, @encode(long)) == 0) {
        WRAP_GET_VALUE(long);
    } else if (strcmp(returnType, @encode(long long)) == 0) {
        WRAP_GET_VALUE(long long);
    } else if (strcmp(returnType, @encode(unsigned char)) == 0) {
        WRAP_GET_VALUE(unsigned char);
    } else if (strcmp(returnType, @encode(unsigned int)) == 0) {
        WRAP_GET_VALUE(unsigned int);
    } else if (strcmp(returnType, @encode(unsigned short)) == 0) {
        WRAP_GET_VALUE(unsigned short);
    } else if (strcmp(returnType, @encode(unsigned long)) == 0) {
        WRAP_GET_VALUE(unsigned long);
    } else if (strcmp(returnType, @encode(unsigned long long)) == 0) {
        WRAP_GET_VALUE(unsigned long long);
    } else if (strcmp(returnType, @encode(float)) == 0) {
        WRAP_GET_VALUE(float);
    } else if (strcmp(returnType, @encode(double)) == 0) {
        WRAP_GET_VALUE(double);
    } else if (strcmp(returnType, @encode(BOOL)) == 0) {
        WRAP_GET_VALUE(BOOL);
    } else if (strcmp(returnType, @encode(char *)) == 0) {
        WRAP_GET_VALUE(const char *);
    } else if (strcmp(returnType, @encode(void)) == 0) {
        return @"void";
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(returnType, &valueSize, NULL);
        unsigned char valueBytes[valueSize];
        [invocation getReturnValue:valueBytes];
        
        return [NSValue valueWithBytes:valueBytes objCType:returnType];
    }
    return nil;
}

static BOOL runOriginalSelector(NSInvocation *invocation,id objc,SEL origSel){
    if (![objc respondsToSelector:invocation.selector]) {//不存在这个方法,说明被其它切片编程干扰了
        invocation.selector = origSel;
        SEL originalForwardInvocationSEL = NSSelectorFromString(ANYForwardInvocationSelectorName);
        if ([objc respondsToSelector:originalForwardInvocationSEL]) {
            ((void( *)(id, SEL, NSInvocation *))objc_msgSend)(objc, originalForwardInvocationSEL, invocation);
        }else {
            [objc doesNotRecognizeSelector:invocation.selector];
        }
        return YES;
    }
    return NO;
}

//获取方法参数
NSArray *qhd_method_arguments(NSInvocation *invocation) {
    NSMethodSignature *methodSignature = [invocation methodSignature];
    NSMutableArray *argList = (methodSignature.numberOfArguments > 2 ? [NSMutableArray array] : nil);
    for (NSUInteger i = 2; i < methodSignature.numberOfArguments; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        id arg = nil;
        
        if (qhd_isStructType(argumentType)) {
            #define GET_STRUCT_ARGUMENT(_type)\
                if (is##_type(argumentType)) {\
                    _type arg_temp;\
                    [invocation getArgument:&arg_temp atIndex:i];\
                    arg = NSStringFrom##_type(arg_temp);\
                }
            GET_STRUCT_ARGUMENT(CGRect)
            else GET_STRUCT_ARGUMENT(CGPoint)
            else GET_STRUCT_ARGUMENT(CGSize)
            else GET_STRUCT_ARGUMENT(CGVector)
            else GET_STRUCT_ARGUMENT(UIOffset)
            else GET_STRUCT_ARGUMENT(UIEdgeInsets)
            else GET_STRUCT_ARGUMENT(CGAffineTransform)
            
            if (arg == nil) {
                arg = @"{unknown}";
            }
        }
        #define GET_ARGUMENT(_type)\
            if (0 == strcmp(argumentType, @encode(_type))) {\
                _type arg_temp;\
                [invocation getArgument:&arg_temp atIndex:i];\
                arg = @(arg_temp);\
            }
        else GET_ARGUMENT(char)
        else GET_ARGUMENT(int)
        else GET_ARGUMENT(short)
        else GET_ARGUMENT(long)
        else GET_ARGUMENT(long long)
        else GET_ARGUMENT(unsigned char)
        else GET_ARGUMENT(unsigned int)
        else GET_ARGUMENT(unsigned short)
        else GET_ARGUMENT(unsigned long)
        else GET_ARGUMENT(unsigned long long)
        else GET_ARGUMENT(float)
        else GET_ARGUMENT(double)
        else GET_ARGUMENT(BOOL)
        else if (0 == strcmp(argumentType, @encode(id))) {
            __unsafe_unretained id arg_temp;
            [invocation getArgument:&arg_temp atIndex:i];
            arg = arg_temp;
        }
        else if (0 == strcmp(argumentType, @encode(SEL))) {
            SEL arg_temp;
            [invocation getArgument:&arg_temp atIndex:i];
            arg = NSStringFromSelector(arg_temp);
        }
        else if (0 == strcmp(argumentType, @encode(char *))) {
            char *arg_temp;
            [invocation getArgument:&arg_temp atIndex:i];
            arg = [NSString stringWithUTF8String:arg_temp];
        }
        else if (0 == strcmp(argumentType, @encode(void *))) {
            void *arg_temp;
            [invocation getArgument:&arg_temp atIndex:i];
            arg = (__bridge id _Nonnull)arg_temp;
        }
        else if (0 == strcmp(argumentType, @encode(Class))) {
            Class arg_temp;
            [invocation getArgument:&arg_temp atIndex:i];
            arg = arg_temp;
        }
        
        if (!arg) {
            arg = @"unknown";
        }
        [argList addObject:arg];
    }
    return argList;
}

//forwardInvocation:方法的新IMP
void qhd_forwardInvocation(id target, SEL selector, NSInvocation *invocation) {
    NSArray *argList = qhd_method_arguments(invocation);
    SEL originSelector = invocation.selector;
    NSString *originSelectorString = NSStringFromSelector(originSelector);
    //友盟的UMAOCTools会产生问题
    if ([originSelectorString rangeOfString:@"hook_"].location != NSNotFound) {
        return;
    }
    
#pragma mark -
#pragma mark -这块是我添加的内容
    
    //找到最合适的方法名称,一旦错了,就会崩溃
    NSString *oldSelectorName = NSStringFromSelector(originSelector);
    NSString *newSelectorName=[NSString stringWithFormat:@"qhd_%@", oldSelectorName];
    NSDictionary *values=[[ZHSingleMethodDic shareInstance].methodDic getValuesForKey:newSelectorName];
//    Hint_LOG(@"%@,%@",newSelectorName,values);
    
    BOOL isFind=NO;
    for (NSString *tempSelectorName in values) {
        if ([values[tempSelectorName] isEqualToString:NSStringFromClass([target class])]) {
            newSelectorName=tempSelectorName;
            isFind=YES;
            break;
        }
    }
    if (!isFind) {
//        Hint_LOG(@"%@",@"💡说明存在2个或更多个类,子类或者中间的类没有被hook,但是他的父类被hook了,但是他却调用了super的父类方法");
        [[ZHClassTree shareInstance] addClassArrInTree:@[NSStringFromClass([target class])]];//临时将这个类加进去
        NSArray *fathers=[[ZHClassTree shareInstance] fathersForClass:NSStringFromClass([target class])];//找到他所有的父类
        for (NSString *father in [fathers reverseObjectEnumerator]) {
            NSString *sameMethod=[[ZHSingleMethodDic shareInstance] findSameMethod:newSelectorName inClass:father];
            if (sameMethod!=nil&&sameMethod.length>0) {
                newSelectorName=sameMethod;
                break;
            }
        }
    }
    
    //开始保存到栈中
    static NSMutableArray *statckMethod=nil; if (statckMethod==nil) statckMethod=[NSMutableArray array];//这个是用来存 执行对象+执行方法的栈
    static NSMutableDictionary *statckMethodDicM=nil; if (statckMethodDicM==nil) statckMethodDicM=[NSMutableDictionary dictionary];//这个是用来存某个(执行对象+执行方法的栈)的子类和父类集合的字典()说明子类父类都有这个方法
    
    NSString *didRunSelector=[NSString stringWithFormat:@"%@-%@",NSStringFromClass([target class]),newSelectorName];
    NSMutableArray *statckClass=statckMethodDicM[didRunSelector]; if (statckClass==nil)  statckClass=[NSMutableArray arrayWithCapacity:1];
    
    NSString *curClass=nil;
    if (statckClass.count>0) curClass=[statckClass lastObject];//如果超过3层super,这个就非常有作用了
    else curClass=[[ZHSingleMethodDic shareInstance].methodDic getValueForKey:newSelectorName];//找到第一个调用者
    
    if ([didRunSelector isEqualToString:[statckMethod lastObject]]||statckMethodDicM[didRunSelector]!=nil) {
        static NSMutableDictionary *isSuperOrRecursive=nil; if (isSuperOrRecursive==nil) isSuperOrRecursive=[NSMutableDictionary dictionary];
        
        //如果这个方法,父类存在,那么调用父类的方法,还需要打印出来,提醒用户,这个可能是递归算法,可能是super的方法,否则,就认为它是递归算法,不用考虑
        NSArray *fathers=[[ZHClassTree shareInstance] fathersForClass:curClass];
//        Hint_LOG(@"fathers=%@",fathers);
        for (NSString *father in [fathers reverseObjectEnumerator]) {
            NSString *sameMethod=[[ZHSingleMethodDic shareInstance] findSameMethod:newSelectorName inClass:father];
            if (sameMethod!=nil&&sameMethod.length>0) {
                newSelectorName=sameMethod;
                curClass=father;
                NSString *superOrRecursiveString = [NSString stringWithFormat:@"%@-%@",curClass,oldSelectorName];
                if (isSuperOrRecursive[superOrRecursiveString]==nil) {
                    Waring_LOG(@"%@-%@ ⚠️可能是递归函数调用,可能是super的方法调用",curClass,oldSelectorName);
                    isSuperOrRecursive[superOrRecursiveString]=@"";
                }
                didRunSelector=[NSString stringWithFormat:@"%@-%@",NSStringFromClass([target class]),newSelectorName];
                break;
            }
        }
    }
    [statckMethodDicM setValue:statckClass forKey:didRunSelector];
    [statckMethod addObject:didRunSelector];
    [statckClass addObject:curClass];
    
//    Hint_LOG(@"statckClass=%@",statckMethod);
    
//    Hint_LOG(@"%@🐦%@",[target class],newSelectorName);
//    Hint_LOG(@"入栈:%@",statckMethodDicM);
#pragma mark -
#pragma mark -这块是我添加的内容
    
    SEL newSelector = NSSelectorFromString(newSelectorName);
    
    [invocation setSelector:newSelector];
    [invocation setTarget:target];
    
    if(runOriginalSelector(invocation,target,originSelector))return;
    
    deep++;
    
    AMLBlock *block = [SHARED_ANYMETHODLOG blockWithTarget:target];
    [block rundBefore:target sel:originSelector args:argList deep:deep];

    NSDate *start = [NSDate date];
    [invocation invoke];
    
    if (statckMethod.count>0) [statckMethod removeLastObject];
    if (statckClass.count>0) [statckClass removeLastObject];
    [statckMethodDicM removeObjectForKey:didRunSelector];
//    Hint_LOG(@"出栈:%@",statckMethodDicM);
    
    NSDate *end = [NSDate date];
    NSTimeInterval interval = [end timeIntervalSinceDate:start];
    
    [block rundAfter:target sel:originSelector args:argList interval:interval deep:deep retValue:getReturnValue(invocation)];
    
    deep--;
}

//替换方法
BOOL qhd_replaceMethod(Class cls, SEL originSelector, char *returnType) {
    Method originMethod = class_getInstanceMethod(cls, originSelector);
    if (originMethod == nil) {
        return NO;
    }
    const char *originTypes = method_getTypeEncoding(originMethod);
    IMP msgForwardIMP = _objc_msgForward;
    
#if !defined(__arm64__)
    if (qhd_isStructType(returnType)) {
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:originTypes];
        if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
            msgForwardIMP = (IMP)_objc_msgForward_stret;
        }
    }
#endif
    
    IMP originIMP = method_getImplementation(originMethod);
    if (originIMP == nil || originIMP == msgForwardIMP) {
        return NO;
    }
    
    //把原方法的IMP换成_objc_msgForward，使之触发forwardInvocation方法
    class_replaceMethod(cls, originSelector, msgForwardIMP, originTypes);
    
    //把方法forwardInvocation的IMP换成qhd_forwardInvocation
    IMP originalImplementation = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)qhd_forwardInvocation, "v@:@");
    if (originalImplementation) {
        class_addMethod(cls, NSSelectorFromString(ANYForwardInvocationSelectorName), originalImplementation, "v@:@");
    }
#pragma mark -
#pragma mark -这块是我添加的内容
    
    NSString *oldSelectorName = NSStringFromSelector(originSelector);
    NSString *clsName=NSStringFromClass(cls);
    NSMutableDictionary *methods=[ZHSingleMethodDic shareInstance].classDic[clsName];
    if (!methods) {
        methods=[NSMutableDictionary dictionaryWithCapacity:1];
        [[ZHSingleMethodDic shareInstance].classDic setValue:methods forKey:clsName];
    }
    
    //这里有个坑,如果又是类方法 +(void)fun; 又是实例方法 -(void)fun;注意不要会同时建立两个,否则会崩溃,我也不知道为什么
    NSString *newSelectorName=nil;
    NSString *originalSelectorName=[NSString stringWithFormat:@"qhd_%@", oldSelectorName];
    if (!methods[originalSelectorName]) {
        newSelectorName=[[ZHSingleMethodDic shareInstance].methodDic setValue:NSStringFromClass(cls) forKey:originalSelectorName];
        if (newSelectorName.length>originalSelectorName.length) {
            [methods setValue:[newSelectorName substringFromIndex:originalSelectorName.length] forKey:originalSelectorName];
        }else{
            [methods setValue:@"" forKey:originalSelectorName];
        }
    }else{
        newSelectorName=originalSelectorName;
    }

//    NSLog(@"创建🔥%@--%@",newSelectorName,NSStringFromClass(cls));
#pragma mark -
#pragma mark -这块是我添加的内容
    
    
    
    
    
    
    
    
    
    //创建一个新方法，IMP就是原方法的原来的IMP，那么只要在qhd_forwardInvocation调用新方法即可
    SEL newSelecotr = NSSelectorFromString(newSelectorName);
    BOOL isAdd = class_addMethod(cls, newSelecotr, originIMP, originTypes);
    if (!isAdd) {
        DEV_LOG(@"class_addMethod fail");
    }
    return YES;
}

void qhd_logMethod(Class aClass, BOOL(^condition)(SEL sel)) {
    unsigned int outCount;
    Method *methods = class_copyMethodList(aClass,&outCount);
    
    for (int i = 0; i < outCount; i ++) {
        Method tempMethod = *(methods + i);
        SEL selector = method_getName(tempMethod);
        char *returnType = method_copyReturnType(tempMethod);
        
        BOOL isCan = qhd_isCanHook(tempMethod, returnType);
        if (isCan && condition) {
            isCan = condition(selector);
        }
        
        if (isCan) {
//            DEV_LOG(@"%@ success hook method:%@ types:%s",NSStringFromClass(aClass), NSStringFromSelector(selector), method_getDescription(tempMethod)->types);
            
            if (qhd_replaceMethod(aClass, selector, returnType)) {
//                DEV_LOG(@"%@ success hook method:%@ types:%s",NSStringFromClass(aClass), NSStringFromSelector(selector), method_getDescription(tempMethod)->types);
            } else {
//                DEV_LOG(@"%@ fail method:%@ types:%s",NSStringFromClass(aClass), NSStringFromSelector(selector), method_getDescription(tempMethod)->types);
            }
        } else {
//            DEV_LOG(@"can not hook method:%@ types:%s", NSStringFromSelector(selector), method_getDescription(tempMethod)->types);
        }
        free(returnType);
    }
    free(methods);
}


#pragma mark - ANYMethodLog implementation

@implementation ANYMethodLog

+ (void)logMethodWithClass:(Class)aClass
                 condition:(ConditionBlock) condition
                    before:(BeforeBlock) before
                     after:(AfterBlock) after {
    #ifndef DEBUG
        return;
    #endif
    
    if (aClass) {
        AMLBlock *block = [[AMLBlock alloc] init];
        block.targetClassName = NSStringFromClass(aClass);
        block.condition = condition;
        block.before = before;
        block.after = after;
        [SHARED_ANYMETHODLOG setAMLBlock:block forKey:block.targetClassName];
    }
    
    qhd_logMethod(aClass, condition);
    
    //获取元类，处理类方法。（注意获取元类是用object_getClass，而不是class_getSuperclass）
    Class metaClass = object_getClass(aClass);
    qhd_logMethod(metaClass, condition);
}

+ (instancetype)sharedANYMethodLog {
    static ANYMethodLog *_sharedANYMethodLog = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedANYMethodLog = [[self alloc] init];
        _sharedANYMethodLog.blockCache = [NSMutableDictionary dictionary];
    });
    return _sharedANYMethodLog;
}

- (void)setAMLBlock:(AMLBlock *)block forKey:(NSString *)aKey {
    @synchronized (self) {
        [self.blockCache setObject:block forKey:aKey];
    }
}

- (AMLBlock *)blockWithTarget:(id)target {
    Class class = [target class];
    AMLBlock *block = [self.blockCache objectForKey:NSStringFromClass(class)];
    while (block == nil) {
        class = [class superclass];
        if (class == nil) {
            break;
        }
        block = [self.blockCache objectForKey:NSStringFromClass(class)];
    }
    return block;
}

@end
