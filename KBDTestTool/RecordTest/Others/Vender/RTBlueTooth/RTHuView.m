#import "RTHuView.h"

@implementation RTHuView

- (void)drawRect:(CGRect)rect{
    //    仪表盘底部
    drawHu1();
    //    仪表盘进度
    [self drawHu2];
}
- (void)drawHu2{
    //1.获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    //1.1 设置线条的宽度
    CGContextSetLineWidth(ctx, 10);
    //1.2 设置线条的起始点样式
    CGContextSetLineCap(ctx, kCGLineCapButt);
    //1.3  虚实切换 ，实线5虚线10
    CGFloat length[] = { 4, 8 };
    CGContextSetLineDash(ctx, 0, length, 2);
    //1.4 设置颜色
    [[UIColor whiteColor] set];

    //2.设置路径
    CGFloat end = -5 * M_PI_4 + (6 * M_PI_4 * _num / 100);
    CGContextAddArc(ctx, kScreenW / 2, kScreenW / 2, 60, -5 * M_PI_4, end, 0);
    //3.绘制
    CGContextStrokePath(ctx);
}

void drawHu1(){
    //1.获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    //1.1 设置线条的宽度
    CGContextSetLineWidth(ctx, 10);
    //1.2 设置线条的起始点样式
    CGContextSetLineCap(ctx, kCGLineCapButt);
    //1.3  虚实切换 ，实线5虚线10
    CGFloat length[] = { 4, 8 };
    CGContextSetLineDash(ctx, 0, length, 2);
    //1.4 设置颜色
    [[UIColor blackColor] set];
    //2.设置路径
    CGContextAddArc(ctx, kScreenW / 2, kScreenW / 2, 60, -5 * M_PI_4, M_PI_4, 0);
    //3.绘制
    CGContextStrokePath(ctx);
}

- (void)setNum:(int)num{
    _num = num;
    if (_num >= 100) {
        _num = 100;
    }
    _numLabel.text = [NSString stringWithFormat:@"%d", _num];
    [self setNeedsDisplay];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenW - 120) / 2, (kScreenW - 80) / 2, 120, 80)];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.font = [UIFont systemFontOfSize:60];
        [self addSubview:_numLabel];
    }
    return self;
}

@end
