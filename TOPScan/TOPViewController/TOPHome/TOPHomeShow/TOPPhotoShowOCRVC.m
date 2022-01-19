#import "TOPPhotoShowOCRVC.h"
#import "TOPPhotoShowChildImageView.h"
#import <MLKitVision/MLKitVision.h>
#import <MLKitTextRecognition/MLKitTextRecognition.h>
#import <MLKitTextRecognitionCommon/MLKitTextRecognitionCommon.h>
#import <FIRHTTPSCallable.h>
#import "TOPPhotoShowTextAgainVC.h"
#import "TOPSettingDocumentFormatterView.h"
#import "TOPHomeShowView.h"
#import "TOPOcrModel.h"
#import "TOPImageView.h"
#import "TOPSVPOCRShowView.h"
#import "TOPCornerToast.h"
#import "TOPCreditsTipView.h"
#import "TOPLoginViewController.h"
#import "TOPSelectedLoginOrSettingAlertView.h"
#import "TOPFreeBaseSqliteTools.h"
#import "UIImage+category.h"

#import "TOPUnlockFunctionViewController.h"
#import "TOPPurchaseCredutsViewController.h"
#import "TOPSubscriptionPayListViewController.h"

@interface TOPPhotoShowOCRVC ()<TOPPhotoShowChildImageViewDelegate>
@property (nonatomic, strong) TOPPhotoShowChildImageView * myOCRView;
@property (nonatomic, strong) TOPSettingDocumentFormatterView * languageView;
@property (nonatomic, strong) TOPSettingDocumentFormatterView * endpointView;
@property (nonatomic, strong) NSMutableArray * ocrArray;
@property (nonatomic, strong) NSMutableArray * languageArray;
@property (nonatomic, strong) TOPSCAlertController * alertVC;
@property (nonatomic, strong) UIView * backView;
@property (nonatomic, strong) TOPHomeShowView * ocrTypeView;
@property (nonatomic, assign) BOOL isLoad;
@property (nonatomic, assign) NSInteger ocrCount;
@property (nonatomic, strong) NSMutableArray * myData;
@property (nonatomic, strong) TOPSVPOCRShowView * animationView;
@property (nonatomic, strong) NSMutableArray * taskArray;
@property (nonatomic, assign) NSInteger consumeCount;
@end

@implementation TOPPhotoShowOCRVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self top_getLanguageData];
    [self top_changeDefultLanguage];
    [self top_setupChildImageView];
    [TOPDocumentHelper top_getNetworkState];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[TOPScannerHttpRequest shareManager] top_tryConnectGoogle];
        [self top_loadData];
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(top_ocr_recognize_pagesChange:) name:@"top_ocr_recognize_pagesChange" object:nil];
    [FIRAnalytics logEventWithName:@"TOPPhotoShowOCRVC" parameters:nil];
    [self.myOCRView top_loadCurrentData];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    self.navigationController.navigationBarHidden = NO;
}
#pragma google实时数据库更新余额通知
- (void)top_ocr_recognize_pagesChange:(NSNotification *)not
{
    [self.myOCRView top_loadCurrentData];
}

- (void)top_getLanguageData{
    NSArray * tempArray = [NSArray new];
    if ([TOPScanerShare top_googleConnection] && [[TOPScanerShare top_saveWlanFinish] isEqualToString:@"1"]){
        tempArray = [TOPDocumentHelper top_getAllLanguageData];
    }else{
        tempArray = [TOPDocumentHelper top_getThirdLanguageData];
    }
    self.languageArray = [tempArray mutableCopy];
}

- (void)top_getSelectLanguageType:(NSString *)keyString selectRow:(NSInteger)row{
    NSDictionary * getDic = self.languageArray[row];
    if (getDic.allKeys.count>0) {
        NSLog(@"getDic.allValues[0]==%@",getDic.allValues[0]);
        [TOPScanerShare top_writeSaveOcrLanguage:getDic];
    }
    self.languageView.enterType = TOPFormatterViewEnterTypeTextAgainLanguage;
    self.myOCRView.showType = TOPPhotoShowViewTextOCR;
}

#pragma mark -- 重选节点保存之后 再重新识别
- (void)top_getSelectEndpointType:(NSString *)keyString selectRow:(NSInteger)row{
    [FIRAnalytics logEventWithName:@"OCRVC_top_getSelectEndpointType" parameters:nil];
    NSDictionary * getDic = [TOPDocumentHelper top_getEndpointData][row];
    if (getDic.allKeys.count>0) {
        [TOPScanerShare top_writeSaveOcrEndpoint:getDic];
        self.endpointView.enterType = TOPFormatterViewEnterTypeTextAgainEndpoint;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_showSVProgressHUDState:[NSLocalizedString(@"topscan_ocr", @"") stringByAppendingString:@"..."]];
        });
        [self top_starcallOCRSpace:self.ocrArray];
    }
}


