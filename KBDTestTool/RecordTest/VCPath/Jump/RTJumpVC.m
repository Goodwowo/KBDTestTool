
#import "RTJumpVC.h"
#import "RTSegmentedSlideSwitch.h"
#import "RecordTestHeader.h"
#import "RTJumpListVC.h"

@interface RTJumpVC ()<RTSlideSwitchDelegate>
@property (nonatomic,strong)RTSegmentedSlideSwitch *slideSwitch;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation RTJumpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.activityIndicatorView];
    self.activityIndicatorView.center = self.view.center;
    self.activityIndicatorView.y-=64;
    [self.activityIndicatorView startAnimating];
    
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadVC];
}

- (void)loadVC{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 处理耗时操作的代码块...
        
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *viewControllers = [NSMutableArray new];
            
            RTJumpListVC *jumplist_vc = [RTJumpListVC new];
            jumplist_vc.title = @"跳转到";
            [viewControllers addObject:jumplist_vc];
            [self addChildViewController:jumplist_vc];
            
            _slideSwitch = [[RTSegmentedSlideSwitch alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
            _slideSwitch.backgroundColor = [UIColor whiteColor];
            _slideSwitch.delegate = self;
            _slideSwitch.tintColor = [UIColor darkGrayColor];
            _slideSwitch.viewControllers = viewControllers;
            [_slideSwitch showsInNavBarOf:self];
            [self.view addSubview:_slideSwitch];
            
            [self.activityIndicatorView stopAnimating];
        });
    });
}

- (void)backAction{
    [[RTInteraction shareInstance]showAll];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
