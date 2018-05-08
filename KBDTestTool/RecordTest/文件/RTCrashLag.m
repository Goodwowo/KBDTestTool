
#import "RTCrashLag.h"
#import "ZHSaveDataToFMDB.h"
#import "DateTools.h"

@implementation RTCrashLag

+ (RTCrashLag *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTCrashLag *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTCrashLag alloc] init];
    });
    return _sharedObject;
}

- (NSMutableDictionary *)crashs{
    NSMutableDictionary *crashs = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTCrashs"];
    if (!crashs) {
        crashs = [NSMutableDictionary dictionary];
    }
    return crashs;
}

- (NSMutableDictionary *)lags{
    NSMutableDictionary *lags = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTLags"];
    if (!lags) {
        lags = [NSMutableDictionary dictionary];
    }
    return lags;
}

- (void)addCrash:(RTCrashModel *)model{
    NSMutableDictionary *crashs = [self crashs];
    [crashs setValue:model forKey:[DateTools currentDate]];
    [ZHSaveDataToFMDB insertDataWithData:crashs WithIdentity:@"RTCrashs"];
}

- (void)addLag:(RTLagModel *)model{
    NSMutableDictionary *lags = [self lags];
    [lags setValue:model forKey:[DateTools currentDate]];
    [ZHSaveDataToFMDB insertDataWithData:lags WithIdentity:@"RTLags"];
}

- (void)removeCrash:(NSString *)stamp{
    NSMutableDictionary *crashs = [self crashs];
    if (crashs[stamp]) {
        [crashs removeObjectForKey:stamp];
        [ZHSaveDataToFMDB insertDataWithData:crashs WithIdentity:@"RTCrashs"];
    }
}

- (void)removeLag:(NSString *)stamp{
    NSMutableDictionary *lags = [self lags];
    if (lags[stamp]) {
        [lags removeObjectForKey:stamp];
        [ZHSaveDataToFMDB insertDataWithData:lags WithIdentity:@"RTLags"];
    }
}

@end
