//
//  ZHSingleMethodDic.h
//  MaiXiang
//
//  Created by mac on 2017/11/10.
//  Copyright © 2017年 GD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHRepearDictionary.h"

@interface ZHSingleMethodDic : NSObject

@property (nonatomic,strong)ZHRepearDictionary *methodDic;
@property (nonatomic,strong)NSMutableDictionary *classDic;


+ (ZHSingleMethodDic *)shareInstance;

- (NSString *)findSameMethod:(NSString *)method inClass:(NSString *)className;

@end
