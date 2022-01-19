#import "TOPEditPDFViewController.h"
#import "TOPPhotoLongPressView.h"
#import "TOPEditPDFModel.h"
#import "TOPEditPDFHandler.h"
#import "TOPEditPDFViewCell.h"
#import "TOPPDFSettingViewController.h"
#import "TOPChildMoreView.h"
#import "TOPShareDownSizeView.h"
#import "TOPMarkTextInputView.h"
#import "TOPWaterMark.h"
#import "TOPPdfSizeSettingView.h"
#import "TOPDocPasswordView.h"
#import "TOPActionSheetView.h"
#import "TOPPDFSignatureViewController.h"
#import "TOPVerticalSlider.h"

#define Bottom_H 60
#define AddFolder_W 310
#define AddFolder_H 240
#define AddFolderSingle_H 190
#define SSCountScroll 20

@interface TOPEditPDFViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIPrintInteractionControllerDelegate, UICollectionViewDelegateFlowLayout,MFMailComposeViewControllerDelegate,GADBannerViewDelegate,GADFullScreenContentDelegate>
@property (nonatomic, strong)  UICollectionView *collectionView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) TOPPhotoLongPressView *barBootomView;
@property (strong, nonatomic) TOPMarkTextInputView *inputTextView;//文字输入控件
@property (strong, nonatomic) UIView *maskView;//遮罩层
@property (strong, nonatomic) TOPPdfSizeSettingView *pdfSizeView;
@property (nonatomic ,strong) UIView * coverView;
@property (nonatomic, strong) TOPDocPasswordView * passwordView;//密码弹框
@property (strong, nonatomic) UILabel *pageLab;//总页数
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) TOPEditPDFHandler *editPDFHandler;
@property (strong, nonatomic) NSMutableArray *sendNameArray;
@property (nonatomic, assign) BOOL showWaterMark;
@property (copy, nonatomic) NSString *pdfName;
@property (assign, nonatomic) CGFloat compressionRate;
@property (assign, nonatomic) NSInteger pdfSizeType;
@property (assign, nonatomic) NSInteger pdfCompressionIndex;
@property (assign, nonatomic) NSInteger currentPage;
@property (nonatomic, strong) NSMutableArray *signatureData;
@property (nonatomic, assign) BOOL isBoxEnter;
@property (nonatomic, strong) GADBannerView * scBannerView;
@property (nonatomic, strong) GADInterstitialAd *interstitial;
@property (nonatomic, assign) CGFloat adViewH;
@property (nonatomic, assign) BOOL isBanner;
@property (nonatomic, strong) TOPVerticalSlider *scrollIndicator;
@property (nonatomic, assign) BOOL scrollMark;//滑动条拖拽
@end

@implementation TOPEditPDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    self.pdfName = [TOPWHCFileManager top_fileNameAtPath:self.filePath suffix:YES];
    self.isBoxEnter = YES;
    self.isBanner = NO;
    self.adViewH = 0.0;
    [self top_loadAdData];
}
- (void)top_loadAdData{
    CGFloat navH = self.navigationController.navigationBar.frame.size.height;
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![TOPPermissionManager top_enableByAdvertising]) {//展示广告
                    [self top_setupSubViews];
                    [self top_setupData];
                    [self top_addBannerViewWithSize:CGSizeMake(self.view.width, self.view.height-TOPStatusBarHeight-navH)];//横幅广告
                    [self top_getInterstitialAd];//插页广告
                }else{
                    [self top_setupSubViews];
                    [self top_setupData];
                }
            });
        }];
    } else {
        if (![TOPPermissionManager top_enableByAdvertising]) {//展示广告
            [self top_setupSubViews];
            [self top_setupData];
            [self top_addBannerViewWithSize:CGSizeMake(self.view.width, self.view.height-TOPStatusBarHeight-navH)];//横幅广告
            [self top_getInterstitialAd];//插页广告
        }else{
            [self top_setupSubViews];
            [self top_setupData];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self top_initNavBar];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    if (_barBootomView) {
        BOOL show = ![TOPPermissionManager top_enableByPDFPageNO];
        [_barBootomView top_refreshLogoShow:show];
    }
    self.title = self.pdfName;
    [self.navigationController setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    if (self.selectModel&&self.isBoxEnter) {
        self.isBoxEnter = NO;
        if (self.selectModel.functionType == TopFunctionTypePDFSignature) {
            [FIRAnalytics logEventWithName:@"EditPDFVC_pdfSignature" parameters:nil];
            __weak typeof(self) weakSelf = self;
            TOPPDFSignatureViewController *signVC = [[TOPPDFSignatureViewController alloc] init];
            signVC.filePath = self.filePath;
            if (self.signatureData.count) {
                signVC.dataArray = [self.signatureData mutableCopy];
            }
            if (self.imagePathArr) {
                signVC.imagePathArr = self.imagePathArr;
            }
            signVC.top_savePDFSignatureBlock = ^(NSMutableArray * _Nonnull arr) {
                weakSelf.signatureData = [arr mutableCopy];//保存签名数据
                weakSelf.dataArray = [arr mutableCopy];
                weakSelf.editPDFHandler.tempData = weakSelf.dataArray;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            };
            signVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:signVC animated:NO];
        }else if (self.selectModel.functionType == TopFunctionTypePDFAddWatermark){
            [self top_addWaterMark];
        }else if(self.selectModel.functionType == TopFunctionTypePDFPassword){
            NSString *pass = [TOPScanerShare top_pdfPassword];
            if ([pass length]) {
                [[TOPCornerToast shareInstance] makeToast:[NSString stringWithFormat:@"%@ %@",[NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"],pass]];
            } else {
                [self top_showPasswordView];
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark -- 横竖屏切换时重新设置titleView
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self top_restoreBannerAD:size];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self top_restoreBannerAD:size];
}
- (void)top_restoreBannerAD:(CGSize)size{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self top_changeBannerViewFream:size];
            });
        }];
    } else {
        [self top_changeBannerViewFream:size];
    }
}
- (void)top_removeBannerView{
    [self.scBannerView removeFromSuperview];
    self.scBannerView = nil;
}
- (void)top_changeBannerViewFream:(CGSize)size{
    if (![TOPPermissionManager top_enableByAdvertising]) {//展示广告
        [self top_removeBannerView];
        [self top_addBannerViewWithSize:size];
    }
}
#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];

    if (_passwordView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_H, AddFolder_W, AddFolder_H);
        }];
    }
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    if (![_passwordView.tField isFirstResponder]&&![_passwordView.againField isFirstResponder]) {
        [self top_tapAction];
    }
}
#pragma mark -- 导航栏
- (void)top_initNavBar {
    self.navigationController.navigationBar.titleTextAttributes=
    @{NSForegroundColorAttributeName:[UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:kBlackColor],
    NSFontAttributeName:[UIFont systemFontOfSize:18]};
    //导航栏背景色
    [self.navigationController.navigationBar setBarTintColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor]];
    if (isRTL()) {//黑色
        [self top_setBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_setBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    [self top_setRightButtons:@[@"top_pdf_setting",@"top_pdf_share"]];
}


- (void)top_setBackButton:(nullable NSString *)imgName withSelector:(SEL)selector {
    TOPImageTitleButton * btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
    btn.frame = CGRectMake(0, 0, 44, 44);
    if (isRTL()) {
        btn.style = EImageLeftTitleRightCenter;
    }else{
        btn.style = EImageLeftTitleRightLeft;
    }
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

- (void)top_setRightButtons:(NSArray *)imgNames {
    if (imgNames.count) {
        NSString *imgName = imgNames[0];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(top_pdfSetting) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        NSString *imgName2 = imgNames[1];
        UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
        [btn2 setImage:[UIImage imageNamed:imgName2] forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(top_pdfShare) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barItem2 = [[UIBarButtonItem alloc] initWithCustomView:btn2];
        
        self.navigationItem.rightBarButtonItems = @[barItem,barItem2];
    }
}

- (void)top_setupSubViews {
    [self.contentView addSubview:self.collectionView];
    [self top_editPDFMenuBottomView];
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
}

- (void)top_setupData {
    self.currentPage = 0;
    self.pdfSizeType = [TOPScanerShare top_pageSizeType];
    CGRect current = [TOPDocumentHelper top_getPdfsizeWithType:[TOPScanerShare top_pageSizeType]];
    self.compressionRate = 1.0;
    self.pdfCompressionIndex = 0;
    if ([TOPWHCFileManager top_isExistsAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]]) {
        [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]];
    }
    [TOPWHCFileManager top_removeItemAtPath:TOPCompress_Path];
    self.editPDFHandler = [[TOPEditPDFHandler alloc] init];
    self.editPDFHandler.filePath = self.filePath;
    self.editPDFHandler.imagePathArr = self.imagePathArr;
    self.editPDFHandler.aspectRatio = CGRectGetHeight(current) / CGRectGetWidth(current);
    [self top_refreshPDF];
}

- (void)top_refreshPDF {
    NSArray *temp = self.imagePathArr.count ? self.imagePathArr : [TOPDocumentHelper top_showPicArrayAtPath:self.filePath];
    if (temp.count > 200) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.signatureData.count) {
            self.editPDFHandler.signatureData = self.signatureData;
        }
        self.dataArray = [self.editPDFHandler setupPdfDatasProgress:^(CGFloat myProgress) {
            [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [self.collectionView reloadData];
            if (self.dataArray.count > SSCountScroll) {
                self.scrollIndicator.hidden = YES;
                self.scrollIndicator.itemCount = self.dataArray.count;
            }
        });
    });
}

