
#import <Foundation/Foundation.h>
@class RTIdentify;

@interface RTPlayBack : NSObject

@property (nonatomic,assign)long long stamp;
@property (nonatomic,strong)RTIdentify *identify;

+ (RTPlayBack *)shareInstance;
- (NSMutableDictionary *)playBacks;
+ (void)addPlayBacksFromOtherDataBase:(NSString *)dataBase;
+ (NSArray *)allPlayBackModels;
- (void)savePlayBack:(NSArray *)playBackModels;
- (void)deletePlayBacks:(NSArray *)stamps;

@end
