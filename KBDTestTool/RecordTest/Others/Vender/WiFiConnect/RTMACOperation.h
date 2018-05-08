
#import "RTSimplePing.h"

@class RTDeviceModel;

@interface RTMACOperation : NSOperation {
    BOOL _isFinished;
    BOOL _isExecuting;
}

- (nullable instancetype)initWithIPToRetrieveMAC:(nonnull NSString*)ip andBrandDictionary:(nullable NSDictionary*)brandDictionary andCompletionHandler:(nullable void (^)(NSError* _Nullable error, NSString* _Nonnull ip, RTDeviceModel* _Nonnull device))result;

@end
