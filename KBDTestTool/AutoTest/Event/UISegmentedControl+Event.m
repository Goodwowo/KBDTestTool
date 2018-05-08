//
//  UISegmentedControl+Event.m
//  CJOL
//
//  Created by mac on 2018/3/18.
//  Copyright © 2018年 SuDream. All rights reserved.
//

#import "UISegmentedControl+Event.h"
#import "AutoTestHeader.h"

@implementation UISegmentedControl (Event)

- (void)happenEvent{
    if (self.numberOfSegments > 1) {
        NSInteger original = self.selectedSegmentIndex;
        while (original == self.selectedSegmentIndex) {
            original = arc4random()%self.numberOfSegments;
        }
        self.selectedSegmentIndex = original;
    }
    [super happenEvent];
}

@end
