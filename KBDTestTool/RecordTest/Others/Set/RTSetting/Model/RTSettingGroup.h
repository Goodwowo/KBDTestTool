
#import <Foundation/Foundation.h>

@interface RTSettingGroup : NSObject

@property (nonatomic, copy) NSString *header; // 头部标题
@property (nonatomic, copy) NSString *footer; // 尾部标题
@property (nonatomic, strong) NSArray *items; // 中间的条目
@property (nonatomic,assign)long long sort;

@end
