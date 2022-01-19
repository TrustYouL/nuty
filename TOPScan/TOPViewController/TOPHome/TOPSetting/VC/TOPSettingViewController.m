#define CoverH  60

#import "TOPSettingViewController.h"
#import "TOPRestoreViewController.h"
#import "TOPAppSafeSetViewController.h"
#import "TOPSettingWebViewController.h"
#import "TOPSettingDocManagementVC.h"
#import "TOPSettingGeneralVC.h"
#import "TOPSuggestionsVC.h"
#import "TOPSettingCell.h"
#import "TOPSettingFooterView.h"
#import <StoreKit/StoreKit.h>
#import "TOPSubscriptionPayListViewController.h"
#import "TOPCreditsTipView.h"
#import "TOPSelectedLoginOrSettingAlertView.h"
#import "TOPPurchaseCredutsViewController.h"
#import "TOPUnlockFunctionViewController.h"
#import "TOPSettingSubsciptInfoTableViewCell.h"
#import "TOPJDSKPaymentTools.h"
#import "TOPPurchasepayModel.h"
#import "TOPSetMemberTableViewCell.h"
#import "TOPTransferDataViewController.h"
#import "TOPBinHomeViewController.h"
#import "TOPInAppStoreObserver.h"
#import "TOPSettingMoreVC.h"

@interface TOPSettingViewController ()<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate,SKStoreProductViewControllerDelegate,TOPJDSKPaymentToolsDelegate,SKProductsRequestDelegate,TOPStoreObserverProtocol>
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic ,strong)NSMutableArray * listDataArray;//列表的数据源
@property (nonatomic ,strong)NSMutableArray * subScriptArrays;//内购
@property (nonatomic ,strong)NSMutableArray * sOneArray;//通用设置
@property (nonatomic ,strong)NSMutableArray * dataMigrationArray;//数据转移
@property (nonatomic ,strong)NSMutableArray * sTwoArray;//分享、反馈
@property (nonatomic ,strong)NSMutableArray * sthreeArray;//建议、问卷
@property (nonatomic ,strong)NSMutableArray * sfourArray;//推荐app
@property (nonatomic ,strong)TOPSettingFooterView * footerView;
@property (nonatomic ,assign)BOOL isRestoreSuecss;//是否是恢复订阅成功的回调请求的商品信息
@property(nonatomic ,strong) SKProductsRequest *productsRequest;
@end
@implementation TOPSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    [self top_loadData];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(self.view);
    }];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    self.navigationController.navigationBarHidden = NO;

    [self top_setTopView];
    [self.tableView reloadData];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    self.footerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)settingView_BackHomeAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.listDataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self top_getSectionRow:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==0) {
        if ([TOPSubscriptTools getSubscriptStates]) {
            TOPSettingSubsciptInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPSettingSubsciptInfoTableViewCell class])];
            WS(weakself);
            cell.top_clickMoreDetailBlock = ^{
                [weakself top_setting_subscriptFunDetail];
            };
            return cell;
        }else{
            TOPSetMemberTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPSetMemberTableViewCell class])];
            cell.dic = [self top_getSectionRowDic:indexPath];
            return cell;
        }
    }
    TOPSettingCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPSettingCell class])];
    cell.indexPath = indexPath;
    cell.dic = [self top_getSectionRowDic:indexPath];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 15)];
    headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];;
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerF = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 20)];
    footerF.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];;
    return footerF;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==0) {
        if ([TOPSubscriptTools getSubscriptStates]) {
            return 151;
        }else{
            return 65;
        }
    }
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dic = [self top_getSectionRowDic:indexPath];
    [self didSelectSettingRow:dic];
}

