#import "TOPSubscribeVC.h"
#import "TOPSubscribeModel.h"
#import "TOPSubscribeView.h"
#import "TOPPurchasepayModel.h"
#import "TOPJDSKPaymentTools.h"
#import "TOPSettingWebViewController.h"
@interface TOPSubscribeVC ()<SKProductsRequestDelegate,TOPJDSKPaymentToolsDelegate>
@property(strong, nonatomic)TOPPurchasepayModel * currentProductModel;
@property(nonatomic, strong) SKProductsRequest *productsRequest;
@property(nonatomic, strong)TOPSubscribeView * subscribeView;
@end

@implementation TOPSubscribeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self top_setupUI];
    [self top_getPurchData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;//关闭手势
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;//激活手势
    };
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
       
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (IS_IPAD) {
        self.subscribeView.currentSize = size;
    }
}
- (void)top_getPurchData{
    [self top_validateProductIdentifiers:@[InAppProductIdSubscriptionYear]];
}
#pragma mark -- 请求商品信息
- (void)top_validateProductIdentifiers:(NSArray *)productIdentifiers
{
    self.productsRequest = [[SKProductsRequest alloc]
        initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    self.productsRequest .delegate = self;
    [self.productsRequest  start];
}

#pragma mark -- SKProductsRequestDelegate 代理方法
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response{
    NSArray *product = response.products;
    if([product count] == 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        return;
    }
    
    for (SKProduct *pro in product) {
        NSLog(@"SKProduct:%@", pro.mj_keyValues);
        NSLog(@"description:%@", [pro description]);
        NSLog(@"localizedTitle:%@", [pro localizedTitle]);
        NSLog(@"localizedDescription:%@", [pro localizedDescription]);
        NSLog(@"price:%@", [pro price]);
        NSLog(@"productIdentifier:%@", [pro productIdentifier]);
        NSNumberFormatter*numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:pro.priceLocale];
        NSString*formattedPrice = [numberFormatter stringFromNumber:pro.price];
        TOPPurchasepayModel *purModel = [[TOPPurchasepayModel alloc] init];
        purModel.purchaseKey = [pro productIdentifier];
        purModel.productTitle = [NSString stringWithFormat:@"%@/year",formattedPrice];
        purModel.payMoney = [[pro price] floatValue];
        if (pro.introductoryPrice) {
            purModel.isFreeTrial = YES;
            purModel.freeTrialTypeUnit = pro.introductoryPrice.subscriptionPeriod.unit;
            purModel.numberOfUnits = pro.introductoryPrice.subscriptionPeriod.numberOfUnits;
            
        }
        NSNumber *unitPrice =  [NSNumber numberWithFloat:[ pro.price floatValue]/12];
        NSString*formattedUnitPrice = [numberFormatter stringFromNumber:unitPrice];
        purModel.productSubTitle = [NSString stringWithFormat:@"%@/Mon", formattedUnitPrice];
        purModel.buyType = @"1 Year";
        self.currentProductModel = purModel;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [self updateProductItemWithModel:self.currentProductModel];
    });
}
- (void)updateProductItemWithModel:(TOPPurchasepayModel *)purModel{
    self.subscribeView.purModel = purModel;
}
- (NSMutableArray *)loadSubscribeData{
    NSArray * iconArray = @[@"top_subscrib1",@"top_subscrib2",@"top_subscrib3",@"top_subscrib4",@"top_subscrib5",@"top_subscrib6"];
    NSArray * titleArray = @[NSLocalizedString(@"topscan_collage", @""),NSLocalizedString(@"topscan_colletionpdfsignaturetitle", @""),NSLocalizedString(@"topscan_graffititextrecognition", @""),NSLocalizedString(@"topscan_collageidcard", @""),NSLocalizedString(@"topscan_txt", @""),NSLocalizedString(@"topscan_docgraffiti", @"")];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (int i = 0; i<iconArray.count; i++) {
        TOPSubscribeModel * model = [TOPSubscribeModel new];
        model.imgString = iconArray[i];
        model.titleString = titleArray[i];
        if (i == 1 || i == 2 || i == 3 ) {
            model.isLeft = YES;
        }else{
            model.isLeft = NO;
        }
        [tempArray addObject:model];
    }
    return tempArray;
}

