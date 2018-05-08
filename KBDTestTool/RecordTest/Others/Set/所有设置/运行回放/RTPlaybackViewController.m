
#import "RTPlaybackViewController.h"
#import "RecordTestHeader.h"
#import "RTPlayBackVC.h"
#import "RTPublicFooterButtonView.h"
#import "DXAlertView.h"

@interface RTPlaybackViewController ()
@property (nonatomic,strong)NSMutableDictionary *sortDic;
@property (nonatomic,strong)UIView *headerView;
@property (nonatomic,assign)BOOL isEdit;
@end

@implementation RTPlaybackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self autoDeleteOverDate];
    self.sortDic = [NSMutableDictionary dictionary];
    [self add0SectionItems];
    
    if (self.allGroups.count>0) {
        self.headerView=[[RTPublicFooterButtonView new] publicFooterOneButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 64) withTitle:@"批量操作" withTarget:self withSelector:@selector(editAction)];
    }
}

- (void)editAction{
    for (RTSettingGroup *group in self.allGroups) {
        for (RTSettingItem *item in group.items) {
            item.isSelect = NO;
            item.isEdit = YES;
        }
    }
    self.headerView=[[RTPublicFooterButtonView new]publicFooterTwoButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 64) withLeftTitle:@"全选" withRightTitle:@"删除" withTarget:self withLeftSelector:@selector(allSelect) withRightSelector:@selector(delete)];
    self.isEdit = YES;
    [self.tableView reloadData];
}

- (void)allSelect{
    for (RTSettingGroup *group in self.allGroups) {
        for (RTSettingItem *item in group.items) {
            item.isSelect = YES;
        }
    }
    [self.tableView reloadData];
}

- (void)setHeaderView:(UIView *)headerView{
    if (_headerView) {
        [_headerView removeFromSuperview];
    }
    _headerView = headerView;
    if (headerView) {
        [self.view addSubview:headerView];
        self.tableView.contentInset = UIEdgeInsetsMake(headerView.height, 0, headerView.height, 0);
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    }
}

- (void)delete{
    BOOL isHaveSelect = NO;
    for (RTSettingGroup *group in self.allGroups) {
        for (RTSettingItem *item in group.items) {
            if (item.isSelect) {
                isHaveSelect = YES;
                break;
            }
        }
    }
    if(!isHaveSelect)return;
    
    NSString *title = @"是否删除选中的运行回放?";
    DXAlertView *alertView = [[DXAlertView alloc] initWithTitle:@"提示" message:title cancelBtnTitle:@"取消" otherBtnTitle:@"确定"];
    __weak typeof(self)weakSelf=self;
    alertView.block = ^(NSInteger index) {
        if (index == 1) {
            NSMutableArray *selects = [NSMutableArray array];
            for (RTSettingGroup *group in weakSelf.allGroups) {
                for (RTSettingItem *item in group.items) {
                    if (item.isSelect) {
                        [selects addObject:item];
                    }
                }
            }
            NSMutableArray *stamps = [NSMutableArray array];
            for (RTSettingItem *item in selects) {
                if (item.stamp) {
                    [stamps addObject:item.stamp];
                }
            }
            if(stamps.count>0){
                [[RTPlayBack shareInstance] deletePlayBacks:stamps];
            }
            weakSelf.isEdit = NO;
            [weakSelf add0SectionItems];
            [weakSelf.tableView reloadData];
            weakSelf.headerView=[[RTPublicFooterButtonView new] publicFooterOneButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 64) withTitle:@"批量操作" withTarget:self withSelector:@selector(editAction)];
        }
    };
    [alertView show];
}

