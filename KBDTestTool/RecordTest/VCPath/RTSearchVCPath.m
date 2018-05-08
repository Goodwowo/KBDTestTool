
#import "RTSearchVCPath.h"
#import "RecordTestHeader.h"
#import "RTVertex.h"
#import "NSArray+ZH.h"

@interface RTSearchVCPath ()

@property (nonatomic,assign)BOOL shouldSave;
@property (nonatomic,assign)NSInteger identity;
@property (nonatomic,copy)NSString *searchVCPath;
@property (nonatomic,weak)UIViewController *curVC;
@end

@implementation RTSearchVCPath

+ (RTSearchVCPath *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTSearchVCPath *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTSearchVCPath alloc] init];
        _sharedObject.searchVCPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/SearchVCPath"];
        _sharedObject.operationQueue = [NSKeyedUnarchiver unarchiveObjectWithFile:_sharedObject.searchVCPath];
        while (_sharedObject.operationQueue.count>1000) {
            [_sharedObject.operationQueue removeObjectAtIndex:0];
        }
        _sharedObject.identity = 1;
        if (!_sharedObject.operationQueue) {
            _sharedObject.operationQueue = [NSMutableArray array];
        }
        if (_sharedObject.operationQueue.count>0) {
            RTOperationQueueModel *model = [_sharedObject.operationQueue lastObject];
            _sharedObject.identity = model.runResult + 1;
        }
        [_sharedObject autoSave];
    });
    return _sharedObject;
}

- (void)autoSave{
    if (self.shouldSave) {
        [[NSKeyedArchiver archivedDataWithRootObject:self.operationQueue] writeToFile:self.searchVCPath atomically:YES];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self autoSave];
    });
}

+ (void)addOperation:(UIView *)view type:(RTOperationQueueType)type parameters:(NSArray *)parameters repeat:(BOOL)repeat{
    if (![RTSearchVCPath shareInstance].isLearnVCPath || [RTOperationQueue shareInstance].isRecord || [RTAutoJump shareInstance].isJump) {
        return;
    }
    [RTSearchVCPath shareInstance].shouldSave = YES;
    if(view.layerDirector.length <= 0) return;
    if (repeat == NO) {
        NSArray *operationQueue = [RTSearchVCPath shareInstance].operationQueue;
        for (NSInteger i = operationQueue.count - 1; i >= 0; i--) {
            RTOperationQueueModel *model = operationQueue[i];
            if (model.type != type) {
                break;
            }
            if ([model.viewId isEqualToString:view.layerDirector] && model.type == type) {
                model.parameters = parameters;
//                NSLog(@"%@",[RTSearchVCPath shareInstance].operationQueue);
                return;
            }
        }
    }
    RTOperationQueueModel *model = [RTOperationQueueModel new];
    model.type = type;
    model.viewId = view.layerDirector;
    model.parameters = parameters;
    model.view = NSStringFromClass(view.class);
    model.vc = [RTTopVC shareInstance].topVC;
    model.runResult = [RTSearchVCPath shareInstance].identity;
    [[RTSearchVCPath shareInstance].operationQueue addObject:model];
//    NSLog(@"%@",[RTSearchVCPath shareInstance].operationQueue);
}

- (BOOL)popVC{
    return [UIViewController popOrDismissViewController:nil];
}

- (void)popToRootVC{
    self.isPopToRoot = YES;
    if ([UIViewController popOrDismissViewController:nil]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self popToRootVC];
        });
    }else{
        self.isPopToRoot = NO;
    }
}

- (BOOL)canPopToVC:(NSString *)vc{
    UIViewController *controllerTarget = nil;
    for (UIViewController * controller in self.curVC.navigationController.viewControllers) { //遍历
        if ([controller isKindOfClass:NSClassFromString(vc)]) { //这里判断是否为你想要跳转的页面
            controllerTarget = controller;
        }
    }
    if (controllerTarget) {
        return YES;
    }
    return NO;
}

- (NSArray *)stepGoToVc:(NSString *)vc{
    NSMutableArray *arr = [RTVertex shortestPath:[RTSearchVCPath shareInstance].operationQueue from:[RTTopVC shareInstance].topVC to:vc].mutableCopy;
    [arr reverse];
    NSMutableArray *steps = [NSMutableArray array];
    if (arr.count>1) {
        for (NSInteger i=0; i<arr.count-1; i++) {
            NSString *cur = arr[i];
            NSString *curNext = arr[i+1];
            NSDictionary *values = [[RTVertex shareInstance].repearDictionary getValuesForKey:[NSString stringWithFormat:@"%@->%@",cur,curNext]];
            NSMutableArray * allValues = [values allValues].mutableCopy;
            [allValues sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSNumber *num1 = obj1 , *num2 = obj2;
                return [num1 intValue]<[num2 intValue];
            }];
//            NSLog(@"allValues = %@",allValues);
            while (allValues.count>3) {
                [allValues removeLastObject];
            }
            [steps addObject:allValues];
        }
    }
    return steps;
}

- (NSArray *)allCanGotoVcs{
    return [RTVertex allShortestPath:[RTSearchVCPath shareInstance].operationQueue from:[RTTopVC shareInstance].topVC];
}

- (NSString *)traceOperation{
    if (self.operationQueue.count>0) {
        NSMutableArray *arrM = [NSMutableArray array];
        for (RTOperationQueueModel *model in self.operationQueue) {
            if (model.runResult == self.identity) {
                [arrM addObject:model];
            }
        }
        if (arrM.count>0) {
            return [arrM componentsJoinedByString:@"\n"];
        }
    }
    return @"没有记录操作路径";
}

@end