- (void)top_setupUI{
    WS(weakSelf);
    TOPSubscribeView * subscribeView = [[TOPSubscribeView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
    self.subscribeView = subscribeView;
    subscribeView.top_subscribeEvent = ^(TOPSubscribeEvent eventTag) {
        [weakSelf top_subscribeViewEvent:eventTag];
    };
    subscribeView.top_subscribePrivacyURL = ^(NSString * _Nonnull urlString) {
    };
    UIButton * payCloseBtn = [UIButton new];
    [payCloseBtn addTarget:self action:@selector(top_dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:subscribeView];
    [self.view addSubview:payCloseBtn];
    
    if (IS_IPAD) {
        [subscribeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.bottom.equalTo(self.view);
            make.width.mas_equalTo(450);
        }];
        [payCloseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(20);
            make.trailing.equalTo(self.view).offset(-60);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        [payCloseBtn setImage:[UIImage imageNamed:@"top_payClose"] forState:UIControlStateNormal];
    }else{
        [subscribeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [payCloseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(TOPStatusBarHeight+10);
            make.trailing.equalTo(self.view).offset(-20);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        [payCloseBtn setImage:[UIImage imageNamed:@"top_ipadClose"] forState:UIControlStateNormal];
    }
    subscribeView.dataArray = [self loadSubscribeData];
}

- (void)top_subscribeViewEvent:(TOPSubscribeEvent)eventTag{
    switch (eventTag) {
        case TOPSubscribeEventPay:
            [self top_startSubscription];
            break;
        case TOPSubscribeEventLimitVersion:
            [self top_dismissView];
            break;
        case TOPSubscribeEventRestore:
            [self top_topStoreObserverDidReceiveMessage];
            break;
        default:
            break;
    }
}
- (void)top_sendToPrivacy:(NSString *)urlString{
    NSString * urlString1 =@"https://www.tongsoftinfo.com/simple-scanner/FAQ.html";
    NSString * urlString2 = @"https://www.tongsoftinfo.com/simple-scanner/Privacy-Policy.html";
    NSString * titleString1 = NSLocalizedString(@"topscan_faq", @"");
    NSString * titleString2 = NSLocalizedString(@"topscan_privacypolicy", @"");
    NSString * titleString = [NSString new];
    if ([urlString isEqual:urlString1]) {
        titleString = titleString1;
    }
    if ([urlString isEqual:urlString2]) {
        titleString = titleString2;
    }
    TOPSettingWebViewController * webVC = [TOPSettingWebViewController new];
    webVC.titleString = titleString;
    webVC.urlString = urlString;
    webVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark- 开始订阅
- (void)top_startSubscription
{
    NSLog(@"%s",__func__);
    [TOPJDSKPaymentTools shareInstance].delegate = self;
    [[TOPJDSKPaymentTools shareInstance] top_startBuyNumberWithServer:self.currentProductModel];
}
#pragma mark- 订阅成功回调
- (void)top_succeedWithsucceedCode:(NSInteger)succeedCode{
    switch (succeedCode) {
        case IAPSucceedCode_ServersSucceed:
        {
            [SVProgressHUD dismiss];
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_subscriptsuccessfully", @"")];
            [self top_dismissView];
        }
            break;
        case IAPSucceedCode_ServersRestoreSucceed:
        {
            [SVProgressHUD dismiss];
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_restoresuccessfully", @"")];
            [self top_dismissView];
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
    switch (errorCode) {
         case IAP_FILEDCOED_RestoreFiled:
         {
             [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_restorefailed", @"")];
         }
             break;
         case IAP_FILEDCOED_NORestoreData:
         {
             [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_nopurrestore", @"")];
         }
             break;
        default:
             break;
     }
}
- (void)top_topStoreObserverDidReceiveMessage{
    [TOPJDSKPaymentTools shareInstance].delegate = self;
    [[TOPJDSKPaymentTools shareInstance] top_restoreSubscriptTransaction];
}

- (void)top_dismissView{
    [self.productsRequest  cancel];
    [TOPScanerShare top_writeFirstOpenStatesSave:YES];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

@end
