#import <UIKit/UIKit.h>
#import "RTOperationQueue.h"

typedef NS_ENUM(NSUInteger, OperationRunResultType) {
    OperationRunResultTypeNoRun = 0,
    OperationRunResultTypeRunSuccess,
    OperationRunResultTypeFailure,
};
@interface RTCommandListVCCellModel : NSObject

@property (nonatomic,strong)NSIndexPath *indexPath;
@property (nonatomic,strong)RTIdentify *identify;
@property (nonatomic,strong)RTOperationQueueModel *operationModel;
@property (nonatomic,assign)OperationRunResultType runResultType;
@property (nonatomic,assign)BOOL isSelect;
@property (nonatomic,assign)BOOL isShowSelect;

@end
