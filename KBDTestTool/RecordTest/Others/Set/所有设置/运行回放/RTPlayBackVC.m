
#import "RTPlayBackVC.h"
#import "RecordTestHeader.h"
#import "RTPhotosViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "RTALAssetsLibrary.h"
#import "TabBarAndNavagation.h"

@interface RTPlayBackVC ()
@property (nonatomic,strong)MPMoviePlayerViewController *moviePlayerController;
@property (nonatomic,assign)BOOL isExport;
@end

@implementation RTPlayBackVC

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = [self.identify debugDescription];
    self.videoPath = [[RTRecordVideo shareInstance] videosPlayBacks][self.stamp];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"导出" TintColor:[UIColor redColor] target:self action:@selector(export)];
    [self add0SectionItems];
}

- (void)export{
    self.isExport = !self.isExport;
}

- (void)setIsExport:(BOOL)isExport{
    _isExport = isExport;
    [TabBarAndNavagation setRightBarButtonItemTitle:isExport ? @"取消":@"导出" TintColor:[UIColor redColor] target:self action:@selector(export)];
    [self add0SectionItems];
}

- (void)video{
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:[RTOperationImage videoPlayBackPathWithName:self.videoPath]];
    _moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:URL];
    [self presentMoviePlayerViewControllerAnimated:_moviePlayerController];
    _moviePlayerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [_moviePlayerController.moviePlayer setFullscreen:YES animated:YES];
    [_moviePlayerController.moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
    _moviePlayerController.moviePlayer.movieSourceType=MPMovieSourceTypeFile;
    [_moviePlayerController.moviePlayer prepareToPlay];
}

#pragma mark 添加第0组的模型数据
- (void)add0SectionItems
{
    [self.allGroups removeAllObjects];
    __weak typeof(self)weakSelf=self;
    if (self.videoPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:[RTOperationImage videoPlayBackPathWithName:self.videoPath]]) {
        RTSettingItem *item = [RTSettingItem itemWithIcon:@"" title:self.isExport ? @"导出视频":@"播放视频" detail:nil type:ZFSettingItemTypeArrow];
        item.titleFontSize = 14;
        item.operation = ^{
            if (weakSelf.isExport) {
                [[RTALAssetsLibrary shareInstance] saveVideoToPhotosAlbum:[RTOperationImage videoPlayBackPathWithName:self.videoPath]];
            }else{
                [weakSelf video];
            }
        };
        RTSettingGroup *group = [[RTSettingGroup alloc] init];
        group.header = @"录屏视频";
        group.items = @[item];
        [self.allGroups addObject:group];
    }
    
    NSMutableArray *items = [NSMutableArray array];
    for (RTOperationQueueModel *model in self.playBackModels) {
        RTSettingItem *item = [RTSettingItem itemWithIcon:@"" title:self.isExport ? [@"导出截图 " stringByAppendingString:[model debugDescription]]:[model debugDescription] detail:nil type:ZFSettingItemTypeArrow];
        item.operation = ^{
            if (model.imagePath.length > 0) {
                [weakSelf goToPhotoBrowser:model.imagePath];
            }
        };
        switch (model.runResult) {
            case RTOperationQueueRunResultTypeNoRun:
                item.titleColor = [UIColor darkGrayColor];
                break;
            case RTOperationQueueRunResultTypeSuccess:
                item.titleColor = [UIColor greenColor];
                break;
            case RTOperationQueueRunResultTypeFailure:
                item.titleColor = [UIColor redColor];
                break;
            default:
                break;
        }
        [items addObject:item];
    }
    
    RTSettingGroup *group = [[RTSettingGroup alloc] init];
    group.header = @"所有执行命令";
    group.items = items;
    [self.allGroups addObject:group];
    [self.tableView reloadData];
}

- (void)goToPhotoBrowser:(NSString *)imagePath{
    if (!imagePath || imagePath.length<=0 || (![[NSFileManager defaultManager] fileExistsAtPath:[RTOperationImage imagePathWithPlayBackName:imagePath]])) {
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:@"没有对应的截图!"];
        return;
    }
    if (self.isExport) {
        [[RTALAssetsLibrary shareInstance] savePhotoToPhotosAlbum:[RTOperationImage imagePathWithPlayBackName:imagePath]];
        return;
    }
    
    NSMutableArray *imagePaths = [NSMutableArray array];
    for (RTOperationQueueModel *model in self.playBackModels){
        if (model.imagePath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:[RTOperationImage imagePathWithPlayBackName:model.imagePath]]){
            [imagePaths addObject:[RTOperationImage imagePathWithPlayBackName:model.imagePath]];
        }
    }
    RTPhotosViewController *vc=[RTPhotosViewController new];
    vc.imageNames = imagePaths;
    vc.indexCur = [imagePaths indexOfObject:[RTOperationImage imagePathWithPlayBackName:imagePath]];
    vc.bgColor=[UIColor whiteColor];
    vc.isShowPageIndex = YES;
    [vc showToVC:self];
}

- (void)remove:(UITapGestureRecognizer *)ges{
    [ges.view removeFromSuperview];
}

@end
