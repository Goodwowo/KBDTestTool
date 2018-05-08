
#import "RTSetFileSizeViewController.h"
#import "RecordTestHeader.h"
#import "AutoTestHeader.h"

@interface RTSetFileSizeViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation RTSetFileSizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.activityIndicatorView];
    self.activityIndicatorView.center = self.view.center;
    self.activityIndicatorView.y-=64;
    [self.activityIndicatorView startAnimating];
    
    self.title = @"占用的存储空间";
    [TabBarAndNavagation setRightBarButtonItemTitle:@"清除过期" TintColor:[UIColor redColor] target:self action:@selector(delete)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadData];
    });
}

- (void)loadData{
    [self.allGroups removeAllObjects];
    
    NSString *title = @"计算中...", *subTitle = @"计算中...";
    RTSettingItem *item1 = [RTSettingItem itemWithIcon:@"" title:title subTitle:subTitle type:ZFSettingItemTypeNone];
    item1.subTitleFontSize = 12;
    RTSettingGroup *group1 = [[RTSettingGroup alloc] init];
    group1.header = @"所有录制占用的存储空间";
    group1.items = @[item1];
    [self.allGroups addObject:group1];
    
    RTSettingItem *item2 = [RTSettingItem itemWithIcon:@"" title:title subTitle:subTitle type:ZFSettingItemTypeNone];
    item2.subTitleFontSize = 12;
    RTSettingGroup *group2 = [[RTSettingGroup alloc] init];
    group2.header = @"所有运行回放的存储空间";
    group2.items = @[item2];
    [self.allGroups addObject:group2];
    
    RTSettingItem *item3 = [RTSettingItem itemWithIcon:@"" title:title subTitle:subTitle type:ZFSettingItemTypeNone];
    item3.subTitleFontSize = 12;
    RTSettingGroup *group3 = [[RTSettingGroup alloc] init];
    group3.header = @"所有录制的视频占用的存储空间";
    group3.items = @[item3];
    [self.allGroups addObject:group3];
    
    RTSettingItem *item4 = [RTSettingItem itemWithIcon:@"" title:title subTitle:subTitle type:ZFSettingItemTypeNone];
    item4.subTitleFontSize = 12;
    RTSettingGroup *group4 = [[RTSettingGroup alloc] init];
    group4.header = @"所有运行回放视频的存储空间";
    group4.items = @[item4];
    [self.allGroups addObject:group4];
    
    RTSettingItem *item5 = [RTSettingItem itemWithIcon:@"" title:title subTitle:subTitle type:ZFSettingItemTypeNone];
    item5.subTitleFontSize = 12;
    RTSettingGroup *group5 = [[RTSettingGroup alloc] init];
    group5.header = @"所有崩溃截图占用的存储空间";
    group5.items = @[item5];
    [self.allGroups addObject:group5];
    
    RTSettingItem *item6 = [RTSettingItem itemWithIcon:@"" title:title subTitle:subTitle type:ZFSettingItemTypeNone];
    item6.subTitleFontSize = 12;
    RTSettingGroup *group6 = [[RTSettingGroup alloc] init];
    group6.header = @"所有卡顿截图占用的存储空间";
    group6.footer = [NSString stringWithFormat:@"总占用空间: %@",@"计算中..."];
    group6.items = @[item6];
    [self.allGroups addObject:group6];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        item1.title = [NSString stringWithFormat:@"总个数: %@   截图张数: %@",[NSString stringWithFormat:@"%zd",[RTOperationQueue operationQueues].count],[RTOperationImage imagesFileCount]];
        item2.title = [NSString stringWithFormat:@"总个数: %@   截图张数: %@",[NSString stringWithFormat:@"%zd",[[RTPlayBack shareInstance] playBacks].count],[RTOperationImage imagesPlayBackFileCount]];
        item3.title = [NSString stringWithFormat:@"总个数: %@",[RTOperationImage videoFileCount]];
        item4.title = [NSString stringWithFormat:@"总个数: %@",[RTOperationImage videoPlayBackFileCount]];
        item5.title = [NSString stringWithFormat:@"崩溃截图张数: %@",[RTOperationImage crashFileCount]];
        item6.title = [NSString stringWithFormat:@"卡顿截图张数: %@",[RTOperationImage lagFileCount]];
        
        item1.subTitle = [NSString stringWithFormat:@"%@",[RTOperationImage imagesFileSize]];
        item2.subTitle = [NSString stringWithFormat:@"%@",[RTOperationImage imagesPlayBackFileSize]];
        item3.subTitle = [NSString stringWithFormat:@"%@",[RTOperationImage videoFileSize]];
        item4.subTitle = [NSString stringWithFormat:@"%@",[RTOperationImage videoPlayBackFileSize]];
        item5.subTitle = [NSString stringWithFormat:@"%@",[RTOperationImage crashFileSize]];
        item6.subTitle = [NSString stringWithFormat:@"%@",[RTOperationImage lagFileSize]];
        
        group6.footer = [NSString stringWithFormat:@"总占用空间: %@",[RTOperationImage allSize]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.activityIndicatorView stopAnimating];
    });
}

- (void)delete{
    [RTOperationImage deleteOverduePlayBackVideo];
    [RTOperationImage deleteOverdueVideo];
    [RTOperationImage deleteOverdueImage];
    [RTOperationImage deleteOverduePlayBackImage];
    [RTOperationImage deleteOverdueCrash];
    [RTOperationImage deleteOverdueLag];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"" TintColor:[UIColor redColor] target:self action:nil];
    [self loadData];
}

@end
