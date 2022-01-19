
#import "TOPPurchaseCredutsViewController.h"
#import "TOPPurchaseCreditsTableViewCell.h"
#import "TOPJDSKPaymentTools.h"
#import "TOPPurchasepayModel.h"
#import "TOPFreeBaseSqliteTools.h"



@interface TOPPurchaseCredutsViewController ()<UITableViewDelegate,UITableViewDataSource,SKProductsRequestDelegate,TOPJDSKPaymentToolsDelegate>
@property (nonatomic ,strong)UITableView * tableView;
/**
 订阅的产品数组
 */
@property (nonatomic,strong) NSMutableArray *productsArrays;

@property (nonatomic,strong) TOPImageTitleButton *creditsbgView;


@property (nonatomic,strong) UILabel *creditsLabel;


/*
 请求商品信息
 */
@property(nonatomic, strong) SKProductsRequest *productsRequest;

@end

@implementation TOPPurchaseCredutsViewController



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(top_ocr_recognize_pagesChange:) name:@"top_ocr_recognize_pagesChange" object:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
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
    if (isRTL()) {//黑色
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
    
    UIBarButtonItem * creditsItem = [[UIBarButtonItem alloc]initWithCustomView:self.creditsbgView];
    self.navigationItem.rightBarButtonItem = creditsItem;
    
    NSString *plistsPath =  [[TOPDocumentHelper top_appBoxDirectory] stringByAppendingPathComponent:TOP_TRPlistsString];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistsPath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:plistsPath];
    }
    NSMutableArray*localArrays = [NSMutableArray arrayWithArray:[NSArray arrayWithContentsOfFile:[plistsPath stringByAppendingFormat:@"/SavePurchaseProductList.plist"]]];
    if (!localArrays.count) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_loading", @"")];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }else{
        self.productsArrays = [TOPPurchasepayModel mj_objectArrayWithKeyValuesArray:localArrays];
    }
    [self top_validateProductIdentifiers:@[@"20210624_ocrpages_1",@"20210624_ocrpages_2"]];
}

#pragma mark -- 自定义方法
- (void)top_validateProductIdentifiers:(NSArray *)productIdentifiers
{
    self.productsRequest = [[SKProductsRequest alloc]
                            initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    self.productsRequest .delegate = self;
    [self.productsRequest  start];
}
#pragma mark -- SKProductsRequestDelegate 代理方法
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"--------------收到产品反馈消息---------------------");
    NSArray *product = response.products;
    if([product count] == 0){
        NSLog(@"---------没有商品信息");
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
    NSString *plistsPath =  [[TOPDocumentHelper top_appBoxDirectory] stringByAppendingPathComponent:TOP_TRPlistsString];
    NSMutableArray *productHistoryArrays = [NSMutableArray array];
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
        NSString*formattedPrice = [numberFormatter stringFromNumber:pro.price];//例如 ￥12.00
        TOPPurchasepayModel *purModel = [[TOPPurchasepayModel alloc] init];
        purModel.purchaseKey = [pro productIdentifier];
        purModel.payMoney = [[pro price] floatValue];
        purModel.productTitle = formattedPrice;
        
        if ([[pro productIdentifier] isEqualToString:@"20210624_ocrpages_1"]) {
            purModel.productSubTitle = @"200 Pages for";
            purModel.buyMoney = @"200";
            
        }else if([[pro productIdentifier] isEqualToString:@"20210624_ocrpages_2"]){
            purModel.productSubTitle = @"1000 Pages for";
            purModel.buyMoney = @"1000";
        }
        [productHistoryArrays addObject:purModel];
    }
    productHistoryArrays = [self soreCustomArray:productHistoryArrays];
    NSMutableArray *newLocalArrays = [NSMutableArray array];
    
    for ( int i = 0;i< productHistoryArrays.count ;i++) {
        TOPPurchasepayModel *proModel  = productHistoryArrays[i];
        [newLocalArrays addObject:proModel.mj_keyValues];
    }
    [newLocalArrays writeToFile:[plistsPath stringByAppendingFormat:@"/SavePurchaseProductList.plist"] atomically:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        self.productsArrays = productHistoryArrays;
        [self.tableView reloadData];
    });
}

