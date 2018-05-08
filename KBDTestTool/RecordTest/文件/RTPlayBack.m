
#import "RTPlayBack.h"
#import "RecordTestHeader.h"

@interface RTPlayBack ()
@property (nonatomic,strong)NSMutableDictionary *playBacksCache;//为了解决每次都要访问数据库而导致速度变慢
@end

@implementation RTPlayBack

+ (RTPlayBack *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTPlayBack *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTPlayBack alloc] init];
    });
    return _sharedObject;
}

- (NSMutableDictionary *)playBacks{
    if (self.playBacksCache) {
        return self.playBacksCache;
    }
    NSMutableDictionary *playBacks = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTPlayBack"];
    if (!playBacks) {
        playBacks = [NSMutableDictionary dictionary];
    }
    self.playBacksCache = playBacks;
    return playBacks;
}

+ (void)save{
    [[RTPlayBack shareInstance] save];
}
- (void)save{
    if ([RTPlayBack shareInstance].playBacksCache) {
        [ZHSaveDataToFMDB insertDataWithData:[RTPlayBack shareInstance].playBacksCache WithIdentity:@"RTPlayBack"];
    }
}

+ (void)addPlayBacksFromOtherDataBase:(NSString *)dataBase{
    NSDictionary *playBacksOther = [RTOpenDataBase selectDataWithIdentity:@"RTPlayBack" dataBasePath:dataBase];
    if (playBacksOther.count>0) {
        NSMutableDictionary *playBacks = [[RTPlayBack shareInstance] playBacks];
        [playBacks setValuesForKeysWithDictionary:playBacksOther];
        [self save];
    }
}

- (void)savePlayBack:(NSArray *)playBackModels{
    if (self.stamp > 0 && playBackModels.count > 0 && self.identify) {
        NSMutableDictionary *playBacks = [self playBacks];
        [playBacks setValue:@{[self.identify description]:playBackModels} forKey:[NSString stringWithFormat:@"%lld",self.stamp]];
        [self save];
    }
}

- (void)deletePlayBacks:(NSArray *)stamps{
    if (stamps.count>0) {
        NSMutableDictionary *playBacks = [self playBacks];
        for (NSString *stamp in stamps) {
            if (stamp.length>0) {
                [playBacks removeObjectForKey:stamp];
            }
        }
        [self save];
        [RTOperationImage deleteOverduePlayBackImage];
        [[RTRecordVideo shareInstance]deletePlayBackVideos:stamps];
    }
}

+ (NSArray *)allPlayBackModels{
    NSMutableArray *allPlayBackModels = [NSMutableArray array];
    NSMutableDictionary *playBacks = [[RTPlayBack shareInstance] playBacks];
    NSArray *values = [playBacks allValues];
    for (NSDictionary *value in values) {
        if (value.count>0) {
            NSArray *models = [value allValues][0];
            if ([models isKindOfClass:[NSArray class]] && models.count>0) {
                [allPlayBackModels addObjectsFromArray:models];
            }
        }
    }
    return allPlayBackModels;
}

@end
