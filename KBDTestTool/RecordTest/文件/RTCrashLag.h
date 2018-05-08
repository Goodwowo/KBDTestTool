
#import <Foundation/Foundation.h>
#import "RTLagModel.h"
#import "RTCrashModel.h"

@interface RTCrashLag : NSObject

+ (RTCrashLag *)shareInstance;

- (NSMutableDictionary *)crashs;
- (NSMutableDictionary *)lags;
- (void)addCrash:(RTCrashModel *)model;
- (void)addLag:(RTLagModel *)model;
- (void)removeCrash:(NSString *)stamp;
- (void)removeLag:(NSString *)stamp;

@end
