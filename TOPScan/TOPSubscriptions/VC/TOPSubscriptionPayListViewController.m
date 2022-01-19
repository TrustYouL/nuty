
#import "TOPSubscriptionPayListViewController.h"
#import "TOPUnlockFunctionCollectionViewCell.h"
#import "TOPUnlockFunctionViewController.h"
#import "TOPSettingWebViewController.h"
#import "TOPJDSKPaymentTools.h"
#import "TOPPurchasepayModel.h"
#import "TOPSettingViewController.h"
#import "ACPDownloadView.h"
#import "ACPIndeterminateGoogleLayer.h"

#import "TOPInAppStoreManager.h"
#import "TOPInAppStoreObserver.h"

#import "UILabel+Block.h"

@interface TOPSubscriptionPayListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TOPJDSKPaymentToolsDelegate, TOPStoreManagerProtocol, TOPStoreObserverProtocol>

/**
 购买订阅后解锁的功能 (标题)
 */
@property (nonatomic,strong) NSMutableArray *needUnlockTitleArrays;
/**
 购买订阅后解锁的功能 (图片)
 */
@property (nonatomic,strong) NSMutableArray *needUnlockImageArrays;
/**
订阅的产品数组
 */
@property (nonatomic,strong) NSMutableArray *productsArrays;

@property (strong, nonatomic) UICollectionView *collectionView;

/**
当前默认选中的订阅 默认为1年 currentProductIndex = 1;
 */
@property (nonatomic,assign) NSInteger currentProductIndex;

@property (strong, nonatomic) UIView *bottomSunView;


@property (strong, nonatomic) UIView *productOneView;
/**
 产品类型 1个月 1年
 */
@property (strong, nonatomic) UILabel *productTypeOneLabel;
/**
 产品价格
 */
@property (strong, nonatomic) UILabel *productPriceOneLabel;

/**
 产品均价 单个月的价格
 */
@property (strong, nonatomic) UILabel *productAveragePriceOneLabel;


@property (strong, nonatomic) UIView *productTwoView;
/**
 产品类型 1个月 1年
 */
@property (strong, nonatomic) UILabel *productTypeTwoLabel;
/**
 产品价格
 */
@property (strong, nonatomic) UILabel *productPriceTwoLabel;

/**
 产品均价 单个月的价格
 */
@property (strong, nonatomic) UILabel *productAveragePriceTwoLabel;


/**
 产品优惠显示信息
 */
@property (strong, nonatomic) UILabel *productTipsLabel;


/**
购买产品头部标题显示
 */
@property (strong, nonatomic) UILabel *confirmTopTitleLabel;

/**
 购买产品底部小标题显示
 */
@property (strong, nonatomic) UILabel *confirmBottomTitleLabel;

@end

@implementation TOPSubscriptionPayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.title = NSLocalizedString(@"topscan_premium", @"");
    self.currentProductIndex = 1;

    if (isRTL()) {//黑色
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    [self top_createBottomProductView];
    NSInteger count = [TOPScanerShare top_theCountSubscribtionVC];
    count ++;
    [TOPScanerShare top_writeSubscribtionVCCount:count];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self top_setUpProductsData];
}

#pragma mark -- 商品数据
- (void)top_setUpProductsData {
    if (self.productsArrays.count<=0) {
        [self top_setBuyButtonState:NO];
        [self top_validateProductIdentifiers:@[InAppProductIdSubscriptionMonth, InAppProductIdSubscriptionYear]];
    }
}

#pragma mark -- 横竖屏切换时重新设置titleView
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView reloadData];
}

