
#import "RTImagePreVC.h"
#import "RecordTestHeader.h"
#import "RTPhotosViewController.h"

@implementation RTImagePreVC

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (self.image == nil) {
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64)];
        textView.text = @"没有截图";
        textView.textColor = [UIColor redColor];
        textView.font = [UIFont boldSystemFontOfSize:20];
        textView.editable = NO;
        [self.view addSubview:textView];
    }else{
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64)];
        imageView.image = self.image;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView];
        [imageView addUITapGestureRecognizerWithTarget:self withAction:@selector(zoomAction:)];
    }
}

- (void)zoomAction:(UITapGestureRecognizer *)ges{
    UIImageView *imageView = (UIImageView *)ges.view;
    [self goToPhotoBrowser:imageView.image];
}

- (void)goToPhotoBrowser:(UIImage *)image{
    RTPhotosViewController *vc=[RTPhotosViewController new];
    vc.images = @[image].mutableCopy;
    vc.indexCur = 0;
    vc.bgColor=[UIColor whiteColor];
    vc.isShowPageIndex = NO;
    [vc showToVC:self];
}

@end
