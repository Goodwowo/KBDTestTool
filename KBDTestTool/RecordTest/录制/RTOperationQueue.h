
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RTOperationQueueType) {
    RTOperationQueueTypeEvent,
    RTOperationQueueTypeTap,
    RTOperationQueueTypeScroll,
    RTOperationQueueTypeTableViewCellTap,
    RTOperationQueueTypeCollectionViewCellTap,
    RTOperationQueueTypePickerViewItemTap,
    RTOperationQueueTypeTextChange,
    RTOperationQueueTypeTextFieldDidReturn,
    RTOperationQueueTypeSlide,
};

typedef NS_ENUM(NSUInteger, RTOperationQueueRunResultType) {
    RTOperationQueueRunResultTypeNoRun,
    RTOperationQueueRunResultTypeSuccess,
    RTOperationQueueRunResultTypeFailure,
};

@interface RTOperationQueueModel : NSObject <NSCoding>

@property (nonatomic,copy)NSString *viewId;
@property (nonatomic,copy)NSString *view;
@property (nonatomic,copy)NSString *vc;
@property (nonatomic,copy)NSString *imagePath;
@property (nonatomic,assign)RTOperationQueueType type;
@property (nonatomic,strong)NSArray *parameters;
@property (nonatomic,assign)RTOperationQueueRunResultType runResult;

- (instancetype)copyNew;

@end


@interface RTIdentify : NSObject

@property (nonatomic,copy)NSString *identify;
@property (nonatomic,copy)NSString *forVC;

- (instancetype)copyNew;

- (instancetype)initWithIdentify:(NSString *)identify forVC:(NSString *)forVC;
- (instancetype)initWithIdentify:(NSString *)identifyString;

@end

@interface RTOperationQueue : NSObject

@property (nonatomic,copy)NSString *forVC;
@property (nonatomic,assign)BOOL isRecord;
@property (nonatomic,assign)BOOL isStopRecordTemp;

+ (RTOperationQueue *)shareInstance;
+ (NSMutableDictionary *)operationQueues;
+ (void)addOperationQueuesFromOtherDataBase:(NSString *)dataBase;

+ (void)startOrStopRecord;
+ (void)addOperation:(UIView *)view type:(RTOperationQueueType)type parameters:(NSArray *)parameters repeat:(BOOL)repeat;

+ (BOOL)saveOperationQueue:(RTIdentify *)identify;
+ (NSMutableArray *)getOperationQueue:(RTIdentify *)identify;
+ (void)deleteOperationQueues:(NSArray *)identifys;
+ (void)deleteOperationQueueModelIndexs:(NSArray *)indexs forIdentify:(RTIdentify *)identify;
+ (BOOL)reChanggeOperationQueue:(RTIdentify *)identify;
+ (BOOL)isExsitOperationQueue:(RTIdentify *)identify;

+ (NSArray *)allIdentifyModels;
+ (NSArray *)allIdentifyModelsForVC:(NSString *)vc;
+ (NSArray *)alloperationQueueModels;
+ (void)save;

@end
