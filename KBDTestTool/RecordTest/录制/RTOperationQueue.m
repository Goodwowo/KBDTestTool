
#import "RTOperationQueue.h"
#import "NSArray+ZH.h"
#import "RecordTestHeader.h"
#import "ZHSaveDataToFMDB.h"
#import "ZHAlertAction.h"

@implementation RTOperationQueueModel

- (instancetype)copyNew{
    RTOperationQueueModel *copy = [RTOperationQueueModel new];
    copy.view = self.view;
    copy.viewId = self.viewId;
    copy.parameters = self.parameters;
    copy.type = self.type;
    copy.vc = self.vc;
    copy.imagePath = self.imagePath;
    copy.runResult = self.runResult;
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.viewId forKey:@"viewId"];
    [aCoder encodeObject:self.view forKey:@"view"];
    [aCoder encodeObject:self.parameters forKey:@"parameters"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:self.vc forKey:@"vc"];
    [aCoder encodeObject:self.imagePath forKey:@"imagePath"];
    [aCoder encodeInteger:self.runResult forKey:@"runResult"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.viewId = [aDecoder decodeObjectForKey:@"viewId"];
        self.view = [aDecoder decodeObjectForKey:@"view"];
        self.parameters = [aDecoder decodeObjectForKey:@"parameters"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.vc = [aDecoder decodeObjectForKey:@"vc"];
        self.imagePath = [aDecoder decodeObjectForKey:@"imagePath"];
        self.runResult = [aDecoder decodeIntegerForKey:@"runResult"];
    }
    return self;
}

//- (NSString *)description{
//    return [NSString stringWithFormat:@"%@-%@-%@",self.vc,[self typeString],[self parameterString]];
//}

- (NSString *)description{
//    return [NSString stringWithFormat:@"%@-%@-%@",self.viewId,[self typeString],[self parameterString]];
    return [NSString stringWithFormat:@"%@-%@-%@-%@",self.view,[self typeString],[self vc],@(self.runResult)];
}

- (NSString *)debugDescription{
    return [NSString stringWithFormat:@"%@-%@-%@-%@",self.view,[self typeString],[self parameterString],self.vc];
}

- (NSString *)parameterString{
    if (self.parameters) {
        NSMutableString *string = [NSMutableString string];
        for (id obj in self.parameters) {
            [string appendFormat:@"%@ ",obj];
        }
        return string;
    }
    return @"";
}

//- (NSString *)typeString{
//    switch (self.type) {
//        case RTOperationQueueTypeEvent: case RTOperationQueueTypeTableViewCellTap:
//            return @"控件点击";
//            break;
//        case RTOperationQueueTypeScroll:
//            return @"滚动";
//            break;
//        default:
//            break;
//    }
//    return @"unknow";
//}

- (NSString *)typeString{
    switch (self.type) {
        case RTOperationQueueTypeEvent:
            return @"Click";
            break;
        case RTOperationQueueTypeScroll:
            return @"Scroll";
            break;
        case RTOperationQueueTypeTap:
            return @"Tap";
            break;
        case RTOperationQueueTypeTableViewCellTap:
            return @"CellTap";
            break;
        default:
            break;
    }
    return @"unknow";
}

@end

@implementation RTIdentify

- (instancetype)initWithIdentify:(NSString *)identify forVC:(NSString *)forVC{
    self = [super init];
    if (self) {
        self.identify = identify;
        self.forVC = forVC;
    }
    return self;
}

- (instancetype)initWithIdentify:(NSString *)identifyString{
    self = [super init];
    if (self) {
        NSArray *splits = [identifyString componentsSeparatedByString:@"_&^_^&_"];
        if (splits.count >= 2) {
            self.identify = splits[0];
            self.forVC = splits[1];
        }
    }
    return self;
}

- (instancetype)copyNew{
    RTIdentify *copy = [RTIdentify new];
    copy.identify = self.identify;
    copy.forVC = self.forVC;
    return copy;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@_&^_^&_%@",self.identify,self.forVC];
}

- (NSString *)debugDescription{
    return [NSString stringWithFormat:@"%@ : %@",self.identify,self.forVC];
}