- (void)top_loadData{
    WS(weakSelf);
    NSString * urlString = @"https://www.tongsoft.top/OCR/GG_USABLE";
    [[TOPScannerHttpRequest shareManager]top_GetNetDataWith:urlString withDic:@{} andSuccess:^(NSDictionary * _Nonnull dictionary) {
        NSString * statuString = [NSString stringWithFormat:@"%@",dictionary[@"status"]];
        if ([statuString isEqualToString:@"1"]) {
            NSDictionary * dataDic = dictionary[@"data"];
            NSString * dicCount = [NSString stringWithFormat:@"%@",dataDic[@"GG_USABLE"]];
            [TOPScanerShare top_writeSaveWlanFinish:dicCount];
        }
        
        if ([statuString isEqualToString:@"0"]) {
            [TOPScanerShare top_writeSaveWlanFinish:@"0"];
        }
        [weakSelf top_reloadLanguageData];
    } andFailure:^{
        [TOPScanerShare top_writeSaveWlanFinish:@"0"];
        [weakSelf top_reloadLanguageData];
    }];
}

#pragma mark -- 重置语言数据
- (void)top_reloadLanguageData {
    [self top_getLanguageData];
    [self top_changeDefultLanguage];
    self.languageView.languageArray = self.languageArray;
    self.languageView.enterType = TOPFormatterViewEnterTypeTextAgainLanguage;
    self.endpointView.enterType = TOPFormatterViewEnterTypeTextAgainEndpoint;
    self.myOCRView.showType = TOPPhotoShowViewTextOCR;
}

- (void)top_changeDefultLanguage{
    NSDictionary * dic = [TOPScanerShare top_saveOcrLanguage];
    if (![TOPScanerShare top_googleConnection] || [[TOPScanerShare top_saveWlanFinish] isEqualToString:@"0"]) {
        if ([[TOPDocumentHelper top_getGoogleLanguageData] containsObject:dic]) {
            NSDictionary * dic = @{@"English - eng":@"eng"};
            [TOPScanerShare top_writeSaveOcrLanguage:dic];
        }
    }
}

#pragma mark -- 弹窗处理
#pragma mark -- 蒙版
- (void)top_addMaskingView {
    if (_backView) {
        [self.backView removeFromSuperview];
        self.backView = nil;
    }
    [self.view addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
}

- (void)top_removeMaskingView {
    [self.backView removeFromSuperview];
    self.backView = nil;
}

- (void)top_addAnimationViewTitle {
    if (_animationView) {
        [self.animationView removeFromSuperview];
        self.animationView = nil;
    }
    [self.view addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
}
#pragma mark -- 识别动画
- (void)top_showSVProgressHUDState:(NSString *)title {
    if (!_backView) {
        [self top_addMaskingView];
    }
    [self top_addAnimationViewTitle];
    self.animationView.titleString = title;
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0.5;
        self.animationView.alpha = 1;
    }];
}

- (void)top_dismissAnimationView{
    [UIView animateWithDuration:0.1 animations:^{
        [self.animationView removeFromSuperview];
        self.animationView = nil;
        [self top_removeMaskingView];
    }];
}

- (void)top_clickTap{
    [self top_clickHideTypeView];
}

#pragma mark -- 识别方式弹窗
- (void)top_clickShowTypeView{
    [self top_addMaskingView];
    [self.view addSubview:self.ocrTypeView];
    if (IS_IPAD) {
        [self.ocrTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.height.mas_equalTo(120);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.ocrTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(20);
            make.trailing.equalTo(self.view).offset(-20);
            make.center.equalTo(self.view);
            make.height.mas_equalTo(120);
        }];
    }

    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0.5;
        self.ocrTypeView.alpha = 1;
    }];
}
#pragma mark -- 收起识别方式弹窗
- (void)top_hideShowTypeView{
    [UIView animateWithDuration:0.3 animations:^{
        [self.ocrTypeView removeFromSuperview];
        self.ocrTypeView = nil;
    }];
}

#pragma mark -- 语言列表弹窗
- (void)top_showLanguageView{
    [self top_addMaskingView];
    [self.view addSubview:self.languageView];
    [self.languageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(20);
        make.trailing.equalTo(self.view).offset(-20);
        make.top.equalTo(self.view).offset(TOPNavBarAndStatusBarHeight-10);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0.5;
        self.languageView.alpha = 1;
    }];
}

#pragma mark -- 节点弹窗
- (void)top_showEndpointView{
    [self top_addMaskingView];
    [self.view addSubview:self.endpointView];
    if (IS_IPAD) {
        [self.endpointView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.height.mas_equalTo(240+50);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.endpointView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.leading.equalTo(self.view).offset(20);
            make.trailing.equalTo(self.view).offset(-20);
            make.height.mas_equalTo(240+50);
        }];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0.5;
        self.endpointView.alpha = 1;
    }];
}

#pragma mark -- 收起弹窗
- (void)top_clickHideTypeView{
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0;
        [self.languageView removeFromSuperview];
        self.languageView = nil;
        [self.endpointView removeFromSuperview];
        self.endpointView = nil;
        [self.ocrTypeView removeFromSuperview];
        self.ocrTypeView = nil;
        [self top_removeMaskingView];
    }];
}

