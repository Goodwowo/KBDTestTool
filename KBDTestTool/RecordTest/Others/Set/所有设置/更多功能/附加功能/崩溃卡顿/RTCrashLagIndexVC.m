
#import "RTCrashLagIndexVC.h"
#import "RTSegmentedSlideSwitch.h"
#import "RecordTestHeader.h"
#import "RTTextPreVC.h"
#import "RTCrashLag.h"
#import "RTImagePreVC.h"
#import "RTOperationImage.h"

@interface RTCrashLagIndexVC ()<RTSlideSwitchDelegate>
@property (nonatomic,strong)RTSegmentedSlideSwitch *slideSwitch;
@end

@implementation RTCrashLagIndexVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"删除" TintColor:[UIColor redColor] target:self action:@selector(deleteAction)];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadVC];
}

- (void)deleteAction{
    if (self.isCrash) {
        [[RTCrashLag shareInstance] removeCrash:self.stamp];
        [RTOperationImage removeCrash:self.imageName];
        [RTOperationImage deleteOverdueCrash];
    }else{
        [[RTCrashLag shareInstance] removeLag:self.stamp];
        [RTOperationImage removeLag:self.imageName];
        [RTOperationImage deleteOverdueLag];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadVC{
    NSMutableArray *viewControllers = [NSMutableArray new];
    
    RTTextPreVC *statck_vc = [RTTextPreVC new];
    statck_vc.isCrash = self.isCrash;
    statck_vc.text = self.text;
    statck_vc.stamp = self.stamp;
    statck_vc.title = @"堆栈";
    [viewControllers addObject:statck_vc];
    [self addChildViewController:statck_vc];
    
    RTImagePreVC *image_vc = [RTImagePreVC new];
    if (self.isCrash) {
        image_vc.image = [RTOperationImage imageWithCrash:self.imageName];
    }else{
        image_vc.image = [RTOperationImage imageWithLag:self.imageName];
    }
    image_vc.title = @"截图";
    [viewControllers addObject:image_vc];
    [self addChildViewController:image_vc];
    
    RTTextPreVC *vcstatck_vc = [RTTextPreVC new];
    vcstatck_vc.isCrash = self.isCrash;
    vcstatck_vc.text = self.vcStack;
    vcstatck_vc.stamp = self.stamp;
    vcstatck_vc.title = @"控制器轨迹";
    [viewControllers addObject:vcstatck_vc];
    [self addChildViewController:vcstatck_vc];
    
    RTTextPreVC *crashstatck_vc = [RTTextPreVC new];
    crashstatck_vc.isCrash = self.isCrash;
    crashstatck_vc.text = self.operationStack;
    crashstatck_vc.stamp = self.stamp;
    crashstatck_vc.title = @"操作轨迹";
    [viewControllers addObject:crashstatck_vc];
    [self addChildViewController:crashstatck_vc];
    
    _slideSwitch = [[RTSegmentedSlideSwitch alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    _slideSwitch.backgroundColor = [UIColor whiteColor];
    _slideSwitch.delegate = self;
    _slideSwitch.tintColor = [UIColor darkGrayColor];
    _slideSwitch.viewControllers = viewControllers;
    [_slideSwitch showsInNavBarOf:self];
    [self.view addSubview:_slideSwitch];
}

@end