#pragma mark -- 返回
- (void)top_backHomeAction
{
    [[TOPInAppStoreManager shareInstance].productRequest cancel];

    if (self.closeType == TOPSubscriptOverCloseTypeLoginSuccess || TOPSubscriptOverCloseTypeOCRSub == self.closeType || TOPSubscriptOverCloseTypeDissmiss == self.closeType) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -- 拉取商品信息
- (void)top_validateProductIdentifiers:(NSArray *)productIdentifiers
{
    [TOPInAppStoreManager shareInstance].delegate = self;
    [[TOPInAppStoreManager shareInstance] topstartProductRequestWithIdentifiers:productIdentifiers];
}

#pragma mark -- TOPStoreManagerProtocol
- (void)topStoreManagerDidReceiveResponse:(id)response {//数据回调
    NSMutableArray *section = (NSMutableArray *)response;
    if (section.count) {
        NSDictionary *dic = section[0];
        NSArray *products = dic[@"elements"];
        [self top_showAvailableProducts:products];
    }
}

- (void)topStoreManagerDidReceiveMessage:(NSString *)message {//信息回调
    [[TOPCornerToast shareInstance] makeToast:message];
}

#pragma mark -- 显示商品信息
- (void)top_showAvailableProducts:(NSArray *)products {
    NSMutableArray *productHistoryArrays = @[].mutableCopy;
    for (SKProduct *pro in products) {
        NSLog(@"SKProduct:%@", pro.mj_keyValues);
        TOPPurchasepayModel *purModel = [[TOPPurchasepayModel alloc] initWithProduct:pro];
        [productHistoryArrays addObject:purModel];
    }
    productHistoryArrays = [self top_soreCustomArray:productHistoryArrays];
    
    NSMutableArray *newLocalArrays = [NSMutableArray array];
    
    for ( int i = 0;i< productHistoryArrays.count ;i++) {
        TOPPurchasepayModel *proModel  = productHistoryArrays[i];
        [newLocalArrays addObject:proModel.mj_keyValues];
    }
    NSString *plistsPath =  [[TOPDocumentHelper top_appBoxDirectory] stringByAppendingPathComponent:TOP_TRPlistsString];
    [newLocalArrays writeToFile:[plistsPath stringByAppendingFormat:@"/SaveSubscriptionProductList.plist"] atomically:YES];
    
    ACPDownloadView *downloadView = [self.view viewWithTag:1938];
    downloadView.hidden = YES;

    [self top_setBuyButtonState:YES];
    
    self.confirmTopTitleLabel.text = NSLocalizedString(@"topscan_questioncontinue", @"");
    self.productsArrays = productHistoryArrays;
    for (int i = 0; i < productHistoryArrays.count; i++) {
        TOPPurchasepayModel *purModel = productHistoryArrays[i];
        [self top_updateProductItemWithModel:purModel];
    }
}
    
#pragma mark- 开始订阅
- (void)top_startSubscriptionClick:(UIButton *)sender
{
    [TOPNetWorkManager topReachabilityNewWorkStatusBlock:^(BOOL isOnline) {
        if (isOnline) {//有网络
            if ([TOPValidateTools top_isJailBreak]) {//如果越狱了，不能购买--请使用未越狱的手机购买
                [[TOPCornerToast shareInstance] makeToast:@"Please use a mobile phone that has not been jailbroken"];
                return;
            }
            //需要打开内购权限
            if (![[TOPInAppStoreObserver shareInstance] topIsAuthorizedForPayments]) {
                NSString *msg = @"Please open the in-app purchase";
                __weak typeof(self) weakSelf = self;
                [self takeAlert:nil withMessage:msg actionHandler:^{
                    [weakSelf top_backHomeAction];
                }];
                return;
            }
            
            TOPPurchasepayModel *purModel = self.productsArrays[self.currentProductIndex];
            [TOPJDSKPaymentTools shareInstance].delegate = self;
            [[TOPJDSKPaymentTools shareInstance] top_startBuyNumberWithServer:purModel];
        }else{//无网络
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_networkunavailable", @"")];
        }
    }];
}
-(void)startMonitoring:(id)obj{

}
#pragma mark -- TOPTOPStoreObserverProtocol.h
- (void)top_topStoreObserverRestoreDidSucceed {
    [SVProgressHUD dismiss];
    [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_restoresuccessfully", @"")];
}

- (void)top_topStoreObserverDidReceiveMessage:(NSString *)message {
    [SVProgressHUD dismiss];
    [[TOPCornerToast shareInstance] makeToast:message];
}

#pragma mark -- 购买成功
- (void)topStoreObserverPurchaseSucceed {
    [[TOPCornerToast shareInstance] makeToast:InAppPurchaseSucceed];
}

#pragma mark -- 票据验证成功
- (void)topStoreObserverValidateSucceed {
    [SVProgressHUD dismiss];
    [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_subscriptsuccessfully", @"")];
    [self top_succeedGoBack];
}

- (void)topStoreObserverValidateAgain {
    [SVProgressHUD dismiss];
    [self top_validateAgainAlert];
}

- (void)top_validateAgainHandle {
    [SVProgressHUD show];
    [[TOPInAppStoreObserver shareInstance] topValidateAgain];//二次校验
}

- (void)top_validateAgainAlert {
    NSString *msg = InAppValidateAgain;
    __weak typeof(self) weakSelf = self;
    [self top_takeAlertWithMessage:msg actionBlock:^{
        [weakSelf top_validateAgainHandle];
    } cancleBlock:^{
        [[TOPInAppStoreObserver shareInstance] topUnlockValidattion];
    }];
}

#pragma mark -- 票据为空 ，提示用户去主动获取收据
- (void)topStoreObserverAppReceiptIsEmpty {
    [SVProgressHUD dismiss];
    [self top_noReceiptAlert];
}

- (void)top_fetchAppReceipt {
    [SVProgressHUD show];
    [[TOPInAppStoreObserver shareInstance] topRefreshAppReceipt];//重新获取票据
}

#pragma mark --
- (void)top_noReceiptAlert {
    NSString *msg = InAppGetReceiptAgain;
    __weak typeof(self) weakSelf = self;
    [self top_takeAlertWithMessage:msg actionBlock:^{
        [weakSelf top_fetchAppReceipt];
    } cancleBlock:^{
        [[TOPInAppStoreObserver shareInstance] topUnlockValidattion];
    }];
}

- (void)top_takeAlertWithMessage:(NSString *)msg actionBlock:(void (^)(void))actionBlock cancleBlock:(void (^)(void))cancleBlock {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        if (actionBlock) {
            actionBlock();
        }
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark- 解锁功能详情
- (void)top_jumpPush_detailItemInfo:(UIButton *)sender
{
    NSLog(@"%s",__func__);
    TOPUnlockFunctionViewController *functionDetail = [[TOPUnlockFunctionViewController alloc] init];
    functionDetail.closeType = self.closeType;
    [self.navigationController pushViewController:functionDetail animated:YES];
}

- (void)top_userAgreementAndPrivacyPolicyClick:(UIButton *)sender
{
    NSLog(@"%s",__func__);
    
    switch (sender.tag) {
        case 1444:
        {
            TOPSettingWebViewController *webViewVC = [[TOPSettingWebViewController alloc] init];
            webViewVC.titleString = NSLocalizedString(@"topscan_settinguseragreement", @"");
            webViewVC.urlString = TOP_TRUserAgreementURL;

            [self.navigationController pushViewController:webViewVC animated:YES];
        }
            
            break;
        case 1445:
        {
            TOPSettingWebViewController *webViewVC = [[TOPSettingWebViewController alloc] init];
            webViewVC.titleString = NSLocalizedString(@"topscan_privacypolicy", @"");
            webViewVC.urlString = TOP_TRPrivacyPolicyURL;
            [self.navigationController pushViewController:webViewVC animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark- 选择订阅商品
- (void)top_selectProductClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 1342:
            self.productOneView.clipsToBounds = NO;
            self.productOneView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineMostDarkColor defaultColor:RGBA(208, 245, 238, 1.0)];
            self.productOneView.layer.borderColor = TOPAPPGreenColor.CGColor;

            self.currentProductIndex = 0;
            self.productTwoView.clipsToBounds = YES;
            self.productTwoView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF6F6F6)];
            self.productTwoView.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF6F6F6)].CGColor;

            break;
        case 1343:
            self.productTwoView.clipsToBounds = NO;
            self.productTwoView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineMostDarkColor defaultColor:RGBA(208, 245, 238, 1.0)];
            self.productTwoView.layer.borderColor = TOPAPPGreenColor.CGColor;

            self.currentProductIndex = 1;
            self.productOneView.clipsToBounds = YES;
            self.productOneView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF6F6F6)];
            self.productOneView.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF6F6F6)].CGColor;
            break;
        default:
            break;
    }
    if (self.productsArrays.count > self.currentProductIndex) {
        [self top_updateProductItemWithModel:self.productsArrays[self.currentProductIndex]];
    }
}

