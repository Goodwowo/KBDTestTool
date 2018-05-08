
#import "RTFeedbackVC.h"
#import "RecordTestHeader.h"

@interface RTFeedbackVC () <UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextView* txtContent;
@property (nonatomic, strong) UILabel* txtViewplaceholder;
@property (nonatomic, strong) UIButton* btnSubmit;

@end

@implementation RTFeedbackVC

- (void)viewDidLoad{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"反馈建议";
    [self setupUI];
}

- (void)setupUI{
    
//    CGFloat subViewWidth = CurrentScreen_Width - 40;
//    CGFloat subViewX = 20;
//    CGFloat fontHeight = [SDTools currentViewHeight:16];
//    UILabel* lbtitleFK = [[UILabel alloc] initWithFrame:CGRectMake(subViewX, 40, subViewWidth, fontHeight)];
//    lbtitleFK.text = @"反馈建议";
//    lbtitleFK.textColor = RGBOnly(83);
//    lbtitleFK.font = [UIFont systemFontOfSize:fontHeight];
//    [self.view addSubview:lbtitleFK];
//
//    CGFloat txtViewHeight = [SDTools currentViewHeight:175];
//    self.txtContent = [[UITextView alloc] initWithFrame:CGRectMake(subViewX, MaxY(lbtitleFK) + 5, subViewWidth, txtViewHeight)];
//    self.txtContent.layer.borderWidth = 1;
//    self.txtContent.layer.borderColor = [UIColor colorWithHexString:@"#f1eff0"].CGColor;
//    self.txtContent.delegate = self;
//    self.txtContent.textContainerInset = UIEdgeInsetsMake(5, 5, 2, 5);
//    [self.view addSubview:self.txtContent];
//
//    CGFloat placeholderfont = 15;
//    self.txtViewplaceholder = [[UILabel alloc] initWithFrame:CGRectMake(subViewX + 5, Y(self.txtContent) + 5, WIDTH(self.txtContent) - 10, placeholderfont * 3)];
//    self.txtViewplaceholder.numberOfLines = 0;
//    self.txtViewplaceholder.font = [UIFont systemFontOfSize:placeholderfont];
//    self.txtViewplaceholder.text = @"写下您遇到的问题,或希望改善的地方,300字内。";
//    self.txtViewplaceholder.textColor = RGB(194, 194, 200);
//    [self.view addSubview:self.txtViewplaceholder];
//
//    self.btnSubmit = [[UIButton alloc] initWithFrame:CGRectMake(subViewX, MaxY(self.txtContent) + 20, subViewWidth, 44)];
//    self.btnSubmit.backgroundColor = [UIColor colorWithHexString:@"#31c1c2"];
//
//    self.btnSubmit.layer.cornerRadius = 3;
//    self.btnSubmit.layer.masksToBounds = YES;
//    [self.btnSubmit setTitle:@"提交" forState:UIControlStateNormal];
//    [self.btnSubmit addTarget:self action:@selector(clickSubmitBtn) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.btnSubmit];
}

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event{
    [self.view endEditing:YES];
}

- (void)clickSubmitBtn{
//    if (![SDSingletonTool shared].isNetWork) {
//        [MBProgressHUD showMessage:NoNetWork toView:self.view];
//        return;
//    }
//    if (self.txtContent.text.length > 0) {
//
//    } else {
//        [MBProgressHUD showMessage:@"请输入反馈" toView:self.view];
//    }
}

- (void)textViewDidBeginEditing:(UITextView*)textView{
    self.txtViewplaceholder.hidden = YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView.text.length>=300) {
        return NO;
    }
    return YES;
}

@end
