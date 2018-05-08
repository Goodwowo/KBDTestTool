
#import "RTTopVC.h"
#import "RecordTestHeader.h"
#import <mach/mach.h>
#import <objc/runtime.h>
#import "AutoTestHeader.h"

@interface RTTopVC ()

@property (nonatomic,strong)NSMutableArray *vcStack;

@end

@implementation RTTopVC

+ (RTTopVC*)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTTopVC* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTTopVC alloc] init];
        _sharedObject.vcStack = [NSMutableArray array];
    });
    return _sharedObject;
}

/**判断某类（cls）是否为指定类（acls）的子类*/
- (BOOL)rt_isKindOfClass:(Class)cls acls:(Class)acls{
    Class scls = class_getSuperclass(cls);
    if (scls==acls) return true;
    else if (scls==nil) return false;
    return [self rt_isKindOfClass:scls acls:acls];
}

- (BOOL)isContainVC:(NSString *)vc{
    return [_vcStack containsObject:vc];
}

- (void)hookTopVC{
    if (Run) {
        [UIViewController aspect_hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info) {
            NSString* className = NSStringFromClass([[info instance] class]);
            [self.vcStack addObject:className];
            [self updateTopVC:YES];
            [[RTCommandList shareInstance] initData];
            [[KVOAllView new] kvoAllView];
        } error:NULL];
        
        [UIViewController aspect_hookSelector:@selector(viewDidDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info) {
            NSString* className = NSStringFromClass([[info instance] class]);
            [self popVC:className];
            [self updateTopVC:NO];
            [[RTCommandList shareInstance]initData];
        } error:NULL];
    }
}

- (void)popVC:(NSString *)vc{
    NSInteger index = -1;
    for (NSInteger i=self.vcStack.count-1; i>=0; i--) {
        NSString *className = self.vcStack[i];
        if ([className isEqualToString:vc]) {
            [self.vcStack removeObjectAtIndex:i];
            index = i-1;
            break;
        }
    }
    [self popNoExsitVCFromIndex:index];
}

- (void)updateTopVC:(BOOL)isNewVC{
    NSMutableArray *vcStack = [NSMutableArray arrayWithArray:self.vcStack];
    [self removeNotShowInWindow:vcStack];
    [[RTVCLearn shareInstance] setUnionVC:vcStack];
    if(isNewVC)[[RTVCLearn shareInstance]setTopologyVCMore:vcStack];
//    [[RTVCLearn shareInstance] setTopologyVC:vcStack];
//    NSLog(@"😄:%@",vcStack);
    if (vcStack.count>0) {
        self.topVC = [vcStack lastObject];
//        NSLog(@"当前最顶部的控制器%@",self.topVC);
    }else if(self.vcStack.count>0){
//        NSLog(@"有异常情况发生:控制器堆栈被筛选后为空");
    }
}

- (void)removeNotShowInWindow:(NSMutableArray *)vcStack{
    NSMutableArray *temp = [NSMutableArray array];
    for (NSString *vc in vcStack) {
        Class vcCls =  NSClassFromString(vc);
        if ([[RTSystemClass shareInstance] isSystemClass:vcCls] ||
//            [self rt_isKindOfClass:vcCls acls:[UINavigationController class]] ||
//            [self rt_isKindOfClass:vcCls acls:[UITabBarController class]] ||
            [self isExsitVC:vc] == NO) {
            [temp addObject:vc];
        }
    }
    [vcStack removeObjectsInArray:temp];
}

- (void)popNoExsitVC{
    NSString *topVC = [self.vcStack lastObject];
    while (topVC && [self isExsitVC:topVC] == NO) {
        [self.vcStack popLastObject];
        topVC = [self.vcStack lastObject];
    }
}

- (void)popNoExsitVCFromIndex:(NSInteger)index{
    if (index>=0 && index<self.vcStack.count) {
        NSString *className = self.vcStack[index];
        if ([self isExsitVC:className] == NO) {
            [self.vcStack removeObjectAtIndex:index];
        }
        [self popNoExsitVCFromIndex:index-1];
    }
}

- (BOOL)isExsitVC:(NSString *)vc{
    BOOL result = NO;
    for (int i = 0; i < [UIApplication sharedApplication].windows.count; i++) {
        UIWindow *window = [UIApplication sharedApplication].windows[i];
        if (window.subviews.count > 0) {
            if ([self dumpView:window isExsitVC:vc]) {
                result = YES;
                break;
            }
        }
    }
    return result;
}

- (BOOL)dumpView:(UIView *)aView isExsitVC:(NSString *)vc{
    BOOL result = NO;
    if(!aView.curViewController || aView.curViewController.length<=0){
        aView.curViewController=NSStringFromClass([aView getViewController].class);
    }
    if (aView.curViewController.length == vc.length) {
        if ([aView.curViewController isEqualToString:vc]) {
            if ([self viewIsCanShowInWindow:aView]) {
                return YES;
            }
        }
    }
    //继续递归遍历
    for (UIView *view in [aView subviews]){
        if ([self dumpView:view isExsitVC:vc]) {
            result = YES;
            break;
        }
    }
    return result;
}

- (BOOL)viewIsCanShowInWindow:(UIView *)view{
    CGRect rect = [view rectIntersectionInWindow];// 获取 该view与window 交叉的 Rect
    if (!(CGRectIsEmpty(rect) || CGRectIsNull(rect))) {
        CGRect canShowFrame = [view canShowFrameRecursive];
        if (!(CGRectIsEmpty(canShowFrame) || CGRectIsNull(canShowFrame))){
            return YES;
        }
    }
    return NO;
}

@end
