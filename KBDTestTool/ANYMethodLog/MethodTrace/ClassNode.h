//
//  ClassNode.h
//  ANYMethodLogDemo
//
//  Created by mac on 2017/11/8.
//  Copyright © 2017年 qiuhaodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MethodNode.h"

@interface ClassNode : NSObject

@property (nonatomic,copy)NSString *runObj;

@property (nonatomic,strong)NSMutableDictionary *methods;
@property (nonatomic,strong)NSMutableArray *methodOrder;
@property (nonatomic,strong)MethodNode *curMethodNode;
@property (nonatomic,weak)MethodNode *headMethodNode;

- (void)recordTrace:(NSString *)objRun method:(NSString *)method classString:(NSString *)cls isBegin:(BOOL)begin;

@end