#pragma mark -- 菜单栏
- (void)top_editPDFMenuBottomView {
    TOPPhotoLongPressView *pressBootomView = [[TOPPhotoLongPressView alloc] initWithFrame:CGRectZero withBarItems:[self tabbarItems]];
    WS(weakSelf);
    pressBootomView.top_longPressBootomItemHandler = ^(NSInteger index) {
        [FIRAnalytics logEventWithName:@"top_longPressBootomItemHandler" parameters:@{@"longPress":@(index)}];
        [weakSelf top_pressBottomViewWithIndex:index];
    };
    [self.view addSubview:pressBootomView];
    self.barBootomView = pressBootomView;
    if (!self.isBanner) {
        [pressBootomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
            make.height.mas_equalTo(Bottom_H);
        }];
    }else{
        [self.barBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
            make.height.mas_equalTo(Bottom_H);
        }];
    }
    
}

- (NSMutableArray *)tabbarItems {
    NSArray *tools = [self toolItems];
    NSArray * sendPicArray = @[@"top_pdf_size",@"top_pdf_watermark",@"top_pdf_signature",@"top_pdf_compress",@"top_downview_moreFun"];
    NSMutableArray *temp = @[].mutableCopy;
    for (int i = 0; i < tools.count; i ++) {
        TOPTabBarModel *model = [[TOPTabBarModel alloc] init];
        model.functionType = [tools[i] integerValue];
        if (model.functionType == TOPEditPDFFunctionTypeWaterMark) {
            model.showVip = ![TOPPermissionManager top_enableByPDFWaterMark];
        } else if (model.functionType == TOPEditPDFFunctionTypeSignature) {
            model.showVip = ![TOPPermissionManager top_enableByPDFSignature];
        } else {
            model.showVip = NO;
        }
        model.icon = sendPicArray[i];
        model.title = self.sendNameArray[i];
        model.isSelected = NO;
        [temp addObject:model];
    }
    return temp;
}

- (NSArray *)toolItems {
    NSArray *tools = @[@(TOPEditPDFFunctionTypePaperSize),
                       @(TOPEditPDFFunctionTypeWaterMark),
                       @(TOPEditPDFFunctionTypeSignature),
                       @(TOPEditPDFFunctionTypeCompress),
                       @(TOPEditPDFFunctionTypeMore)];
    
    return tools;
}

#pragma mark -- 菜单执行事件
- (void)top_pressBottomViewWithIndex:(NSInteger)index {
    NSInteger toolType = [[self toolItems][index] integerValue];
    switch (toolType) {
        case TOPEditPDFFunctionTypePaperSize:
            [self top_pdfPaperSize];
            break;
        case TOPEditPDFFunctionTypeWaterMark:
            [self top_pdfWaterMark];
            break;
        case TOPEditPDFFunctionTypeSignature:
            [self top_pdfSignature];
            break;
        case TOPEditPDFFunctionTypeCompress:
            [self top_pdfCompression];
            break;
        case TOPEditPDFFunctionTypeMore:
            [self top_pdfFunctionMore];
            break;
        
        default:
            break;
    }
}

