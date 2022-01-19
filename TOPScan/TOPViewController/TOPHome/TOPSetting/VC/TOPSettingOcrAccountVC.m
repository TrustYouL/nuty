#import "TOPSettingOcrAccountVC.h"
#import "TOPOcrAccountTableViewCell.h"
#import "TOPLoginViewController.h"
#import "TOPPurchaseCredutsViewController.h"
#import "TOPSubscriptionPayListViewController.h"

@interface TOPSettingOcrAccountVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic,strong) NSMutableArray *datasArrays;
@property (nonatomic,strong) TOPImageTitleButton *creditsbgView;
@property (nonatomic,strong) UIButton *signOutButton;
@property (nonatomic,strong) UILabel *creditsLabel;
@end

@implementation TOPSettingOcrAccountVC
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.tableView reloadData];
    if ([TOPSubscriptTools googleLoginStates]) {
        self.datasArrays = [NSMutableArray arrayWithArray:@[[FIRAuth auth].currentUser.email,@"UUID"]];
        self.signOutButton.hidden = NO;
        self.creditsbgView.hidden = NO;
        
    }else{
        self.datasArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_loginregister", @""),@"UUID"]];
        self.signOutButton.hidden = YES;
        self.creditsbgView.hidden = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(top_ocr_recognize_pagesChange:) name:@"top_ocr_recognize_pagesChange" object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma google实时数据库更新余额通知
- (void)top_ocr_recognize_pagesChange:(NSNotification *)not
{
    NSString *creditBalance = [NSString stringWithFormat:@"%ld",[TOPSubscriptTools getCurrentUserBalance]];
    CGSize creditSize = [self top_sizeWidthWidth:creditBalance font:PingFang_R_FONT_(16) maxHeight:44];
    [self.creditsbgView setTitle:creditBalance forState:UIControlStateNormal];
    self.creditsbgView.frame =CGRectMake(0, 0, creditSize.width+25, 50);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    UIButton *signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signOutButton setTitle:NSLocalizedString(@"topscan_singoutlowercase", @"") forState:UIControlStateNormal];
    [signOutButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    signOutButton.layer.cornerRadius = 25;
    signOutButton.clipsToBounds = YES;
    [signOutButton addTarget:self action:@selector(top_signOutClick:) forControlEvents:UIControlEventTouchUpInside];
    [signOutButton setBackgroundColor: TOPAPPGreenColor];
    [self.view addSubview:signOutButton];
    self.signOutButton = signOutButton;
    
    [signOutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(15);
        make.trailing.equalTo(self.view).offset(-15);
        make.bottom.equalTo(self.view).offset(-20-TOPBottomSafeHeight);
        make.height.mas_offset(50);
    }];
    UIBarButtonItem * creditsItem = [[UIBarButtonItem alloc]initWithCustomView:self.creditsbgView];
    self.navigationItem.rightBarButtonItem = creditsItem;
}


- (void)top_backHomeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([TOPSubscriptTools googleLoginStates]) {
        return 2;
    }else{
        return 1;
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.datasArrays.count;
    }
    return 1;
    
}
#pragma mark - TableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TOPOcrAccountTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPOcrAccountTableViewCell class]) forIndexPath:indexPath];
    if (indexPath.section == 0) {
        NSString *rowTitleName = self.datasArrays[indexPath.row];
        if ([rowTitleName isEqualToString:@"UUID"]) {
            cell.ocrContentLab.text = [NSString stringWithFormat:@"%@:%@",rowTitleName,[TOPUUID top_getUUID]];
            cell.ocrContentLab.font = PingFang_R_FONT_(14);
            
        }else{
            cell.ocrContentLab.text = rowTitleName;
            cell.ocrContentLab.font = PingFang_R_FONT_(16);
        }
    }else{
        cell.ocrContentLab.font = PingFang_R_FONT_(16);
        cell.ocrContentLab.text = NSLocalizedString(@"topscan_resetpassword", @"");
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]init];
    footerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }else{
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                if ([TOPSubscriptTools googleLoginStates]) {
                    [self top_setting_CopyStringToPastboard:[FIRAuth auth].currentUser.email];
                }else{
                    [self top_setting_loginOrregister];
                }
                break;
            case 1:
                [self top_setting_CopyStringToPastboard:[TOPUUID top_getUUID]];
                
                break;
            default:
                break;
        }
    }else{
        [self top_setting_ResetPasswordWithEmail];
    }
}

- (void)top_signOutClick:(UIButton *)sender
{
    [self top_setting_showTipSignOut];
}

