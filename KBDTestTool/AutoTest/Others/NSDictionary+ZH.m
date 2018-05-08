#import "NSDictionary+ZH.h"

@interface _YYXMLDictionaryParser : NSObject <NSXMLParserDelegate>
@property (nonatomic,assign)BOOL needRecoderOrder;
@end

@implementation _YYXMLDictionaryParser
{
    NSMutableDictionary *_root;
    NSMutableArray *_stack;
    NSMutableString *_text;
    NSInteger recoderOrderIndex;
}

- (instancetype)initWithData:(NSData *)data needRecoderOrder:(BOOL)needRecoderOrder{
    self = super.init;
    self.needRecoderOrder=needRecoderOrder;
    recoderOrderIndex=0;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
    return self;
}

- (instancetype)initWithString:(NSString *)xml needRecoderOrder:(BOOL)needRecoderOrder{
    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
    return [self initWithData:data needRecoderOrder:needRecoderOrder];
}

- (NSDictionary *)result {
    return _root;
}

#pragma mark - NSXMLParserDelegate

#define XMLText @"_text"
#define XMLName @"_name_zh"

- (NSString *)stringByTrim:(NSString *)text {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [text stringByTrimmingCharactersInSet:set];
}

/**这个函数是将xml中的value值保存,但是保存在key:_text value:(value)中*/
- (void)textEnd {
    _text = [self stringByTrim:_text].mutableCopy;
    if (_text.length) {
        NSMutableDictionary *top = _stack.lastObject;
        id existing = top[XMLText];
        if ([existing isKindOfClass:[NSArray class]]) {
            [existing addObject:_text];
        } else if (existing) {
            top[XMLText] = [@[existing, _text] mutableCopy];
        } else {
            top[XMLText] = _text;
        }
    }
    _text = nil;
}

/**解析的时候,是按照一句一句的来,当发现新的xml节点时,就会调用这个函数,并且传过来一些参数*/
- (void)parser:(__unused NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(__unused NSString *)namespaceURI qualifiedName:(__unused NSString *)qName attributes:(NSDictionary *)attributeDict {
    [self textEnd];
    
    NSMutableDictionary *node = [NSMutableDictionary new];
    if (!_root) node[XMLName] = elementName;
    if (attributeDict.count) [node addEntriesFromDictionary:attributeDict];
    
    if (_root) {
        
        if(_needRecoderOrder&&[node isKindOfClass:[NSDictionary class]])
            node[@"ZH_Recoder_Order"]=[NSString stringWithFormat:@"%ld",(long)recoderOrderIndex++];
        
        NSMutableDictionary *top = _stack.lastObject;
        id existing = top[elementName];
        if ([existing isKindOfClass:[NSArray class]]) {
            [existing addObject:node];
        } else if (existing) {
            top[elementName] = [@[existing, node] mutableCopy];
        } else {
            top[elementName] = node;
        }
        [_stack addObject:node];
    } else {
        _root = node;
        _stack = [NSMutableArray arrayWithObject:node];
    }
}

/**解析的时候,当遇到闭合开关的时候,并会调用这个函数,并且传回的参数会告诉是那个开关的闭合*/
- (void)parser:(__unused NSXMLParser *)parser didEndElement:(__unused NSString *)elementName namespaceURI:(__unused NSString *)namespaceURI qualifiedName:(__unused NSString *)qName {
    [self textEnd];
    
    NSMutableDictionary *lastObject = _stack.lastObject;
    [_stack removeLastObject];
    
    //下面的这些操作是因为前面全部的数据都放在字典里,而有时候,需要将这些信息整理成为数组
    
    NSMutableDictionary *secondObject = _stack.lastObject;
    NSString *nodeName = lastObject[XMLName];
    if (!nodeName) {
        for (NSString *name in secondObject) {
            id object = secondObject[name];
            if (object == lastObject) {//当它还只有一个的时候
                nodeName = name; break;
            }else if ([object isKindOfClass:[NSArray class]] && [object containsObject:lastObject]) {//当它有一群的时候
                nodeName = name; break;
            }
        }
    }
    if (!nodeName) return;
    
    id inner = lastObject[XMLText];
    if (!inner) return;
    
    id parent = secondObject[nodeName];
    if ([parent isKindOfClass:[NSArray class]]) {
        NSArray *parentAsArray = parent;
        parent[parentAsArray.count - 1] = inner;
    } else {
        secondObject[nodeName] = inner;
    }
}

- (void)parser:(__unused NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (_text) [_text appendString:string];
    else _text = [NSMutableString stringWithString:string];
}

- (void)parser:(__unused NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    NSString *string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    if (_text) [_text appendString:string];
    else _text = [NSMutableString stringWithString:string];
}

#undef XMLText
#undef XMLName
#undef XMLPref
@end

@implementation NSDictionary (ZH)
/**将字典Data转换成NSDictionary*/
+ (NSDictionary *)dictionaryWithPlistData:(NSData *)plist {
    if (!plist) return nil;
    NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:plist options:NSPropertyListImmutable format:NULL error:NULL];
    if ([dictionary isKindOfClass:[NSDictionary class]]) return dictionary;
    return nil;
}
/**将字典NSString转换成NSDictionary*/
+ (NSDictionary *)dictionaryWithPlistString:(NSString *)plist {
    if (!plist) return nil;
    NSData *data = [plist dataUsingEncoding:NSUTF8StringEncoding];
    return [self dictionaryWithPlistData:data];
}