#pragma mark -- 返回
- (void)top_backHomeAction {
    [self top_updateDocumentNameComplete:^{
        if (self.selectModel) {
            if (self.backRefresh) {
                [self top_backAndBlockAction];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{
            [self top_backAndBlockAction];
        }
    } ];
}

- (void)top_backAndBlockAction{
    if (self.top_backBtnAction) {
        self.top_backBtnAction();
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 没有蜂窝数据时点击分享时给出的弹框
- (void)top_showCellularView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    TOPCellularView *cellularView = [[TOPCellularView alloc]init];
    cellularView.top_settingBlock = ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    };
    [keyWindow addSubview:cellularView];
    [cellularView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}
#pragma mark -- 分享时判断有没有手动关闭app的蜂窝数据
- (void)top_pdfShare {
    [FIRAnalytics logEventWithName:@"EditPDFVC_pdfShare" parameters:nil];
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self top_showPdfShareView];
        }
    }];
}
#pragma mark -- 分享
- (void)top_showPdfShareView{
    NSNumber *totalSize = [self fileSize];
    CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
    if (freeSize < [totalSize floatValue]/1024.0/1024.0 +5) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
        return;
    }
    if ([totalSize floatValue] >= (1024 * 1024) && self.compressionRate == 1) {
        [self top_compressImagesToSharePDF:totalSize];
    } else {
        __weak typeof(self) weakSelf = self;
        [self top_createPDFSuccess:^(NSString *path) {
            NSURL *file = [NSURL fileURLWithPath:path];
            [weakSelf top_showShareView:@[file]];
        }];
    }
}
#pragma mark -- 先压缩图片 然后分享
- (void)top_compressImagesToSharePDF:(NSNumber *)totalSize {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    WS(weakSelf);
    NSArray * titleArray = @[NSLocalizedString(@"topscan_originalsize", @""),NSLocalizedString(@"topscan_medium", @""),NSLocalizedString(@"topscan_small", @"")];
    TOPShareDownSizeView * sizeView = [[TOPShareDownSizeView alloc]initWithTitleView:[UIView new] optionsArr:titleArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
         
    }  selectItemBlock:^(CGFloat rate) {
        [weakSelf top_pdfCompressAndShare:rate];
    }];
    sizeView.compressType = 0;
    sizeView.childArray = weakSelf.dataArray;
    sizeView.totalNum = [totalSize floatValue];
    sizeView.numberStr = [TOPDocumentHelper top_memorySizeStr:[totalSize floatValue]];
    sizeView.pdfPath = weakSelf.filePath;
    [window addSubview:sizeView];
    [sizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(window);
    }];
}

- (void)top_pdfCompressAndShare:(CGFloat)rate {
    self.compressionRate = rate;
    if (rate < 1.0) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingjpg", @"")]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int i = 0;
            for (TOPEditPDFModel *model in self.dataArray) {
                i ++;
                [TOPDocumentHelper top_saveCompressPDFImage:model.imagePath maxCompression:rate];
                CGFloat myProgress = (i * 10.0) / (self.dataArray.count * 10.0);
                [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingjpg", @"")]];
            }
            if ([TOPWHCFileManager top_isExistsAtPath:TOPCompress_Path]) {
                self.editPDFHandler.filePath = TOPCompress_Path;
                self.dataArray = [self.editPDFHandler setupPdfDatasProgress:^(CGFloat myProgress) {
                }];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                __weak typeof(self) weakSelf = self;
                [self top_createPDFSuccess:^(NSString *path) {
                    NSURL *file = [NSURL fileURLWithPath:path];
                    [weakSelf top_showShareView:@[file]];
                }];
            });
        });
    } else {
        __weak typeof(self) weakSelf = self;
        [self top_createPDFSuccess:^(NSString *path) {
            NSURL *file = [NSURL fileURLWithPath:path];
            [weakSelf top_showShareView:@[file]];
        }];
    }
}

#pragma mark -- 弹出分享视图
- (void)top_showShareView:(NSArray *)pdfArray {
    UIActivityViewController * activityVC = [[UIActivityViewController alloc]initWithActivityItems:pdfArray applicationActivities:nil];
    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    activityVC.excludedActivityTypes = excludedActivityTypes;
    if (IS_IPAD) {
        activityVC.popoverPresentationController.sourceView = self.view;
        activityVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark -- 设置
- (void)top_pdfSetting {
    [FIRAnalytics logEventWithName:@"EditPDFVC_pdfSetting" parameters:nil];
    __weak typeof(self) weakSelf = self;
    TOPPDFSettingViewController *settingVC = [[TOPPDFSettingViewController alloc] init];
    settingVC.pdfName = self.pdfName;
    settingVC.signatureArr = [NSArray arrayWithArray:self.signatureData];
    settingVC.top_editPDFNameBlock = ^(NSString * _Nonnull name) {
        weakSelf.pdfName = name;
    };
    settingVC.top_editPDFDirectionBlock = ^{
        [weakSelf.signatureData removeAllObjects];
        [weakSelf top_refreshPDF];
    };
    settingVC.top_editPDFNumLayoutBlock = ^{
        [weakSelf.signatureData removeAllObjects];
        [weakSelf top_refreshPDF];
    };
    settingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)top_updateDocumentNameComplete:(void (^)(void))success {
    NSString *oldName = [TOPWHCFileManager top_fileNameAtPath:self.filePath suffix:YES];
    NSString *name = self.pdfName;
    if ([oldName isEqualToString:self.pdfName]) {
        if (success) {
            success();
        }
    } else {
        [SVProgressHUD show];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *newDocPath = [[TOPWHCFileManager top_directoryAtPath:self.filePath] stringByAppendingPathComponent:name];
            [TOPDocumentHelper top_moveFileItemsAtPath:self.filePath toNewFileAtPath:newDocPath];
            [TOPEditDBDataHandler top_editDocumentName:name withId:self.docModel.docId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if (self.top_editDocNameBlock) {
                    self.top_editDocNameBlock(newDocPath);
                }
                if (success) {
                    success();
                }
            });
        });
    }
}

#pragma mark -- 纸张大小
- (void)top_pdfPaperSize {
    [FIRAnalytics logEventWithName:@"EditPDFVC_pdfPaperSize" parameters:nil];
    [self top_pdfSizeViewShowAction];
}

#pragma mark -- pdf尺寸设置
- (void)top_pdfSizeViewShowAction {
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    if (![keyWindow.subviews containsObject:self.coverView]) {
        [keyWindow addSubview:self.coverView];
        [self top_makeCoverView];
    }
    
    if (![keyWindow.subviews containsObject:self.pdfSizeView]) {
        [keyWindow addSubview:self.pdfSizeView];
        [self top_makePdfSizeView];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.alpha = 0.5;
            [self top_remakeCoverView];
            [self top_remakePdfSizeView];
            [keyWindow layoutIfNeeded];
        }];
    });
}