- (void)takeAlert:(NSString *)title withMessage:(NSString *)message actionHandler:(void(^)(void))actionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok" ,@"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (actionHandler) {
            actionHandler();
        }
    }];
    
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 数组排序
- (NSMutableArray *)top_soreCustomArray:(NSMutableArray *)temp  {
    NSArray *sortArray = [temp sortedArrayUsingComparator:^NSComparisonResult(TOPPurchasepayModel *tempContentPath1, TOPPurchasepayModel *tempContentPath2) {
        NSString *sortNO1 = [NSString stringWithFormat:@"%f",tempContentPath1.payMoney];
        NSString *sortNO2 =[NSString stringWithFormat:@"%f",tempContentPath2.payMoney];
        
        return [sortNO1 compare:sortNO2 options:NSNumericSearch];
    }];
    return [sortArray mutableCopy];
}

#pragma mark -- 设置按钮状态
- (void)top_setBuyButtonState:(BOOL)enable {
    UIButton *startBuyButton = [self.view viewWithTag:1939];
    startBuyButton.userInteractionEnabled = enable;
    UIButton *selectOneProductButton = [self.view viewWithTag:1342];
    selectOneProductButton.userInteractionEnabled = enable;
    UIButton *selectTwoProductButton = [self.view viewWithTag:1343];
    selectTwoProductButton.userInteractionEnabled = enable;
}

