
#import "RTFilePreVC.h"
#import "RTFileInfo.h"
#import <QuickLook/QuickLook.h>
#import <WebKit/WebKit.h>
#import "Sandbox.h"
#import <MediaPlayer/MediaPlayer.h>

@interface RTFilePreVC () <WKNavigationDelegate, WKUIDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) WKWebView *wkWebView;

@property (strong, nonatomic) UITextView *textView;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic,strong)MPMoviePlayerViewController *moviePlayerController;

@end

@implementation RTFilePreVC

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.fileInfo.displayName;
    [self setupViews];
    [self loadFile];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.wkWebView) {
        self.wkWebView.frame = self.view.bounds;
    }
    if (self.textView) {
        self.textView.frame = self.view.bounds;
    }
    self.activityIndicatorView.center = self.view.center;
}

#pragma mark - Getters

- (UIDocumentInteractionController *)documentInteractionController {
    if (!_documentInteractionController) {
        _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:self.fileInfo.URL];
        _documentInteractionController.delegate = self;
        _documentInteractionController.name = self.fileInfo.displayName;
    }
    
    return _documentInteractionController;
}

#pragma mark - Private Methods

- (void)setupViews {
    
    if (self.fileInfo.isCanPreviewInWebView) {
        self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        self.wkWebView.backgroundColor = [UIColor whiteColor];
        self.wkWebView.navigationDelegate = self;
        [self.view addSubview:self.wkWebView];
    } else {
        switch (self.fileInfo.type) {
            case MLBFileTypePList: {
                self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
                self.textView.editable = NO;
                self.textView.alwaysBounceVertical = YES;
                [self.view addSubview:self.textView];
                break;
            }
            default:
                //copyied by liman
                self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
                self.textView.editable = NO;
                self.textView.alwaysBounceVertical = YES;
                [self.view addSubview:self.textView];
                break;
        }
    }
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.activityIndicatorView];
}

- (void)loadFile {
    if (self.fileInfo.isCanPreviewInWebView) {
        if (@available(iOS 9.0, *)) {
            [self.wkWebView loadFileURL:self.fileInfo.URL allowingReadAccessToURL:self.fileInfo.URL];
        } else {
            [self.wkWebView loadRequest:[NSURLRequest requestWithURL:self.fileInfo.URL]];
        }
    } else {
        switch (self.fileInfo.type) {
            case MLBFileTypePList: case MLBFileTypeJSON: case MLBFileTypeC:
            case MLBFileTypeCPP: case MLBFileTypePHP: case MLBFileTypeHTML:
            case MLBFileTypeXML: case MLBFileTypeJS: {
                [self openTextFile];
                break;
            }
            case MLBFileTypeMP4: case MLBFileTypeAVI: case MLBFileTypeFLV:
            case MLBFileTypeMIDI: case MLBFileTypeMOV: case MLBFileTypeMPG:
            case MLBFileTypeWMV: case MLBFileTypeMP3: case MLBFileTypeAAC:
            case MLBFileTypeOGG: {
                [self openVideo];
                break;
            }
            default:
                //liman
                self.textView.text = @" 暂不支持打开该格式的文件";
                self.textView.backgroundColor = [UIColor whiteColor];
                self.textView.textColor = [UIColor redColor];
                self.textView.font = [UIFont boldSystemFontOfSize:17];
                break;
        }
    }
}

- (void)openTextFile{
    [self.activityIndicatorView startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfFile:self.fileInfo.URL.path];
        
        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.textView.text = @" 暂不支持打开该格式的文件";
                self.textView.backgroundColor = [UIColor whiteColor];
                self.textView.textColor = [UIColor redColor];
                self.textView.font = [UIFont boldSystemFontOfSize:17];
            });
        }else{
            NSError *error;
            NSString *content = [[NSPropertyListSerialization propertyListWithData:data options:kNilOptions format:nil error:&error] description];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicatorView stopAnimating];
                //liman
                if (error) {
                    self.textView.text = @" 暂不支持打开该格式的文件";
                    self.textView.backgroundColor = [UIColor whiteColor];
                    self.textView.textColor = [UIColor redColor];
                    self.textView.font = [UIFont boldSystemFontOfSize:17];
                }else{
                    self.textView.text = content;
                    self.textView.backgroundColor = [UIColor whiteColor];
                    self.textView.textColor = [UIColor blackColor];
                    self.textView.font = [UIFont systemFontOfSize:12];
                }
            });
        }
    });
}

- (void)openVideo{
    _moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:self.fileInfo.URL];
    [self presentMoviePlayerViewControllerAnimated:_moviePlayerController];
    _moviePlayerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [_moviePlayerController.moviePlayer setFullscreen:YES animated:YES];
    [_moviePlayerController.moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
    _moviePlayerController.moviePlayer.movieSourceType=MPMovieSourceTypeFile;
    [_moviePlayerController.moviePlayer prepareToPlay];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self.navigationController;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {
    return self.view.bounds;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
    return self.view;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.activityIndicatorView startAnimating];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [self.activityIndicatorView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.activityIndicatorView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.activityIndicatorView stopAnimating];
}

@end
