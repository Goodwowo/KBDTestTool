#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface RTOpenDataBase : NSObject

+ (id)selectDataWithIdentity:(NSString *)identity dataBasePath:(NSString *)dataBasePath;
+ (void)closeDataBasePath:(NSString *)dataBasePath;

@end
