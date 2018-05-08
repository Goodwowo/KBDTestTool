
#import "UIView+RTLayerIndex.h"
#import <objc/runtime.h>

@implementation UIView (RTLayerIndex)

static const int UIView_LayerIndex;
static const int UIView_LayerDirector;
static const int UIView_CurViewController;

- (NSInteger)layerIndex{
    id num=objc_getAssociatedObject(self, &UIView_LayerIndex);
    if (num) {
        return [num integerValue];
    }
    return 0;
}

- (void)setLayerIndex:(NSInteger)layerIndex{
    objc_setAssociatedObject(self, &UIView_LayerIndex, [NSNumber numberWithInteger:layerIndex], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)layerDirector{
    return objc_getAssociatedObject(self, &UIView_LayerDirector);
}

- (void)setLayerDirector:(NSString *)layerDirector{
    objc_setAssociatedObject(self, &UIView_LayerDirector, layerDirector, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)curViewController{
    id obj=objc_getAssociatedObject(self, &UIView_CurViewController);
    if (obj==nil) obj= @"";
    return obj;
}

- (void)setCurViewController:(NSString *)curViewController{
    objc_setAssociatedObject(self, &UIView_CurViewController, curViewController, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation UITableViewCell (RTLayerIndex)

static const int UITableViewCell_IndexPath;

- (NSIndexPath *)indexPath{
    return objc_getAssociatedObject(self, &UITableViewCell_IndexPath);
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    objc_setAssociatedObject(self, &UITableViewCell_IndexPath, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UICollectionViewCell (RTLayerIndex)

static const int UICollectionViewCell_IndexPath;

- (NSIndexPath *)indexPath{
    return objc_getAssociatedObject(self, &UICollectionViewCell_IndexPath);
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    objc_setAssociatedObject(self, &UICollectionViewCell_IndexPath, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
