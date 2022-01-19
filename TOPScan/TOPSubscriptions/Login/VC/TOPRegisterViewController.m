
#import "TOPRegisterViewController.h"
#import "TOPPurchaseCredutsViewController.h"
#import "TOPFreeBaseSqliteTools.h"
#import "TOPSubscriptionPayListViewController.h"
#import "TOPPurchaseCredutsViewController.h"
#import "TOPSettingOcrAccountVC.h"


@interface TOPRegisterViewController ()
/*
 注册验证码邮件模块的启用或者禁用1启用,-1禁用
 */
@property (nonatomic,assign) NSInteger signUpEmailType;
@property (strong, nonatomic) UITextField *emailTextF;
@property (strong, nonatomic) UITextField *passwordTextF;
@property (strong, nonatomic) UITextField *sendCodeTextF;
@property (strong, nonatomic) UIButton *lockpsdButton;
@property (strong, nonatomic) UIButton *sendCodeButton;
@property (strong, nonatomic) UIButton *signinButton;
@property (strong, nonatomic) UIView *sendCodebgView;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) dispatch_source_t codeTimer;
@end

@implementation TOPRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    [self top_getAppVersionFunction];
    [self top_creatLoginTextFieldUIView];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
- (void)top_creatLoginTextFieldUIView
{
    [GIDSignIn sharedInstance].presentingViewController = self;
    if (isRTL()) {//黑色
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    
    self.emailTextF = [[UITextField alloc] init];
    self.emailTextF.layer.cornerRadius = 44/2;
    self.emailTextF.clipsToBounds = YES;
    self.emailTextF.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:UIColorFromRGB(0xF3F3F3)];
    self.emailTextF.placeholder = NSLocalizedString(@"topscan_email", @"");
    self.emailTextF.font = PingFang_R_FONT_(11);
    [ self.emailTextF addTarget:self action:@selector(top_changeEmailAndPassWordClick:) forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:self.emailTextF];
    UIView *leftBGViw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    UIImageView *emailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_login_mail"]];
    emailImageView.frame = CGRectMake((60-38), (44-23)/2, 23, 23);
    [leftBGViw addSubview:emailImageView];
    self.emailTextF.leftView = leftBGViw;
    self.emailTextF.leftViewMode = UITextFieldViewModeAlways;
    [_emailTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-40);
        make.top.equalTo(self.view).offset(30);
        make.leading.equalTo(self.view).offset(40);
        make.height.mas_offset(44);
    }];
    
    self.passwordTextF = [[UITextField alloc] init];
    self.passwordTextF.layer.cornerRadius = 44/2;
    self.passwordTextF.clipsToBounds = YES;
    self.passwordTextF.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:UIColorFromRGB(0xF3F3F3)];
    self.passwordTextF.placeholder = NSLocalizedString(@"topscan_placeholderpassword", @"");
    self.passwordTextF.font = PingFang_R_FONT_(11);
    [self.passwordTextF addTarget:self action:@selector(top_changeEmailAndPassWordClick:) forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:self.passwordTextF];
    UIView *passLeftBGViw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    UIImageView *passwordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_login_password"]];
    passwordImageView.frame = CGRectMake((60-38), (44-23)/2, 23, 23);
    [passLeftBGViw addSubview:passwordImageView];
    self.passwordTextF.leftView = passLeftBGViw;
    self.passwordTextF.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextF.secureTextEntry = YES;
    [_passwordTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-40);
        make.top.equalTo(self.emailTextF.mas_bottom).offset(30);
        make.leading.equalTo(self.view).offset(40);
        make.height.mas_offset(44);
    }];
    self.lockpsdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lockpsdButton setImage:[UIImage imageNamed:@"top_dismissPassword"] forState:UIControlStateNormal];
    [self.lockpsdButton setImage:[UIImage imageNamed:@"top_showPassword"] forState:UIControlStateSelected];
    [self.lockpsdButton addTarget:self action:@selector(top_lockPasswordClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.lockpsdButton];
    
    [_lockpsdButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-40);
        make.top.equalTo(self.emailTextF.mas_bottom).offset(30);
        make.height.mas_offset(44);
        make.width.mas_offset(60);
    }];
    
    self.sendCodeTextF = [[UITextField alloc] init];
    self.sendCodeTextF.layer.cornerRadius = 44/2;
    self.sendCodeTextF.clipsToBounds = YES;
    self.sendCodeTextF.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:UIColorFromRGB(0xF3F3F3)];
    self.sendCodeTextF.placeholder = NSLocalizedString(@"topscan_entervercode", @"");
    self.sendCodeTextF.font = PingFang_R_FONT_(11);
    [self.sendCodeTextF addTarget:self action:@selector(top_changeEmailAndPassWordClick:) forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:self.sendCodeTextF];
    UIView *codeLeftBGViw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    UIImageView *codeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_login_password"]];
    codeImageView.frame = CGRectMake((60-38), (44-23)/2, 23, 23);
    [codeLeftBGViw addSubview:codeImageView];
    self.sendCodeTextF.leftView = codeLeftBGViw;
    self.sendCodeTextF.leftViewMode = UITextFieldViewModeAlways;
    self.sendCodeTextF.hidden = YES;
    
    [_sendCodeTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-40);
        make.top.equalTo(self.passwordTextF.mas_bottom).offset(30);
        make.leading.equalTo(self.view).offset(40);
        make.height.mas_offset(0);
    }];
    self.sendCodebgView = [[UIView alloc] init];
    self.sendCodebgView.hidden = YES;
    [self.view addSubview:_sendCodebgView];
    
    [_sendCodebgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-40);
        make.top.equalTo(self.passwordTextF.mas_bottom).offset(30);
        make.height.mas_offset(0);
        make.width.mas_offset(80);
    }];
    
    self.sendCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendCodeButton setBackgroundColor:TOPAPPGreenColor];
    [self.sendCodeButton setTitle:NSLocalizedString(@"topscan_send", @"") forState:UIControlStateNormal];
    self.sendCodeButton.layer.cornerRadius = 32/2;
    self.sendCodeButton.titleLabel.font = PingFang_R_FONT_(13);
    self.sendCodeButton.clipsToBounds = YES;
    [self.sendCodeButton addTarget:self action:@selector(top_getCodeForServerClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendCodebgView addSubview:self.sendCodeButton];
    
    [_sendCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_sendCodebgView).offset(-8);
        make.centerY.equalTo(_sendCodebgView);
        make.height.mas_offset(32);
        make.width.mas_offset(71);
    }];
    
    self.signinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.signinButton setTitle:NSLocalizedString(@"topscan_signup", @"") forState:UIControlStateNormal];
    self.signinButton.titleLabel.font = PingFang_M_FONT_(17);
    
    [self.signinButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    [self.signinButton addTarget:self action:@selector(top_signinGoogleAccountClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.signinButton setBackgroundColor:RGBA(36, 196, 164, 0.5)];
    [self.view addSubview:self.signinButton];
    self.signinButton.layer.cornerRadius = 50/2;
    self.signinButton.clipsToBounds = YES;
    [_signinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-35.5);
        make.leading.equalTo(self.view).offset(35.5);
        make.top.equalTo(_sendCodeTextF.mas_bottom).offset(40);
        make.height.mas_offset(50);
    }];
}
#pragma mark- 监听输入邮箱和密码输入框内容
- (void)top_changeEmailAndPassWordClick:(UITextField *)textfield
{
    if (self.signUpEmailType ==1) {
        if (self.emailTextF.text.length>0&&self.passwordTextF.text.length>0 &&self.sendCodeTextF.text.length>0) {
            self.signinButton.backgroundColor = TOPAPPGreenColor;
            self.signinButton.userInteractionEnabled = YES;
        }else{
            self.signinButton.backgroundColor = UIColorFromRGB(0xBCD7F7);
            self.signinButton.userInteractionEnabled = NO;
        }
    }else{
        if (self.emailTextF.text.length>0&&self.passwordTextF.text.length>0) {
            self.signinButton.backgroundColor = TOPAPPGreenColor;
            self.signinButton.userInteractionEnabled = YES;
        }else{
            self.signinButton.backgroundColor = UIColorFromRGB(0xBCD7F7);
            self.signinButton.userInteractionEnabled = NO;
        }
    }
}
#pragma mark- 返回上一页面
- (void)top_backHomeAction
{
    if (self.codeTimer) {
        dispatch_source_cancel(_codeTimer);
    }
    [self.view endEditing:YES];
    if ([self isPushOrModal]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
#pragma mark- 查看密码
- (void)top_lockPasswordClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.passwordTextF.secureTextEntry = NO;
    }else{
        self.passwordTextF.secureTextEntry = YES;
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)top_signinGoogleAccountClick:(UIButton *)sender
{
    [FIRAnalytics logEventWithName:@"signIn_Method" parameters:nil];
    [self.view endEditing:YES];
    if ([TOPValidateTools top_validateString:self.emailTextF.text] ||  [[self.emailTextF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_emailemptytips", @"")];
        return;
    }
    if ([TOPValidateTools top_validateString:self.passwordTextF.text] || [[self.passwordTextF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_psdemptytips", @"")];
        return;
    }
    if (self.signUpEmailType == 1) {
        if ([TOPValidateTools top_validateString:self.sendCodeTextF.text] || [[self.sendCodeTextF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_codeemptytips", @"")];
            return;
        }
    }
    
    //去除textfieled的前后空格
    self.emailTextF.text = [self.emailTextF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //去除textfieled的前后空格
    self.passwordTextF.text = [self.passwordTextF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![TOPValidateTools top_validateEmail:self.emailTextF.text]) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_emailinvalidtips"   , @"")];
        return;
    }
    [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_loading", @"")];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    if (self.signUpEmailType == 1) {
        [self top_verificationCodeRequestServerCode:self.emailTextF.text];
    }else{
        [[FIRAuth auth] createUserWithEmail:self.emailTextF.text
                                   password:self.passwordTextF.text
                                 completion:^(FIRAuthDataResult * _Nullable authResult,
                                              NSError * _Nullable error) {
            [self  top_setUserInfoAndDisMissLogin:authResult errorInfo:error];
        }];
    }
    
}

#pragma mark- 获取验证码
- (void)top_getCodeForServerClick:(UIButton *)sender
{
    if ([TOPValidateTools top_validateString:self.emailTextF.text] ||  [[self.emailTextF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_emailemptytips", @"")];
        return;
    }
    if (![TOPValidateTools istop_validateEmail:self.emailTextF.text] || [[self.emailTextF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_emailinvalidtips"   , @"")];
        return;
    }
    [self top_requestServerCode:self.emailTextF.text];
}
#pragma mark -  获取是否需要验证码
/*
 获取app版本信息
 */
- (void)top_getAppVersionFunction
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WS(weakself);
    [[TOPScannerHttpRequest shareManager] top_PostNetDataWith:TOP_TRVersionFunctionInfo withDic:params andSuccess:^(NSDictionary * _Nonnull responseObject) {
        NSLog(@"获取app版本信息------%@",responseObject);
        NSInteger code = [responseObject[@"status"] integerValue];
        if (code == 1) {
            NSDictionary *resultDict = responseObject[@"data"];
            if (resultDict) {
                NSDictionary *versionFunctionDict = resultDict[@"versionFunction"];
                self.signUpEmailType = [versionFunctionDict[@"signUpEmailType"] integerValue];
            }
        }
        if (self.signUpEmailType == 1) {//隐藏验证码
            [weakself.sendCodeTextF mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_offset(44);
            }];
            [weakself.sendCodebgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_offset(44);
            }];
            self.sendCodeTextF.hidden = NO;
            self.sendCodebgView.hidden = NO;
        }else{
            self.sendCodeTextF.hidden = YES;
            self.sendCodebgView.hidden = YES;
        }
    } andFailure:^(NSError * _Nonnull error) {
    }];
}
#pragma mark- 获取验证码
- (void)top_requestServerCode:(NSString *)emailStr
{
    [self top_yourButtonTitleTime];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"deviceId"] = [TOPUUID top_getUUID];
    params[@"appType"] = AppType_SimpleScan;
    params[@"email"] = emailStr;
    params[@"appVersion"] = [TOPAppTools getAppVersion];
    [[TOPScannerHttpRequest shareManager] top_PostNetDataWith:TOP_TRVerificationCodeVerification withDic:params andSuccess:^(NSDictionary * _Nonnull responseObj) {
        NSInteger code = [responseObj[@"status"] integerValue];
        if (code == 1) {
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_sendcodesuccess", @"")];
        }
    } andFailure:^(NSError * _Nonnull error) {
    }];
}

#pragma mark-  校验验证码
- (void)top_verificationCodeRequestServerCode:(NSString *)emailStr
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"deviceId"] = [TOPUUID top_getUUID];
    params[@"appType"] = AppType_SimpleScan;
    params[@"email"] = emailStr;
    params[@"appVersion"] = [TOPAppTools getAppVersion];
    params[@"code"] = self.sendCodeTextF.text;
    [[TOPScannerHttpRequest shareManager] top_PostNetDataWith:TOP_TRVerificationCodeVerification withDic:params andSuccess:^(NSDictionary * _Nonnull responseObj) {
        NSLog(@"验证码校验------%@",responseObj);
        NSInteger code = [responseObj[@"status"] integerValue];
        if (code == 1) {
            NSDictionary *dict = responseObj[@"data"];
            if (dict) {
                NSInteger resultType = [dict[@"resultType"] integerValue];
                switch (resultType) {
                    case 0:
                    {
                        [[FIRAuth auth] createUserWithEmail:self.emailTextF.text
                                                   password:self.passwordTextF.text
                                                 completion:^(FIRAuthDataResult * _Nullable authResult,
                                                              NSError * _Nullable error) {
                            [self  top_setUserInfoAndDisMissLogin:authResult errorInfo:error];
                        }];
                    }
                        break;
                    case 1:
                    {
                        [SVProgressHUD dismiss];
                        [[TOPCornerToast shareInstance] makeToast:@"Parameter error"];
                    }
                        break;
                    case 1009:
                    {
                        [SVProgressHUD dismiss];
                        [[TOPCornerToast shareInstance] makeToast:@"Verification code error"];
                    }
                        break;
                    default:
                        break;
                }
            }
        }
    } andFailure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark- 登录成功数据处理
- (void)top_setUserInfoAndDisMissLogin:(FIRAuthDataResult *)authResult errorInfo:(NSError *)error
{
    if (error) {
        if (error.userInfo && [error.userInfo.allKeys containsObject:@"NSLocalizedDescription"]) {
            [[TOPCornerToast shareInstance] makeToast:error.userInfo[@"NSLocalizedDescription"]];
            [SVProgressHUD dismiss];
            return;
        }
        [SVProgressHUD dismiss];
        return;
    }
    
    [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_signinsuccess" , @"")];
    NSString *userID = [FIRAuth auth].currentUser.uid;
    [[[self.ref child:@"ocr_recognize_pages"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"%@",snapshot.value);
        NSInteger currentUserBalance = [TOPSubscriptTools getCurrentUserBalance];
        if (![snapshot.value isEqual:[NSNull null]]) {
            if (currentUserBalance >0) {
                if (![snapshot.value isEqual:[NSNull null]]) {
                    currentUserBalance = currentUserBalance + [snapshot.value integerValue];
                }
                [[[self.ref child:@"ocr_recognize_pages"] child:userID] setValue:[NSNumber numberWithInteger:currentUserBalance] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                    NSLog(@"%@",error);
                }];
            }else{
                currentUserBalance =  [snapshot.value integerValue];
            }
        }
        TOPSubscriptModel *model = [TOPSubscriptTools getSubScriptData];
        model.userBalance = 0;
        model.userLoginBalance = currentUserBalance;
        [TOPSubscriptTools changeSaveSubScripWith:model];
        
        [SVProgressHUD dismiss];
        [self top_closeBack];
        [[TOPFreeBaseSqliteTools sharedSingleton] openObserveGoogleFirebaseValue];
    } withCancelBlock:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self top_closeBack];
        [[TOPFreeBaseSqliteTools sharedSingleton] openObserveGoogleFirebaseValue];
    }];
}

- (void)top_closeBack
{
    switch (self.closeLoginType) {
        case TOPLoginSuccessfulJumpTypeClose:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case TOPLoginSuccessfulJumpTypePurchase:
        {
            TOPPurchaseCredutsViewController *subscriptVC = [[TOPPurchaseCredutsViewController alloc] init];
            subscriptVC.isCloseDissmiss = YES;
            subscriptVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:subscriptVC animated:YES];
        }
            break;
        case TOPLoginSuccessfulJumpTypePopToGeneral:
        {
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[TOPSettingOcrAccountVC class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
        }
            break;
        case TOPLoginSuccessfulJumpTypeSubscript:
        {
            if ([TOPAppTools needShowDiscountThemeView]) {
                [[TOPDiscountThemeView shareInstance] top_showDiscountTheme:@"20211123_year_sub"];
                return;
            } 
            TOPSubscriptionPayListViewController *subscriptVC = [[TOPSubscriptionPayListViewController alloc] init];
            subscriptVC.closeType = TOPSubscriptOverCloseTypeLoginSuccess;
            subscriptVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:subscriptVC animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark- 倒计时
- (void)top_yourButtonTitleTime
{
    __block int timeout=60; //倒计时时间
    WeakSelf(weakself);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _codeTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_codeTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_codeTimer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_codeTimer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                weakself.sendCodeButton.userInteractionEnabled = YES;
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [weakself.sendCodeButton setTitle:(timeout==0?NSLocalizedString(@"topscan_resend", @""):[NSString stringWithFormat:@"%ds",timeout]) forState:UIControlStateNormal];
                weakself.sendCodeButton.userInteractionEnabled = timeout==0?YES:NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_codeTimer);
}

#pragma mark- google GIDSignInDelegate
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    [SVProgressHUD dismiss];
    
    if (error == nil) {
        GIDAuthentication *authentication = user.authentication;
        [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_loading", @"")];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRAuthDataResult * _Nullable authResult,
                                               NSError * _Nullable error) {
            [self  top_setUserInfoAndDisMissLogin:authResult errorInfo:error];
        }];
    }
}
- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error{
    [SVProgressHUD dismiss];
}
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [SVProgressHUD dismiss];
}
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController
{
    [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:viewController animated:YES completion:nil];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