/**将字典转换成xml(plistData)*/
- (NSData *)plistData {
    return [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListBinaryFormat_v1_0 options:kNilOptions error:NULL];
}

/**将字典转换成xml(plist字符串)*/
- (NSString *)plistString {
    NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListXMLFormat_v1_0 options:kNilOptions error:NULL];
    if (xmlData) return [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    return nil;
}

/**所有的keys值通过字符字典序列进行排序*/
- (NSArray *)allKeysSorted {
    return [[self allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

/**因为字典是无序的,所以在这里对keys进行排序,根据排序好的key对应的value组成数组并返回*/
- (NSArray *)allValuesSortedByKeys {
    NSArray *sortedKeys = [self allKeysSorted];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (id key in sortedKeys) {
        [arr addObject:self[key]];
    }
    return [arr copy];
}

/**判断是否包含某个key值对应的value*/
- (BOOL)containsObjectForKey:(id)key {
    if (!key) return NO;
    return self[key] != nil;
}

/**拿出keys对应的value重新组成一个字典返回*/
- (NSDictionary *)entriesForKeys:(NSArray *)keys {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    for (id key in keys) {
        id value = self[key];
        if (value) dic[key] = value;
    }
    return [dic copy];
}

/**将字典转换过成json字符串,但是是一串没有格式化的字符串*/
- (NSString *)jsonStringEncoded {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}

/**将字典转换过成json字符串,并把json字符串格式化*/
- (NSString *)jsonPrettyStringEncoded {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}

/**将xml转换成NSDictionary*/
+ (NSDictionary *)dictionaryWithXML:(id)xml needRecoderOrder:(BOOL)needRecoderOrder{
    _YYXMLDictionaryParser *parser = nil;
    if ([xml isKindOfClass:[NSString class]]) {
        parser = [[_YYXMLDictionaryParser alloc] initWithString:xml needRecoderOrder:needRecoderOrder];
    } else if ([xml isKindOfClass:[NSData class]]) {
        parser = [[_YYXMLDictionaryParser alloc] initWithData:xml needRecoderOrder:needRecoderOrder];
    }
    return [parser result];
}

/**将Json转换成NSDictionary*/
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)json{
    return [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingMutableContainers) error:nil];
}

/**将id转换成NSNumber*/
static NSNumber *NSNumberFromID(id value) {
    static NSCharacterSet *dot;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
    });
    if (!value || value == [NSNull null]) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSString *lower = ((NSString *)value).lowercaseString;
        if ([lower isEqualToString:@"true"] || [lower isEqualToString:@"yes"]) return @(YES);
        if ([lower isEqualToString:@"false"] || [lower isEqualToString:@"no"]) return @(NO);
        if ([lower isEqualToString:@"nil"] || [lower isEqualToString:@"null"]) return nil;
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            return @(((NSString *)value).doubleValue);//最大化保留精度
        } else {
            return @(((NSString *)value).longLongValue);//最大化保留精度
        }
    }
    return nil;
}

//利用define的优点 如(NSNumberFromID(value)._type_)有点吊
#define RETURN_VALUE(_type_)                                                     \
if (!key) return def;                                                            \
id value = self[key];                                                            \
if (!value || value == [NSNull null]) return def;                                \
if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value)._type_;   \
if ([value isKindOfClass:[NSString class]]) return NSNumberFromID(value)._type_; \
return def;

