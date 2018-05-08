//
//  AutoTestProject.h
//  MaiXiang
//
//  Created by mac on 2017/10/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoTestProject : NSObject

@property (nonatomic,assign)BOOL isRuning;

+ (AutoTestProject *)shareInstance;

- (void)autoTest;

@end
