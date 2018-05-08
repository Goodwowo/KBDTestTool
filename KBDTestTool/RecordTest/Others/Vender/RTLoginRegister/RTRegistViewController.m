#import "RTLoginViewController.h"
#import "RTRegistViewController.h"
#import "RecordTestHeader.h"
#import "RTCountDownButton.h"
//#import "ZHNSString.h"

@interface RTRegistViewController () {
    UIView* bgView;
    UITextField* phone;
    UITextField* code;
    UITextField* verificationCode;
    UINavigationBar* customNavigationBar;
    UIButton* yzButton;
    RTCountDownButton* getVerficationCodeButton;
}
@end

@implementation RTRegistViewController

- (void)regsiter{
//    StringEmptyAlert(phone.text, @"手机号不能为空!");
//    StringEmptyAlert(code.text, @"密码不能为空!");
//    StringEmptyAlert(verificationCode.text, @"验证码不能为空!");
//    ConditionAlert([ZHNSString isValidateNumber:phone.text] == NO, @"手机号码不存在!");
//    [self registerWith:phone.text password:code.text verCode:verificationCode.text];
}
- (void)getVerficationCodeAction{
//    StringEmptyAlert(phone.text, @"手机号不能为空!");
//    ConditionAlert([ZHNSString isValidateNumber:phone.text] == NO, @"手机号不存在!");
//    getVerficationCodeButton.enabled = YES;
//    getVerficationCodeButton.custom_acceptEventInterval = 1;

    //    NSString *urlMd5=[NSString stringWithFormat:@"http://dk.juyoux.cn/DKapi/SendVerification?UserPhone=%@&Types=%@&device=%@&version=%@&timestamp=%@",phone.text,@"0",[SDTool deviceID],[SDTool version],[NSString stringWithFormat:@"%lld",[DateTools getCurInterval]]];
    //    NSString *md5=[ZHNSString md5:urlMd5];
    //    [SDNetworking postWithUrl:[NSString stringWithFormat:@"http://dk.juyoux.cn/DKapi/SendVerification"] parameters:@{@"UserPhone":phone.text,@"Types":@"0",@"v":md5} shouldShowHud:YES forVC:self success:^(id json) {
    //
    //        NSDictionary  *dic=(NSDictionary *)json;
    //        NSLog(@"获取验证码:\n%@",dic);
    //        if ([dic isKindOfClass:[NSDictionary class]]) {
    //            [MBProgressHUD showMessage:dic[@"smgtxt"]];
    //            NSString *Success=[NSString stringWithFormat:@"%@",dic[@"Success"]];
    //            if ([Success isEqual:@"1"]) {
    //                [getVerficationCodeButton startCountDown];
    //                getVerficationCodeButton.enabled=NO;
    //                return;
    //            }
    //        }
    //        getVerficationCodeButton.enabled=YES;
    //
    //    } failure:^(NSError *error) {
    //        [MBProgressHUD showMessage:@"注册失败,请重试!"];
    //        getVerficationCodeButton.enabled=YES;
    //    }reloadBlock:^{
    //        if(![SDSingletonTool shared].isNetWork&&[SDSingletonTool shared].isMonitored){
    //            [MBProgressHUD showMessage:@"没有联网"];return;
    //        }
    //    }];
}
- (void)registerWith:(NSString*)userName password:(NSString*)password verCode:(NSString*)verCode{
    //    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithDictionary:@{@"UserPhone":userName,@"Pw":password,@"code":verCode}];
    //    NSString *urlMd5=@"";
    //    if (ycode.length>0) {
    //        [parameters setObject:ycode forKey:@"ycode"];
    //        urlMd5=[NSString stringWithFormat:@"http://dk.juyoux.cn/DKapi/AppRegister?UserPhone=%@&Pw=%@&code=%@&device=%@&version=%@&timestamp=%@",userName,password,verCode,[SDTool deviceID],[SDTool version],[NSString stringWithFormat:@"%lld",[DateTools getCurInterval]]];
    //    }else{
    //        urlMd5=[NSString stringWithFormat:@"http://dk.juyoux.cn/DKapi/AppRegister?UserPhone=%@&Pw=%@&code=%@&ycode=%@&device=%@&version=%@&timestamp=%@",userName,password,verCode,ycode,[SDTool deviceID],[SDTool version],[NSString stringWithFormat:@"%lld",[DateTools getCurInterval]]];
    //    }
    //
    //    NSString *md5=[ZHNSString md5:urlMd5];
    //    [parameters setObject:md5 forKey:@"v"];
    //
    //    [SDNetworking postWithUrl:[NSString stringWithFormat:@"http://dk.juyoux.cn/DKapi/AppRegister"] parameters:parameters shouldShowHud:YES forVC:self success:^(id json) {
    //
    //        NSDictionary  *dic=(NSDictionary *)json;
    //        NSLog(@"注册:\n%@",dic);
    //        if ([dic isKindOfClass:[NSDictionary class]]) {
    //            [MBProgressHUD showMessage:dic[@"smgtxt"]];
    //            NSString *Success=[NSString stringWithFormat:@"%@",dic[@"Success"]];
    //            if ([Success isEqual:@"1"]) {
    //                [self.navigationController popViewControllerAnimated:YES];
    //            }else{
    //                NSString *smgtxt=dic[@"smgtxt"];
    //                if(!(smgtxt&&[smgtxt isKindOfClass:[NSString class]]&&smgtxt.length>0))
    //                    [MBProgressHUD showMessage:@"注册失败,请重试!"];
    //            }
    //        }
    //    } failure:^(NSError *error) {
    //        [MBProgressHUD showMessage:@"注册失败,请重试!"];
    //    }reloadBlock:^{
    //        if(![SDSingletonTool shared].isNetWork&&[SDSingletonTool shared].isMonitored){
    //            [MBProgressHUD showMessage:@"没有联网"];return;
    //        }
    //    }];
}
- (void)viewDidLoad{
    [super viewDidLoad];

    self.title = @"注册";

    self.navigationController.navigationBarHidden = NO;
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    self.view.backgroundColor = [UIColor colorWithRed:240 / 255.0f green:240 / 255.0f blue:240 / 255.0f alpha:1];

    [self createTextFields];

    [self.view addUITapGestureRecognizerWithTarget:self withAction:@selector(hideKeyBoard)];
}