#pragma mark -- 去订阅
- (void)top_subscriptionService {
    if ([TOPAppTools needShowDiscountThemeView]) {
        [[TOPDiscountThemeView shareInstance] top_showDiscountTheme:@"20211123_year_sub"];
        return;
    } 
    TOPSubscriptionPayListViewController * generalVC = [[TOPSubscriptionPayListViewController alloc] init];
    generalVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:generalVC animated:YES];
}

#pragma mark -- 水印
- (void)top_pdfWaterMark {
    [FIRAnalytics logEventWithName:@"EditPDFVC_pdfWaterMark" parameters:nil];
    if (![TOPPermissionManager top_enableByPDFWaterMark]) {
        [self top_subscriptionService];
        return;
    }
    [self top_addWaterMark];
}

#pragma mark -- 签名
- (void)top_pdfSignature {
    [FIRAnalytics logEventWithName:@"EditPDFVC_pdfSignature" parameters:nil];
    __weak typeof(self) weakSelf = self;
    TOPPDFSignatureViewController *signVC = [[TOPPDFSignatureViewController alloc] init];
    signVC.filePath = self.filePath;
    if (self.signatureData.count) {
        signVC.dataArray = [self.signatureData mutableCopy];
    }
    if (self.imagePathArr) {
        signVC.imagePathArr = self.imagePathArr;
    }
    signVC.top_savePDFSignatureBlock = ^(NSMutableArray * _Nonnull arr) {
        weakSelf.signatureData = [arr mutableCopy];//保存签名数据
        weakSelf.dataArray = [arr mutableCopy];
        weakSelf.editPDFHandler.tempData = weakSelf.dataArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    };
    signVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:signVC animated:YES];
}

#pragma mark -- 加密
- (void)top_pdfPassword {
    [FIRAnalytics logEventWithName:@"EditPDFVC_pdfPassword" parameters:nil];
    NSString *pass = [TOPScanerShare top_pdfPassword];
    if ([pass length]) {//已经设置了密码
        [TOPScanerShare top_writePDFPassword:@""];
        [[TOPCornerToast shareInstance] makeToast:[NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"]];
    } else {
        [self top_showPasswordView];
    }
}

- (void)top_addPassword:(NSString *)password {
    [TOPScanerShare top_writePDFPassword:password];
    [[TOPCornerToast shareInstance] makeToast:[NSString stringWithFormat:@"%@ %@",[NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"], password]];
}

#pragma mark -- 创建密码
- (void)top_showPasswordView {
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    if (!_coverView) {
        [keyWindow addSubview:self.coverView];
        [self top_makeCoverView];
    }
    if (!_passwordView) {
        self.passwordView.actionType = TOPHomeMoreFunctionPDFPassword;
        [keyWindow addSubview:self.passwordView];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha = 0.4;
        [self top_remakeCoverView];
        [self.passwordView top_beginEditing];
    }];
}

#pragma mark -- 添加/删除水印
- (void)top_addWaterMark {
    if (![TOPWHCFileManager top_isExistsAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]]) {
        [self top_showInputView];
    } else {
        [self top_removeWaterMark];
    }
}

- (void)top_removeWaterMark {
    self.showWaterMark = NO;
    [self.collectionView reloadData];
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]];
    self.sendNameArray[1] = NSLocalizedString(@"topscan_addwatermark", @"");
    self.barBootomView.funcTitles = self.sendNameArray;
}

#pragma mark -- 设置水印文字
- (NSString *)markText {
    NSString *markText = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRWatermarkTextkey];
    if (!markText) {
        markText = @"";
    }
    return markText;
}

- (void)top_setMarkTextColor:(UIColor *)textColor {
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:textColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:TOP_TRWatermarkTextColorKey];
}

#pragma mark -- 弹出输入框、键盘
- (void)top_showInputView {
    self.maskView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 1.5);
    self.inputTextView.textFld.text = [self markText];
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRWatermarkTextColorKey];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    self.inputTextView.currentColor = color;
    [self.maskView addSubview:self.inputTextView];
    [UIView animateWithDuration:0.3
                     animations:^{
        self.maskView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
        [self.inputTextView top_beginEditing];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -- 输入控件消失
- (void)top_hiddenInputView {
    [UIView animateWithDuration:0.3
                     animations:^{
        self.maskView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 1.5);
    } completion:^(BOOL finished) {
        [self.inputTextView removeFromSuperview];
        self.inputTextView = nil;
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }];
}

- (void)top_createWaterMarkImage:(NSString *)text textColor:(UIColor *)textColor fontValue:(CGFloat)fontValue opacity:(CGFloat)opacity {
    [self top_setMarkTextColor:textColor];
    [[NSUserDefaults standardUserDefaults] setObject:text forKey:TOP_TRWatermarkTextkey];
    [[NSUserDefaults standardUserDefaults] setFloat:fontValue forKey:TOP_TRWatermarkTextFontValueKey];
    [[NSUserDefaults standardUserDefaults] setFloat:opacity forKey:TOP_TRWatermarkTextOpacityKey];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat v_width = (TOPScreenWidth - 15 * 2) * scale;
    UIImageView *waterMarkView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, v_width, v_width * 106.0/75.0)];
    [TOPWaterMark view:waterMarkView WaterImageWithImage:[UIImage imageNamed:@""] text:text];
    self.showWaterMark = YES;
    [self.collectionView reloadData];
    self.sendNameArray[1] = NSLocalizedString(@"topscan_removewatermark", @"");
    self.barBootomView.funcTitles = self.sendNameArray;
}

- (NSNumber *)fileSize {
    if (self.docModel.docId) {
        long size = [TOPDBDataHandler top_sumDocumentsFileSize:@[self.docModel.docId]];
        return @(size);
    } else {
        NSMutableArray *temp = @[].mutableCopy;
        NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:self.filePath deep:NO];
        for (NSString *tempContentPath in tempContentsArray) {
            if ([TOPDocumentHelper top_isCoverJPG:tempContentPath]) {
                NSString *jpgFile = [self.filePath stringByAppendingPathComponent:tempContentPath];
                [temp addObject:jpgFile];
            }
        }
        CGFloat size = [TOPDocumentHelper top_totalMemorySize:temp];
        return @(size);;
    }
}

#pragma mark -- 压缩
- (void)top_pdfCompression {
    [FIRAnalytics logEventWithName:@"EditPDFVC_pdfCompression" parameters:nil];
    [self top_chooseCompressionType];
}

