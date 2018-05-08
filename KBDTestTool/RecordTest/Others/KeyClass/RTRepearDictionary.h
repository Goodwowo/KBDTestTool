#import <Foundation/Foundation.h>

@interface RTRepearDictionary : NSObject

@property (nonatomic,strong)NSMutableDictionary *dicM;
@property (nonatomic,strong)NSMutableDictionary *countKeyDicM;

- (NSString *)setValue:(id)value forKey:(NSString *)key;
- (NSString *)getValueForKey:(NSString *)key;
- (NSMutableDictionary *)getValuesForKey:(NSString *)key;
+ (NSString *)getKeyForKey:(NSString *)key;

@end