- (void)didSelectSettingRow:(NSDictionary *)dic{
    TOPSettingVCAction actionType = [dic[@"settingAction"] integerValue];
    switch (actionType) {
        case TOPSettingVCActionSubscriptionMember://会员
            if (![TOPSubscriptTools getSubscriptStates]) {
                [self top_upgradeMember];
            }
            break;
        case TOPSettingVCActionGeneral:
            [self top_supportGeneral];
            break;
        case TOPSettingVCActionRestoreSubscript:
            [self top_topStoreObserverDidReceiveMessage];
            break;
        case TOPSettingVCActionSupportBackupRestore:
            [self top_supportRestoreOrBack];
            break;
        case TOPSettingVCActionSupportAppSafeSet:
            [self top_supportAppSafeSet];
            break;
        case TOPSettingVCActionDocManagement:
            [self top_supportDocManagement];
            break;
        case TOPSettingVCActionSupportRateApp:
            [self top_supportRateMyApp];
            break;
        case TOPSettingVCActionSupportShareApp:
            [self top_supportShareMyApp];
            break;
        case TOPSettingVCActionSupportSendFeedBack:
            [self top_settingView_SendFeedback];
            break;
        case TOPSettingVCActionSupportFAQ:
            [self top_supportFAQ];
            break;
        case TOPSettingVCActionSupportPrivacy:
            [self top_supportPrivacyPolicy];
            break;
        case TOPSettingVCActionSupportUserAgreement:
            [self top_supportUserAgreement];
            break;
        case TOPSettingVCActionSupportUserSuggestion:
            [self top_useFreedback];
            break;
        case TOPSettingVCActionSendDataToOthers:
            [self top_transferData];
            break;
        case TOPSettingVCCheckRecycleBin:
            [self top_settingView_RecycleBin];
            break;
        case TOPSettingActionGeneralMore:
            [self top_settingView_More];
            break;
        default:
            
            break;
    }
}
#pragma mark -- app内跳转到appstore
- (void)top_supportOurApp:(NSInteger)tag{
    NSString * appID = [NSString new];
    if (tag<[self appIDArray].count) {
        appID = [self appIDArray][tag];
    }
    SKStoreProductViewController * storeProductViewContorller = [SKStoreProductViewController new];
    storeProductViewContorller.delegate = self;
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [storeProductViewContorller loadProductWithParameters:
         @{SKStoreProductParameterITunesItemIdentifier : appID} completionBlock:^(BOOL result, NSError *error) {
             if(error){
                 NSLog(@"error %@ with userInfo %@",error,[error userInfo]);
             }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentViewController:storeProductViewContorller animated:YES completion:nil];
        });
    });
}
#pragma mark -- 取消按钮监听
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --  恢复购买事务回调
- (void)top_topStoreObserverRestoreDidSucceed {
    [SVProgressHUD dismiss];
    [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_restoresuccessfully", @"")];
    [self top_loadData];
    [self.tableView reloadData];
}

- (void)top_topStoreObserverDidReceiveMessage:(NSString *)message {
    [SVProgressHUD dismiss];
    [[TOPCornerToast shareInstance] makeToast:message];
}

#pragma mark --  恢复订阅
- (void)top_topStoreObserverDidReceiveMessage {
    [TOPJDSKPaymentTools shareInstance].delegate = self;
    [[TOPJDSKPaymentTools shareInstance] top_restoreSubscriptTransaction];
}
- (void)top_filedWithErrorCode:(NSInteger)errorCode andError:(NSString *)error //失败
{
    switch (errorCode) {
        case IAP_FILEDCOED_RestoreFiled:
        {
            [SVProgressHUD dismiss];
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_restorefailed", @"")];
        }
            break;
        case IAP_FILEDCOED_NORestoreData:
        {
            [SVProgressHUD dismiss];
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_nopurrestore", @"")];
        }
            break;
        default:
            break;
    }
}
- (void)top_succeedWithsucceedCode:(NSInteger)succeedCode
{
    switch (succeedCode) {
        case IAPSucceedCode_ServersRestoreSucceed:
        {
            TOPSubscriptModel *subModel = [TOPSubscriptTools getSubScriptData];
            if ((subModel.priceTitle.length<=0 || [subModel.priceTitle containsString:@"null"]) &&subModel.apple_sub_status) {
                if ([subModel.purchaseKey isEqualToString:InAppProductIdSubscriptionMonth]) {
                    subModel.priceTitle =@"1 Month Premium";
                    
                }else  if ([subModel.purchaseKey isEqualToString:InAppProductIdSubscriptionYear]) {
                    subModel.priceTitle =@"1 Year Premium";
                }
            }
            [SVProgressHUD dismiss];
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_restoresuccessfully", @"")];
            [self.tableView reloadData];
        }
            break;
        default:
            break;
    }
}
#pragma mark-  升级会员
- (void)top_upgradeMember{
    if ([TOPAppTools needShowDiscountThemeView]) {
        [[TOPDiscountThemeView shareInstance] top_showDiscountTheme:@"20211123_year_sub"];
        return;
    } 
    TOPSubscriptionPayListViewController * generalVC = [TOPSubscriptionPayListViewController new];
    generalVC.closeType = TOPSubscriptOverCloseTypePopToSetting;
    generalVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:generalVC animated:YES];

}
#pragma mark --跳转到订阅功能详情
- (void)top_setting_subscriptFunDetail
{
    TOPUnlockFunctionViewController *functionVC = [[TOPUnlockFunctionViewController alloc] init];
    functionVC.isHiddenBottomSubScript = YES;
    functionVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:functionVC animated:YES];
}
- (void)top_settingView_More{
    TOPSettingMoreVC * morVC = [TOPSettingMoreVC new];
    morVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:morVC animated:YES];
}
#pragma mark -- 用户反馈
- (void)top_useFreedback{
    TOPSuggestionsVC * suVC = [TOPSuggestionsVC new];
    suVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:suVC animated:YES];
}
#pragma mark --General
- (void)top_supportGeneral{
    TOPSettingGeneralVC * generalVC = [TOPSettingGeneralVC new];
    generalVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:generalVC animated:YES];
}

