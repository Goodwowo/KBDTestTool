
#import <Foundation/Foundation.h>

@interface RTVCLearn : NSObject

+ (RTVCLearn *)shareInstance;

- (void)setUnionVC:(NSArray *)vcs;
- (void)setTopologyVCMore:(NSArray *)vcStack;
- (NSString *)getVcIdentity:(NSString *)vc;
- (NSString *)getVcWithIdentity:(NSString *)identity;

- (NSArray *)unionVC;
- (NSArray *)traceVC;
- (NSString *)traceString;
- (NSArray *)traceMemory;
- (NSArray *)tracePerformance;

+ (BOOL)filter:(NSString *)vc;

@end
