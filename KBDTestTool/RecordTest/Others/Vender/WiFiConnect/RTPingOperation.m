
#import "RTDeviceModel.h"
#import "RTLANProperties.h"
#import "RTMacFinder.h"
#import "RTPingOperation.h"

static const float PING_TIMEOUT = 1;

@interface RTPingOperation ()
@property (nonatomic, strong) NSString* ipStr;
@property (nonatomic, strong) NSDictionary* brandDictionary;
@property (nonatomic, strong) RTSimplePing* simplePing;
@property (nonatomic, copy) void (^result)(NSError* _Nullable error, NSString* _Nonnull ip);
@end

@interface RTPingOperation ()
- (void)finish;
@end

@implementation RTPingOperation {
    BOOL _stopRunLoop;
    NSTimer* _keepAliveTimer;
    NSError* errorMessage;
    NSTimer* pingTimer;
}

- (instancetype)initWithIPToPing:(NSString*)ip andCompletionHandler:(nullable void (^)(NSError* _Nullable error, NSString* _Nonnull ip))result;{

    self = [super init];

    if (self) {
        self.name = ip;
        self.ipStr = ip;
        self.simplePing = [RTSimplePing simplePingWithHostName:ip];
        self.simplePing.delegate = self;
        self.result = result;
        _isExecuting = NO;
        _isFinished = NO;
    }

    return self;
}

- (void)start{

    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        _isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];

    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];

    _keepAliveTimer = [NSTimer timerWithTimeInterval:1000000.0 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
    [runLoop addTimer:_keepAliveTimer forMode:NSDefaultRunLoopMode];

    [self ping];

    NSTimeInterval updateInterval = 0.1f;
    NSDate* loopUntil = [NSDate dateWithTimeIntervalSinceNow:updateInterval];

    while (!_stopRunLoop && [runLoop runMode:NSDefaultRunLoopMode beforeDate:loopUntil]) {
        loopUntil = [NSDate dateWithTimeIntervalSinceNow:updateInterval];
    }
}
- (void)ping{

    [self.simplePing start];
}
- (void)finishedPing{

    if (self.result) {
        self.result(errorMessage, self.name);
    }

    [self finish];
}

- (void)timeout:(NSTimer*)timer{
    errorMessage = [NSError errorWithDomain:@"Ping Timeout" code:10 userInfo:nil];
    [self finishedPing];
}

- (void)finish{

    [_keepAliveTimer invalidate];
    _keepAliveTimer = nil;

    _stopRunLoop = YES;

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];

    _isExecuting = NO;
    _isFinished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isExecuting{
    return _isExecuting;
}

- (BOOL)isFinished{
    return _isFinished;
}
#pragma mark - Pinger delegate

- (void)simplePing:(RTSimplePing*)pinger didStartWithAddress:(NSData*)address{
    if (self.isCancelled) {
        [self finish];
        return;
    }
    [pinger sendPingWithData:nil];
}

- (void)simplePing:(RTSimplePing*)pinger didFailWithError:(NSError*)error{
    [pingTimer invalidate];
    errorMessage = error;
    [self finishedPing];
}

- (void)simplePing:(RTSimplePing*)pinger didFailToSendPacket:(NSData*)packet error:(NSError*)error{

    [pingTimer invalidate];
    errorMessage = error;
    [self finishedPing];
}

- (void)simplePing:(RTSimplePing*)pinger didReceivePingResponsePacket:(NSData*)packet{
    [pingTimer invalidate];
    [self finishedPing];
}

- (void)simplePing:(RTSimplePing*)pinger didSendPacket:(NSData*)packet{
    pingTimer = [NSTimer scheduledTimerWithTimeInterval:PING_TIMEOUT target:self selector:@selector(pingTimeOut:) userInfo:nil repeats:NO];
}

- (void)pingTimeOut:(NSTimer*)timer{
    errorMessage = [NSError errorWithDomain:@"Ping timeout" code:11 userInfo:nil];
    [self finishedPing];
}

@end
