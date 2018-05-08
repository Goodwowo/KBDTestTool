
#import "RTVCDetailVC.h"
#import "RTChartView.h"
#import "RecordTestHeader.h"
#import "RTPerformanceAVGVC.h"

@interface RTVCDetailVC ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic,strong)NSArray *cupMonitor;
@property (nonatomic,strong)NSArray *meomeryMonitor;
@property (nonatomic,strong)NSArray *netMonitor;
@property (nonatomic,strong)NSArray *fpsMonitor;

@property (nonatomic, strong) RTChartLabel* label;
@property (nonatomic, strong) NSMutableString *textM;

@end

@implementation RTVCDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.vc;
    self.scrollView = [[UIScrollView alloc] initWithFrame: self.view.frame];
    [self.view addSubview:self.scrollView];
    self.view.backgroundColor = [UIColor colorWithRed:41/255.0 green:44/255.0 blue:49/255.0 alpha:1];
    self.maxHeight = 0;
    
    if ([RTConfigManager shareInstance].isShowCpu)[self getcpu];
    if ([RTConfigManager shareInstance].isShowMemory) [self getmeomery];
    if ([RTConfigManager shareInstance].isShowNetDelay) [self getnet];
    if ([RTConfigManager shareInstance].isShowFPS)[self getfps];
    [self addavg];
    if ([RTConfigManager shareInstance].isShowCpu)[self addcpu];
    if ([RTConfigManager shareInstance].isShowMemory) [self addmeomery];
    if ([RTConfigManager shareInstance].isShowNetDelay) [self addnet];
    if ([RTConfigManager shareInstance].isShowFPS)[self addfps];
    
    self.scrollView.contentSize = CGSizeMake(0, self.maxHeight+100);
}

+ (CGFloat)getShowTimes:(NSString *)target{
    CGFloat times = 0;
    NSArray *traceVC   = [[RTVCLearn shareInstance] traceVC];
    NSArray *tracePerformance = [[RTVCLearn shareInstance] tracePerformance];
    for (NSInteger i=0; i<traceVC.count; i++) {
        NSString *vc = traceVC[i];
        if (vc.length == target.length && [vc isEqualToString:target]) {
            if (i+1<tracePerformance.count) {
                NSInteger index = [tracePerformance[i] integerValue];
                NSInteger indexNext = [tracePerformance[i+1] integerValue];
                if (index == indexNext) {
                    times += 0.5;
                }else{
                    times += (indexNext - index);
                }
            }
        }
    }
    return times;
}

- (void)getcpu{
    NSArray *data      = [RTDeviceInfo shareInstance].cupMonitor;
    NSArray *traceVC   = [[RTVCLearn shareInstance] traceVC];
    NSArray *tracePerformance = [[RTVCLearn shareInstance] tracePerformance];
    NSMutableArray *cupMonitor = [NSMutableArray array];
    for (NSInteger i=0; i<traceVC.count; i++) {
        NSString *vc = traceVC[i];
        if (vc.length == self.vc.length && [vc isEqualToString:self.vc]) {
            if (i+1<tracePerformance.count) {
                NSInteger index = [tracePerformance[i] integerValue];
                NSInteger indexNext = [tracePerformance[i+1] integerValue];
                for (NSInteger j=index; j<indexNext; j++) {
                    NSInteger temp = j - [RTDeviceInfo shareInstance].minTime;
                    temp = labs(temp);
                    if(data.count>temp)[cupMonitor addObject:data[temp]];
                }
            }
        }
    }
    self.cupMonitor = cupMonitor;
}

- (void)getmeomery{
    NSArray *data      = [RTDeviceInfo shareInstance].memoryMonitor;
    NSArray *traceVC   = [[RTVCLearn shareInstance] traceVC];
    NSArray *tracePerformance = [[RTVCLearn shareInstance] tracePerformance];
    NSMutableArray *memoryMonitor = [NSMutableArray array];
    for (NSInteger i=0; i<traceVC.count; i++) {
        NSString *vc = traceVC[i];
        if (vc.length == self.vc.length && [vc isEqualToString:self.vc]) {
            if (i+1<tracePerformance.count) {
                NSInteger index = [tracePerformance[i] integerValue];
                NSInteger indexNext = [tracePerformance[i+1] integerValue];
                for (NSInteger j=index; j<indexNext; j++) {
                    NSInteger temp = j - [RTDeviceInfo shareInstance].minTime;
                    temp = labs(temp);
                    if(data.count>temp)[memoryMonitor addObject:data[temp]];
                }
            }
        }
    }
    self.meomeryMonitor = memoryMonitor;
}

