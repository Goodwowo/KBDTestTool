//
//  UIColor+SDColor.h
//  CJOL
//
//  Created by leo on 16/8/24.
//  Copyright © 2016年 SuDream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SDColor)

/**
 *  RGB转换UIColor
 *
 *  @param stringToConvert rgb
 *
 *  @return color
 */
+(instancetype) colorWithHexString:(NSString *) stringToConvert;

@end
