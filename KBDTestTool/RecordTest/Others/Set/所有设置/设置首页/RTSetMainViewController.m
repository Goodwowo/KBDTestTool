
#import "RTSetMainViewController.h"
#import "RTSegmentedSlideSwitch.h"
#import "RTSettingViewController.h"
#import "RecordTestHeader.h"
#import "RTAllRecordVC.h"
#import "RTPlaybackViewController.h"
#import "RTMoreFuncVC.h"

@interface RTSetMainViewController ()<RTSlideSwitchDelegate>
@property (nonatomic,strong)RTSegmentedSlideSwitch *slideSwitch;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation RTSetMainViewController

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
            
            RTMoreFuncVC *more_vc = [RTMoreFuncVC new];
            more_vc.title = @"功能";
            [viewControllers addObject:more_vc];
            [self addChildViewController:more_vc];
            
            RTAllRecordVC *allRecord_vc = [RTAllRecordVC new];
            allRecord_vc.title = @"录制";
            [viewControllers addObject:allRecord_vc];
            [self addChildViewController:allRecord_vc];
            
            RTPlaybackViewController *playback_vc = [RTPlaybackViewController new];
            playback_vc.title = @"回放";
            [viewControllers addObject:playback_vc];
            [self addChildViewController:playback_vc];
            
            RTSettingViewController *set_vc = [RTSettingViewController new];
            set_vc.title = @"设置";
            [viewControllers addObject:set_vc];
            [self addChildViewController:set_vc];
            
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
