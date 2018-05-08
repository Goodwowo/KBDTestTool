
#import "RTJumpListVC.h"
#import "RecordTestHeader.h"
#import "AutoTestProject.h"
#import "RTVertex.h"
#import "RTSearchVCPath.h"
#import "NSArray+ZH.h"
#import "RTAutoJump.h"

@implementation RTJumpListVC

- (void)viewDidLoad{
    [super viewDidLoad];
    [self addRootVC];
    [self add0SectionItems];
}

#pragma mark 添加第0组的模型数据
- (void)add0SectionItems{
    
    NSArray *allCanGotoVcs = [[RTSearchVCPath shareInstance] allCanGotoVcs];
    __weak typeof(self)weakSelf=self;
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *vcIdentity in allCanGotoVcs) {
        NSString *vc = [[RTVCLearn shareInstance] getVcWithIdentity:vcIdentity];
        if ([RTVCLearn filter:vc] || [[RTTopVC shareInstance] isContainVC:vc]) {
            continue;
        }
        RTSettingItem *item1 = [RTSettingItem itemWithIcon:@"" title:vc subTitle:nil type:ZFSettingItemTypeArrow];
        item1.subTitleFontSize = 10;
        __weak typeof(item1)weakitem1=item1;
        item1.operation = ^{
            NSString *targetVC = weakitem1.title;
            [[RTInteraction shareInstance] showAll];
            [weakSelf dismissViewControllerAnimated:NO completion:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[RTAutoJump shareInstance] gotoVC:targetVC];
                });
            }];
        };
        [items addObject:item1];
    }
    
    RTSettingGroup *group1 = [[RTSettingGroup alloc] init];
    group1.header = @"跳转到VC";
    group1.items = items;
    [self.allGroups addObject:group1];
}

- (void)addRootVC{
    __weak typeof(self)weakSelf=self;
    RTSettingItem *item1 = [RTSettingItem itemWithIcon:@"" title:@"RootVC(根控制器)" subTitle:nil type:ZFSettingItemTypeArrow];
    item1.subTitleFontSize = 10;
    __weak typeof(item1)weakitem1=item1;
    item1.operation = ^{
        NSString *targetVC = weakitem1.title;
        [[RTInteraction shareInstance] showAll];
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            [[RTAutoJump shareInstance] gotoVC:targetVC];
        }];
    };
    RTSettingGroup *group1 = [[RTSettingGroup alloc] init];
    group1.header = @"根目录";
    group1.items = @[item1];
    [self.allGroups addObject:group1];
}

@end