#pragma mark 添加第0组的模型数据
- (void)add0SectionItems
{
    [self.allGroups removeAllObjects];
    NSDictionary *playBacks = [[RTPlayBack shareInstance] playBacks];
    NSMutableDictionary *stampDic = [NSMutableDictionary dictionary];
    for (NSString *stamp in playBacks) {
        NSString *compareTime = [self compareCurrentTime:stamp];
        NSMutableArray *playBackModels = stampDic[compareTime];
        if(!playBackModels) playBackModels = [NSMutableArray array];
        [playBackModels addObject:stamp];
        stampDic[compareTime] = playBackModels;
    }
    __weak typeof(self)weakSelf=self;
    for (NSString *compareTime in stampDic) {
        NSArray *sections = stampDic[compareTime];
        NSMutableArray *items = [NSMutableArray array];
        for (NSString *stamp in sections) {
            NSDictionary *value = playBacks[stamp];
            if (value.count>0) {
                NSString *identifyString = [value allKeys][0];
                RTIdentify *identify = [[RTIdentify alloc]initWithIdentify:identifyString];
                NSArray *playBackModels = value[identifyString];
                RTSettingItem *item = [RTSettingItem itemWithIcon:@"" title:[identify debugDescription] detail:nil type:ZFSettingItemTypeArrow];
                __weak typeof(item)weakItem=item;
                item.operation = ^{
                    if (weakSelf.isEdit) {
                        weakItem.isSelect = !weakItem.isSelect;
                        [weakSelf.tableView reloadData];
                    }else{
                        RTPlayBackVC *playBackVC = [RTPlayBackVC new];
                        playBackVC.identify = identify;
                        playBackVC.stamp = stamp;
                        playBackVC.playBackModels = playBackModels;
                        [self.navigationController pushViewController:playBackVC animated:YES];
                    }
                };
                BOOL isRunSuccess = YES;
                for (RTOperationQueueModel *model in playBackModels){
                    if(model.runResult != RTOperationQueueRunResultTypeSuccess){isRunSuccess = NO; break;}
                }
                if (isRunSuccess) {
                    item.titleColor = [UIColor greenColor];
                }else{
                    item.titleColor = [UIColor redColor];
                }
                item.stamp = stamp;
                [items addObject:item];
            }
        }
        RTSettingGroup *group = [[RTSettingGroup alloc] init];
        group.header = compareTime;
        group.items = items;
        group.sort = [self.sortDic[compareTime] integerValue];
        [self.allGroups addObject:group];
    }
    [self.allGroups sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        RTSettingGroup *group1 = obj1;
        RTSettingGroup *group2 = obj2;
        return group1.sort < group2.sort;;
    }];
}

- (NSString *)compareCurrentTime:(NSString *)stamp{
    NSTimeInterval timeInterval = [DateTools getCurInterval] - [stamp longLongValue];
    long temp = 0;
    NSString *result;
    if (timeInterval/60 <= 10){
        result = [NSString stringWithFormat:@"刚刚 (10分钟内)"];
    }else if(timeInterval/60 <= 30){
        result = [NSString stringWithFormat:@"30分钟内"];
    }else if((temp = timeInterval/60) <=60){
        result = [NSString stringWithFormat:@"1小时内"];
    }else if((temp = temp/60) <= 6){
        result = [NSString stringWithFormat:@"6小时内"];
    }else if(temp <= 12){
        result = [NSString stringWithFormat:@"12小时内"];
    }else if(temp <= 24){
        result = [NSString stringWithFormat:@"1天内"];
    }else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld天前",temp];
    }else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld月前",temp];
    }else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld年前",temp];
    }
    [self.sortDic setValue:stamp forKey:result];
    return  result;
}


- (BOOL)isOverDate:(NSString *)stamp{
    NSTimeInterval timeInterval = [DateTools getCurInterval] - [stamp longLongValue];
    timeInterval /=(3600*24);
    if ([RTConfigManager shareInstance].autoDeleteDay < 0) {
        return NO;
    }
    if(timeInterval > [RTConfigManager shareInstance].autoDeleteDay){
        return YES;
    }
    return NO;
}

- (void)autoDeleteOverDate{
    if ([RTConfigManager shareInstance].isAutoDelete) {
        NSDictionary *playBacks = [[RTPlayBack shareInstance] playBacks];
        NSMutableArray *stamps = [NSMutableArray array];
        for (NSString *stamp in playBacks) {
            if ([self isOverDate:stamp]) {
                [stamps addObject:stamp];
            }
        }
        if(stamps.count>0){
            [[RTPlayBack shareInstance] deletePlayBacks:stamps];
        }
    }
}

@end
