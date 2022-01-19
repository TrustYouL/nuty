

#import "TOPDiscountThemeView.h"
#import "ACPDownloadView.h"
#import "ACPIndeterminateGoogleLayer.h"
#import "TOPJDSKPaymentTools.h"
#import "TOPPurchasepayModel.h"
#import "TOPInAppStoreManager.h"
#import "TOPInAppStoreObserver.h"
#import "TOPFHTimer.h"
#import "TOPNetWorkManager.h"

#define kElementWidth  52
#define kElementHeight 78

@interface SSImageTitleView : UIView
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLab;

- (void)setViewContent:(NSDictionary *)param;

@end

@implementation SSImageTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self top_configContentView];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.bounds = CGRectMake(0, 0, kElementWidth, kElementHeight);
        [self top_configContentView];
    }
    return self;
}

- (void)setViewContent:(NSDictionary *)param {
    UIImage *img = [UIImage imageNamed:param[@"icon"]];
    NSString *text = param[@"title"];
    self.imgView.image = img;
    self.titleLab.text = text;
}

- (void)top_configContentView {
    self.backgroundColor = [UIColor clearColor];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(kElementWidth, kElementWidth));
    }];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView.mas_bottom).offset(0);
        make.centerX.equalTo(self);
    }];
}

#pragma mark -- lazy
- (UIImageView *)imgView {
    if (!_imgView) {
        UIImageView *noClass = [[UIImageView alloc] init];
        [self addSubview:noClass];
        _imgView = noClass;
    }
    return _imgView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = RGB(255, 229, 198);
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_R_FONT_(12);
        noClassLab.text = @"";
        noClassLab.numberOfLines = 2;
        [self addSubview:noClassLab];
        _titleLab = noClassLab;
    }
    return _titleLab;
}


@end

#define kBGWidth  375
#define kBGHeight 585

@interface TOPDiscountThemeView ()<TOPJDSKPaymentToolsDelegate, TOPStoreManagerProtocol>
@property (nonatomic, strong) UIView *maskView;//透明遮罩层
@property (nonatomic, strong) UIView *themeView;//活动主题视图
@property (nonatomic, copy) NSString *productId;//活动商品id
@property (nonatomic, strong) UIButton *purchaseBtn;//购买按钮
@property (nonatomic, strong) UILabel *priceTitleLab;//first year
@property (nonatomic, strong) UILabel *disCountLab;//折扣价
@property (nonatomic, strong) UILabel *priceLab;//原价
@property (nonatomic, strong) UILabel *countdownLab;//倒计时
@property (nonatomic, strong) ACPDownloadView *downloadView;//加载动画

@property (nonatomic, strong) NSMutableArray *productsArrays;//订阅的产品数组
@property (nonatomic, assign) NSInteger lifeTime;//优惠活动剩余时间

@end

static NSInteger totalHours = 24 * 3;

@implementation TOPDiscountThemeView

+ (instancetype)shareInstance {
    
    static TOPDiscountThemeView *singleTon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[TOPDiscountThemeView alloc] init];
    });
    return singleTon;
}

- (instancetype)init {
    if ([super init]) {
        _lifeTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"lifeTimeKey"];
        if (!_lifeTime) {
            _lifeTime = 3600 * totalHours;
            [self getEndTime];
        }
    }
    return self;
}

