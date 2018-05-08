
#import <UIKit/UIKit.h>

@interface RTChartLabel : UILabel

@end

@interface RTChartView : UIView

/**X轴显示数组*/
@property (strong, nonatomic) NSArray * xLabels;
/**y轴数组*/
@property (strong, nonatomic) NSArray * yLabels;

@property (nonatomic, assign) BOOL isdrawLine;
@property (nonatomic, assign) BOOL isDrawPoint;
/**是否显示渐变*/
@property (nonatomic, assign) BOOL isShadow;
/**y轴显示的单位*/
@property (copy, nonatomic) NSString *unit;
@property (copy, nonatomic) NSString *unitX;
/**折线的颜色*/
@property (nonatomic, strong) UIColor *lineColor;
/**点的颜色*/
@property (nonatomic, strong) UIColor *pointColor;
/**横线的颜色*/
@property (nonatomic, strong) UIColor *xlineColor;
/**竖线的颜色*/
@property (nonatomic, strong) UIColor *yLineColor;

@property (nonatomic,assign)NSInteger showCount;//显示多少个点

- (void)strokeChart;

@end
