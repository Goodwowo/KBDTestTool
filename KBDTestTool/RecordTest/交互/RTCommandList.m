
#import "RTCommandList.h"
#import "RTCommandListVCCellModel.h"
#import "RecordTestHeader.h"

#define RC_WAITING_KEYWINDOW_AVAILABLE 0.f
#define RC_AUTODOCKING_ANIMATE_DURATION 0.2f
#define RC_DOUBLE_TAP_TIME_INTERVAL 0.16f


@interface RTCommandListTableViewCell : UITableViewCell
@property (nonatomic,strong)UIImageView *hintImg;
@property (nonatomic,strong)UILabel *hintLabel;
@property (nonatomic,weak)RTCommandListVCCellModel *dataModel;
@end

@implementation RTCommandListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        self.hintImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 4, 5, 5)];
        [self.contentView addSubview:self.hintImg];
        [self.hintImg cornerRadius];
        self.hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width - 20, 12)];
        self.hintLabel.textColor = [UIColor whiteColor];
        self.hintLabel.font = [UIFont systemFontOfSize:10];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self.contentView addSubview:self.hintLabel];
        self.hintImg.image = [UIImage imageNamed:@"SuspendBall_startrecord"];
    }
    return self;
}

- (void)refreshUI:(RTCommandListVCCellModel *)dataModel{
    _dataModel = dataModel;
    if (dataModel.identify) {
        self.hintLabel.text = [dataModel.identify debugDescription];
    }else if (dataModel.operationModel){
        self.hintLabel.text = [dataModel.operationModel debugDescription];
    }
    switch (dataModel.runResultType) {
        case OperationRunResultTypeNoRun:
            self.hintImg.backgroundColor = [UIColor whiteColor];
            self.hintLabel.textColor = [UIColor whiteColor];
            break;
        case OperationRunResultTypeRunSuccess:
            self.hintImg.backgroundColor = [UIColor greenColor];
            self.hintLabel.textColor = [UIColor greenColor];
            break;
        case OperationRunResultTypeFailure:
            self.hintImg.backgroundColor = [UIColor redColor];
            self.hintLabel.textColor = [UIColor redColor];
            break;
        default:
            break;
    }
}

@end

@implementation RTCommandList

@synthesize draggable = _draggable;
@synthesize autoDocking = _autoDocking;

@synthesize longPressBlock = _longPressBlock;
@synthesize tapBlock = _tapBlock;
@synthesize doubleTapBlock = _doubleTapBlock;

@synthesize draggingBlock = _draggingBlock;
@synthesize dragDoneBlock = _dragDoneBlock;

@synthesize autoDockingBlock = _autoDockingBlock;
@synthesize autoDockingDoneBlock = _autoDockingDoneBlock;

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

+ (RTCommandList *)shareInstance{
    static dispatch_once_t pred = 0;
    __strong static RTCommandList *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[RTCommandList alloc] init];
        [_sharedObject defaultSetting];
    });
    return _sharedObject;
}

- (id)initInKeyWindowWithFrame:(CGRect)frame {
    self = [RTCommandList shareInstance];
    self.frame = frame;
    if (self) {
        [self performSelector:@selector(addButtonToKeyWindow) withObject:nil afterDelay:RC_WAITING_KEYWINDOW_AVAILABLE];
        [self defaultSetting];
        
        UILabel *curCommand = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 12)];
        curCommand.textColor = [UIColor redColor];
        curCommand.font = [UIFont systemFontOfSize:10];
        [self addSubview:curCommand];
        curCommand.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        self.curCommand = curCommand;
        
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 12, frame.size.width, frame.size.height-12)];
        [self addSubview:tableView];
        tableView.tableFooterView = [UIView new];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[RTCommandListTableViewCell class] forCellReuseIdentifier:@"RTCommandListCell"];
        self.tableView = tableView;
        self.tableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
    return self;
}

- (void)defaultSetting {
    _draggable = YES;
    _autoDocking = YES;
    _singleTapBeenCanceled = NO;
    
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [_longPressGestureRecognizer addTarget:self action:@selector(gestureRecognizerHandle:)];
    [_longPressGestureRecognizer setAllowableMovement:0];
    [self addGestureRecognizer:_longPressGestureRecognizer];
}