- (void)hideKeyBoard{
    [self.view endEditing:YES];
}

- (void)createTextFields{

    UIImageView* View = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    View.image = [UIImage imageNamed:@"bg4.jpg"];
    [self.view addSubview:View];

    CGRect frame = [UIScreen mainScreen].bounds;
    bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 45, frame.size.width - 20, 100 + 50)];
    bgView.layer.cornerRadius = 3.0;
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.alpha = 0.7;
    [self.view addSubview:bgView];

    phone = [self createTextFielfFrame:CGRectMake(80, 10, 260, 30) font:[UIFont systemFontOfSize:14] placeholder:@"输入手机号"];
    phone.keyboardType = UIKeyboardTypeNumberPad;

    code = [self createTextFielfFrame:CGRectMake(80, 60, 260, 30) font:[UIFont systemFontOfSize:14] placeholder:@"6-16位数字或字母"];

    verificationCode = [self createTextFielfFrame:CGRectMake(80, 110, 120, 30) font:[UIFont systemFontOfSize:14] placeholder:@"请填写验证码"];
    verificationCode.keyboardType = UIKeyboardTypeASCIICapable;

    //密文样式
    code.secureTextEntry = YES;

    UILabel* phonelabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, 50, 25)];
    phonelabel.text = @"手机号";
    phonelabel.textColor = [UIColor blackColor];
    phonelabel.textAlignment = NSTextAlignmentLeft;
    phonelabel.font = [UIFont systemFontOfSize:14];

    UILabel* codelabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 62, 50, 25)];
    codelabel.text = @"密码";
    codelabel.textColor = [UIColor blackColor];
    codelabel.textAlignment = NSTextAlignmentLeft;
    codelabel.font = [UIFont systemFontOfSize:14];

    UILabel* verificationCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 62 + 50, 50, 25)];
    verificationCodeLabel.text = @"验证码";
    verificationCodeLabel.textColor = [UIColor blackColor];
    verificationCodeLabel.textAlignment = NSTextAlignmentLeft;
    verificationCodeLabel.font = [UIFont systemFontOfSize:14];

    getVerficationCodeButton = [[RTCountDownButton alloc] initWithFrame:CGRectMake(bgView.width - 100 - 20, 62 + 50, 100, 25)];
    getVerficationCodeButton.originalColor = [UIColor whiteColor];
    getVerficationCodeButton.processColor = [UIColor grayColor];
    [getVerficationCodeButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [getVerficationCodeButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.7] forState:(UIControlStateDisabled)];
    getVerficationCodeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    getVerficationCodeButton.durationOfCountDown = 60;
    [getVerficationCodeButton addUITapGestureRecognizerWithTarget:self withAction:@selector(getVerficationCodeAction)];
    getVerficationCodeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//    getVerficationCodeButton.backgroundColor = CurrentAppThemeColor;
    [getVerficationCodeButton cornerRadiusWithFloat:2.5];

    UIImageView* line1 = [self createImageViewFrame:CGRectMake(20, 50, bgView.frame.size.width - 40, 1) imageName:nil color:[UIColor colorWithRed:180 / 255.0f green:180 / 255.0f blue:180 / 255.0f alpha:.3]];

    UIImageView* line2 = [self createImageViewFrame:CGRectMake(20, 50 + 50, bgView.frame.size.width - 40, 1) imageName:nil color:[UIColor colorWithRed:180 / 255.0f green:180 / 255.0f blue:180 / 255.0f alpha:.3]];

    UIButton* landBtn = [self createButtonFrame:CGRectMake(10, bgView.frame.size.height + bgView.frame.origin.y + 30, self.view.frame.size.width - 20, 37) backImageName:nil title:@"注册" titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:17] target:self action:@selector(regsiter)];
//    landBtn.backgroundColor = CurrentAppThemeColor;
    landBtn.layer.cornerRadius = 5.0f;

    [bgView addSubview:phone];
    [bgView addSubview:code];
    [bgView addSubview:verificationCode];

    [bgView addSubview:getVerficationCodeButton];
    [bgView addSubview:phonelabel];
    [bgView addSubview:codelabel];
    [bgView addSubview:verificationCodeLabel];
    [bgView addSubview:line1];
    [bgView addSubview:line2];
    [self.view addSubview:landBtn];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    [phone resignFirstResponder];
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
    if (imageName)imageView.image = [UIImage imageNamed:imageName];
    if (color)imageView.backgroundColor = color;
    return imageView;
}

- (UIButton*)createButtonFrame:(CGRect)frame backImageName:(NSString*)imageName title:(NSString*)title titleColor:(UIColor*)color font:(UIFont*)font target:(id)target action:(SEL)action{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (imageName)[btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    if (font)btn.titleLabel.font = font;
    if (title)[btn setTitle:title forState:UIControlStateNormal];
    if (color)[btn setTitleColor:color forState:UIControlStateNormal];
    if (target && action)[btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