- (void)top_updateProductItemWithModel:(TOPPurchasepayModel *)purModel
{
    if ([purModel.purchaseKey isEqualToString:InAppProductIdSubscriptionMonth]) {
        self.productTypeOneLabel.text = purModel.buyType;
        self.productPriceOneLabel.text = purModel.productTitle;
        self.productAveragePriceOneLabel.text = purModel.productSubTitle;

    }else if ([purModel.purchaseKey isEqualToString:InAppProductIdSubscriptionYear])
    {
        self.productTypeTwoLabel.text = purModel.buyType;
        self.productPriceTwoLabel.text = purModel.productTitle;
        self.productAveragePriceTwoLabel.text = purModel.productSubTitle;

    }
    if (purModel.isFreeTrial) {
        NSString *freeDateStr = @"3-day";
        switch ( purModel.freeTrialTypeUnit) {
            case 0:
                freeDateStr = [NSString stringWithFormat:@"* %ld-%@ %@, %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_day", @""),NSLocalizedString(@"topscan_freetrial", @""),NSLocalizedString(@"topscan_autorenewable", @"")];
                self.confirmBottomTitleLabel.text = [NSString stringWithFormat:@"%ld-%@ %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_day", @""),NSLocalizedString(@"topscan_freetrial", @"")];

                break;
            case 1:
                freeDateStr = [NSString stringWithFormat:@"* %ld-%@ %@, %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_week", @""),NSLocalizedString(@"topscan_freetrial", @""),NSLocalizedString(@"topscan_autorenewable", @"")];
                self.confirmBottomTitleLabel.text = [NSString stringWithFormat:@"%ld-%@ %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_week", @""),NSLocalizedString(@"topscan_freetrial", @"")];

                break;
            case 2:
                freeDateStr = [NSString stringWithFormat:@"* %ld-%@ %@, %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_month", @""),NSLocalizedString(@"topscan_freetrial", @""),NSLocalizedString(@"topscan_autorenewable", @"")];
                self.confirmBottomTitleLabel.text = [NSString stringWithFormat:@"%ld-%@ %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_month", @""),NSLocalizedString(@"topscan_freetrial", @"")];

                break;
            case 3:
                freeDateStr = [NSString stringWithFormat:@"* %ld-%@ %@, %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_year", @""),NSLocalizedString(@"topscan_freetrial", @""),NSLocalizedString(@"topscan_autorenewable", @"")];
                self.confirmBottomTitleLabel.text = [NSString stringWithFormat:@"%ld-%@ %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_year", @""),NSLocalizedString(@"topscan_freetrial", @"")];
                break;
            default:
                break;
        }
        self.productTipsLabel.text = freeDateStr;
    }else{
        self.productTipsLabel.text = [NSString stringWithFormat:@"* %@",NSLocalizedString(@"topscan_autorenewable", @"")];
        self.confirmBottomTitleLabel.text = NSLocalizedString(@"topscan_nofreetrial", @"");
    }
}


