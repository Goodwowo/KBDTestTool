
#import "RTPerformanceVC.h"
#import "RTChartView.h"
#import "RecordTestHeader.h"
#import "RTPerformanceAVGVC.h"

@interface RTPerformanceVC ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic,assign)CGFloat maxHeight;

@end

@implementation RTPerformanceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [TabBarAndNavagation setRightBarButtonItemTitle:@"查看平均" TintColor:[UIColor redColor] target:self action:@selector(export)];
    
    self.title = @"性能数据展示(1小时内)";
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.scrollView];
    self.view.backgroundColor = [UIColor colorWithRed:41/255.0 green:44/255.0 blue:49/255.0 alpha:1];
    self.maxHeight = 0;
    
    if ([RTConfigManager shareInstance].isShowCpu)[self addcpu];
    if ([RTConfigManager shareInstance].isShowMemory) [self addmeomery];
    if ([RTConfigManager shareInstance].isShowNetDelay) [self addnet];
    if ([RTConfigManager shareInstance].isShowFPS)[self addfps];
    
    self.scrollView.contentSize = CGSizeMake(0, self.maxHeight+100);
}

- (void)export{
    RTPerformanceAVGVC *vc = [RTPerformanceAVGVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addcpu{
    RTChartLabel* label = [[RTChartLabel alloc] initWithFrame:CGRectMake(10, self.maxHeight + 20 , 100 , 20)];
    label.text = @"CPU";
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:label];
    
    RTChartView *view = [[RTChartView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(label.frame) + 10,  self.view.frame.size.width-20, 200)];
    view.isdrawLine    = YES;
    view.isDrawPoint   = NO;
    view.isShadow      = YES;
    view.unit          = @"%";
    view.unitX         = @"(s)";
    view.showCount     = 100;
    view.lineColor     = [UIColor redColor];
    view.pointColor    = [UIColor orangeColor];
    view.yLabels       = [RTDeviceInfo shareInstance].cupMonitor;
    NSMutableArray *xLabels = [NSMutableArray arrayWithCapacity:view.yLabels.count];
    for (NSInteger i=0; i<view.yLabels.count; i++) {
        [xLabels addObject:[NSString stringWithFormat:@"%ld",i+[RTDeviceInfo shareInstance].minTime]];
    }
    view.xLabels       = xLabels;
    [view strokeChart];
    [self.scrollView addSubview:view];
    self.maxHeight = CGRectGetMaxY(view.frame);
}

- (void)addmeomery{
    RTChartLabel* label = [[RTChartLabel alloc] initWithFrame:CGRectMake(10, self.maxHeight + 20 , 100 , 20)];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.text = @"内存(MB)";
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:label];
    
    RTChartView *view = [[RTChartView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(label.frame) + 10,  self.view.frame.size.width-20, 200)];
    view.isdrawLine    = YES;
    view.isDrawPoint   = NO;
    view.isShadow      = YES;
    view.unit          = @"";
    view.unitX         = @"(s)";
    view.showCount     = 100;
    view.lineColor     = [UIColor redColor];
    view.pointColor    = [UIColor orangeColor];
    view.yLabels       = [RTDeviceInfo shareInstance].memoryMonitor;
    NSMutableArray *xLabels = [NSMutableArray arrayWithCapacity:view.yLabels.count];
    for (NSInteger i=0; i<view.yLabels.count; i++) {
        [xLabels addObject:[NSString stringWithFormat:@"%ld",i+[RTDeviceInfo shareInstance].minTime]];
    }
    view.xLabels       = xLabels;
    [view strokeChart];
    [self.scrollView addSubview:view];
    self.maxHeight = CGRectGetMaxY(view.frame);
}

- (void)addnet{
    RTChartLabel* label = [[RTChartLabel alloc] initWithFrame:CGRectMake(10, self.maxHeight + 20 , 100 , 20)];
    label.text = @"网络延迟(ms)";
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:label];
    
    RTChartView *view = [[RTChartView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(label.frame) + 10,  self.view.frame.size.width-20, 200)];
    view.isdrawLine    = YES;
    view.isDrawPoint   = NO;
    view.isShadow      = YES;
    view.unit          = @"";
    view.unitX         = @"(s)";
    view.showCount     = 100;
    view.lineColor     = [UIColor redColor];
    view.pointColor    = [UIColor orangeColor];
    view.yLabels       = [RTDeviceInfo shareInstance].netMonitor;
    NSMutableArray *xLabels = [NSMutableArray arrayWithCapacity:view.yLabels.count];
    for (NSInteger i=0; i<view.yLabels.count; i++) {
        [xLabels addObject:[NSString stringWithFormat:@"%ld",i+[RTDeviceInfo shareInstance].minTime]];
    }
    view.xLabels       = xLabels;
    [view strokeChart];
    [self.scrollView addSubview:view];
    self.maxHeight = CGRectGetMaxY(view.frame);
}

- (void)addfps{
    RTChartLabel* label = [[RTChartLabel alloc] initWithFrame:CGRectMake(10, self.maxHeight + 20 , 100 , 20)];
    label.text = @"FPS";
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:label];
    
    RTChartView *view = [[RTChartView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(label.frame) + 10,  self.view.frame.size.width-20, 200)];
    view.isdrawLine    = YES;
    view.isDrawPoint   = NO;
    view.isShadow      = YES;
    view.unit          = @"";
    view.unitX         = @"(s)";
    view.showCount     = 100;
    view.lineColor     = [UIColor redColor];
    view.pointColor    = [UIColor orangeColor];
    view.yLabels       = [RTDeviceInfo shareInstance].fpsMonitor;
    NSMutableArray *xLabels = [NSMutableArray arrayWithCapacity:view.yLabels.count];
    for (NSInteger i=0; i<view.yLabels.count; i++) {
        [xLabels addObject:[NSString stringWithFormat:@"%ld",i+[RTDeviceInfo shareInstance].minTime]];
    }
    view.xLabels       = xLabels;
    [view strokeChart];
    [self.scrollView addSubview:view];
    self.maxHeight = CGRectGetMaxY(view.frame);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