#pragma mark-- 滑动试图
- (void)top_setupChildImageView{
    TOPPhotoShowChildImageView * myOCRView = [[TOPPhotoShowChildImageView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
    myOCRView.currentIndex = self.currentIndex;
    myOCRView.showType = TOPPhotoShowViewTextOCR;
    myOCRView.ocrAgain = self.ocrAgain;
    myOCRView.dataArray = self.dataArray;
    myOCRView.delegate = self;
    [myOCRView top_loadCurrentData];
    [self.view addSubview:myOCRView];
    self.myOCRView = myOCRView;
    [myOCRView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
}

#pragma mark --TOPPhotoShowChildImageViewDelegate 导航栏按钮点击等事件
- (void)top_photoShowChildImageViewCurrentLocation:(NSInteger)index{
    if (self.dataArray.count>1) {
        self.currentIndex = index;
    }
}

#pragma mark -- 切换语言
- (void)top_photoShowChildImageViewOCRLanguage{
    [self top_getLanguageData];
    [self top_changeDefultLanguage];
    self.languageView.languageArray = self.languageArray;
    self.languageView.enterType = TOPFormatterViewEnterTypeTextAgainLanguage;
    self.myOCRView.showType = TOPPhotoShowViewTextOCR;
    [FIRAnalytics logEventWithName:@"OCRVC_photoShowChildImageViewOCRLanguage" parameters:nil];
    [self top_showLanguageView];
}


#pragma mark -- 点击OCR识别余额
- (void)top_photoShowChildImageViewOCRBalanceClick{
    if ([TOPSubscriptTools getSubscriptStates] ) {
        [self top_purchaseBalancePoints];
    }else{
        if ([TOPSubscriptTools getCurrentUserBalance]>0 || [TOPSubscriptTools getCurrentFreeIdentifyNum] >0) {
            [self top_subscriptionService];
        }
        
    }
    
}
#pragma mark -- 返回 这里需要处理一下 返回数据的位置需要处理
- (void)top_photoShowChildImageViewBackHomeVC{
    [FIRAnalytics logEventWithName:@"OCRVC_photoShowChildImageViewBackHomeVC" parameters:nil];
    if (self.enterType == TOPEnterShowOCRVCTypeCamera) {
        [self top_backCameraVCAlert];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
        if (self.top_clickToReloadData) {
            self.top_clickToReloadData(self.currentIndex);
        }
    }
}

- (void)top_deleteFile{
    //丢弃需要删除文件
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]];
    if ([self.docModel.type isEqualToString:@"1"]) {
        for (NSString *fileName in self.imagePathArray) {
            NSString *imgPath = [self.filePath stringByAppendingPathComponent:fileName];
            [TOPWHCFileManager top_removeItemAtPath:imgPath];
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_originalImage:imgPath]];
        }
    } else {
        [TOPWHCFileManager top_removeItemAtPath:self.filePath];
    }
}
- (void)top_backCameraVCAlert{
    WS(weakSelf);
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_note", @"")
                                                                   message:NSLocalizedString(@"topscan_savealert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_discard", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [weakSelf top_deleteFile];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark -- 开始识别
- (void)top_photoShowChildImageViewOCRStarImage:(NSMutableArray *)dataArray currentIndex:(NSInteger)index{
    self.myData = dataArray;
    self.currentIndex = index;
    NSArray *languageArry = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languageArry objectAtIndex:0];
    
    NSArray * compareArray = [currentLanguage componentsSeparatedByString:@"-"];
    NSMutableArray * keyArray = [NSMutableArray new];
    if (compareArray.count>0) {
        NSString * copmareString = compareArray[0];
        NSArray * dicArray = [TOPDocumentHelper top_getGoogleLocationLanguageData];
        for (NSDictionary * dic in dicArray) {
            if (dic.allKeys.count>0) {
                [keyArray addObject:dic.allKeys[0]];
            }
        }
        
        [self top_clickShowTypeView];
    }
}

- (void)top_backBtnClick{
    [FIRAnalytics logEventWithName:@"endOCRAndBack" parameters:nil];
    WS(weakSelf);
    TOPSCAlertController *actionSheet = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_ocrocrvctip", @"") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [weakSelf top_dismissAnimationView];
        [weakSelf top_cancelAllSessionDataTask];

        if (weakSelf.enterType == TOPEnterShowOCRVCTypeCamera) {
            [weakSelf top_deleteFile];
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
        if (weakSelf.top_clickToReloadData) {
            weakSelf.top_clickToReloadData(weakSelf.currentIndex);
        }
    }];
    
    UIAlertAction *alertF = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [actionSheet addAction:alertF];
    [actionSheet addAction:okAction];
    self.alertVC = actionSheet;
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark -- 根据所选语言开始线上识别
- (void)top_judgeLanguageStateAndOCR{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self top_showSVProgressHUDState:NSLocalizedString(@"topscan_showprocess", @"")];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self top_getOCRImageData:self.myData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.animationView.titleString = [NSLocalizedString(@"topscan_ocr", @"") stringByAppendingString:@"..."];
            [self top_onlineRecognizer];
        });
    });
   
}

