
#import "RTDeviceModel.h"
#import "RTLANProperties.h"
#import "RTLANScanner.h"
#import "RTMainPresenter.h"

@interface RTMainPresenter () <RTLANScannerDelegate>

@property (nonatomic, weak) id<RTMainPresenterDelegate> delegate;
@property (nonatomic, strong) RTLANScanner* lanScanner;
@property (nonatomic, assign, readwrite) BOOL isScanRunning;
@property (nonatomic, assign, readwrite) float progressValue;
@end

@implementation RTMainPresenter {
    NSMutableArray* connectedDevicesMutable;
}

#pragma mark - Init method
- (instancetype)initWithDelegate:(id<RTMainPresenterDelegate>)delegate{
    self = [super init];
    if (self) {
        self.isScanRunning = NO;
        self.delegate = delegate;
        self.lanScanner = [[RTLANScanner alloc] initWithDelegate:self];
    }
    return self;
}

#pragma mark - Button Actions
- (void)scanButtonClicked{
    if (self.isScanRunning) {
        [self stopNetworkScan];
    } else {
        [self startNetworkScan];
    }
}
- (void)startNetworkScan{
    self.isScanRunning = YES;
    connectedDevicesMutable = [[NSMutableArray alloc] init];
    [self.lanScanner start];
}

- (void)stopNetworkScan{
    [self.lanScanner stop];
    self.isScanRunning = NO;
}

#pragma mark - SSID
- (NSString*)ssidName{
    return [NSString stringWithFormat:@"%@", [RTLANProperties fetchSSIDInfo]];
}

#pragma mark - RTLANScannerDelegate methods
- (void)lanScanDidFindNewDevice:(RTDeviceModel*)device{
    if (![connectedDevicesMutable containsObject:device]) {
        [connectedDevicesMutable addObject:device];
    }
    self.connectedDevices = [NSArray arrayWithArray:connectedDevicesMutable];
}

- (void)lanScanDidFinishScanningWithStatus:(MMLanScannerStatus)status{
    self.isScanRunning = NO;
    if (status == MMLanScannerStatusFinished) {
        [self.delegate mainPresenterIPSearchFinished];
    } else if (status == MMLanScannerStatusCancelled) {
        [self.delegate mainPresenterIPSearchCancelled];
    }
}

- (void)lanScanProgressPinged:(float)pingedHosts from:(NSInteger)overallHosts{
    self.progressValue = pingedHosts / overallHosts;
}

- (void)lanScanDidFailedToScan{
    self.isScanRunning = NO;
    [self.delegate mainPresenterIPSearchFailed];
}

@end