- (void)top_chooseCompressionType {
    [FIRAnalytics logEventWithName:@"chooseCompressionType" parameters:nil];
    NSNumber *totalSize = [self fileSize];
    UIWindow * window = [UIApplication sharedApplication].windows[0];
    
    NSArray * titleArray = @[[NSString stringWithFormat:@"%@ (%@)",NSLocalizedString(@"topscan_originalsize", @""), [TOPDocumentHelper top_memorySizeStr:[totalSize floatValue]]],
                             [NSString stringWithFormat:@"%@ (%@ %@)",NSLocalizedString(@"topscan_medium", @""), NSLocalizedString(@"topscan_about", @""),[TOPDocumentHelper top_memorySizeStr:[totalSize floatValue] * 0.7]],
                             [NSString stringWithFormat:@"%@ (%@ %@)",NSLocalizedString(@"topscan_small", @"") , NSLocalizedString(@"topscan_about", @""),[TOPDocumentHelper top_memorySizeStr:[totalSize floatValue] * 0.5]]];
    WS(weakSelf);
    NSArray *rates = @[@(1.0), @(0.7), @(0.5)];
    TOPActionSheetView *action = [[TOPActionSheetView alloc] initWithTitleView:[UIView new] optionsArr:titleArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
           
    } selectBlock:^(NSInteger index) {
        weakSelf.pdfCompressionIndex = index;
        CGFloat rate = [rates[index] floatValue];
        [weakSelf top_imagesCompress:rate];
    }];
    action.drawIndex = self.pdfCompressionIndex;
    [window addSubview:action];
    [action mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(window);
    }];
}

#pragma mark -- 根据所选压缩系数压缩图片并刷新界面
- (void)top_imagesCompress:(CGFloat)rate {
    self.compressionRate = rate;
    if (rate < 1.0) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingjpg", @"")]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int i = 0;
            for (TOPEditPDFModel *model in self.dataArray) {
                i ++;
                [TOPDocumentHelper top_saveCompressPDFImage:model.imagePath maxCompression:rate];
                CGFloat myProgress = (i * 10.0) / (self.dataArray.count * 10.0);
                [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingjpg", @"")]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                if ([TOPWHCFileManager top_isExistsAtPath:TOPCompress_Path]) {
                    self.editPDFHandler.filePath = TOPCompress_Path;
                    [self top_refreshPDF];
                }
            });
        });
    } else {
        self.editPDFHandler.filePath = self.filePath;
        [self top_refreshPDF];
    }
}

#pragma mark -- 更多
- (void)top_pdfFunctionMore {
    [FIRAnalytics logEventWithName:@"EditPDFVC_pdfFunctionMore" parameters:nil];
    NSString *passwordTitle = [[TOPScanerShare top_pdfPassword] length] ? NSLocalizedString(@"topscan_pdfpasswordclear", @"") : NSLocalizedString(@"topscan_pdfpassword", @"");
    NSArray *titleArray = @[NSLocalizedString(@"topscan_fax", @""), NSLocalizedString(@"topscan_printing", @""), passwordTitle];
    NSArray *iconArray = @[@"top_homeFa", @"top_photoshow_printing", @"top_menu_pdfPassword"];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    __weak typeof(self) weakSelf = self;
    TOPChildMoreView * moreView = [[TOPChildMoreView alloc]initWithTitleView:[UIView new] optionsArr:titleArray iconArr:iconArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
        
    } selectBlock:^(NSInteger index) {
        [weakSelf top_editPDF_ClickMoreViewAction:index];
    }];
    
    [window addSubview:moreView];
}

- (NSArray *)homeMoreArray {
    return @[@(TOPEditPDFMoreMenuFax), @(TOPEditPDFMoreMenuPrint), @(TOPEditPDFMoreMenuPassword)];
}


#pragma mark -- 底部更多视图点击
- (void)top_editPDF_ClickMoreViewAction:(NSInteger)index{
    [FIRAnalytics logEventWithName:@"EditPDFVC_ClickMoreViewAction" parameters:@{@"index":@(index)}];
    NSNumber * num = self.homeMoreArray[index];
    switch ([num integerValue]) {
        case TOPEditPDFMoreMenuFax:
            [self top_pdfFax];
            break;
        case TOPEditPDFMoreMenuPrint:
            [self top_pdfPrint];
            break;
        case TOPEditPDFMoreMenuPassword:
            [self top_pdfPassword];
            break;
        default:
            break;
    }
}

#pragma mark -- pdf传真
- (void)top_pdfFax {
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [FIRAnalytics logEventWithName:@"editPDF_FaxTip" parameters:nil];
            [self top_createNOPasswordPDFSuccess:^(NSString *path) {
                [TOPDocumentHelper top_jumpToSimpleFax:path];
            }];
        }
    }];
}

#pragma mark -- pdf打印
- (void)top_pdfPrint {
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [FIRAnalytics logEventWithName:@"EditPDFVC_pdfPrint" parameters:nil];
            //先生成pdf再打印
            __weak typeof(self) weakSelf = self;
            [self top_createNOPasswordPDFSuccess:^(NSString *path) {
                [weakSelf top_showPrintVC:path];
            }];
        }
    }];
}

#pragma mark -- 生成pdf不带加密
- (void)top_createNOPasswordPDFSuccess:(nonnull void (^)(NSString *path))success {
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //先清空pdf文件夹里的内容
        [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
        NSMutableArray * imgArray = [[NSMutableArray alloc] init];
        NSString * pdfName = self.pdfName;
        for (TOPEditPDFModel * model in self.dataArray) {
            UIImage * img = [UIImage imageWithContentsOfFile:model.imagePath];
            if (img) {
                [imgArray addObject:img];
            }
        }
        //合成pdf
        NSString * pdfPath = [self.editPDFHandler top_creatNOPasswordPDF:imgArray documentName:pdfName progress:^(CGFloat myProgress) {
            [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
        }];
        self.editPDFHandler.filePath = self.filePath;
        if (self.signatureData.count) {
            self.editPDFHandler.signatureData = self.signatureData;
        }
        self.dataArray = [self.editPDFHandler setupPdfDatasProgress:^(CGFloat myProgress) {
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            success(pdfPath);
        });
    });
}