- (void)getEndTime {//活动结束时间
    [TOPNetWorkManager topFetchGoogleTimeSuccess:^(NSTimeInterval time) {
        NSInteger future =  lround(time) + self.lifeTime;
        [[NSUserDefaults standardUserDefaults] setInteger:future forKey:@"futureTimeKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)top_showDiscountTheme:(NSString *)productId {
    if ([productId length]) {
        _productId = productId;
        [self top_configContentView];
        [self fetchProductInfo];
        [self timerBegin];
    }
}

#pragma mark -- 开始计时
- (void)timerBegin {
    [[TOPFHTimer shareInstance] top_createTimerSeconds:^(int interval) {
        [self refreshLifeTime];
        [self updateCountDown];
    }];
}

- (void)refreshLifeTime {
    self.lifeTime --;
    [[NSUserDefaults standardUserDefaults] setInteger:self.lifeTime forKey:@"lifeTimeKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateCountDown {
    if (self.lifeTime < 0) {
        [[TOPFHTimer shareInstance] top_destroyTimer];
        if (self.overTimeBlock) {
            self.overTimeBlock();
        }
        return;
    }
    //设置倒计时显示的时间
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",self.lifeTime/3600];//时
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(self.lifeTime%3600)/60];//分
    NSString *str_second = [NSString stringWithFormat:@"%02ld",self.lifeTime%60];//秒
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    self.countdownLab.text = [NSString stringWithFormat:@" %@",format_time];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",format_time] attributes:@{NSKernAttributeName: @3,NSFontAttributeName: [UIFont fontWithName:@"Seravek" size: 19],NSForegroundColorAttributeName: RGB(50, 30, 127),}];

    self.countdownLab.attributedText = string;
}

- (void)top_hiddenTheme {
    [self.productsArrays removeAllObjects];
    [self.themeView removeFromSuperview];
    self.themeView = nil;
    [self.maskView removeFromSuperview];
    self.maskView = nil;
}

- (void)fetchProductInfo {
    if (!self.productsArrays.count) {
        [self updateBtnState:NO];
        [self top_validateProductIdentifiers:@[self.productId]];
    }
}
#pragma mark -- 拉取商品信息
- (void)top_validateProductIdentifiers:(NSArray *)productIdentifiers
{
    [TOPInAppStoreManager shareInstance].delegate = self;
    [[TOPInAppStoreManager shareInstance] topstartProductRequestWithIdentifiers:productIdentifiers];
}

#pragma mark -- 显示商品信息
- (void)showAvailableProducts:(NSArray *)products {
    [self.productsArrays removeAllObjects];
    for (SKProduct *pro in products) {
        NSLog(@"SKProduct:%@", pro.mj_keyValues);
        TOPPurchasepayModel *purModel = [[TOPPurchasepayModel alloc] initWithProduct:pro];
        [self.productsArrays addObject:purModel];
    }
    if (self.productsArrays.count) {
        [self updateBtnState:YES];
        [self updateProductInfo];
    }
}

- (void)top_clickCloseBtn {
    [self top_hiddenTheme];
}

- (void)clickPurchaseBtn {
    double systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion < 12.2) {
        [[TOPCornerToast shareInstance] makeToast:@"Please upgrade to a later version of 'iOS 12.2'" duration:2.0];
        return;
    }
    [TOPJDSKPaymentTools shareInstance].delegate = self;
    [[TOPJDSKPaymentTools shareInstance] top_startBuyNumberWithServer:self.productsArrays.firstObject];
}

#pragma mark -- TOPStoreManagerProtocol
- (void)topStoreManagerDidReceiveResponse:(id)response {//数据回调
    NSMutableArray *section = (NSMutableArray *)response;
    if (section.count) {
        NSDictionary *dic = section[0];
        NSArray *products = dic[@"elements"];
        [self showAvailableProducts:products];
    }
}

- (void)topStoreManagerDidReceiveMessage:(NSString *)message {//信息回调
    [[TOPCornerToast shareInstance] makeToast:message];
}

#pragma mark- 订阅成功回调
- (void)top_succeedWithsucceedCode:(NSInteger)succeedCode {
    switch (succeedCode) {
        case IAPSucceedCode_ServersSucceed:
        {
            [[TOPFHTimer shareInstance] top_destroyTimer];
            [SVProgressHUD dismiss];
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_subscriptsuccessfully", @"")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self top_hiddenTheme];
            });
            if (self.purchaseSucceed) {
                self.purchaseSucceed();
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark- 订阅失败回调
- (void)top_filedWithErrorCode:(NSInteger)errorCode andError:(NSString *)error {
    [SVProgressHUD dismiss];
}

- (void)updateBtnState:(BOOL)enable {
    self.downloadView.hidden = enable;
    self.purchaseBtn.enabled = enable;
}

- (void)updateProductInfo {
    TOPPurchasepayModel *purModel = self.productsArrays.firstObject;
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 2;
    shadow.shadowColor = [UIColor colorWithRed:139/255.0 green:26/255.0 blue:16/255.0 alpha:0.5];
    shadow.shadowOffset = CGSizeMake(0,2);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@/year", purModel.discountPrice] attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Arial" size: 27],NSForegroundColorAttributeName: [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0], NSShadowAttributeName: shadow}];

    self.disCountLab.attributedText = string;
    
    NSString *priceStr = [NSString stringWithFormat:@"%@/year", purModel.productTitle];
    NSMutableAttributedString *newPrice = [[NSMutableAttributedString alloc] initWithString:priceStr];
    [newPrice addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, priceStr.length)];
    self.priceLab.attributedText = newPrice;
}

