#define AddFolder_W 310
#define AddFolder_H 240
#define AddFolderSingle_H 190
#import "TOPAppSafeSetViewController.h"
#import "TOPSwithBackTapTableViewCell.h"
#import "TOPAppSafeItemTableViewCell.h"
#import "TOPAppSafeShowPasswordVC.h"
#import "TOPTouchUnlockViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface TOPAppSafeSetViewController ()<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate>
@property (nonatomic,strong ) UITableView *tableView;
@property (nonatomic,strong ) NSMutableArray *itemArrays;
@property (nonatomic,strong ) NSMutableArray *sectionArrays;
@property (nonatomic,strong ) NSMutableArray *sectionSubTitleArrays;
@property (nonatomic,strong ) TOPDocPasswordView * passwordView;
@property (nonatomic,assign ) TOPLAContextSupportType currentDeviceType;
@property (nonatomic, strong) UIView * coverView;
@property (nonatomic,strong ) NSMutableArray *docSetArrays;
@property (nonatomic,strong ) NSMutableArray *pdfSetArrays;
@property (nonatomic, assign) BOOL isShowFailToast;

@end

@implementation TOPAppSafeSetViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self top_configLightBgDarkTitle];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.titleTextAttributes=
    @{NSForegroundColorAttributeName:[UIColor top_textColor:[UIColor whiteColor] defaultColor:TOPAPPGreenColor],
      NSFontAttributeName:[UIFont systemFontOfSize:18]};
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    BOOL isAppSafeState = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeStates] boolValue];
    NSInteger currentType = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeUnLockType] integerValue];
    
    if (isAppSafeState &&currentType==TOPAppSetSafeUnlockTypePwd) {
        self.sectionArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_appsecurity", @""),NSLocalizedString(@"topscan_changepassword", @"")]];
        self.sectionSubTitleArrays =  [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_appheadingtitle", @""),NSLocalizedString(@"topscan_changepassword", @"")]];
    }else{
        self.sectionArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_appsecurity", @"")]];
        self.sectionSubTitleArrays =  [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_appheadingtitle", @"")]];
    }
    [self.tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"topscan_appsecurity", @"");
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF9F9F9)];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[_tableView]|"
                               options:1.0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(_tableView)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    
    [self.tableView registerClass:[TOPAppSafeItemTableViewCell class] forCellReuseIdentifier:@"AppSafeItemIdentifier"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TOPSwithBackTapTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingSaveCellIdentifier"];
    
    self.sectionArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_appsecurity", @"")]];
    if ([TOPScanerShare top_docPassword].length>0) {
        self.docSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @""),NSLocalizedString(@"topscan_changepassword", @"")]];
    }else{
        self.docSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @"")]];
    }
    if ([TOPScanerShare top_pdfPassword].length>0) {
        self.pdfSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @""),NSLocalizedString(@"topscan_changepassword", @"")]];
    }else{
        self.pdfSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @"")]];
    }
    self.currentDeviceType =   [TOPDocumentHelper top_getBiometryType];
    switch (self.currentDeviceType) {
        case TOPLAContextSupportTypeNone:
        {
            self.itemArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_apppwd", @"")]];
        }
            break;
        case TOPLAContextSupportTypeTouchIDNotEnrolled:
        case TOPLAContextSupportTypeTouchID:
        {
            self.itemArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_apppwd", @""),NSLocalizedString(@"topscan_touchidtitle", @"")]];
        }
            break;
        case TOPLAContextSupportTypeFaceIDNotEnrolled:
        case TOPLAContextSupportTypeFaceID:
        {
            self.itemArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_apppwd", @""),NSLocalizedString(@"topscan_faceidtitle", @"")]];
        }
            break;
            
        default:
            break;
    }
    
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
}
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTapAction)];
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
        };
        _passwordView.top_clickToHide = ^{
            [weakSelf top_clickTapAction];
        };
        
        _passwordView.top_clickToHelp = ^{
            [weakSelf top_settingView_SendFeedback];
        };
    }
    return _passwordView;
}

