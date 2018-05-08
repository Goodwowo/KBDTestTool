
#import "RTDeviceModel.h"
#import "RTMainPresenter.h"
#import "RTWifiConnectionDevicesVC.h"
#import "RecordTestHeader.h"
#import "TabBarAndNavagation.h"

@interface RTWifiConnectionDevicesVC () <RTMainPresenterDelegate>
@property (strong, nonatomic) RTMainPresenter* presenter;
@end

@implementation RTWifiConnectionDevicesVC

- (void)viewDidLoad{
    [super viewDidLoad];
    [self add0SectionItems];
    self.title = @"连接人数";
    [TabBarAndNavagation setRightBarButtonItemTitle:@"刷新" TintColor:[UIColor redColor] target:self action:@selector(refreshInfo)];

    self.presenter = [[RTMainPresenter alloc] initWithDelegate:self];
    [self scanButtonClicked];
    [self addObserversForKVO];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.title = [self.presenter ssidName];
}

- (void)refreshInfo{
    [self scanButtonClicked];
}

#pragma mark - KVO Observers
- (void)addObserversForKVO{
    [self.presenter addObserver:self forKeyPath:@"connectedDevices" options:NSKeyValueObservingOptionNew context:nil];
    [self.presenter addObserver:self forKeyPath:@"progressValue" options:NSKeyValueObservingOptionNew context:nil];
    [self.presenter addObserver:self forKeyPath:@"isScanRunning" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)scanButtonClicked{
    self.title = [self.presenter ssidName];
    [self.presenter scanButtonClicked];
}

#pragma mark - Presenter Delegates
- (void)mainPresenterIPSearchFinished{
    self.title = @"连接人数";
}

- (void)mainPresenterIPSearchFailed{
    self.title = @"扫描失败";
}

- (void)mainPresenterIPSearchCancelled{
    [self add0SectionItems];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context{
    if (object == self.presenter) {
        if ([keyPath isEqualToString:@"connectedDevices"]) {
            [self add0SectionItems];
        } else if ([keyPath isEqualToString:@"progressValue"]) {
            self.title = [NSString stringWithFormat:@"扫描进度:%.0f%%", self.presenter.progressValue * 100];
        } else if ([keyPath isEqualToString:@"isScanRunning"]) {
        }
    }
}

#pragma mark - Dealloc

- (void)dealloc{
    [self removeObserversForKVO];
}

- (void)removeObserversForKVO{
    [self.presenter removeObserver:self forKeyPath:@"connectedDevices"];
    [self.presenter removeObserver:self forKeyPath:@"progressValue"];
    [self.presenter removeObserver:self forKeyPath:@"isScanRunning"];
}

#pragma mark 添加第0组的模型数据
- (void)add0SectionItems{
    [self.allGroups removeAllObjects];
    NSMutableArray* items = [NSMutableArray array];
    for (NSInteger i = 0; i < self.presenter.connectedDevices.count; i++) {
        RTDeviceModel* nd = [self.presenter.connectedDevices objectAtIndex:i];
        if ([nd.ipAddress isEqualToString:@"192.168.0.1"]) {
            continue;
        }
        NSString* title = [NSString stringWithFormat:@"ip地址分配 : %@", nd.ipAddress];
        RTSettingItem* item1 = [RTSettingItem itemWithIcon:@"rt_wifi" title:title detail:nil type:ZFSettingItemTypeNone];
        [items addObject:item1];
    }

    RTSettingGroup* group1 = [[RTSettingGroup alloc] init];
    group1.items = items;
    group1.header = [NSString stringWithFormat:@"连接人数 : %zd", items.count];
    [self.allGroups addObject:group1];
    [self.tableView reloadData];
}

@end