#pragma mark -- 生成pdf支持加密
- (void)top_createPDFSuccess:(nonnull void (^)(NSString *path))success {
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //先清空pdf文件夹里的内容
        [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
        NSMutableArray * imgArray = [[NSMutableArray alloc] init];
        NSString * pdfName = self.pdfName;
        for (TOPEditPDFModel * model in self.dataArray) {
            UIImage * img = [UIImage imageWithContentsOfFile:model.imagePath];
            if (img) {
                [imgArray addObject:img];
            }
        }
        //合成pdf
        NSString * pdfPath = [self.editPDFHandler top_creatPDF:imgArray documentName:pdfName progress:^(CGFloat myProgress) {
            [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
        }];
        //
        self.editPDFHandler.filePath = self.filePath;
        if (self.signatureData.count) {
            self.editPDFHandler.signatureData = self.signatureData;
        }
        self.dataArray = [self.editPDFHandler setupPdfDatasProgress:^(CGFloat myProgress) {
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            success(pdfPath);
        });
    });
}

- (void)top_showPrintVC:(NSString *)itemPath {
    NSData * imgData = [NSData dataWithContentsOfFile:itemPath];
    if (!imgData) {
        [FIRAnalytics logEventWithName:@"EditPDF_top_showPrintVCNoData" parameters:nil];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_savefail", @"")];
        [SVProgressHUD dismissWithDelay:1];
        return;
    }
    UIPrintInteractionController * printVC = [UIPrintInteractionController sharedPrintController];
    if (printVC) {
        UIPrintInfo * printInfo = [UIPrintInfo printInfo];
        //打印输出类型
        printInfo.outputType = UIPrintInfoOutputGeneral;
        //默认应用程序名称
        printInfo.jobName = @"PDF";
        //双面打印信息，NONE为双面禁止
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        //打印纵向还是横向
        printInfo.orientation = UIPrintInfoOrientationPortrait;
        printVC.printInfo = printInfo;
        printVC.delegate = self;
        printVC.printingItems = @[imgData];
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                NSLog(@"FAILED! due to error in domain %@ with error code %lu", error.domain, error.code);
            }
        };
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            
            [printVC presentFromRect:self.view.frame inView:self.view animated:YES completionHandler:completionHandler];
        }
        else {
            [printVC presentAnimated:YES completionHandler:completionHandler];
        }
    }
}

#pragma mark -- 隐藏手势点击事件
- (void)top_tapAction{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [UIView animateWithDuration:0.3 animations:^{
        if (self->_coverView) {
            [self top_remakeCoverViewDefault];
        }
        if (self->_pdfSizeView) {
            [self top_remakePdfSizeViewDefault];
        }
        if (self->_passwordView) {
            [self.passwordView top_hiddenkeyboard];
            [self.passwordView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(keyWindow);
                make.top.equalTo(keyWindow.mas_bottom);
                make.width.mas_equalTo(310);
                make.height.mas_equalTo(260);
            }];
        }
        [keyWindow layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.coverView removeFromSuperview];
        [self.passwordView removeFromSuperview];
        [self.pdfSizeView removeFromSuperview];

        self.coverView = nil;
        self.passwordView = nil;
        self.pdfSizeView = nil;
    }];
}

#pragma mark -- 重新生成选择尺寸对应的pdf
- (void)top_choosePdfSizeAndCreat:(TOPPdfSizeModel *)model {
    if (self.signatureData.count) {
        [self top_deleteSignatureAlert:model];
    } else {
        [self top_refreshPDFWithNewSize:model];
    }
}

- (void)top_refreshPDFWithNewSize:(TOPPdfSizeModel *)model {
    [TOPScanerShare top_writePageSizeType:model.pdfType];
    CGFloat pdfRate = (model.pdfSizeH * 10.0) / (model.pdfSizeW * 10.0);
    NSDecimalNumber *newRate = [TOPAppTools Rounding:pdfRate afterPoint:3];
    NSDecimalNumber *oldRate = [TOPAppTools Rounding:self.editPDFHandler.aspectRatio afterPoint:3];
    if ([newRate compare:oldRate] != NSOrderedSame) {
        [self.signatureData removeAllObjects];
        self.editPDFHandler.aspectRatio = pdfRate;
        [self top_refreshPDF];
    } else {
        if (self.signatureData.count) {
            [self.signatureData removeAllObjects];
            [self top_refreshPDF];
        }
    }
}

#pragma mark -- 删除签名提示
- (void)top_deleteSignatureAlert:(TOPPdfSizeModel *)model {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_changepdfsizealert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_yes", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        
        [self top_refreshPDFWithNewSize:model];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_no", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:nil];
        [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.1];
        [self didScroll];
    }
    if (self.scrollMark) {
        self.pageLab.text = [NSString stringWithFormat:@" %@/%@ ",self.scrollIndicator.valueLabel.text,@(self.dataArray.count)];
        return;
    }
    if (self.currentPage < self.dataArray.count) {
        NSInteger page = 1;
        NSArray *items = [self.collectionView indexPathsForVisibleItems];
        if (items.count == 1) {
            page = self.currentPage + 1;
        } else {
            NSArray *sortItems = [items sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *indexPath1, NSIndexPath *indexPath2) {
                if (indexPath1.item > indexPath2.item) {
                    return NSOrderedDescending;
                } else {
                    return  NSOrderedAscending;
                }
            }];
            NSIndexPath *indexPath = [sortItems lastObject];
            UICollectionViewCell *lastCell = [self.collectionView cellForItemAtIndexPath:indexPath];
            if (lastCell) {
                CGRect cellRect = [self.collectionView convertRect:lastCell.frame toView:_collectionView];
                CGRect rectInSuperview = [self.collectionView convertRect:cellRect toView:self.view];
                if ((rectInSuperview.origin.y + lastCell.frame.size.height / 2) <= (TOPScreenHeight - Bottom_H - TOPBottomSafeHeight)) {
                    page = indexPath.item + 1;
                } else {
                    page = indexPath.item;
                }
            } else {
                return;
            }
        }
        if (self.dataArray.count > 1) {
            self.currentPage = page - 1;
            self.pageLab.text = [NSString stringWithFormat:@" %@/%@ ",@(page),@(self.dataArray.count)];
        }
    }
}

