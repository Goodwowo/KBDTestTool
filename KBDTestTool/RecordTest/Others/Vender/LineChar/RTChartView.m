
#import "RTChartView.h"
#import "AutoTestHeader.h"

#define UULabelHeight       20
#define UUYLabelwidth       25

@implementation RTChartLabel

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setLineBreakMode:NSLineBreakByWordWrapping];
        [self setMinimumScaleFactor:5.0f];
        [self setNumberOfLines:1];
        [self setFont:[UIFont boldSystemFontOfSize:8.0f]];
        [self setTextColor:[UIColor whiteColor]];
        [self setTextAlignment:NSTextAlignmentCenter];
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

@end


@interface RTChartView ()

@property (nonatomic) CGFloat xLabelWidth;
@property (nonatomic) CGFloat xMargin;
@property (nonatomic, strong) UIScrollView* myScrollView;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGPoint originPoint;
@property (nonatomic, assign) CGPoint prePoint;

@end

@implementation RTChartView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(UUYLabelwidth, 0, frame.size.width - UUYLabelwidth, frame.size.height)];
        self.myScrollView.bounces = NO;
        [self addSubview:self.myScrollView];
        self.isDrawPoint = YES;
        self.isdrawLine = YES;
        self.isShadow = YES;
    }
    return self;
}

- (void)setXLabels:(NSArray*)xLabels{

    _xLabels = xLabels;
    CGFloat num = xLabels.count;
    if (xLabels.count < 1) num = 1.0;
    _showCount = _showCount>0 ? _showCount:60;
    _xLabelWidth = (self.myScrollView.frame.size.width - UUYLabelwidth * 0.5) / _showCount;
    
    NSInteger count = xLabels.count;
    NSInteger rowCount = _showCount/10;
    _xMargin = rowCount*_xLabelWidth/2.0;
    for (int i = 0; i < count; i++) {
        if (i % rowCount == 0) {
            NSString* labelText = xLabels[i];
            RTChartLabel* label = [[RTChartLabel alloc] initWithFrame:CGRectMake(i * _xLabelWidth + UUYLabelwidth * 0.5 - 10, self.frame.size.height - UULabelHeight, _xLabelWidth *rowCount, UULabelHeight)];
            label.text = labelText;
            [self.myScrollView addSubview:label];
        }
    }

    //画竖线
    for (int i = 0; i < count; i++) {
        CAShapeLayer* shapeLayer = [CAShapeLayer layer];
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(_xMargin+ i * _xLabelWidth, 0)];
        [path addLineToPoint:CGPointMake(_xMargin+ i * _xLabelWidth, self.frame.size.height - UULabelHeight - 10)];
        [path closePath];
        shapeLayer.path = path.CGPath;
        shapeLayer.strokeColor = self.yLineColor ? self.yLineColor.CGColor : [[[UIColor blackColor] colorWithAlphaComponent:0.1] CGColor];
        shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
        shapeLayer.lineWidth = 1;
        [self.myScrollView.layer addSublayer:shapeLayer];
    }
    
    float max = ((count - 1) * _xLabelWidth ) + _xLabelWidth;
    self.myScrollView.contentSize = CGSizeMake(max + 30, 0);
    if(max + 30>self.myScrollView.width)[self.myScrollView setContentOffset:CGPointMake(max+30-self.myScrollView.width, 0)];
}

- (void)setYLabels:(NSArray*)yLabels{
    _yLabels = yLabels;
    _xLabelWidth = (self.myScrollView.frame.size.width - UUYLabelwidth * 0.5) / 10;

    CGFloat _yValueMax = [[self.yLabels valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat _yValueMin = [[self.yLabels valueForKeyPath:@"@min.floatValue"] floatValue];
    float level = (_yValueMax - _yValueMin) / 3;
    CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight * 3;
    CGFloat levelHeight = chartCavanHeight / 3;

    for (int i = 0; i < 4; i++) {
        RTChartLabel* label = [[RTChartLabel alloc] initWithFrame:CGRectMake(0, chartCavanHeight - i * levelHeight, UUYLabelwidth, UULabelHeight)];
        label.text = [NSString stringWithFormat:@"%d%@", (int)(level * i + _yValueMin), self.unit ? self.unit : @""];
        [self addSubview:label];
    }
    
    RTChartLabel* label = [[RTChartLabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - UULabelHeight, UUYLabelwidth, UULabelHeight)];
    label.text = self.unitX;
    [self addSubview:label];

    //画横线
    for (int i = 0; i < 4; i++) {
        CAShapeLayer* shapeLayer = [CAShapeLayer layer];
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(20, UULabelHeight + i * levelHeight)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, UULabelHeight + i * levelHeight)];
        [path closePath];
        shapeLayer.path = path.CGPath;
        shapeLayer.strokeColor = self.xlineColor ? self.xlineColor.CGColor : [[[UIColor blackColor] colorWithAlphaComponent:0.1] CGColor];
        shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
        shapeLayer.lineWidth = 1;
        [self.layer insertSublayer:shapeLayer atIndex:0];
    }
    
    float max = (([yLabels count] - 1) * _xLabelWidth ) + _xLabelWidth;
    self.myScrollView.contentSize = CGSizeMake(max + 30, 0);
}

