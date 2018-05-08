
#import "RTBaseSettingViewController.h"
#import "RTSettingCell.h"
#import "AutoTestHeader.h"

@interface RTBaseSettingViewController ()
@property (nonatomic,strong)UILabel *emptylabel;
@end

@implementation RTBaseSettingViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _allGroups = [NSMutableArray array];
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
}

- (UILabel *)emptylabel{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.width, self.tableView.height - 64)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"无数据...";
    return label;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    if (_allGroups.count == 0) {
        self.tableView.tableFooterView = self.emptylabel;
    }else{
        self.tableView.tableFooterView = [UIView new];
    }
    return _allGroups.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    RTSettingGroup* group = _allGroups[section];
    return group.items.count;
}

#pragma mark 每当有一个cell进入视野范围内就会调用，返回当前这行显示的cell
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    // 取出这行对应的模型（RTSettingItem）
    RTSettingGroup* group = _allGroups[indexPath.section];
    RTSettingItem *item = group.items[indexPath.row];
    RTSettingCell* cell = [RTSettingCell settingCellWithTableView:tableView item:item];
    __block RTSettingCell* weakCell = cell;
    cell.switchChangeBlock = ^(BOOL on) {
        if (weakCell.item.switchBlock) {
            weakCell.item.switchBlock(on);
        }
    };
    return cell;
}

#pragma mark 点击了cell后的操作
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath{
    // 0.取出这行对应的模型
    RTSettingGroup* group = _allGroups[indexPath.section];
    RTSettingItem* item = group.items[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 1.取出这行对应模型中的block代码
    if (item.operation) {
        // 执行block
        item.operation();
    }
}

#pragma mark 返回每一组的header标题
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
    RTSettingGroup* group = _allGroups[section];
    return [NSString stringWithFormat:@"%@",group.header];
}
#pragma mark 返回每一组的footer标题
- (NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section{
    RTSettingGroup* group = _allGroups[section];
    return group.footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}

@end
