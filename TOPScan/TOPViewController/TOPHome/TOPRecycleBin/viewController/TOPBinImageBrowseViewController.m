#define Bottom_H 49

#import "TOPBinImageBrowseViewController.h"
#import "TOPImageBrowser.h"
#import "TOPBinImage.h"
#import "TOPCropTipView.h"

@interface TOPBinImageBrowseViewController ()<GADBannerViewDelegate>
@property (nonatomic, strong) UIButton *restoreBtn;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) TOPImageBrowser *imageBrowser;
@property (nonatomic, strong) DocumentModel *currentModel;

@property (nonatomic, strong) GADBannerView * scBannerView;
@property (nonatomic, assign) CGFloat adViewH;
@property (nonatomic, assign) CGSize currentSize;
@property (nonatomic, assign) BOOL isBanner;
@end

@implementation TOPBinImageBrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adViewH = 0.0;
    self.isBanner = NO;
    self.title = self.currentIndex + 1 < 10 ? [NSString stringWithFormat:@"0%@",@(self.currentIndex + 1)] :[NSString stringWithFormat:@"%@",@(self.currentIndex + 1)];
    [self top_configNavBar];
    [self top_configContentView];
}

- (void)top_backHomeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self top_loadBinData];
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self top_loadDocDataAndAD:self.view.size];
            });
        }];
    } else {
        [self top_loadDocDataAndAD:self.view.size];
    }
}
#pragma mark -- 加载横幅广告
- (void)top_loadDocDataAndAD:(CGSize)size{
    self.currentSize = size;
    if (![TOPPermissionManager top_enableByAdvertising]) {//要展示广告
        if (!self.isBanner) {//横幅没有加载过
            [self top_AddBannerViewWithSize:size];
        }else{//已经加载出了广告
            if (!self.scBannerView.hidden) {
                GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(size.width);
                self.adViewH = adSize.size.height;
            }
            [self top_adFinishContentFatherFream];
        }
    } else {//是会员移除横幅广告
        [self top_removeBannerView];
        [self top_adFailContentFatherFream];
    }
}
#pragma mark -- 隐藏横幅广告视图
- (void)top_removeBannerView{
    [self top_adFailContentFatherFream];
    [self.scBannerView removeFromSuperview];
    self.scBannerView = nil;
    self.isBanner = NO;
}
- (void)top_loadBinData {
    self.imageBrowser.dataArray = self.dataArray;
    self.imageBrowser.currentIndex = self.currentIndex;
    [self.imageBrowser top_updateCurrentItem];
}

#pragma mark -- 删除
- (void)top_takeDeleteAlert {
    [self top_showCropTip];
}

- (void)top_showCropTip {
    BOOL showTip = [TOPScanerShare top_deleteFileAlert];
    if (showTip) {
        NSString *msg = [NSString stringWithFormat:@"%@ \n %@",NSLocalizedString(@"topscan_deleteoption", @""), NSLocalizedString(@"topscan_recyclebindeletetip", @"")];
        UIWindow *window = [UIApplication sharedApplication].windows[0];
        __weak typeof(self) weakSelf = self;
        TOPCropTipView *tipView = [[TOPCropTipView alloc] initWithTipMessage:msg];
        tipView.okBlock = ^{
            [weakSelf top_deleteHandle];
        };
        [window addSubview:tipView];
        [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(window);
        }];
    } else {
        [self top_deleteHandle];
    }
}

#pragma mark -- 删除
- (void)top_clickDeleteBtn {
    [self top_takeDeleteAlert];
}

- (void)top_deleteHandle {
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DocumentModel *model = self.dataArray[self.currentIndex];
        [TOPWHCFileManager top_removeItemAtPath:model.path];
        [TOPBinEditDataHandler top_deleteImagesWithIds:@[model.docId]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self top_deleteItemUpdate];
        });
    });
}

#pragma mark -- 删除后刷新
- (void)top_deleteItemUpdate {
    [self.dataArray removeObjectAtIndex:self.currentIndex];
    if (self.dataArray.count>0) {
        NSInteger i = 0;
        if (self.currentIndex == 0) {
            i = 0;
        } else {
            i = self.currentIndex -1 ;
        }
        [self top_updateWithIndex:i];
        [self top_loadBinData];
    } else {
        if (self.top_deleteAllDataBlock) {
            self.top_deleteAllDataBlock();
        }
        [self.navigationController popViewControllerAnimated:NO];
    }

}

#pragma mark -- 还原
- (void)top_clickRestoreBtn {
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DocumentModel *model = self.dataArray[self.currentIndex];
        [self top_restoreImageHandler:model];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_showSuccessTip];
            [self top_deleteItemUpdate];
        });
    });
}

- (void)top_showSuccessTip {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_recyclebinsuccess", @"")];
    [SVProgressHUD dismissWithDelay:1];
}

