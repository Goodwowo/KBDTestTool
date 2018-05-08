
#import "RTRecordVideo.h"
#import "RecordTestHeader.h"
#import "ZHSaveDataToFMDB.h"

@interface RTRecordVideo ()
@property (nonatomic,strong)NSMutableDictionary *videosCache;
@property (nonatomic,strong)NSMutableDictionary *videosPlayBacksCache;
@end

@implementation RTRecordVideo

+ (RTRecordVideo *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTRecordVideo *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTRecordVideo alloc] init];
    });
    return _sharedObject;
}
- (NSMutableDictionary *)videos{
    if (self.videosCache) {
        return self.videosCache;
    }
    NSMutableDictionary *videos = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTVideo"];
    if (!videos) {
        videos = [NSMutableDictionary dictionary];
    }
    self.videosCache = videos;
    return videos;
}

+ (void)save{
    [[RTRecordVideo shareInstance] save];
}

- (void)save{
    if ([RTRecordVideo shareInstance].videosCache) {
        [ZHSaveDataToFMDB insertDataWithData:[RTRecordVideo shareInstance].videosCache WithIdentity:@"RTVideo"];
    }
    if ([RTRecordVideo shareInstance].videosPlayBacksCache) {
        [ZHSaveDataToFMDB insertDataWithData:[RTRecordVideo shareInstance].videosPlayBacksCache WithIdentity:@"RTVideoPlayBack"];
    }
}

+ (void)addVideosFromOtherDataBase:(NSString *)dataBase{
    NSDictionary *videosOther = [RTOpenDataBase selectDataWithIdentity:@"RTVideo" dataBasePath:dataBase];
    if (videosOther.count>0) {
        NSMutableDictionary *videos = [[RTRecordVideo shareInstance] videos];
        [videos setValuesForKeysWithDictionary:videosOther];
        [self save];
    }
}
- (NSMutableDictionary *)videosPlayBacks{
    if (self.videosPlayBacksCache) {
        return self.videosPlayBacksCache;
    }
    NSMutableDictionary *videosPlayBacks = [ZHSaveDataToFMDB selectDataWithIdentity:@"RTVideoPlayBack"];
    if (!videosPlayBacks) {
        videosPlayBacks = [NSMutableDictionary dictionary];
    }
    self.videosPlayBacksCache = videosPlayBacks;
    return videosPlayBacks;
}
+ (void)addVideosPlayBacksFromOtherDataBase:(NSString *)dataBase{
    NSDictionary *videosPlayBacksOther = [RTOpenDataBase selectDataWithIdentity:@"RTVideoPlayBack" dataBasePath:dataBase];
    if (videosPlayBacksOther.count>0) {
        NSMutableDictionary *videosPlayBacks = [[RTRecordVideo shareInstance] videosPlayBacks];
        [videosPlayBacks setValuesForKeysWithDictionary:videosPlayBacksOther];
        [self save];
    }
}
- (void)saveVideoPlayBackForStamp:(NSString *)stamp videoPath:(NSString *)videoPath{
    if (stamp > 0 && videoPath.length > 0) {
        NSMutableDictionary *playBacks = [self videosPlayBacks];
        [playBacks setValue:[RTOperationImage savePlayBackVideo:videoPath] forKey:stamp];
        [self save];
    }
}
- (void)saveVideoForIdentify:(RTIdentify *)identify videoPath:(NSString *)videoPath{
    if ([identify description] > 0 && videoPath.length > 0) {
        NSMutableDictionary *videos = [self videos];
        [videos setValue:[RTOperationImage saveVideo:videoPath] forKey:[identify description]];
        [self save];
    }
}

- (void)deleteVideos:(NSArray *)identifys{
    NSMutableDictionary *videos = [self videos];
    for (RTIdentify *identify in identifys) {
        if (videos[[identify description]]) {
            [videos removeObjectForKey:[identify description]];
        }
    }
    [self save];
    [RTOperationImage deleteOverdueVideo];
}

- (void)deletePlayBackVideos:(NSArray *)stamps{
    NSMutableDictionary *videosPlayBacks = [self videos];
    for (NSString *stamp in stamps) {
        if (videosPlayBacks[stamp]) {
            [videosPlayBacks removeObjectForKey:stamp];
        }
    }
    [self save];
    [RTOperationImage deleteOverduePlayBackVideo];
}

@end