#pragma mark- 创建底部购买视图
- (void)top_createBottomProductView
{
    [self.view addSubview:self.bottomSunView];
    [self.bottomSunView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(300);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
    }];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(_bottomSunView.mas_top);
    }];
    
    UIView *tempProductOneView = [[UIView alloc] init];
    tempProductOneView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF6F6F6)];
    [self.bottomSunView addSubview:tempProductOneView];
    self.productOneView = tempProductOneView;
    tempProductOneView.layer.cornerRadius= 10;
    tempProductOneView.layer.shadowOffset = CGSizeMake(0, 1);
    tempProductOneView.layer.shadowColor = RGBA(38, 38, 38, 0.20).CGColor ;
    tempProductOneView.layer.shadowOpacity = 1;
    tempProductOneView.layer.shadowRadius = 4;
    tempProductOneView.clipsToBounds =YES;
    tempProductOneView.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF6F6F6)].CGColor;
    tempProductOneView.layer.borderWidth = 1.5;
    [tempProductOneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomSunView).offset(15);
        make.leading.equalTo(self.bottomSunView).offset(15);
        make.height.mas_offset(95);
    }];
    self.productTypeOneLabel = [[UILabel alloc] init];
    self.productTypeOneLabel.font = PingFang_R_FONT_(13);
    self.productTypeOneLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:[UIColor blackColor]];
    self.productTypeOneLabel.text = @"1 Month";

    self.productTypeOneLabel.textAlignment = NSTextAlignmentCenter;
    [tempProductOneView addSubview:self.productTypeOneLabel];
    [_productTypeOneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tempProductOneView);
        make.top.equalTo(tempProductOneView).offset(15);
    }];
    
    self.productPriceOneLabel = [[UILabel alloc] init];
    self.productPriceOneLabel.font = PingFang_M_FONT_(17);
    self.productPriceOneLabel.textColor = TOPAPPGreenColor;
    self.productPriceOneLabel.text = @"$ 3.99";
    self.productPriceOneLabel.textAlignment = NSTextAlignmentCenter;
    [tempProductOneView addSubview:self.productPriceOneLabel];
    [_productPriceOneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tempProductOneView);
        make.top.equalTo(_productTypeOneLabel.mas_bottom).offset(5);
    }];
    
    self.productAveragePriceOneLabel = [[UILabel alloc] init];
    self.productAveragePriceOneLabel.font = PingFang_M_FONT_(12);
    self.productAveragePriceOneLabel.textColor = UIColorFromRGB(0xDB2F1F);
    self.productAveragePriceOneLabel.text = @"$ 3.99/Mon";
    self.productAveragePriceOneLabel.textAlignment = NSTextAlignmentCenter;
    [tempProductOneView addSubview:self.productAveragePriceOneLabel];
    [_productAveragePriceOneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tempProductOneView);
        make.top.equalTo(_productPriceOneLabel.mas_bottom).offset(15);
    }];
    UIButton *selectOneProductButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectOneProductButton.tag = 1342;
    [selectOneProductButton addTarget:self action:@selector(top_selectProductClick:) forControlEvents:UIControlEventTouchUpInside];
    [tempProductOneView addSubview:selectOneProductButton];
    [selectOneProductButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(tempProductOneView);
        make.top.equalTo(tempProductOneView);
        make.leading.equalTo(tempProductOneView);
        make.bottom.equalTo(tempProductOneView);
    }];
    
    UIView *tempProductTwoView = [[UIView alloc] init];
    tempProductTwoView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineMostDarkColor defaultColor:RGBA(208, 245, 238, 1.0)];
    [self.bottomSunView addSubview:tempProductTwoView];
    tempProductTwoView.layer.cornerRadius= 10;
    tempProductTwoView.layer.shadowOffset = CGSizeMake(0, 1);
    tempProductTwoView.layer.shadowColor =  RGBA(38, 38, 38, 0.20).CGColor ;
    tempProductTwoView.layer.shadowOpacity = 1;
    tempProductTwoView.layer.shadowRadius = 4;
    tempProductTwoView.clipsToBounds =NO;
    tempProductTwoView.layer.borderColor = TOPAPPGreenColor.CGColor;
    tempProductTwoView.layer.borderWidth = 1.5;

    self.productTwoView = tempProductTwoView;
    [tempProductTwoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tempProductOneView);
        make.leading.equalTo(tempProductOneView.mas_trailing).offset(15);
        make.trailing.equalTo(self.bottomSunView).offset(-15);
        make.height.mas_offset(95);
        make.width.equalTo(tempProductOneView);
    }];
    
    self.productTypeTwoLabel = [[UILabel alloc] init];
    self.productTypeTwoLabel.font = PingFang_R_FONT_(13);
    self.productTypeTwoLabel.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:[UIColor blackColor]];
    self.productTypeTwoLabel.text = @"1 Year";

    self.productTypeTwoLabel.textAlignment = NSTextAlignmentCenter;
    [tempProductTwoView addSubview:self.productTypeTwoLabel];
    [_productTypeTwoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tempProductTwoView);
        make.top.equalTo(tempProductTwoView).offset(15);
    }];
    
    self.productPriceTwoLabel = [[UILabel alloc] init];
    self.productPriceTwoLabel.font = PingFang_M_FONT_(17);
    self.productPriceTwoLabel.textColor = TOPAPPGreenColor;
    self.productPriceTwoLabel.text = @"$ 29.99";
    self.productPriceTwoLabel.textAlignment = NSTextAlignmentCenter;
    [tempProductTwoView addSubview:self.productPriceTwoLabel];
    [_productPriceTwoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tempProductTwoView);
        make.top.equalTo(_productTypeTwoLabel.mas_bottom).offset(5);
    }];
    
    self.productAveragePriceTwoLabel = [[UILabel alloc] init];
    self.productAveragePriceTwoLabel.font = PingFang_M_FONT_(12);
    self.productAveragePriceTwoLabel.textColor = UIColorFromRGB(0xDB2F1F);
    self.productAveragePriceTwoLabel.text = @"$ 2.49/Mon";
    self.productAveragePriceTwoLabel.textAlignment = NSTextAlignmentCenter;
    [tempProductTwoView addSubview:self.productAveragePriceTwoLabel];
    [_productAveragePriceTwoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tempProductTwoView);
        make.top.equalTo(_productPriceTwoLabel.mas_bottom).offset(15);
    }];
    
    UIImageView *bestValueImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_subscriptction_bastValue"]];
    [tempProductTwoView addSubview:bestValueImageView];
    [bestValueImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(tempProductTwoView);
        make.top.equalTo(tempProductTwoView);
        make.height.mas_offset(43);
        make.width.mas_offset(43);

    }];
    
    UIButton *selectTwoProductButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectTwoProductButton.tag = 1343;
    [selectTwoProductButton addTarget:self action:@selector(top_selectProductClick:) forControlEvents:UIControlEventTouchUpInside];
    [tempProductTwoView addSubview:selectTwoProductButton];
    [selectTwoProductButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(tempProductTwoView);
        make.top.equalTo(tempProductTwoView);
        make.leading.equalTo(tempProductTwoView);
        make.bottom.equalTo(tempProductTwoView);
    }];
    
    
    self.productTipsLabel = [[UILabel alloc] init];
    self.productTipsLabel.font = PingFang_M_FONT_(13);
    self.productTipsLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x333333)];
    self.productTipsLabel.text = @"* 3-day Free Trial, Auto-renewable, cancel anytime.";
    self.productTipsLabel.textAlignment = NSTextAlignmentCenter;
    [_bottomSunView addSubview:self.productTipsLabel];
    [_productTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tempProductOneView.mas_bottom).offset(15);
        make.leading.equalTo(tempProductOneView);
        make.trailing.mas_lessThanOrEqualTo(_bottomSunView.mas_trailing).offset(-15);
    }];
    
    UIView *confirmbgView = [UIView new];
    confirmbgView.backgroundColor = TOPAPPGreenColor;
    confirmbgView.clipsToBounds = YES;
    confirmbgView.layer.cornerRadius = 49/2;
    [_bottomSunView addSubview:confirmbgView];
    [confirmbgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_productTipsLabel.mas_bottom).offset(10);
        make.leading.equalTo(_bottomSunView).offset(50);
        make.trailing.equalTo(_bottomSunView).offset(-50);
        make.height.mas_offset(49);
    }];
    
    self.confirmTopTitleLabel = [[UILabel alloc] init];
    self.confirmTopTitleLabel.font = PingFang_M_FONT_(16);
    self.confirmTopTitleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    self.confirmTopTitleLabel.text = NSLocalizedString(@"topscan_questioncontinue", @"");
    self.confirmTopTitleLabel.textAlignment = NSTextAlignmentCenter;
    [confirmbgView addSubview:self.confirmTopTitleLabel];
    [_confirmTopTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(confirmbgView).offset(10);
        make.centerX.equalTo(confirmbgView);
    }];
    
    self.confirmBottomTitleLabel = [[UILabel alloc] init];
    self.confirmBottomTitleLabel.font = PingFang_M_FONT_(11);
    self.confirmBottomTitleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    self.confirmBottomTitleLabel.text = NSLocalizedString(@"topscan_nofreetrial", @"");
    self.confirmBottomTitleLabel.textAlignment = NSTextAlignmentCenter;
    [confirmbgView addSubview:self.confirmBottomTitleLabel];
    [_confirmBottomTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_confirmTopTitleLabel.mas_bottom);
        make.centerX.equalTo(confirmbgView);
        
    }];

    
    UIButton *startBuyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startBuyButton addTarget:self action:@selector(top_startSubscriptionClick:) forControlEvents:UIControlEventTouchUpInside];
    [confirmbgView addSubview:startBuyButton];
    startBuyButton.tag = 1939;
    [startBuyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(confirmbgView);
        make.top.equalTo(confirmbgView);
        make.leading.equalTo(confirmbgView);
        make.bottom.equalTo(confirmbgView);
    }];
    
    UIScrollView *userinstructionsScrollView = [[UIScrollView alloc] init];
    userinstructionsScrollView.backgroundColor = [UIColor clearColor];
    userinstructionsScrollView.showsVerticalScrollIndicator = NO;
    [_bottomSunView addSubview:userinstructionsScrollView];

    [userinstructionsScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_bottomSunView).offset(-20);
        make.top.equalTo(confirmbgView.mas_bottom).offset(10);
        make.leading.equalTo(_bottomSunView).offset(20);
        make.height.mas_offset(50);
    }];
    
    UILabel *scrollTiplabel = [[UILabel alloc] init];
    scrollTiplabel.font = PingFang_R_FONT_(10);
    NSString *conentStr = [NSString stringWithFormat:@"%@\n%@\n%@",NSLocalizedString(@"topscan_paymenttext1", @""),NSLocalizedString(@"topscan_paymenttext2", @""),NSLocalizedString(@"topscan_paymenttext3", @"")];
    
    scrollTiplabel.text = conentStr;
    scrollTiplabel.textColor = UIColorFromRGB(0x777777);
    scrollTiplabel.numberOfLines = 0;
    [userinstructionsScrollView addSubview:scrollTiplabel];
    [scrollTiplabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userinstructionsScrollView);
        make.width.mas_offset(TOPScreenWidth-40);
        make.bottom.equalTo(userinstructionsScrollView);
    }];
    CGSize moneySize = [self top_sizeWidthWidth:conentStr font:PingFang_R_FONT_(10) maxHeight:TOPScreenWidth-40];
    if (moneySize.height>50) {
        userinstructionsScrollView.contentSize = CGSizeMake(0, moneySize.height) ;

    }else{
        userinstructionsScrollView.contentSize = CGSizeMake(0, 0) ;
    }
    
    UILabel * userAgreementLabel = [[UILabel alloc] init];
    userAgreementLabel.font = PingFang_R_FONT_(10);
    userAgreementLabel.text =  NSLocalizedString(@"topscan_settinguseragreement", @"");
    userAgreementLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
    [_bottomSunView addSubview:userAgreementLabel];
    [userAgreementLabel showUnderLine];
    [userAgreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userinstructionsScrollView.mas_bottom).offset(10);
        make.trailing.equalTo(_bottomSunView).offset(-20);
    }];
    UIButton *userAgreementButton = [UIButton buttonWithType:UIButtonTypeCustom];
    userAgreementButton.tag = 1444;
    [userAgreementButton addTarget:self action:@selector(top_userAgreementAndPrivacyPolicyClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomSunView addSubview:userAgreementButton];
    [userAgreementButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(userAgreementLabel);
        make.top.equalTo(userAgreementLabel);
        make.leading.equalTo(userAgreementLabel);
        make.height.mas_offset(40);

    }];
    
    UILabel * privacyPolicyLabel = [[UILabel alloc] init];
    privacyPolicyLabel.font = PingFang_R_FONT_(10);
    privacyPolicyLabel.text =  NSLocalizedString(@"topscan_privacypolicy", @"");
    privacyPolicyLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
    [_bottomSunView addSubview:privacyPolicyLabel];
    [privacyPolicyLabel showUnderLine];

    [privacyPolicyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userinstructionsScrollView.mas_bottom).offset(10);
        make.leading.equalTo(_bottomSunView).offset(20);
        make.trailing.mas_lessThanOrEqualTo(userAgreementLabel).offset(-15);
    }];
    UIButton *privacyPolicyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    privacyPolicyButton.tag = 1445;
    [privacyPolicyButton addTarget:self action:@selector(top_userAgreementAndPrivacyPolicyClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomSunView addSubview:privacyPolicyButton];
    [privacyPolicyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(privacyPolicyLabel);
        make.top.equalTo(privacyPolicyLabel);
        make.leading.equalTo(privacyPolicyLabel);
        make.height.mas_offset(40);
    }];
    
    TOPImageTitleButton *detailButton = [[TOPImageTitleButton alloc] initWithStyle:(ETitleLeftImageRightLeft)];

    float titleWidth = [TOPDocumentHelper top_getSizeWithStr:NSLocalizedString(@"topscan_details", @"") Height:50  Font:14].width;
    detailButton.frame = CGRectMake(0, 0, titleWidth+20, 50);

    [detailButton setTitle:NSLocalizedString(@"topscan_details", @"") forState:UIControlStateNormal];
    if (isRTL()) {
        detailButton.style = EImageLeftTitleRightLeft;
        [detailButton setImage:[UIImage imageNamed:@"top_subscription_detail_left"] forState:UIControlStateNormal];

    }else{
        detailButton.style = ETitleLeftImageRightLeft;
        [detailButton setImage:[UIImage imageNamed:@"top_subscription_detail"] forState:UIControlStateNormal];
    }
    [detailButton.titleLabel setFont:[self fontsWithSize:14]];
    [detailButton setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [detailButton addTarget:self action:@selector(top_jumpPush_detailItemInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc]initWithCustomView:detailButton];
    self.navigationItem.rightBarButtonItem = barItem;
    
    self.confirmTopTitleLabel.text = @"";
    self.confirmBottomTitleLabel.text = @"";
    
    ACPDownloadView *downloadView = [[ACPDownloadView alloc] init];
    [confirmbgView addSubview:downloadView];
    downloadView.backgroundColor = [UIColor clearColor];
    downloadView.tintColor = [UIColor whiteColor];
    downloadView.tag = 1938;
    [downloadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(confirmbgView);
        make.centerX.equalTo(confirmbgView);
        make.height.mas_offset(26);
        make.width.mas_offset(26);
    }];
    
    ACPIndeterminateGoogleLayer * layer = [ACPIndeterminateGoogleLayer new];
    [layer updateColor:[UIColor grayColor]];
    [downloadView setIndeterminateLayer:layer];
    [downloadView setIndicatorStatus:ACPDownloadStatusIndeterminate];
    startBuyButton.userInteractionEnabled = NO;
    selectOneProductButton.userInteractionEnabled = NO;
    selectTwoProductButton.userInteractionEnabled = NO;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    if (self.productOneView.clipsToBounds) {
        self.productOneView.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF6F6F6)].CGColor;
    }
    if (self.productTwoView.clipsToBounds) {
        self.productTwoView.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF6F6F6)].CGColor;
    }
}

