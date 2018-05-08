
#import <UIKit/UIKit.h>

#ifndef NSLog
#define NSLog(frmt, ...)    LOG_OBJC_MAYBE(frmt, ##__VA_ARGS__)
#endif

#define LOG_OBJC_MAYBE(frmt, ...) \
[[RTConsole sharedConsole] function : __PRETTY_FUNCTION__ \
line : __LINE__ \
format : (frmt), ## __VA_ARGS__]

@interface RTConsole : NSObject

@property (nonatomic,strong)NSMutableString *log;
+ (instancetype)sharedConsole;
- (void)function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ... NS_FORMAT_FUNCTION(3,4);

@end