#pragma mark -- 数据处理
- (void)top_getOCRImageData:(NSMutableArray *)dataArray{
    [self.ocrArray removeAllObjects];
    if (self.ocrAgain == TOPPhotoShowOCRVCAgainTypeOCRNot) {
        for (TOPOcrModel * model in dataArray) {
            if ([TOPWHCFileManager top_isExistsAtPath:model.ocrPath]) {
                if (model.isChange) {
                    [self.ocrArray addObject:model];
                }
            }else{
                [self.ocrArray addObject:model];
            }
        }
    }else{
        [self.ocrArray addObjectsFromArray:dataArray];
    }
}

#pragma mark -- 购买点数
- (void)top_purchaseBalancePoints {
    TOPPurchaseCredutsViewController *purchaseVC = [[TOPPurchaseCredutsViewController alloc] init];
    purchaseVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:purchaseVC animated:YES];
}

#pragma mark -- 去订阅
- (void)top_subscriptionService {
    if ([TOPAppTools needShowDiscountThemeView]) {
        [[TOPDiscountThemeView shareInstance] top_showDiscountTheme:@"20211123_year_sub"];
        return;
    } 
    TOPSubscriptionPayListViewController *subscriptVC = [[TOPSubscriptionPayListViewController alloc] init];
    subscriptVC.closeType = TOPSubscriptOverCloseTypeOCRSub;
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:subscriptVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- 识别方式选择 线上/本地
- (void)top_prepareOCR:(NSInteger)row{
    if (row == 0) {
        if (![TOPPermissionManager top_enableByOCROnline]) {
            [self top_removeMaskingView];
            if ([TOPUserInfoManager shareInstance].isVip) {
                [self top_purchaseBalancePoints];
            } else {
                [self top_subscriptionService];
            }
            
            return;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self top_showSVProgressHUDState:NSLocalizedString(@"topscan_showprocess", @"")];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self top_getOCRImageData:self.myData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.animationView.titleString = [NSLocalizedString(@"topscan_ocr", @"") stringByAppendingString:@"..."];
            if (row == 0) {
                [self top_onlineRecognizer];
            } else {
                [self top_googleLocalOCR:self.ocrArray];
            }
        });
    });
}

#pragma mark -- 线上识别
- (void)top_onlineRecognizer {
    if ([TOPScanerShare top_saveNetworkState] == 0 || [TOPScanerShare top_saveNetworkState] == -1) {
        [self top_dismissAnimationView];
        [TOPDocumentHelper top_showAlertControllerStyleAlertTitle:NSLocalizedString(@"topscan_networkstate", @"") message:NSLocalizedString(@"topscan_networkstatecontent", @"")];
        return;
    }
    if ([TOPSubscriptTools getCurrentAvailableOcrNum]<self.ocrArray.count) {
        if ([TOPSubscriptTools getSubscriptStates]) {
            [self top_dismissAnimationView];
            if (![TOPScanerShare top_getCurrentiCloudStates] && ![TOPSubscriptTools googleLoginStates]) {//未开启iCloud
                [self top_jumpLoginOrRegisterPage:TOPLoginSuccessfulJumpTypePurchase];
            }else{
                WS(weakself);
                TOPCreditsTipView *tipAlertView = [[TOPCreditsTipView alloc] initWithTitleViewSelectBlock:^{
                    TOPPurchaseCredutsViewController *purchaseVC = [[TOPPurchaseCredutsViewController alloc] init];
                    purchaseVC.hidesBottomBarWhenPushed = YES;
                    [weakself.navigationController pushViewController:purchaseVC animated:YES];
                }];
                [tipAlertView top_showAlertUnBoundView];
            }
            return;
            
        }else{
            [self top_dismissAnimationView];
            if (![TOPScanerShare top_getCurrentiCloudStates] && ![TOPSubscriptTools googleLoginStates]) {//未开启iCloud 未登录
                [self top_jumpLoginOrRegisterPage:TOPLoginSuccessfulJumpTypeSubscript];
            }else{
                [self top_subscriptionService];
            }
            return;
        }
    }
    
    NSDictionary * languageDic = [TOPScanerShare top_saveOcrLanguage];
    if ([[TOPDocumentHelper top_getGoogleLanguageData] containsObject:languageDic]) {
        if ([FIRAuth auth].currentUser) {
            [self top_googleCloudOCR:self.ocrArray];
        }else{
            NSLog(@"66666");
            [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
                NSLog(@"7777");
                if (!error) {
                    [self top_googleCloudOCR:self.ocrArray];
                }else{
                    [self top_dismissAnimationView];
                    NSString *message = error.localizedDescription;
                    [[TOPCornerToast shareInstance] makeToast:message];
                }
            }];;
        }
    }

    if ([[TOPDocumentHelper top_getThirdLanguageData] containsObject:languageDic]) {
        [self top_starcallOCRSpace:self.ocrArray];
    }
     
}
#pragma mark- 跳转登陆注册页
- (void)top_jumpLoginOrRegisterPage:(TOPLoginSuccessfulJumpType)jumpType
{
    WS(weakself);
    TOPSelectedLoginOrSettingAlertView *tipAlertView = [[TOPSelectedLoginOrSettingAlertView alloc] initWithTitleViewSelectBlock:^{
        TOPLoginViewController *loginVC = [[TOPLoginViewController alloc] init];
        loginVC.closeLoginType = jumpType;
        TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:loginVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [weakself presentViewController:nav animated:YES completion:nil];
        
    }];
    [tipAlertView top_showAlertUnBoundView];
}
#pragma mark -- 第三方识别
- (void)top_starcallOCRSpace:(NSArray *)imgArray {
    [FIRAnalytics logEventWithName:@"OCRVC_starcallOCRSpace" parameters:nil];
    __weak typeof(self) weakSelf = self;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakSelf.ocrCount = 0;
        self.consumeCount = 0;
        for (int i = 0; i < imgArray.count; i++) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            TOPOcrModel * ocrModel = imgArray[i];
            NSData *imgData = [weakSelf top_configUploadData:ocrModel];
            NSMutableURLRequest *request = [weakSelf top_uploadImageRequestWithImage:imgData imageName:ocrModel.photoName];
            if (request) {
                NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    weakSelf.ocrCount ++;
                    dispatch_semaphore_signal(semaphore);
                    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
                    if (httpResponse.statusCode == 200) {
                        [weakSelf top_uploadImageCompletionHandler:data imageModel:ocrModel];
                        [weakSelf top_consumptionOcrBalanceKou:1];

                    } else {
                        [weakSelf top_requestError];
                    }
                    if (i == imgArray.count-1) {
                        NSString * languageString = @"";
                        NSDictionary * getDic = [TOPScanerShare top_saveOcrLanguage];
                        if (getDic.allKeys.count>0) {
                            languageString = getDic.allValues[0];
                        }
                        [self top_ocrFinishAndSendUsedCount:imgArray.count ocrLanguage:languageString];
                        [self top_uploadBalanceToiCloudOrBalance];
                    }
                }];
                [task resume];
                [weakSelf.taskArray addObject:task];
            } else {
                dispatch_semaphore_signal(semaphore);
            }
        }

    });
}

