//
//  UISwitch+Event.m
//  CJOL
//
//  Created by mac on 2018/3/18.
//  Copyright © 2018年 SuDream. All rights reserved.
//

#import "UISwitch+Event.h"
#import "AutoTestHeader.h"

@implementation UISwitch (Event)

- (void)happenEvent{
    self.on = !self.on;
    [super happenEvent];
}

@end