- (void)getnet{
    NSArray *data      = [RTDeviceInfo shareInstance].netMonitor;
    NSArray *traceVC   = [[RTVCLearn shareInstance] traceVC];
    NSArray *tracePerformance = [[RTVCLearn shareInstance] tracePerformance];
    NSMutableArray *netMonitor = [NSMutableArray array];
    for (NSInteger i=0; i<traceVC.count; i++) {
        NSString *vc = traceVC[i];
        if (vc.length == self.vc.length && [vc isEqualToString:self.vc]) {
            if (i+1<tracePerformance.count) {
                NSInteger index = [tracePerformance[i] integerValue];
                NSInteger indexNext = [tracePerformance[i+1] integerValue];
                for (NSInteger j=index; j<indexNext; j++) {
                    NSInteger temp = j - [RTDeviceInfo shareInstance].minTime;
                    temp = labs(temp);
                    if(data.count>temp)[netMonitor addObject:data[temp]];
                }
            }
        }
    }
    self.netMonitor = netMonitor;
}

- (void)getfps{
    NSArray *data      = [RTDeviceInfo shareInstance].fpsMonitor;
    NSArray *traceVC   = [[RTVCLearn shareInstance] traceVC];
    NSArray *tracePerformance = [[RTVCLearn shareInstance] tracePerformance];
    NSMutableArray *fpsMonitor = [NSMutableArray array];
    for (NSInteger i=0; i<traceVC.count; i++) {
        NSString *vc = traceVC[i];
        if (vc.length == self.vc.length && [vc isEqualToString:self.vc]) {
            if (i+1<tracePerformance.count) {
                NSInteger index = [tracePerformance[i] integerValue];
                NSInteger indexNext = [tracePerformance[i+1] integerValue];
                for (NSInteger j=index; j<indexNext; j++) {
                    NSInteger temp = j - [RTDeviceInfo shareInstance].minTime;
                    temp = labs(temp);
                    if(data.count>temp)[fpsMonitor addObject:data[temp]];
                }
            }
        }
    }
    self.fpsMonitor = fpsMonitor;
}

- (void)addavg{
    self.textM = [NSMutableString string];
    if ([RTConfigManager shareInstance].isShowCpu)[self addcpuText];
    if ([RTConfigManager shareInstance].isShowMemory) [self addmeomeryText];
    if ([RTConfigManager shareInstance].isShowNetDelay) [self addnetText];
    if ([RTConfigManager shareInstance].isShowFPS)[self addfpsText];
    
    if (self.textM.length) {
        self.label = [[RTChartLabel alloc] initWithFrame:CGRectMake(20, 20 , self.view.width-40 , 100)];
        self.label.font = [UIFont boldSystemFontOfSize:14];
        self.label.numberOfLines = 0;
        self.label.textAlignment = NSTextAlignmentLeft;
        self.label.textColor = [UIColor redColor];
        [self.scrollView addSubview:self.label];
        self.label.text = self.textM;
        [self.label sizeToFit];
        self.maxHeight = CGRectGetMaxY(self.label.frame);
    }
}

- (void)addcpu{
    if (self.cupMonitor.count<=0)return;
    RTChartLabel* label = [[RTChartLabel alloc] initWithFrame:CGRectMake(10, self.maxHeight + 20 , 110 , 20)];
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
    view.unitX         = @"(共s)";
    view.showCount     = 100;
    view.lineColor     = [UIColor redColor];
    view.pointColor    = [UIColor orangeColor];
    view.yLabels       = self.cupMonitor;
    
    NSMutableArray *xLabels = [NSMutableArray arrayWithCapacity:view.yLabels.count];
    for (NSInteger i=0; i<view.yLabels.count; i++) {
        [xLabels addObject:[NSString stringWithFormat:@"%ld",i]];
    }
    view.xLabels       = xLabels;
    [view strokeChart];
    [self.scrollView addSubview:view];
    self.maxHeight = CGRectGetMaxY(view.frame);
}

- (void)addmeomery{
    if (self.meomeryMonitor.count<=0)return;
    RTChartLabel* label = [[RTChartLabel alloc] initWithFrame:CGRectMake(10, self.maxHeight + 20 , 110 , 20)];
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
    view.unitX         = @"(共s)";
    view.showCount     = 100;
    view.lineColor     = [UIColor redColor];
    view.pointColor    = [UIColor orangeColor];
    view.yLabels       = self.meomeryMonitor;
    NSMutableArray *xLabels = [NSMutableArray arrayWithCapacity:view.yLabels.count];
    for (NSInteger i=0; i<view.yLabels.count; i++) {
        [xLabels addObject:[NSString stringWithFormat:@"%ld",i]];
    }
    view.xLabels       = xLabels;
    [view strokeChart];
    [self.scrollView addSubview:view];
    self.maxHeight = CGRectGetMaxY(view.frame);
}

