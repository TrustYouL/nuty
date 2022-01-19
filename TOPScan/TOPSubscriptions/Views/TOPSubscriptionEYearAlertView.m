

#import "TOPSubscriptionEYearAlertView.h"
#import "TOPUnlockFunctionCollectionViewCell.h"
#import "TOPJDSKPaymentTools.h"
#import "TOPPurchasepayModel.h"
#import "ACPDownloadView.h"
#import "ACPIndeterminateGoogleLayer.h"
@interface TOPSubscriptionEYearAlertView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SKProductsRequestDelegate,TOPJDSKPaymentToolsDelegate>

@property (nonatomic,strong) NSMutableArray *needUnlockTitleArrays;
@property (nonatomic,strong) NSMutableArray *needUnlockImageArrays;
@property (strong, nonatomic) UIView *bottomSunView;
@property (strong, nonatomic) UILabel *productTipsLabel;
@property (strong, nonatomic) UILabel *confirmTopTitleLabel;
@property (strong, nonatomic) UILabel *confirmBottomTitleLabel;
@property (strong, nonatomic)TOPPurchasepayModel * currentProductModel;
@property (nonatomic, strong) SKProductsRequest *productsRequest;
@property (nonatomic, strong) UIView *mAlert;
@property (nonatomic, assign) NSInteger mPageNum;
@property (nonatomic, copy) void(^selectBlock)(TOPSubscriptionEYearAlertView *showAlertView);
@property (nonatomic, copy) void(^cancelBlock)(void);
@end

