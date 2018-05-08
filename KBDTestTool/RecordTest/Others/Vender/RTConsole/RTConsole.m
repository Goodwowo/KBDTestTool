
#import "RTConsole.h"

@interface RTConsole ()
@property (nonatomic, strong) NSDateFormatter* formatter;
@end
@implementation RTConsole

+ (instancetype)sharedConsole{
    static RTConsole* _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [RTConsole new];
        _instance.log = [NSMutableString string];
        _instance.formatter = [[NSDateFormatter alloc] init];
        _instance.formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    });
    return _instance;
}

- (void)function:(const char*)function
            line:(NSUInteger)line
          format:(NSString*)format, ... NS_FORMAT_FUNCTION(3, 4){
    va_list args;
    if (format) {
        va_start(args, format);
        [self printMSG:[[NSString alloc] initWithFormat:format arguments:args] andFunc:function andLine:line];
        va_end(args);
    }
}

- (void)printMSG:(NSString*)msg andFunc:(const char*)function andLine:(NSInteger)Line{
    msg = [NSString stringWithFormat:@"%@ %@ line:%ld %@\n", [_formatter stringFromDate:[NSDate new]], [NSString stringWithUTF8String:function], (long)Line, msg];
//    [self.log appendString:msg];
    
    const char* resultCString = NULL;
    if ([msg canBeConvertedToEncoding:NSUTF8StringEncoding]) {
        resultCString = [msg cStringUsingEncoding:NSUTF8StringEncoding];
    }
    //控制台打印
    printf("%s", resultCString);
}

@end