- (void)top_passwordViewActionWithPassword:(NSString *)password WithType:(NSInteger)actionType{
    switch (actionType) {
        case TOPHomeMoreFunctionUnLock:
            [self top_safe_SetTurnOffLock:password];
            break;
        case TOPHomeMoreFunctionSetLockFirst:
            [self top_safe_SetTurnOnLock:password];
            break;
        case TOPHomeMoreFunctionSetLock:
            [self top_safe_SetChangeLock:password];
            break;
        case TOPHomeMoreFunctionPDFChangeLock:
            [self top_safe_SetChangePDFLock:password];
            break;
        case TOPHomeMoreFunctionPDFPassword:
            [self top_safe_SetTurnOnPDFLock:password];
            break;
        default:
            break;
    }
}

#pragma mark -- 关闭doc密码功能
- (void)top_safe_SetTurnOffLock:(NSString *)password{
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_clickTapAction];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray  * docArray = [TOPDataModelHandler top_buildSearchDataAtPath:[TOPDocumentHelper top_appBoxDirectory]];
            for (DocumentModel * docModel in docArray) {
                if ([docModel.type isEqualToString:@"1"]) {
                    NSString * docPasswordPath = docModel.docPasswordPath;
                    if (docPasswordPath.length>0) {
                        [TOPWHCFileManager top_removeItemAtPath:docPasswordPath];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [TOPScanerShare top_writeDocPasswordSave:@""];
                self.docSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @"")]];
                [self.tableView reloadData];
            });
        });
    }else{
        [self top_writePasswordFail];
    }
}

#pragma mark -- 开启doc密码功能
- (void)top_safe_SetTurnOnLock:(NSString *)password{
    [self top_clickTapAction];
    self.docSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @""),NSLocalizedString(@"topscan_changepassword", @"")]];
    [[TOPCornerToast shareInstance]makeToast:[NSString stringWithFormat:@"%@%@",[NSLocalizedString(@"topscan_colletiondocpasswordtitle", @"") stringByAppendingString:@":"],password]];
    [TOPScanerShare top_writeDocPasswordSave:password];
    [self.tableView reloadData];
}

#pragma mark -- 更改doc密码功能
- (void)top_safe_SetChangeLock:(NSString *)password{
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_clickTapAction];
        [self top_addPasswordView];
        self.passwordView.actionType = TOPHomeMoreFunctionSetLockFirst;
    }else{
        [self top_writePasswordFail];
    }
}

#pragma mark -- 开启PDF密码功能
- (void)top_safe_SetTurnOnPDFLock:(NSString *)password{
    [self top_clickTapAction];
    self.pdfSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @""),NSLocalizedString(@"topscan_changepassword", @"")]];
    [[TOPCornerToast shareInstance]makeToast:[NSString stringWithFormat:@"%@%@",[NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"],password]];
    [TOPScanerShare top_writePDFPassword:password];
    [self.tableView reloadData];
}

#pragma mark -- 更改PDF密码功能
- (void)top_safe_SetChangePDFLock:(NSString *)password{
    if ([password isEqualToString:[TOPScanerShare top_pdfPassword]]) {
        [self top_clickTapAction];
        [self top_addPasswordView];
        self.passwordView.actionType = TOPHomeMoreFunctionPDFPassword;
    }else{
        [self top_writePasswordFail];
    }
}
- (void)top_writePasswordFail{
    if (self.isShowFailToast) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_writepasswordfail", @"") duration:1];
    }
}

- (void)top_clickTapAction{
    [UIView animateWithDuration:0.3 animations:^{
        [self.passwordView removeFromSuperview];
        [self.coverView removeFromSuperview];
        self.passwordView = nil;
        self.coverView = nil;
    }];
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
        [self top_clickTapAction];
    }
}

#pragma mark -- 关闭doc密码视图
- (void)top_clickToTurnOffPassword{
    [self top_addPasswordView];
    self.passwordView.actionType = TOPHomeMoreFunctionUnLock;
}