@end

@interface RTOperationQueue ()

@property (nonatomic,strong)NSMutableArray *operationQueue;
@property (nonatomic,strong)NSMutableDictionary *operationQueuesCache;//为了解决每次都要访问数据库而导致速度变慢

@end

@implementation RTOperationQueue

+ (RTOperationQueue *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTOperationQueue *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTOperationQueue alloc] init];
    });
    return _sharedObject;
}

- (NSMutableArray *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [NSMutableArray array];
    }
    return _operationQueue;
}

- (void)setIsRecord:(BOOL)isRecord{
    _isRecord = isRecord;
    if (!isRecord) {
        if([SuspendBall shareInstance].showImage) [[SuspendBall shareInstance] setImage:@"SuspendBall_startrecord" index:3];
        else [[SuspendBall shareInstance] setTitle:@"开始录制" index:3];
        [self.operationQueue removeAllObjects];
        [[RTCommandList shareInstance] initData];
        [RTCommandList shareInstance].alpha = 1;
        [SuspendBall shareInstance].showFunction = NO;
        [[SuspendBall shareInstance] suspendBallShow];
        if ([RTConfigManager shareInstance].isRecoderVideo) {
            [[RTScreenRecorder sharedInstance] stopRecordingWithCompletion:nil];
        }
    }else{
        if([SuspendBall shareInstance].showImage) [[SuspendBall shareInstance] setImage:@"SuspendBall_stoprecord" index:3];
        else [[SuspendBall shareInstance] setTitle:@"停止录制" index:3];
        [self.operationQueue removeAllObjects];
        [RTCommandList shareInstance].alpha = 0;
        [[SuspendBall shareInstance] suspendBallShow];
        if([SuspendBall shareInstance].showImage) [[SuspendBall shareInstance] setHomeImage:@"SuspendBall_stoprecord"];
        else [[SuspendBall shareInstance] setTitle:@"停止录制" forState:0];
        if ([RTConfigManager shareInstance].isRecoderVideo) {
            [[RTScreenRecorder sharedInstance] startRecording];
        }
    }
}

+ (void)startOrStopRecord{
    if (![RTOperationQueue shareInstance].isRecord) {//开始录制
        [RTOperationQueue shareInstance].isRecord = YES;
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:@"开始录制!"];
        [RTOperationQueue shareInstance].forVC = [NSString stringWithFormat:@"%@",[RTTopVC shareInstance].topVC];
    }else{//结束录制
        if([RTOperationQueue shareInstance].operationQueue.count<=0){
            [RTOperationQueue shareInstance].isRecord = NO;
            [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:@"录制为空!"];
            return;
        }
        [RTOperationQueue shareInstance].isStopRecordTemp = YES;
        [ZHAlertAction alertWithTitle:@"是否保存?" withMsg:nil addToViewController:[UIViewController getCurrentVC] ActionSheet:NO otherButtonBlocks:@[^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction showOneTextEntryAlertTitle:@"请命名" withMsg:@"唯一标识符" addToViewController:[UIViewController getCurrentVC] withCancleBlock:^{
                    [RTOperationQueue shareInstance].isStopRecordTemp = NO;
                } withOkBlock:^(NSString *str) {
                    RTIdentify *identify = [[RTIdentify alloc] initWithIdentify:str forVC:[RTOperationQueue shareInstance].forVC];
                    if ([RTOperationQueue saveOperationQueue:identify]) {
                        [RTOperationQueue shareInstance].isRecord = NO;
                    }
                    [RTOperationQueue shareInstance].isStopRecordTemp = NO;
                } cancelButtonTitle:@"取消" OkButtonTitle:@"确定" onePlaceHold:@"唯一标识符"];
            });
        },^{
            [RTOperationQueue shareInstance].isRecord = NO;
            [RTOperationQueue shareInstance].isStopRecordTemp = NO;
            [RTOperationImage deleteOverdueImage];
        }] otherButtonTitles:@[@"保存",@"取消"]];
    }
}

