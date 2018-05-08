
#import <UIKit/UIKit.h>

@interface UIView (RTLayerIndex)

@property (nonatomic,assign)NSInteger layerIndex;//当前所在第几层嵌套层数(UIview嵌套子控件)
@property (nonatomic,copy)NSString *layerDirector;//记录层级director 作用是用来标记这个控件的绝对位置 比如 window/view/tableview/tableviewcell/imageview
@property (nonatomic,copy)NSString *curViewController;//记录当前控件所在的viewController

@end

@interface UITableViewCell (RTLayerIndex)

@property (nonatomic,strong)NSIndexPath *indexPath;

@end

@interface UICollectionViewCell (RTLayerIndex)

@property (nonatomic,strong)NSIndexPath *indexPath;

@end
