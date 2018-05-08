#import "RTRepearDictionary.h"

@implementation RTRepearDictionary

- (instancetype)init{
    self = [super init];
    if (self) {
        self.countKeyDicM = [NSMutableDictionary dictionaryWithCapacity:10];
        self.dicM = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

- (NSString*)setValue:(id)value forKey:(NSString*)key{

    id targetValue = self.dicM[key];
    if (targetValue != nil) {

        NSString* newKey = [self getNewKey:key];

        //说明已经存在这个key值,但是不能直接为下面这样,这样虽然写起来简单,但是数量一旦多了,会出现性能问题,比如你要查找所有类似这个key值,就要for循环一遍
        //        [self.dicM setValue:value forKey:newKey];

        //而应该这么写
        NSMutableDictionary* subValues = nil;
        if ([targetValue isKindOfClass:[NSMutableDictionary class]]) { //如果是字典类型,说明相同的早就已经存放在数据里面了
            subValues = targetValue;
        } else { //说明还是字符串类型
            subValues = [NSMutableDictionary dictionaryWithObject:targetValue forKey:key];
            [self.dicM setValue:subValues forKey:key];
        }
        [subValues setValue:value forKey:newKey];

        NSNumber* num = self.countKeyDicM[key];
        NSInteger count = 0;
        if (num != nil)
            count = [num integerValue];
        count++;
        [self.countKeyDicM setValue:[NSNumber numberWithInteger:count] forKey:key];
        return newKey;
    } else {
        [self.dicM setValue:value forKey:key];
    }
    return key;
}

- (NSString*)getValueForKey:(NSString*)key{
    NSString* origalKey = key;
    key = [RTRepearDictionary getKeyForKey:key];

    id targetValue = self.dicM[key];
    if (targetValue != nil) {
        if ([targetValue isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary* subValues = targetValue;
            return subValues[origalKey];
        }
    }

    return self.dicM[key];
}

- (NSMutableDictionary*)getValuesForKey:(NSString*)key{

    key = [RTRepearDictionary getKeyForKey:key];
    id targetValue = self.dicM[key];
    if (targetValue != nil) {
        if ([targetValue isKindOfClass:[NSMutableDictionary class]]) {
            return targetValue;
        }
    }

    return [NSMutableDictionary dictionaryWithObject:self.dicM[key] forKey:key];
}
- (NSInteger)hasKeyCount:(NSString*)key{
    NSNumber* num = self.countKeyDicM[key];
    if (num != nil) {
        return [num integerValue];
    }
    return 0;
}

+ (NSString*)getKeyForKey:(NSString*)key{
    NSUInteger location = [key rangeOfString:@"_index_" options:4].location;
    if (location != NSNotFound) {
        key = [key substringToIndex:location];
    }
    return key;
}

- (NSString*)getNewKey:(NSString*)key{
    return [NSString stringWithFormat:@"%@_index_%zd", key, [self hasKeyCount:key] + 1];
}

@end


