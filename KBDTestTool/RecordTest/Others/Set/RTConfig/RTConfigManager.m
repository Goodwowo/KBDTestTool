
#import "RTConfigManager.h"
#import "ZHSaveDataToFMDB.h"

@implementation RTConfigManager

+ (RTConfigManager *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTConfigManager *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTConfigManager alloc] init];
        
        NSString *autoDeleteDay = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTAutoDeleteDay"];
        if(autoDeleteDay.length > 0) _sharedObject.autoDeleteDay = [autoDeleteDay integerValue];
        else _sharedObject.autoDeleteDay = -1;
        
        NSString *compressionQuality = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTCompressionQuality"];
        if(compressionQuality.length > 0) _sharedObject.compressionQuality = [compressionQuality floatValue];
        else _sharedObject.compressionQuality = -1;
        
        NSString *isAutoDelete = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTIsAutoDelete"];
        if(isAutoDelete.length > 0) _sharedObject.isAutoDelete = [isAutoDelete boolValue];
        else _sharedObject.isAutoDelete = NO;
        
        NSString *isRecoderVideo = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTIsRecoderVideo"];
        if(isRecoderVideo.length > 0) _sharedObject.isRecoderVideo = [isRecoderVideo boolValue];
        else _sharedObject.isRecoderVideo = NO;
        
        NSString *isRecoderVideoPlayBack = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTIsRecoderVideoPlayBack"];
        if(isRecoderVideoPlayBack.length > 0) _sharedObject.isRecoderVideoPlayBack = [isRecoderVideoPlayBack boolValue];
        else _sharedObject.isRecoderVideoPlayBack = NO;
        
        NSString *compressionQualityRecoderVideo = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTCompressionQualityRecoderVideo"];
        if(compressionQualityRecoderVideo.length > 0) _sharedObject.compressionQualityRecoderVideo = [compressionQualityRecoderVideo integerValue];
        else _sharedObject.compressionQualityRecoderVideo = -1;
        
        NSString *compressionQualityRecoderVideoPlayBack = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTCompressionQualityRecoderVideoPlayBack"];
        if(compressionQualityRecoderVideoPlayBack.length > 0) _sharedObject.compressionQualityRecoderVideoPlayBack = [compressionQualityRecoderVideoPlayBack integerValue];
        else _sharedObject.compressionQualityRecoderVideoPlayBack = -1;
        
        NSString *isMigrationImage = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTIsMigrationImage"];
        if(isMigrationImage.length > 0) _sharedObject.isMigrationImage = [isMigrationImage boolValue];
        else _sharedObject.isMigrationImage = YES;
        
        NSString *isMigrationVideo = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTIsMigrationVideo"];
        if(isMigrationVideo.length > 0) _sharedObject.isMigrationVideo = [isMigrationVideo boolValue];
        else _sharedObject.isMigrationVideo = YES;
        
        NSString *isShowCpu = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTIsShowCpu"];
        if(isShowCpu.length > 0) _sharedObject.isShowCpu = [isShowCpu boolValue];
        else _sharedObject.isShowCpu = NO;
        
        NSString *isShowMemory = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTIsShowMemory"];
        if(isShowMemory.length > 0) _sharedObject.isShowMemory = [isShowMemory boolValue];
        else _sharedObject.isShowMemory = NO;
        
        NSString *isShowNetDelay = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTIsShowNetDelay"];
        if(isShowNetDelay.length > 0) _sharedObject.isShowNetDelay = [isShowNetDelay boolValue];
        else _sharedObject.isShowNetDelay = NO;
        
        NSString *isShowFPS = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTIsShowFPS"];
        if(isShowFPS.length > 0) _sharedObject.isShowFPS = [isShowFPS boolValue];
        else _sharedObject.isShowFPS = NO;
        
        NSString *lagThreshold = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTLagThreshold"];
        if(lagThreshold.length > 0) _sharedObject.lagThreshold = [lagThreshold floatValue];
        else _sharedObject.lagThreshold = 5;
    });
    return _sharedObject;
}

- (void)setAutoDeleteDay:(NSInteger)autoDeleteDay{
    _autoDeleteDay = autoDeleteDay;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%zd",autoDeleteDay] WithIdentity:@"RTAutoDeleteDay"];
}

- (void)setCompressionQuality:(CGFloat)compressionQuality{
    _compressionQuality = compressionQuality;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%0.2f",compressionQuality] WithIdentity:@"RTCompressionQuality"];
}

- (void)setIsAutoDelete:(BOOL)isAutoDelete{
    _isAutoDelete = isAutoDelete;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%d",isAutoDelete] WithIdentity:@"RTIsAutoDelete"];
}

- (void)setIsRecoderVideo:(BOOL)isRecoderVideo{
    _isRecoderVideo = isRecoderVideo;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%d",isRecoderVideo] WithIdentity:@"RTIsRecoderVideo"];
}

- (void)setIsRecoderVideoPlayBack:(BOOL)isRecoderVideoPlayBack{
    _isRecoderVideoPlayBack = isRecoderVideoPlayBack;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%d",isRecoderVideoPlayBack] WithIdentity:@"RTIsRecoderVideoPlayBack"];
}

- (void)setCompressionQualityRecoderVideo:(NSInteger)compressionQualityRecoderVideo{
    _compressionQualityRecoderVideo = compressionQualityRecoderVideo;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%zd",compressionQualityRecoderVideo] WithIdentity:@"RTCompressionQualityRecoderVideo"];
}

- (void)setCompressionQualityRecoderVideoPlayBack:(NSInteger)compressionQualityRecoderVideoPlayBack{
    _compressionQualityRecoderVideoPlayBack = compressionQualityRecoderVideoPlayBack;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%zd",compressionQualityRecoderVideoPlayBack] WithIdentity:@"RTCompressionQualityRecoderVideoPlayBack"];
}

- (void)setIsMigrationImage:(BOOL)isMigrationImage{
    _isMigrationImage = isMigrationImage;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%d",isMigrationImage] WithIdentity:@"RTIsMigrationImage"];
}

- (void)setIsMigrationVideo:(BOOL)isMigrationVideo{
    _isMigrationVideo = isMigrationVideo;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%d",isMigrationVideo] WithIdentity:@"RTIsMigrationVideo"];
}

- (void)setIsShowCpu:(BOOL)isShowCpu{
    _isShowCpu = isShowCpu;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%d",isShowCpu] WithIdentity:@"RTIsShowCpu"];
}

- (void)setIsShowMemory:(BOOL)isShowMemory{
    _isShowMemory = isShowMemory;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%d",isShowMemory] WithIdentity:@"RTIsShowMemory"];
}

- (void)setIsShowNetDelay:(BOOL)isShowNetDelay{
    _isShowNetDelay = isShowNetDelay;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%d",isShowNetDelay] WithIdentity:@"RTIsShowNetDelay"];
}

- (void)setIsShowFPS:(BOOL)isShowFPS{
    _isShowFPS = isShowFPS;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%d",isShowFPS] WithIdentity:@"RTIsShowFPS"];
}

- (void)setLagThreshold:(CGFloat)lagThreshold{
    _lagThreshold = lagThreshold;
    [ZHSaveDataToFMDB insertDataWithData:[NSString stringWithFormat:@"%0.1f",lagThreshold] WithIdentity:@"RTLagThreshold"];
}

@end