#pragma mark -- 开启doc密码视图
- (void)top_clickToTurnOnPassword{
    [self top_addPasswordView];
    self.passwordView.actionType = TOPHomeMoreFunctionSetLockFirst;
}

#pragma mark --修改doc密码视图
- (void)top_clickToChangePassword{
    [self top_addPasswordView];
    self.passwordView.actionType = TOPHomeMoreFunctionSetLock;
}

#pragma mark -- 关闭pdf密码
- (void)top_clickToTurnOffPDFPassword{
    [TOPScanerShare top_writePDFPassword:@""];
    self.pdfSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @"")]];
    [self.tableView reloadData];
}

#pragma mark -- 开启pdf密码视图
- (void)top_clickToTurnOnPDFPassword{
    [self top_addPasswordView];
    self.passwordView.actionType = TOPHomeMoreFunctionPDFPassword;
}

#pragma mark --修改pdf密码视图
- (void)top_clickToChangePDFPassword{
    [self top_addPasswordView];
    self.passwordView.actionType = TOPHomeMoreFunctionPDFChangeLock;
    
}
- (void)top_addPasswordView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.coverView];
    [keyWindow addSubview:self.passwordView];
    [self top_markupCoverMask];
}

- (void)top_initBackButton:(nullable NSString *)imgName withSelector:(SEL)selector{
    TOPImageTitleButton * btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

- (void)top_backHomeAction{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:UIColorFromRGB(0xFFFFFF),
                                                                    NSFontAttributeName:[UIFont systemFontOfSize:18]};
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionArrays.count;
}

