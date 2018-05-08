
#import "RTDeviceInfoVC.h"
#import "RecordTestHeader.h"
#import "RTDeviceDetailInfo.h"
#import "RTDeviceInfo.h"
#import "RTWifiConnectionDevicesVC.h"

@interface RTDeviceInfoVC ()
@property (nonatomic,assign)BOOL shouldRefresh;
@end

@implementation RTDeviceInfoVC

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"手机设备信息";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.shouldRefresh = YES;
    [self refreshInfo];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.shouldRefresh = NO;
}

- (void)refreshInfo{
    if (self.shouldRefresh) {
        [self add0SectionItems];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshInfo];
        });
    }
}

#pragma mark 添加第0组的模型数据
- (void)add0SectionItems{
    [self.allGroups removeAllObjects];
    NSMutableArray *datas = [NSMutableArray array];
    [datas addObject:@{[NSString stringWithFormat:@"AppName : %@",[RTDeviceDetailInfo applicationDisplayName]]:@""}];
    [datas addObject:@{[NSString stringWithFormat:@"App Vesion : %@",[RTDeviceDetailInfo applicationVersion]]:@""}];
    [datas addObject:@{[NSString stringWithFormat:@"iOS Vesion : %@",[RTDeviceDetailInfo phoneSystemVersion]]:@""}];
    [datas addObject:@{[NSString stringWithFormat:@"是否越狱 : %@",[RTDeviceDetailInfo jailbrokenDevice]?@"已越狱":@"未越狱"]:@""}];
    [datas addObject:@{[NSString stringWithFormat:@"app占用内存 : %.2f MB",[RTDeviceInfo shareInstance].appMemory]:@""}];
    [datas addObject:@{[NSString stringWithFormat:@"系统可用内存 : %.2f MB",[RTDeviceInfo shareInstance].systemAvailableMemory]:@""}];
    [datas addObject:@{[NSString stringWithFormat:@"app占用cpu : %.2f%%",[RTDeviceInfo shareInstance].appCpu]:@""}];
    [datas addObject:@{[NSString stringWithFormat:@"系统占用cpu : %.2f%%",[RTDeviceInfo shareInstance].systemCpu]:@""}];
    NSString * wifiName = [RTDeviceDetailInfo wifiName];
    NSString * hint = @"";
    if (![wifiName isEqualToString:@"当前没有连接Wifi"]) {
        if (!TARGET_IPHONE_SIMULATOR) {
            hint = @"点击查看连接人数";
        }
    }
    [datas addObject:@{[NSString stringWithFormat:@"Wifi名称 : %@",wifiName]:hint}];
    [datas addObject:@{[NSString stringWithFormat:@"Wifi Ip : %@",[RTDeviceDetailInfo localWifiIpAddress]]:@""}];
    [datas addObject:@{[NSString stringWithFormat:@"Ip : %@",[RTDeviceDetailInfo deviceIpAddress]]:@""}];
    [datas addObject:@{[NSString stringWithFormat:@"DNS : %@",[RTDeviceDetailInfo domainNameSystemIp]]:@""}];
    [datas addObject:@{[NSString stringWithFormat:@"运营商 : %@",[RTDeviceDetailInfo telephonyCarrier]]:@""}];
    [datas addObject:@{[NSString stringWithFormat:@"网络类型 : %@",[RTDeviceDetailInfo networkType]]:@""}];
    
    __weak typeof(self)weakSelf=self;
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dic in datas) {
        NSString *key = [dic allKeys][0];
        NSString *value = [dic allValues][0];
        RTSettingItem *item1 = nil;
        if (value.length>0 && [value isEqualToString:@"点击查看连接人数"]) {
            item1 = [RTSettingItem itemWithIcon:@"" title:key subTitle:value type:ZFSettingItemTypeArrow];
            item1.operation = ^{
                [weakSelf.navigationController pushViewController:[RTWifiConnectionDevicesVC new] animated:YES];
            };
        }else{
            item1 = [RTSettingItem itemWithIcon:@"" title:key subTitle:value type:ZFSettingItemTypeNone];
        }
        item1.subTitleFontSize = 10;
        item1.subTitleColor = [UIColor redColor];
        [items addObject:item1];
    }
    RTSettingGroup *group1 = [[RTSettingGroup alloc] init];
    group1.header = @"手机设备信息";
    group1.items = items;
    [self.allGroups addObject:group1];
    [self.tableView reloadData];
}

@end
