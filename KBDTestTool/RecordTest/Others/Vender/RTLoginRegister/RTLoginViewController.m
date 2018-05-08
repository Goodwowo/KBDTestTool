
#import "RTForgetPasswordViewController.h"
#import "RTLoginViewController.h"
#import "RTRegistViewController.h"
#import "RecordTestHeader.h"
//#import "SDSingletonTool.h"
#import "TabBarAndNavagation.h"
//#import "ZHNSString.h"

@interface RTLoginViewController () {
    UIImageView* View;
    UIView* bgView;
    UITextField* pwd;
    UITextField* user;
    UIButton* QQBtn;
    UIButton* weixinBtn;
    UIButton* xinlangBtn;
}
@property (copy, nonatomic) NSString* accountNumber;
@property (copy, nonatomic) NSString* mmmm;

@end

@implementation RTLoginViewController

//登录
- (void)landClick{
    [self loginWith:user.text password:pwd.text];
    //    if(user.text.length>0&&pwd.text.length>0){
    ////        if([ZHNSString isValidateNumber:user.text]==NO){
    ////            [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:@"手机号码不存在!"];
    ////            return;
    ////        }
    //        [self loginWith:user.text password:pwd.text];
    //    }else{
    //        [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:@"账号或密码不能为空!"];
    //    }
}

- (void)forgetClick{
    RTForgetPasswordViewController* vc = [RTForgetPasswordViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loginWith:(NSString*)userName password:(NSString*)password{
//    [SDNetworking postIsShowProgress:NO WithUrl:[NSString stringWithFormat:@"http://192.168.1.12:8080/KBDAutoTest/Login"]
//        parameters:@{ @"username" : @"13077821373",
//            @"password" : @"123456" }
//        success:^(id json) {
//            NSLog(@"%@", @"登录成功");
//            NSDictionary* dic = (NSDictionary*)json;
//            if ([dic[@"errcode"] longValue] == 200) {
//
//            } else {
//                NSLog(@"%@", @"登录失败");
//            }
//        }
//        failure:^(NSError* error) {
//            NSLog(@"%@", error);
//        }];
}

- (void)viewDidLoad{
    [super viewDidLoad];

    View = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    View.image = [UIImage imageNamed:@"bg4.jpg"];
    [self.view addSubview:View];
    self.view.backgroundColor = [UIColor colorWithRed:240 / 255.0f green:240 / 255.0f blue:240 / 255.0f alpha:1];

    [self createButtons];
    [self createTextFields];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"注册" TintColor:[UIColor redColor] target:self action:@selector(registerAccount)];

    self.title = @"登录";

//    [ZHBlockSingleCategroy addBlockWithTwoNSString:^(NSString* str1, NSString* str2) {
//        user.text = str1;
//        pwd.text = str2;
//    } WithIdentity:@"regisetSuccess"];
}

- (void)registerAccount{
    RTRegistViewController* vc = [RTRegistViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)createTextFields{
    CGRect frame = [UIScreen mainScreen].bounds;
    bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 45, frame.size.width - 20, 100)];
    bgView.layer.cornerRadius = 3.0;
    bgView.alpha = 0.7;
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];

    user = [self createTextFielfFrame:CGRectMake(60, 10, 271, 30) font:[UIFont systemFontOfSize:14] placeholder:@"请输入手机号"];

    user.keyboardType = UIKeyboardTypeNumberPad;
    user.clearButtonMode = UITextFieldViewModeWhileEditing;

    pwd = [self createTextFielfFrame:CGRectMake(60, 60, 271, 30) font:[UIFont systemFontOfSize:14] placeholder:@"请输入密码"];
    pwd.clearButtonMode = UITextFieldViewModeWhileEditing;

    //密文样式
    pwd.secureTextEntry = YES;

    UIImageView* userImageView = [self createImageViewFrame:CGRectMake(20, 10, 25, 25) imageName:@"ic_landing_nickname" color:nil];
    UIImageView* pwdImageView = [self createImageViewFrame:CGRectMake(20, 60, 25, 25) imageName:@"mm_normal" color:nil];
    UIImageView* line1 = [self createImageViewFrame:CGRectMake(20, 50, bgView.frame.size.width - 40, 1) imageName:nil color:[UIColor colorWithRed:180 / 255.0f green:180 / 255.0f blue:180 / 255.0f alpha:.3]];

    [bgView addSubview:user];
    [bgView addSubview:pwd];

    [bgView addSubview:userImageView];
    [bgView addSubview:pwdImageView];
    [bgView addSubview:line1];
}

- (void)touchesEnded:(nonnull NSSet<UITouch*>*)touches withEvent:(nullable UIEvent*)event{
    [user resignFirstResponder];
    [pwd resignFirstResponder];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    [user resignFirstResponder];
    [pwd resignFirstResponder];
}

- (void)createButtons{
//    UIButton* landBtn = [self createButtonFrame:CGRectMake(10, 170, self.view.frame.size.width - 20, 37) backImageName:nil title:@"登录" titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:17] target:self action:@selector(landClick)];
//    landBtn.backgroundColor = CurrentAppThemeColor;
//    landBtn.layer.cornerRadius = 5.0f;
//    [self.view addSubview:landBtn];
//
//    UIButton* forgetBtn = [self createButtonFrame:CGRectMake(10, landBtn.maxY + 10, self.view.frame.size.width - 20, 37) backImageName:nil title:@"忘记密码" titleColor:CurrentAppThemeColor font:[UIFont systemFontOfSize:15] target:self action:@selector(forgetClick)];
//    forgetBtn.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:forgetBtn];
}

- (UITextField*)createTextFielfFrame:(CGRect)frame font:(UIFont*)font placeholder:(NSString*)placeholder{
    UITextField* textField = [[UITextField alloc] initWithFrame:frame];
    textField.font = font;
    textField.textColor = [UIColor grayColor];
    textField.borderStyle = UITextBorderStyleNone;
    textField.placeholder = placeholder;
    return textField;
}

- (UIImageView*)createImageViewFrame:(CGRect)frame imageName:(NSString*)imageName color:(UIColor*)color{
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
    if (imageName) imageView.image = [UIImage imageNamed:imageName];
    if (color) imageView.backgroundColor = color;
    return imageView;
}

- (UIButton*)createButtonFrame:(CGRect)frame backImageName:(NSString*)imageName title:(NSString*)title titleColor:(UIColor*)color font:(UIFont*)font target:(id)target action:(SEL)action{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (imageName) [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    if (font) btn.titleLabel.font = font;
    if (title) [btn setTitle:title forState:UIControlStateNormal];
    if (color)[btn setTitleColor:color forState:UIControlStateNormal];
    if (target && action) [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

//注册
- (void)registration:(UIButton*)button{
    [self.navigationController pushViewController:[[RTRegistViewController alloc] init] animated:YES];
}

@end
