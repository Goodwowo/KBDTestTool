
#import "RTVCLearn.h"
#import "RecordTestHeader.h"
//#import "ZHNSString.h"

@interface RTVCLearn ()

@property (nonatomic,strong)NSMutableDictionary *vcIdentity;
@property (nonatomic,strong)NSMutableArray *vcIdentityReverse;

@property (nonatomic,strong)NSMutableDictionary *vcUnion;//页面相互共存的
@property (nonatomic,strong)NSMutableString *topology;//vc路径,连续的操作路径
@property (nonatomic,strong)NSMutableArray *topologyMemory;
@property (nonatomic,strong)NSMutableArray *topologyPerformance;
@property (nonatomic,strong)NSMutableString *topologyMore;//vc路径,连续的操作路径(这个可以存在相同的push)

@end

@implementation RTVCLearn

+ (RTVCLearn*)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTVCLearn* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTVCLearn alloc] init];
        _sharedObject.vcIdentityReverse = [NSMutableArray array];
        _sharedObject.vcIdentity = [NSMutableDictionary dictionary];
        _sharedObject.vcUnion = [NSMutableDictionary dictionary];
        _sharedObject.topology = [NSMutableString string];
        _sharedObject.topologyMore = [NSMutableString string];
        _sharedObject.topologyMemory = [NSMutableArray array];
        _sharedObject.topologyPerformance = [NSMutableArray array];
    });
    return _sharedObject;
}

- (NSArray *)unionVC{
    NSArray *allKeys = self.vcUnion.allKeys;
    NSMutableArray *unionVC = [NSMutableArray array];
    for (NSString *key in allKeys) {
        if ([key rangeOfString:@","].location!=NSNotFound) {
            NSArray *splits = [key componentsSeparatedByString:@","];
            NSMutableArray *subArr = [NSMutableArray arrayWithCapacity:splits.count];
            for (NSString *split in splits) {
                if (split.length>0) {
                    NSString *vc = [self getVcWithIdentity:split];
                    if (vc.length>0) {
                        [subArr addObject:vc];
                    }
                }
            }
            if (subArr.count>0) {
                [unionVC addObject:subArr];
            }
        }
    }
    return unionVC;
}

- (NSArray *)traceVC{
    NSMutableArray *traceVC = [NSMutableArray array];
    if ([self.topology rangeOfString:@","].location!=NSNotFound) {
        NSArray *splits = [self.topology componentsSeparatedByString:@","];
        for (NSString *split in splits) {
            if (split.length>0) {
                NSString *vc = [self getVcWithIdentity:split];
                if (vc.length>0) {
                    [traceVC addObject:vc];
                }
            }
        }
    }
    return traceVC;
}

- (NSString *)traceString{
    NSArray *traceVC = [self traceVC];
    NSMutableArray *items = [NSMutableArray array];
    NSInteger index = 1;
    NSString *lastVC = nil;
    for (NSString *vc in traceVC) {
        if ([RTVCLearn filter:vc]) continue;
        if (lastVC && lastVC.length == vc.length && [lastVC isEqualToString:vc]) continue;
        NSString *title = [NSString stringWithFormat:@"%zd : %@",index++,vc];
        [items addObject:title];
        lastVC = vc;
    }
    return [items componentsJoinedByString:@"\n"];
}

- (NSArray *)traceMemory{
    NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.topologyMemory];
    NSString *memory = [NSString stringWithFormat:@"内存:%0.1fM",[RTDeviceInfo shareInstance].appMemory];
    [arrM addObject:memory];
    return arrM;
}

- (NSArray *)tracePerformance{
    NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.topologyPerformance];
    [arrM addObject:[NSNumber numberWithInteger:[RTDeviceInfo shareInstance].curTime]];
    return arrM;
}

- (NSString *)getVcIdentity:(NSString *)vc{
    if (!vc) {
        return @"";
    }
    NSString *vcIdentity = self.vcIdentity[vc];
    if (!vcIdentity) {
        vcIdentity = [NSString stringWithFormat:@"%lu",(unsigned long)self.vcIdentity.count];
        self.vcIdentity[vc] = vcIdentity;
        [self.vcIdentityReverse addObject:vc];
    }
    return vcIdentity;
}

- (NSString *)getVcWithIdentity:(NSString *)identity{
    NSInteger index = [identity integerValue];
    if (self.vcIdentityReverse.count>index) {
        return self.vcIdentityReverse[index];
    }
    return nil;
}

- (void)setUnionVC:(NSArray *)vcs{
    NSMutableString *identitys = [NSMutableString string];
    for (NSString *vc in vcs) {
        NSString *vcIdentity = [self getVcIdentity:vc];
        [identitys appendFormat:@"%@,",vcIdentity];
    }
    if (identitys.length>0) {
        static NSString *lastIdentitys = nil;
        NSString *temp = [identitys substringToIndex:identitys.length-1];
        if (!self.vcUnion[temp]) {
            self.vcUnion[temp] = @"";
            [self setTopologyVC:vcs unionVC:temp];
        }else{
            if (temp.length != lastIdentitys.length ||![temp isEqualToString:lastIdentitys]) {
                [self setTopologyVC:vcs unionVC:temp];
            }
        }
        lastIdentitys = temp;
    }
//    NSLog(@"%@",self.vcUnion);
}