#pragma mark - CollectionViewDelegate

//有多少个item
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.needUnlockTitleArrays.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPUnlockFunctionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPUnlockFunctionCollectionViewCell class]) forIndexPath:indexPath];
    cell.coverImageView.image = [UIImage imageNamed:self.needUnlockImageArrays[indexPath.item]];
    cell.driveNameLabel.text = self.needUnlockTitleArrays[indexPath.item];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return  UIEdgeInsetsMake(10, 10, 5, 10);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger cellW = (CGRectGetWidth(self.view.frame)-([self top_getDefaultParamete]+1)*10)/([self top_getDefaultParamete]);
    return CGSizeMake(cellW, 140);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

}
#pragma mark -- 根据列表的排列方式 确定横竖屏对应的列数
- (NSInteger)top_getDefaultParamete{
    NSInteger kColumnCount = 0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown) {
        kColumnCount = 3;
    }else{
        kColumnCount = 5;
    }
    return kColumnCount;
}
#pragma mark-  懒加载
- (NSMutableArray *)needUnlockImageArrays
{
    if (!_needUnlockImageArrays) {
        _needUnlockImageArrays = [NSMutableArray arrayWithArray:@[@"top_unlock_unlimitedFolder",@"top_unlock_NoAds",@"top_unlock_pdflock",@"top_unlock_ocr",@"top_unlock_fileupload",@"top_unlock_function",@"top_unlock_scans",@"top_unlock_watermark",@"top_unlock_signature",@"top_unlock_highqualityDocument",@"top_unlock_email",@"top_unlock_sharepdf",@"top_unlock_backup_restore",@"top_unlock_idcard",@"top_unlock_graffiti",@"top_unlock_applock",@"top_unlock_imagetotext",@"top_unlock_emportpdf"]];
    }
    return  _needUnlockImageArrays;
}