#pragma mark- 弹出退出登录提示
- (void)top_setting_showTipSignOut
{
    UIAlertController *col = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"") message:NSLocalizedString(@"topscan_loginouttipsmessage", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    WS(ws);
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok" ,@"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [ws top_clearUserInfoTosignOut];
    }];
    [col addAction:confirmAction];
    [col addAction:cancelAction];
    [self presentViewController:col animated:YES completion:nil];
}

#pragma mark -  退出登录时清空相关信息
- (void)top_clearUserInfoTosignOut
{
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    TOPSubscriptModel *model = [TOPSubscriptTools getSubScriptData];
    model.userBalance = 0;
    model.userLoginBalance = 0;
    [TOPSubscriptTools changeSaveSubScripWith:model];
    self.creditsbgView.hidden = YES;
    self.signOutButton.hidden = YES;
    self.datasArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_loginregister", @""),@"UUID"]];
    
    [self.tableView reloadData];
}
#pragma mark- 登录注册
- (void)top_setting_loginOrregister
{
    TOPLoginViewController *loginVC = [[TOPLoginViewController alloc] init];
    loginVC.closeLoginType = TOPLoginSuccessfulJumpTypePopToGeneral;
    loginVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginVC animated:YES];
    
}
- (void)top_setting_pushPurchaseCredits:(UIButton *)sender
{
    if (![TOPSubscriptTools getSubscriptStates]) {
        if ([TOPAppTools needShowDiscountThemeView]) {
            [[TOPDiscountThemeView shareInstance] top_showDiscountTheme:@"20211123_year_sub"];
            return;
        } 
        TOPSubscriptionPayListViewController *subscriptVC = [[TOPSubscriptionPayListViewController alloc] init];
        subscriptVC.closeType = TOPSubscriptOverCloseTypeOCRSub;
        TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:subscriptVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        if ([TOPSubscriptTools getCurrentSubscriptIdentifyNum]<=0) {
            TOPPurchaseCredutsViewController *purVC = [[TOPPurchaseCredutsViewController alloc] init];
            purVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:purVC animated:YES];
        }
    }
    
}
#pragma mark- 复制到粘贴板
- (void)top_setting_CopyStringToPastboard:(NSString *)padString
{
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    pab.string = padString;
    if (pab == nil) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_copyfailed", @"")];
    } else {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_copysuccessful", @"")];
    }
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[TOPOcrAccountTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPOcrAccountTableViewCell class])];
    }
    return _tableView;
}
- (NSMutableArray *)datasArrays
{
    if (!_datasArrays) {
        _datasArrays = [NSMutableArray array];
    }
    return   _datasArrays;
}

- (TOPImageTitleButton *)creditsbgView
{
    if (!_creditsbgView) {
        NSString *creditBalance = [NSString stringWithFormat:@"%ld",[TOPSubscriptTools getCurrentUserBalance]];
        
        TOPImageTitleButton *btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
        UIImage *btnImg = [UIImage imageNamed:@"top_credits_ocrNum"];
        [btn setImage:btnImg forState:UIControlStateNormal];
        [btn setTitle:creditBalance forState:UIControlStateNormal];
        CGSize creditSize = [self top_sizeWidthWidth:creditBalance font:PingFang_R_FONT_(16) maxHeight:44];
        btn.frame =CGRectMake(0, 0, creditSize.width+25, 50);
        btn.titleLabel.font = PingFang_R_FONT_(16);
        [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x262B30)] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(top_setting_pushPurchaseCredits:) forControlEvents:UIControlEventTouchUpInside];
        
        _creditsbgView = btn;
    }
    return  _creditsbgView;
}

- (CGSize)top_sizeWidthWidth:(NSString *)text font:(UIFont *)font maxHeight:(CGFloat)height{
    
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
    attrDict[NSFontAttributeName] = font;
    CGSize size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil].size;
    return size;
}
#pragma mark- 重置密码
- (void)top_setting_ResetPasswordWithEmail{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_loading", @"")];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    [[FIRAuth auth] sendPasswordResetWithEmail:[FIRAuth auth].currentUser.email completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        
        if (!error) {
            UIAlertController *col = [UIAlertController alertControllerWithTitle:@"Reset Password" message:[NSString stringWithFormat:@"Reset the password link has been sent to the account %@ , please pay attention to check.",[FIRAuth auth].currentUser.email] preferredStyle:UIAlertControllerStyleAlert];
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
}


@end
