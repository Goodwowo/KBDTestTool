#import <Foundation/Foundation.h>

@interface NSDictionary (ZH)
/**将字典Data转换成NSDictionary*/
+ (NSDictionary *)dictionaryWithPlistData:(NSData *)plist;
/**将字典NSString转换成NSDictionary*/
+ (NSDictionary *)dictionaryWithPlistString:(NSString *)plist;

/**将字典转换成xml(plistData)*/
- (NSData *)plistData;

/**将字典转换成xml(plist字符串)*/
- (NSString *)plistString;

/**所有的keys值通过字符字典序列进行排序*/
- (NSArray *)allKeysSorted;

/**因为字典是无序的,所以在这里对keys进行排序,根据排序好的key对应的value组成数组并返回*/
- (NSArray *)allValuesSortedByKeys;

/**判断是否包含某个key值对应的value*/
- (BOOL)containsObjectForKey:(id)key;

/**拿出keys对应的value重新组成一个字典返回*/
- (NSDictionary *)entriesForKeys:(NSArray *)keys;

/**将字典转换过成json字符串,但是是一串没有格式化的字符串*/
- (NSString *)jsonStringEncoded;

/**将字典转换过成json字符串,并把json字符串格式化*/
- (NSString *)jsonPrettyStringEncoded;

/**将xml转换成NSDictionary*/
+ (NSDictionary *)dictionaryWithXML:(id)xml needRecoderOrder:(BOOL)needRecoderOrder;

/**将Json转换成NSDictionary*/
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)json;

- (BOOL)boolValueForKey:(NSString *)key default:(BOOL)def;

- (char)charValueForKey:(NSString *)key default:(char)def;

- (unsigned char)unsignedCharValueForKey:(NSString *)key default:(unsigned char)def;

- (short)shortValueForKey:(NSString *)key default:(short)def;

- (unsigned short)unsignedShortValueForKey:(NSString *)key default:(unsigned short)def;

- (int)intValueForKey:(NSString *)key default:(int)def;

- (unsigned int)unsignedIntValueForKey:(NSString *)key default:(unsigned int)def;

- (long)longValueForKey:(NSString *)key default:(long)def;

- (unsigned long)unsignedLongValueForKey:(NSString *)key default:(unsigned long)def;

- (long long)longLongValueForKey:(NSString *)key default:(long long)def;

- (unsigned long long)unsignedLongLongValueForKey:(NSString *)key default:(unsigned long long)def;

- (float)floatValueForKey:(NSString *)key default:(float)def;

- (double)doubleValueForKey:(NSString *)key default:(double)def;

- (NSInteger)integerValueForKey:(NSString *)key default:(NSInteger)def;

- (NSUInteger)unsignedIntegerValueForKey:(NSString *)key default:(NSUInteger)def;

/**如果key值对应的value为NSNumber或者NSString类型的返回对应的NSNumber,否则返回默认的def
 这个一般用于获取json数据中的某个字段,如果这个字段不存在或者这个字段是number类型的,都可以进行防崩溃处理
 还可以不用我们去判断某个字段是字符串时需要转换成那种number类型
 */
- (NSNumber *)numberValueForKey:(NSString *)key default:(NSNumber *)def;

/**如果key值对应的value为String或者number类型的返回对应的NSSTring,否则返回默认的def
 这个一般用于获取json数据中的某个字段,如果这个字段不存在或者这个字段是number类型的,都可以进行防崩溃处理
 */
- (NSString *)stringValueForKey:(NSString *)key default:(NSString *)def;
@end





@interface NSMutableDictionary (ZH)
/**将字典Data转换成NSMutableDictionary*/
+ (NSMutableDictionary *)dictionaryWithPlistData:(NSData *)plist;

/**将plist文件数据转换成字典,先会进行尝试,如果发现plist文件数据存放的是字典,就返回解析数据*/
+ (NSMutableDictionary *)dictionaryWithPlistString:(NSString *)plist;

/**pop出一个元素,根据key值*/
- (id)popObjectForKey:(id)aKey;

/**pop出多个元素,根据keys值*/
- (NSDictionary *)popEntriesForKeys:(NSArray *)keys;
@end
