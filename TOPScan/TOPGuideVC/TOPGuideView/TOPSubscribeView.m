#import "TOPSubscribeView.h"
#import "TOPSubscribeModel.h"
#import "TOPSubscribeCell.h"
#import "FFCustomSquareDotView.h"
#import "ACPDownloadView.h"
#import "ACPIndeterminateGoogleLayer.h"

@interface TOPSubscribeView()
@property (nonatomic ,strong)UIImageView * imgView;
@property (nonatomic ,strong)GKCycleScrollView * scrollView;
@property (nonatomic ,strong)FFPageControl * pageControl;
@property (nonatomic ,strong)UILabel * titleLabF;
@property (nonatomic ,strong)UIButton * payBtn;
@end
@implementation TOPSubscribeView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        _imgView = [UIImageView new];
        [self addSubview:_imgView];
        
        _scrollView = [GKCycleScrollView new];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        _scrollView.dataSource = self;
        _scrollView.leftRightMargin = 15.0f;
        _scrollView.topBottomMargin = 15.0f;
        _scrollView.autoScrollTime = 2.0;
        [self addSubview:_scrollView];
    }
    return self;
}
#pragma mark -- 计算最上面显示图片所占的高度 作为滚动试图的中心点的Y坐标
- (NSString *)top_getImgName{
    CGFloat topH = 0.0;
    NSString * imgName = [NSString new];
    if (TOPScreenHeight == 667) {
        imgName = @"top_750-1334";
        topH = 300;
    }
    if (TOPScreenHeight == 736) {
        imgName = @"top_1242-2208";
        topH = (980*TOPScreenWidth)/1242;
    }
    if (TOPScreenHeight == 812) {
        if ([[TOPAppTools deviceVersion] isEqualToString:@"iPhone 12 mini"]) {
            imgName = @"top_1080-2340";
            topH = (860*TOPScreenWidth)/1080;
        }else{
            imgName = @"top_1125-2436";
            topH = (890*TOPScreenWidth)/1125;
        }
    }
    
    if (TOPScreenHeight == 844) {
        imgName = @"top_1170-2532";
        topH = (930*TOPScreenWidth)/1170;
    }
    
    if (TOPScreenHeight == 896) {
        if ([[TOPAppTools deviceVersion] isEqualToString:@"iPhone 11 Pro Max"]) {
            imgName = @"top_1242-2688";
            topH = (980*TOPScreenWidth)/1242;
        }else{
            imgName = @"top_828-1792";
            topH = (650*TOPScreenWidth)/828;
        }
    }
    
    if (TOPScreenHeight == 926) {
        imgName = @"top_1284-2778";
        topH = (1010*TOPScreenWidth)/1284;
    }
    
    if (TOPScreenHeight == 1344) {
        imgName = @"top_1242-2688";
        topH = (980*TOPScreenWidth)/1242;
    }
    return [NSString stringWithFormat:@"%@-%d",imgName,4];;
}

- (void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = dataArray;

    if (!_pageControl) {
        [self addSubview:self.pageControl];
        [self top_setFixedView];
    }
    [_scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.pageControl.mas_top).offset(-10);
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(120);
    }];
    if (IS_IPAD) {
        [self top_setTopImgFream:CGSizeMake(TOPScreenWidth, TOPScreenHeight)];
        _imgView.image = [UIImage imageNamed:@"top_iPad5"];
    }else{
        [_imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        _imgView.image = [UIImage imageNamed:[self top_getImgName]];
    }
    
    [_scrollView reloadData];
}

- (NSInteger)numberOfCellsInCycleScrollView:(GKCycleScrollView *)cycleScrollView{
    return _dataArray.count;
}

