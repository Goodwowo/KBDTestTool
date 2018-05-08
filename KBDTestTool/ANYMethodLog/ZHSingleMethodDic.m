//
//  ZHSingleMethodDic.m
//  MaiXiang
//
//  Created by mac on 2017/11/10.
//  Copyright © 2017年 GD. All rights reserved.
//

#import "ZHSingleMethodDic.h"
#import "ZHRepearDictionary.h"

@implementation ZHSingleMethodDic

+ (ZHSingleMethodDic *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static ZHSingleMethodDic *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[ZHSingleMethodDic alloc] init];
        
        _sharedObject.methodDic=[ZHRepearDictionary new];
        _sharedObject.classDic=[NSMutableDictionary dictionaryWithCapacity:1];
    });
    
    return _sharedObject;
}

- (NSString *)findSameMethod:(NSString *)method inClass:(NSString *)className{
    NSDictionary *methods=self.classDic[className];
    if (methods!=nil) {
        method=[ZHRepearDictionary getKeyForKey:method];
        if(methods[method]){
            return [method stringByAppendingString:methods[method]];
        }
    }
    return nil;
}

@end