- (void)top_configContentView {
    [self.maskView addSubview:self.themeView];
    [self.themeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.maskView).offset(TOPScreenHeight * 0.12);
        make.centerX.equalTo(self.maskView);
    }];
    UIImageView *bgV = [self bgImgView];
    [self.themeView addSubview:bgV];
    [bgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.themeView);
    }];
    UIButton *closeBtn = [self closeBtn];
    [bgV addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgV).offset(12);
        make.trailing.equalTo(bgV).offset(-12);
        make.height.mas_offset(30);
        make.width.mas_offset(30);
        
    }];
    CGFloat width = 52, height = 78, margin = 47;
    CGFloat gap = (kBGWidth - margin*2 - width*4)/3.0;
    UIView *stackView = [[UIView alloc] initWithFrame:CGRectMake(margin, 356, kBGWidth - margin * 2, height)];
    stackView.backgroundColor = [UIColor clearColor];
    [bgV addSubview:stackView];
    for (int i = 0; i < [self dataSource].count; i ++) {
        NSDictionary *item = [self dataSource][i];
        SSImageTitleView *imgElement = [[SSImageTitleView alloc] initWithFrame:CGRectMake((width + gap)* i, 0, width, height)];
        [imgElement setViewContent:item];
        [stackView addSubview:imgElement];
    }
    UILabel *moreLab = [self moreTipLab];
    [bgV addSubview:moreLab];
    [moreLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgV);
        make.centerY.equalTo(bgV.mas_bottom).offset(-131);
        make.width.mas_equalTo(kBGWidth - 80);
    }];
    [bgV addSubview:self.purchaseBtn];
    [self.purchaseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgV);
        make.bottom.equalTo(bgV.mas_bottom).offset(-41);
        make.width.mas_equalTo(256);
        make.height.mas_equalTo(52);
    }];
    
    [bgV addSubview:self.priceLab];
    [bgV addSubview:self.priceTitleLab];
    [bgV addSubview:self.disCountLab];
    [bgV addSubview:self.countdownLab];
    UILabel *countLab = [self countTitleLab];
    [bgV addSubview:countLab];
    
    [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgV);
        make.top.equalTo(self.disCountLab.mas_bottom).offset(6);
    }];
    
    [self.priceTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.disCountLab.mas_centerY).offset(0);
        make.trailing.equalTo(self.disCountLab.mas_leading).offset(-2);
    }];
    
    [self.disCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgV);
        make.top.equalTo(bgV).offset(240);
        make.height.mas_equalTo(28);
    }];
    
    [countLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(bgV.mas_centerX).offset(20);
        make.centerY.equalTo(self.countdownLab.mas_centerY).offset(0);
    }];
    
    [self.countdownLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bgV.mas_centerX).offset(20);
        make.centerY.equalTo(bgV.mas_top).offset(341);
    }];
    
    UIScrollView *scrollV = [self scrollTip];
    [bgV addSubview:scrollV];
    [scrollV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(bgV).offset(-53);
        make.top.equalTo(self.purchaseBtn.mas_bottom).offset(10);
        make.leading.equalTo(bgV).offset(53);
        make.bottom.equalTo(bgV.mas_bottom).offset(-5);
    }];
    
    [self.purchaseBtn addSubview:self.downloadView];
    [self.downloadView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.purchaseBtn);
        make.centerX.equalTo(self.purchaseBtn);
        make.height.mas_offset(26);
        make.width.mas_offset(26);
    }];
    self.purchaseBtn.enabled = NO;
}

- (NSArray *)dataSource {
    NSDictionary *item1 = @{@"title": NSLocalizedString(@"topscan_noads", @""), @"icon": @"top_theme_noads"};
    NSDictionary *item2 = @{@"title": NSLocalizedString(@"topscan_unlimitedscans", @""), @"icon": @"top_theme_scan"};
    NSDictionary *item3 = @{@"title": NSLocalizedString(@"topscan_cloudservice", @""), @"icon": @"top_theme_cloud"};
    NSDictionary *item4 = @{@"title": NSLocalizedString(@"topscan_ocrtypecloud", @""), @"icon": @"top_theme_ocr"};
    return @[item1, item2, item3, item4];
}

#pragma mark -- lazy
//遮罩层
- (UIView *)maskView {
    if (!_maskView) {
        UIView *mask = [[UIView alloc] init];
        mask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.05];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:mask];
        [mask mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(window);
        }];
        _maskView = mask;
    }
    return _maskView;
}

- (UIView *)themeView {
    if (!_themeView) {
        UIView *mask = [[UIView alloc] init];
        _themeView = mask;
    }
    return _themeView;
}

- (UIImageView *)bgImgView {
    UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_discountTheme_bg"]];
    imgV.userInteractionEnabled = YES;
    return imgV;
}

- (UILabel *)moreTipLab {
    UILabel *noClassLab = [[UILabel alloc] init];
    noClassLab.textColor = kBlackColor;
    noClassLab.textAlignment = NSTextAlignmentCenter;
    noClassLab.font = PingFang_R_FONT_(14);
    noClassLab.text = @"20+ more advanced features";
    return noClassLab;
}

- (UIButton *)closeBtn {
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"top_theme_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(top_clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    return closeButton;
}