#pragma mark --Doc management
- (void)top_supportDocManagement{
    TOPSettingDocManagementVC * managementVC = [TOPSettingDocManagementVC new];
    managementVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:managementVC animated:YES];
}

#pragma mark -- Backup&Restore
- (void)top_supportRestoreOrBack{
    TOPRestoreViewController * webVC = [TOPRestoreViewController new];
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark -- AppSafeSet
- (void)top_supportAppSafeSet{
    [FIRAnalytics logEventWithName:@"settingView_AppLock" parameters:nil];
    TOPAppSafeSetViewController * webVC = [TOPAppSafeSetViewController new];
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark -- Rate app
- (void)top_supportRateMyApp{
    NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", @"1531265666"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
    NSInteger rateCount = [TOPScanerShare top_saveClickRateApp];
    rateCount++;
    [TOPScanerShare top_writeSaveClickRateApp:rateCount];
    
    [self top_loadData];
    [self.tableView reloadData];
}

#pragma mark -- Share app
- (void)top_supportShareMyApp{
    NSString * shareText = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"topscan_shareappcontent", @""),@"https://itunes.apple.com/app/apple-store/id1531265666"];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareText] applicationActivities:nil];
    if (IS_IPAD) {
        activityVC.popoverPresentationController.sourceView = self.view;
        activityVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:activityVC animated:YES completion:nil];
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
    [mailCompose setSubject:@"Simple Scan Feedback"];
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
#pragma mark -- FAQ
- (void)top_supportFAQ{
    NSString * titleString = NSLocalizedString(@"topscan_faq", @"");
    [FIRAnalytics logEventWithName:@"settingView_WebViewSupportFAQ" parameters:nil];

    TOPSettingWebViewController * webVC = [TOPSettingWebViewController new];
    webVC.titleString = titleString;
    webVC.urlString = TOP_TRFAQURL;
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark -- Privacy Policy
- (void)top_supportPrivacyPolicy{
    NSString * titleString = NSLocalizedString(@"topscan_privacypolicy", @"");
    [FIRAnalytics logEventWithName:@"settingView_PrivacyPolicy" parameters:nil];

    TOPSettingWebViewController * webVC = [TOPSettingWebViewController new];
    webVC.titleString = titleString;
    webVC.urlString = TOP_TRPrivacyPolicyURL;
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)top_supportUserAgreement{
    NSString * titleString = NSLocalizedString(@"topscan_settinguseragreement", @"");
    [FIRAnalytics logEventWithName:@"settingView_UserAgreement" parameters:nil];

    TOPSettingWebViewController * webVC = [TOPSettingWebViewController new];
    webVC.titleString = titleString;
    webVC.urlString = TOP_TRUserAgreementURL;
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark -- 传输数据
- (void)top_transferData {
    [FIRAnalytics logEventWithName:@"settingView_transferData" parameters:nil];

    TOPTransferDataViewController *vc = [[TOPTransferDataViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark --- 回收站
- (void)top_settingView_RecycleBin {
    [FIRAnalytics logEventWithName:@"settingView_RecycleBin" parameters:nil];
    TOPBinHomeViewController *binHome = [[TOPBinHomeViewController alloc] init];
    binHome.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:binHome animated:YES];
}

#pragma mark -- section下row的个数
- (NSInteger)top_getSectionRow:(NSInteger)section{
    NSMutableArray *sectionArr = self.listDataArray[section];
    return sectionArr.count;
}
#pragma mark -- section下的数据源
- (NSDictionary *)top_getSectionRowDic:(NSIndexPath *)indexPath{
    NSMutableArray *sectionArr = self.listDataArray[indexPath.section];
    return sectionArr[indexPath.row];
}
#pragma mark -- 导航栏视图
- (void)top_setTopView{
    self.title = NSLocalizedString(@"topscan_questionsetting", @"");
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(settingView_BackHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(settingView_BackHomeAction)];
    }
}

- (TOPSettingFooterView *)footerView{
    if (!_footerView) {
        WS(weakSelf);
        _footerView = [[TOPSettingFooterView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 250)];
        _footerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];;
        _footerView.top_clickBtnBlock = ^(NSInteger tag) {
            [weakSelf top_supportOurApp:tag];
        };
    }
    return _footerView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = self.footerView;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        [_tableView registerClass:[TOPSettingCell class] forCellReuseIdentifier:NSStringFromClass([TOPSettingCell class])];
        [_tableView registerClass:[TOPSetMemberTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPSetMemberTableViewCell class])];
        [_tableView registerClass:[TOPSettingSubsciptInfoTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPSettingSubsciptInfoTableViewCell class])];
    }
    return _tableView;
}
- (NSMutableArray *)listDataArray{
    if (!_listDataArray) {
        _listDataArray = @[].mutableCopy;
    }
    return _listDataArray;
}
- (NSMutableArray *)dataMigrationArray{
    if (!_dataMigrationArray) {
        _dataMigrationArray = @[].mutableCopy;
    }
    return _dataMigrationArray;
}
- (NSMutableArray *)subScriptArrays{
    if (!_subScriptArrays) {
        _subScriptArrays = [NSMutableArray new];
    }
    return _subScriptArrays;
}
- (NSMutableArray *)sOneArray{
    if (!_sOneArray) {
        _sOneArray = [NSMutableArray new];
    }
    return _sOneArray;
}
- (NSMutableArray *)sTwoArray{
    if (!_sTwoArray) {
        _sTwoArray = [NSMutableArray new];
    }
    return _sTwoArray;
}
- (NSMutableArray *)sthreeArray{
    if (!_sthreeArray) {
        _sthreeArray = [NSMutableArray new];
    }
    return _sthreeArray;
}
- (NSMutableArray *)sfourArray{
    if (!_sfourArray) {
        _sfourArray = [NSMutableArray new];
    }
    return _sfourArray;
}
- (void)top_loadData{
    [self.listDataArray removeAllObjects];
    NSInteger sTwoArrayCount;
    if ([TOPScanerShare top_saveClickRateApp]>1) {
        if (![TOPSubscriptTools getSubscriptStates]) {
            sTwoArrayCount = 3;
        }else{
            sTwoArrayCount = 2;
        }
    }else{
        if (![TOPSubscriptTools getSubscriptStates]) {
            sTwoArrayCount = 4;
        }else{
            sTwoArrayCount = 3;
        }
    }
    NSString * rowIcon = [NSString new];
    if (isRTL()) {
        rowIcon = @"top_reverpushVCRow";
    }else{
        rowIcon = @"top_pushVCRow";
    }
    NSDictionary *dic1 = @{@"settingIcon":@"top_settingGeneral",
                           @"rowIcon":rowIcon,
                           @"arrayCount":@(4),
                           @"settingAction":@(TOPSettingVCActionGeneral),
                           @"title":NSLocalizedString(@"topscan_settinggeneral", @"")};
    NSDictionary *dic2 = @{@"settingIcon":@"top_settingBackup",
                           @"rowIcon":rowIcon,
                           @"arrayCount":@(4),
                           @"settingAction":@(TOPSettingVCActionSupportBackupRestore),
                           @"title":NSLocalizedString(@"topscan_backup", @"")};
    NSDictionary *dic3 = @{@"settingIcon":@"top_settingSecurity",
                           @"rowIcon":rowIcon,
                           @"arrayCount":@(4),
                           @"settingAction":@(TOPSettingVCActionSupportAppSafeSet),
                           @"title":NSLocalizedString(@"topscan_appsecurity", @"")};
    NSDictionary *dic4 = @{@"settingIcon":@"top_settingDocManagement",
                           @"rowIcon":rowIcon,
                           @"arrayCount":@(4),
                           @"settingAction":@(TOPSettingVCActionDocManagement),
                           @"title":NSLocalizedString(@"topscan_settingdocmanagement", @"")};
    NSDictionary *dic5 = @{@"settingIcon":@"top_settingRate",
                           @"rowIcon":rowIcon,
                           @"arrayCount":@(sTwoArrayCount),
                           @"settingAction":@(TOPSettingVCActionSupportRateApp),
                           @"title":NSLocalizedString(@"topscan_rateapp", @"")};
    NSDictionary *dic6 = @{@"settingIcon":@"top_settingShareApp",
                           @"rowIcon":rowIcon,
                           @"arrayCount":@(sTwoArrayCount),
                           @"settingAction":@(TOPSettingVCActionSupportShareApp),
                           @"title":NSLocalizedString(@"topscan_shareapp", @"")};
    NSDictionary *dic7 = @{@"settingIcon":@"top_settingSendFeedback",
                           @"rowIcon":rowIcon,
                           @"arrayCount":@(sTwoArrayCount),
                           @"settingAction":@(TOPSettingVCActionSupportSendFeedBack),
                           @"title":NSLocalizedString(@"topscan_sendfeedback", @"")};
    NSDictionary *dic8 = @{@"settingIcon":@"top_setting_restore",
                           @"rowIcon":rowIcon,
                           @"arrayCount":@(sTwoArrayCount),
                           @"settingAction":@(TOPSettingVCActionRestoreSubscript),
                           @"title":NSLocalizedString(@"topscan_restorepurchase", @"")};
    
    NSDictionary *dic9 = @{@"rowIcon":@"top_setting_member",
                            @"arrayCount":@(1),
                            @"settingAction":@(TOPSettingVCActionSubscriptionMember),
                            @"title":@"Upgrade VIP to imagine more advanced rights"};
    NSArray * temp0 = @[dic9];

    NSDictionary *dic10 = @{@"settingIcon":@"top_dataTransmission",
                            @"rowIcon":rowIcon,
                            @"arrayCount":@(2),
                            @"settingAction":@(TOPSettingVCActionSendDataToOthers),
                            @"title":NSLocalizedString(@"topscan_transferdata", @"")};
    NSDictionary *dic11 = @{@"settingIcon":@"top_setting_recycelBin",
                            @"rowIcon":rowIcon,
                            @"arrayCount":@(2),
                            @"settingAction":@(TOPSettingVCCheckRecycleBin),
                            @"title":NSLocalizedString(@"topscan_recyclebin", @"")};
    NSDictionary *dic12 = @{@"settingIcon":@"top_setting_more",
                            @"rowIcon":rowIcon,
                            @"arrayCount":@(1),
                            @"settingAction":@(TOPSettingActionGeneralMore),
                            @"title":NSLocalizedString(@"topscan_more", @"")};

    NSArray * temp1 = @[dic1,dic2,dic3,dic4];
    NSArray * temp2 = [NSArray new];
    NSArray * temp3 = @[dic12];
    NSArray * temp4 = @[dic10,dic11];
    if ([TOPScanerShare top_saveClickRateApp]>1) {
        if (![TOPSubscriptTools getSubscriptStates]) {
            temp2 = @[dic8,dic6,dic7];
        }else{
            temp2 = @[dic6,dic7];
        }
    }else{
        if (![TOPSubscriptTools getSubscriptStates]) {
            temp2 = @[dic8,dic5,dic6,dic7];
        }else{
            temp2 = @[dic5,dic6,dic7];
        }
    }
    self.subScriptArrays = [temp0 mutableCopy];
    self.sOneArray = [temp1 mutableCopy];
    self.sTwoArray = [temp2 mutableCopy];
    self.dataMigrationArray = [temp4 mutableCopy];
    self.sthreeArray = [temp3 mutableCopy];
    [self.listDataArray addObject:self.subScriptArrays];
    [self.listDataArray addObject:self.sOneArray];
    [self.listDataArray addObject:self.dataMigrationArray];
    [self.listDataArray addObject:self.sTwoArray];
    [self.listDataArray addObject:self.sthreeArray];
    [self.tableView reloadData];
    TOPSubscriptModel *subModel = [TOPSubscriptTools getSubScriptData];
    if ((subModel.priceTitle.length<=0 || [subModel.priceTitle containsString:@"null"]) &&subModel.apple_sub_status) {
        if ([subModel.purchaseKey isEqualToString:InAppProductIdSubscriptionMonth]) {
            subModel.priceTitle =@"1 Month Premium";
        }else  if ([subModel.purchaseKey isEqualToString:InAppProductIdSubscriptionYear]) {
            subModel.priceTitle =@"1 Year Premium";
        }
    }
}
- (NSArray *)appIDArray{
    NSArray * idArray = @[@"1523972672",@"1554197658"];
    return idArray;
}

@end
