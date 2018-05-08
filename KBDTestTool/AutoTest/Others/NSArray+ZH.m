#import "NSArray+ZH.h"
#import <objc/runtime.h>

@implementation NSArray (ZH)

/**将数组Data转换成NSArray*/
+ (NSArray *)arrayWithPlistData:(NSData *)plist {
    if (!plist) return nil;
    NSArray *array = [NSPropertyListSerialization propertyListWithData:plist options:NSPropertyListImmutable format:NULL error:NULL];
    if ([array isKindOfClass:[NSArray class]]) return array;
    return nil;
}

/**将Json转换成NSArray*/
+ (NSArray *)arrayWithJsonString:(NSString *)json{
    return [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingMutableContainers) error:nil];
}

/**将plist文件数据转换成数组,先会进行尝试,如果发现plist文件数据存放的是数组,就返回解析数据*/
+ (NSArray *)arrayWithPlistString:(NSString *)plist {
    if (!plist) return nil;
    NSData *data = [plist dataUsingEncoding:NSUTF8StringEncoding];
    return [self arrayWithPlistData:data];
}

/**将数组转换过成NSData(XML)*/
- (NSData *)plistData{
    return [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListBinaryFormat_v1_0 options:kNilOptions error:NULL];
}

/**将数组转换过成NSString(XML)*/
- (NSString *)plistString {
    NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListXMLFormat_v1_0 options:kNilOptions error:NULL];
    if (xmlData) return [[NSString alloc]initWithData:xmlData encoding:NSUTF8StringEncoding];
    return nil;
}

/**随机的一个元素*/
- (id)randomObject {
    if (self.count) {
        return self[arc4random_uniform((u_int32_t)self.count)];
    }
    return nil;
}

/**返回第几个元素,如果不存在,就返回nil*/
- (id)objectOrNilAtIndex:(NSUInteger)index {
    return index < self.count ? self[index] : nil;
}

/**将数组转换过成json字符串,但是是一串没有格式化的字符串*/
- (NSString *)jsonStringEncoded {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}

/**将数组转换过成json字符串,并把json字符串格式化*/
- (NSString *)jsonPrettyStringEncoded {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}

/**移除相同的字符串*/
- (NSArray *)removeSameString:(NSArray *)arr{
    NSMutableArray *arrM=[NSMutableArray array];
    for (NSString *str in arr) {
        if ([arrM containsObject:str]==NO) {
            [arrM addObject:str];
        }
    }
    return arrM;
}

- (BOOL)haveSameString:(NSArray *)arr targetStr:(NSString *)targrtStr{
    NSInteger count=0;
    for (NSString *tempStr in arr) {
        if ([tempStr isEqualToString:targrtStr]) {
            count++;
            if (count>1) {
                return YES;
            }
        }
    }
    return NO;
}
/**去和另外一个数组(字符串)比较*/
- (CompareArray)compareToTextArr:(NSArray *)otherTextArr{
    
    NSArray *selfUniqueArr=[self removeSameString:self];
    NSArray *otherUniqueArr=[self removeSameString:otherTextArr];
    NSArray *maxLenArr=selfUniqueArr.count>otherUniqueArr.count?selfUniqueArr:otherUniqueArr;
    NSArray *minLenArr;
    if (maxLenArr==selfUniqueArr) minLenArr=otherUniqueArr;
    else minLenArr=selfUniqueArr;
    
    NSArray *targetArr;
    NSMutableString *text=[NSMutableString stringWithString:@"-"];
    [text appendString:[maxLenArr componentsJoinedByString:@"-"]];
    [text appendString:@"-"];

    for (NSString *tempStr in minLenArr) {
        if ([text rangeOfString:[NSString stringWithFormat:@"-%@-",tempStr]].location==NSNotFound) {
            targetArr=minLenArr;
            break;
        }
    }
    if (targetArr==nil) {
        if (maxLenArr.count==minLenArr.count)
            return CompareArray_Same;
        else if(maxLenArr==selfUniqueArr)return CompareArray_PoriorLarge;
        return CompareArray_NextLarge;
    }
    return CompareArray_Different;
}

