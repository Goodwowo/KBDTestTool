
#import "RTCrashThreadInfo.h"

@implementation RTCrashThreadInfo

- (instancetype)init{
    self = [super init];
    if (self) {
        _stackTrace = [[NSMutableString alloc] init];
        _isCrashThread = NO;
        _threadId = 0;
        _errorCode = 0;
        _threadName = @"";
    }
    return self;
}

- (NSString*)description{
    return _stackTrace;
}

@end
