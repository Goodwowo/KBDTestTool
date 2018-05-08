
#import "RTAutoRun.h"
#import "RecordTestHeader.h"

@interface RTAutoRun ()

@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,assign)NSInteger index;

@end

@implementation RTAutoRun

+ (RTAutoRun *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTAutoRun *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTAutoRun alloc] init];
        _sharedObject.autoRunQueue = [NSMutableArray array];
        _sharedObject.index = 0;
    });
    return _sharedObject;
}

- (void)repeatAction{
    if (![RTCommandList shareInstance].isRunOperationQueue) {
        if (self.autoRunQueue.count > self.index) {
            if (![RTAutoJump shareInstance].isJump && ![RTSearchVCPath shareInstance].isPopToRoot) {
                RTIdentify *identify = self.autoRunQueue[self.index];
                if ([identify.forVC isEqualToString:[RTTopVC shareInstance].topVC]) {
//                    NSLog(@"🔥%@",@"好了,终于可以执行命令了");
                    self.index++;
                    [RTAutoJump shareInstance].canotJump = NO;
                    [[RTCommandList shareInstance] setOperationQueue:identify];
                    //延迟1s,不然太快会导致录制屏幕那里的多线程和信号量提前被释放
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[RTCommandList shareInstance] runStep:YES];
                    });
                }else{
                    if ([[RTSearchVCPath shareInstance] popVC]) {
                        [[RTSearchVCPath shareInstance] popToRootVC];
//                        NSLog(@"🔥%@",@"先返回根目录");
                    }else{
                        if ([RTAutoJump shareInstance].canotJump) {
                            self.index++;
                            [RTAutoJump shareInstance].canotJump = NO;
//                            NSLog(@"🔥%@",@"实在跳转到目标VC,还是执行下一个回放吧");
                        }else{
                            //开始自动寻址并跳转
//                            NSLog(@"🔥%@",@"开始自动寻址并跳转");
                            [[RTAutoJump shareInstance] gotoVC:identify.forVC];
                        }
                    }
                }
            }else{
                if ([RTAutoJump shareInstance].isJump){
//                    NSLog(@"🔥%@",@"正在自动寻址并跳转....");
                }
                if ([RTSearchVCPath shareInstance].isPopToRoot){
//                    NSLog(@"🔥%@",@"正在跳转到根目录...");
                }
            }
        }else{
//            NSLog(@"🔥%@",@"哦哦,停止了...");
            [self stop];
        }
    }
}

- (void)start{
    self.index = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(repeatAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer setFireDate:[NSDate distantPast]];
    });
}

- (void)stop{
    [self.autoRunQueue removeAllObjects];
    self.autoRunQueue = [NSMutableArray array];
    self.index = 0;
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.timer invalidate];
}

@end
