
#import "KVOAllView.h"
#import "RecordTestHeader.h"
#import "RTRepearDictionary.h"
#import "AutoTestHeader.h"

@interface KVOAllView ()

@property (nonatomic,strong)RTRepearDictionary *repearDictionary;

@end

@implementation KVOAllView

- (void)kvoAllView{
    if ([RTOperationQueue shareInstance].isRecord || [RTCommandList shareInstance].isRunOperationQueue || [RTSearchVCPath shareInstance].isLearnVCPath) {
        self.repearDictionary = nil;
        self.repearDictionary = [RTRepearDictionary new];
        for (int i = 0; i < [UIApplication sharedApplication].windows.count; i++) {
            UIWindow *window = [UIApplication sharedApplication].windows[i];
            if (window.subviews.count > 0) {
                [self dumpView:window fatherView:nil atIndent:0 layerDirector:@""];
            }
        }
    }
}

- (void)kvoView:(UIView *)aView fatherView:(UIView *)fatherView atIndent:(int)indent layerDirector:(NSString *)layerDirector{
    
    [aView kvo];
    
    //记录所在第几个嵌套层,用于方便排序
    aView.layerIndex=indent;
    
    //记录层级director 作用是用来标记这个控件的绝对位置 比如 window/view/tableview/tableviewcell/imageview
    NSString *superViewLayerDirector = fatherView.layerDirector;
    if(superViewLayerDirector.length<=0) superViewLayerDirector=@"";
    if ([aView isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)aView;
        layerDirector=[superViewLayerDirector stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-section-%ld-row-%ld",[cell class],(long)cell.indexPath.section,(long)cell.indexPath.row]];
    }else if ([aView isKindOfClass:[UICollectionViewCell class]]){
        UICollectionViewCell *cell = (UICollectionViewCell *)aView;
        layerDirector=[superViewLayerDirector stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-section-%ld-row-%ld",[cell class],(long)cell.indexPath.section,(long)cell.indexPath.row]];
    }else{
        layerDirector=[superViewLayerDirector stringByAppendingPathComponent:NSStringFromClass([aView class])];
    }
    NSString *layerDirectorTemp = [self.repearDictionary setValue:@"" forKey:layerDirector];
    aView.layerDirector=layerDirectorTemp;
    
//    printf("%s\n",[aView.layerDirector UTF8String]);
    
    //记录当前控件所在的控制器
    UIViewController *vc=[aView getViewController];
    if (vc) aView.curViewController=NSStringFromClass(vc.class);
    else aView.curViewController=fatherView.curViewController;
}

- (void)dumpView:(UIView *)aView fatherView:(UIView *)fatherView atIndent:(int)indent layerDirector:(NSString *)layerDirector{
    
    if (aView.isNoNeedKVO) return;
    
    //获取记录相关信息
    [self kvoView:aView fatherView:fatherView atIndent:indent layerDirector:layerDirector];
    
    if ([aView isKindOfClass:[UITableView class]]) {
        UITableView *tableView=((UITableView *)aView);
        NSMutableArray *visibleCells=[NSMutableArray arrayWithArray:[tableView visibleCells]];
        for (UITableViewCell *cell in visibleCells) {
            NSIndexPath *indexPath=[tableView indexPathForCell:cell];
            cell.indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        }
    }
    if ([aView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView=((UICollectionView *)aView);
        NSMutableArray *visibleCells=[NSMutableArray arrayWithArray:[collectionView visibleCells]];
        for (UICollectionViewCell *cell in visibleCells) {
            NSIndexPath *indexPath=[collectionView indexPathForCell:cell];
            cell.indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        }
    }
    
    //继续递归遍历
    for (UIView *view in [aView subviews]){
        [self dumpView:view fatherView:aView atIndent:indent + 1 layerDirector:layerDirector];
    }
}

@end
