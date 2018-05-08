#import "RTBaseSettingViewController.h"

@class RTIdentify;

@interface RTPlayBackVC : RTBaseSettingViewController

@property (nonatomic,strong)NSArray *playBackModels;
@property (nonatomic,weak)RTIdentify *identify;
@property (nonatomic,copy)NSString *videoPath;
@property (nonatomic,copy)NSString *stamp;
@end
