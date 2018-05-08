
typedef enum {
    MMLanScannerStatusFinished,
    MMLanScannerStatusCancelled
} MMLanScannerStatus;

#import <Foundation/Foundation.h>

@class RTDeviceModel;

@protocol RTLANScannerDelegate;

#pragma mark - RTLANScanner Protocol
@protocol RTLANScannerDelegate <NSObject>
@required

- (void)lanScanDidFindNewDevice:(RTDeviceModel*)device;

- (void)lanScanDidFinishScanningWithStatus:(MMLanScannerStatus)status;

- (void)lanScanDidFailedToScan;

@optional

- (void)lanScanProgressPinged:(float)pingedHosts from:(NSInteger)overallHosts;

@end

#pragma mark - Public methods
@interface RTLANScanner : NSObject

@property (nonatomic, weak) id<RTLANScannerDelegate> delegate;

- (instancetype)initWithDelegate:(id<RTLANScannerDelegate>)delegate;

@property (nonatomic, assign, readonly) BOOL isScanning;

- (void)start;

- (void)stop;

@end