#pragma mark -- 还原图片
- (void)top_restoreImageHandler:(DocumentModel *)model {
    NSString *targetPath = [TOPBinDataHandler top_restoreImageParentPath:model.docId];
    if ([TOPDocumentHelper top_directoryHasJPG:targetPath]) {//有图片 ,往文档中加图片，排在最后
        NSString *imgPath = [TOPBinHelper top_restoreImage:model.path atPath:targetPath];
        NSString *imgName = [TOPWHCFileManager top_fileNameAtPath:imgPath suffix:YES];
        NSString *parentId = [TOPBinDataHandler top_imageParentId:model.docId];
        [TOPEditDBDataHandler top_addBinImageFileAtDocument:@[imgName] WithId:parentId];
    } else {//无图片，则新建文档
        [TOPBinHelper top_restoreImage:model.path atPath:targetPath];
        DocumentModel *newObj = [TOPBinDataHandler top_restoreNewDocModel:targetPath withDelParentId:model.docId];
        TOPBinImage *img = [TOPBinQueryHandler top_imageFileById:model.docId];
        [TOPEditDBDataHandler top_setDocTime:newObj.docId withBinDocId:img.parentId];
    }
    [TOPBinEditDataHandler top_deleteImagesWithIds:@[model.docId]];
}

- (void)top_updateWithIndex:(NSInteger)index {
    self.currentIndex = index;
    self.title = self.currentIndex + 1 < 10 ? [NSString stringWithFormat:@"0%@",@(self.currentIndex + 1)] :[NSString stringWithFormat:@"%@",@(self.currentIndex + 1)];
}

#pragma mark -- 设置导航栏
- (void)top_configNavBar {
    if (isRTL()) {//黑色
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    } else {
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}

- (void)top_configContentView {
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    [self.view addSubview:self.imageBrowser];
    [self top_setupBottomView];
    [self.imageBrowser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(Bottom_H+TOPBottomSafeHeight));
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(49);
    }];
    [self top_refreshBottomBtnState];
    __weak typeof(self) weakSelf = self;
    self.imageBrowser.top_refreshCurrentIndex = ^(NSInteger index) {
        [weakSelf top_updateWithIndex:index];
    };
}

- (void)top_refreshBottomBtnState {
    [self.deleteBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
    self.deleteBtn.enabled = YES;
    [self.restoreBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
    self.restoreBtn.enabled = YES;
}

- (void)top_setupBottomView {
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-49, TOPScreenWidth,49)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    
    UIView * safeView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    safeView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];;
    
    UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, (TOPScreenWidth-1)/2-20, 49)];
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancelBtn setTitle:NSLocalizedString(@"topscan_delete", @"") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(top_clickDeleteBtn) forControlEvents:UIControlEventTouchUpInside];
    self.deleteBtn = cancelBtn;
    
    UIView * midLine = [[UIView alloc]initWithFrame:CGRectMake((TOPScreenWidth-1)/2, 12, 1, 25)];
    midLine.backgroundColor = TOPAPPGreenColor;
    
    UIButton * mergeBtn = [[UIButton alloc]initWithFrame:CGRectMake((TOPScreenWidth-1)/2+1+10,0 , (TOPScreenWidth-1)/2-20, 49)];
    mergeBtn.backgroundColor = [UIColor clearColor];
    mergeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [mergeBtn setTitle:NSLocalizedString(@"topscan_restoretitle", @"") forState:UIControlStateNormal];
    [mergeBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
    [mergeBtn addTarget:self action:@selector(top_clickRestoreBtn) forControlEvents:UIControlEventTouchUpInside];
    self.restoreBtn = mergeBtn;
    
    [self.view addSubview:bottomView];
    [self.view addSubview:safeView];
    [bottomView addSubview:cancelBtn];
    [bottomView addSubview:midLine];
    [bottomView addSubview:mergeBtn];
    self.bottomView = bottomView;
    
    [safeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
    
    [midLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bottomView);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(25);
    }];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(bottomView);
        make.trailing.equalTo(midLine.mas_leading);
    }];
    [mergeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.bottom.equalTo(bottomView);
        make.leading.equalTo(midLine.mas_trailing);
    }];
}

#pragma mark -- lazy
- (TOPImageBrowser *)imageBrowser {
    if (!_imageBrowser) {
        _imageBrowser = [[TOPImageBrowser alloc] initWithFrame:CGRectMake(0, TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight - 49 - TOPBottomSafeHeight)];
    }
    return _imageBrowser;
}

#pragma mark -- 横幅广告
- (void)top_AddBannerViewWithSize:(CGSize)currentSize{
    GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(currentSize.width);
    self.adViewH = adSize.size.height;
    NSString * adID = @"ca-app-pub-3940256099942544/2934735716";
    adID = [TOPDocumentHelper top_bannerAdID][5];
    GADBannerView * scbannerView = [[GADBannerView alloc] init];
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
    }];
}
#pragma mark -- 获取横幅广告成功
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView{
    [FIRAnalytics logEventWithName:@"homeView_bannerReceiveAd" parameters:nil];
    if (bannerView) {
        bannerView.hidden = NO;
        self.isBanner = YES;
        [self top_adFinishContentFatherFream];
    }
}

#pragma mark -- 获取横幅广告失败
- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"error==%@",error);
    if (!self.isBanner) {//google广告没有出现过
        [self top_removeBannerView];
    }
}
- (void)top_adFinishContentFatherFream{
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
    }];
    [self.imageBrowser mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H+self.adViewH));
    }];
}
- (void)top_adFailContentFatherFream{
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
    }];
    [self.imageBrowser mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
    }];
}
@end