- (UIButton *)purchaseBtn {
    if (!_purchaseBtn) {
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [ovalBtn setTitle:NSLocalizedString(@"topscan_questioncontinue", @"") forState:UIControlStateNormal];
        ovalBtn.titleLabel.font = PingFang_S_FONT_(15);
        [ovalBtn setTitleColor:RGB(200, 9, 39) forState:UIControlStateNormal];
        ovalBtn.backgroundColor = RGB(255, 211, 169);
        ovalBtn.layer.cornerRadius = 26.0;//圆角的弧度
        [ovalBtn addTarget:self action:@selector(clickPurchaseBtn) forControlEvents:UIControlEventTouchUpInside];
        _purchaseBtn = ovalBtn;
    }
    return _purchaseBtn;
}

- (UILabel *)priceTitleLab {
    if (!_priceTitleLab) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = RGB(255, 211, 169);
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_R_FONT_(12);
        noClassLab.text = @"First year：";
        _priceTitleLab = noClassLab;
    }
    return _priceTitleLab;
}

- (UILabel *)disCountLab {
    if (!_disCountLab) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = kWhiteColor;
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_R_FONT_(27);
        noClassLab.text = @"$14.99/year";
        _disCountLab = noClassLab;
    }
    return _disCountLab;
}

- (UILabel *)priceLab {
    if (!_priceLab) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = kWhiteColor;
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_R_FONT_(15);
        noClassLab.text = @"";
        NSString *priceStr = @"$29.99/year";
        NSMutableAttributedString *newPrice = [[NSMutableAttributedString alloc] initWithString:priceStr];
        [newPrice addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, priceStr.length)];
        noClassLab.attributedText = newPrice;
        
        _priceLab = noClassLab;
    }
    return _priceLab;
}

- (UILabel *)countdownLab {
    if (!_countdownLab) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = RGB(50, 30, 127);
        noClassLab.textAlignment = NSTextAlignmentLeft;
        noClassLab.font = [UIFont fontWithName:@"Seravek" size: 19];
        noClassLab.text = @" 72:00:00";
        _countdownLab = noClassLab;
    }
    return _countdownLab;
}

- (UILabel *)countTitleLab {
    UILabel *noClassLab = [[UILabel alloc] init];
    noClassLab.textColor = RGB(50, 30, 127);
    noClassLab.textAlignment = NSTextAlignmentCenter;
    noClassLab.font = PingFang_R_FONT_(19);
    noClassLab.text = @"Countdown:";
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"Countdown:" attributes:@{NSKernAttributeName: @3,NSFontAttributeName: [UIFont fontWithName:@"Seravek" size: 19],NSForegroundColorAttributeName: RGB(50, 30, 127),}];

    noClassLab.attributedText = string;
    return noClassLab;
}

- (UIScrollView *)scrollTip {
    UIScrollView *userinstructionsScrollView = [[UIScrollView alloc] init];
    userinstructionsScrollView.backgroundColor = [UIColor clearColor];
    userinstructionsScrollView.showsVerticalScrollIndicator = NO;
    
    UILabel *scrollTiplabel = [[UILabel alloc] init];
    scrollTiplabel.font = PingFang_R_FONT_(10);
    NSString *conentStr = [NSString stringWithFormat:@"%@\n%@\n%@",NSLocalizedString(@"topscan_paymenttext1", @""),NSLocalizedString(@"topscan_paymenttext2", @""),NSLocalizedString(@"topscan_paymenttext3", @"")];
    
    scrollTiplabel.text = conentStr;
    scrollTiplabel.textColor = UIColorFromRGB(0x777777);
    scrollTiplabel.numberOfLines = 0;
    [userinstructionsScrollView addSubview:scrollTiplabel];
    [scrollTiplabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.equalTo(userinstructionsScrollView);
        make.width.mas_offset(TOPScreenWidth-53*2);
    }];
    CGSize textSize = [TOPAppTools sizeWithFont:10 textSizeWidht:(TOPScreenWidth-53*2) textSizeHeight:0 text:conentStr];
    if (textSize.height>50) {
        userinstructionsScrollView.contentSize = CGSizeMake(0, textSize.height) ;
    }
    return userinstructionsScrollView;
}

- (ACPDownloadView *)downloadView {
    if (!_downloadView) {
        ACPDownloadView *downloadView = [[ACPDownloadView alloc] init];
        downloadView.backgroundColor = [UIColor clearColor];
        downloadView.tintColor = [UIColor whiteColor];
        ACPIndeterminateGoogleLayer * layer = [ACPIndeterminateGoogleLayer new];
        [layer updateColor:[UIColor grayColor]];
        [downloadView setIndeterminateLayer:layer];
        [downloadView setIndicatorStatus:ACPDownloadStatusIndeterminate];
        _downloadView = downloadView;
    }
    return _downloadView;
}

- (NSMutableArray *)productsArrays {
    if (!_productsArrays) {
        _productsArrays = @[].mutableCopy;
    }
    return _productsArrays;
}

@end
