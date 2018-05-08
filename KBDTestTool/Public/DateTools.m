//
//  DateTools.m
//  Calendar
//
//  Created by macairwkcao on 15/12/18.
//  Copyright © 2015年 CWK. All rights reserved.
//

#import "DateTools.h"

@implementation DateTools

+(NSDateComponents *)getCurrentDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now;
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    now = [NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    return comps;
}


+(NSDateComponents *)getMonthDateWithDeviation:(NSInteger)deviation
{
    NSDateComponents *comps = [DateTools getCurrentDate];
    
    NSInteger month = [comps month];
    NSInteger year = [comps year];
    
    NSInteger yearDeviation;
    NSInteger monthDeviation;
    
    if (deviation>0) {
        
        yearDeviation = deviation/12;//说明大于一年了
        monthDeviation = deviation%12;//比现在多了几个月
        
        if (monthDeviation+month >12 ) {//如果多了的月数加上现在的月数大于12,说明要增加一年,并且约束要
            month = monthDeviation + month - 12;
            yearDeviation++;
        }
        else{
            month = month + monthDeviation;//否则说明还是在本月内
        }
        
        year = year+yearDeviation;
    }
    else
    {
        if (deviation<0) {
            deviation*=-1;
        }
        
        yearDeviation = deviation/12;
        monthDeviation = deviation%12;
        
        if (month -monthDeviation<= 0) {
            month = 12 - ( monthDeviation- month );
            yearDeviation++;
        }
        else{
            month = month - monthDeviation;
        }
        
        year = year-yearDeviation;
    }
    
    NSString* string;
    if(month<10)
    {
        string = [NSString stringWithFormat:@"%ld0%ld01",(long)year,(long)month];
    }
    else
    {
        string = [NSString stringWithFormat:@"%ld%ld01",(long)year,(long)month];
    }
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    inputFormatter.timeZone = [NSTimeZone systemTimeZone];
    [inputFormatter setDateFormat:@"yyyyMMdd"];
    NSDate* inputDate = [inputFormatter dateFromString:string];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    components = [calendar components:unitFlags fromDate:inputDate];
    return components;
}

//判断每个月的天数,是为了特殊的二月份的天数
+(NSInteger)getMonthDays:(NSInteger)month year:(NSInteger)year
{
    if (month<=0 || month > 12) {
        return 0;
    }
    BOOL isLeapYear = [DateTools isLeapYear:year];
    int  februaryDay;
    if (isLeapYear) {
        februaryDay = 29;
    }
    else
    {
        februaryDay = 28;
    }
    
    if (month == 1||month == 3||month == 5||month == 7||month == 8||month == 10||month == 12) {
        return 31;
    } else if (month == 4||month ==6||month ==9||month ==11) {
        return 30;
    }else {
        return februaryDay;
    }
}

//判断是否是闰年
+(BOOL)isLeapYear:(NSInteger)year{
    if ((year % 4  == 0 && year % 100 != 0)|| year % 400 == 0)
        return YES;
    else
        return NO;
}

//获取阴历
+(NSString*)getChineseCalendarWithDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year{
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                          @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                          @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    NSString* string;
    if(month<10)
    {
        if (day < 10) {
            string = [NSString stringWithFormat:@"%ld0%ld0%ld",(long)year,(long)month,(long)day];
        }
        else{
            string = [NSString stringWithFormat:@"%ld0%ld%ld",(long)year,(long)month,(long)day];
        }
    }
    else
    {
        if (day < 10) {
            string = [NSString stringWithFormat:@"%ld%ld0%ld",(long)year,(long)month,(long)day];
        }
        else{
            string = [NSString stringWithFormat:@"%ld%ld%ld",(long)year,(long)month,(long)day];
        }
    }
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyyMMdd"];
    NSDate* inputDate = [inputFormatter dateFromString:string];
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:inputDate];
    NSString *d_str = [chineseDays objectAtIndex:localeComp.day-1];
    return d_str;
}


/**根据字符串获取时间*/
+ (NSDate*)convertDateFromString:(NSString*)uiDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[formatter dateFromString:uiDate];
    return date;
}

/**获取某个时间的字符串*/
+ (NSString *)getDateString:(NSDate *)date{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

/**获取当前年*/
+ (NSString *)getCurYearString{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy"];
    return [formatter stringFromDate:[NSDate date]];
}

/**获取当前月*/
+ (NSString *)getCurMonthString{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM"];
    return [formatter stringFromDate:[NSDate date]];
}

/**获取当前天*/
+ (NSString *)getCurDayString{
    return [self getDayString:[NSDate date]];
}

/**获取某月的当天*/
+ (NSString *)getDayString:(NSDate *)date{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd"];
    return [formatter stringFromDate:date];
}

/**获取当前小时*/
+ (NSString *)getCurHourString{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH"];
    return [formatter stringFromDate:[NSDate date]];
}

/**获取当前分钟*/
+ (NSString *)getCurMinuteString{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"mm"];
    return [formatter stringFromDate:[NSDate date]];
}

/**获取当前秒*/
+ (NSString *)getCurSecondString{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"ss"];
    return [formatter stringFromDate:[NSDate date]];
}

/**获取现在的时间字符串*/
+ (NSString *)currentDate{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:[NSDate date]];
}
+ (NSString *)currentDate_yyyy_MM{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM"];
    return [formatter stringFromDate:[NSDate date]];
}
+ (NSString *)currentDate_yyyy_MM_dd{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:[NSDate date]];
}
+ (NSString *)currentDate_yyyy_MM_dd_AfterDays:(NSInteger)days{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:days*24*3600]];
}

/**获取现在的日期的时间戳,当天晚上12:00*/
+ (long long)getCurDayInterval{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *curTimeString=[formatter stringFromDate:[NSDate date]];
    NSDate *curDay=[self convertDateFromString:curTimeString];
    
    long long timeStamp=(long long)[curDay timeIntervalSince1970];
    return timeStamp;
}

/**获取现在的月份日期的时间戳,当天晚上12:00*/
+ (long long)getCurMonthInterval{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM"];
    NSString *curTimeString=[formatter stringFromDate:[NSDate date]];
    curTimeString=[curTimeString stringByAppendingString:@"-01"];
    
    NSDate *curDay=[self convertDateFromString:curTimeString];
    
    long long timeStamp=(long long)[curDay timeIntervalSince1970];
    return timeStamp;
}
+ (long long)getMonthInterval:(NSString *)monthDate{
    monthDate=[monthDate stringByAppendingString:@"-01"];
    
    NSDate *curDay=[self convertDateFromString:monthDate];
    
    long long timeStamp=(long long)[curDay timeIntervalSince1970];
    return timeStamp;
}

+ (long long)getDayInterval:(NSString *)date{
    NSDate *curDay=[self convertDateFromString:date];
    long long timeStamp=(long long)[curDay timeIntervalSince1970];
    return timeStamp;
}

/**获取现在的日期的时间戳,现在时刻*/
+ (long long)getCurInterval{
    long long timeStamp=(long long)[[NSDate date] timeIntervalSince1970];
    return timeStamp;
}

/**获取环信时间戳的最后消息时间*/
+ (NSString *)currentMessageTime:(NSString *)chatTimeStamp{
    long long timeStamp=(long long)[[NSDate date] timeIntervalSince1970];
    NSString *timeStampStr=[NSString stringWithFormat:@"%lld",timeStamp];
    chatTimeStamp=[chatTimeStamp substringToIndex:timeStampStr.length];
    
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm"];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[chatTimeStamp longLongValue]]];
}
@end
