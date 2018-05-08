
#import <UIKit/UIKit.h>

@interface RTCrashLagIndexVC : UIViewController

@property (nonatomic,copy)NSString *text;
@property (nonatomic,copy)NSString *stamp;
@property (nonatomic,copy)NSString *imageName;
@property (nonatomic,assign)BOOL isCrash;
@property (nonatomic,copy)NSString *vcStack;
@property (nonatomic,copy)NSString *operationStack;

@end
