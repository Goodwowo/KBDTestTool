
#import "RTCrashCollectionVC.h"
#import "RecordTestHeader.h"
#import "RTCrashLagIndexVC.h"
#import "RTCrashLag.h"

@implementation RTCrashCollectionVC

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"崩溃收集";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self add0SectionItems];
}

#pragma mark 添加第0组的模型数据
- (void)add0SectionItems{
    [self.allGroups removeAllObjects];
    NSDictionary *crashs = [[RTCrashLag shareInstance] crashs];
    __weak typeof(self)weakSelf=self;
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *stamp in crashs) {
        NSString *title = stamp;
        RTCrashModel *model = crashs[stamp];
        if (model.crashStack.length<=0) {
            [[RTCrashLag shareInstance] removeLag:stamp];
            continue;
        }
        RTSettingItem *item1 = [RTSettingItem itemWithIcon:@"" title:title detail:nil type:ZFSettingItemTypeArrow];
        item1.detailFontSize = 10;
        item1.operation = ^{
            [weakSelf openTextVC:stamp];
        };
        [items addObject:item1];
    }
    [items sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        RTSettingItem *item1 = obj1;
        RTSettingItem *item2 = obj2;
        return [item2.title compare:item1.title];
    }];
    RTSettingGroup *group1 = [[RTSettingGroup alloc] init];
    group1.header = @"崩溃(按时间降序)";
    group1.items = items;
    [self.allGroups addObject:group1];
    [self.tableView reloadData];
}

- (void)openTextVC:(NSString *)stamp{
    NSDictionary *crashs = [[RTCrashLag shareInstance] crashs];
    RTCrashLagIndexVC *detailVC = [RTCrashLagIndexVC new];
    detailVC.isCrash = YES;
    RTCrashModel *model = crashs[stamp];
    detailVC.text = model.crashStack;
    detailVC.stamp = stamp;
    detailVC.imageName = model.imagePath;
    detailVC.vcStack = model.vcStack;
    detailVC.operationStack = model.operationStack;
    if (detailVC.text.length>0) {
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}
@end
