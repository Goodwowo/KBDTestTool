
#import "RTSettingViewController.h"
#import "RecordTestHeader.h"
#import "RTPickerManager.h"
#import "RTSetFileSizeViewController.h"
#import "RTMigrationDataVC.h"
#import "RTFileListVC.h"
#import "RTFeedbackVC.h"
#import "SuspendBall.h"

@interface RTSettingViewController ()
@end

@implementation RTSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 1.第0组：3个
    [self add0SectionItems];
}

#pragma mark 添加第0组的模型数据
- (void)add0SectionItems
{
    __weak typeof(self)weakSelf=self;
    // 1.1.录制测试设置
    NSString *curTitle = @"0.0";
    if ([RTConfigManager shareInstance].compressionQuality != -1) {
        curTitle = [NSString stringWithFormat:@"%0.1f",[RTConfigManager shareInstance].compressionQuality];
    }
    RTSettingItem *item1 = [RTSettingItem itemWithIcon:@"" title:@"截图压缩率" detail:[NSString stringWithFormat:@"录制过程屏幕截图的压缩率: %@",curTitle] type:ZFSettingItemTypeArrow];
    //cell点击事件
    __weak typeof(item1)weakItem1=item1;
    item1.operation = ^{
        NSMutableArray *dataArr = [NSMutableArray array];
        for (NSInteger i=0; i<=5; i++) {
            [dataArr addObject:[NSString stringWithFormat:@"%0.1f",i/10.0]];
        }
        NSString *curTitle = dataArr[0];
        if ([RTConfigManager shareInstance].compressionQuality != -1) {
            curTitle = [NSString stringWithFormat:@"%0.1f",[RTConfigManager shareInstance].compressionQuality];
        }
        [[RTPickerManager shareManger] showPickerViewWithDataArray:dataArr curTitle:curTitle title:@"选择截图压缩率" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString *string) {
            weakSelf.compressionQuality = [string floatValue];
            weakItem1.detail = [NSString stringWithFormat:@"录制过程屏幕截图的压缩率: %@",string];
            [weakSelf.tableView reloadData];
        } cancelBlock:nil];
    };
    
    NSArray *qualitys = @[@"不清晰(节省空间)",@"一般(推荐使用)",@"清晰(比较清晰,有点浪费空间)",@"高清(画质非常好,非常浪费空间)"];
    curTitle = qualitys[0];
    if ([RTConfigManager shareInstance].compressionQualityRecoderVideo != -1) {
        NSInteger compressionQualityRecoderVideo = [RTConfigManager shareInstance].compressionQualityRecoderVideo;
        if(compressionQualityRecoderVideo >=0 || compressionQualityRecoderVideo<qualitys.count){
            curTitle = qualitys[compressionQualityRecoderVideo];
        }
    }
    RTSettingItem *item1_1 = [RTSettingItem itemWithIcon:@"" title:@"录制过程是否录制视频" subTitle:curTitle type:ZFSettingItemTypeSwitch];
    item1_1.subTitleFontSize = 10;
    item1_1.on = [RTConfigManager shareInstance].isRecoderVideo;
    __weak typeof(item1_1)weakItem1_1=item1_1;
    //开关事件
    item1_1.switchBlock = ^(BOOL on) {
        weakSelf.isRecoderVideo = on;
    };
    item1_1.operation = ^{
        NSString *curTitle = qualitys[0];
        if ([RTConfigManager shareInstance].compressionQualityRecoderVideo != -1) {
            NSInteger compressionQualityRecoderVideo = [RTConfigManager shareInstance].compressionQualityRecoderVideo;
            if(compressionQualityRecoderVideo >=0 || compressionQualityRecoderVideo<qualitys.count){
                curTitle = qualitys[compressionQualityRecoderVideo];
            }
        }
        [[RTPickerManager shareManger] showPickerViewWithDataArray:qualitys curTitle:curTitle title:@"选择录制视频的画质" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString *string) {
            weakItem1_1.detail = [NSString stringWithFormat:@"%@",string];
            weakSelf.compressionQualityRecoderVideo = [qualitys indexOfObject:string];
            [weakSelf.tableView reloadData];
        } cancelBlock:nil];
    };
    
    RTSettingGroup *group = [[RTSettingGroup alloc] init];
    group.header = @"录制测试设置";
    group.items = @[item1,item1_1];
    [self.allGroups addObject:group];
    
    // 1.2.测试回放设置
    curTitle = @"30天";
    if ([RTConfigManager shareInstance].autoDeleteDay != -1) {
        curTitle = [NSString stringWithFormat:@"%ld天",(long)[RTConfigManager shareInstance].autoDeleteDay];
    }
    RTSettingItem *item2 = [RTSettingItem itemWithIcon:@"" title:@"录制截图自动清除" subTitle:curTitle type:ZFSettingItemTypeSwitch];
    item2.subTitleFontSize = 10;
    item2.on = [RTConfigManager shareInstance].isAutoDelete;
    __weak typeof(item2)weakItem2=item2;
    //开关事件
    item2.switchBlock = ^(BOOL on) {
        weakSelf.isAutoDelete = on;
    };
    item2.operation = ^{
        NSMutableArray *dataArr = [NSMutableArray array];
        for (NSInteger i=5; i<=30; i++) {
            [dataArr addObject:[NSString stringWithFormat:@"%ld天",(long)i]];
        }
        NSString *curTitle = dataArr[0];
        if ([RTConfigManager shareInstance].autoDeleteDay != -1) {
            curTitle = [NSString stringWithFormat:@"%ld天",(long)[RTConfigManager shareInstance].autoDeleteDay];
        }
        [[RTPickerManager shareManger] showPickerViewWithDataArray:dataArr curTitle:curTitle title:@"选择多少天后自动清除" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString *string) {
            weakItem2.detail = [NSString stringWithFormat:@"%@",string];
            weakSelf.autoDeleteDay = [string integerValue];
            [weakSelf.tableView reloadData];
        } cancelBlock:nil];
    };
    
    curTitle = qualitys[0];
    if ([RTConfigManager shareInstance].compressionQualityRecoderVideoPlayBack != -1) {
        NSInteger compressionQualityRecoderVideoPlayBack = [RTConfigManager shareInstance].compressionQualityRecoderVideoPlayBack;
        if(compressionQualityRecoderVideoPlayBack >=0 || compressionQualityRecoderVideoPlayBack<qualitys.count){
            curTitle = qualitys[compressionQualityRecoderVideoPlayBack];
        }
    }
    RTSettingItem *item2_1 = [RTSettingItem itemWithIcon:@"" title:@"测试回放是否录制视频" subTitle:curTitle type:ZFSettingItemTypeSwitch];
    item2_1.subTitleFontSize = 10;
    item2_1.on = [RTConfigManager shareInstance].isRecoderVideoPlayBack;
    __weak typeof(item2_1)weakItem2_1=item2_1;
    //开关事件
    item2_1.switchBlock = ^(BOOL on) {
        weakSelf.isRecoderVideoPlayBack = on;
    };
    item2_1.operation = ^{
        NSString *curTitle = qualitys[0];
        if ([RTConfigManager shareInstance].compressionQualityRecoderVideoPlayBack != -1) {
            NSInteger compressionQualityRecoderVideoPlayBack = [RTConfigManager shareInstance].compressionQualityRecoderVideoPlayBack;
            if(compressionQualityRecoderVideoPlayBack >=0 || compressionQualityRecoderVideoPlayBack<qualitys.count){
                curTitle = qualitys[compressionQualityRecoderVideoPlayBack];
            }
        }
        [[RTPickerManager shareManger] showPickerViewWithDataArray:qualitys curTitle:curTitle title:@"选择录制视频的画质" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString *string) {
            weakItem2_1.detail = [NSString stringWithFormat:@"%@",string];
            weakSelf.compressionQualityRecoderVideoPlayBack = [qualitys indexOfObject:string];
            [weakSelf.tableView reloadData];
        } cancelBlock:nil];
    };
    
    
    RTSettingGroup *group2 = [[RTSettingGroup alloc] init];
    group2.header = @"测试回放设置";
    group2.items = @[item2,item2_1];
    [self.allGroups addObject:group2];
    
    // 1.3占用存储空间
    RTSettingItem *item3 = [RTSettingItem itemWithIcon:@"" title:@"占用存储空间" subTitle:@"计算中..." type:ZFSettingItemTypeArrow];
    item3.subTitleFontSize = 10;
    item3.operation = ^{
        RTSetFileSizeViewController *vc = [RTSetFileSizeViewController new];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    RTSettingItem *item3_1 = [RTSettingItem itemWithIcon:@"" title:@"沙盒目录" subTitle:@"计算中..." type:ZFSettingItemTypeArrow];
    item3_1.subTitleFontSize = 10;
    item3_1.operation = ^{
        [weakSelf.navigationController pushViewController:[RTFileListVC new] animated:YES];
    };
    RTSettingGroup *group3 = [[RTSettingGroup alloc] init];
    group3.header = @"存储空间";
    group3.items = @[item3,item3_1];
    [self.allGroups addObject:group3];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //通知主线程刷新
        item3.subTitle = [RTOperationImage allSize];
        item3_1.subTitle = [RTOperationImage homeDirectorySize];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    
    RTSettingItem *item4 = [RTSettingItem itemWithIcon:@"" title:@"共享数据到其它设备" subTitle:nil type:ZFSettingItemTypeArrow];
    item4.subTitleFontSize = 10;
    item4.operation = ^{
        RTMigrationDataVC *vc = [RTMigrationDataVC new];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    
    RTSettingItem *item4_1 = [RTSettingItem itemWithIcon:@"" title:@"是否共享录制和回放截屏" subTitle:@"" type:ZFSettingItemTypeSwitch];
    item4_1.on = [RTConfigManager shareInstance].isMigrationImage;
    //开关事件
    item4_1.switchBlock = ^(BOOL on) {
        weakSelf.isMigrationImage = on;
    };
    RTSettingItem *item4_2 = [RTSettingItem itemWithIcon:@"" title:@"是否共享录制和回放视频" subTitle:@"" type:ZFSettingItemTypeSwitch];
    item4_2.on = [RTConfigManager shareInstance].isMigrationVideo;
    //开关事件
    item4_2.switchBlock = ^(BOOL on) {
        weakSelf.isMigrationVideo = on;
    };
    RTSettingGroup *group4 = [[RTSettingGroup alloc] init];
    group4.header = @"蓝牙传输";
    group4.items = @[item4,item4_1,item4_2];
    [self.allGroups addObject:group4];
    
    
    RTSettingItem *item5_1 = [RTSettingItem itemWithIcon:@"" title:@"是否显示CPU使用率" subTitle:@"显示在第1个球上方" type:ZFSettingItemTypeSwitch];
    item5_1.on = [RTConfigManager shareInstance].isShowCpu;
    item5_1.subTitleFontSize = 10;
    //开关事件
    item5_1.switchBlock = ^(BOOL on) {
        weakSelf.isShowCpu = on;
    };
    
    RTSettingItem *item5_2 = [RTSettingItem itemWithIcon:@"" title:@"是否显示内存使用" subTitle:@"显示在第2个球上方" type:ZFSettingItemTypeSwitch];
    item5_2.on = [RTConfigManager shareInstance].isShowMemory;
    item5_2.subTitleFontSize = 10;
    //开关事件
    item5_2.switchBlock = ^(BOOL on) {
        weakSelf.isShowMemory = on;
    };
    
    RTSettingItem *item5_3 = [RTSettingItem itemWithIcon:@"" title:@"是否显示网络延迟" subTitle:@"显示在第3个球上方" type:ZFSettingItemTypeSwitch];
    item5_3.on = [RTConfigManager shareInstance].isShowNetDelay;
    item5_3.subTitleFontSize = 10;
    //开关事件
    item5_3.switchBlock = ^(BOOL on) {
        weakSelf.isShowNetDelay = on;
    };
    
    RTSettingItem *item5_4 = [RTSettingItem itemWithIcon:@"" title:@"是否显示网络延迟" subTitle:@"显示在第4个球上方" type:ZFSettingItemTypeSwitch];
    item5_4.on = [RTConfigManager shareInstance].isShowFPS;
    item5_4.subTitleFontSize = 10;
    //开关事件
    item5_4.switchBlock = ^(BOOL on) {
        weakSelf.isShowFPS = on;
    };
    
    RTSettingGroup *group5 = [[RTSettingGroup alloc] init];
    group5.header = @"性能展示";
    group5.items = @[item5_1,item5_2,item5_3,item5_4];
    [self.allGroups addObject:group5];
    
    RTSettingItem *item6 = [RTSettingItem itemWithIcon:@"" title:@"退出登录" subTitle:nil type:ZFSettingItemTypeArrow];
    item6.subTitleFontSize = 10;
    item6.operation = ^{
        RTLoginViewController *vc = [RTLoginViewController new];
        [self.navigationController pushViewController:vc animated:YES];
        //        [weakSelf.navigationController pushViewController:[RTFeedbackVC new] animated:YES];
    };
    
    RTSettingGroup *group6 = [[RTSettingGroup alloc] init];
    group6.header = @"账户";
    group6.items = @[item6];
    [self.allGroups addObject:group6];
}

- (void)setCompressionQuality:(CGFloat)compressionQuality{
    [RTConfigManager shareInstance].compressionQuality = compressionQuality;
}
- (void)setAutoDeleteDay:(NSInteger)autoDeleteDay{
    [RTConfigManager shareInstance].autoDeleteDay = autoDeleteDay;
}
- (void)setIsAutoDelete:(BOOL)isAutoDelete{
    [RTConfigManager shareInstance].isAutoDelete = isAutoDelete;
}
- (void)setIsRecoderVideo:(BOOL)isRecoderVideo{
    [RTConfigManager shareInstance].isRecoderVideo = isRecoderVideo;
}
- (void)setIsRecoderVideoPlayBack:(BOOL)isRecoderVideoPlayBack{
    [RTConfigManager shareInstance].isRecoderVideoPlayBack = isRecoderVideoPlayBack;
}
- (void)setCompressionQualityRecoderVideo:(NSInteger)compressionQualityRecoderVideo{
    [RTConfigManager shareInstance].compressionQualityRecoderVideo = compressionQualityRecoderVideo;
}
- (void)setCompressionQualityRecoderVideoPlayBack:(NSInteger)compressionQualityRecoderVideoPlayBack{
    [RTConfigManager shareInstance].compressionQualityRecoderVideoPlayBack = compressionQualityRecoderVideoPlayBack;
}
- (void)setIsMigrationImage:(BOOL)isMigrationImage{
    [RTConfigManager shareInstance].isMigrationImage = isMigrationImage;
}
- (void)setIsMigrationVideo:(BOOL)isMigrationVideo{
    [RTConfigManager shareInstance].isMigrationVideo = isMigrationVideo;
}
- (void)setIsShowCpu:(BOOL)isShowCpu{
    [RTConfigManager shareInstance].isShowCpu = isShowCpu;
    [[SuspendBall shareInstance] setBadge:@"" index:0];
}
- (void)setIsShowMemory:(BOOL)isShowMemory{
    [RTConfigManager shareInstance].isShowMemory = isShowMemory;
    [[SuspendBall shareInstance] setBadge:@"" index:1];
}
- (void)setIsShowNetDelay:(BOOL)isShowNetDelay{
    [RTConfigManager shareInstance].isShowNetDelay = isShowNetDelay;
    [[SuspendBall shareInstance] setBadge:@"" index:2];
}
- (void)setIsShowFPS:(BOOL)isShowFPS{
    [RTConfigManager shareInstance].isShowFPS = isShowFPS;
    [[SuspendBall shareInstance] setBadge:@"" index:3];
}

@end
