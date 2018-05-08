
#import <Foundation/Foundation.h>

@interface RTCrashModel : NSObject <NSCoding>

@property (nonatomic,copy)NSString *crashStack;
@property (nonatomic,copy)NSString *imagePath;
@property (nonatomic,copy)NSString *vcStack;
@property (nonatomic,copy)NSString *operationStack;

@end
