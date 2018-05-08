
#import <UIKit/UIKit.h>

@interface RTPhotosViewCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIScrollView *scrollImageView;
@property (strong, nonatomic) UIImageView *largeImageView;
@property (nonatomic,strong)UIColor *bgColor;
- (void)adjustFrame;

@property (nonatomic,assign)BOOL isAddGestureRecognizer;

@end

@interface RTPhotosViewController : UIViewController

@property (nonatomic,assign)BOOL isShowDelete;//是否显示删除按钮
@property (nonatomic,assign)BOOL isShowPageIndex;//是否显示下标
@property (nonatomic,strong)UIColor *bgColor;
@property (nonatomic,strong)NSMutableArray *urls;//图片网址

@property (nonatomic,strong)NSMutableArray *rects;//如果在放大和缩小时需要找到对应的位置做动画

@property (nonatomic,strong)NSMutableArray *images;//如果想显示已经加载好了的image

@property (nonatomic,strong)NSMutableArray *imageNames;//如果想加载图片名字的图片

//@property (nonatomic,assign)BOOL needAutoScrollRects;//如果需要在滚动到后面的图片,发现rects数组里面已经不存在对应的rect,就自动滚动TableView或者是CollectionView的UISCrollView

@property (nonatomic,assign)NSInteger indexCur;//显示第几张

@property (nonatomic,weak)UIImageView *srcImageView;//最初显示的位置的图片(可以为空)

- (void)show;
- (void)showToVC:(UIViewController *)vc;

- (void)addRectWithImageView:(UIImageView *)imageView;

@end