- (BOOL)boolValueForKey:(NSString *)key default:(BOOL)def {
    RETURN_VALUE(boolValue);
}

- (char)charValueForKey:(NSString *)key default:(char)def {
    RETURN_VALUE(charValue);
}

- (unsigned char)unsignedCharValueForKey:(NSString *)key default:(unsigned char)def {
    RETURN_VALUE(unsignedCharValue);
}

- (short)shortValueForKey:(NSString *)key default:(short)def {
    RETURN_VALUE(shortValue);
}

- (unsigned short)unsignedShortValueForKey:(NSString *)key default:(unsigned short)def {
    RETURN_VALUE(unsignedShortValue);
}

- (int)intValueForKey:(NSString *)key default:(int)def {
    RETURN_VALUE(intValue);
}

- (unsigned int)unsignedIntValueForKey:(NSString *)key default:(unsigned int)def {
    RETURN_VALUE(unsignedIntValue);
}

- (long)longValueForKey:(NSString *)key default:(long)def {
    RETURN_VALUE(longValue);
}

- (unsigned long)unsignedLongValueForKey:(NSString *)key default:(unsigned long)def {
    RETURN_VALUE(unsignedLongValue);
}

- (long long)longLongValueForKey:(NSString *)key default:(long long)def {
    RETURN_VALUE(longLongValue);
}

- (unsigned long long)unsignedLongLongValueForKey:(NSString *)key default:(unsigned long long)def {
    RETURN_VALUE(unsignedLongLongValue);
}

- (float)floatValueForKey:(NSString *)key default:(float)def {
    RETURN_VALUE(floatValue);
}

- (double)doubleValueForKey:(NSString *)key default:(double)def {
    RETURN_VALUE(doubleValue);
}

- (NSInteger)integerValueForKey:(NSString *)key default:(NSInteger)def {
    RETURN_VALUE(integerValue);
}

- (NSUInteger)unsignedIntegerValueForKey:(NSString *)key default:(NSUInteger)def {
    RETURN_VALUE(unsignedIntegerValue);
}

/**如果key值对应的value为NSNumber或者NSString类型的返回对应的NSNumber,否则返回默认的def
 这个一般用于获取json数据中的某个字段,如果这个字段不存在或者这个字段是number类型的,都可以进行防崩溃处理
 还可以不用我们去判断某个字段是字符串时需要转换成那种number类型
 */
- (NSNumber *)numberValueForKey:(NSString *)key default:(NSNumber *)def {
    if (!key) return def;
    id value = self[key];
    if (!value || value == [NSNull null]) return def;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) return NSNumberFromID(value);
    return def;
}

/**如果key值对应的value为String或者number类型的返回对应的NSSTring,否则返回默认的def
 这个一般用于获取json数据中的某个字段,如果这个字段不存在或者这个字段是number类型的,都可以进行防崩溃处理
 */
- (NSString *)stringValueForKey:(NSString *)key default:(NSString *)def {
    if (!key) return def;
    id value = self[key];
    if (!value || value == [NSNull null]) return def;
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value).description;
    return def;
}
@end

@implementation NSMutableDictionary (ZH)

/**将字典Data转换成NSMutableDictionary*/
+ (NSMutableDictionary *)dictionaryWithPlistData:(NSData *)plist {
    if (!plist) return nil;
    NSMutableDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:plist options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
    if ([dictionary isKindOfClass:[NSMutableDictionary class]]) return dictionary;
    return nil;
}

/**将plist文件数据转换成字典,先会进行尝试,如果发现plist文件数据存放的是字典,就返回解析数据*/
+ (NSMutableDictionary *)dictionaryWithPlistString:(NSString *)plist {
    if (!plist) return nil;
    NSData *data = [plist dataUsingEncoding:NSUTF8StringEncoding];
    return [self dictionaryWithPlistData:data];
}

/**pop出一个元素,根据key值*/
- (id)popObjectForKey:(id)aKey {
    if (!aKey) return nil;
    id value = self[aKey];
    [self removeObjectForKey:aKey];
    return value;
}

/**pop出多个元素并返回,根据keys值*/
- (NSDictionary *)popEntriesForKeys:(NSArray *)keys {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    for (id key in keys) {
        id value = self[key];
        if (value) {
            [self removeObjectForKey:key];
            dic[key] = value;
        }
    }
    return [dic copy];
}

@end