- (GKCycleScrollViewCell *)cycleScrollView:(GKCycleScrollView *)cycleScrollView cellForViewAtIndex:(NSInteger)index{
    GKCycleScrollViewCell *cell = [cycleScrollView dequeueReusableCell];
    if (!cell) {
        cell = [TOPSubscribeCell new];
    }
    if ([cell isKindOfClass:[TOPSubscribeCell class]]) {
        TOPSubscribeCell * subscribeCell = (TOPSubscribeCell *)cell;
        subscribeCell.model = _dataArray[index];
    }
    return cell;
}

#pragma mark - GKCycleScrollViewDelegate
- (CGSize)sizeForCellInCycleScrollView:(GKCycleScrollView *)cycleScrollView {
    
    return CGSizeMake(200, 120);
}

- (void)cycleScrollView:(GKCycleScrollView *)cycleScrollView didScrollCellToIndex:(NSInteger)index {
    self.pageControl.currentPage = index;
}

- (void)cycleScrollView:(GKCycleScrollView *)cycleScrollView didSelectCellAtIndex:(NSInteger)index {
}

- (void)cycleScrollView:(GKCycleScrollView *)cycleScrollView scrollingFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex ratio:(CGFloat)ratio {
}

- (FFPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[FFPageControl alloc] init];
        _pageControl.currentPage = 0;
        _pageControl.numberOfPages = self.dataArray.count;
        _pageControl.hidesForSinglePage = true;
        _pageControl.dotColor = [UIColor whiteColor];
        _pageControl.currentDotColor = TOPAPPGreenColor;
        _pageControl.dotViewClass = [FFCustomSquareDotView class];
    }
    return _pageControl;
}

