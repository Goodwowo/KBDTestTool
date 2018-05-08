#import <UIKit/UIKit.h>

@interface RTCommandListVCViewController : UIViewController

@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,weak)UINavigationController *nav;

@end
