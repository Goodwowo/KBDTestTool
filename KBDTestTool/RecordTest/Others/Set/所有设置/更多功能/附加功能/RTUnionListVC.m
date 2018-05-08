
#import "RTUnionListVC.h"
#import "RecordTestHeader.h"

@implementation RTUnionListVC

- (void)viewDidLoad{
    [super viewDidLoad];
    [self add0SectionItems];
    self.title = @"并存控制器";
}

#pragma mark 添加第0组的模型数据
- (void)add0SectionItems{
    NSMutableArray *noRepeat = [[NSMutableArray alloc]init];
    NSArray *traceVC = [[RTVCLearn shareInstance] unionVC];
    for (NSArray *subArr in traceVC) {
        //去重
        NSMutableArray *listAry = [[NSMutableArray alloc]init];
        for (NSString *str in subArr) if (![listAry containsObject:str]) [listAry addObject:str];
        NSString *traceVCs = [listAry componentsJoinedByString:@" "];
        if (![noRepeat containsObject:traceVCs]) [noRepeat addObject:traceVCs];
        else continue;
        
        NSMutableArray *items = [NSMutableArray array];
        for (NSString *vc in listAry) {
            if ([RTVCLearn filter:vc]) {
                continue;
            }
            NSString *title = [NSString stringWithFormat:@"%@",vc];
            RTSettingItem *item1 = [RTSettingItem itemWithIcon:@"" title:title subTitle:nil type:ZFSettingItemTypeNone];
            item1.subTitleFontSize = 10;
            [items addObject:item1];
        }
        if(items.count<=1)continue;
        
        RTSettingGroup *group1 = [[RTSettingGroup alloc] init];
        group1.header = @"并存控制器";
        group1.items = items;
        [self.allGroups addObject:group1];
    }
}

@end
