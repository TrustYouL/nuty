
#import "TOPLoginViewController.h"
#import "UILabel+Block.h"
#import "TOPYYForgotPasswordAlertView.h"
#import "TOPRegisterViewController.h"
#import "TOPPurchaseCredutsViewController.h"
#import "TOPFreeBaseSqliteTools.h"
#import "TOPSubscriptionPayListViewController.h"
#import "TOPPurchaseCredutsViewController.h"


#import "TOPSettingGeneralVC.h"



#import <AuthenticationServices/AuthenticationServices.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
@interface TOPLoginViewController ()<GIDSignInDelegate,ASAuthorizationControllerDelegate,ASAuthorizationCredential,ASAuthorizationControllerPresentationContextProviding>

@property (strong, nonatomic) UITextField *emailTextF;
@property (strong, nonatomic) UITextField *passwordTextF;
@property (strong, nonatomic) UIButton *googleButton;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) UIButton *lockpsdButton;
@property (copy,nonatomic)    NSString *currentNonce;
@property (strong, nonatomic) UIButton *appleLoginButton;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UILabel *signLabel;

/*
 当前的登录状态
 */
@property (assign, nonatomic)  NSInteger signType;
@end

@implementation TOPLoginViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    [self top_creatLoginTextFieldUIView];
}
- (void)top_creatLoginTextFieldUIView
{
    [GIDSignIn sharedInstance].presentingViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    self.ref = [[FIRDatabase database] reference];
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
    
    UIButton *forgetPsdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgetPsdButton setTitle:NSLocalizedString(@"topscan_forgotpsd", @"") forState:UIControlStateNormal];
    [forgetPsdButton setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    forgetPsdButton.titleLabel.font = PingFang_R_FONT_(9);
    [forgetPsdButton.titleLabel showUnderLine];
    [forgetPsdButton addTarget:self action:@selector(top_forgetPasswordClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:forgetPsdButton];
    [forgetPsdButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.passwordTextF).offset(20);
        make.top.equalTo(self.passwordTextF.mas_bottom).offset(3);
        make.height.mas_offset(30);
    }];
    
    UIButton *signinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signinButton setTitle:NSLocalizedString(@"topscan_signup", @"") forState:UIControlStateNormal];
    [signinButton setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    signinButton.titleLabel.font = PingFang_R_FONT_(9);
    [signinButton.titleLabel showUnderLine];
    [self.view addSubview:signinButton];
    [signinButton addTarget:self action:@selector(top_signinRegisterGoogleAccountClick:) forControlEvents:UIControlEventTouchUpInside];
    [signinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.passwordTextF).offset(-20);
        make.top.equalTo(self.passwordTextF.mas_bottom).offset(3);
        make.height.mas_offset(30);
    }];
    
    UILabel *noAccountLabel = [UILabel new];
    noAccountLabel.text = NSLocalizedString(@"topscan_noaccount", @"");
    noAccountLabel.textColor = TOPAPPGreenColor;
    noAccountLabel.font = PingFang_R_FONT_(9);
    
    [self.view addSubview:noAccountLabel];
    [noAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(signinButton.mas_leading);
        make.top.equalTo(signinButton);
        make.height.mas_offset(30);
    }];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setTitle:NSLocalizedString(@"topscan_login", @"") forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = PingFang_M_FONT_(17);
    
    [self.loginButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(top_loginEmailClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setBackgroundColor:RGBA(36, 196, 164, 0.5)];
    [self.view addSubview:self.loginButton];
    self.loginButton.layer.cornerRadius = 50/2;
    self.loginButton.clipsToBounds = YES;
    [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-35.5);
        make.leading.equalTo(self.view).offset(35.5);
        make.top.equalTo(noAccountLabel.mas_bottom).offset(40);
        make.height.mas_offset(50);
    }];
    
    self.googleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.googleButton setImage:[UIImage imageNamed:@"top_login_googlelogin"] forState:UIControlStateNormal];
    [self.googleButton addTarget:self action:@selector(top_googleAccountLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.googleButton];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0) {
        CGFloat centerSpace = 0.0;
        if (isRTL()) {
            centerSpace = 30;
        }else{
            centerSpace = -30;
        }
        [_googleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).offset(centerSpace);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight-60);
            make.height.mas_offset(40);
            make.width.mas_offset(40);
        }];
        self.appleLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.appleLoginButton setImage:[UIImage imageNamed:@"top_login_applelogin"] forState:UIControlStateNormal];
        [self.appleLoginButton addTarget:self action:@selector(top_appleIDLoginClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.appleLoginButton];
        [_appleLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.googleButton.mas_trailing).offset(20);
            make.bottom.equalTo(self.googleButton);
            make.height.mas_offset(40);
            make.width.mas_offset(40);
        }];
    }else{
        [_googleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight-60);
            make.height.mas_offset(40);
            make.width.mas_offset(40);
        }];
    }
    UILabel *quickLoginLabel = [UILabel new];
    quickLoginLabel.text = NSLocalizedString(@"topscan_quicklogin", @"");
    quickLoginLabel.textColor = UIColorFromRGB(0xC4C4C5);
    quickLoginLabel.font = PingFang_R_FONT_(11);
    
    [self.view addSubview:quickLoginLabel];
    [quickLoginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.googleButton.mas_top).offset(-20);
        make.height.mas_offset(70);
    }];
    
    UILabel *leftLineLabel = [UILabel new];
    leftLineLabel.backgroundColor = UIColorFromRGB(0xC4C4C5);
    [self.view addSubview:leftLineLabel];
    [leftLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(quickLoginLabel);
        make.trailing.equalTo(quickLoginLabel.mas_leading).offset(-30);
        make.leading.equalTo(self.view).offset(60);
        make.height.mas_offset(1);
    }];
    
    UILabel *rightLineLabel = [UILabel new];
    rightLineLabel.backgroundColor = UIColorFromRGB(0xC4C4C5);
    [self.view addSubview:rightLineLabel];
    [rightLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(quickLoginLabel);
        make.leading.equalTo(quickLoginLabel.mas_trailing).offset(30);
        make.trailing.equalTo(self.view).offset(-60);
        make.height.mas_offset(1);
    }];
}
#pragma mark- 监听输入邮箱和密码输入框内容
- (void)top_changeEmailAndPassWordClick:(UITextField *)textfield
{
    if (self.emailTextF.text.length>0&&self.passwordTextF.text.length>0) {
        self.loginButton.backgroundColor = TOPAPPGreenColor;
        self.loginButton.userInteractionEnabled = YES;
    }else{
        self.loginButton.backgroundColor = UIColorFromRGB(0xBCD7F7);
        self.loginButton.userInteractionEnabled = NO;
    }
}
#pragma mark- 返回上一页面
- (void)top_backHomeAction
{
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


#pragma mark- 忘记密码
- (void)top_forgetPasswordClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    [FIRAnalytics logEventWithName:@"forgotPassword_Method" parameters:nil];
    TOPYYForgotPasswordAlertView *forgotAlertView = [TOPYYForgotPasswordAlertView top_creatXIB];
    forgotAlertView.sendTextForgotPasswordBlock = ^(NSString *tempName) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_loading", @"")];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [[FIRAuth auth] sendPasswordResetWithEmail:tempName completion:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            if (!error) {
                UIAlertController *col = [UIAlertController alertControllerWithTitle:@"Reset Password" message:[NSString stringWithFormat:@"Reset the password link has been sent to the account %@ , please pay attention to check.",tempName] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok" ,@"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                
                [col addAction:cancelAction];
                [self presentViewController:col animated:YES completion:nil];
                NSLog(@"成功");
            }else{
                if (error && [error.userInfo.allKeys containsObject:@"NSLocalizedDescription"]) {
                    UIAlertController *col = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"") message:error.userInfo[@"NSLocalizedDescription"] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok" ,@"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    
                    [col addAction:cancelAction];
                    [self presentViewController:col animated:YES completion:nil];
                }
                NSLog(@"失败");
            }
            
        }];
    };
    [forgotAlertView top_showXibSupview:self.navigationController.view];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark- 注册账号
- (void)top_signinRegisterGoogleAccountClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    TOPRegisterViewController *registVC = [[TOPRegisterViewController alloc] init];
    registVC.closeLoginType = self.closeLoginType;
    registVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:registVC animated:YES];
}

#pragma mark- 账号密码登录
- (void)top_loginEmailClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    [FIRAnalytics logEventWithName:@"login_Method" parameters:nil];
    if (![TOPValidateTools istop_validateEmail:self.emailTextF.text] || [[self.emailTextF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_emailinvalidtips", @"")];
        return;
    }
    if ([TOPValidateTools top_validateString:self.passwordTextF.text] || [[self.passwordTextF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_psdemptytips", @"")];
        return;
    }
    //去除textfieled的前后空格
    self.emailTextF.text = [self.emailTextF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //去除textfieled的前后空格
    self.passwordTextF.text = [self.passwordTextF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![TOPValidateTools top_validateEmail:self.emailTextF.text]) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_emailinvalidtips"   , @"")];
        return;
    }
    self.signType = 1;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_loading", @"")];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [[FIRAuth auth] signInWithEmail:self.emailTextF.text
                           password:self.passwordTextF.text
                         completion:^(FIRAuthDataResult * _Nullable authResult,
                                      NSError * _Nullable error) {
        [self  top_setUserInfoAndDisMissLogin:authResult errorInfo:error];
    }];
}

#pragma mark- google登录
- (void)top_googleAccountLoginClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    [FIRAnalytics logEventWithName:@"google_signMethod" parameters:nil];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_loading", @"")];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    self.signType = 2;
    
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    signIn.shouldFetchBasicProfile = YES;
    signIn.delegate = self;
    
    signIn.presentingViewController = self;
    [signIn signIn];
}
#pragma mark- AppleID登录

- (void)top_appleIDLoginClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    self.signType = 3;
    
    if (@available(iOS 13.0, *)) {
        [self top_startSignInWithAppleFlow];
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark-ASAuthorizationControllerDelegate
-(void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)){
    
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
        NSString *rawNonce = self.currentNonce;
        if (appleIDCredential.identityToken == nil) {
            NSLog(@"Unable to fetch identity token.");
            return;
        }
        
        NSString *idToken = [[NSString alloc] initWithData:appleIDCredential.identityToken
                                                  encoding:NSUTF8StringEncoding];
        if (idToken == nil) {
            NSLog(@"Unable to serialize id token from data: %@", appleIDCredential.identityToken);
        }
        
        FIROAuthCredential *credential = [FIROAuthProvider credentialWithProviderID:@"apple.com"
                                                                            IDToken:idToken
                                                                           rawNonce:rawNonce];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_loading", @"")];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRAuthDataResult * _Nullable authResult,
                                               NSError * _Nullable error) {
            [self  top_setUserInfoAndDisMissLogin:authResult errorInfo:error];
        }];
    }
    
}
///回调失败
-(void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)){
    NSLog(@"%@",error);
}
///代理主要用于展示在哪里
-(ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller API_AVAILABLE(ios(13.0)){
    return self.view.window;
}

- (NSString *)top_randomNonce:(NSInteger)length {
    NSAssert(length > 0, @"Expected nonce to have positive length");
    NSString *characterSet = @"0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._";
    NSMutableString *result = [NSMutableString string];
    NSInteger remainingLength = length;
    
    while (remainingLength > 0) {
        NSMutableArray *randoms = [NSMutableArray arrayWithCapacity:16];
        for (NSInteger i = 0; i < 16; i++) {
            uint8_t random = 0;
            int errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random);
            NSAssert(errorCode == errSecSuccess, @"Unable to generate nonce: OSStatus %i", errorCode);
            
            [randoms addObject:@(random)];
        }
        
        for (NSNumber *random in randoms) {
            if (remainingLength == 0) {
                break;
            }
            
            if (random.unsignedIntValue < characterSet.length) {
                unichar character = [characterSet characterAtIndex:random.unsignedIntValue];
                [result appendFormat:@"%C", character];
                remainingLength--;
            }
        }
    }
    
    return result;
}
- (void)top_startSignInWithAppleFlow API_AVAILABLE(ios(13.0)){
    NSString *nonce = [self top_randomNonce:32];
    self.currentNonce = nonce;
    ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
    ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
    request.nonce = [self top_stringBySha256HashingString:nonce];
    
    ASAuthorizationController *authorizationController =
    [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    authorizationController.delegate = self;
    authorizationController.presentationContextProvider = self;
    [authorizationController performRequests];
}

- (NSString *)top_stringBySha256HashingString:(NSString *)input {
    const char *string = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(string, (CC_LONG)strlen(string), result);
    
    NSMutableString *hashed = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hashed appendFormat:@"%02x", result[i]];
    }
    return hashed;
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
    switch (self.signType) {
        case 1:
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_loginsuccessful", @"")];
            break;
        case 2:
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_googleloginsuccessful", @"")];
            break;
        case 3:
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_appleloginsuccessful", @"")];
            break;
        default:
            break;
    }
    
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
        case TOPLoginSuccessfulJumpTypePopToGeneral:
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


@end