#pragma mark -- 数组排序
- (NSMutableArray *)soreCustomArray:(NSMutableArray *)temp  {
    //获取合成后的新文件下的所有文件 有显示图片和原始图片(original_)
    //排序,根据图片的后几位数字去排序
    NSArray *sortArray = [temp sortedArrayUsingComparator:^NSComparisonResult(TOPPurchasepayModel *tempContentPath1, TOPPurchasepayModel *tempContentPath2) {
        NSString *sortNO1 = [NSString stringWithFormat:@"%f",tempContentPath1.payMoney];
        NSString *sortNO2 =[NSString stringWithFormat:@"%f",tempContentPath2.payMoney];
        return [sortNO1 compare:sortNO2 options:NSNumericSearch];
    }];
    return [sortArray mutableCopy];
}

- (void)top_backHomeAction
{
    [self.productsRequest cancel];
    if (self.isCloseDissmiss) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.productsArrays.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
#pragma mark - TableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TOPPurchaseCreditsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPPurchaseCreditsTableViewCell class]) forIndexPath:indexPath];
    cell.dictDataModel = self.productsArrays[indexPath.section];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    if (section == 0) {
        UIImageView *iconHeaderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_buyocr_icon"]];
        [headerView addSubview:iconHeaderImageView];
        [iconHeaderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(headerView);
            make.centerY.equalTo(headerView);
            make.height.mas_offset(99);
            make.width.mas_offset(111);
        }];
    }
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]init];
    footerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 200;
        
    }else{
        return 0.001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 15;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TOPPurchasepayModel *purModel = self.productsArrays[indexPath.section];
    [TOPJDSKPaymentTools shareInstance].delegate = self;
    [[TOPJDSKPaymentTools shareInstance] top_startBuyNumberWithServer:purModel];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[TOPPurchaseCreditsTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPPurchaseCreditsTableViewCell class])];
    }
    return _tableView;
}
- (NSMutableArray *)productsArrays
{
    if (!_productsArrays) {
        _productsArrays = [NSMutableArray array];
    }
    return _productsArrays;
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
        [btn setTitleColor:[UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x262B30)] forState:UIControlStateNormal];
        _creditsbgView = btn;
    }
    return  _creditsbgView;
}
/**
 根据指定文本,字体和最大高度计算宽度
 @param text 字符串
 @param font 字体大小
 @param height 最大高度
 @return 大小SIZE
 */
- (CGSize)top_sizeWidthWidth:(NSString *)text font:(UIFont *)font maxHeight:(CGFloat)height{
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
    attrDict[NSFontAttributeName] = font;
    CGSize size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil].size;
    return size;
}
#pragma mark- 充值成功回调
- (void)top_succeedWithsucceedCode:(NSInteger)succeedCode{
    switch (succeedCode) {
        case IAPSucceedCode_ServersSucceed:
        {
            [SVProgressHUD dismiss];
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_subscriptsuccessfully", @"")];
            NSString *creditBalance = [NSString stringWithFormat:@"%ld",[TOPSubscriptTools getCurrentUserBalance]];
            
            CGSize creditSize = [self top_sizeWidthWidth:creditBalance font:PingFang_R_FONT_(16) maxHeight:44];
            [self.creditsbgView setTitle:creditBalance forState:UIControlStateNormal];
            self.creditsbgView.frame =CGRectMake(0, 0, creditSize.width+25, 50);
            [self top_uploadBalanceToiCloudOrBalance];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark- 同步余额识别点数到iCloud 或 google实时数据库
- (void)top_uploadBalanceToiCloudOrBalance
{
    NSInteger currentBalance = [TOPSubscriptTools getCurrentUserBalance];
    if ([TOPSubscriptTools googleLoginStates]) {
        [[TOPFreeBaseSqliteTools sharedSingleton] setOcr_recognize_pagesToServiceWith:currentBalance];
    }else{
        [TOPSubscriptTools updateiCloudKitModel:currentBalance];
    }
}

#pragma mark- 订阅失败回调
- (void)top_filedWithErrorCode:(NSInteger)errorCode andError:(NSString *)error
{
    [SVProgressHUD dismiss];
}

@end
