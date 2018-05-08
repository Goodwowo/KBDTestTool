
#import "RTTraceListVC.h"
#import "RecordTestHeader.h"
@implementation RTTraceListVC

- (void)viewDidLoad{
    [super viewDidLoad];
    [self add0SectionItems];
    self.title = @"控制器轨迹";
}

#pragma mark 添加第0组的模型数据
- (void)add0SectionItems{
    
    NSArray *traceVC = [[RTVCLearn shareInstance] traceVC];
    NSArray *traceMemory = [[RTVCLearn shareInstance] traceMemory];
    NSMutableArray *items = [NSMutableArray array];
    NSInteger index = 1;
    NSInteger cur = 0;
    NSString *lastVC = nil;
    for (NSString *vc in traceVC) {
        NSString *subTitle = nil;
        if (traceMemory.count > cur+1) {
            subTitle = traceMemory[cur+1];
        }
        cur ++;
        if ([RTVCLearn filter:vc]) {
            continue;
        }
        if (lastVC && lastVC.length == vc.length && [lastVC isEqualToString:vc]) {
            continue;
        }
        NSString *title = [NSString stringWithFormat:@"%zd : %@",index++,vc];
        RTSettingItem *item1 = [RTSettingItem itemWithIcon:@"" title:title subTitle:subTitle type:ZFSettingItemTypeNone];
        item1.subTitleFontSize = 10;
        [items addObject:item1];
        lastVC = vc;
    }
    [items reverse];
    RTSettingGroup *group1 = [[RTSettingGroup alloc] init];
    group1.header = @"控制器轨迹";
    group1.items = items;
    [self.allGroups addObject:group1];
}

@end