@implementation TOPSubscriptionEYearAlertView
- (instancetype)initWithAlertViewSelectBlock:(void(^)(TOPSubscriptionEYearAlertView *showAlertView))selectBlock cancelBlock:(void(^)(void))cancelBlock
{
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5f];
        self.needUnlockTitleArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_unlimitedfolders", @""),NSLocalizedString(@"topscan_noads", @""),NSLocalizedString(@"topscan_pdffileencryption", @""),NSLocalizedString(@"topscan_ocrtypecloud", @""),NSLocalizedString(@"topscan_cloudservice", @""),NSLocalizedString(@"topscan_functionofcollage", @""),NSLocalizedString(@"topscan_unlimitedscans", @""),NSLocalizedString(@"topscan_clearwaternark", @""),NSLocalizedString(@"topscan_writesignature", @""),NSLocalizedString(@"topscan_highqualitydoc", @""),NSLocalizedString(@"topscan_emailmyself", @""),NSLocalizedString(@"topscan_exportpdfdoc", @""),NSLocalizedString(@"topscan_backup", @""),NSLocalizedString(@"topscan_collageidcard", @""),NSLocalizedString(@"topscan_graffiti", @""),NSLocalizedString(@"topscan_applock", @""),NSLocalizedString(@"topscan_imagetotext", @""),NSLocalizedString(@"topscan_propdfeditor", @"")]];
        self.needUnlockImageArrays = [NSMutableArray arrayWithArray:@[@"top_unlock_unlimitedFolder",@"top_unlock_NoAds",@"top_unlock_pdflock",@"top_unlock_ocr",@"top_unlock_fileupload",@"top_unlock_function",@"top_unlock_scans",@"top_unlock_watermark",@"top_unlock_signature",@"top_unlock_highqualityDocument",@"top_unlock_email",@"top_unlock_sharepdf",@"top_unlock_backup_restore",@"top_unlock_idcard",@"top_unlock_graffiti",@"top_unlock_applock",@"top_unlock_imagetotext",@"top_unlock_emportpdf"]];
        self.cancelBlock = cancelBlock;
        self.selectBlock = selectBlock;
        [self top_drawView];
    }
    return self;
}
- (void)top_drawView
{
    _mAlert = [[UIView alloc] init];
    _mAlert.backgroundColor = [UIColor clearColor];
    [self addSubview:_mAlert];
    [_mAlert mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.top.equalTo(self).offset(80);
        make.left.equalTo(self).offset(15);
        make.bottom.equalTo(self).offset(-80);
    }];
    
    UIView *contentAlertView = [[UIView alloc] init];
    contentAlertView.layer.cornerRadius = 10;
    contentAlertView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    contentAlertView.clipsToBounds = YES;
    [self.mAlert addSubview:contentAlertView];
    [contentAlertView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mAlert);
        make.top.equalTo(self.mAlert);
        make.left.equalTo(self.mAlert);
        make.bottom.equalTo(self.mAlert).offset(-50);
    }];
    [contentAlertView addSubview:self.bottomSunView];
    [self.bottomSunView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(130);
        make.left.equalTo(contentAlertView);
        make.right.equalTo(contentAlertView);
        make.bottom.equalTo(contentAlertView);
    }];
    [contentAlertView addSubview:self.collectionView];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentAlertView);
        make.left.equalTo(contentAlertView);
        make.right.equalTo(contentAlertView);
        make.bottom.equalTo(_bottomSunView.mas_top);
    }];
    
    self.productTipsLabel = [[UILabel alloc] init];
    self.productTipsLabel.font = PingFang_M_FONT_(12);
    self.productTipsLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x333333)];
    self.productTipsLabel.text = @"* 3-day Free Trial, Auto-renewable, cancel anytime.";
    self.productTipsLabel.textAlignment = NSTextAlignmentCenter;
    [_bottomSunView addSubview:self.productTipsLabel];
    self.productTipsLabel.numberOfLines = 0;
    [_productTipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomSunView).offset(15);
        make.left.equalTo(self.bottomSunView).offset(15);
        make.right.mas_lessThanOrEqualTo(_bottomSunView.mas_right).offset(-60);
    }];
    
    UIButton *detailMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [detailMoreButton setTitle:NSLocalizedString(@"topscan_details", @"") forState:UIControlStateNormal];
    [detailMoreButton setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    detailMoreButton.titleLabel.font = PingFang_M_FONT_(10);
    [detailMoreButton addTarget:self action:@selector(top_detailMoreClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomSunView addSubview:detailMoreButton];
    [detailMoreButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_bottomSunView).offset(-10);
        make.centerY.equalTo(self.productTipsLabel);
        make.height.mas_offset(35);
        make.width.mas_offset(40);
    }];
    
    UIView *confirmbgView = [UIView new];
    confirmbgView.backgroundColor = TOPAPPGreenColor;
    confirmbgView.clipsToBounds = YES;
    confirmbgView.layer.cornerRadius = 49/2;
    [_bottomSunView addSubview:confirmbgView];
    [confirmbgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_productTipsLabel.mas_bottom).offset(10);
        make.left.equalTo(_bottomSunView).offset(50);
        make.right.equalTo(_bottomSunView).offset(-50);
        make.height.mas_offset(49);
    }];
    self.confirmTopTitleLabel = [[UILabel alloc] init];
    self.confirmTopTitleLabel.font = PingFang_M_FONT_(16);
    self.confirmTopTitleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    self.confirmTopTitleLabel.text = NSLocalizedString(@"topscan_questioncontinue", @"");
    self.confirmTopTitleLabel.textAlignment = NSTextAlignmentCenter;
    [confirmbgView addSubview:self.confirmTopTitleLabel];
    [_confirmTopTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(confirmbgView).offset(10);
        make.centerX.equalTo(confirmbgView);
    }];
    
    self.confirmBottomTitleLabel = [[UILabel alloc] init];
    self.confirmBottomTitleLabel.font = PingFang_M_FONT_(11);
    self.confirmBottomTitleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    self.confirmBottomTitleLabel.text = @"3-day Free Trial";
    self.confirmBottomTitleLabel.textAlignment = NSTextAlignmentCenter;
    [confirmbgView addSubview:self.confirmBottomTitleLabel];
    [_confirmBottomTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_confirmTopTitleLabel.mas_bottom);
        make.centerX.equalTo(confirmbgView);
    }];
    
    UIButton *startBuyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startBuyButton addTarget:self action:@selector(top_startSubscriptionClick:) forControlEvents:UIControlEventTouchUpInside];
    startBuyButton.tag = 1939;
    [confirmbgView addSubview:startBuyButton];
    [startBuyButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(confirmbgView);
        make.top.equalTo(confirmbgView);
        make.left.equalTo(confirmbgView);
        make.bottom.equalTo(confirmbgView);
    }];
    //  关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"top_home_vip_tc_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(top_closeAlertView:) forControlEvents:UIControlEventTouchUpInside];
    [_mAlert addSubview:closeButton];
    [closeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_mAlert);
        make.centerX.equalTo(_mAlert);
        make.height.mas_offset(29);
        make.width.mas_offset(29);
        
    }];
    NSString *plistsPath =  [[TOPDocumentHelper top_appBoxDirectory] stringByAppendingPathComponent:TOP_TRPlistsString];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistsPath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:plistsPath];
    }
    NSMutableArray*localArrays = [NSMutableArray arrayWithArray:[NSArray arrayWithContentsOfFile:[plistsPath stringByAppendingFormat:@"/SaveSubscriptionProductList.plist"]]];
    if (!localArrays.count) {
        self.confirmTopTitleLabel.text = @"";
        self.confirmBottomTitleLabel.text = @"";
        ACPDownloadView *downloadView = [[ACPDownloadView alloc] init];
        [confirmbgView addSubview:downloadView];
        downloadView.backgroundColor = [UIColor clearColor];
        downloadView.tintColor = [UIColor whiteColor];
        downloadView.tag = 1938;
        [downloadView mas_remakeConstraints:^(MASConstraintMaker *make) {
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
    }else{
        startBuyButton.userInteractionEnabled = YES;
        self.confirmTopTitleLabel.text = NSLocalizedString(@"topscan_questioncontinue", @"");
        self.confirmBottomTitleLabel.text = NSLocalizedString(@"topscan_nofreetrial", @"");
        for (int i = 0; i < localArrays.count; i++) {
            TOPPurchasepayModel *purModel = [TOPPurchasepayModel mj_objectWithKeyValues:localArrays[i]];
            if ([purModel.purchaseKey isEqualToString:InAppProductIdSubscriptionYear]) {
                purModel.productTitle = [NSString stringWithFormat:@"%@/%@",purModel.productTitle,NSLocalizedString(@"topscan_year", @"")];
                self.currentProductModel = purModel;
                [self top_updateProductItemWithModel:purModel];
            }
        }
    }
    [self top_validateProductIdentifiers:@[InAppProductIdSubscriptionYear]];
}
- (void)top_updateProductItemWithModel:(TOPPurchasepayModel *)purModel
{
    NSString *titleString = [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"topscan_questioncontinue", @""),purModel.productTitle];
    NSRange range = [titleString rangeOfString:purModel.productTitle];
    NSMutableAttributedString * attri = [[NSMutableAttributedString alloc] initWithString:titleString];
    [attri addAttribute:NSFontAttributeName value:PingFang_R_FONT_(13) range:range];
    self.confirmTopTitleLabel.attributedText = attri;
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
        purModel.productTitle = [NSString stringWithFormat:@"%@/year",formattedPrice];
        purModel.payMoney = [[pro price] floatValue];
        if (pro.introductoryPrice) {
            purModel.isFreeTrial = YES;
            purModel.freeTrialTypeUnit = pro.introductoryPrice.subscriptionPeriod.unit;
            purModel.numberOfUnits = pro.introductoryPrice.subscriptionPeriod.numberOfUnits;
        }
        NSNumber *unitPrice =  [NSNumber numberWithFloat:[ pro.price floatValue]/12];
        NSString*formattedUnitPrice = [numberFormatter stringFromNumber:unitPrice];//例如 ￥12.00
        purModel.productSubTitle = [NSString stringWithFormat:@"%@/Mon", formattedUnitPrice];
        purModel.buyType = @"1 Year";
        self.currentProductModel = purModel;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        ACPDownloadView *downloadView = [self viewWithTag:1938];
        downloadView.hidden = YES;
        UIButton *startBuyButton = [self viewWithTag:1939];
        startBuyButton.userInteractionEnabled = YES;
        [self top_updateProductItemWithModel:self.currentProductModel];
    });
}


