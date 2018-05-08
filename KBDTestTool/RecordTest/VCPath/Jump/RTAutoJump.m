
#import "RTAutoJump.h"
#import "RecordTestHeader.h"
#import "AutoTestProject.h"
#import "RTVertex.h"
#import "RTSearchVCPath.h"
#import "NSArray+ZH.h"

@interface RTAutoJump ()
@property (nonatomic,assign)NSIndexPath *indexPath;
@property (nonatomic,strong)NSArray *steps;
@end

@implementation RTAutoJump

- (void)gotoVC:(NSString *)vc{
    if ([vc isEqualToString:@"RootVC(根控制器)"]) {
        [[RTSearchVCPath shareInstance] popToRootVC];
    }else{
        if (vc.length>0) {
            self.steps = [[RTSearchVCPath shareInstance] stepGoToVc:vc];
            self.isJump = YES;
            self.canotJump = NO;
            self.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self runStep];
        }
    }
}

- (void)runStep{
    static int runFailure = 0;
    if (self.isJump) {
        if ([self isCanRun]) {
            NSNumber *num = self.steps[self.indexPath.section][self.indexPath.row];
            RTOperationQueueModel *operationQueue = nil;
            if ([RTSearchVCPath shareInstance].operationQueue.count>[num intValue]) {
                operationQueue = [RTSearchVCPath shareInstance].operationQueue[[num intValue]];
            }else{
                runFailure ++;
                [ZHStatusBarNotification showWithStatus:[NSString stringWithFormat:@"这步跳转不存在 次数:%d/5",runFailure] dismissAfter:1 styleName:JDStatusBarStyleWarning];
            }
            UIView *targetView = [[RTGetTargetView new] getTargetView:operationQueue.viewId];
            if (targetView) {
                if ([targetView runOperation:operationQueue]) {
                    [ZHStatusBarNotification showWithStatus:@"正在跳转" dismissAfter:1 styleName:JDStatusBarStyleSuccess];
                    [self nextSectionStep];
                    runFailure = 0;
                }else{
                    runFailure ++;
                    [ZHStatusBarNotification showWithStatus:[NSString stringWithFormat:@"跳转-执行失败 次数:%d/5",runFailure] dismissAfter:1 styleName:JDStatusBarStyleError];
                }
            }else{
                runFailure ++;
                [ZHStatusBarNotification showWithStatus:[NSString stringWithFormat:@"跳转-没找到控件 次数:%d/5",runFailure] dismissAfter:1 styleName:JDStatusBarStyleWarning];
            }
            if (runFailure >= 5) {//执行10次还是失败,说明这句命令是真的不能执行了,或者是因为网络问题,实在加载不出来对应的控件了,这个是用来自动运行的
                runFailure = 0;
                [self nextStep];
            }
        }else{
            self.canotJump = YES;
            [self stop];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self runStep];
        });
    }
}


+ (RTAutoJump*)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTAutoJump* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTAutoJump alloc] init];
    });
    return _sharedObject;
}

- (void)stop{
    self.isJump = NO;
    self.steps = nil;
}

- (BOOL)isCanRun{
    return self.steps.count > self.indexPath.section && [self.steps[self.indexPath.section] count] > self.indexPath.row;
}

- (void)nextSectionStep{
    self.indexPath=[NSIndexPath indexPathForRow:0 inSection:self.indexPath.section+1];
    if (self.indexPath.section>=self.steps.count) {
        [ZHStatusBarNotification showWithStatus:@"跳转完毕" dismissAfter:1 styleName:JDStatusBarStyleSuccess];
        [self stop];
        self.canotJump = NO;
    }
}

- (void)nextStep{
    self.indexPath=[NSIndexPath indexPathForRow:self.indexPath.row+1 inSection:self.indexPath.section];
    if (self.steps.count > self.indexPath.section) {
        NSArray *subArr = self.steps[self.indexPath.section];
        if (subArr && subArr.count<=self.indexPath.row) {
            self.canotJump = YES;
            [self stop];
        }
    }else{
        self.canotJump = YES;
        [self stop];
    }
    if (self.indexPath.section>=self.steps.count) {
        [ZHStatusBarNotification showWithStatus:@"跳转完毕" dismissAfter:1 styleName:JDStatusBarStyleSuccess];
        [self stop];
        self.canotJump = NO;
    }
}

@end
