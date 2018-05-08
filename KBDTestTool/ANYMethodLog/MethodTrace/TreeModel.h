//
//  TreeModel.h
//  ANYMethodLogDemo
//
//  Created by mac on 2017/11/8.
//  Copyright © 2017年 qiuhaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeModel : NSObject

@property (nonatomic,strong)NSMutableDictionary *tree;

+ (TreeModel *)sharedObj;
- (void)addTrace:(NSString *)objRun method:(NSString *)method classString:(NSString *)cls isBegin:(BOOL)begin;
- (NSString *)printTree;

@end