#pragma mark - UICollectionViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        return self.contentView;
    }
    return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        CGFloat centerX = scrollView.center.x, centerY = scrollView.center.y;
        centerX = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : centerX;
        centerY = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : centerY;
        [self.contentView setCenter:CGPointMake(centerX, centerY)];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (scrollView == self.scrollView) {
        if (scale > 1.0) {
            self.collectionView.showsVerticalScrollIndicator = NO;
        } else {
            self.collectionView.showsVerticalScrollIndicator = YES;
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:nil];
    [self didEndDecelerating];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TOPEditPDFViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPEditPDFViewCell class]) forIndexPath:indexPath];
    cell.contentView.backgroundColor = kWhiteColor;
    TOPEditPDFModel *picModel = self.dataArray[indexPath.item];
    [cell top_configCellWithData:picModel];
    if (self.showWaterMark) {
        [cell top_showWaterMarkView];
    } else {
        [cell top_hiddenWaterMarkView];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TOPEditPDFModel *model = self.dataArray[indexPath.item];
    return model.cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 15, 10, 15);
}

#pragma mark------- 双击
-(void)top_doubleTapAction:(UITapGestureRecognizer *)sender{
    if (self.scrollView.zoomScale == 1.0) {
        [self.scrollView setZoomScale:3.0 animated:YES];
        
    } else {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}

#pragma mark scrollview Delegate block
- (void)didScroll {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endScrollingAnimationDelay) object:nil];
    if (self.dataArray.count <= SSCountScroll) {
        self.scrollIndicator.hidden = YES;
        return;
    }
    if (self.scrollMark) {
        return;
    }
    self.scrollIndicator.hidden = NO;
    self.scrollIndicator.valueLabel.hidden = YES;
    BOOL currentIsInBottom = NO;
    CGFloat height = self.collectionView.frame.size.height;
    CGFloat contentOffsetY = self.collectionView.contentOffset.y;
    CGFloat bottomOffset = self.collectionView.contentSize.height - contentOffsetY;
    if (bottomOffset <= height) { //在最底部
        currentIsInBottom = YES;
    } else {
        currentIsInBottom = NO;
    }
    self.scrollIndicator.value = currentIsInBottom ? 1.0 : contentOffsetY/(self.collectionView.contentSize.height - height);
}

- (void)didEndDecelerating {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endScrollingAnimationDelay) object:nil];
    [self performSelector:@selector(endScrollingAnimationDelay) withObject:nil afterDelay:1.5];
}

#pragma mark 拖动滑块 滚动到指定位置
- (void)scrollToIndex:(float)value {
    self.scrollMark = YES;
    self.scrollIndicator.hidden = NO;
    CGFloat contentHeight = self.collectionView.contentSize.height -  self.collectionView.frame.size.height;
    CGFloat offHeight = value * contentHeight;
    [self.collectionView setContentOffset:CGPointMake(0, offHeight) animated:NO];
    self.scrollIndicator.valueLabel.hidden = YES;
}

#pragma mark 拖动滑块结束
- (void)scrollDidEnd:(float)value {
    self.scrollMark = NO;
    self.scrollIndicator.valueLabel.hidden = YES;
}

- (void)endScrollingAnimationDelay {
    self.scrollIndicator.hidden = YES;
}

#pragma mark -- lazy
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = 6.0;
        scrollView.bouncesZoom = NO;
        scrollView.bounces = NO;
        scrollView.delegate = self;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.frame = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - Bottom_H - TOPBottomSafeHeight- TOPNavBarAndStatusBarHeight - self.adViewH);
        [self.view addSubview:scrollView];
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.frame = self.scrollView.bounds;
        contentView.userInteractionEnabled = YES;
        [self.scrollView addSubview:contentView];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(top_doubleTapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [contentView addGestureRecognizer:doubleTap];
        _contentView = contentView;
    }
    return _contentView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.bouncesZoom = NO;
        collectionView.bounces = NO;
        collectionView.frame = self.contentView.bounds;
        collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:ViewBgColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
        collectionView.showsVerticalScrollIndicator = NO;
        _collectionView = collectionView;
        [_collectionView registerClass:[TOPEditPDFViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPEditPDFViewCell class])];
    }
    return _collectionView;
}

- (TOPVerticalSlider *)scrollIndicator {
    __weak typeof(self) weakSelf = self;
    if (!_scrollIndicator) {
        TOPVerticalSlider *vSlider = [[TOPVerticalSlider alloc] initWithFrame:CGRectZero title:@"1" progressColor:[UIColor grayColor] thumImage:@"top_indicator"];
        [self.view addSubview:vSlider];
        [vSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.view);
            make.width.mas_equalTo(30);
            make.top.equalTo(self.collectionView.mas_top).offset(50);
            make.bottom.equalTo(self.collectionView.mas_bottom).offset(-50);
        }];
        _scrollIndicator = vSlider;
        _scrollIndicator.passValue = ^(float value) {
            [weakSelf scrollToIndex:value];
        };
        _scrollIndicator.passEndValue = ^(float value) {
            [weakSelf scrollDidEnd:value];
        };
    }
    return _scrollIndicator;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

//遮罩层
- (UIView *)maskView {
    if (!_maskView) {
        UIView *mask = [[UIView alloc] init];
        mask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:mask];
        mask.frame = window.bounds;
        _maskView = mask;
    }
    return _maskView;
}

- (TOPMarkTextInputView *)inputTextView {
    if (!_inputTextView) {
        __weak typeof(self) weakSelf = self;
        CGFloat font = [[NSUserDefaults standardUserDefaults] floatForKey:TOP_TRWatermarkTextFontValueKey];
        CGFloat opacity = [[NSUserDefaults standardUserDefaults] floatForKey:TOP_TRWatermarkTextOpacityKey];
        _inputTextView = [[TOPMarkTextInputView alloc] initWithFontSie:font opacity:opacity];
        _inputTextView.top_callTextCompleteBlock = ^(NSString * _Nonnull text, UIColor * _Nonnull textColor, CGFloat fontValue, CGFloat opacity) {
            [weakSelf top_hiddenInputView];
            [weakSelf top_createWaterMarkImage:text textColor:textColor fontValue:fontValue opacity:opacity];
        };
        _inputTextView.top_clickCancelBlock = ^{
            [weakSelf top_hiddenInputView];
        };
    }
    return _inputTextView;
}

- (TOPPdfSizeSettingView *)pdfSizeView{
    if (!_pdfSizeView) {
        WS(weakSelf);
        _pdfSizeView = [[TOPPdfSizeSettingView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, TOPScreenWidth, 560+TOPBottomSafeHeight)];
        _pdfSizeView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        _pdfSizeView.top_choosePdfSize = ^(TOPPdfSizeModel * _Nonnull model) {
            [weakSelf top_tapAction];
            [weakSelf top_choosePdfSizeAndCreat:model];
        };
        _pdfSizeView.top_dismissAction = ^{
            [weakSelf top_tapAction];
        };
    }
    return _pdfSizeView;
}

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_tapAction)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

