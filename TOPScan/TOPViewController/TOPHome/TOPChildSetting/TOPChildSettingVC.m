#define AddFolder_W 310
#define AddFolder_H 240
#define AddFolderSingle_H 190

#import "TOPChildSettingVC.h"
#import "TOPChildSettingFCell.h"
#import "TOPChildSettingSCell.h"
#import "TOPChildSettingTLockCell.h"
#import "TOPChildSettingFourthCell.h"
#import "TOPChildSettingTPDFCell.h"
#import "TOPChildSettingTPDFFinishCell.h"
@interface TOPChildSettingVC ()<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) TOPDocPasswordView * passwordView;
@property (nonatomic, strong) UIView * coverView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, assign) BOOL isShowFailToast;
@end

@implementation TOPChildSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self top_setupUI];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    [self.tableView reloadData];
}
#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    if (self.passwordView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            if (self.passwordView.actionType == TOPHomeMoreFunctionSetLockFirst || self.passwordView.actionType == TOPHomeMoreFunctionPDFPassword) {
                self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_H, AddFolder_W, AddFolder_H);
            }else{
                self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolderSingle_H, AddFolder_W, AddFolderSingle_H);
            }
        }];
    }
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    if (![self.passwordView.tField isFirstResponder]&&![self.passwordView.againField isFirstResponder]) {
        [self top_childSetting_RemoveCurrentView];
    }
}
- (void)childSetting_BackHomeAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2) {
        return 2;
    }else{
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TOPChildSettingFCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPChildSettingFCell class]) forIndexPath:indexPath];
        if (IS_IPAD) {
            cell.hidden = YES;
        }else{
            cell.hidden = NO;
        }
        return cell;
    }else if(indexPath.section == 1){
        TOPChildSettingSCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPChildSettingSCell class]) forIndexPath:indexPath];
        return cell;
    }else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            TOPChildSettingTLockCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPChildSettingTLockCell class]) forIndexPath:indexPath];
            cell.pathString = self.pathString;
            return cell;
        }else{
            if ([[TOPScanerShare top_pdfPassword] length]) {
                TOPChildSettingTPDFFinishCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPChildSettingTPDFFinishCell class]) forIndexPath:indexPath];
                cell.showVip = ![TOPPermissionManager top_enableByPDFPassword];
                return cell;
            }else{
                TOPChildSettingTPDFCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPChildSettingTPDFCell class]) forIndexPath:indexPath];
                cell.showVip = ![TOPPermissionManager top_enableByPDFPassword];
                return cell;
            }
        }
    }else{
        TOPChildSettingFourthCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPChildSettingFourthCell class]) forIndexPath:indexPath];
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (IS_IPAD) {
            return 0;
        }else{
            return 140;
        }
    }else if(indexPath.section == 1){
        return 140;
    }else {
        if (indexPath.section == 2) {
            if (indexPath.row == 1) {
                if ([[TOPScanerShare top_pdfPassword] length]) {
                    return 70;
                }
            }
        }
        return 50;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 10)];
    headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    return headerView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 10)];
    footerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (IS_IPAD) {
            return 0;
        }
        return 15;
    }else if(section == 3){
        return 30;
    }else{
        return 10;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            NSString * passwordString = [TOPDocumentHelper top_getDocPasswordPathString:self.pathString];//用于判断是加锁还是解锁功能
            if (![TOPWHCFileManager top_isExistsAtPath:passwordString]) {//加锁
                [self top_childSetting_DocLock];
            }else{//解锁
                [self top_childSetting_DocUnlock:passwordString];
            }
        }else{
            [self top_childSetting_MoreViewPDFPassword];
        }
    }
}
#pragma mark -- doc加锁
- (void)top_childSetting_DocLock{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    NSString * password = [TOPScanerShare top_docPassword];
    if (password.length == 0) {//保存本地的密码如果是空的 就重新全局遍历一次 看文档是不是有密码
        [SVProgressHUD show];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TOPDocumentHelper top_defaultPassword];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            NSString * defaultPassword = [TOPScanerShare top_docPassword];
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0);
            if (defaultPassword.length == 0) {
                self.passwordView.actionType = TOPHomeMoreFunctionSetLockFirst;
            }else{
                self.passwordView.actionType = TOPHomeMoreFunctionSetLock;
            }
            [keyWindow addSubview:self.coverView];
            [self top_markupCoverMask];
            [keyWindow addSubview:self.passwordView];
        });
    });
}
#pragma mark -- doc解锁
- (void)top_childSetting_DocUnlock:(NSString *)passwordString{
    [TOPWHCFileManager top_removeItemAtPath:passwordString];
    [TOPScanerShare shared].isRefresh = YES;//密码清楚完成之后在 工具箱listVC界面刷新数据
    [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_successfullyunlocked", @"")];
    [self.tableView reloadData];
}
- (void)top_passwordViewActionWithPassword:(NSString *)password WithType:(NSInteger)actionType{
    switch (actionType) {
        case TOPHomeMoreFunctionSetLockFirst://第一次写入密码
            [self top_childSetting_RemoveCurrentView];
            [self top_childSetting_WritePasswordToDoc:password];
            break;
        case TOPHomeMoreFunctionSetLock://有默认密码时设置密码
            [self top_childSetting_SetLockagain:password];
            break;
        case TOPHomeMoreFunctionPDFPassword:
            [self top_childSetting_RemoveCurrentView];
            [self top_addPDFPassword:password];
        default:
            break;
    }
}
- (void)top_childSetting_WritePasswordToDoc:(NSString *)password{
    [TOPDocumentHelper top_creatDocPasswordWithPath:self.pathString withPassword:password];//没有默认密码直接写入
    [[TOPCornerToast shareInstance]makeToast:[NSString stringWithFormat:@"%@%@",[NSLocalizedString(@"topscan_colletiondocpasswordtitle", @"") stringByAppendingString:@":"],password]];
    [TOPScanerShare top_writeDocPasswordSave:password];
    [self.tableView reloadData];
}

- (void)top_childSetting_SetLockagain:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_SetLockagain" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_childSetting_RemoveCurrentView];
        [self top_childSetting_WritePasswordToDoc:password];
    }else{
        [self top_writePasswordFail];
    }
}
- (void)top_writePasswordFail{
    if (self.isShowFailToast) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_writepasswordfail", @"") duration:1];
    }
}
#pragma mark --PDF密码
- (void)top_childSetting_MoreViewPDFPassword{
    if ([[TOPScanerShare top_pdfPassword] length] > 0) {//有密码时清空pdf密码
        [TOPScanerShare top_writePDFPassword:@""];
        [[TOPCornerToast shareInstance] makeToast:[NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"]];
        [self.tableView reloadData];
    } else {
        if (![TOPPermissionManager top_enableByPDFPassword]) {
            [self top_subscriptionService];
            return;
        }
        [self top_showPasswordView];//没有密码时弹出弹框设置pdf密码
    }
}
#pragma mark -- 创建密码
- (void)top_showPasswordView {
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    if (!_coverView) {
        self.coverView.alpha = 0.5;
        [keyWindow addSubview:self.coverView];
        [self top_markupCoverMask];
    }
    if (!_passwordView) {
        self.passwordView.actionType = TOPHomeMoreFunctionPDFPassword;
        [keyWindow addSubview:self.passwordView];
    }
}
#pragma mark -- 写入pdf密码
- (void)top_addPDFPassword:(NSString *)password {
    [TOPScanerShare top_writePDFPassword:password];
    [[TOPCornerToast shareInstance] makeToast:[NSString stringWithFormat:@"%@ %@",[NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"], password]];
    [self.tableView reloadData];
}
#pragma mark -- 去订阅
- (void)top_subscriptionService {
    TOPSubscriptionPayListViewController * generalVC = [[TOPSubscriptionPayListViewController alloc] init];
    [self.navigationController pushViewController:generalVC animated:YES];
}
#pragma mark -- Send feedback
- (void)top_settingView_SendFeedback{
    [FIRAnalytics logEventWithName:@"settingView_SendFeedback" parameters:nil];
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        return;
    }
    if (![mailClass canSendMail]) {
        //提示框添加文本输入框
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_bind", @"")
                                                                       message:NSLocalizedString(@"topscan_bindcontent", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
          
        }];
        [alert addAction:okAction];

        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    MFMailComposeViewController * mailCompose = [[MFMailComposeViewController alloc]init];
    mailCompose.mailComposeDelegate = self;
    [mailCompose setSubject:NSLocalizedString(@"topscan_passwordhelpsubject", @"")];
    
    NSArray * toRecipients = [NSArray arrayWithObjects:SimplescannerEmail,nil];
    [mailCompose setToRecipients:toRecipients];
    
    NSString *emailBody = [NSString stringWithFormat:@"Model:%@\n %@\n App:%@",[TOPAppTools deviceVersion],[TOPAppTools SystemVersion],[TOPAppTools getAppVersion]];

    [mailCompose setMessageBody:emailBody isHTML:NO];
    [self presentViewController:mailCompose animated:YES completion:^{
           
    }];
}
#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSString * msg ;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"取消发送邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"保存邮件成功";
            break;
        case MFMailComposeResultSent:
            msg = @"邮件发送成功";
           
            break;
        case MFMailComposeResultFailed:
            msg = @"保存或者发送邮件失败";
            break;
        default:
            msg = @"66666";
            break;
    }
    NSLog(@"msg===%@",msg);
}
- (void)top_childSetting_RemoveCurrentView{
    [UIView animateWithDuration:0.3 animations:^{
        [self.coverView removeFromSuperview];
        [self.passwordView removeFromSuperview];
        self.coverView = nil;
        self.passwordView = nil;
    }];
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight) style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[TOPChildSettingFCell class] forCellReuseIdentifier:NSStringFromClass([TOPChildSettingFCell class])];
        [_tableView registerClass:[TOPChildSettingSCell class] forCellReuseIdentifier:NSStringFromClass([TOPChildSettingSCell class])];
        [_tableView registerClass:[TOPChildSettingTLockCell class] forCellReuseIdentifier:NSStringFromClass([TOPChildSettingTLockCell class])];
        [_tableView registerClass:[TOPChildSettingTPDFCell class] forCellReuseIdentifier:NSStringFromClass([TOPChildSettingTPDFCell class])];
        [_tableView registerClass:[TOPChildSettingTPDFFinishCell class] forCellReuseIdentifier:NSStringFromClass([TOPChildSettingTPDFFinishCell class])];
        [_tableView registerClass:[TOPChildSettingFourthCell class] forCellReuseIdentifier:NSStringFromClass([TOPChildSettingFourthCell class])];
    }
    return _tableView;
}
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_childSetting_RemoveCurrentView)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}
#pragma mark -- 密码弹框
- (TOPDocPasswordView *)passwordView{
    if (!_passwordView) {
        WS(weakSelf);
        _passwordView = [[TOPDocPasswordView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolderSingle_H)];
        _passwordView.top_sendPassword = ^(NSString * _Nonnull password, NSInteger actionType ,BOOL isShowFailToast) {
            weakSelf.isShowFailToast = isShowFailToast;
            [weakSelf top_passwordViewActionWithPassword:password WithType:actionType];
            [TOPScanerShare shared].isRefresh = YES;//密码设置完成之后在 工具箱listVC界面刷新数据
        };
        _passwordView.top_clickToHide = ^{
            [weakSelf top_childSetting_RemoveCurrentView];
        };
        
        _passwordView.top_clickToHelp = ^{
            [weakSelf top_settingView_SendFeedback];
        };
    }
    return _passwordView;
}
#pragma mark -- 设置约束
- (void)top_markupCoverMask{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}
- (void)top_setupUI{
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(childSetting_BackHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(childSetting_BackHomeAction)];
    }
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
}

@end