- (NSMutableArray *)needUnlockTitleArrays
{
    if (!_needUnlockTitleArrays) {
        _needUnlockTitleArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_unlimitedfolders", @""),NSLocalizedString(@"topscan_noads", @""),NSLocalizedString(@"topscan_pdffileencryption", @""),NSLocalizedString(@"topscan_ocrtypecloud", @""),NSLocalizedString(@"topscan_cloudservice", @""),NSLocalizedString(@"topscan_functionofcollage", @""),NSLocalizedString(@"topscan_unlimitedscans", @""),NSLocalizedString(@"topscan_clearwaternark", @""),NSLocalizedString(@"topscan_writesignature", @""),NSLocalizedString(@"topscan_highqualitydoc", @""),NSLocalizedString(@"topscan_emailmyself", @""),NSLocalizedString(@"topscan_exportpdfdoc", @""),NSLocalizedString(@"topscan_backup", @""),NSLocalizedString(@"topscan_collageidcard", @""),NSLocalizedString(@"topscan_graffiti", @""),NSLocalizedString(@"topscan_applock", @""),NSLocalizedString(@"topscan_imagetotext", @""),NSLocalizedString(@"topscan_propdfeditor", @"")]];
    }
    return   _needUnlockTitleArrays;
}

- (NSMutableArray *)productsArrays
{
    if (!_productsArrays) {
        _productsArrays = [NSMutableArray array];
    }
    return   _productsArrays;
}

