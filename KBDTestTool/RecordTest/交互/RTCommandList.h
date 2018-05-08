
#import <UIKit/UIKit.h>

@class RTIdentify;
#define RC_DB_VERSION @"0.2"
@interface RTCommandList : UIView <UITableViewDelegate,UITableViewDataSource>
{
    BOOL _isDragging;
    BOOL _singleTapBeenCanceled;
    CGPoint _beginLocation;
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
}

@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UILabel *curCommand;
@property (nonatomic,assign)NSInteger curRow;
@property (nonatomic) BOOL isRunOperationQueue;
@property (nonatomic,strong)RTIdentify *operationQueueIdentify;
@property (nonatomic) BOOL draggable;
@property (nonatomic) BOOL autoDocking;

@property (nonatomic, copy) void(^longPressBlock)(RTCommandList *view);
@property (nonatomic, copy) void(^tapBlock)(RTCommandList *view);
@property (nonatomic, copy) void(^doubleTapBlock)(RTCommandList *view);

@property (nonatomic, copy) void(^draggingBlock)(RTCommandList *view);
@property (nonatomic, copy) void(^dragDoneBlock)(RTCommandList *view);

@property (nonatomic, copy) void(^autoDockingBlock)(RTCommandList *view);
@property (nonatomic, copy) void(^autoDockingDoneBlock)(RTCommandList *view);

+ (RTCommandList *)shareInstance;
- (id)initInKeyWindowWithFrame:(CGRect)frame;
- (BOOL)isDragging;

+ (NSString *)version;

+ (void)removeAllFromKeyWindow;
+ (void)removeAllFromView:(id)superView;

- (void)reloadData;
- (void)initData;
- (void)setOperationQueue:(RTIdentify *)identify;

- (BOOL)runStep:(BOOL)isAuto;

@end
