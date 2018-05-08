#import "RTOpenDataBase.h"

static NSString *TableNameBLOB=@"ZHJSONBLOB";//(这个不能改)

@implementation RTOpenDataBase

//读取数据出来(中间不会产生一个临时的文件)
+ (id)selectDataWithIdentity:(NSString *)identity dataBasePath:(NSString *)dataBasePath{
    NSString *code=[NSString stringWithFormat:@"select * from %@ where Identity='%@'",TableNameBLOB,identity];
    FMDatabase *dataBase = [[FMDatabase alloc] initWithPath:dataBasePath];
    if (![dataBase open]) {
        NSLog(@"数据库创建失败");
        return nil;
    }
    FMResultSet *set = [dataBase executeQuery:code];
    NSData * JSONData;
    NSString *DataType;
    while ([set next]) {
        JSONData=[set dataForColumn:@"JSONBLOBData"];
        DataType=[set stringForColumn:@"DataType"];
    }
    //开始判断类型
    if([DataType isEqualToString:@"NSString"]){
        return [[NSString alloc]initWithData:JSONData encoding:NSUTF8StringEncoding];
    }else if([DataType isEqualToString:@"NSDictionary"]){
        NSDictionary *tempDic=[NSKeyedUnarchiver unarchiveObjectWithData:JSONData];
        return tempDic;
    }else if([DataType isEqualToString:@"NSArray"]){
        NSArray *tempArr=[NSKeyedUnarchiver unarchiveObjectWithData:JSONData];
        return tempArr;
    }else if([DataType isEqualToString:@"URL"]){
        return [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
    }
    return nil;
}

+ (void)closeDataBasePath:(NSString *)dataBasePath{
    FMDatabase *dataBase = [[FMDatabase alloc] initWithPath:dataBasePath];
    if (dataBase) {
        [dataBase close];
    }
}

@end