- (void)top_setFixedView{
    UIColor * currentColor = [UIColor new];
    if (IS_IPAD) {
        currentColor = RGBA(51, 51, 51, 1.0);
    }else{
        currentColor = [UIColor whiteColor];
    }
    UIImageView * iconImgO = [UIImageView new];
    UIImageView * iconImgS = [UIImageView new];
    UIImageView * iconImgT = [UIImageView new];
    iconImgO.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
    iconImgS.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
    iconImgT.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];

    UILabel * titleLabO = [UILabel new];
    titleLabO.text = NSLocalizedString(@"topscan_noads", @"");
    titleLabO.textColor = currentColor;
    titleLabO.font = [UIFont systemFontOfSize:16];
    titleLabO.textAlignment = NSTextAlignmentNatural;

    UILabel * titleLabS = [UILabel new];
    titleLabS.text = NSLocalizedString(@"topscan_unlimitedscans", @"");
    titleLabS.textColor = currentColor;
    titleLabS.font = [UIFont systemFontOfSize:16];
    titleLabS.textAlignment = NSTextAlignmentNatural;
    
    UILabel * titleLabT = [UILabel new];
    titleLabT.text = NSLocalizedString(@"topscan_unlimitedfeatures", @"");
    titleLabT.textColor = currentColor;
    titleLabT.font = [UIFont systemFontOfSize:16];
    titleLabT.textAlignment = NSTextAlignmentNatural;
    
    UILabel * titleLabF = [UILabel new];
    titleLabF.text = [NSString stringWithFormat:@"%@-%@%@%@",@"3",@"day",NSLocalizedString(@"topscan_freetrial", @""),NSLocalizedString(@"topscan_autorenewable", @"")];
    titleLabF.textColor = currentColor;
    titleLabF.font = [UIFont systemFontOfSize:12];
    titleLabF.textAlignment = NSTextAlignmentCenter;
    self.titleLabF = titleLabF;

    UIButton * payBtn = [UIButton new];
    payBtn.tag = 1000+TOPSubscribeEventPay;
    payBtn.titleLabel.numberOfLines = 0;
    payBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    payBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    payBtn.titleLabel.textColor = [UIColor whiteColor];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payBtn setBackgroundColor:TOPAPPGreenColor];
    [payBtn addTarget:self action:@selector(top_btnAction:) forControlEvents:UIControlEventTouchUpInside];
    payBtn.layer.cornerRadius = 22;
    payBtn.layer.masksToBounds = YES;
    self.payBtn = payBtn;

    
    
    UIButton * limitBtn = [UIButton new];
    limitBtn.tag = 1000+TOPSubscribeEventLimitVersion;
    limitBtn.backgroundColor = [UIColor clearColor];
    limitBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [limitBtn setTitle:NSLocalizedString(@"topscan_uselimitedversion", @"") forState:UIControlStateNormal];
    [limitBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [limitBtn addTarget:self action:@selector(top_btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString * restoreImg = [NSString new];
    if (IS_IPAD) {
        restoreImg = @"top_toRestoreIpad";
    }else{
        restoreImg = @"top_toRestore";
    }
    TOPImageTitleButton *restoreBtn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightCenter)];
    restoreBtn.padding = CGSizeMake(2, 2);
    restoreBtn.tag = 1000+TOPSubscribeEventRestore;
    restoreBtn.backgroundColor = [UIColor clearColor];
    restoreBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [restoreBtn setTitleColor:currentColor forState:UIControlStateNormal];
    [restoreBtn setTitle:NSLocalizedString(@"topscan_restoretitle", @"") forState:UIControlStateNormal];
    [restoreBtn setImage:[UIImage imageNamed:restoreImg] forState:UIControlStateNormal];
    [restoreBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    [restoreBtn addTarget:self action:@selector(top_btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UITextView * textview = [UITextView new];
    textview.backgroundColor = [UIColor clearColor];
    textview.font = [UIFont systemFontOfSize:10];
    textview.textAlignment = NSTextAlignmentCenter;
    textview.textContainerInset = UIEdgeInsetsMake(0, 0,0, 0);
    textview.showsVerticalScrollIndicator = NO;
    textview.linkTextAttributes = @{NSForegroundColorAttributeName:TOPAPPGreenColor};
    textview.delegate = self;
    textview.editable = NO;
    textview.scrollEnabled = YES;
    
    NSString * textTitleString = [NSString stringWithFormat:@"%@\n%@\n%@",NSLocalizedString(@"topscan_paymenttext1", @""),NSLocalizedString(@"topscan_paymenttext2", @""),NSLocalizedString(@"topscan_paymenttext3", @"")];
    NSString * serviceString = NSLocalizedString(@"topscan_termsofserice", @"");
    NSString * serviceUrl = TOP_TRUserAgreementURL;
    NSString * privacyString = NSLocalizedString(@"topscan_privacypolicy", @"");
    NSString * pricacyUrl = TOP_TRPrivacyPolicyURL;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@ & %@",textTitleString,serviceString,privacyString]];

    NSRange serviceRange = [[attributedString string] rangeOfString:serviceString];
    NSRange privacyRange = [[attributedString string] rangeOfString:privacyString];
    if (IS_IPAD) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:RGBA(153, 153, 153, 1.0) range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSUnderlineColorAttributeName value:RGBA(153, 153, 153, 1.0) range:serviceRange];
        [attributedString addAttribute:NSUnderlineColorAttributeName value:RGBA(153, 153, 153, 1.0) range:privacyRange];
    }else{
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSUnderlineColorAttributeName value:TOPAPPGreenColor range:serviceRange];
        [attributedString addAttribute:NSUnderlineColorAttributeName value:TOPAPPGreenColor range:privacyRange];
    }
    [attributedString addAttribute:NSFontAttributeName value:PingFang_R_FONT_(13) range:serviceRange];
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(1) range:serviceRange];

    [attributedString addAttribute:NSFontAttributeName value:PingFang_R_FONT_(13) range:privacyRange];
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(1) range:privacyRange];
   
    [attributedString addAttribute:NSLinkAttributeName
                             value:serviceUrl
                             range:serviceRange];
    [attributedString addAttribute:NSLinkAttributeName
                             value:pricacyUrl
                             range:privacyRange];
    textview.attributedText = attributedString;
    
    [self addSubview:iconImgO];
    [self addSubview:iconImgS];
    [self addSubview:iconImgT];
    [self addSubview:titleLabO];
    [self addSubview:titleLabS];
    [self addSubview:titleLabT];
    [self addSubview:titleLabF];
    [self addSubview:payBtn];
    [self addSubview:limitBtn];
    [self addSubview:restoreBtn];
    [self addSubview:textview];
    CGFloat limitH = 14;
    CGFloat centerW = 60;
    if (IS_IPAD) {
        [textview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-(5+TOPBottomSafeHeight));
            make.size.mas_equalTo(CGSizeMake(400, 50));
        }];
    }else{
        [textview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(15);
            make.trailing.equalTo(self).offset(-15);
            make.bottom.equalTo(self).offset(-(5+TOPBottomSafeHeight));
            make.height.mas_equalTo(50);
        }];
    }
    
    [restoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(textview.mas_top);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    [limitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(restoreBtn.mas_top);
        make.size.mas_equalTo(CGSizeMake(200, 35));
    }];
    [payBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(limitBtn.mas_top).offset(-15);
        make.size.mas_equalTo(CGSizeMake(305, 44));
    }];
    
    
    ACPDownloadView *downloadView = [[ACPDownloadView alloc] init];
    [self addSubview:downloadView];
    downloadView.backgroundColor = [UIColor clearColor];
    downloadView.tintColor = [UIColor whiteColor];
    downloadView.tag = 1938;
    
    [downloadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(payBtn).offset(9);
        make.height.mas_offset(26);
        make.width.mas_offset(26);
    }];

    ACPIndeterminateGoogleLayer * layer = [ACPIndeterminateGoogleLayer new];
    [layer updateColor:[UIColor grayColor]];
    [downloadView setIndeterminateLayer:layer];
    [downloadView setIndicatorStatus:ACPDownloadStatusIndeterminate];
    payBtn.userInteractionEnabled = NO;
    
    [titleLabF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(payBtn.mas_top).offset(-10);
        make.leading.equalTo(self).offset(15);
        make.trailing.equalTo(self).offset(-15);
        make.height.mas_offset(15);
    }];
    CGFloat msCenterX = 0;
    if (isRTL()) {
        msCenterX = centerW;
    }else{
        msCenterX = -centerW;
    }
    [iconImgT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(titleLabF.mas_top).offset(-limitH);
        make.centerX.equalTo(self).offset(msCenterX);
        make.size.mas_equalTo(CGSizeMake(17, 17 ));
    }];
    [titleLabT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(iconImgT.mas_centerY);
        make.leading.equalTo(iconImgT.mas_trailing).offset(10);
        make.trailing.equalTo(self).offset(-20);
    }];
    [iconImgS mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(iconImgT.mas_top).offset(-limitH);
        make.centerX.equalTo(iconImgT.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(17, 17 ));
    }];
    [titleLabS mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(iconImgS.mas_centerY);
        make.leading.equalTo(iconImgS.mas_trailing).offset(10);
        make.trailing.equalTo(self).offset(-20);
    }];
    
    [iconImgO mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(iconImgS.mas_top).offset(-limitH);
        make.centerX.equalTo(iconImgS.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(17, 17 ));
    }];
    [titleLabO mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(iconImgO.mas_centerY);
        make.leading.equalTo(iconImgO.mas_trailing).offset(10);
        make.trailing.equalTo(self).offset(-20);
    }];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(titleLabO.mas_top).offset(-15);
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(15);
    }];
}