- (void)strokeChart{

    BOOL isShowMaxAndMinPoint = YES;
    NSInteger maxValue = [[_yLabels valueForKeyPath:@"@max.intValue"] integerValue];
    NSInteger minValue = [[_yLabels valueForKeyPath:@"@min.intValue"] integerValue];

    //划线
    CAShapeLayer* _chartLine = [CAShapeLayer layer];
    _chartLine.lineCap = kCALineCapRound; //设置线条拐角帽的样式
    _chartLine.lineJoin = kCALineJoinRound; //设置两条线连结点的样式
    _chartLine.fillColor = [[UIColor clearColor] CGColor];
    _chartLine.lineWidth = 1.0;
    _chartLine.strokeEnd = 0.0;
    [self.myScrollView.layer addSublayer:_chartLine];

    //线
    UIBezierPath* progressline = [UIBezierPath bezierPath];
    CGFloat firstValue = [[_yLabels objectAtIndex:0] floatValue];
    CGFloat xPosition = _xMargin;
    CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight * 3;

    //第一个点
    float grade = ((float)firstValue - minValue) / ((float)maxValue - minValue);
    if (isnan(grade)) {
        grade = 0;
    }
    CGPoint firstPoint = CGPointMake(xPosition, chartCavanHeight - grade * chartCavanHeight + UULabelHeight);
    [progressline moveToPoint:firstPoint];
    [progressline setLineWidth:1.0];
    [progressline setLineCapStyle:kCGLineCapRound];
    [progressline setLineJoinStyle:kCGLineJoinRound];

    //遮罩层形状
    UIBezierPath* bezier1 = [UIBezierPath bezierPath];
    bezier1.lineCapStyle = kCGLineCapRound;
    bezier1.lineJoinStyle = kCGLineJoinMiter;
    [bezier1 moveToPoint:firstPoint];
    self.originPoint = firstPoint; //记录原点

    NSInteger index = 0;
    for (NSString* valueString in _yLabels) {

        float grade = ([valueString floatValue] - minValue) / ((float)maxValue - minValue);
        if (isnan(grade)) {
            grade = 0;
        }
        CGPoint point = CGPointMake(xPosition + index * _xLabelWidth, chartCavanHeight - grade * chartCavanHeight + UULabelHeight);
        
        if (index != 0) {
            [progressline addCurveToPoint:point controlPoint1:CGPointMake((point.x + self.prePoint.x) / 2, self.prePoint.y) controlPoint2:CGPointMake((point.x + self.prePoint.x) / 2, point.y)];
            [progressline moveToPoint:point];
            [bezier1 addCurveToPoint:point controlPoint1:CGPointMake((point.x + self.prePoint.x) / 2, self.prePoint.y) controlPoint2:CGPointMake((point.x + self.prePoint.x) / 2, point.y)];
        }
        if (index == _yLabels.count - 1) {
            self.lastPoint = point; //记录最后一个点
        }
        if (self.isDrawPoint) {
            [self addPoint:point
                     index:index
                    isShow:isShowMaxAndMinPoint
                     value:[valueString floatValue]];
        }
        index += 1;
        self.prePoint = point;
    }

    if (self.isdrawLine) {

        _chartLine.path = progressline.CGPath;
        _chartLine.strokeColor = self.lineColor ? self.lineColor.CGColor : [UIColor greenColor].CGColor;
        _chartLine.strokeEnd = 1.0;

        if (self.isShadow) {
            [bezier1 addLineToPoint:CGPointMake(self.lastPoint.x, self.frame.size.height - UULabelHeight * 2)];
            [bezier1 addLineToPoint:CGPointMake(self.originPoint.x, self.frame.size.height - UULabelHeight * 2)];
            [bezier1 addLineToPoint:self.originPoint];
            [self addGradientLayer:bezier1];
        }
    }
}

- (void)addPoint:(CGPoint)point index:(NSInteger)index isShow:(BOOL)isHollow value:(CGFloat)value{
    if (!self.isDrawPoint) return;
    CGFloat viewWH = 3;
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(5, 5, viewWH, viewWH)];
    view.center = point;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = viewWH * 0.5;
    view.layer.borderWidth = 2;
    view.layer.borderColor = self.pointColor ? self.pointColor.CGColor : [UIColor greenColor].CGColor;
    view.backgroundColor = self.pointColor;
    [self.myScrollView addSubview:view];
}

/**添加渐变图层*/
- (void)addGradientLayer:(UIBezierPath*)bezier1{
    CAShapeLayer* shadeLayer = [CAShapeLayer layer];
    shadeLayer.path = bezier1.CGPath;
    shadeLayer.fillColor = [UIColor greenColor].CGColor;

    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(5, 0, 0, self.myScrollView.bounds.size.height - 20);
    gradientLayer.cornerRadius = 5;
    gradientLayer.masksToBounds = YES;
    gradientLayer.colors = @[ (__bridge id)[self.lineColor colorWithAlphaComponent:0.4].CGColor, (__bridge id)[self.lineColor colorWithAlphaComponent:0.0].CGColor ];
    gradientLayer.locations = @[ @(0.1f), @(1.0f) ];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.bounds = CGRectMake(5, 0, 2 * self.lastPoint.x, self.myScrollView.bounds.size.height - 20);
    
    CALayer* baseLayer = [CALayer layer];
    [baseLayer addSublayer:gradientLayer];
    [baseLayer setMask:shadeLayer];
    [self.myScrollView.layer insertSublayer:baseLayer atIndex:0];
}

@end
