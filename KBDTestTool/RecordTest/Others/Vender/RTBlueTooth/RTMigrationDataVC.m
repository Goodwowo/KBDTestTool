#import "RTMigrationDataVC.h"
#import "RTHuView.h"
#import "RTMCTool.h"
#import "RecordTestHeader.h"
#import "ZHFileManager.h"

typedef NS_ENUM(NSUInteger, MigrationDataType) {
    MigrationDataTypeNone,
    MigrationDataTypeSend,
    MigrationDataTypeReceive,
    MigrationDataTypeSendOK,
    MigrationDataTypeReceiveOK,
};

@interface RTMigrationDataVC ()<RTMCToolDelegate>
@property(nonatomic,strong)RTHuView *huView;
@property (nonatomic,strong)UIButton *sendBtn;
@property (nonatomic,strong)UIButton *receiveBtn;
@property (nonatomic,strong)UILabel *hintlabel;

@property (nonatomic,assign)MigrationDataType type;
@property (nonatomic,assign)NSInteger sendIndex;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,strong)NSTimer *sendFileTimer;

@property (nonatomic,copy)NSString *filePath;

@end


@implementation RTMigrationDataVC

- (void)viewDidLoad{
	[super viewDidLoad];
    self.title=@"数据共享";
    self.dataArr = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    self.sendIndex = 0;
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
    [self setUI];
}

- (void)setUI{
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, 200, 40)];
    self.sendBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.sendBtn setTitle:@"我要发送" forState:(UIControlStateNormal)];
    [self.sendBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [self.sendBtn addTarget:self action:@selector(connectAction) forControlEvents:1<<6];
    [self.view addSubview:self.sendBtn];
    self.sendBtn.centerX = self.view.centerX;
    self.sendBtn.centerY = self.view.centerY-120;
    [self.sendBtn cornerRadiusWithFloat:10];
    
    self.receiveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, 200, 40)];
    self.receiveBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.receiveBtn setTitle:@"我要接收" forState:(UIControlStateNormal)];
    [self.receiveBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [self.receiveBtn addTarget:self action:@selector(receiveAction) forControlEvents:1<<6];
    [self.view addSubview:self.receiveBtn];
    self.receiveBtn.centerX = self.view.centerX;
    self.receiveBtn.centerY = self.view.centerY - 50;
    [self.receiveBtn cornerRadiusWithFloat:10];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, self.view.width - 40, 60)];
    label.text = @"(需要该设备和另外一台打开蓝牙)";
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.textColor = [UIColor grayColor];
    [self.view addSubview:label];
    self.hintlabel= label;
    label.centerX = self.sendBtn.centerX;
    label.y = self.receiveBtn.maxY + 10;
}

- (void)setSendFiles{
    NSArray *allFilePaths = [RTOperationImage allFilePaths];
    for (NSString *filePath in allFilePaths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [self.dataArr addObject:filePath];
        }
    }
}

- (void)connectAction{
    self.type = MigrationDataTypeSend;
    [RTMCTool setUp:self];
}

- (void)receiveAction{
    self.type = MigrationDataTypeReceive;
    [RTMCTool setUp:self];
}