#pragma mark- 开始订阅
- (void)top_startSubscriptionClick:(UIButton *)sender
{
    NSLog(@"%s",__func__);
    [TOPJDSKPaymentTools shareInstance].delegate = self;
    [[TOPJDSKPaymentTools shareInstance] top_startBuyNumberWithServer:self.currentProductModel];
}

#pragma mark- 查看更多
- (void)top_detailMoreClick:(UIButton *)sender
{
    self.selectBlock(self);
}

#pragma mark -- 关闭
-(void)top_closeAlertView:(UIButton *)btn
{
    self.cancelBlock();
    [self.productsRequest cancel];
    [self top_dismissUnBoundView];
    
}
#pragma mark -- 展示弹窗
- (void)top_showAlertUnBoundView
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
//    [self drawView];
    _mAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    _mAlert.alpha = 0;
    
    WeakSelf(ws);
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        ws.mAlert.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        ws.mAlert.alpha = 1.0;
    } completion:nil];
}

// 展示弹窗
- (void)top_showAlertUnBoundViewSuperView:(UIView *)supView
{
    [supView addSubview:self];
    _mAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    _mAlert.alpha = 0;
    WeakSelf(ws);
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        ws.mAlert.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        ws.mAlert.alpha = 1.0;
    } completion:nil];
}
#pragma mark -- 点击其他区域关闭弹窗
- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded){
        CGPoint location = [sender locationInView:nil];
        if (![_mAlert pointInside:[_mAlert convertPoint:location fromView:_mAlert.window] withEvent:nil]){
            [_mAlert.window removeGestureRecognizer:sender];
            [self top_dismissUnBoundView];
        }
    }
}
#pragma mark -- 隐藏弹窗
- (void)top_dismissUnBoundView {
    _mAlert.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    WeakSelf(ws);
    [UIView animateWithDuration:0.3f animations:^{
        ws.mAlert.alpha = 0;
        ws.alpha = 0;
    } completion:^(BOOL finished) {
        [ws removeFromSuperview];
    }];
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
    cell.contentView.backgroundColor =  [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    return cell;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return  UIEdgeInsetsMake(10, 10, 5, 10);
}

//UICollectionViewCell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger cellW = (CGRectGetWidth(self.frame)-30-([self top_getDefaultParamete]+1)*10)/([self top_getDefaultParamete]);
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
        _needUnlockImageArrays = [NSMutableArray array];
    }
    return  _needUnlockImageArrays;
}

- (NSMutableArray *)needUnlockTitleArrays
{
    if (!_needUnlockTitleArrays) {
        _needUnlockTitleArrays = [NSMutableArray array];
    }
    return   _needUnlockTitleArrays;
}
#pragma mark -- collectionView
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
       //滚动方向
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:UIColorFromRGB(0xf2f2f7)];
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TOPUnlockFunctionCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPUnlockFunctionCollectionViewCell class])];
    }
    return _collectionView;
}

- (UIView *)bottomSunView
{
    if (!_bottomSunView) {
        _bottomSunView = [UIView new];
        _bottomSunView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    }
    return _bottomSunView;
}

#pragma mark- 订阅成功回调
- (void)top_succeedWithsucceedCode:(NSInteger)succeedCode{
    switch (succeedCode) {
        case IAPSucceedCode_ServersSucceed:
        {
            [SVProgressHUD dismiss];
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_subscriptsuccessfully", @"")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.cancelBlock();
                [self top_dismissUnBoundView];
            });
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
