
#import <Foundation/Foundation.h>

@protocol RTMainPresenterDelegate

- (void)mainPresenterIPSearchFinished;

- (void)mainPresenterIPSearchCancelled;

- (void)mainPresenterIPSearchFailed;

@end

@interface RTMainPresenter : NSObject

@property (nonatomic, strong) NSArray* connectedDevices;

@property (nonatomic, assign, readonly) float progressValue;

@property (nonatomic, assign, readonly) BOOL isScanRunning;

- (instancetype)initWithDelegate:(id<RTMainPresenterDelegate>)delegate;

- (void)scanButtonClicked;

- (NSString*)ssidName;

@end
