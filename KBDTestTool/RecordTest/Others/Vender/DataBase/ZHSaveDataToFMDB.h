#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface ZHSaveDataToFMDB : NSObject

+ (void)insertDataWithData:(id)data WithIdentity:(NSString *)identity;

+ (id)selectDataWithIdentity:(NSString *)identity;

+ (void)deleteBLOBDataWithIdentity:(NSString *)identity;

+ (void)cleanAllData;

@end
