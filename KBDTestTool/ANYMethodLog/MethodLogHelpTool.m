//
//  MethodLogHelpTool.m
//  ANYMethodLogDemo
//
//  Created by mac on 2017/11/8.
//  Copyright © 2017年 qiuhaodong. All rights reserved.
//

#import "MethodLogHelpTool.h"
#import "ANYMethodLog.h"
#import "TreeModel.h"
#import "ZHClassTree.h"
#import <objc/runtime.h>
#import "ZHSingleMethodDic.h"
#import "NSArray+ZH.h"
#import "NSDictionary+ZH.h"
#import "RTSystemClass.h"

@implementation MethodLogHelpTool

+ (void)logMethodTrace{
    NSMutableArray *noSystemClass=[[RTSystemClass shareInstance] getNoSystemClass].mutableCopy;
    [noSystemClass removeObject:@"ANYMethodLog"];
    [noSystemClass removeObject:@"AMLBlock"];
    [noSystemClass removeObject:@"ZHSingleMethodDic"];
    [noSystemClass removeObject:@"ZHRepearDictionary"];
    
    [[ZHClassTree shareInstance] addClassArrInTree:noSystemClass];
    
    for (NSString *className in noSystemClass) {
        [self logMethodTraceWithClass:className];
    }
}

+ (void)logAllMethod{
    NSMutableArray *noSystemClass=[[RTSystemClass shareInstance] getNoSystemClass].mutableCopy;
    [noSystemClass removeObject:@"ANYMethodLog"];
    [noSystemClass removeObject:@"AMLBlock"];
    [noSystemClass removeObject:@"ZHSingleMethodDic"];
    
    for (NSString *className in noSystemClass) {
        [ANYMethodLog logMethodWithClass:NSClassFromString(className) condition:^BOOL(SEL sel) {
            
            Method instanceMethod=class_getInstanceMethod(NSClassFromString(className),sel);
            IMP instanceMethodIMP=method_getImplementation(instanceMethod);
            Method classMethod=class_getClassMethod(NSClassFromString(className),sel);
            IMP classMethodIMP=method_getImplementation(classMethod);
            
            BOOL isInstance=NO;
            BOOL isClass=NO;
            if (instanceMethodIMP) isInstance=YES;
            if (classMethodIMP) isClass=YES;
            NSString *typeMethod=isInstance?@"实例方法":@"类方法";
            typeMethod=(isInstance&&isClass)?@"既是实例方法也是类方法":typeMethod;
            printf("类:%s 方法:%s 类型:%s\n",[className UTF8String], [NSStringFromSelector(sel) UTF8String],[typeMethod UTF8String]);
            return NO;
        } before:nil after:nil];
    }
}