#pragma mark -- request error
- (void)top_requestError {
    if (self.ocrArray.count == 1) {
        [self top_handleCompleteBack];
    } else {
        [self top_recognizerTextsComplete];
    }
}

#pragma mark -- URLResponse 处理识别结果
- (void)top_uploadImageCompletionHandler:(NSData *)data imageModel:(TOPOcrModel *)model{
    NSString *noteFilePath = [TOPDocumentHelper top_getTxtPath:model.movePath imgName:model.photoIndex txtType:@""];
    NSString * resultString = @"";
    if (data) {
        NSError* myError;
        [FIRAnalytics logEventWithName:@"A_SpaceOCR_count" parameters:nil];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions
                                                                 error:&myError];
        NSArray * resultArray = result[@"ParsedResults"];
        if (resultArray.count>0) {
            resultString = result[@"ParsedResults"][0][@"ParsedText"];
        }
    }
    
    if (![TOPWHCFileManager top_isExistsAtPath:model.ocrPath]) {
        [resultString writeToFile:noteFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        if (resultString.length>0) {
            [resultString writeToFile:noteFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
    DocumentModel * docModel = self.dataArray[model.index];
    docModel.ocr = [TOPDocumentHelper top_getTxtContent:noteFilePath];
    
    if (!data) {
        [FIRAnalytics logEventWithName:@"A_spaceocrapi_endpoint_connection_failed" parameters:nil];
        if (self.ocrArray.count == 1) {
            [self top_handleCompleteBack];
            return;
        }
    }
    [self top_ocrProgressShow];
    [self top_recognizerTextsComplete];
}

#pragma mark -- progress show
- (void)top_ocrProgressShow {
    if (self.ocrArray.count > 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * stateStr = [[NSString alloc]initWithFormat:@"%@(%ld%%)",[NSLocalizedString(@"topscan_ocr", @"") stringByAppendingString:@"..."],((self.ocrCount)*100/(self.ocrArray.count))];
            self.animationView.titleString = stateStr;
        });
    }
}

#pragma mark -- 所有图片识别结束处理
- (void)top_recognizerTextsComplete {
    if (self.ocrCount == self.ocrArray.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_finishAndEnter];
            [self top_dismissAnimationView];
        });
    }
}

#pragma mark -- 单张图片识别失败后界面处理
- (void)top_handleCompleteBack {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self top_dismissAnimationView];
        [self top_showEndpointView];
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_ocrthirdocrfailprompt", @"") duration:1.5];
        [[TOPCornerToast shareInstance] setToastCenter:CGPointMake(TOPScreenWidth/2, TOPScreenHeight/2 + 260)];
    });
}

#pragma mark -- 设置上传的图片数据 二进制文件：NSData
- (NSData *)top_configUploadData:(TOPOcrModel *)model {
    UIImage * cutImg = [self top_clipImage:model];
    CGFloat maxImageMemory = 4.9*1024*1024;
    NSData *imgData = [TOPDocumentHelper top_compressImageQuality:cutImg toByte:maxImageMemory];
    return imgData;
}