+ (void)addOperation:(UIView *)view type:(RTOperationQueueType)type parameters:(NSArray *)parameters repeat:(BOOL)repeat{
    [RTSearchVCPath addOperation:view type:type parameters:parameters repeat:repeat];
    if (!IsRecord || (![RTOperationQueue shareInstance].isRecord) || ([RTOperationQueue shareInstance].isStopRecordTemp)) {
        return;
    }
//    [[RTDisPlayAllView new] disPlayAllView];
    if(view.layerDirector.length <= 0) return;
    if (repeat == NO) {
        NSArray *operationQueue = [RTOperationQueue shareInstance].operationQueue;
        for (NSInteger i = operationQueue.count - 1; i >= 0; i--) {
            RTOperationQueueModel *model = operationQueue[i];
            if (model.type != type) {
                break;
            }
            if ([model.viewId isEqualToString:view.layerDirector] && model.type == type) {
                model.parameters = parameters;
//                NSLog(@"%@",[RTOperationQueue shareInstance].operationQueue);
                if (model.type != RTOperationQueueTypeScroll && [RTOperationQueue shareInstance].isRecord) {
                    [ZHStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%@",[model debugDescription]] dismissAfter:1 styleName:JDStatusBarStyleSuccess];
                }
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
    model.imagePath = [RTOperationImage saveOperationImage:[[RTViewHierarchy new] snap:[view targetViewWithOperation:model] type:type]];
    [[RTOperationQueue shareInstance].operationQueue addObject:model];
    if (model.type != RTOperationQueueTypeScroll && [RTOperationQueue shareInstance].isRecord) {
        [ZHStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%@",[model debugDescription]] dismissAfter:1 styleName:JDStatusBarStyleSuccess];
    }
//    NSLog(@"%@",[RTOperationQueue shareInstance].operationQueue);
}

+ (NSMutableDictionary *)operationQueues{
    if ([RTOperationQueue shareInstance].operationQueuesCache) {
        return [RTOperationQueue shareInstance].operationQueuesCache;
    }
    NSMutableDictionary *operationQueues = [ZHSaveDataToFMDB selectDataWithIdentity:@"operationQueue"];
    if (!operationQueues) {
        operationQueues = [NSMutableDictionary dictionary];
    }
    [RTOperationQueue shareInstance].operationQueuesCache = operationQueues;
    return operationQueues;
}

- (void)save{
    if ([RTOperationQueue shareInstance].operationQueuesCache) {
        [ZHSaveDataToFMDB insertDataWithData:[RTOperationQueue shareInstance].operationQueuesCache WithIdentity:@"operationQueue"];
    }
}

+ (void)save{
    [[RTOperationQueue shareInstance] save];
}

+ (void)addOperationQueuesFromOtherDataBase:(NSString *)dataBase{
    NSDictionary *operationQueuesOther = [RTOpenDataBase selectDataWithIdentity:@"operationQueue" dataBasePath:dataBase];
    if (operationQueuesOther.count>0) {
        NSMutableDictionary *operationQueues = [self operationQueues];
        [operationQueues setValuesForKeysWithDictionary:operationQueuesOther];
        [self save];
    }
}

+ (BOOL)saveOperationQueue:(RTIdentify *)identify{
    NSMutableDictionary *operationQueues = [self operationQueues];
    if (operationQueues[[identify description]]) {
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:@"已经存在!"];
        return NO;
    }
    [operationQueues setValue:[[RTOperationQueue shareInstance].operationQueue mutableCopy] forKey:[identify description]];
    [self save];
    [JohnAlertManager showAlertWithType:JohnTopAlertTypeSuccess title:@"保存成功!"];
    [[RTScreenRecorder sharedInstance] stopRecordingWithCompletion:^(NSString *videoPath) {
        [[RTRecordVideo shareInstance] saveVideoForIdentify:identify videoPath:videoPath];
    }];
    return YES;
}

+ (NSMutableArray *)getOperationQueue:(RTIdentify *)identify{
    NSMutableDictionary *operationQueues = [self operationQueues];
    return operationQueues[[identify description]];
}
+ (void)deleteOperationQueueModelIndexs:(NSArray *)indexs forIdentify:(RTIdentify *)identify{
    NSMutableDictionary *operationQueues = [self operationQueues];
    NSMutableArray *operationModels = operationQueues[[identify description]];
    BOOL isSuccess = NO;
    if (operationModels) {
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (NSNumber *num in indexs) {
            NSInteger index = [num integerValue];
            if (operationModels.count > index) {
                [indexSet addIndex:index];
            }
        }
        if (indexSet.count>0) {
            isSuccess = YES;
            [operationModels removeObjectsAtIndexes:indexSet];
        }
    }
    if (isSuccess) {
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeSuccess title:@"删除成功!"];
        [self save];
        [RTOperationImage deleteOverdueImage];
    }else{
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:@"删除下标不存在!"];
    }
}
+ (void)deleteOperationQueue:(RTIdentify *)identify{
    NSMutableDictionary *operationQueues = [self operationQueues];
    if (operationQueues[[identify description]]) {
        [operationQueues removeObjectForKey:[identify description]];
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeSuccess title:@"删除成功!"];
        [self save];
        [RTOperationImage deleteOverdueImage];
    }else{
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:@"删除对象不存在!"];
    }
}
+ (void)deleteOperationQueues:(NSArray *)identifys{
    NSMutableDictionary *operationQueues = [self operationQueues];
    NSInteger count = 0;
    for (RTIdentify *identify in identifys) {
        if (operationQueues[[identify description]]) {
            [operationQueues removeObjectForKey:[identify description]];
            count ++;
        }
    }
    if (count == identifys.count) {
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeSuccess title:@"删除成功!"];
    }else{
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeSuccess title:[NSString stringWithFormat:@"成功删除了%zd个,%zd个不存在!",count,identifys.count - count]];
    }
    [self save];
    [RTOperationImage deleteOverdueImage];
    [[RTRecordVideo shareInstance] deleteVideos:identifys];
}

