//
//  MethodNode.h
//  ANYMethodLogDemo
//
//  Created by mac on 2017/11/8.
//  Copyright © 2017年 qiuhaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MethodNode : NSObject

@property (nonatomic,copy)NSString *methodName;

@property (nonatomic,strong)MethodNode *prior;
@property (nonatomic,strong)MethodNode *next;

@end