+ (void)logMethodTraceWithClassArr:(NSArray *)arr{
    NSMutableArray *noSystemClass=[NSMutableArray arrayWithArray:arr];
    [noSystemClass removeObject:@"ANYMethodLog"];
    [noSystemClass removeObject:@"AMLBlock"];
    
//    [noSystemClass addObject:@"UILabel"];
//    [noSystemClass addObject:@"UIButton"];
//    [noSystemClass addObject:@"UIImageView"];
    
    [[ZHClassTree shareInstance] addClassArrInTree:noSystemClass];
//    [[ZHClassTree shareInstance] printTree];
//    NSLog(@"count=%zd",noSystemClass.count);
    for (NSString *className in noSystemClass) {
//        NSLog(@"%@",className);
        [self logMethodTraceWithClass:className];
    }
    
//    [[[ZHSingleMethodDic shareInstance].methodDic.dicM jsonPrettyStringEncoded] writeToFile:@"/Users/mac/Desktop/code1.m" atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    [[[ZHSingleMethodDic shareInstance].classDic jsonPrettyStringEncoded] writeToFile:@"/Users/mac/Desktop/code2.m" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

+ (void)logAllMethodWithClassArr:(NSArray *)arr{
    NSMutableArray *noSystemClass=[NSMutableArray arrayWithArray:arr];
    [noSystemClass removeObject:@"ANYMethodLog"];
    [noSystemClass removeObject:@"AMLBlock"];
    
    for (NSString *className in noSystemClass) {
        [ANYMethodLog logMethodWithClass:NSClassFromString(className) condition:^BOOL(SEL sel) {
            
            Method instanceMethod=class_getInstanceMethod(NSClassFromString(className),sel);
            IMP instanceMethodIMP=method_getImplementation(instanceMethod);
            Method classMethod=class_getClassMethod(NSClassFromString(className),sel);
            IMP classMethodIMP=method_getImplementation(classMethod);
            
            BOOL isInstance=NO;
            BOOL isClass=NO;
            if (instanceMethodIMP) isInstance=YES;
            if (classMethodIMP) isClass=YES;
            NSString *typeMethod=isInstance?@"实例方法":@"类方法";
            typeMethod=(isInstance&&isClass)?@"既是实例方法也是类方法":typeMethod;
            printf("类:%s 方法:%s 类型:%s\n",[className UTF8String], [NSStringFromSelector(sel) UTF8String],[typeMethod UTF8String]);
            return NO;
        } before:nil after:nil];
    }
}

+ (void)logAllPropertyWithClassArr:(NSArray *)arr{
    NSMutableArray *noSystemClass=[NSMutableArray arrayWithArray:arr];
    [noSystemClass removeObject:@"ANYMethodLog"];
    [noSystemClass removeObject:@"AMLBlock"];
    for (NSString *className in noSystemClass) {
        NSArray *propertys=[NSArray allPropertiesFromClass:NSClassFromString(className)];
        for (NSString *property in propertys) {
            NSLog(@"%@->%@",className,property);
        }
    }
}

//+ (void)logMethodTraceWithClass:(NSString *)clsString{
//    Class cls=NSClassFromString(clsString);
//    if (cls!=NULL) {
//        
//        [ANYMethodLog logMethodWithClass:cls condition:^BOOL(SEL sel) {
//            return YES;
//        } before:^(id target, SEL sel, NSArray *args, int deep ,NSString *cls) {
//
////            if (args) {
////                printf("(begin)类:%s 方法:%s 参数:%s\n",[NSStringFromClass([target class]) UTF8String], [NSStringFromSelector(sel) UTF8String],[[NSString stringWithFormat:@"%@",args] UTF8String]);
////            }else{
//                printf("(begin)类:%s 方法:%s\n",[NSStringFromClass([target class]) UTF8String], [NSStringFromSelector(sel) UTF8String]);
////            }
//            
//            [[TreeModel sharedObj] addTrace:NSStringFromClass([target class]) method:NSStringFromSelector(sel) classString:cls isBegin:YES];
//        } after:^(id target, SEL sel, NSArray *args, NSTimeInterval interval, int deep, id retValue ,NSString *cls){
//
////                printf("(end  )类:%s 方法:%s\n",[NSStringFromClass([target class]) UTF8String], [NSStringFromSelector(sel) UTF8String]);
////            [[TreeModel sharedObj] addTrace:NSStringFromClass([target class]) method:NSStringFromSelector(sel) classString:cls isBegin:NO];
//
//        }];
//    }
//}

+ (void)logMethodTraceWithClass:(NSString *)clsString{
    Class cls=NSClassFromString(clsString);
    if (cls!=NULL) {
        [ANYMethodLog logMethodWithClass:cls condition:^BOOL(SEL sel) {
            return YES;
        } before:^(id target, SEL sel, NSArray *args, int deep) {
            //            printf("(begin)类:%s 方法:%s\n",[cls UTF8String], [NSStringFromSelector(sel) UTF8String]);
        } after:^(id target, SEL sel, NSArray *args, NSTimeInterval interval, int deep, id retValue){
            if (interval>0.01) {
                printf("⚠️类:%s 方法:%s 耗时%f \n",[NSStringFromClass(cls) UTF8String], [NSStringFromSelector(sel) UTF8String],interval);
            }
        }];
    }
}

@end
