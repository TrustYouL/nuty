
#import "TOPUnlockFunctionViewController.h"
#import "TOPUnlockFuntionTableViewCell.h"
#import "TOPJDSKPaymentTools.h"
#import "TOPPurchasepayModel.h"
#import "TOPSettingViewController.h"
#import "ACPDownloadView.h"
#import "ACPIndeterminateGoogleLayer.h"


@interface TOPUnlockFunctionViewController ()<UITableViewDelegate,UITableViewDataSource,SKProductsRequestDelegate,TOPJDSKPaymentToolsDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic ,strong)NSMutableArray * dataArray;
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

/**
订阅的产品数组
 */
@property (nonatomic,strong) NSMutableArray *productsArrays;

/*
请求商品信息
*/
@property(nonatomic, strong) SKProductsRequest *productsRequest;

@end

@implementation TOPUnlockFunctionViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    if (!self.isHiddenBottomSubScript) {
        if (self.productsArrays.count<=0) {
            UIButton *startBuyButton = [self.view viewWithTag:1939];
            startBuyButton.userInteractionEnabled = NO;
            UIButton *selectOneProductButton = [self.view viewWithTag:1342];
            selectOneProductButton.userInteractionEnabled = NO;
            UIButton *selectTwoProductButton = [self.view viewWithTag:1343];
            selectTwoProductButton.userInteractionEnabled = NO;
            [self top_validateProductIdentifiers:@[InAppProductIdSubscriptionMonth,InAppProductIdSubscriptionYear]];
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.currentProductIndex = 1;
    if (isRTL()) {//黑色
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    self.title = NSLocalizedString(@"topscan_details", @"");
    [self top_setRightItem];
    
    NSArray * needUnlockTitleArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_unlimitedfolders", @""),NSLocalizedString(@"topscan_noads", @""),NSLocalizedString(@"topscan_pdffileencryption", @""),NSLocalizedString(@"topscan_ocrtypecloud", @""),NSLocalizedString(@"topscan_cloudservice", @""),NSLocalizedString(@"topscan_functionofcollage", @""),NSLocalizedString(@"topscan_unlimitedscans", @""),NSLocalizedString(@"topscan_clearwaternark", @""),NSLocalizedString(@"topscan_writesignature", @""),NSLocalizedString(@"topscan_highqualitydoc", @""),NSLocalizedString(@"topscan_emailmyself", @""),NSLocalizedString(@"topscan_exportpdfdoc", @""),NSLocalizedString(@"topscan_backup", @""),NSLocalizedString(@"topscan_collageidcard", @""),NSLocalizedString(@"topscan_graffiti", @""),NSLocalizedString(@"topscan_applock", @""),NSLocalizedString(@"topscan_imagetotext", @""),NSLocalizedString(@"topscan_propdfeditor", @"")]];
    
    WS(weakSelf);
    [needUnlockTitleArrays enumerateObjectsUsingBlock:^(NSString *  _Nonnull unlockName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *rowIconName = @[@"top_unlock_unlimitedFolder",@"top_unlock_NoAds",@"top_unlock_pdflock",@"top_unlock_ocr",@"top_unlock_fileupload",@"top_unlock_function",@"top_unlock_scans",@"top_unlock_watermark",@"top_unlock_signature",@"top_unlock_highqualityDocument",@"top_unlock_email",@"top_unlock_sharepdf",@"top_unlock_backup_restore",@"top_unlock_idcard",@"top_unlock_graffiti",@"top_unlock_applock",@"top_unlock_imagetotext",@"top_unlock_emportpdf"][idx];
        
        NSString *rowDetailStr = @[NSLocalizedString(@"topscan_unlimitedfoldersintroduce", @""),NSLocalizedString(@"topscan_noadsintroduce", @""),NSLocalizedString(@"topscan_pdffileencryptionintroduce", @""),NSLocalizedString(@"topscan_ocrtypecloudintroduce", @""),NSLocalizedString(@"topscan_cloudserviceintroduce", @""),NSLocalizedString(@"topscan_functionofcollageintroduce", @""),NSLocalizedString(@"topscan_unlimitedscansintroduce", @""),NSLocalizedString(@"topscan_clearwaternarkintroduce", @""),NSLocalizedString(@"topscan_writesignatureintroduce", @""),NSLocalizedString(@"topscan_highqualitydocintroduce", @""),NSLocalizedString(@"topscan_emailmyselfintroduce", @""),NSLocalizedString(@"topscan_exportpdfdocintroduce", @""),NSLocalizedString(@"topscan_backupintroduce", @""),NSLocalizedString(@"topscan_cameratypeidcardintroduce", @""),NSLocalizedString(@"topscan_graffitiintroduce", @""),NSLocalizedString(@"topscan_applockintroduce", @""),NSLocalizedString(@"topscan_imagetotextintroduce", @""),NSLocalizedString(@"topscan_propdfeditorintroduce", @"")][idx];
        
        
        float titleHeight = [TOPDocumentHelper top_getSizeWithStr:unlockName Width:CGRectGetWidth(self.view.frame)-45*2-47-5 Font:15].height;
        float titleDetailHeight = [TOPDocumentHelper top_getSizeWithStr:rowDetailStr Width:CGRectGetWidth(self.view.frame)-45*2-47-5 Font:11].height;
        float cellHeight = titleHeight+titleDetailHeight+45;
        if (cellHeight< 85) {
            cellHeight = 85;
        }
        NSDictionary *dic = @{@"rowIcon":rowIconName,@"rowName":unlockName,@"titleHeight":@(titleHeight),@"CellHeight":@(cellHeight),@"titleDetailHeight":@(titleDetailHeight),@"rowDetail":rowDetailStr};
        [weakSelf.dataArray addObject:dic];
    }];
    
    
    if (self.isHiddenBottomSubScript) {
        [self.view addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.leading.equalTo(self.view);
            make.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }else{
        [self.view addSubview:self.bottomSunView];
        
        [self.bottomSunView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(210);
            make.leading.equalTo(self.view);
            make.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        }];
        [self.view addSubview:self.tableView];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.leading.equalTo(self.view);
            make.trailing.equalTo(self.view);
            make.bottom.equalTo(_bottomSunView.mas_top);
            
        }];
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF2F2F7)];
        [self.bottomSunView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottomSunView);
            make.leading.equalTo(self.bottomSunView);
            make.trailing.equalTo(self.bottomSunView);
            
            make.height.mas_offset(5);
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
            make.top.equalTo(self.bottomSunView).offset(20);
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
        self.confirmBottomTitleLabel.text = @"3-day Free Trial";
        self.confirmBottomTitleLabel.textAlignment = NSTextAlignmentCenter;
        [confirmbgView addSubview:self.confirmBottomTitleLabel];
        [_confirmBottomTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_confirmTopTitleLabel.mas_bottom);
            make.centerX.equalTo(confirmbgView);
        }];
        
        UIButton *startBuyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        startBuyButton.tag = 1939;

        [startBuyButton addTarget:self action:@selector(top_startSubscriptionClick:) forControlEvents:UIControlEventTouchUpInside];
        [confirmbgView addSubview:startBuyButton];
        [startBuyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(confirmbgView);
            make.top.equalTo(confirmbgView);
            make.leading.equalTo(confirmbgView);
            make.bottom.equalTo(confirmbgView);
        }];
        
        
        NSString *plistsPath =  [[TOPDocumentHelper top_appBoxDirectory] stringByAppendingPathComponent:TOP_TRPlistsString];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistsPath]) {
            [TOPWHCFileManager top_createDirectoryAtPath:plistsPath];
        }
        NSMutableArray*localArrays = [NSMutableArray arrayWithArray:[NSArray arrayWithContentsOfFile:[plistsPath stringByAppendingFormat:@"/SaveSubscriptionProductList.plist"]]];
        if (!localArrays.count) {
//            [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_loading", @"")];
//            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
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
        }else{
            startBuyButton.userInteractionEnabled = YES;

            self.confirmTopTitleLabel.text = NSLocalizedString(@"topscan_questioncontinue", @"");
            self.confirmBottomTitleLabel.text = NSLocalizedString(@"topscan_nofreetrial", @"");
            for (int i = 0; i < localArrays.count; i++) {
                TOPPurchasepayModel *purModel = [TOPPurchasepayModel mj_objectWithKeyValues:localArrays[i]];
                [self.productsArrays addObject:purModel];
                [self top_updateProductItemWithModel:purModel];
            }
        }
        [self top_validateProductIdentifiers:@[InAppProductIdSubscriptionMonth,InAppProductIdSubscriptionYear]];

        
    }
}
#pragma mark --右边的反馈按钮
- (void)top_setRightItem{
    //添加导航右边的按钮
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn setImage:[UIImage imageNamed:@"top_detailRight"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(top_sendFeedback) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
}
#pragma mark -- Send feedback
- (void)top_sendFeedback{
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


// 自定义方法
- (void)top_validateProductIdentifiers:(NSArray *)productIdentifiers
{
    self.productsRequest = [[SKProductsRequest alloc]
                            initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    self.productsRequest .delegate = self;
    [self.productsRequest  start];
}

// SKProductsRequestDelegate 代理方法
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
        purModel.productTitle = formattedPrice;
        purModel.payMoney = [[pro price] floatValue];
        
        if (pro.introductoryPrice) {
            purModel.isFreeTrial = YES;
            purModel.freeTrialTypeUnit = pro.introductoryPrice.subscriptionPeriod.unit;
            purModel.numberOfUnits = pro.introductoryPrice.subscriptionPeriod.numberOfUnits;
            
        }
        if ([[pro productIdentifier] isEqualToString:InAppProductIdSubscriptionYear]) {
            NSNumber *unitPrice =  [NSNumber numberWithFloat:[ pro.price floatValue]/12];
            NSString*formattedUnitPrice = [numberFormatter stringFromNumber:unitPrice];//例如 ￥12.00
            purModel.productSubTitle = [NSString stringWithFormat:@"%@/Mon", formattedUnitPrice];
            purModel.buyType = @"1 Year";
            
        }else if([[pro productIdentifier] isEqualToString:InAppProductIdSubscriptionMonth]){
            purModel.productSubTitle = [NSString stringWithFormat:@"%@/Mon", formattedPrice];
            purModel.buyType = @"1 Month";
        }
        [productHistoryArrays addObject:purModel];
        
    }
    productHistoryArrays = [self soreCustomArray:productHistoryArrays];
    NSMutableArray *newLocalArrays = [NSMutableArray array];
        for ( int i = 0;i< productHistoryArrays.count ;i++) {
            TOPPurchasepayModel *proModel  = productHistoryArrays[i];
            [newLocalArrays addObject:proModel.mj_keyValues];
        }
        [newLocalArrays writeToFile:[plistsPath stringByAppendingFormat:@"/SaveSubscriptionProductList.plist"] atomically:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            ACPDownloadView *downloadView = [self.view viewWithTag:1938];
            downloadView.hidden = YES;
            
            UIButton *startBuyButton = [self.view viewWithTag:1939];
            startBuyButton.userInteractionEnabled = YES;
            UIButton *selectOneProductButton = [self.view viewWithTag:1342];

            selectOneProductButton.userInteractionEnabled = YES;
            UIButton *selectTwoProductButton = [self.view viewWithTag:1343];

            selectTwoProductButton.userInteractionEnabled = YES;
            
            self.confirmTopTitleLabel.text = NSLocalizedString(@"topscan_questioncontinue", @"");
            self.productsArrays = productHistoryArrays;
            for (int i = 0; i < productHistoryArrays.count; i++) {
                TOPPurchasepayModel *purModel =  productHistoryArrays[i];
                [self top_updateProductItemWithModel:purModel];
            }
            
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
    if ([self isPushOrModal]) {
        if (self.purchaseSuecssCloseHomeAlertBlock) {
            self.purchaseSuecssCloseHomeAlertBlock(NO);
        }
        [self.navigationController popViewControllerAnimated:YES];

    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}
#pragma mark- 开始订阅
- (void)top_startSubscriptionClick:(UIButton *)sender
{
    NSLog(@"%s",__func__);
    TOPPurchasepayModel *purModel = self.productsArrays[self.currentProductIndex];
    [TOPJDSKPaymentTools shareInstance].delegate = self;
    [[TOPJDSKPaymentTools shareInstance] top_startBuyNumberWithServer:purModel];
}

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
    if (self.productsArrays.count) {
        [self top_updateProductItemWithModel:self.productsArrays[self.currentProductIndex]];

    }

}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    if (self.productOneView.clipsToBounds) {
        self.productOneView.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF6F6F6)].CGColor;
    }
    if (self.productTwoView.clipsToBounds) {
        self.productTwoView.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF6F6F6)].CGColor;
    }
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
#pragma mark - TableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TOPUnlockFuntionTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPUnlockFuntionTableViewCell class]) forIndexPath:indexPath];
    cell.dictData = self.dataArray[indexPath.section];

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    return headerView;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]init];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary * dictArys = self.dataArray[indexPath.section];

    return [dictArys[@"CellHeight"] floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (UIView *)bottomSunView
{
    if (!_bottomSunView) {
        _bottomSunView = [UIView new];
        _bottomSunView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    }
    return _bottomSunView;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[TOPUnlockFuntionTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPUnlockFuntionTableViewCell class])];
    }
    return _tableView;
}
- (NSMutableArray *)productsArrays
{
    if (!_productsArrays) {
        _productsArrays = [NSMutableArray array];
    }
    return   _productsArrays;
}

#pragma mark- 订阅成功回调
- (void)top_succeedWithsucceedCode:(NSInteger)succeedCode{
    switch (succeedCode) {
        case IAPSucceedCode_ServersSucceed:
        {
            [SVProgressHUD dismiss];
            if (self.purchaseSuecssCloseHomeAlertBlock) {
                self.purchaseSuecssCloseHomeAlertBlock(YES);
            }
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_subscriptsuccessfully", @"")];
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
