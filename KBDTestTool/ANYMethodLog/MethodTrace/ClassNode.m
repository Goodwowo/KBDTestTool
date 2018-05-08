//
//  ClassNode.m
//  ANYMethodLogDemo
//
//  Created by mac on 2017/11/8.
//  Copyright © 2017年 qiuhaodong. All rights reserved.
//

#import "ClassNode.h"

@implementation ClassNode

- (NSMutableDictionary *)methods{
    if (!_methods) {
        _methods=[NSMutableDictionary dictionary];
    }
    return _methods;
}

- (NSMutableArray *)methodOrder{
    if (!_methodOrder) {
        _methodOrder=[NSMutableArray array];
    }
    return _methodOrder;
}

- (void)recordTrace:(NSString *)objRun method:(NSString *)method classString:(NSString *)cls isBegin:(BOOL)begin{
    
    if ([objRun isEqualToString:self.runObj]) {
        if (self.methods[method]==nil) {
            [self.methods setValue:[NSMutableArray array] forKey:method];
        }
    }
    
    if (begin) {
        if ([cls isEqualToString:objRun]) {
            [self.methodOrder addObject:@{method:@"self"}];
        }else{
            [self.methodOrder addObject:@{method:cls}];
        }
        [self recordMethods];
    }else{
        if (self.methodOrder.count>0) {
            [self.methodOrder removeLastObject];
        }
    }
}

- (void)recordMethods{
    if (self.methodOrder.count>1) {
        for (NSInteger i=0,count=self.methodOrder.count; i<count; i++) {
            NSDictionary *tempDic=self.methodOrder[i];
            NSString *method=[tempDic allKeys][0];
            NSMutableArray *methodOrders=self.methods[method];
            for (NSInteger j=i+1; j<count; j++) {
                NSDictionary *tempMethod=self.methodOrder[j];
                NSString *subMethod=[tempMethod allKeys][0];
                NSString *cls=[tempMethod allValues][0];
                NSString *targetStr=[NSString stringWithFormat:@"[%@ %@]",cls,subMethod];
                if (![methodOrders containsObject:targetStr]) {
                    [methodOrders addObject:targetStr];
                }
            }
        }
    }
}

//- (void)recordTrace:(NSString *)classString method:(NSString *)method isBegin:(BOOL)begin{
//
//    if (begin) {
//        if (self.curMethodNode==nil) {
//            self.curMethodNode=[MethodNode new];
//            self.curMethodNode.methodName=method;
//            self.curMethodNode.prior=nil;
//            self.curMethodNode.next=nil;
//            self.headMethodNode=self.curMethodNode;
//        }else{
//            MethodNode *newMethodNode=[MethodNode new];
//            newMethodNode.methodName=method;
//            newMethodNode.prior=nil;
//            newMethodNode.next=nil;
//
//            self.curMethodNode.next=newMethodNode;
//            newMethodNode.prior=self.curMethodNode;
//            self.curMethodNode=newMethodNode;
//        }
//    }else{
//        MethodNode *priorNode=self.curMethodNode.prior;
//        self.curMethodNode.prior=nil;
//        self.curMethodNode=priorNode;
//        self.curMethodNode.next=nil;
//    }
//
//    if ([classString isEqualToString:self.classString]) {
//        if (self.methods[method]==nil) {
//            [self.methods setValue:[NSMutableArray array] forKey:method];
//        }
//    }
//
//    [self recordMethods];
//}
//
//- (BOOL)needRecordMethodNodes{
//    NSInteger count=0;
//    MethodNode *curNode=self.headMethodNode;
//    while (curNode) {
//        count++;
//        if (count>1) return YES;
//        curNode=curNode.next;
//    }
//    return count>1;
//}
//
//- (void)recordMethods{
//    if ([self needRecordMethodNodes]) {
//        MethodNode *curNode=self.headMethodNode;
//        while (curNode) {
//            curNode=curNode.next;
//        }
//    }
//}

@end
