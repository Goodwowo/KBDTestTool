
#import <UIKit/UIKit.h>

@interface RTConfigManager : NSObject

@property (nonatomic,assign)NSInteger autoDeleteDay;//录制截图多少天后自动清除
@property (nonatomic,assign)BOOL isAutoDelete;
@property (nonatomic,assign)CGFloat compressionQuality;//录制过程屏幕截图的压缩率
@property (nonatomic,assign)BOOL isRecoderVideo; //是否录制视频
@property (nonatomic,assign)BOOL isRecoderVideoPlayBack; //是否录制运行回放视频
@property (nonatomic,assign)NSInteger compressionQualityRecoderVideo;//录制视频的清晰程度
@property (nonatomic,assign)NSInteger compressionQualityRecoderVideoPlayBack;//录制运行回放视频的清晰程度
@property (nonatomic,assign)BOOL isMigrationImage; //是否共享录制截屏
@property (nonatomic,assign)BOOL isMigrationVideo; //是否共享回放视频

@property (nonatomic,assign)BOOL isShowCpu; //是否显示CPU使用率
@property (nonatomic,assign)BOOL isShowMemory; //是否显示内存使用
@property (nonatomic,assign)BOOL isShowNetDelay; //是否显示网络延迟
@property (nonatomic,assign)BOOL isShowFPS; //是否显示网络延迟

@property (nonatomic,assign)CGFloat lagThreshold;//卡顿阀值

+ (RTConfigManager *)shareInstance;

@end