#pragma mark -- collectionView
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;

        //滚动方向
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TOPUnlockFunctionCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPUnlockFunctionCollectionViewCell class])];
    }
    return _collectionView;
}

- (UIView *)bottomSunView{
    if (!_bottomSunView) {
        _bottomSunView = [UIView new];
        _bottomSunView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    }
    return _bottomSunView;
}
/**
 根据指定文本,字体和最大高度计算宽度
 @param text 字符串
 @param font 字体大小
 @param width 最大高度
 @return 大小SIZE
*/
- (CGSize)top_sizeWidthWidth:(NSString *)text font:(UIFont *)font maxHeight:(CGFloat)width{
    
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
    attrDict[NSFontAttributeName] = font;
    CGSize size = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil].size;
    return size;
}

- (void)top_succeedGoBack {
    switch (self.closeType) {
        case TOPSubscriptOverCloseTypePop:
            [self.navigationController popViewControllerAnimated:YES];

            break;
        case TOPSubscriptOverCloseTypeDissmiss:
        case TOPSubscriptOverCloseTypeLoginSuccess:
        case TOPSubscriptOverCloseTypeOCRSub:

            
            [self dismissViewControllerAnimated:YES completion:nil];

            break;
        case TOPSubscriptOverCloseTypePopToSetting:

            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[TOPSettingViewController class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }

            break;
        default:
            break;
    }
}

#pragma mark- 订阅成功回调
- (void)top_succeedWithsucceedCode:(NSInteger)succeedCode{
    switch (succeedCode) {
        case IAPSucceedCode_ServersSucceed:
        {
            [SVProgressHUD dismiss];

            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_subscriptsuccessfully", @"")];
            [self top_succeedGoBack];

        }
            break;
            
        default:
            break;
    }
}


#pragma mark- 订阅失败回调
- (void)top_filedWithErrorCode:(NSInteger)errorCode andError:(NSString *)error
{
    [SVProgressHUD dismiss];

}
@end