- (void)addButtonToKeyWindow {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

#pragma mark - Ges
- (void)gestureRecognizerHandle:(UILongPressGestureRecognizer *)gestureRecognizer {
    switch ([gestureRecognizer state]) {
        case UIGestureRecognizerStateBegan: {
            if (_longPressBlock) {
                _longPressBlock(self);
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Blocks
#pragma mark Touch Blocks
- (void)setTapBlock:(void (^)(RTCommandList *))tapBlock {
    _tapBlock = tapBlock;
    
    if (_tapBlock) {
        [self addUITapGestureRecognizerWithTarget:self withAction:@selector(buttonTouched)];
    }
}

#pragma mark - Touch
- (void)buttonTouched {
    [self performSelector:@selector(executeButtonTouchedBlock) withObject:nil afterDelay:(_doubleTapBlock ? RC_DOUBLE_TAP_TIME_INTERVAL : 0)];
}

- (void)executeButtonTouchedBlock {
    if (!_singleTapBeenCanceled && _tapBlock && !_isDragging) {
        _tapBlock(self);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    _isDragging = NO;
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2) {
        if (_doubleTapBlock) {
            _singleTapBeenCanceled = YES;
            _doubleTapBlock(self);
        }
    } else {
        _singleTapBeenCanceled = NO;
    }
    _beginLocation = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_draggable) {
        _isDragging = YES;
        
        UITouch *touch = [touches anyObject];
        CGPoint currentLocation = [touch locationInView:self];
        
        //设置自身的位置
        float offsetX = currentLocation.x - _beginLocation.x;
        float offsetY = currentLocation.y - _beginLocation.y;
        
        self.center = CGPointMake(self.center.x + offsetX, self.center.y + offsetY);
        
        //设置自身移动不超过边界
        CGRect superviewFrame = self.superview.frame;
        CGRect frame = self.frame;
        CGFloat leftLimitX = frame.size.width / 2;
        CGFloat rightLimitX = superviewFrame.size.width - leftLimitX;
        CGFloat topLimitY = frame.size.height / 2;
        CGFloat bottomLimitY = superviewFrame.size.height - topLimitY;
        
        if (self.center.x > rightLimitX) {
            self.center = CGPointMake(rightLimitX, self.center.y);
        }else if (self.center.x <= leftLimitX) {
            self.center = CGPointMake(leftLimitX, self.center.y);
        }
        
        if (self.center.y > bottomLimitY) {
            self.center = CGPointMake(self.center.x, bottomLimitY);
        }else if (self.center.y <= topLimitY){
            self.center = CGPointMake(self.center.x, topLimitY);
        }
        
        if (_draggingBlock) {
            _draggingBlock(self);
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded: touches withEvent: event];
    
    if (_isDragging && _dragDoneBlock) {
        _dragDoneBlock(self);
        _singleTapBeenCanceled = YES;
    }
    
    if (_isDragging && _autoDocking) {
        CGRect superviewFrame = self.superview.frame;
        CGRect frame = self.frame;
        CGFloat middleX = superviewFrame.size.width / 2;
        
        if (self.center.x >= middleX) {
            [UIView animateWithDuration:RC_AUTODOCKING_ANIMATE_DURATION animations:^{
                self.center = CGPointMake(superviewFrame.size.width - frame.size.width / 2, self.center.y);
                if (_autoDockingBlock) {
                    _autoDockingBlock(self);
                }
            } completion:^(BOOL finished) {
                if (_autoDockingDoneBlock) {
                    _autoDockingDoneBlock(self);
                }
            }];
        } else {
            [UIView animateWithDuration:RC_AUTODOCKING_ANIMATE_DURATION animations:^{
                self.center = CGPointMake(frame.size.width / 2, self.center.y);
                if (_autoDockingBlock) {
                    _autoDockingBlock(self);
                }
            } completion:^(BOOL finished) {
                if (_autoDockingDoneBlock) {
                    _autoDockingDoneBlock(self);
                }
            }];
        }
    }
    
    _isDragging = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    _isDragging = NO;
    [super touchesCancelled:touches withEvent:event];
}

- (BOOL)isDragging {
    return _isDragging;
}

#pragma mark - version
+ (NSString *)version {
    return RC_DB_VERSION;
}

#pragma mark - remove
+ (void)removeAllFromKeyWindow {
    for (id view in [[UIApplication sharedApplication].keyWindow subviews]) {
        if ([view isKindOfClass:[RTCommandList class]]) {
            [view removeFromSuperview];
        }
    }
}

+ (void)removeAllFromView:(id)superView {
    for (id view in [superView subviews]) {
        if ([view isKindOfClass:[RTCommandList class]]) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark TableViewDelegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdtifier=@"RTCommandListCell";
    RTCommandListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdtifier];
    if (!cell) {
        cell = [[RTCommandListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdtifier];
    }
    RTCommandListVCCellModel *model = self.dataArr[indexPath.row];
    model.indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    [cell refreshUI:model];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 12;
}

- (void)reloadData{
    [self.tableView reloadData];
}

- (void)initData{
    if (self.isRunOperationQueue) return;
    [self.dataArr removeAllObjects];
    self.curCommand.text = [NSString stringWithFormat:@"VC:%@",[RTTopVC shareInstance].topVC];
    self.draggable = NO;
    NSArray *identifys = [RTOperationQueue allIdentifyModelsForVC:[RTTopVC shareInstance].topVC];
    for (RTIdentify *identify in identifys) {
        RTCommandListVCCellModel *model = [RTCommandListVCCellModel new];
        model.identify = [identify copyNew];
        [self.dataArr addObject:model];
    }
    [self reloadData];
    [RTCommandList shareInstance].curRow = 0;
    static BOOL isTimerRun = NO;
    if (!isTimerRun) {
        isTimerRun = YES;
        [self timer];
    }
}

- (void)timer{
    static NSString *curTopVC;
    if (![[RTTopVC shareInstance].topVC isEqualToString:curTopVC]) {
        [self initData];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self timer];
    });
}

- (void)setIsRunOperationQueue:(BOOL)isRunOperationQueue{
    _isRunOperationQueue = isRunOperationQueue;
    if(!isRunOperationQueue) self.operationQueueIdentify = nil;
    if (isRunOperationQueue) {
        [[SuspendBall shareInstance] setEnable:YES index:0 hide:NO];
//        [[SuspendBall shareInstance] setEnable:YES index:1 hide:NO];
        [[SuspendBall shareInstance] setEnable:NO index:3 hide:YES];
        [[SuspendBall shareInstance] setEnable:NO index:4 hide:YES];
        if ([RTConfigManager shareInstance].isRecoderVideoPlayBack) {
            [[RTScreenRecorder sharedInstance] startRecording];
        }
    }else{
        [[SuspendBall shareInstance] setEnable:NO index:0 hide:NO];
//        [[SuspendBall shareInstance] setEnable:NO index:1 hide:NO];
        [[SuspendBall shareInstance] setEnable:YES index:3 hide:NO];
        [[SuspendBall shareInstance] setEnable:YES index:4 hide:NO];
        if ([RTConfigManager shareInstance].isRecoderVideoPlayBack) {
            BOOL shouldSave = _curRow>0;
            [[RTScreenRecorder sharedInstance] stopRecordingWithCompletion:^(NSString *videoPath) {
                if (shouldSave) {
                    [[RTRecordVideo shareInstance] saveVideoPlayBackForStamp:[NSString stringWithFormat:@"%lld",[RTPlayBack shareInstance].stamp] videoPath:videoPath];
                }
            }];
        }
    }
}

- (void)setOperationQueue:(RTIdentify *)identify{
    [RTPlayBack shareInstance].stamp = 0;
    self.isRunOperationQueue = YES;
    self.operationQueueIdentify = [identify copyNew];
    self.curCommand.text = [NSString stringWithFormat:@"正在执行:%@",[identify debugDescription]];
    [self.dataArr removeAllObjects];
    NSArray *operationQueues = [RTOperationQueue getOperationQueue:identify];
    for (RTOperationQueueModel *model in operationQueues) {
        RTCommandListVCCellModel *modelTemp = [RTCommandListVCCellModel new];
        modelTemp.operationModel = [model copyNew];
        [self.dataArr addObject:modelTemp];
    }
    [self reloadData];
    [RTCommandList shareInstance].curRow = 0;
}

- (void)setCurRow:(NSInteger)row{
    _curRow = row;
    [self.tableView reloadData];
    if (self.dataArr.count > row) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:(UITableViewScrollPositionTop) animated:YES];
    }
}

- (BOOL)runStep:(BOOL)isAuto{
    static int runFailure = 0;
    static BOOL isAutoStatic = NO;
    BOOL result = NO;
    isAutoStatic = isAuto;
    if (self.isRunOperationQueue) {
        if (_curRow == 0) {
            if ([RTPlayBack shareInstance].stamp == 0) {
                [RTPlayBack shareInstance].stamp = [DateTools getCurInterval];
                [RTPlayBack shareInstance].identify = [self.operationQueueIdentify copyNew];
            }
        }
        if (self.dataArr.count > _curRow) {
            RTCommandListVCCellModel *model = self.dataArr[_curRow];
            RTOperationQueueModel *operationQueue = model.operationModel;
            UIView *targetView = [[RTGetTargetView new] getTargetView:operationQueue.viewId];
            if (targetView) {
                operationQueue.imagePath = [RTOperationImage saveOperationPlayBackImage:[[RTViewHierarchy new] snap:[targetView targetViewWithOperation:operationQueue] type:operationQueue.type]];
                if ([targetView runOperation:operationQueue]) {
                    model.runResultType = OperationRunResultTypeRunSuccess;
                    [ZHStatusBarNotification showWithStatus:@"执行成功" dismissAfter:1 styleName:JDStatusBarStyleSuccess];
                    self.curRow++;
                    runFailure = 0;
                    result = YES;
                    operationQueue.runResult = RTOperationQueueRunResultTypeSuccess;
                }else{
                    model.runResultType = OperationRunResultTypeFailure;
                    runFailure ++;
                    [ZHStatusBarNotification showWithStatus:[NSString stringWithFormat:@"执行失败 次数:%d/10",runFailure] dismissAfter:1 styleName:JDStatusBarStyleError];
                    operationQueue.runResult = RTOperationQueueRunResultTypeFailure;
                }
            }else{
                model.runResultType = OperationRunResultTypeFailure;
                runFailure ++;
                [ZHStatusBarNotification showWithStatus:[NSString stringWithFormat:@"没找到控件 次数:%d/10",runFailure] dismissAfter:1 styleName:JDStatusBarStyleWarning];
                operationQueue.runResult = RTOperationQueueRunResultTypeFailure;
            }
            if (runFailure >= 10) {//执行10次还是失败,说明这句命令是真的不能执行了,或者是因为网络问题,实在加载不出来对应的控件了,这个是用来自动运行的
                runFailure = 0;
                self.curRow++;
            }
            [self savePlayBackModels];
        }else{
            if(self.dataArr.count > 0){
                [ZHStatusBarNotification showWithStatus:@"已执行完毕" dismissAfter:1 styleName:JDStatusBarStyleSuccess];
            }else{
                [ZHStatusBarNotification showWithStatus:@"该执行为空" dismissAfter:1 styleName:JDStatusBarStyleSuccess];
            }
            [RTCommandList shareInstance].isRunOperationQueue = NO;
            [[RTCommandList shareInstance] initData];
        }
        if (isAutoStatic) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self runStep:isAuto];
            });
        }
    }
    return result;
}

- (void)savePlayBackModels{
    NSMutableArray *operationQueues = [NSMutableArray arrayWithCapacity:self.dataArr.count];
    for (RTCommandListVCCellModel *model in self.dataArr) {
        [operationQueues addObject:model.operationModel];
    }
    [[RTPlayBack shareInstance] savePlayBack:operationQueues];
}

@end
