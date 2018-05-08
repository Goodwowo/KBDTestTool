
#import "RTAllRecordVC.h"
#import "RecordTestHeader.h"
#import "RTOperationsVC.h"
#import "RTPublicFooterButtonView.h"
#import "DXAlertView.h"
#import "RTMutableRunVC.h"

@interface RTAllRecordVC ()
@property (nonatomic,strong)UIView *headerView;
@property (nonatomic,assign)BOOL isEdit;
@end

@implementation RTAllRecordVC

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    self.headerView=[[RTPublicFooterButtonView new]publicFooterTwoButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 64) withLeftTitle:@"自动运行" withRightTitle:@"删除" withTarget:self withLeftSelector:@selector(run) withRightSelector:@selector(delete)];
    [self.tableView reloadData];
}

- (void)run{
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
    
    for (RTSettingGroup *group in self.allGroups) {
        for (RTSettingItem *item in group.items) {
            if (item.isSelect) {
                [[RTAutoRun shareInstance].autoRunQueue addObject:[item.identify copyNew]];
            }
        }
    }
    __weak typeof(self)weakSelf=self;
    RTMutableRunVC *vc = [RTMutableRunVC new];
    vc.block = ^{
        [[RTInteraction shareInstance] showAll];
        [weakSelf dismissViewControllerAnimated:NO completion:nil];
    };
    [self presentViewController:vc animated:YES completion:nil];
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
    
    NSString *title = @"是否删除选中的测试录制?";
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
            NSMutableArray *identifys = [NSMutableArray array];
            for (RTSettingItem *item in selects) {
                if (item.identify) {
                    [identifys addObject:item.identify];
                }
            }
            if(identifys.count>0){
                [RTOperationQueue deleteOperationQueues:identifys];
            }
            weakSelf.isEdit = NO;
            [weakSelf add0SectionItems];
            [weakSelf.tableView reloadData];
            weakSelf.headerView=[[RTPublicFooterButtonView new] publicFooterOneButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 64) withTitle:@"批量操作" withTarget:self withSelector:@selector(editAction)];
        }
    };
    [alertView show];
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

#pragma mark 添加第0组的模型数据
- (void)add0SectionItems
{
    __weak typeof(self)weakSelf=self;
    [self.allGroups removeAllObjects];
    NSArray *identifys = [RTOperationQueue allIdentifyModels];
    NSMutableArray *forVCs = [NSMutableArray array];
    for (RTIdentify *identify in identifys) {
        if (![forVCs containsObject:identify.forVC]) {
            [forVCs addObject:identify.forVC];
        }
    }
    
    for (NSString *vc in forVCs) {
        NSMutableArray *items = [NSMutableArray array];
        for (RTIdentify *identify in identifys) {
            if ([vc isEqualToString:identify.forVC]) {
                RTSettingItem *item = [RTSettingItem itemWithIcon:@"" title:identify.identify detail:identify.forVC type:ZFSettingItemTypeArrow];
                RTIdentify *copNew = [identify copyNew];
                __weak typeof(item)weakItem=item;
                item.operation = ^{
                    if (weakSelf.isEdit) {
                        weakItem.isSelect = !weakItem.isSelect;
                        weakSelf.headerView=[[RTPublicFooterButtonView new]publicFooterTwoButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 64) withLeftTitle:@"自动运行" withRightTitle:@"删除" withTarget:weakSelf withLeftSelector:@selector(run) withRightSelector:@selector(delete)];
                        [weakSelf.tableView reloadData];
                    }else{
                        RTOperationsVC *operationsVC = [RTOperationsVC new];
                        operationsVC.identify = copNew;
                        [weakSelf.navigationController pushViewController:operationsVC animated:YES];
                    }
                };
                item.identify = copNew;
                item.isEdit = NO;
                [items addObject:item];
            }
        }
        
        RTSettingGroup *group = [[RTSettingGroup alloc] init];
        group.header = vc;
        group.items = items;
        [self.allGroups addObject:group];
    }
}

#pragma mark 返回每一组的header标题
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
    RTSettingGroup* group = self.allGroups[section];
    return [NSString stringWithFormat:@"控制器:%@",group.header];
}

@end
