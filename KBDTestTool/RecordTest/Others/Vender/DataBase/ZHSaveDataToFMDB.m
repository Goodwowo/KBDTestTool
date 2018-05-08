#import "ZHSaveDataToFMDB.h"

#define FilePath [NSHomeDirectory() stringByAppendingFormat:@"/Documents/FMDBTemp"]
static NSString *DataBaseName=@"ZHJSONData.rdb";//(数据库名字)
static NSString *TableNameBLOB=@"ZHJSONBLOB";//(这个不能改)
static FMDatabase *dataBase;

@implementation ZHSaveDataToFMDB

+ (void)insertDataWithData:(id)data WithIdentity:(NSString *)identity{
    if([self exsistDataBLOBWithIdentity:identity])[self deleteBLOBDataWithIdentity:identity];
    if([data isKindOfClass:[NSString class]]){
        NSData *myData=[data dataUsingEncoding:NSUTF8StringEncoding];
        if (![[self getDataBase] executeUpdate:@"insert into ZHJSONBLOB (DataType,Identity,JSONBLOBData) values (?,?,?)",@"NSString",identity,myData]) {
            NSLog(@"插入失败");
        }
    }else if([data isKindOfClass:[NSDictionary class]]){
        NSDictionary *tempDic=(NSDictionary *)data;
        NSData *myData=[NSKeyedArchiver archivedDataWithRootObject:tempDic];
        if(myData==nil){
            NSLog(@"归档失败");
            return;
        }
        //注意:我这里被坑了好久,%@来格式化二进制会被格式化成字符串(总之,要想存储二进制,不能使用下面的这句语句)
        
        //错误示范
        //        NSString *code=[NSString stringWithFormat:@"insert into %@ (DataType,Identity,JSONBLOBData) values ('%@','%@','%@')",TableNameBLOB,@"NSDictionary",identity,myData];
        
        if (![[self getDataBase] executeUpdate:@"insert into ZHJSONBLOB (DataType,Identity,JSONBLOBData) values (?,?,?)",@"NSDictionary",identity,myData]) {
            NSLog(@"插入失败");
        }
    }else if([data isKindOfClass:[NSArray class]]){
        NSArray *tempArr=(NSArray *)data;
        
        NSData *myData=[NSKeyedArchiver archivedDataWithRootObject:tempArr];
        if(myData==nil){
            NSLog(@"归档失败");
            return;
        }
        if (![[self getDataBase] executeUpdate:@"insert into ZHJSONBLOB (DataType,Identity,JSONBLOBData) values (?,?,?)",@"NSArray",identity,myData]) {
            NSLog(@"插入失败");
        }
    }
}

+ (BOOL)selectDataWithIdentity:(NSString *)identity toModel:(id)model{
    id obj=[self selectDataWithIdentity:identity];
    if(obj!=nil){
        if([obj isKindOfClass:[NSDictionary class]]){
            [model setValuesForKeysWithDictionary:(NSDictionary *)obj];
            return YES;
        }else{
            NSLog(@"模型setValuesForKeysWithDictionary的数据不是Dictionary");
            return NO;
        }
    }else{
        return NO;
    }
}

#pragma mark ----------删除数据
+ (void)deleteBLOBDataWithIdentity:(NSString *)identity{
    //需要检测是否在删除空数据,因为可能会被误认为删除失败
    NSString *codeBLOB=[NSString stringWithFormat:@"delete from %@ where Identity = '%@'",TableNameBLOB,identity];
    if(![[self getDataBase] executeUpdate:codeBLOB]){
        NSLog(@"删除缓存 %@ 失败",identity);
    }
}

#pragma mark ----------清除所有缓存
+ (void)cleanAllData{
    NSString *code=[NSString stringWithFormat:@"delete from %@",TableNameBLOB];
    if(![[self getDataBase]executeUpdate:code]){
        NSLog(@"清除缓存失败");
    }
}

//通过使用静态FMDatabase来获取唯一的Database句柄,这个用来操作数据库的
+ (FMDatabase *)getDataBase{
    if (dataBase==nil) {
        dataBase = [[FMDatabase alloc] initWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",DataBaseName]];
        if (![dataBase open]) {
            NSLog(@"数据库创建失败");
        }
        
        NSString *codeBLOB=[NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement ,DataType text,Identity text,JSONBLOBData BLOB)",TableNameBLOB];
        if (![dataBase executeUpdate:codeBLOB]) {
            NSLog(@"创建表失败");
        }
    }
    return dataBase;
}

//读取数据出来(中间不会产生一个临时的文件)
+ (id)selectDataWithIdentity:(NSString *)identity{
    NSString *code=[NSString stringWithFormat:@"select * from %@ where Identity='%@'",TableNameBLOB,identity];
    FMResultSet *set = [[self getDataBase] executeQuery:code];
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

//判断是否已经存在这条数据
+ (BOOL)exsistDataBLOBWithIdentity:(NSString *)identity{
    NSString *code=[NSString stringWithFormat:@"select * from %@ where Identity='%@'",TableNameBLOB,identity];
    FMResultSet *set = [[self getDataBase] executeQuery:code];
    while ([set next]) {
        return YES;
    }
    return NO;
}

//处理数据存储单引号所引起的问题
+ (NSString *)enCode:(NSString *)text{
    NSMutableString *temp=[NSMutableString string];
    NSInteger lenth=text.length;
    unichar ch;
    for(NSInteger i=0;i<lenth;i++){
        ch=[text characterAtIndex:i];
        if(ch=='\''){
            [temp appendString:@"@@"];
        }
        else [temp appendFormat:@"%C",ch];
    }
    return temp;
}

+ (NSString *)deCode:(NSString *)text{
    NSMutableString *temp=[NSMutableString string];
    NSInteger lenth=text.length;
    unichar ch;
    for(NSInteger i=0;i<lenth-1;i++){
        ch=[text characterAtIndex:i];
        if(ch=='@'&&[text characterAtIndex:i+1]=='@'){
            [temp appendString:@"'"];
            i++;
        }
        else [temp appendFormat:@"%C",ch];
    }
    if([text characterAtIndex:lenth-1]!='@')
        [temp appendFormat:@"%C",[text characterAtIndex:lenth-1]];
    return temp;
}

@end
