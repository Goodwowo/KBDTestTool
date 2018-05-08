//
//  ZHClassTree.m
//  ANYMethodLogDemo
//
//  Created by mac on 2017/11/13.
//  Copyright © 2017年 qiuhaodong. All rights reserved.
//

#import "NSArray+ZH.h"
#import "NSDictionary+ZH.h"
#import "ZHClassTree.h"
#import <objc/runtime.h>

@interface ZHClassTree ()
@property (nonatomic, strong) NSMutableDictionary* classTree;
@end

@implementation ZHClassTree

//判断某类（cls）是否为指定类（acls）的子类
- (BOOL)isSubOfClass:(Class)cls1 otherClass:(Class)cls2{

    Class scls = class_getSuperclass(cls1);
    if (scls == cls2) {
        return YES;
    } else if (scls == nil) {
        return NO;
    }
    return [self isSubOfClass:scls otherClass:cls2];
}

- (void)addClassArrInTree:(NSArray*)classNames{
    for (NSString* className in classNames) {
        [self addClassInTree:className forDicM:self.classTree];
    }
}

- (BOOL)addClassInTree:(NSString*)className forDicM:(NSMutableDictionary*)dicTree{

    if (dicTree.count == 1) {
        NSString* nodeClassName = [dicTree allKeys][0];
        if ([className isEqualToString:nodeClassName])
            return YES;
        if ([nodeClassName isEqualToString:@"ZHClassTree_RootNode"] || [self isSubOfClass:NSClassFromString(className) otherClass:NSClassFromString(nodeClassName)]) {
            NSMutableArray* subClass = dicTree[nodeClassName];
            for (NSMutableDictionary* dicTreeSub in subClass) {
                if ([self addClassInTree:className forDicM:dicTreeSub]) { //找到了
                    return YES;
                }
            }

            NSMutableArray* curSubClassNamesNode = [NSMutableArray arrayWithCapacity:1];
            [subClass addObject:[NSMutableDictionary dictionaryWithObject:curSubClassNamesNode forKey:className]];

            //可能这个className是当前Tree根节点下子节点的父类
            for (NSMutableDictionary* dicTreeSub in subClass) {
                NSString* nodeClassName = [dicTreeSub allKeys][0];
                if ([self isSubOfClass:NSClassFromString(nodeClassName) otherClass:NSClassFromString(className)]) {
                    [curSubClassNamesNode addObject:dicTreeSub];
                }
            }

            for (NSMutableDictionary* itemNode in curSubClassNamesNode) {
                [subClass removeObject:itemNode];
            }

            return YES;
        }
    }

    return NO;
}

- (NSArray*)fathersForClass:(NSString*)className{
    NSMutableArray* fathers = [NSMutableArray arrayWithCapacity:1];
    [self fathersForClass:className forDicM:self.classTree intoArr:fathers];
    [fathers removeObject:@"ZHClassTree_RootNode"];
    [fathers removeObject:className];
    return fathers;
}

- (BOOL)fathersForClass:(NSString*)className forDicM:(NSMutableDictionary*)dicTree intoArr:(NSMutableArray*)fathers{
    if (dicTree.count == 1) {
        NSString* nodeClassName = [dicTree allKeys][0];
        [fathers addObject:nodeClassName];
        if ([nodeClassName isEqualToString:className]) {
            return YES;
        }

        NSMutableArray* subClass = dicTree[nodeClassName];
        for (NSMutableDictionary* dicTreeSub in subClass) {
            if ([self fathersForClass:className forDicM:dicTreeSub intoArr:fathers]) {
                return YES;
            }
        }

        [fathers removeObject:nodeClassName];
    }
    return NO;
}

- (void)printTree{
    NSLog(@"%@", [self.classTree jsonPrettyStringEncoded]);
}

+ (ZHClassTree*)shareInstance{
    static dispatch_once_t pred = 0;
    static ZHClassTree* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[ZHClassTree alloc] init];
        _sharedObject.classTree = [NSMutableDictionary dictionaryWithCapacity:1];
        [_sharedObject.classTree setValue:[NSMutableArray arrayWithCapacity:1] forKey:@"ZHClassTree_RootNode"];
    });

    return _sharedObject;
}

@end