#pragma mark -- 密码弹框
- (TOPDocPasswordView *)passwordView{
    if (!_passwordView) {
        WS(weakSelf);
        _passwordView = [[TOPDocPasswordView alloc]initWithFrame:CGRectMake((TOPScreenWidth-310)/2, TOPScreenHeight, 310, 260)];
        _passwordView.top_sendPassword = ^(NSString * _Nonnull password, NSInteger actionType,BOOL isShowFailToast) {
            [weakSelf top_tapAction];
            [weakSelf top_addPassword:password];
        };
        _passwordView.top_clickToHide = ^{
            [weakSelf top_tapAction];
        };
        
        _passwordView.top_clickToHelp = ^{
            [weakSelf top_settingView_SendFeedback];
        };
    }
    return _passwordView;
}

- (UILabel *)pageLab {
    if (!_pageLab) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = kTopicBlueColor;
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_R_FONT_(11);
        noClassLab.text = @"";
        noClassLab.backgroundColor = RGBA(36, 196, 164, 0.2);
        noClassLab.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:noClassLab];
        _pageLab = noClassLab;
        [_pageLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(15);
            make.top.equalTo(self.view).offset(15);
            make.height.mas_equalTo(20);
            make.width.mas_greaterThanOrEqualTo(32);
        }];
    }
    return _pageLab;
}
- (NSMutableArray *)sendNameArray {
    if (!_sendNameArray) {
        _sendNameArray = [@[NSLocalizedString(@"topscan_size", @""),NSLocalizedString(@"topscan_watermarktitle", @""),NSLocalizedString(@"topscan_writesignature", @""),NSLocalizedString(@"topscan_compression", @""),NSLocalizedString(@"topscan_more", @"")] mutableCopy];
    }
    return _sendNameArray;
}

- (NSMutableArray *)signatureData {
    if (!_signatureData) {
        _signatureData = [@[] mutableCopy];
    }
    return _signatureData;
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

- (void)top_makeCoverView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(keyWindow);
        make.top.equalTo(keyWindow.mas_bottom);
        make.height.mas_equalTo(keyWindow.mas_height);
    }];
}

- (void)top_remakeCoverView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}

- (void)top_remakeCoverViewDefault{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(keyWindow);
        make.top.equalTo(keyWindow.mas_bottom);
        make.height.mas_equalTo(keyWindow.mas_height);
    }];
}

- (void)top_makePdfSizeView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.pdfSizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(keyWindow);
        make.top.equalTo(keyWindow.mas_bottom);
        make.height.mas_equalTo(560+TOPBottomSafeHeight);
    }];
}

- (void)top_remakePdfSizeView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.pdfSizeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(keyWindow);
        make.height.mas_equalTo(560+TOPBottomSafeHeight);
    }];
}

- (void)top_remakePdfSizeViewDefault{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.pdfSizeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(keyWindow);
        make.top.equalTo(keyWindow.mas_bottom);
        make.height.mas_equalTo(560+TOPBottomSafeHeight);
    }];
}
- (void)dealloc {
    NSLog(@"delloc -- editpdf");
    [TOPScanerShare top_writePageSizeType:self.pdfSizeType];
}

#pragma mark -- 横幅广告
- (void)top_addBannerViewWithSize:(CGSize)currentSize{
    GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(currentSize.width);
    self.adViewH = adSize.size.height;
    NSString * adID = @"ca-app-pub-3940256099942544/2934735716";
    adID = [TOPDocumentHelper top_bannerAdID][4];
    GADBannerView * scbannerView = [[GADBannerView alloc]initWithFrame:CGRectMake(0, currentSize.height-adSize.size.height-TOPBottomSafeHeight, currentSize.width, 1.0)];
    scbannerView.adSize = adSize;
    scbannerView.delegate = self;
    scbannerView.adUnitID = adID;
    scbannerView.rootViewController = self;
    self.scBannerView = scbannerView;
    [self.view addSubview:self.scBannerView];
    [self.scBannerView loadRequest:[GADRequest request]];
    self.scBannerView.hidden = YES;
    [self.scBannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(adSize.size.height);
    }];
}
#pragma mark -- 获取横幅广告成功
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView{
    if (bannerView) {
        self.isBanner = YES;
        bannerView.hidden = NO;
        [self top_bannerViewSuccessViewFream];
    }
}
#pragma mark -- 获取横幅广告失败
- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    if (!self.isBanner) {
        self.isBanner = NO;
        bannerView.hidden = YES;
        [self top_bannerViewFailViewFream];
    }
}
#pragma mark -- 获取横幅广告成功试图时 重置试图坐标位置
- (void)top_bannerViewSuccessViewFream{
    [self.barBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
        make.height.mas_equalTo(Bottom_H);
    }];
    self.scrollView.frame = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - Bottom_H - TOPBottomSafeHeight- TOPNavBarAndStatusBarHeight-self.adViewH);
    self.contentView.frame = self.scrollView.bounds;
    self.collectionView.frame = self.contentView.bounds;
}
#pragma mark -- 获取横幅广告失败试图时 重置试图坐标位置
- (void)top_bannerViewFailViewFream{
    [self.barBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(Bottom_H);
    }];
    self.scrollView.frame = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - Bottom_H - TOPBottomSafeHeight- TOPNavBarAndStatusBarHeight);
    self.contentView.frame = self.scrollView.bounds;
    self.collectionView.frame = self.contentView.bounds;
}
#pragma mark -- 插页广告 1~12的随机数与界面ID相等时才显示插页广告
- (void)top_getInterstitialAd{
    int index = [TOPDocumentHelper top_interstitialAdRandomNumber];
    if (index == TOPAppInterfaceIDEditPDF) {
        WS(weakSelf);
        GADRequest *request = [GADRequest request];
        NSString * adID = @"ca-app-pub-3940256099942544/4411468910";
        adID = [TOPDocumentHelper top_interstitialAdID][4];
        [GADInterstitialAd loadWithAdUnitID:adID
                                    request:request
                          completionHandler:^(GADInterstitialAd *ad, NSError *error) {
            if (error) {
                [weakSelf top_getInterstitialAd];
            }else{
                weakSelf.interstitial = ad;
                weakSelf.interstitial.fullScreenContentDelegate = weakSelf;
                if (weakSelf.interstitial) {
                    [weakSelf.interstitial presentFromRootViewController:weakSelf];
                }
            }
        }];
    }
}

@end
