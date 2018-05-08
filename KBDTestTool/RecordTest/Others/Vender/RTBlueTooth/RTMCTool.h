
#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol RTMCToolDelegate <NSObject>

@optional
- (void)session:(MCSession *)session didReceiveString:(NSString *)str;
- (void)session:(MCSession *)session didReceiveData:(NSData *)data;
- (void)session:(MCSession *)session didChangeState:(MCSessionState)state;
- (void)browserControllerCancleAndDone;
@end

@interface RTMCTool : NSObject

@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, assign) id<RTMCToolDelegate> delegate;

+ (instancetype)tool;
+ (void)setUp:(id)vc;
+ (void)closeAdvertiser;
+ (void)sendMessage:(NSString *)message error:(NSError *)error;
+ (void)sendData:(NSData *)data error:(NSError*)error;

@end
