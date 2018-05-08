//
//  DateTools.h
//  Calendar
//
//  Created by macairwkcao on 15/12/18.
//  Copyright © 2015年 CWK. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface DateTools : NSObject

+(NSDateComponents *)getMonthDateWithDeviation:(NSInteger)deviation;
+(NSInteger)getMonthDays:(NSInteger)month year:(NSInteger)year;
+(NSString*)getChineseCalendarWithDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;


/**根据字符串获取时间*/
+ (NSDate*)convertDateFromString:(NSString*)uiDate;

/**获取某个时间的字符串*/
+ (NSString *)getDateString:(NSDate *)date;

/**获取现在的时间字符串*/
+ (NSString *)currentDate;
+ (NSString *)currentDate_yyyy_MM;
+ (NSString *)currentDate_yyyy_MM_dd;
+ (NSString *)currentDate_yyyy_MM_dd_AfterDays:(NSInteger)days;

//判断是否是闰年
+(BOOL)isLeapYear:(NSInteger)year;

/**获取现在的日期的时间戳,当天晚上12:00*/
+ (long long)getCurDayInterval;
/**获取现在的月份日期的时间戳,当天晚上12:00*/
+ (long long)getCurMonthInterval;
+ (long long)getMonthInterval:(NSString *)monthDate;

+ (long long)getDayInterval:(NSString *)date;
/**获取现在的日期的时间戳,现在时刻*/
+ (long long)getCurInterval;

/**获取当前年*/
+ (NSString *)getCurYearString;
/**获取当前月*/
+ (NSString *)getCurMonthString;
/**获取当前天*/
+ (NSString *)getCurDayString;
/**获取某月的当天*/
+ (NSString *)getDayString:(NSDate *)date;
/**获取当前小时*/
+ (NSString *)getCurHourString;
/**获取当前分钟*/
+ (NSString *)getCurMinuteString;
/**获取当前秒*/
+ (NSString *)getCurSecondString;

/**获取环信时间戳的最后消息时间*/
+ (NSString *)currentMessageTime:(NSString *)chatTimeStamp;
@end
