
#import <Foundation/Foundation.h>
#import "RTPickerView.h"

typedef void (^DatePickerCommitBlock)(NSDate * _Nonnull date);
typedef void (^DatePickerCancelBlock)(void);

typedef void (^PickerViewCommitBlock)(NSString * _Nonnull string);
typedef void (^PickerViewCancelBlock)(void);

@interface RTPickerManager : NSObject

+ (RTPickerManager *_Nonnull)shareManger;

@property (nonatomic, strong) RTPickerView * _Nonnull pickView;

- (void)showPickerViewWithDataArray:(NSArray *_Nullable)array curTitle:(NSString *)curTitle title:(NSString *_Nullable)title cancelTitle:(NSString *_Nullable)cancelTitle commitTitle:(NSString *_Nullable)commitTitle commitBlock:(PickerViewCommitBlock _Nullable )commitBlock cancelBlock:(PickerViewCancelBlock _Nullable )cancelBlock;

@end