#pragma mark -- URLRequest 配置
- (NSMutableURLRequest *)top_uploadImageRequestWithImage:(NSData *)imageData imageName:(NSString *)imageName {
    NSString * languageString = @"";
    NSDictionary * getDic = [TOPScanerShare top_saveOcrLanguage];
    NSString * endpointString = [TOPDocumentHelper top_getEndPoint:getDic];
    if (getDic.allKeys.count>0) {
        languageString = getDic.allValues[0];
    }
    NSInteger ocrEngine = [TOPDocumentHelper top_getOCREngine:languageString];
    NSString * apiKey = @"OCRK9487898A";
    NSURL *url = [NSURL URLWithString:endpointString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval: 15];
    NSString *boundary = @"randomString";
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    NSDictionary * parametersDictionary = @{@"apikey":apiKey,
                                            @"isOverlayRequired":@"False",
                                            @"language":languageString,
                                            @"OCREngine":@(ocrEngine)};
    NSData *httpBody = [self top_createBodyWithBoundary:boundary
                                         parameters:parametersDictionary
                                          imageData:imageData
                                           filename:imageName];
    [request setHTTPBody:httpBody];
    
    return request;
}

- (NSData *) top_createBodyWithBoundary:(NSString *)boundary parameters:(NSDictionary *)parameters imageData:(NSData*)data filename:(NSString *)filename
{
    NSMutableData *body = [NSMutableData data];
    if (data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    for (id key in parameters.allKeys) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameters[key]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return body;
}

#pragma mark -- 确定图片识别区域
- (UIImage *)top_clipImage:(TOPOcrModel *)ocrModel {
    UIImage * cutImg = [UIImage new];
    UIImage * dealImg = [UIImage imageWithContentsOfFile:ocrModel.imgPath].fixOrientation;
    if (ocrModel.isChange) {
        cutImg = [TOPDocumentHelper top_imageAtRect:dealImg imageRect:ocrModel.ocrRect];
    }else{
        cutImg = dealImg;
    }
    return cutImg;
}

#pragma mark -- google云识别
- (void)top_googleCloudOCR:(NSArray *)imageArray{
    [FIRAnalytics logEventWithName:@"OCRVC_googleCloudOCR" parameters:nil];
    [self top_starGoogleCloudOCR:imageArray];
}
-(NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
- (void)top_starGoogleCloudOCR:(NSArray *)imageArray{
    [FIRAnalytics logEventWithName:@"OCRVC_starGoogleCloudOCR" parameters:nil];
    WS(weakSelf);
    FIRFunctions * textRecognizer = [FIRFunctions functions];
    NSArray * languageArray = [self top_configGoogleCloudRecognizerLanguange];
    self.ocrCount = 0;
    self.consumeCount = 0;
    
    for (int i = 0; i<imageArray.count; i++) {
        TOPOcrModel * ocrModel = imageArray[i];
        
        UIImage * cutImg = [self top_clipImage:ocrModel];
        NSData * imageData = UIImageJPEGRepresentation(cutImg, 0.6f);
        NSString *base64encodedImage= [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        NSDictionary *requestData = @{
            @"image":@{@"content": base64encodedImage},
            @"features": @[@{@"type": @"TEXT_DETECTION"}],
            @"imageContext": @{@"languageHints": languageArray}
        };
        NSString *jsonStr = [self convertToJsonData:requestData];

        [[textRecognizer HTTPSCallableWithName:@"annotateImage"] callWithObject:jsonStr completion:^(FIRHTTPSCallableResult * _Nullable result, NSError * _Nullable error) {
            weakSelf.ocrCount ++;
            if (error) {
                if (error.domain == FIRFunctionsErrorDomain) {
                    [FIRAnalytics logEventWithName:@"A_GoogleOCR_error" parameters:nil];
                    FIRFunctionsErrorCode code = error.code;
                    NSString *message = error.localizedDescription;
                    NSObject *details = error.userInfo[FIRFunctionsErrorDetailsKey];
                    NSLog(@"message==%@ details==%@ code==%ld",message,details,code);
                }
            }
            [FIRAnalytics logEventWithName:@"A_GoogleOCR_count" parameters:nil];
            NSDictionary *annotation = result.data[0][@"fullTextAnnotation"];
            NSString * text = annotation[@"text"];
            NSLog(@"result==%@ annotation==%@ text==%@",result,annotation,text);
            NSLog(@"\n%@", annotation[@"text"]);
            if (!error) {
                [weakSelf top_consumptionOcrBalanceKou:1];
            }
            [weakSelf top_googleCloudRecognizerCompleteHandle:annotation[@"text"] imageModel:ocrModel];
            if (i == imageArray.count-1) {
                [self top_ocrFinishAndSendUsedCount:imageArray.count ocrLanguage:languageArray];
                [self top_uploadBalanceToiCloudOrBalance];
            }
        }];
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
#pragma mark- 识别减点
- (void)top_consumptionOcrBalanceKou:(NSInteger)count {
    self.consumeCount ++;
    if ([TOPSubscriptTools getSubscriptStates]) {
        NSInteger identifyNum = [TOPSubscriptTools getCurrentSubscriptIdentifyNum];

        if (identifyNum >= count) {
            identifyNum = identifyNum - count;
            [TOPSubscriptTools saveWriteCurrentSubscripIdentifyNum:identifyNum];
        }else{
            NSInteger currentBalance = [TOPSubscriptTools getCurrentUserBalance];
            if (currentBalance>= count) {
                currentBalance = currentBalance-count;
                [TOPSubscriptTools saveWriteCurrentUserBalance:currentBalance];
            }
        }

    }else{
        NSInteger freeBalanceNum = [TOPSubscriptTools getCurrentFreeIdentifyNum];
        if (freeBalanceNum >= count) {
            freeBalanceNum = freeBalanceNum-count;
            [TOPSubscriptTools saveWriteCurrentFreeIdentifyNum:freeBalanceNum];
        }else{
            NSInteger currentBalance = [TOPSubscriptTools getCurrentUserBalance];
            if (currentBalance>= count) {
                currentBalance = currentBalance-count;
                [TOPSubscriptTools saveWriteCurrentUserBalance:currentBalance];
            }
        }

    }
}
#pragma mark -- 处理Google识别结果
- (void)top_googleCloudRecognizerCompleteHandle:(NSString *)ocrText  imageModel:(TOPOcrModel *)ocrModel{
    NSString * resultString = ocrText ? ocrText : @"";;
    DocumentModel * model = self.dataArray[ocrModel.index];
    NSString *noteFilePath = [TOPDocumentHelper top_getTxtPath:model.movePath imgName:model.photoIndex txtType:@""];
    if (![TOPWHCFileManager top_isExistsAtPath:ocrModel.ocrPath]) {
        [resultString writeToFile:noteFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        if (resultString.length>0) {
            [resultString writeToFile:noteFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
    if (!ocrText) {
        if (self.ocrArray.count == 1) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"topscan_ocrthirdocrfailprompt", @"")];
            [SVProgressHUD dismissWithDelay:1.5];
            return;
        }
    }
    [self top_ocrProgressShow];
    [self top_recognizerTextsComplete];
}
- (NSArray *)top_configGoogleCloudRecognizerLanguange{
    NSArray * languageArray = [NSArray new];
    NSDictionary * dic = [TOPScanerShare top_saveOcrLanguage];
    NSString * languageString = @"";
    if (dic.allKeys.count>0) {
        languageString = dic.allValues[0];
    }
    if (![languageString isEqual:@"other"]) {
        languageArray = @[languageString];
    }
    return languageArray;
}
#pragma mark -- google本地识别
- (void)top_googleLocalOCR:(NSArray *)imageArray{
    [FIRAnalytics logEventWithName:@"OCRVC_googleLocalOCR" parameters:nil];
    WS(weakSelf);
    self.ocrCount = 0;
    for (int i = 0; i<imageArray.count; i++) {
        TOPOcrModel * ocrModel = imageArray[i];
        UIImage *cutImg = [self top_clipImage:ocrModel];
        if (!cutImg) {
            self.ocrCount ++;
            continue;
        }
        
        MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:cutImg];
        visionImage.orientation = cutImg.imageOrientation;
        MLKTextRecognizer *textRecognizer = [MLKTextRecognizer textRecognizer];
        [textRecognizer processImage:visionImage completion:^(MLKText * _Nullable text, NSError * _Nullable error) {
            weakSelf.ocrCount ++;
            if (error != nil || text == nil) {
                [FIRAnalytics logEventWithName:@"A_GoogleLocalLocalLocalOCR_error" parameters:nil];
            }else{
                [FIRAnalytics logEventWithName:@"A_GoogleLocalLocalLocalOCR_count" parameters:nil];
            }
            [weakSelf top_googleCloudRecognizerCompleteHandle:text.text imageModel:ocrModel];
        }];
         
    }
}

- (void)top_finishAndEnter{
    [self.alertVC dismissViewControllerAnimated:YES completion:nil];
    if (self.enterType == TOPEnterShowOCRVCTypeCamera) {
        if ([self.docModel.type isEqualToString:@"0"]) {
            [TOPEditDBDataHandler top_addDocumentAtFolder:self.filePath WithParentId:self.docModel.docId];
        } else {
            [TOPEditDBDataHandler top_addImageFileAtDocument:self.imagePathArray WithId:self.docModel.docId];
        }
    }
    if (self.finishType == TOPPhotoShowOCRVCAgainFinishNot) {
        [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
        [FIRAnalytics logEventWithName:@"OCRVC_OCRVCAgainFinishNot" parameters:nil];
        TOPPhotoShowTextAgainVC * againVC = [[TOPPhotoShowTextAgainVC alloc]init];
        againVC.currentIndex = self.currentIndex;
        againVC.dataArray = self.dataArray;
        againVC.backType = self.backType;
        againVC.dataType = self.dataType;
        againVC.filePath = self.filePath;
        againVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:againVC animated:YES];
    }else{
        [FIRAnalytics logEventWithName:@"OCRVC_OCRVCAgainFinishAlready" parameters:nil];
        if (self.top_clickToReloadData) {
            self.top_clickToReloadData(self.currentIndex);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (self.consumeCount > 0) {
        NSString *toastStr = self.consumeCount == 1 ? @"Consume 1 page" : [NSString stringWithFormat:@"Consume %@ pages",@(self.consumeCount)];
        [[TOPCornerToast shareInstance] makeToast:toastStr];
    }
}
- (void)top_ocrFinishAndSendUsedCount:(NSInteger)count ocrLanguage:language{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary * dic = [NSMutableDictionary new];
        [dic setValue:[TOPUUID top_getUUID] forKey:@"deviceId"];
        if ([FIRAuth auth].currentUser.uid.length) {
            [dic setValue:[FIRAuth auth].currentUser.uid forKey:@"userId"];
        }
        [dic setValue:@(count) forKey:@"usedPages"];
        [dic setValue:language forKey:@"comment"];
        [[TOPScannerHttpRequest shareManager]top_PostNetDataWith:TOP_TROCRUsedPages withDic:dic andSuccess:^(NSDictionary * _Nonnull responseObject) {
        } andFailure:^(NSError * _Nonnull error) {
        }];
    });
}
#pragma mark -- lazy
- (NSMutableArray *)myData{
    if (!_myData) {
        _myData = [NSMutableArray new];
    }
    return _myData;
}

- (NSMutableArray *)taskArray {
    if (!_taskArray) {
        _taskArray = [[NSMutableArray alloc] init];
    }
    return _taskArray;
}

- (TOPSVPOCRShowView *)animationView{
    if (!_animationView) {
        WS(weakSelf);
        _animationView = [[TOPSVPOCRShowView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _animationView.alpha = 0;
        _animationView.top_clickAction = ^{
            [weakSelf top_backBtnClick];
        };
    }
    return _animationView;
}

- (NSMutableArray *)ocrArray{
    if (!_ocrArray) {
        _ocrArray = [NSMutableArray new];
    }
    return _ocrArray;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (NSMutableArray *)languageArray{
    if (!_languageArray) {
        _languageArray = [NSMutableArray new];
    }
    return _languageArray;
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTap)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

- (TOPHomeShowView *)ocrTypeView{
    if (!_ocrTypeView) {
        NSString *title2 = [NSString stringWithFormat:@"%@ \n(%@)",NSLocalizedString(@"topscan_ocrtypelocal", @""), NSLocalizedString(@"topscan_ocrtypelocaltip", @"")];
        NSArray * array = @[NSLocalizedString(@"topscan_ocrtypecloud", @""),title2];
        _ocrTypeView = [[TOPHomeShowView alloc]initWithFrame:CGRectMake(20, (TOPScreenHeight-120)/2, TOPScreenWidth-40, 120)];
        _ocrTypeView.alpha = 0;
        _ocrTypeView.showType = TOPHomeShowViewLocationTypeMiddle;
        _ocrTypeView.dataArray = array;
        WS(weakSelf);
        _ocrTypeView.top_clickCellAction = ^(NSInteger row) {
            [weakSelf top_hideShowTypeView];
            [weakSelf top_prepareOCR:row];
        };
    }
    return _ocrTypeView;
}

- (TOPSettingDocumentFormatterView *)languageView {
    if (!_languageView) {
        WS(weakSelf);
        TOPSettingDocumentFormatterView * languageView = [[TOPSettingDocumentFormatterView alloc]initWithFrame:CGRectMake(20, TOPNavBarAndStatusBarHeight-10, TOPScreenWidth-40, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-10)];
        languageView.alpha = 0;
        languageView.layer.masksToBounds = YES;
        languageView.layer.cornerRadius = 5;
        [languageView.languageArray addObjectsFromArray:self.languageArray];
        languageView.enterType = TOPFormatterViewEnterTypeTextAgainLanguage;
        languageView.top_clickToDismiss = ^{
            [weakSelf top_clickTap];
        };
        languageView.top_clickCellSendLanguageDic = ^(NSString * _Nonnull keyString, NSInteger row) {
            [weakSelf top_clickTap];
            [weakSelf top_getSelectLanguageType:keyString selectRow:row];
        };
        _languageView = languageView;
    }
    return _languageView;
}

- (TOPSettingDocumentFormatterView *)endpointView {
    if (!_endpointView) {
        WS(weakSelf);
        TOPSettingDocumentFormatterView * endpointView = [[TOPSettingDocumentFormatterView alloc]initWithFrame:CGRectMake(20, (TOPScreenHeight-240-50)/2, TOPScreenWidth-40, 240+50)];
        endpointView.alpha = 0;
        endpointView.layer.masksToBounds = YES;
        endpointView.layer.cornerRadius = 5;
        endpointView.enterType = TOPFormatterViewEnterTypeTextAgainEndpoint;
        endpointView.top_clickToDismiss = ^{
            [weakSelf top_clickTap];
        };
        endpointView.top_clickCellSendLanguageDic = ^(NSString * _Nonnull keyString, NSInteger row) {
            [weakSelf top_clickTap];
            [weakSelf top_getSelectEndpointType:keyString selectRow:row];
        };
        _endpointView = endpointView;
    }
    return _endpointView;
}

#pragma mark -- 取消网络请求
- (void)top_cancelAllSessionDataTask {
    for (NSURLSessionDataTask *dataTask in self.taskArray) {
        if (dataTask.state == NSURLSessionTaskStateRunning || dataTask.state == NSURLSessionTaskStateSuspended) {
            [dataTask cancel];
        }
    }
    [self.taskArray removeAllObjects];
}


- (void)dealloc {
    NSLog(@"--dealloc ocrVC");
}

@end
;