- (void)addnet{
    if (self.netMonitor.count<=0)return;
    RTChartLabel* label = [[RTChartLabel alloc] initWithFrame:CGRectMake(10, self.maxHeight + 20 , 110 , 20)];
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
    view.unitX         = @"(共s)";
    view.showCount     = 100;
    view.lineColor     = [UIColor redColor];
    view.pointColor    = [UIColor orangeColor];
    view.yLabels       = self.netMonitor;
    NSMutableArray *xLabels = [NSMutableArray arrayWithCapacity:view.yLabels.count];
    for (NSInteger i=0; i<view.yLabels.count; i++) {
        [xLabels addObject:[NSString stringWithFormat:@"%ld",i]];
    }
    view.xLabels       = xLabels;
    [view strokeChart];
    [self.scrollView addSubview:view];
    self.maxHeight = CGRectGetMaxY(view.frame);
}

- (void)addfps{
    if (self.fpsMonitor.count<=0)return;
    RTChartLabel* label = [[RTChartLabel alloc] initWithFrame:CGRectMake(10, self.maxHeight + 20 , 110 , 20)];
    label.text = @"FPS";
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:label];
    
    RTChartView *view = [[RTChartView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(label.frame) + 10, self.view.frame.size.width-20, 200)];
    view.isdrawLine    = YES;
    view.isDrawPoint   = NO;
    view.isShadow      = YES;
    view.unit          = @"";
    view.unitX         = @"(共s)";
    view.showCount     = 100;
    view.lineColor     = [UIColor redColor];
    view.pointColor    = [UIColor orangeColor];
    view.yLabels       = self.fpsMonitor;
    NSMutableArray *xLabels = [NSMutableArray arrayWithCapacity:view.yLabels.count];
    for (NSInteger i=0; i<view.yLabels.count; i++) {
        [xLabels addObject:[NSString stringWithFormat:@"%ld",i]];
    }
    view.xLabels       = xLabels;
    [view strokeChart];
    [self.scrollView addSubview:view];
    self.maxHeight = CGRectGetMaxY(view.frame);
}

- (void)addcpuText{
    NSArray *values = self.cupMonitor;
    if(values.count<=0)return;
    CGFloat sum = 0;
    CGFloat min = 1000000;
    CGFloat max = 0;
    CGFloat avg = 0;
    
    for (NSInteger i=0; i<self.cupMonitor.count; i++) {
        NSInteger index = i;
        if (index >=0 && values.count > index) {
            float value = [values[index] floatValue];
            sum += value;
            if(value<min)min = value;
            if(value>max)max = value;
        }
    }
    float divisor = self.cupMonitor.count;
    avg = sum/divisor;
    [self.textM appendFormat:@"CPU 最小值:%0.1f 最大值:%0.1f 平均值:%0.1f\n",min,max,avg];
}

- (void)addmeomeryText{
    NSArray *values = self.meomeryMonitor;
    if(values.count<=0)return;
    CGFloat sum = 0;
    CGFloat min = 1000000;
    CGFloat max = 0;
    CGFloat avg = 0;
    
    for (NSInteger i=0; i<self.meomeryMonitor.count; i++) {
        NSInteger index = i;
        if (index >=0 && values.count > index) {
            float value = [values[index] floatValue];
            sum += value;
            if(value<min)min = value;
            if(value>max)max = value;
        }
    }
    float divisor = self.meomeryMonitor.count;
    avg = sum/divisor;
    [self.textM appendFormat:@"内存 最小值:%0.1f 最大值:%0.1f 平均值:%0.1f\n",min,max,avg];
}

- (void)addnetText{
    NSArray *values = self.netMonitor;
    if(values.count<=0)return;
    CGFloat sum = 0;
    CGFloat min = 1000000;
    CGFloat max = 0;
    CGFloat avg = 0;
    
    for (NSInteger i=0; i<self.netMonitor.count; i++) {
        NSInteger index = i;
        if (index >=0 && values.count > index) {
            float value = [values[index] floatValue];
            sum += value;
            if(value<min)min = value;
            if(value>max)max = value;
        }
    }
    float divisor = self.netMonitor.count;
    avg = sum/divisor;
    [self.textM appendFormat:@"网络延迟 最小值:%0.1f 最大值:%0.1f 平均值:%0.1f\n",min,max,avg];
}

- (void)addfpsText{
    NSArray *values = self.fpsMonitor;
    if(values.count<=0)return;
    CGFloat sum = 0;
    CGFloat min = 1000000;
    CGFloat max = 0;
    CGFloat avg = 0;
    
    for (NSInteger i=0; i<self.fpsMonitor.count; i++) {
        NSInteger index = i;
        if (index >=0 && values.count > index) {
            float value = [values[index] floatValue];
            sum += value;
            if(value<min)min = value;
            if(value>max)max = value;
        }
    }
    float divisor = self.fpsMonitor.count;
    avg = sum/divisor;
    [self.textM appendFormat:@"FPS 最小值:%0.1f 最大值:%0.1f 平均值:%0.1f\n",min,max,avg];
}

@end
