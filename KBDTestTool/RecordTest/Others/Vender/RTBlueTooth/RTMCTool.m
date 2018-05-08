
#import "RTMCTool.h"

static RTMCTool* tool = nil;
static NSString * const ServiceType = @"rt-recordtest";

@interface RTMCTool () <MCSessionDelegate, MCAdvertiserAssistantDelegate, MCBrowserViewControllerDelegate> {
    MCPeerID* myPeer;
    MCAdvertiserAssistant* advertiser;
    BOOL isConnect ;
}

@end

@implementation RTMCTool

// 初始化
- (void)initData{
    myPeer = nil;
    self.session = nil;
    advertiser = nil;
    self.browser = nil;
    isConnect = NO;
    [self setupPeerSessionAdvertiser];
}

// 单利获取对象
+ (instancetype)tool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[RTMCTool alloc] init];
    });
    return tool;
}

- (void)setUp:(id)vc{
    if (isConnect) return;
    [self initData];
    [RTMCTool tool].delegate = vc;
    [vc presentViewController:[[RTMCTool tool] browser] animated:YES completion:nil];
}

+ (void)setUp:(id)vc{
    [[RTMCTool tool] setUp:vc];
}

#pragma mark - public mothed
- (void)setupPeerSessionAdvertiser{
    // 标识设备，通常是设备昵称
    myPeer = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    // 启用和管理Multipeer连接会话中的所有同行之间的沟通
    _session = [[MCSession alloc] initWithPeer:myPeer securityIdentity:nil encryptionPreference:MCEncryptionNone];
    // 发送广播，向用户呈现传入的邀请并处理用户的响应的UI
    advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:ServiceType discoveryInfo:nil session:_session];
    // 开启广播
    [advertiser start];
    _session.delegate = self;
    advertiser.delegate = self;
}

// 关闭广播
- (void)closeAdvertiser{
    [advertiser stop];
    advertiser = nil;
    [self initData];
}

+ (void)closeAdvertiser{
    [[RTMCTool tool] closeAdvertiser];
}

// 发送消息
- (void)sendMessage:(NSString*)message error:(NSError*)error{
    if (!isConnect) return;
    NSError* errors;
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [_session sendData:data toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:&errors];
    error = errors;
}

+ (void)sendMessage:(NSString*)message error:(NSError*)error{
    [[RTMCTool tool] sendMessage:[@"_string_" stringByAppendingString:message] error:error];
}

- (void)sendData:(NSData *)data error:(NSError*)error{
    if (!isConnect) return;
    NSError* errors;
    [_session sendData:data toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:&errors];
    error = errors;
}

+ (void)sendData:(NSData *)data error:(NSError*)error{
    [[RTMCTool tool] sendData:data error:error];
}

// 查找蓝牙的浏览器控制器
- (MCBrowserViewController*)browser{
    if (!_browser) {
        _browser = [[MCBrowserViewController alloc] initWithServiceType:ServiceType session:_session];
        _browser.delegate = self;
    }
    return _browser;
}

#pragma mark - MCSessionDelegate
// 状态改变
- (void)session:(MCSession*)session peer:(MCPeerID*)peerID didChangeState:(MCSessionState)state{
    if (state == MCSessionStateConnected) {
        isConnect = YES;
        [self.browser dismissViewControllerAnimated:YES completion:nil];
    }else{
        isConnect = NO;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(session:didChangeState:)]) {
        [self.delegate session:session didChangeState:state];
    }
}

// 收到消息
- (void)session:(MCSession*)session didReceiveData:(NSData*)data fromPeer:(MCPeerID*)peerID{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([str hasPrefix:@"_string_"]) {
            str = [str substringFromIndex:@"_string_".length];
            if (str && self.delegate && [self.delegate respondsToSelector:@selector(session:didReceiveString:)]) {
                [self.delegate session:session didReceiveString:str];
            }
        }else if (self.delegate && [self.delegate respondsToSelector:@selector(session:didReceiveData:)]) {
            [self.delegate session:session didReceiveData:data];
        }
    });
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {}


- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {}


- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {}


#pragma mark - MCBrowserViewControllerDelegate
- (void)browserViewControllerDidFinish:(MCBrowserViewController*)browserViewController{
    [_browser dismissViewControllerAnimated:YES completion:^{
         if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerCancleAndDone)]) {
             [self.delegate browserControllerCancleAndDone];
         }
     }];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController*)browserViewController{
    [_browser dismissViewControllerAnimated:YES completion:^{
         if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerCancleAndDone)]) {
             [self.delegate browserControllerCancleAndDone];
         }
     }];
}

@end
