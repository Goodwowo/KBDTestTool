
#import "RTVCPerformanceVC.h"
#import "RecordTestHeader.h"
#import "RTVCDetailVC.h"

@implementation RTVCPerformanceVC

- (void)viewDidLoad{
    [super viewDidLoad];
    [self add0SectionItems];
    self.title = @"页面性能分析";
}

#pragma mark 添加第0组的模型数据
- (void)add0SectionItems{
    NSMutableDictionary *dic = [self sortArr:[[RTVCLearn shareInstance] traceVC]];
    NSArray *traceVC = [dic keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    NSMutableArray *vcs = [NSMutableArray array];
    for (NSString *vc in traceVC) {
        if ([RTVCLearn filter:vc] || [vcs containsObject:vc]) {
            continue;
        }
        [vcs addObject:vc];
    }
    __weak typeof(self)weakSelf=self;
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *vc in vcs) {
        NSString *title = [NSString stringWithFormat:@"%@",vc];
        NSString *subTitle = [NSString stringWithFormat:@"显示次数 %@次 累计显示 %@秒",dic[vc],@([RTVCDetailVC getShowTimes:vc])];
        RTSettingItem *item1 = [RTSettingItem itemWithIcon:@"" title:title detail:subTitle type:ZFSettingItemTypeArrow];
        item1.detailFontSize = 10;
        item1.operation = ^{
            RTVCDetailVC *detailVC = [RTVCDetailVC new];
            detailVC.vc = title;
            [weakSelf.navigationController pushViewController:detailVC animated:YES];
        };
        [items addObject:item1];
    }
    RTSettingGroup *group1 = [[RTSettingGroup alloc] init];
    group1.header = @"页面性能分析(按显示次数降序)";
    group1.items = items;
    [self.allGroups addObject:group1];
}

- (NSMutableDictionary *)sortArr:(NSArray *)arr{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (int i=0; i<arr.count; i++) {
        NSString *key = arr[i];
        NSNumber *value = [dic objectForKey:key];
        if (value) {
            value = @([value integerValue]+1);
        }else value = @(1);
        [dic setObject:value forKey:key];
    }
    return dic;
}

@end