- (void)setPurModel:(TOPPurchasepayModel *)purModel{
    _purModel = purModel;
    [self top_setShowContent:purModel];
}

- (void)top_setShowContent:(TOPPurchasepayModel *)purModel{
    NSString * freeString = [NSString new];
    NSString * payString = [NSString new];
    if (purModel.isFreeTrial) {
        switch ( purModel.freeTrialTypeUnit) {
            case 0:
                freeString = [NSString stringWithFormat:@"* %ld-%@ %@, %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_day", @""),NSLocalizedString(@"topscan_freetrial", @""),NSLocalizedString(@"topscan_autorenewable", @"")];
                payString = [NSString stringWithFormat:@"%ld-%@ %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_day", @""),NSLocalizedString(@"topscan_freetrial", @"")];
                break;
            case 1:
                freeString = [NSString stringWithFormat:@"* %ld-%@ %@, %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_week", @""),NSLocalizedString(@"topscan_freetrial", @""),NSLocalizedString(@"topscan_autorenewable", @"")];
                payString = [NSString stringWithFormat:@"%ld-%@ %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_week", @""),NSLocalizedString(@"topscan_freetrial", @"")];
                
                break;
            case 2:
                freeString = [NSString stringWithFormat:@"* %ld-%@ %@, %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_month", @""),NSLocalizedString(@"topscan_freetrial", @""),NSLocalizedString(@"topscan_autorenewable", @"")];
                payString = [NSString stringWithFormat:@"%ld-%@ %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_month", @""),NSLocalizedString(@"topscan_freetrial", @"")];
                
                break;
            case 3:
                freeString = [NSString stringWithFormat:@"* %ld-%@ %@, %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_year", @""),NSLocalizedString(@"topscan_freetrial", @""),NSLocalizedString(@"topscan_autorenewable", @"")];
                payString = [NSString stringWithFormat:@"%ld-%@ %@",purModel.numberOfUnits,NSLocalizedString(@"topscan_year", @""),NSLocalizedString(@"topscan_freetrial", @"")];
                break;
            default:
                break;
        }
    }else{
        freeString = [NSString stringWithFormat:@"* %@",NSLocalizedString(@"topscan_autorenewable", @"")];
        payString = NSLocalizedString(@"topscan_nofreetrial", @"");
    }
    
    ACPDownloadView *downloadView = [self viewWithTag:1938];
    [downloadView setIndicatorStatus:ACPDownloadStatusNone];

    downloadView.hidden = YES;

    self.payBtn.userInteractionEnabled = YES;
    self.titleLabF.text = freeString;
    [self.payBtn setImage:[UIImage imageNamed:@"top_toPay"] forState:UIControlStateNormal];
    [self.payBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 250, 0, 0)];
    [self.payBtn setAttributedTitle:[self payAttributedString:payString withPrice:purModel.productTitle] forState:UIControlStateNormal];
}

