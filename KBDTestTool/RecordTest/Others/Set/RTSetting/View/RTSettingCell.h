
#import <UIKit/UIKit.h>
@class RTSettingItem;

@interface RTSettingCell : UITableViewCell

@property (nonatomic, strong) RTSettingItem* item;

/** switch状态改变的block*/
@property (copy, nonatomic) void (^switchChangeBlock)(BOOL on);

+ (id)settingCellWithTableView:(UITableView*)tableView item:(RTSettingItem *)item;

@end