-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = self.sectionArrays[section];
    
    if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_appsecurity",@"")]) {
        return self.itemArrays.count;
    }
    if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_docaccesspassword", @"")]) {
        return self.docSetArrays.count;
    }
    if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_pdfpassword", @"")]) {
        return self.pdfSetArrays.count;
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = self.sectionArrays[indexPath.section];
    if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_appsecurity",@"")]) {
        
        NSString *swithName = self.itemArrays[indexPath.row];
        TOPSwithBackTapTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingSaveCellIdentifier" forIndexPath:indexPath];
        cell.swithName = swithName;
        WeakSelf(ws);
        cell.top_swichOpenOrCloseAppSafeBlock = ^(BOOL isOpen,NSString *currentItem) {
            [ws changePwdStates:isOpen inType:currentItem];
        };
        return cell;
    }
    
    if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_docaccesspassword", @"")]) {
        NSString *swithName = self.docSetArrays[indexPath.row];
        if ([swithName isEqualToString:NSLocalizedString(@"topscan_turnoffpassword",@"")]) {
            TOPSwithBackTapTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingSaveCellIdentifier" forIndexPath:indexPath];
            cell.cellType = @"doc";
            cell.swithName = swithName;
            WS(weakSelf);
            cell.top_swichOpenOrCloseAppSafeBlock = ^(BOOL isOpen,NSString *currentItem) {
                if (isOpen) {
                    [weakSelf top_clickToTurnOffPassword];
                }else{
                    [weakSelf top_clickToTurnOnPassword];
                }
                
            };
            return cell;
        }
        TOPAppSafeItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppSafeItemIdentifier" forIndexPath:indexPath];
        cell.titleLab.text = swithName;
        return cell;
    }
    if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_pdfpassword", @"")]) {
        NSString *swithName = self.pdfSetArrays[indexPath.row];
        if ([swithName isEqualToString:NSLocalizedString(@"topscan_turnoffpassword",@"")]) {
            TOPSwithBackTapTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingSaveCellIdentifier" forIndexPath:indexPath];
            cell.cellType = @"pdf";
            cell.swithName = swithName;
            WS(weakSelf);
            cell.top_swichOpenOrCloseAppSafeBlock = ^(BOOL isOpen,NSString *currentItem) {
                if (isOpen) {
                    [weakSelf top_clickToTurnOffPDFPassword];
                }else{
                    [weakSelf top_clickToTurnOnPDFPassword];
                }
            };
            return cell;
        }
        TOPAppSafeItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppSafeItemIdentifier" forIndexPath:indexPath];
        cell.titleLab.text = swithName;
        return cell;
    }
    NSString *swithTwoName = NSLocalizedString(@"topscan_changepassword",@"");
    TOPAppSafeItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppSafeItemIdentifier" forIndexPath:indexPath];
    cell.titleLab.text = swithTwoName;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *sectionTitle = self.sectionArrays[indexPath.section];
    if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_changepassword",@"")])
    {
        TOPAppSafeShowPasswordVC *setpwdVC = [[TOPAppSafeShowPasswordVC alloc] init];
        NSString *currentPwd = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeCurrentPWDKey];
        if (currentPwd) {
            setpwdVC.setSafePsdState = TOPAppSetSafePasswordStateChangePwd;
        }else{
            setpwdVC.setSafePsdState = TOPAppSetSafePasswordStateFirstSetSafe;
        }
        
        TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:setpwdVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
    if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_docaccesspassword", @"")]) {
        NSString *swithName = self.docSetArrays[indexPath.row];
        if ([swithName isEqualToString:NSLocalizedString(@"topscan_changepassword", @"")]) {
            [self top_clickToChangePassword];
        }
    }
    
    if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_pdfpassword", @"")]) {
        NSString *swithName = self.pdfSetArrays[indexPath.row];
        if ([swithName isEqualToString:NSLocalizedString(@"topscan_changepassword", @"")]) {
            [self top_clickToChangePDFPassword];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = self.sectionArrays[section];
    
    if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_appsecurity",@"")] || [sectionTitle isEqualToString:NSLocalizedString(@"topscan_docaccesspassword",@"")]||[sectionTitle isEqualToString:NSLocalizedString(@"topscan_pdfpassword",@"")])  {
        UIView *sectionHeadView = [[UIView alloc] init];
        
        UILabel * titleLab = [UILabel new];
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textColor = UIColorFromRGB(0x777777);
        
        titleLab.textAlignment = NSTextAlignmentNatural;
        titleLab.text = self.sectionArrays[section];
        titleLab.frame = CGRectMake(15, 20, TOPScreenWidth-40, 20);
        [sectionHeadView addSubview:titleLab];
        
        UILabel * subTitleLab = [UILabel new];
        subTitleLab.font = [UIFont systemFontOfSize:11];
        subTitleLab.textColor = UIColorFromRGB(0x777777);
        subTitleLab.textAlignment = NSTextAlignmentNatural;
        subTitleLab.numberOfLines = 0;
        
        if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_docaccesspassword",@"")]) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(top_clearFolderpasswordTap:)];
            tapGesture.numberOfTapsRequired = 5;
            [sectionHeadView addGestureRecognizer:tapGesture];
            
        }
        subTitleLab.text = self.sectionSubTitleArrays[section];
        CGFloat subHeight = [self top_headerHeight:self.sectionSubTitleArrays[section]]-55;
        
        subTitleLab.frame = CGRectMake(15, CGRectGetMaxY(titleLab.frame)+1, TOPScreenWidth-40, subHeight);
        [sectionHeadView addSubview:subTitleLab];
        sectionHeadView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF9F9F9)];
        return sectionHeadView;
    }
    else{
        UIView *sectionHeadView = [[UIView alloc] init];
        
        UILabel * titleLab = [UILabel new];
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textColor = UIColorFromRGB(0x777777);
        titleLab.textAlignment = NSTextAlignmentNatural;
        titleLab.text = NSLocalizedString(@"topscan_apppwd", @"");
        titleLab.frame = CGRectMake(15, 11, TOPScreenWidth-40, 20);
        [sectionHeadView addSubview:titleLab];
        sectionHeadView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF9F9F9)];
        return sectionHeadView;
    }
}

