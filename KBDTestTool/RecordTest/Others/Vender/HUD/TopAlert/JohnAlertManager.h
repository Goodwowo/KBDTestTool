
//二次封装，可将头文件放入pch文件中，方便全局调用
#import <Foundation/Foundation.h>
#import "JohnTopAlert.h"

@interface JohnAlertManager : NSObject

+ (void)showAlertWithType:(JohnTopAlertType)type title:(NSString *)title;

@end
