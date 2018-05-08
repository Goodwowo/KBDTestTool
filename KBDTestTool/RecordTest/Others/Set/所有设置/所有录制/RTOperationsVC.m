
#import "RTOperationsVC.h"
#import "RecordTestHeader.h"
#import "RTPhotosViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "RTALAssetsLibrary.h"

@interface RTOperationsVC ()
@property (nonatomic,strong)NSArray *operationQueueModels;
@property (nonatomic,copy)NSString *videoPath;
@property (nonatomic,strong)MPMoviePlayerViewController *moviePlayerController;
@property (nonatomic,assign)BOOL isExport;
@end

@implementation RTOperationsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [self.identify debugDescription];
    self.videoPath = [[RTRecordVideo shareInstance] videos][[self.identify description]];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"导出" TintColor:[UIColor redColor] target:self action:@selector(export)];
    [self add0SectionItems];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
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
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:[RTOperationImage videoPathWithName:self.videoPath]];
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
    if (self.videoPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:[RTOperationImage videoPathWithName:self.videoPath]]) {
        RTSettingItem *item = [RTSettingItem itemWithIcon:@"" title:self.isExport ? @"导出视频":@"播放视频" detail:nil type:ZFSettingItemTypeArrow];
        item.operation = ^{
            if (weakSelf.isExport) {
                [[RTALAssetsLibrary shareInstance] saveVideoToPhotosAlbum:[RTOperationImage videoPathWithName:self.videoPath]];
            }else{
                [weakSelf video];
            }
        };
        RTSettingGroup *group = [[RTSettingGroup alloc] init];
        group.header = @"录屏视频";
        group.items = @[item];
        [self.allGroups addObject:group];
    }
    
    NSArray *operationQueueModels = [RTOperationQueue getOperationQueue:self.identify];
    self.operationQueueModels = operationQueueModels;
    NSMutableArray *items = [NSMutableArray array];
    for (RTOperationQueueModel *model in operationQueueModels) {
        RTSettingItem *item = [RTSettingItem itemWithIcon:@"" title:self.isExport ? [@"导出截图 " stringByAppendingString:[model debugDescription]]:[model debugDescription] detail:nil type:ZFSettingItemTypeArrow];
        item.operation = ^{
            [weakSelf goToPhotoBrowser:model.imagePath];
        };
        [items addObject:item];
    }
    
    RTSettingGroup *group = [[RTSettingGroup alloc] init];
    group.header = @"所有执行命令";
    group.items = items;
    [self.allGroups addObject:group];
    [self.tableView reloadData];
}

- (void)goToPhotoBrowser:(NSString *)imagePath{
    if (!imagePath || imagePath.length<=0 || (![[NSFileManager defaultManager] fileExistsAtPath:[RTOperationImage imagePathWithName:imagePath]])) {
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:@"没有对应的截图!"];
        return;
    }
    if (self.isExport) {
        [[RTALAssetsLibrary shareInstance] savePhotoToPhotosAlbum:[RTOperationImage imagePathWithName:imagePath]];
        return;
    }
    NSMutableArray *imagePaths = [NSMutableArray array];
    for (RTOperationQueueModel *model in self.operationQueueModels){
        if (model.imagePath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:[RTOperationImage imagePathWithName:model.imagePath]]){
            [imagePaths addObject:[RTOperationImage imagePathWithName:model.imagePath]];
        }
    }
    RTPhotosViewController *vc=[RTPhotosViewController new];
    vc.imageNames = imagePaths;
    vc.indexCur = [imagePaths indexOfObject:[RTOperationImage imagePathWithName:imagePath]];
    vc.bgColor=[UIColor whiteColor];
    vc.isShowPageIndex = YES;
    [vc showToVC:self];
}

@end
