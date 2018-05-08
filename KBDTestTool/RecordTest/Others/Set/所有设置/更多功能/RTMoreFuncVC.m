
#import "RTMoreFuncVC.h"
#import "RecordTestHeader.h"
#import "AutoTestProject.h"
#import "RTUnionListVC.h"
#import "RTTraceListVC.h"
#import "RTPerformanceVC.h"
#import "RTVCPerformanceVC.h"
#import "RTDeviceInfoVC.h"
#import "RTLagVC.h"
#import "RTCrashCollectionVC.h"
#import "RTTextPreVC.h"
#import "RTNetResult.h"

@implementation RTMoreFuncVC

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
    RTSettingItem *item1 = [RTSettingItem itemWithIcon:@"" title:@"开始自动(Monkey)测试" subTitle:nil type:ZFSettingItemTypeArrow];
    item1.subTitleFontSize = 10;
    item1.operation = ^{
        [[RTInteraction shareInstance] hideAll];
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:@"开始Monkey测试!"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[AutoTestProject shareInstance] autoTest];
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
        });
    };
    
    RTSettingItem *item2 = [RTSettingItem itemWithIcon:@"" title:@"控制器轨迹" subTitle:nil type:ZFSettingItemTypeArrow];
    item2.subTitleFontSize = 10;
    item2.operation = ^{
        [weakSelf.navigationController pushViewController:[RTTraceListVC new] animated:YES];
    };
    
    RTSettingItem *item3 = [RTSettingItem itemWithIcon:@"" title:@"并存控制器" subTitle:nil type:ZFSettingItemTypeArrow];
    item3.subTitleFontSize = 10;
    item3.operation = ^{
        [weakSelf.navigationController pushViewController:[RTUnionListVC new] animated:YES];
    };
    
    RTSettingItem *item4 = [RTSettingItem itemWithIcon:@"" title:@"操作轨迹" subTitle:nil type:ZFSettingItemTypeArrow];
    item4.subTitleFontSize = 10;
    item4.operation = ^{
        RTTextPreVC *statck_vc = [RTTextPreVC new];
        statck_vc.text = [[RTSearchVCPath shareInstance] traceOperation];
        statck_vc.title = @"操作轨迹";
        [weakSelf.navigationController pushViewController:statck_vc animated:YES];
    };
    
    NSMutableArray *items = [NSMutableArray array];
    [items addObjectsFromArray:@[item1,item2,item3,item4]];
    if ([RTConfigManager shareInstance].isShowCpu || [RTConfigManager shareInstance].isShowFPS ||
        [RTConfigManager shareInstance].isShowMemory || [RTConfigManager shareInstance].isShowNetDelay
        ) {
        RTSettingItem *item5 = [RTSettingItem itemWithIcon:@"" title:@"性能数据收集展示" subTitle:nil type:ZFSettingItemTypeArrow];
        item5.subTitleFontSize = 10;
        item5.operation = ^{
            [weakSelf.navigationController pushViewController:[RTPerformanceVC new] animated:YES];
        };
        [items addObject:item5];
    }
    
    RTSettingItem *item6 = [RTSettingItem itemWithIcon:@"" title:@"页面性能分析" subTitle:nil type:ZFSettingItemTypeArrow];
    item6.subTitleFontSize = 10;
    item6.operation = ^{
        [weakSelf.navigationController pushViewController:[RTVCPerformanceVC new] animated:YES];
    };
    
    RTSettingItem *item6_1 = [RTSettingItem itemWithIcon:@"" title:@"卡顿分析" subTitle:nil type:ZFSettingItemTypeArrow];
    item6_1.subTitleFontSize = 10;
    item6_1.operation = ^{
        [weakSelf.navigationController pushViewController:[RTLagVC new] animated:YES];
    };
    
    RTSettingItem *item6_2 = [RTSettingItem itemWithIcon:@"" title:@"崩溃收集" subTitle:nil type:ZFSettingItemTypeArrow];
    item6_2.subTitleFontSize = 10;
    item6_2.operation = ^{
        [weakSelf.navigationController pushViewController:[RTCrashCollectionVC new] animated:YES];
    };
    
    [items addObjectsFromArray:@[item6,item6_1,item6_2]];
    
    RTSettingItem *item6_3 = [RTSettingItem itemWithIcon:@"" title:@"网络性能" subTitle:nil type:ZFSettingItemTypeArrow];
    item6_3.subTitleFontSize = 10;
    item6_3.operation = ^{
        RTTextPreVC *statck_vc = [RTTextPreVC new];
        statck_vc.text = [[[RTNetResult shareInstance] getNetResultsAndClear] componentsJoinedByString:@"\n\n"];
        statck_vc.title = @"网络性能";
        [weakSelf.navigationController pushViewController:statck_vc animated:YES];
    };
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10) {
        [items addObjectsFromArray:@[item6_3]];
    }
    
    RTSettingItem *item7 = [RTSettingItem itemWithIcon:@"" title:@"手机设备信息" subTitle:nil type:ZFSettingItemTypeArrow];
    item7.subTitleFontSize = 10;
    item7.operation = ^{
        [weakSelf.navigationController pushViewController:[RTDeviceInfoVC new] animated:YES];
    };
    [items addObjectsFromArray:@[item7]];
    
    RTSettingGroup *group1 = [[RTSettingGroup alloc] init];
    group1.header = @"更多功能";
    group1.items = items;
    [self.allGroups addObject:group1];
}

@end