- (CGFloat)top_headerHeight:(NSString *)subTitle
{
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
    attrDict[NSFontAttributeName] = [UIFont systemFontOfSize:11];
    CGSize size = [subTitle boundingRectWithSize:CGSizeMake(TOPScreenWidth-40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil].size;
    return size.height+55;
}
#pragma mark - 连续点击5次
- (void)top_clearFolderpasswordTap:(UITapGestureRecognizer *)gesture {
    if ( [TOPScanerShare top_docPassword].length) {
        [self top_clearAppLockStatesAlert];
    }
    
}

#pragma mark -- 是否清除安全密码
- (void)top_clearAppLockStatesAlert{
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"")
                                                                         message:NSLocalizedString(@"topscan_clearapppsd" ,@"")
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [self top_clearLocalPassWord];
        
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)top_clearLocalPassWord
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray  * docArray = [TOPDataModelHandler top_buildSearchDataAtPath:[TOPDocumentHelper top_appBoxDirectory]];
        for (DocumentModel * docModel in docArray) {
            if ([docModel.type isEqualToString:@"1"]) {
                NSString * docPasswordPath = docModel.docPasswordPath;
                if (docPasswordPath.length>0) {
                    [TOPWHCFileManager top_removeItemAtPath:docPasswordPath];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [TOPScanerShare top_writeDocPasswordSave:@""];
            self.docSetArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_turnoffpassword", @"")]];
            [self.tableView reloadData];
        });
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = self.sectionArrays[section];
    if ([sectionTitle isEqualToString:NSLocalizedString(@"topscan_appsecurity",@"")] || [sectionTitle isEqualToString:NSLocalizedString(@"topscan_docaccesspassword",@"")]||[sectionTitle isEqualToString:NSLocalizedString(@"topscan_pdfpassword",@"")])  {
        NSString *sectionSubTitle = self.sectionSubTitleArrays[section];
        
        CGFloat subHeight = [self top_headerHeight:sectionSubTitle];
        
        return subHeight;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
- (void)dealloc
{
    NSLog(@"dealloc_safe");
}

- (void)changePwdStates:(BOOL)isOpen inType:(NSString *)currentItem
{
    BOOL isAppSafeStates = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeStates] boolValue];
    if (isAppSafeStates) {
        NSInteger currentUnlockNum =   [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeUnLockType] integerValue];
        switch (currentUnlockNum) {
            case TOPAppSetSafeUnlockTypePwd:
            {
                TOPAppSafeShowPasswordVC *setpwdVC = [[TOPAppSafeShowPasswordVC alloc] init];
                TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:setpwdVC];
                
                if ([currentItem isEqualToString:NSLocalizedString(@"topscan_apppwd",@"")]) {
                    setpwdVC.setSafePsdState = TOPAppSetSafePasswordStateClosePwd;
                }else if ([currentItem isEqualToString:@"Face ID"])
                {
                    setpwdVC.setSafePsdState = TOPAppSetSafePasswordStateChangeFaceIdType;
                }else if ([currentItem isEqualToString:@"Touch ID"])
                {
                    setpwdVC.setSafePsdState = TOPAppSetSafePasswordStateChangeTouchIdType;
                }
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:nil];
                
            }
                break;
            case TOPAppSetSafeUnlockTypeFaceID:
            {
                TOPTouchUnlockViewController *setpwdVC = [[TOPTouchUnlockViewController alloc] init];
                TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:setpwdVC];
                setpwdVC.unlockType = TOPAppSetSafeUnlockTypeFaceID;
                if ([currentItem isEqualToString:NSLocalizedString(@"topscan_apppwd",@"")]) {
                    
                    NSString *currentPwd = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeCurrentPWDKey];
                    if (currentPwd) {
                        setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateChangePassWord;
                    }else{
                        setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateChangeCreatNewPassWord;
                    }
                }else if ([currentItem isEqualToString:@"Face ID"])
                {
                    setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateClose;
                }
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:nil];
            }
                break;
            case TOPAppSetSafeUnlockTypeTouchID:
            {
                TOPTouchUnlockViewController *setpwdVC = [[TOPTouchUnlockViewController alloc] init];
                TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:setpwdVC];
                setpwdVC.unlockType = TOPAppSetSafeUnlockTypeTouchID;
                if ([currentItem isEqualToString:NSLocalizedString(@"topscan_apppwd",@"")]) {
                    NSString *currentPwd = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeCurrentPWDKey];
                    if (currentPwd) {
                        setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateChangePassWord;
                    }else{
                        setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateChangeCreatNewPassWord;
                    }
                }else if ([currentItem isEqualToString:@"Touch ID"])
                {
                    setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateClose;
                }
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    }else{
        
        if ([currentItem isEqualToString:NSLocalizedString(@"topscan_apppwd",@"")]) {
            NSString *currentPwd = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeCurrentPWDKey];
            TOPAppSafeShowPasswordVC *setpwdVC = [[TOPAppSafeShowPasswordVC alloc] init];
            TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:setpwdVC];
            if (currentPwd) {
                setpwdVC.setSafePsdState = TOPAppSetSafePasswordStateRestartPwd;
            }else{
                setpwdVC.setSafePsdState = TOPAppSetSafePasswordStateFirstSetSafe;
            }
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:nav animated:YES completion:nil];
        }else if ([currentItem isEqualToString:@"Touch ID"])
        {
            switch (self.currentDeviceType) {
                case TOPLAContextSupportTypeTouchIDNotEnrolled:
                {
                    [self top_touchToSetMarksAlert:TOPLAContextSupportTypeTouchIDNotEnrolled];
                }
                    break;
                case TOPLAContextSupportTypeTouchID:
                {
                    TOPTouchUnlockViewController *setpwdVC = [[TOPTouchUnlockViewController alloc] init];
                    setpwdVC.unlockType = TOPAppSetSafeUnlockTypeTouchID;
                    setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateOpen;
                    setpwdVC.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:setpwdVC animated:YES completion:nil];
                }
                    break;
                    
                default:
                    break;
            }
        }else if ([currentItem isEqualToString:@"Face ID"])
        {
            switch (self.currentDeviceType) {
                case TOPLAContextSupportTypeFaceIDNotEnrolled:
                {
                    [self top_touchToSetMarksAlert:TOPLAContextSupportTypeFaceIDNotEnrolled];
                }
                    break;
                case TOPLAContextSupportTypeFaceID:
                {
                    TOPTouchUnlockViewController *setpwdVC = [[TOPTouchUnlockViewController alloc] init];
                    setpwdVC.unlockType = TOPAppSetSafeUnlockTypeFaceID;
                    setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateOpen;
                    setpwdVC.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:setpwdVC animated:YES completion:nil];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
}

#pragma mark -- 跳转到设置页面
- (void)top_touchToSetMarksAlert:(TOPLAContextSupportType )type {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                         message:(type == TOPLAContextSupportTypeTouchIDNotEnrolled)? NSLocalizedString(@"topscan_touchidnotenrolled",@""):NSLocalizedString(@"topscan_faceidnotenrolled",@"")
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok",@"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        switch (type) {
            case TOPLAContextSupportTypeTouchIDNotEnrolled:{
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                
                if ([[UIApplication sharedApplication] canOpenURL:url])
                {
                    [[UIApplication sharedApplication] openURL:url options:@{}  completionHandler:nil];
                }
            }
                break;
            case TOPLAContextSupportTypeFaceIDNotEnrolled:
            {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                
                if ([[UIApplication sharedApplication] canOpenURL:url])
                {
                    [[UIApplication sharedApplication] openURL:url options:@{}  completionHandler:nil];
                }
            }
                break;
            default:
                break;
        }
        
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- Send feedback
- (void)top_settingView_SendFeedback{
    [FIRAnalytics logEventWithName:@"settingView_SendFeedback" parameters:nil];
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        return;
    }
    if (![mailClass canSendMail]) {
        TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_bind", @"")
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

- (void)top_markupCoverMask{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}

@end