- (void)addHudView{
    if (_huView==nil) {
        //    创建自定义的仪表盘
        _huView = [[RTHuView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _huView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _huView.num=0;
        [self.view addSubview:_huView];
    }
}

- (void)isReady{
    [self.hintlabel removeFromSuperview];
    [self.sendBtn removeFromSuperview];
    [self.receiveBtn removeFromSuperview];
    [self addHudView];
    self.hintlabel.text = @"正在传输...";
    [self.view addSubview:self.hintlabel];
    self.hintlabel.textColor = [UIColor whiteColor];
}

- (void)backAction{
    self.sendFileTimer.fireDate = [NSDate distantFuture];
    [self.sendFileTimer invalidate];
    [RTMCTool closeAdvertiser];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendFileUpData{
    if (self.filePath.length>0 || self.sendIndex>self.dataArr.count) {
        return;
    }
    if (self.sendIndex>=self.dataArr.count || self.dataArr.count == 0) {
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeSuccess title:@"发送完成"];
        [RTMCTool sendMessage:@"command_done" error:nil];
        [self stop];
        return;
    }
    NSString *filePath = self.dataArr[self.sendIndex];
    self.filePath = filePath;
    [RTMCTool sendMessage:[NSString stringWithFormat:@"command_filepath:%@",filePath] error:nil];
    self.huView.num = (int)((self.sendIndex*100)/self.dataArr.count);
    [RTMCTool sendMessage:[NSString stringWithFormat:@"command_progress:%d",self.huView.num] error:nil];
    self.sendIndex++;
}

- (void)stop{
    self.sendFileTimer.fireDate = [NSDate distantFuture];
    [self.sendFileTimer invalidate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [RTMCTool closeAdvertiser];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)receiveDone{
    [JohnAlertManager showAlertWithType:JohnTopAlertTypeSuccess title:@"接收完成"];
    [self stop];
}

- (void)removeExsitFile{
    [self setSendFiles];
    [RTMCTool sendMessage:[NSString stringWithFormat:@"command_removeExsitFile:%@",[self.dataArr jsonStringEncoded]] error:nil];
}

- (void)beginSendData{
    [self isReady];
    self.sendFileTimer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(sendFileUpData) userInfo:nil repeats:YES];
}

- (void)beginReceiveData{
    [self isReady];
}

#pragma mark - DHMCToolDelegate
- (void)session:(MCSession *)session didReceiveString:(NSString *)str{
    if ([str isEqualToString:@"command_send"]) {
        if (self.type != MigrationDataTypeSend) {
            [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:@"两个连接设备不能都是接收者!"];
            [self stop];
            return;
        }
        self.type = MigrationDataTypeSendOK;
        [self removeExsitFile];
    }else if ([str isEqualToString:@"command_receive"]) {
        if (self.type != MigrationDataTypeReceive) {
            [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:@"两个连接设备不能都是发送者!"];
            [self stop];
            return;
        }
        self.type = MigrationDataTypeReceiveOK;
    }else if ([str isEqualToString:@"command_ready"]) {
        if (self.type == MigrationDataTypeSendOK) {
            [self beginSendData];
        }else if (self.type == MigrationDataTypeReceiveOK) {
            [self beginReceiveData];
        }
    }else if ([str hasPrefix:@"command_removeExsitFile:"]) {
        NSArray *filePaths = [NSArray arrayWithJsonString:[str substringFromIndex:@"command_removeExsitFile:".length]];
        NSMutableArray *noExsit = [NSMutableArray array];
        for (NSString *filePath in filePaths) {
            if (![RTOperationImage isExsitFileFromOtherDevice:filePath]) {
                [noExsit addObject:filePath];
            }
        }
        [RTMCTool sendMessage:[NSString stringWithFormat:@"command_noExsitFile:%@",[noExsit jsonStringEncoded]] error:nil];
        [RTMCTool sendMessage:@"command_ready" error:nil];
    }else if ([str hasPrefix:@"command_noExsitFile:"]) {
        NSArray *filePaths = [NSArray arrayWithJsonString:[str substringFromIndex:@"command_noExsitFile:".length]];
        [self.dataArr setArray:filePaths];
        [RTMCTool sendMessage:@"command_ready" error:nil];
    }else if ([str hasPrefix:@"command_filepath:"]) {
        self.filePath = [str substringFromIndex:@"command_filepath:".length];
        if ([RTOperationImage isExsitFileFromOtherDevice:self.filePath]) {
            [RTMCTool sendMessage:@"command_filepath_exsit" error:nil];
        }else{
            [RTMCTool sendMessage:[NSString stringWithFormat:@"command_filepath_start:%@",self.filePath] error:nil];
        }
    }else if ([str hasPrefix:@"command_filepath_start:"]) {
        NSString *filePath = [str substringFromIndex:@"command_filepath_start:".length];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSString *fileSize = [ZHFileManager sizeOfByte:data.length];
        [RTMCTool sendMessage:[NSString stringWithFormat:@"command_filesize:%@",fileSize] error:nil];
        self.hintlabel.text = [NSString stringWithFormat:@"当前文件大小:%@",fileSize];
        if (data.length>0) {
            [RTMCTool sendData:data error:nil];
        }else{
            self.filePath = nil;
        }
    }else if ([str hasPrefix:@"command_filesize:"]) {
        self.hintlabel.text = [@"当前文件大小:" stringByAppendingString:[str substringFromIndex:@"command_filesize:".length]];
    }else if ([str isEqualToString:@"command_filepath_exsit"]) {
        self.filePath = nil;
    }else if ([str isEqualToString:@"command_datareceive"]) {
        self.filePath = nil;
    }else if ([str hasPrefix:@"command_progress:"]) {
        self.huView.num = [[str substringFromIndex:@"command_progress:".length] intValue];
    }else if ([str isEqualToString:@"command_done"]) {
        [self receiveDone];
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data{
//    NSLog(@"正在接收data:%@",[ZHFileManager sizeOfByte:data.length]);
    [RTMCTool sendMessage:@"command_datareceive" error:nil];
    [RTOperationImage addFileFromOtherDevice:self.filePath data:data];
    self.filePath = nil;
}

- (void)session:(MCSession *)session didChangeState:(MCSessionState)state{
    if (state == MCSessionStateConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.type == MigrationDataTypeSend) {
                [RTMCTool sendMessage:@"command_receive" error:nil];
            }else if (self.type == MigrationDataTypeReceive) {
                [RTMCTool sendMessage:@"command_send" error:nil];
            }
        });
    }
}

@end
