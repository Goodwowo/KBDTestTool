
#import "RTPerformanceAVGVC.h"
#import "RecordTestHeader.h"
#import "RTRangeSlider.h"
#import "RTChartView.h"

@interface RTPerformanceAVGVC ()
@property (nonatomic, strong) RTRangeSlider *rangeSlider;
@property (nonatomic, strong) RTChartLabel* label;
@property (nonatomic, strong) NSMutableString *textM;
@end

@implementation RTPerformanceAVGVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"平均";
    self.view.backgroundColor = [UIColor colorWithRed:41/255.0 green:44/255.0 blue:49/255.0 alpha:1];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"查询" TintColor:[UIColor redColor] target:self action:@selector(avgAction)];
    
    self.minValue = [RTDeviceInfo shareInstance].minTime;
    self.maxValue = [RTDeviceInfo shareInstance].cupMonitor.count + self.minValue;
    self.rangeSlider = [[RTRangeSlider alloc]initWithFrame:CGRectMake(20, 40, self.view.width-40, 60)];
    self.rangeSlider.minValue = self.minValue;
    self.rangeSlider.maxValue = self.maxValue;
    self.rangeSlider.selectedMinimum = self.minValue;
    self.rangeSlider.selectedMaximum = self.maxValue;
    NSNumberFormatter *customFormatter = [[NSNumberFormatter alloc] init];
    customFormatter.positiveSuffix = @"s";
    self.rangeSlider.numberFormatterOverride = customFormatter;
    [self.view addSubview:self.rangeSlider];
    
    self.label = [[RTChartLabel alloc] initWithFrame:CGRectMake(20, 100 + 20 , self.view.width-40 , 100)];
    self.label.font = [UIFont boldSystemFontOfSize:14];
    self.label.numberOfLines = 0;
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.textColor = [UIColor whiteColor];
    [self.view addSubview:self.label];
}

- (void)avgAction{
    self.textM = [NSMutableString string];
    if (self.rangeSlider.selectedMaximum<=self.rangeSlider.selectedMinimum){
        [self.textM setString:@"选择的范围不对"];
    }else{
        if ([RTConfigManager shareInstance].isShowCpu)[self addcpu];
        if ([RTConfigManager shareInstance].isShowMemory) [self addmeomery];
        if ([RTConfigManager shareInstance].isShowNetDelay) [self addnet];
        if ([RTConfigManager shareInstance].isShowFPS)[self addfps];
    }
    self.label.text = self.textM;
}

- (void)addcpu{
    NSArray *values = [RTDeviceInfo shareInstance].cupMonitor;
    CGFloat sum = 0;
    CGFloat min = 1000000;
    CGFloat max = 0;
    CGFloat avg = 0;
    
    for (NSInteger i=self.rangeSlider.selectedMinimum; i<=self.rangeSlider.selectedMaximum; i++) {
        NSInteger index = i - [RTDeviceInfo shareInstance].minTime;
        if (index >=0 && values.count > index) {
            float value = [values[index] floatValue];
            sum += value;
            if(value<min)min = value;
            if(value>max)max = value;
        }
    }
    float divisor = self.rangeSlider.selectedMaximum - self.rangeSlider.selectedMinimum;
    avg = sum/divisor;
    [self.textM appendFormat:@"CPU 最小值:%0.1f 最大值:%0.1f 平均值:%0.1f\n",min,max,avg];
}

- (void)addmeomery{
    NSArray *values = [RTDeviceInfo shareInstance].memoryMonitor;
    CGFloat sum = 0;
    CGFloat min = 1000000;
    CGFloat max = 0;
    CGFloat avg = 0;
    
    for (NSInteger i=self.rangeSlider.selectedMinimum; i<=self.rangeSlider.selectedMaximum; i++) {
        NSInteger index = i - [RTDeviceInfo shareInstance].minTime;
        if (index >=0 && values.count > index) {
            float value = [values[index] floatValue];
            sum += value;
            if(value<min)min = value;
            if(value>max)max = value;
        }
    }
    float divisor = self.rangeSlider.selectedMaximum - self.rangeSlider.selectedMinimum;
    avg = sum/divisor;
    [self.textM appendFormat:@"内存 最小值:%0.1f 最大值:%0.1f 平均值:%0.1f\n",min,max,avg];
}

- (void)addnet{
    NSArray *values = [RTDeviceInfo shareInstance].netMonitor;
    CGFloat sum = 0;
    CGFloat min = 1000000;
    CGFloat max = 0;
    CGFloat avg = 0;
    
    for (NSInteger i=self.rangeSlider.selectedMinimum; i<=self.rangeSlider.selectedMaximum; i++) {
        NSInteger index = i - [RTDeviceInfo shareInstance].minTime;
        if (index >=0 && values.count > index) {
            float value = [values[index] floatValue];
            sum += value;
            if(value<min)min = value;
            if(value>max)max = value;
        }
    }
    float divisor = self.rangeSlider.selectedMaximum - self.rangeSlider.selectedMinimum;
    avg = sum/divisor;
    [self.textM appendFormat:@"网络延迟 最小值:%0.1f 最大值:%0.1f 平均值:%0.1f\n",min,max,avg];
}

- (void)addfps{
    NSArray *values = [RTDeviceInfo shareInstance].fpsMonitor;
    CGFloat sum = 0;
    CGFloat min = 1000000;
    CGFloat max = 0;
    CGFloat avg = 0;
    
    for (NSInteger i=self.rangeSlider.selectedMinimum; i<=self.rangeSlider.selectedMaximum; i++) {
        NSInteger index = i - [RTDeviceInfo shareInstance].minTime;
        if (index >=0 && values.count > index) {
            float value = [values[index] floatValue];
            sum += value;
            if(value<min)min = value;
            if(value>max)max = value;
        }
    }
    float divisor = self.rangeSlider.selectedMaximum - self.rangeSlider.selectedMinimum;
    avg = sum/divisor;
    [self.textM appendFormat:@"FPS 最小值:%0.1f 最大值:%0.1f 平均值:%0.1f\n",min,max,avg];
}

@end