/**获取所有的属性名*/
+ (NSArray *)allPropertiesFromClass:(Class)cls{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    
    static NSArray *filters = nil;
    if (filters==nil)filters=@[@"superclass", @"description", @"debugDescription", @"hash"];
    
    for (NSUInteger i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        if ([filters containsObject:name]==NO) {
            [propertiesArray addObject:name];
        }
    }
    free(properties);
    return propertiesArray;
}

/**获取所有的成员变量名*/
+ (NSArray *)allMemberVariablesFromClass:(Class)cls{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(cls, &count);
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    static NSArray *filters = nil;
    if (filters==nil)filters=@[@"superclass", @"description", @"debugDescription", @"hash"];
    
    for (NSUInteger i = 0; i < count; ++i) {
        Ivar variable = ivars[i];
        const char *name = ivar_getName(variable);
        NSString *varName = [NSString stringWithUTF8String:name];
        if ([filters containsObject:varName]==NO) {
            [results addObject:varName];
        }
    }
    return results;
}

@end


@implementation NSMutableArray (ZH)

/**将数组Data转换成NSMutableArray*/
+ (NSMutableArray *)arrayWithPlistData:(NSData *)plist {
    if (!plist) return nil;
    //    NSMutableArray *arr=[NSMutableArray arrayWithContentsOfFile:@""];这个方法里面可能就是调用了下面的这句方法代码来解析的
    NSMutableArray *array = [NSPropertyListSerialization propertyListWithData:plist options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
    if ([array isKindOfClass:[NSMutableArray class]]) return array;
    return nil;
}

/**将plist文件数据转换成数组,先会进行尝试,如果发现plist文件数据存放的是数组,就返回解析数据*/
+ (NSMutableArray *)arrayWithPlistString:(NSString *)plist {
    if (!plist) return nil;
    NSData *data = [plist dataUsingEncoding:NSUTF8StringEncoding];
    return [self arrayWithPlistData:data];
}

/**移除第一个元素*/
- (void)removeFirstObject {
    if (self.count) {
        [self removeObjectAtIndex:0];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

/**移除最后一个元素*/
- (void)removeLastObject {
    if (self.count) {
        [self removeObjectAtIndex:self.count - 1];
    }
}

#pragma clang diagnostic pop

/**pop出第一个元素*/
- (id)popFirstObject {
    id obj = nil;
    if (self.count) {
        obj = self.firstObject;
        [self removeFirstObject];
    }
    return obj;
}
/**pop出最后一个元素*/
- (id)popLastObject {
    id obj = nil;
    if (self.count) {
        obj = self.lastObject;
        [self removeLastObject];
    }
    return obj;
}



/**在父数组尾部插入一个元素*/
- (void)appendObject:(id)anObject {
    [self addObject:anObject];
}
/**在父数组头部插入一个元素*/
- (void)prependObject:(id)anObject {
    [self insertObject:anObject atIndex:0];
}
/**在父数组尾部插入数组*/
- (void)appendObjects:(NSArray *)objects {
    if (!objects) return;
    [self addObjectsFromArray:objects];
}
/**在父数组头部插入数组*/
- (void)prependObjects:(NSArray *)objects {
    if (!objects) return;
    NSUInteger i = 0;
    for (id obj in objects) {
        [self insertObject:obj atIndex:i++];
    }
}
/**将子数组插入到父数组的第几个位置*/
- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index {
    NSUInteger i = index;
    for (id obj in objects) {
        [self insertObject:obj atIndex:i++];
    }
}
/**反转数组里的内容*/
- (void)reverse {
    NSUInteger count = self.count;
    int mid = floor(count / 2.0);
    for ( NSUInteger i = 0; i < mid; i++ ) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:(count - (i + 1))];
    }
}
/**随机打乱数组*/
- (void)shuffle {
    for ( NSUInteger i = self.count; i > 1; i-- ) {
        [self exchangeObjectAtIndex:(i - 1) withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
}

@end