- (NSMutableAttributedString *)payAttributedString:(NSString *)payString withPrice:(NSString *)productString{
    NSString *titleString = [NSString stringWithFormat:@"%@(%@)\n%@",NSLocalizedString(@"topscan_questioncontinue", @""),productString,payString];
    NSRange range = [titleString rangeOfString:productString];
    NSRange range1 = [titleString rangeOfString:payString];
    NSMutableAttributedString * attri = [[NSMutableAttributedString alloc] initWithString:titleString];
    [attri addAttribute:NSFontAttributeName value:PingFang_R_FONT_(13) range:range];
    [attri addAttribute:NSFontAttributeName value:PingFang_R_FONT_(11) range:range1];
    return attri;
}

- (void)setCurrentSize:(CGSize)currentSize{
    _currentSize = currentSize;
    [self top_setTopImgFream:currentSize];
}

- (void)top_setTopImgFream:(CGSize)currentSize{
    CGFloat BottomH = 0;
    if (currentSize.width<currentSize.height) {
        BottomH = 60;
    }else{
        BottomH = 10;
    }
    [_imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(_scrollView.mas_top).offset(-BottomH);
        make.size.mas_equalTo(CGSizeMake(375, 300));
    }];
}
- (void)top_btnAction:(UIButton *)sender{
    if (self.top_subscribeEvent) {
        self.top_subscribeEvent(sender.tag-1000);
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    if (self.top_subscribePrivacyURL) {
        self.top_subscribePrivacyURL(URL.absoluteString);
    }
    return YES;
}

@end
