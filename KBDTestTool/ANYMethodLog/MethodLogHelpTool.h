//
//  MethodLogHelpTool.h
//  ANYMethodLogDemo
//
//  Created by mac on 2017/11/8.
//  Copyright © 2017年 qiuhaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MethodLogHelpTool : NSObject

+ (void)logMethodTrace;
+ (void)logAllMethod;
+ (void)logMethodTraceWithClassArr:(NSArray *)arr;
+ (void)logAllMethodWithClassArr:(NSArray *)arr;
+ (void)logAllPropertyWithClassArr:(NSArray *)arr;

@end