+ (BOOL)reChanggeOperationQueue:(RTIdentify *)identify{
    NSMutableDictionary *operationQueues = [self operationQueues];
    [operationQueues setValue:[[RTOperationQueue shareInstance].operationQueue mutableCopy] forKey:[identify description]];
    [self save];
    [JohnAlertManager showAlertWithType:JohnTopAlertTypeSuccess title:@"保存成功!"];
    return YES;
}

+ (BOOL)isExsitOperationQueue:(RTIdentify *)identify{
    NSMutableDictionary *operationQueues = [self operationQueues];
    if (operationQueues[[identify description]]) {
        return YES;
    }else{
        return NO;
    }
}

+ (NSArray *)allIdentifyModels{
    NSMutableDictionary *operationQueues = [self operationQueues];
    NSArray *allKyes = [operationQueues allKeys];
    NSMutableArray *allIdentifyModels = [NSMutableArray arrayWithCapacity:allKyes.count];
    for (NSString *key in allKyes) {
        NSArray *splits = [key componentsSeparatedByString:@"_&^_^&_"];
        if (splits.count >= 2) {
            RTIdentify *identifyModel = [RTIdentify new];
            identifyModel.identify = splits[0];
            identifyModel.forVC = splits[1];
            [allIdentifyModels addObject:identifyModel];
        }
    }
    return allIdentifyModels;
}

+ (NSArray *)alloperationQueueModels{
    NSMutableDictionary *operationQueues = [self operationQueues];
    NSArray *allValues = [operationQueues allValues];
    NSMutableArray *alloperationQueueModels = [NSMutableArray array];
    for (NSArray *operationQueueModels in allValues) {
        if (operationQueueModels.count>0) {
            [alloperationQueueModels addObjectsFromArray:operationQueueModels];
        }
    }
    return alloperationQueueModels;
}

+ (NSArray *)allIdentifyModelsForVC:(NSString *)vc{
    if(vc.length <= 0)return nil;
    NSArray *allIdentifyModels = [self allIdentifyModels];
    NSMutableArray *filters = [NSMutableArray arrayWithCapacity:allIdentifyModels.count];
    for (RTIdentify *identify in allIdentifyModels) {
        if ([identify.forVC isEqualToString:vc]) {
            [filters addObject:identify];
        }
    }
    return filters;
}

@end
