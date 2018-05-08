//
//  TreeModel.m
//  ANYMethodLogDemo
//
//  Created by mac on 2017/11/8.
//  Copyright © 2017年 qiuhaodong. All rights reserved.
//

#import "TreeModel.h"
#import "ClassNode.h"
#import "NSDictionary+ZH.h"

@implementation TreeModel

+ (TreeModel *)sharedObj {
    static dispatch_once_t pred = 0;
    __strong static TreeModel *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[TreeModel alloc] init];
        _sharedObject.tree=[NSMutableDictionary dictionary];
    });
    
    return _sharedObject;
}


- (void)addTrace:(NSString *)objRun method:(NSString *)method classString:(NSString *)cls isBegin:(BOOL)begin{
    
    ClassNode *clsNode=self.tree[objRun];
    if (clsNode==nil) {
        clsNode=[ClassNode new];
        clsNode.runObj=objRun;
        [self.tree setObject:clsNode forKey:objRun];
    }
    
    [clsNode recordTrace:objRun method:method classString:cls isBegin:begin];
}

- (NSString *)printTree{
    NSMutableDictionary *logTree=[NSMutableDictionary dictionary];
    for (NSString *classString in self.tree) {
        ClassNode *clsNode=self.tree[classString];
        [logTree setValue:clsNode.methods forKey:classString];
    }
    NSString *text=[logTree jsonPrettyStringEncoded];
    return text;
}

@end
