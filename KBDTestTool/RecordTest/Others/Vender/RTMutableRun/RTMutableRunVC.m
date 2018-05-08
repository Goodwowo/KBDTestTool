
#import "RTMutableRunVC.h"
#import "RecordTestHeader.h"
#import "RTPublicFooterButtonView.h"

@interface RTMutableRunModel : NSObject
@property (nonatomic,strong)RTIdentify *identify;
@property (nonatomic,assign)NSInteger count;
@end

@implementation RTMutableRunModel
@end

@interface RTMutableRunVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArr;
@end

@interface RTMutableRunTableViewCell : UITableViewCell
@property (nonatomic,strong)UILabel *hintLabel;
@property (nonatomic,strong)UILabel *countLabel;
@property (nonatomic,strong)UIStepper *stepper;
@property (nonatomic,weak)RTMutableRunModel *dataModel;
@end

@implementation RTMutableRunTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        self.hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 12, [UIScreen mainScreen].bounds.size.width - 160, 20)];
        self.hintLabel.textColor = [UIColor blackColor];
        self.hintLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.hintLabel];
        
        self.countLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.hintLabel.maxX+10, 12, 30, 20)];
        self.countLabel.textColor = [UIColor redColor];
        self.countLabel.textAlignment = NSTextAlignmentRight;
        self.countLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.countLabel];
        
        self.stepper = [[UIStepper alloc]initWithFrame:CGRectMake(self.countLabel.maxX+10, 7.5, 94, 29)];
        self.stepper.maximumValue = 500;
        self.stepper.minimumValue = 0;
        self.stepper.wraps = YES;
        [self.contentView addSubview:self.stepper];
        [self.stepper addTarget:self action:@selector(stepperAction:) forControlEvents:(UIControlEventValueChanged)];
    }
    return self;
}

- (void)stepperAction:(UIStepper *)stepper{
    self.dataModel.count = stepper.value;
    self.countLabel.text = [NSString stringWithFormat:@"%zd",self.dataModel.count];
}

- (void)refreshUI:(RTMutableRunModel *)dataModel{
    _dataModel = dataModel;
    self.hintLabel.text = [dataModel.identify debugDescription];
    self.countLabel.text = [NSString stringWithFormat:@"%zd",dataModel.count];
    self.stepper.value = dataModel.count;
}

@end

@interface RTMutableRunVC ()
@property (nonatomic,strong)UIView *headerView;
@end

@implementation RTMutableRunVC

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
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y-headerView.height);
        }
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    }
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr=[NSMutableArray array];
    }
    return _dataArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UITableView* tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [self initData];
    self.headerView=[[RTPublicFooterButtonView new]publicFooterTwoButtonViewWithFrame:CGRectMake(0, 0, self.view.width, 84) withLeftTitle:@"开始自动运行" withRightTitle:@"取消" withTarget:self withLeftSelector:@selector(run) withRightSelector:@selector(cancle)];
}

- (void)initData{
    NSArray *autoRunQueue = [RTAutoRun shareInstance].autoRunQueue;
    for (NSInteger i=0; i<autoRunQueue.count; i++) {
        RTIdentify *identify = autoRunQueue[i];
        RTIdentify *identifyNext = nil;
        NSInteger count = 1;
        while (i+1<autoRunQueue.count) {
            identifyNext = autoRunQueue[i+1];
            if ([[identifyNext description] isEqualToString:[identify description]]) {
                count ++;
                i++;
            }else break;
        }
        RTMutableRunModel *model = [RTMutableRunModel new];
        model.identify = identify;
        model.count = count;
        [self.dataArr addObject:model];
    }
}

- (void)emport{
    NSMutableArray *autoRunQueue = [NSMutableArray array];
    for (RTMutableRunModel *model in self.dataArr) {
        for (NSInteger i=0; i<model.count; i++) {
            [autoRunQueue addObject:[model.identify copyNew]];
        }
    }
    [[RTAutoRun shareInstance].autoRunQueue setArray:autoRunQueue];
}

- (void)run{
    [self emport];
    
    [[RTAutoRun shareInstance] start];
    
    [self dismissViewControllerAnimated:NO completion:^{
        self.block();
    }];
}

- (void)cancle{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

#pragma mark 每当有一个cell进入视野范围内就会调用，返回当前这行显示的cell
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    static NSString *cellIdtifier=@"RTMutableRunTableViewCell";
    RTMutableRunTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdtifier];
    if (!cell) {
        cell = [[RTMutableRunTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdtifier];
    }
    RTMutableRunModel *model = self.dataArr[indexPath.row];
    [cell refreshUI:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

@end