- (void)setTopologyVC:(NSArray *)vcStack unionVC:(NSString *)unionVC{
    static NSString *lastVC = nil;
    if (vcStack.count > 0) {
        NSString *curVC = [vcStack lastObject];
        if (!lastVC) {
            [self.topology appendString:[self getVcIdentity:curVC]];
        }
//        NSLog(@"😄%@",unionVC);
        if (lastVC && lastVC.length > 0 && ![lastVC isEqualToString:curVC]) {
            [self.topology appendFormat:@",%@",[self getVcIdentity:curVC]];
            NSString *unionSuffix = [self unionSuffix:unionVC topology:self.topology];
            NSString *appendString = @"";
            NSRange range = [unionSuffix rangeOfString:@","];
            if (range.location != NSNotFound) {
                appendString = [unionSuffix substringFromIndex:range.location+1];
            }else{
                appendString = unionSuffix;
            }
            [self.topology replaceCharactersInRange:NSMakeRange(self.topology.length - unionSuffix.length , unionSuffix.length) withString:appendString];
//            NSLog(@"💣:%@",appendString);
        }
        [self updataMemoryForTopology];
        lastVC = curVC;
    }
//    NSLog(@"当前最顶部的控制器%@",[RTTopVC shareInstance].topVC);
//    NSLog(@"👌%@",self.topology);
}

- (void)updataMemoryForTopology{
    NSInteger count = 0;
    NSArray *split = [self.topology componentsSeparatedByString:@","];
    for (NSString *str in split) {
        if(str.length>0) count++;
    }
    if(count>0)count--;
    NSString *memory = [NSString stringWithFormat:@"内存:%0.1fM",[RTDeviceInfo shareInstance].appMemory];
    if(self.topologyMemory.count > count) {
        self.topologyMemory[count] = memory;
        self.topologyPerformance[count] = [NSNumber numberWithInteger:[RTDeviceInfo shareInstance].curTime];
    }else {
        [self.topologyMemory addObject:memory];
        [self.topologyPerformance addObject:[NSNumber numberWithInteger:[RTDeviceInfo shareInstance].curTime]];
    }
//    NSLog(@"👌%@",self.topology);
//    NSLog(@"👌%@",self.topologyPerformance);
}

- (void)setTopologyVCMore:(NSArray *)vcStack{
//    NSLog(@"%@",vcStack);
    static NSString *lastVCMore = nil;
    if (vcStack.count > 0) {
        NSString *curVC = [vcStack lastObject];
        if (!lastVCMore) {
            [self.topologyMore appendString:[self getVcIdentity:curVC]];
        }
        if (lastVCMore && lastVCMore.length > 0 && ![lastVCMore isEqualToString:curVC]) {
            [self.topologyMore appendFormat:@",%@",[self getVcIdentity:curVC]];
        }
        lastVCMore = curVC;
    }
//    NSLog(@"👌%@",self.topologyMore);
}

- (NSString *)unionSuffix:(NSString *)unionVC topology:(NSString *)topology{
    if (unionVC.length <= 0 || topology.length <= 0) {
        return unionVC;
    }
    if (unionVC.length == topology.length) {
        if ([topology hasSuffix:unionVC]) {
            return unionVC;
        }
    }else{
        if ([topology hasSuffix:[@"," stringByAppendingString:unionVC]]) {
            return unionVC;
        }
    }
    
    NSRange range = [unionVC rangeOfString:@","];
    if (range.location != NSNotFound) {
        return [self unionSuffix:[unionVC substringFromIndex:range.location+1] topology:topology];
    }
    return unionVC;
}

+ (BOOL)filter:(NSString *)vc{
    static NSArray *filters = nil;
    if (!filters) {
        filters = @[
                    @"RTAllRecordVC",@"RTPlaybackViewController",@"RTPlayBackVC",
                    @"RTCommandListVCViewController",@"RTJumpListVC",@"RTJumpVC",
                    @"RTMoreFuncVC",@"RTSetFileSizeViewController",@"RTSetMainViewController",
                    @"RTSettingViewController",@"JDStatusBarNotificationViewController",
                    @"RTOperationsVC",@"RTMutableRunVC",@"RTPhotosViewController",
                    @"RTMigrationDataVC",@"RTFileListVC",@"RTFilePreVC",@"RTTraceListVC",
                    @"RTUnionListVC",@"RTFeedbackVC",@"RTLoginViewController",@"RTRegistViewController",
                    @"RTForgetPasswordViewController",@"RTImagePreVC",@"RTTextPreVC",@"RTCrashLagIndexVC",
                    @"RTVCDetailVC",@"RTPerformanceVC",@"RTPerformanceAVGVC",@"RTBaseSettingViewController",
                    @"RTCrashCollectionVC",@"RTLagVC",@"RTWifiConnectionDevicesVC",@"RTDeviceInfoVC",@"RTVCPerformanceVC"
                    ];
    }
    return [filters containsObject:vc];
}

@end
