#import "RTCommandListVCViewController.h"
#import "RTCommandListVCTableViewCell.h"
#import "RTCommandList.h"
#import "ZHAlertAction.h"
#import "RecordTestHeader.h"
#import "RTPublicFooterButtonView.h"
#import "DXAlertView.h"
#import "RTMutableRunVC.h"

@interface RTCommandListVCViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,assign)BOOL isEdit;
@property (nonatomic,strong)UIView *headerView;
@end

@implementation RTCommandListVCViewController

- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr = [NSMutableArray array];
	}
	return _dataArr;
}

- (void)setHeaderView:(UIView *)headerView{
    BOOL isReplace=NO;
    if (_headerView) {
        [_headerView removeFromSuperview];
        isReplace = YES;
    }
    _headerView = headerView;
    if (headerView) {
        [self.view addSubview:headerView];
        self.tableView.contentInset = UIEdgeInsetsMake(headerView.height, 0, 64, 0);
        if (!isReplace) {
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, -headerView.height);
        }
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    }
}

- (void)viewDidLoad{
	[super viewDidLoad];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64) style:(UITableViewStylePlain)];
    [self.tableView registerClass:[RTCommandListVCTableViewCell class] forCellReuseIdentifier:@"RTCommandListVCTableViewCell"];
    [self.view addSubview:self.tableView];
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
	self.tableView.tableFooterView=[UIView new];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"批量" TintColor:[UIColor redColor] target:self action:@selector(editAction)];
    if ([RTCommandList shareInstance].isRunOperationQueue) {
        self.headerView=[[RTPublicFooterButtonView new] publicFooterOneButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 84) withTitle:@"停止" withTarget:self withSelector:@selector(stopAction)];
    }
    self.navigationController.navigationBar.translucent = NO;
    if (![RTCommandList shareInstance].isRunOperationQueue) {
        [self editAction];
    }
}

- (void)delete{
    BOOL isHaveSelect = NO;
    for (RTCommandListVCCellModel *model in self.dataArr) {
        if (model.isSelect) {
            isHaveSelect = YES;
        }
    }
    if(!isHaveSelect)return;
    
    NSString *title = @"";
    if ([RTCommandList shareInstance].isRunOperationQueue) title = @"是否删除选中的命令行? 删除就会停止执行过程!";
    else title = @"是否删除选中的测试录制?";
    DXAlertView *alertView = [[DXAlertView alloc] initWithTitle:@"提示" message:title cancelBtnTitle:@"取消" otherBtnTitle:@"确定"];
    alertView.block = ^(NSInteger index) {
        if (index == 1) {
            NSMutableArray *selects = [NSMutableArray array];
            for (RTCommandListVCCellModel *model in self.dataArr) {
                if (model.isSelect) {
                    [selects addObject:model];
                }
            }
            if ([RTCommandList shareInstance].isRunOperationQueue) {
                NSMutableArray *indexs = [NSMutableArray array];
                for (NSInteger i=0; i<self.dataArr.count; i++) {
                    RTCommandListVCCellModel *model = self.dataArr[i];
                    if (model.isSelect) {
                        [indexs addObject:[NSNumber numberWithInteger:i]];
                    }
                }
                if (indexs.count>0){
                    [RTOperationQueue deleteOperationQueueModelIndexs:indexs forIdentify:[RTCommandList shareInstance].operationQueueIdentify];
                    [[RTCommandList shareInstance] setOperationQueue:[RTCommandList shareInstance].operationQueueIdentify];
                    [self stopAction];
                }
            }else{
                NSMutableArray *identifys = [NSMutableArray array];
                for (RTCommandListVCCellModel *model in selects) {
                    if (model.identify) {
                        [identifys addObject:model.identify];
                    }
                }
                if(identifys.count>0){
                    [RTOperationQueue deleteOperationQueues:identifys];
                }
            }
            [self.dataArr removeObjectsInArray:selects];
            [self.tableView reloadData];
        }
    };
    [alertView show];
}

- (void)backAction{
    [self.nav.view removeFromSuperview];
    [self.nav removeFromParentViewController];
}

