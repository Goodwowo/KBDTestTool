
#import "RTInteraction.h"
#import "RecordTestHeader.h"
#import "RTCommandList.h"
#import "ZHAlertAction.h"
#import "RTCommandListVCViewController.h"
#import "RTSetMainViewController.h"
#import "AutoTestProject.h"
#import "RTJumpVC.h"

@interface RTInteraction ()<SuspendBallDelegte>

@end

@implementation RTInteraction

+ (RTInteraction *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTInteraction *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTInteraction alloc] init];
    });
    return _sharedObject;
}

- (void)startInteraction{
    SuspendBall *suspendBall = [SuspendBall suspendBallWithFrame:CGRectMake(0, 64, 50, 50) delegate:self subBallImageArray:@[@"SuspendBall_down",@"SuspendBall_monkey",@"SuspendBall_list",@"SuspendBall_startrecord",@"SuspendBall_set"]];
    suspendBall.titleGroup = @[@"下一步",@"跳转",@"列表",@"开始录制",@"更多"];
    [[UIApplication sharedApplication].keyWindow addSubview:suspendBall];
    suspendBall.isNoNeedKVO = suspendBall.isNoNeedSnap = YES;
    RTCommandList *list = [[RTCommandList alloc]initInKeyWindowWithFrame:CGRectMake(0, suspendBall.maxY, 200, 12*10)];
    list.isRunOperationQueue = NO;
    list.isNoNeedKVO = list.isNoNeedSnap = YES;
    [list initData];
    __weak typeof(list)weakList=list;
    list.tapBlock = ^(RTCommandList *view) {
        RTCommandListVCViewController *vc = [RTCommandListVCViewController new];
        vc.title = weakList.curCommand.text;
        [vc.dataArr addObjectsFromArray:weakList.dataArr];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.nav = nav;
        [[UIApplication sharedApplication].keyWindow addSubview:nav.view];
        [[UIViewController getCurrentVC] addChildViewController:nav];
    };
}

#pragma mark - SuspendBallDelegte
- (void)suspendBall:(UIButton *)subBall didSelectTag:(NSInteger)tag{
    switch (tag) {
        case 0:{
            if ([RTCommandList shareInstance].isRunOperationQueue) {
                [[RTCommandList shareInstance] runStep:NO];
            }else{
                [ZHStatusBarNotification showWithStatus:@"没有正在执行的操作队列" dismissAfter:1 styleName:JDStatusBarStyleError];
            }
        }break;
        case 1:{
            [self hideAll];
            [[UIViewController getCurrentVC] presentViewController:[[UINavigationController alloc] initWithRootViewController:[RTJumpVC new]] animated:YES completion:nil];
        }break;
        case 2:{
            [RTCommandList shareInstance].hidden = ![RTCommandList shareInstance].hidden;
        }break;
        case 3:{
            [RTOperationQueue startOrStopRecord];//开始录制 结束录制
        }break;
        case 4:{
            [self hideAll];
            [[UIViewController getCurrentVC] presentViewController:[[UINavigationController alloc] initWithRootViewController:[RTSetMainViewController new]] animated:YES completion:nil];
        }break;
        default:
            break;
    }
}

- (void)showAll{
    [SuspendBall shareInstance].functionMenu.alpha = 1;
    [SuspendBall shareInstance].alpha = 1;
    [RTCommandList shareInstance].alpha = 1;
}

- (void)hideAll{
    [SuspendBall shareInstance].functionMenu.alpha = 0;
    [SuspendBall shareInstance].alpha = 0;
    [RTCommandList shareInstance].alpha = 0;
}

@end
