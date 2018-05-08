#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CompareArray) {
    CompareArray_Same=0,//两个数组相等
    CompareArray_Different=-1,//两个数组不相等
    CompareArray_PoriorLarge=1,//前面的数组包括后面的数组
    CompareArray_NextLarge=2//后面的数组包括前面的数组
};


@interface NSArray (ZH)



/**将数组Data转换成NSArray*/
+ (NSArray *)arrayWithPlistData:(NSData *)plist;

/**将plist文件数据转换成数组,先会进行尝试,如果发现plist文件数据存放的是数组,就返回解析数据*/
+ (NSArray *)arrayWithPlistString:(NSString *)plist;

/**将Json转换成NSArray*/
+ (NSArray *)arrayWithJsonString:(NSString *)json;

/**将数组转换过成NSData(XML)*/
- (NSData *)plistData;

/**将数组转换过成NSString(XML)*/
- (NSString *)plistString;

/**任意的一个元素*/
- (id)randomObject;

/**返回第几个元素,如果不存在,就返回nil*/
- (id)objectOrNilAtIndex:(NSUInteger)index;

/**将数组转换过成json字符串*/
- (NSString *)jsonStringEncoded;

/**将数组转换过成json字符串,并把json字符串格式化*/
- (NSString *)jsonPrettyStringEncoded;

/**去和另外一个数组(字符串)比较*/
- (CompareArray)compareToTextArr:(NSArray *)otherTextArr;

/**获取所有的属性名*/
+ (NSArray *)allPropertiesFromClass:(Class)cls;

/**获取所有的成员变量名*/
+ (NSArray *)allMemberVariablesFromClass:(Class)cls;

@end







@interface NSMutableArray (ZH)



/**将数组Data转换成NSMutableArray*/
+ (NSMutableArray *)arrayWithPlistData:(NSData *)plist;

/**将plist文件数据转换成数组,先会进行尝试,如果发现plist文件数据存放的是数组,就返回解析数据*/
+ (NSMutableArray *)arrayWithPlistString:(NSString *)plist;




/**移除第一个元素*/
- (void)removeFirstObject;

/**移除最后一个元素*/
- (void)removeLastObject;

/**pop出第一个元素*/
- (id)popFirstObject;

/**pop出最后一个元素*/
- (id)popLastObject;




/**在父数组尾部插入一个元素*/
- (void)appendObject:(id)anObject;

/**在父数组头部插入一个元素*/
- (void)prependObject:(id)anObject;

/**在父数组尾部插入数组*/
- (void)appendObjects:(NSArray *)objects;

/**在父数组头部插入数组*/
- (void)prependObjects:(NSArray *)objects;

/**将子数组插入到父数组的第几个位置*/
- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index;

/**反转数组里的内容*/
- (void)reverse;

/**随机打乱数组*/
- (void)shuffle;




@end