- (void)stopAction{
    [RTCommandList shareInstance].isRunOperationQueue = NO;
    [[RTCommandList shareInstance] initData];
    [self backAction];
}

- (void)run{
    BOOL isHaveSelect = NO;
    for (RTCommandListVCCellModel *model in self.dataArr) {
        if (model.isSelect) {
            isHaveSelect = YES;
        }
    }
    if(!isHaveSelect) return;
    for (RTCommandListVCCellModel *model in self.dataArr) {
        if (model.isSelect) {
            [[RTAutoRun shareInstance].autoRunQueue addObject:[model.identify copyNew]];
        }
    }
    [[RTAutoRun shareInstance] start];
    [self backAction];
}

- (void)allSelect{
    for (RTCommandListVCCellModel *model in self.dataArr) {
        model.isSelect = YES;
    }
    if ([RTCommandList shareInstance].isRunOperationQueue) {
        self.headerView=[[RTPublicFooterButtonView new] publicFooterOneButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 84) withTitle:@"删除" withTarget:self withSelector:@selector(delete)];
    }else{
        self.headerView=[[RTPublicFooterButtonView new]publicFooterTwoButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 84) withLeftTitle:@"自动运行" withRightTitle:@"删除" withTarget:self withLeftSelector:@selector(run) withRightSelector:@selector(delete)];
    }
    [self.tableView reloadData];
}

- (void)editAction{
    self.isEdit = !self.isEdit;
    for (RTCommandListVCCellModel *model in self.dataArr) {
        model.isShowSelect = self.isEdit;
        if (!self.isEdit) model.isSelect = NO;
    }
    if ([RTCommandList shareInstance].isRunOperationQueue) {
        if (self.isEdit) {
            self.headerView=[[RTPublicFooterButtonView new]publicFooterTwoButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 84) withLeftTitle:@"全选" withRightTitle:@"删除" withTarget:self withLeftSelector:@selector(allSelect) withRightSelector:@selector(delete)];
        }else{
            self.headerView=[[RTPublicFooterButtonView new] publicFooterOneButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 84) withTitle:@"停止" withTarget:self withSelector:@selector(stopAction)];
        }
    }else{
        if (self.isEdit) {
            self.headerView=[[RTPublicFooterButtonView new]publicFooterTwoButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 84) withLeftTitle:@"全选" withRightTitle:@"删除" withTarget:self withLeftSelector:@selector(allSelect) withRightSelector:@selector(delete)];
        }else{
            self.headerView=nil;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - TableViewDelegate实现的方法:
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	id modelObjct=self.dataArr[indexPath.row];
	if ([modelObjct isKindOfClass:[RTCommandListVCCellModel class]]){
		RTCommandListVCTableViewCell *rTCommandListVCCell=[tableView dequeueReusableCellWithIdentifier:@"RTCommandListVCTableViewCell"];
		RTCommandListVCCellModel *model=modelObjct;
		[rTCommandListVCCell refreshUI:model];
		return rTCommandListVCCell;
	}
	//随便给一个cell
	UITableViewCell *cell=[UITableViewCell new];
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	id modelObjct=self.dataArr[indexPath.row];
	if ([modelObjct isKindOfClass:[RTCommandListVCCellModel class]]){
		return 44.0f;
	}
	return 44.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    RTCommandListVCCellModel *model=self.dataArr[indexPath.row];
    if (self.isEdit) {
        model.isSelect = !model.isSelect;
        if ([RTCommandList shareInstance].isRunOperationQueue) {
            self.headerView=[[RTPublicFooterButtonView new] publicFooterOneButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 84) withTitle:@"删除" withTarget:self withSelector:@selector(delete)];
        }else{
            self.headerView=[[RTPublicFooterButtonView new]publicFooterTwoButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 84) withLeftTitle:@"自动运行" withRightTitle:@"删除" withTarget:self withLeftSelector:@selector(run) withRightSelector:@selector(delete)];
        }
        [self.tableView reloadData];
    }else{
        if (model.operationModel) {
            [RTCommandList shareInstance].curRow = indexPath.row;
        }else if (model.identify) {
            [[RTCommandList shareInstance]setOperationQueue:model.identify];
        }
        [self backAction];
    }
}

@end
