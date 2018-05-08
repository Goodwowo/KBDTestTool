#import <UIKit/UIKit.h>
#define kScreenW [[UIScreen mainScreen] bounds].size.width

#define kScreenH [[UIScreen mainScreen] bounds].size.height
@interface RTHuView : UIView
@property(nonatomic,assign)int num;
@property(nonatomic,strong)UILabel *numLabel;
@end
