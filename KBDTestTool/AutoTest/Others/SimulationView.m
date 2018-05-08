
#import "SimulationView.h"

@implementation SimulationView

/**添加一个模拟点击的一个图片,这样看起来更加友好*/
+ (void)addTouchSimulationView:(CGPoint)point afterDismiss:(NSInteger)time{
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(point.x, point.y, 30, 30)];
    imageView.center=CGPointMake(point.x, point.y);
    imageView.image=[UIImage imageNamed:@"AutoTest_Tap"];
    UIView *keyWindow=[UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:imageView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageView removeFromSuperview];
    });
}

//direction 1左 2上 3右 4下
/**添加一个模拟滑动的一个图片,这样看起来更加友好*/
+ (void)addSwipeSimulationView:(CGPoint)point direction:(NSInteger)direction afterDismiss:(NSInteger)time{
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(point.x, point.y, 20, 20)];
    if (direction==1||direction==3) {
        imageView.frame=CGRectMake(point.x, point.y, 52, 28);
    }else{
        imageView.frame=CGRectMake(point.x, point.y, 28, 52);
    }
    switch (direction) {
        case 1:imageView.image=[UIImage imageNamed:@"AutoTest_Right"]; break;//注意图像刚好要反过来,就像上拉加载和下拉刷新一样的道理
        case 2:imageView.image=[UIImage imageNamed:@"AutoTest_Down"];break;//注意图像刚好要反过来,就像上拉加载和下拉刷新一样的道理
        case 3:imageView.image=[UIImage imageNamed:@"AutoTest_Left"];break;//注意图像刚好要反过来,就像上拉加载和下拉刷新一样的道理
        case 4:imageView.image=[UIImage imageNamed:@"AutoTest_Up"];break;//注意图像刚好要反过来,就像上拉加载和下拉刷新一样的道理
        default:imageView.image=nil;break;
    }
    
    imageView.center=CGPointMake(point.x, point.y);
    UIView *keyWindow=[UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:imageView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageView removeFromSuperview];
    });
}

@end
