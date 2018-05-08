//
//  ZHClassTree.h
//  ANYMethodLogDemo
//
//  Created by mac on 2017/11/13.
//  Copyright © 2017年 qiuhaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHClassTree : NSObject

- (void)addClassArrInTree:(NSArray *)classNames;
- (NSArray *)fathersForClass:(NSString *)className;
- (void)printTree;

+ (ZHClassTree *)shareInstance;

@end
