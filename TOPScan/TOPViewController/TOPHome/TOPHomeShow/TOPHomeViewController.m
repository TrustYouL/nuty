#define FatherTop_Y 90
#define ShareView_H 200
#define TopView_H 55
#define Bottom_H 60
#define SortView_H 60
#define MoreView_H 45
#define AddFolder_W 310
#define AddFolder_H 240
#define AddFolderSingle_H 190
#define MaxFolderCount 3
#define FolderViewTypeAdd @"FolderViewTypeAdd"
#define FolderViewTypeChange @"FolderViewTypeChange"

#import "TOPHomeViewController.h"
#import "TOPSingleBatchViewController.h"
#import "TOPNextFolderViewController.h"
#import "TOPDocumentCollectionView.h"
#import "TOPHomeChildViewController.h"
#import "TOPSearchFileViewController.h"
#import "TOPPhotoShowTextAgainVC.h"
#import "TOPPhotoShowOCRVC.h"
#import "TOPSetTagViewController.h"
#import "TOPTagsManagerViewController.h"
#import "TOPHomeTopMergeVC.h"
#import "TOPRestoreViewController.h"
#import "TOPSCameraViewController.h"
#import "TOPFileTargetListViewController.h"
#import "TOPShowLongImageViewController.h"
#import "TOPSettingViewController.h"
#import "TOPCamerBatchViewController.h"
#import "TOPLoadSelectDriveViewController.h"
#import "TOPUnlockFunctionViewController.h"
#import "TOPDocumentRemindVC.h"
#import "TOPSuggestionsVC.h"
#import "TOPMainTabBarController.h"
#import "TOPBinHomeViewController.h"

#import "TOPSubscriptionEYearAlertView.h"
#import "TOPShareTypeView.h"
#import "TOPShareDownSizeView.h"
#import "TOPPhotoLongPressView.h"
#import "TOPWMDragView.h"
#import "TOPDocumentTableView.h"
#import "TOPHomeModel.h"
#import "TOPHomePageHeaderView.h"
#import "TOPHomeShowView.h"
#import "TOPChildMoreView.h"
#import "TopScanner-Swift.h"
#import "TOPDataModelHandler.h"
#import "TOPPictureProcessTool.h"
#import "TOPScoreView.h"
#import "TOPTopHideView.h"
#import "TOPAddFolderView.h"
#import "TOPHeadMenuModel.h"
#import "TOPGuideVC.h"
#import "TOPShareFileView.h"
#import "TOPShareFileModel.h"
#import "TOPShareFileDataHandler.h"
#import "TOPSuggestionToastView.h"
#import "DriveDownloadManger.h"
#import "TOPSortTypeView.h"
#import "TOPMainTabBar.h"
#import "TOPNextCollectionView.h"
#import "TopEditFolderAndDocNameVC.h"
@interface TOPHomeViewController ()<UINavigationControllerDelegate,MFMailComposeViewControllerDelegate,TZImagePickerControllerDelegate,UIScrollViewDelegate,UIDocumentPickerDelegate,UIPrintInteractionControllerDelegate,GADAdLoaderDelegate,GADNativeAdLoaderDelegate,GADVideoControllerDelegate,GADBannerViewDelegate,GADFullScreenContentDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer * ges;
@property (nonatomic, assign) CGFloat contentOffSetY;
@property (nonatomic, assign) CGPoint containerOrigin;
@property (nonatomic, strong) TOPTopHideView * topHideView;
@property (nonatomic, strong) UILabel *fileSizeLab;
@property (nonatomic, strong) UIView * scrollowFatherView;
@property (nonatomic, strong) UIView * contentFatherView;
@property (nonatomic, strong) UIView * coverView;
@property (nonatomic, strong) UIView * sortCoverView;
@property (nonatomic, strong) UIView * leftTagsCoverView;
@property (nonatomic, strong) TOPDocumentHeadReusableView * nextListHeaderView;
@property (nonatomic, strong) TOPHomeShowView * topMoreView;
@property (nonatomic, strong) TOPHomeShowView * leftTagsView;
@property (nonatomic, strong) TOPDocumentCollectionView *collectionView;
@property (nonatomic, strong) TOPNextCollectionView *nextCollView;
@property (nonatomic, strong) TOPDocumentTableView *tableView;
@property (nonatomic, strong) TOPScoreView * scoreView;
@property (nonatomic, strong) TOPAddFolderView * addFolderView;
@property (nonatomic, strong) TOPDocPasswordView * passwordView;
@property (nonatomic, copy) NSString * folderViewType;
@property (nonatomic, strong) DocumentModel * docModel;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) UIImageView * blankImg;
@property (nonatomic, strong) NSMutableArray  *homeDataArray;
@property (nonatomic, assign) int folderNum;
@property (nonatomic, assign) BOOL isShowSubscriptView;
@property (nonatomic, assign) BOOL isNewFolder;
@property (nonatomic, assign) int documentNum;
@property (nonatomic, assign) BOOL isNewDocument;
@property (nonatomic, assign) BOOL isShowFailToast;
@property (nonatomic, strong) NSMutableArray *folderIndexArray;
@property (nonatomic, strong) NSMutableArray *documentIndexArray;
@property (nonatomic, strong) UIButton *allSelctBtn;
@property (nonatomic, strong) TOPPhotoLongPressView *pressUpView;
@property (nonatomic, strong) TOPPhotoLongPressView *pressBootomView;
@property (nonatomic, strong) TOPSortTypeView *sortPopView;
@property (nonatomic, strong) TOPShareTypeView * shareAction;
@property (nonatomic, strong) TOPSuggestionToastView *suggestionToastView;
@property (nonatomic, strong) TOPWMDragView *photoView;
@property (nonatomic, strong) TOPSettingEmailModel * emailModel;
@property (nonatomic, assign) NSInteger loadType;
@property (nonatomic, assign) BOOL enterInCamera;
@property (nonatomic, assign) NSInteger emailType;
@property (nonatomic, assign) NSInteger pdfType;
@property (nonatomic, copy) NSString * totalSizeString;
@property (nonatomic, assign) CGFloat  totalSizeNum;
@property (nonatomic, strong) NSMutableArray *docsIndexArray;
@property (nonatomic, strong) NSMutableArray *selectedDocsIndexArray;
@property (nonatomic, strong) NSMutableArray *homeMoreArray;
@property (nonatomic, strong) NSMutableArray *tagsArray;
@property (nonatomic, strong) TOPTagsListModel *selectListModel;
@property (nonatomic, strong) TOPShareFileView *shareFilePopView;
@property (nonatomic, strong) TOPSubscriptionEYearAlertView *alertTipSubscriptView;
@property (nonatomic, strong) GADBannerView * scBannerView;
@property (nonatomic, strong) DocumentModel * nativeAdModel;
@property (nonatomic, strong) GADAdLoader *adLoader;
@property (nonatomic, strong) GADInterstitialAd *interstitial;
@property (nonatomic, assign) CGFloat adViewH;
@property (nonatomic, assign) CGFloat changeEndY;
@property (nonatomic, assign) CGSize currentSize;
@property (nonatomic, assign) BOOL isBanner;
@property (nonatomic, assign) NSInteger navADIndex;
@property (nonatomic, assign) BOOL hasCollection;
@property (nonatomic, strong) dispatch_source_t sourceTimer;
@property (nonatomic, assign) BOOL isTagManager;
@end

@implementation TOPHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adViewH = 0.0;
    self.changeEndY = FatherTop_Y;
    self.isBanner = NO;
    [self top_initGoogleTime];
    [self top_configContentView];
    [self top_dataSync];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(top_GetCamera) name:TOP_TRCenterBtnGetCamera object:nil];
    [self top_freeSizeState];
    [self.nextListHeaderView top_refreshViewTypeBtn];//刷新试图排列样式的图标
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(top_downloadFileDrivesSusess:) name:@"downDrives" object:nil];
    [[UINavigationBar appearance] setTranslucent:NO];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    /*
    if (![TOPScanerShare top_firstOpenStates]) {
        TOPGuideVC * guideVC = [TOPGuideVC new];
        guideVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:guideVC animated:NO];
    }else{
    }*/
    [self top_setupNavBar];
    [self top_initFileManager];
    [self top_initRealmDBDataCompletion:^{
        if (![TOPScanerShare shared].isEditing) {
            if ([TOPScanerShare shared].isReceive) {
                if (![AppDelegate top_getAppDelegate].loadSuccess) {
                    [self top_createDispatch_source_t];
                    [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_loading", @"")];
                    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(top_loadHomeDataSuccess:) name:@"loadHomeData" object:nil];
                } else {
                    if (!self.isTagManager) {
                        [self top_LoadSanBoxData:[TOPScanerShare top_sortType]];
                    }
                }
            }
        }
    }];
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self top_loadDocDataAndAD];
            });
        }];
    } else {
        [self top_loadDocDataAndAD];
    }
    self.photoView.hidden = NO;
    if(self.collectionView.headerView.tagBtn.selected||self.tableView.tipHeaderView.tagBtn.selected||self.nextListHeaderView.tagBtn.selected) {
        self.collectionView.headerView.tagBtn.selected = NO;
        self.tableView.tipHeaderView.tagBtn.selected = NO;
        self.nextListHeaderView.tagBtn.selected = NO;
    }
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.blankImg.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    self.fileSizeLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kTabbarNormal];
    if (self.homeDataArray.count == 0) {
        self.blankImg.hidden = NO;
        self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        self.collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        self.nextCollView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    }else{
        self.blankImg.hidden = YES;
        self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        self.collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        self.nextCollView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    }
    if ([TOPScanerShare top_listType] == ShowListGoods) {
        self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    }else if([TOPScanerShare top_listType] == ShowListNextGoods){
        self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    }else{
        self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    }
}
- (void)top_loadHomeDataSuccess:(NSNotificationCenter *)notification {
    [self top_destroyTimer];
    [self top_LoadSanBoxData:[TOPScanerShare top_sortType]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadHomeData" object:nil];
}

- (void)top_loadDocDataAndAD{
    if (![TOPPermissionManager top_enableByAdvertising]) {
        if (!_scoreView) {
            NSInteger adCount = [TOPScanerShare top_saveInterstitialAdCount];
            if (adCount>3) {
                if (adCount % 3 == 0) {
                    if (!self.interstitial) {
                        [self top_getInterstitialAd];
                    }
                }
            }
        }
    }
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isTagManager = NO;
    if (self.pressBootomView) {
        self.ges.enabled = NO;
    }else{
        self.ges.enabled = YES;
    }
    [self top_restoreBannerAD:self.view.size];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self top_sortTap];
    self.ges.enabled = NO;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    };
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self top_removeBannerView];
    if (![TOPScanerShare shared].isEditing) {
        if (self.tabBarController.selectedIndex == 0) {
            self.nativeAdModel = nil;
            self.navADIndex = 0;
        }
    }
}
#pragma mark -- 横竖屏切换时重新设置titleView
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self top_setupNavBar];
    if (self.tabBarController.selectedIndex == 0) {
        if (self.homeDataArray.count) {
            [self.collectionView reloadData];
        }
    }
    if (self.shareFilePopView) {
        [self.shareFilePopView top_updateSubViewsLayout];
    }
    if (self.alertTipSubscriptView) {
        [self.alertTipSubscriptView.collectionView reloadData];
    }
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
#pragma mark -- 加载横幅广告
- (void)top_changeBannerViewFream:(CGSize)size{
    self.currentSize = size;
    if (![TOPPermissionManager top_enableByAdvertising]) {
        if (!self.isBanner) {
            [self top_AddBannerViewWithSize:size];
        }else{
            if (!self.scBannerView.hidden) {
                GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(size.width);
                self.adViewH = adSize.size.height;
            }
            [self top_adFinishContentFatherFream];
        }
    } else {
        [self top_removeBannerView];
    }
}
#pragma mark -- 隐藏横幅广告视图
- (void)top_removeBannerView{
    [self top_adFailContentFatherFream];
    [self.scBannerView removeFromSuperview];
    self.scBannerView = nil;
    self.isBanner = NO;
}
#pragma mark -- 初始化数据库数据 写入数据只执行一次
- (void)top_initRealmDBDataCompletion:(void (^)(void))completion {
    if (![TOPDBDataHandler top_hasDBData]) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_showstatustitle", @"")];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [TOPDBDataHandler top_loadingRealmDBData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if (completion) {
                    completion();
                }
            });
        });
    } else {
        if (completion) {
            completion();
        }
    }
}
#pragma mark -- 同步数据（自检）
- (void)top_dataSync {
    BOOL hasData = [[NSUserDefaults standardUserDefaults] boolForKey:@"RealmDataKey"];//对数据库有过写入
    if (hasData) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [TOPDBDataHandler top_synchronizeRealmDBDataProgress:nil];
        });
    }
}

- (void)top_initFileManager {
    DocumentModel *model = [[DocumentModel alloc] init];
    model.docId = @"000000";
    model.type = @"0";
    model.path = [TOPDocumentHelper top_getDocumentsPathString];
    [TOPFileDataManager shareInstance].docModel = model;
}
#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    
    if (_addFolderView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            self.addFolderView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_W, AddFolder_W, AddFolder_W);
        }];
    }
    if (_passwordView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            if (self.passwordView.actionType == TOPHomeMoreFunctionSetLockFirst|| self.passwordView.actionType == TOPHomeMoreFunctionPDFPassword) {
                self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_H, AddFolder_W, AddFolder_H);
            }else{
                self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolderSingle_H, AddFolder_W, AddFolderSingle_H);
            }
        }];
    }
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    if (_passwordView) {
        if (![self.passwordView.tField isFirstResponder]&&![self.passwordView.againField isFirstResponder]) {
            [self top_ClickTapAction];
        }
    }
    
    if (_addFolderView) {
        if (![self.addFolderView.tField  isFirstResponder]) {
            [self top_ClickTapAction];
        }
    }
}
#pragma mark -- 网盘批量下载成功通知
- (void)top_downloadFileDrivesSusess:(NSNotificationCenter *)notification
{
    [self top_LoadSanBoxData:[TOPScanerShare top_sortType]];
}
- (void)top_changeViewFream:(NSNotificationCenter *)notification{
    CGFloat myTab = self.tabBarController.tabBar.size.height;
    if ([TOPScanerShare shared].isEditing) {
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.equalTo(self.scrollowFatherView);
            make.bottom.equalTo(self.view).offset(-myTab);
        }];
    }
}
- (void)top_addUIPanGestureRecognizer{
    UIPanGestureRecognizer * ges = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(top_panGestureRecognized:)];
    ges.delegate = self;
    self.ges = ges;
    [self.scrollowFatherView addGestureRecognizer:ges];
}

- (void)top_panGestureRecognized:(UIPanGestureRecognizer *)recognizer{
    CGPoint point = [recognizer translationInView:self.scrollowFatherView];
    CGFloat headMenuViewH =FatherTop_Y;
    CGFloat topViewH = 0;
    CGRect frame = recognizer.view.frame;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.containerOrigin = recognizer.view.frame.origin;
    }
    
    if (frame.origin.y == topViewH) {
        NSLog(@"point.y==%f",point.y);
        if (self.contentOffSetY>=0) {
            frame.origin.y = topViewH;
        }else{
            NSLog(@"containerOrigin==%f   point.y == %f",self.containerOrigin.y,point.y);
            frame.origin.y = self.containerOrigin.y + point.y;
            NSLog(@"frame.y==%f",frame.origin.y);
        }
        recognizer.view.frame = CGRectMake(0, frame.origin.y, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-TOPTabBarHeight-frame.origin.y);
        self.changeEndY = frame.origin.y;
    }else{
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            NSLog(@"containerOrigin==%f   point.y == %f",self.containerOrigin.y,point.y);
            frame.origin.y = self.containerOrigin.y + point.y;
            NSLog(@"framey==%f",frame.origin.y);
            
            if (frame.origin.y >= headMenuViewH) {
                frame.origin.y = headMenuViewH;
            }
            if (frame.origin.y <= topViewH) {
                frame.origin.y = topViewH;
            }
            
            if (frame.origin.y == headMenuViewH||frame.origin.y == topViewH) {
            }else{
                self.tableView.contentOffset = CGPointMake(0, 0);
                self.nextCollView.contentOffset = CGPointMake(0, 0);
                self.collectionView.contentOffset = CGPointMake(0, 0);
            }
            recognizer.view.frame = CGRectMake(0, frame.origin.y, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-TOPTabBarHeight-frame.origin.y);
            self.changeEndY = frame.origin.y;
        }
        
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [recognizer setTranslation:CGPointZero inView:self.scrollowFatherView];
            self.containerOrigin = CGPointZero;
            CGRect frame = recognizer.view.frame;
            if (frame.origin.y >= headMenuViewH/2) {
                frame.origin.y = headMenuViewH;
            }
            if (frame.origin.y < headMenuViewH/2) {
                frame.origin.y = topViewH;
            }
            [UIView animateWithDuration:0.3 animations:^{
                recognizer.view.frame = CGRectMake(0, frame.origin.y, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-TOPTabBarHeight-frame.origin.y);
                self.changeEndY = frame.origin.y;
            }];
        }
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
- (void)top_resetScrollowFatherViewFream:(CGFloat)freamY{
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollowFatherView.frame = CGRectMake(0, freamY, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-Bottom_H-freamY);
    }];
}
- (void)top_restScrollowFatherViewLayer:(CGFloat)cornerRadius{
    self.scrollowFatherView.layer.cornerRadius = cornerRadius;
    self.scrollowFatherView.layer.masksToBounds = YES;
}
#pragma mark -- 布局界面
- (void)top_configContentView {
    [TOPScanerShare shared].isEditing = NO;
    _emailType = 0;
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    [self top_JudgeFolder];
    UIImageView * blankImg = [[UIImageView alloc]initWithFrame:CGRectMake((TOPScreenWidth-100)/2, (TOPScreenHeight-(298*100)/325-100)/2, 100, (298*100)/325)];
    blankImg.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    blankImg.image = [UIImage imageNamed:@"top_blankfirstvc"];
    self.blankImg = blankImg;
    blankImg.hidden = YES;
    
    [self.view addSubview:self.topHideView];
    [self.view addSubview:self.scrollowFatherView];
    [self.scrollowFatherView addSubview:self.nextListHeaderView];
    [self.scrollowFatherView addSubview:self.contentFatherView];
    [self.contentFatherView addSubview:self.collectionView];
    [self.contentFatherView addSubview:self.nextCollView];
    [self.contentFatherView addSubview:self.tableView];
    [self.contentFatherView addSubview:self.blankImg];
    [self.contentFatherView addSubview:self.fileSizeLab];
    
    [self.topHideView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.mas_equalTo(FatherTop_Y+10);
    }];
    BOOL isShowVip = NO;
    if (![TOPUserInfoManager shareInstance].isVip) {//用户订阅之后不再显示
        isShowVip = YES;
    }
    [self top_listNextViewState:isShowVip];
    [self top_setContentFatherViewDefaultMask];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(self.contentFatherView);
    }];
    [self.nextCollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(self.contentFatherView);
    }];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(self.contentFatherView);
    }];
    [blankImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.contentFatherView);
    }];
    [self.fileSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentFatherView);
        make.height.mas_equalTo(30);
    }];
    [self top_addUIPanGestureRecognizer];
}
- (void)top_setContentFatherViewDefaultMask{
    CGFloat bottomH = 0;
    if (self.isBanner) {
        bottomH = TOPTabBarHeight+self.adViewH;
    }else{
        bottomH = TOPTabBarHeight;
    }
    if (self.nextListHeaderView.hidden) {
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.top.equalTo(self.scrollowFatherView);
            make.bottom.equalTo(self.view).offset(-bottomH);
        }];
    }else{
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self.scrollowFatherView);
            make.top.equalTo(self.nextListHeaderView.mas_bottom);
            make.bottom.equalTo(self.view).offset(-bottomH);
        }];
    }
}
- (void)top_setListNextViewMask:(CGFloat)listHeaderH{
    [self.nextListHeaderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.scrollowFatherView);
        make.height.mas_equalTo(listHeaderH);
    }];
}
#pragma mark -- Google时间
- (void)top_initGoogleTime {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[TOPScannerHttpRequest shareManager] top_loadWanleFinishState];
    });
}

#pragma mark -- 评分弹框
- (void)top_showScoreView{
    [FIRAnalytics logEventWithName:@"showScoreView" parameters:nil];
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.coverView];
    [keyWindow addSubview:self.scoreView];
    [self top_markupCoverMask];
    
    NSString * titleString = NSLocalizedString(@"topscan_scoretitle", @"");
    CGFloat titleH = [TOPDocumentHelper top_getSizeWithStr:titleString Width:TOPScreenWidth-100 Font:17].height+10;
    if (IS_IPAD) {
        [self.scoreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(keyWindow);
            make.height.mas_equalTo(160+titleH);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.scoreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(keyWindow).offset(20);
            make.trailing.equalTo(keyWindow).offset(-20);
            make.centerY.equalTo(keyWindow.mas_centerY);
            make.height.mas_equalTo(160+titleH);
        }];
    }
}

#pragma mark --LoadData 从沙盒里面获取数据
- (void)top_LoadSanBoxData:(NSInteger)type{
    __block NSMutableArray * tagsListArray = [AppDelegate top_getAppDelegate].homeDataArr.mutableCopy;
    [[AppDelegate top_getAppDelegate].homeDataArr removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!tagsListArray.count) {
            tagsListArray = [TOPDataModelHandler top_getTagsListManagerData];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_loadDataCompleteRefresh:tagsListArray];
        });
    });
}

#pragma mark -- 加载完数据后刷新界面
- (void)top_loadDataCompleteRefresh:(NSMutableArray *)tagsListArray {
    self.tagsArray = tagsListArray;
    [self top_printDocCount];
    [self top_PopupViewShow];
    NSString * tagsName = [TOPScanerShare top_saveTagsName];
    BOOL isFinish = NO;
    if (tagsListArray.count) {
        [TOPFileDataManager shareInstance].allListModel = tagsListArray[0];//所有文档的标签模型
    }
    for (TOPTagsListModel * model in tagsListArray) {
        if ([model.tagName isEqualToString:tagsName]) {
            isFinish = YES;
            [self top_refreshAndShowTagsDoc:model];
            [self top_restoreNativeAd];
            break;
        }else{
            self.fileSizeLab.hidden = YES;
        }
    }
    if (!isFinish) {
        if (tagsListArray.count) {
            TOPTagsListModel * model = tagsListArray[0];
            [self top_refreshAndShowTagsDoc:model];
            [self top_restoreNativeAd];
        }else{
            self.fileSizeLab.hidden = YES;
        }
    }
}
- (void)top_restoreNativeAd{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    [FIRAnalytics logEventWithName:@"ATTrackingManagerAuthorized" parameters:nil];
                }else{
                    [FIRAnalytics logEventWithName:@"ATTrackingManagerDenied" parameters:nil];
                }
                [self top_nativeAdShowState];
            });
        }];
    } else {
        [self top_nativeAdShowState];
    }
}
#pragma mark-- 1.订阅弹框 2.评分弹框 3.反馈弹框 三个弹框的显示顺序的处理
- (void)top_PopupViewShow{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self top_showSubscriptAlertView];
    });
    if (!self.isShowSubscriptView) {
        [self top_judgeScoreView];
    }
}
#pragma mark -- 文档数据获取之后根据用户状态将原生广告数据添加进去
- (void)top_nativeAdShowState{
    if (self.homeDataArray.count) {
        if (![TOPPermissionManager top_enableByAdvertising]) {
            if (!self.nativeAdModel) {
                [self top_getNativeAd];
            }
        }else{
            if (self.nativeAdModel) {
                self.nativeAdModel = nil;
            }
        }
    }
}
#pragma mark -- 点击标签 刷新界面
- (void)top_refreshAndShowTagsDoc:(TOPTagsListModel *)model{
    self.homeDataArray = [model.docArray mutableCopy];
    self.collectionView.listArray = self.homeDataArray;
    self.tableView.listArray = self.homeDataArray;
    self.nextCollView.listArray = self.homeDataArray;
    
    if (self.homeDataArray.count) {
        if (![TOPPermissionManager top_enableByAdvertising]) {
            if (self.nativeAdModel) {
                [self top_adReceiveFinishAndRefreshUI];
            }
        }
    }
    self.collectionView.model = model;
    self.tableView.model = model;
    self.nextCollView.model = model;
    self.nextListHeaderView.model = model;
    [self top_refreshUI];
    
    self.selectListModel = model;
    [self top_sumAllFileSize];
    
    if ([TOPScanerShare top_listType] == ShowListGoods) {
        self.tableView.hidden = NO;
        self.nextCollView.hidden = YES;
        self.collectionView.hidden = YES;
        self.nextListHeaderView.hidden = YES;
        self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    }else if([TOPScanerShare top_listType] == ShowListNextGoods){
        self.tableView.hidden = YES;
        self.nextCollView.hidden = NO;
        self.collectionView.hidden = YES;
        self.nextListHeaderView.hidden = NO;
        self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    }else{
        self.tableView.hidden = YES;
        self.nextCollView.hidden = YES;
        self.collectionView.hidden = NO;
        self.nextListHeaderView.hidden = NO;
        self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    }
    [self top_setContentFatherViewDefaultMask];
    if (self.homeDataArray.count == 0) {
        self.blankImg.hidden = NO;
        self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        self.collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        self.nextCollView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    }else{
        self.blankImg.hidden = YES;
        self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        self.collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        self.nextCollView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    }
}
#pragma mark -- 显示文件大小的lab
- (void)top_sumAllFileSize {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        long total = [TOPDocumentHelper top_calculateAllFilesSize:self.homeDataArray];
        NSString *sizeStr = [TOPDocumentHelper top_memorySizeStr:(total *1.0)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BOOL isShow;
            if ([TOPScanerShare top_listType] == ShowListGoods) {
                isShow = self.tableView.contentSize.height > (self.tableView.bounds.size.height - 30) ? YES : NO;
            }else if([TOPScanerShare top_listType] == ShowListNextGoods){
                isShow = self.nextCollView.contentSize.height > (self.nextCollView.bounds.size.height - 30) ? YES : NO;
            }else{
                isShow = self.collectionView.contentSize.height > (self.collectionView.bounds.size.height - 30) ? YES : NO;
            }
            if (!self.homeDataArray.count) {
                self.fileSizeLab.hidden = YES;
            }else{
                self.fileSizeLab.hidden = isShow;
            }
            self.fileSizeLab.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"topscan_filesize", @""), sizeStr];
        });
        
    });
}
#pragma mark --打印app中doc文档的数量
- (void)top_printDocCount{
    if (self.tagsArray.count>0) {
        TOPTagsListModel * listModel = self.tagsArray[0];
        NSInteger num = [listModel.tagNum integerValue];
        NSString * sendString = [NSString new];
        if (num>=100) {
            if (num>=1000) {
                sendString = @"MoreThan1000";
            }else{
                NSInteger sendNum = (num/100+1)*100;
                sendString = [NSString stringWithFormat:@"%ld",sendNum];
            }
        }else{
            NSInteger sendNum = (num/10+1)*10;
            sendString = [NSString stringWithFormat:@"%ld",sendNum];
        }
        [FIRAnalytics logEventWithName:[NSString stringWithFormat:@"DocumentsCount_%@",sendString] parameters:nil];
    }
}

#pragma mark -- 根据选中的文件来刷新界面底部按钮状态
- (void)top_RefreshViewWithSelectItem {
    [FIRAnalytics logEventWithName:@"homeView_RefreshViewWithSelectItem" parameters:nil];
    [TOPScanerShare shared].isEditing = YES;
    NSInteger docCount = 0;
    NSInteger folderCount = 0;
    TOPItemsSelectedState selectedState = TOPItemsSelectedNone;
    NSMutableArray *selectedArray = [NSMutableArray array];
    for (DocumentModel *model in self.homeDataArray) {
        if (model.selectStatus == YES) {
            [selectedArray addObject:model];
            if ([model.type isEqualToString:@"1"]) {//doc
                docCount ++;
            }
            if ([model.type isEqualToString:@"0"]) {//folder
                folderCount ++;
            }
        }
    }
    if (!selectedArray.count) {
        selectedState = TOPItemsSelectedNone;
    } else {
        if (docCount == 1 && !folderCount) {
            selectedState = TOPItemsSelectedOneDoc;
        } else if (docCount > 1 && !folderCount) {
            selectedState = TOPItemsSelectedSomeDoc;
        } else if (folderCount == 1 && !docCount) {
            selectedState = TOPItemsSelectedOneFolder;
        } else if (folderCount > 1 && !docCount) {
            selectedState = TOPItemsSelectedSomeFolder;
        } else if (docCount == 1 && folderCount == 1) {
            selectedState = TOPItemsSelectedOneDoc | TOPItemsSelectedOneFolder;
        } else if (docCount == 1 && folderCount > 1) {
            selectedState = TOPItemsSelectedOneDoc | TOPItemsSelectedSomeFolder;
        } else if (docCount > 1 && folderCount == 1) {
            selectedState = TOPItemsSelectedSomeDoc | TOPItemsSelectedOneFolder;
        } else if (docCount > 1 && folderCount > 1) {
            selectedState = TOPItemsSelectedSomeDoc | TOPItemsSelectedSomeFolder;
        }
    }
    [self.pressUpView top_configureSelectedCount:selectedArray.count];
    if (selectedArray.count == [self removeAdModelArray].count) {
        self.pressUpView.allSelectBtn.selected = YES;
    }else{
        self.pressUpView.allSelectBtn.selected = NO;
    }
    [self.pressBootomView top_changePressViewBtnState:selectedState];
}

- (void)top_JudgeFolder{
    [FIRAnalytics logEventWithName:@"homeView_JudgeFolder" parameters:nil];
    [TOPDocumentHelper top_initializationFolder];
}
#pragma mark --跳转到tags管理界面
- (void)top_jumpToTagsManagerVC{
    WS(weakSelf);
    TOPTagsManagerViewController * managerVC = [TOPTagsManagerViewController new];
    managerVC.top_clickTagManageBlock = ^(TOPTagsListModel * _Nonnull model) {
        weakSelf.isTagManager = YES;
        [weakSelf top_refreshAndShowTagsDoc:model];
        [weakSelf top_nativeAdShowState];
        [weakSelf top_ClickLeftTapAction];
    };
    managerVC.dataArray = self.tagsArray;
    managerVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:managerVC animated:YES];
}
#pragma mark -- 展示tag列表
- (void)top_showTagsView{
    [FIRAnalytics logEventWithName:@"homeView_showTagsView" parameters:nil];
//    [self top_sortTap];
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    self.leftTagsCoverView.backgroundColor = [UIColor clearColor];
    self.leftTagsCoverView.userInteractionEnabled = YES;
    [keyWindow addSubview:self.leftTagsCoverView];
    [keyWindow addSubview:self.leftTagsView];
    
    [self.leftTagsCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
    [self.leftTagsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(keyWindow).offset(10);
        make.top.equalTo(keyWindow).offset(TOPNavBarAndStatusBarHeight+TopView_H+self.changeEndY);
        make.size.mas_equalTo(CGSizeMake(220, [self top_getLeftTagsViewH]));
        make.width.mas_equalTo(220);
    }];
    self.leftTagsView.showType = TOPHomeShowViewLocationTypeTopLeft;
    self.leftTagsView.dataArray = self.tagsArray;
}

#pragma mark --计算tags列表的高度
- (CGFloat)top_getLeftTagsViewH{
    CGFloat leftTagsViewH = 0;
    CGFloat restH = 0.0;
    if (IS_IPAD) {
        restH = IPAD_CELLW;
    }else{
        restH = TOPScreenHeight-TOPNavBarAndStatusBarHeight-TopView_H-TOPBottomSafeHeight-60;
    }
    CGFloat allCellH = (self.tagsArray.count+1)*50;
    if (allCellH>restH) {
        leftTagsViewH = restH;
    }else{
        leftTagsViewH = allCellH;
    }
    return leftTagsViewH;
}

#pragma mark -- 全选
- (void)top_AllSelectAction:(BOOL)selected {
    [FIRAnalytics logEventWithName:@"homeView_AllSelectAction" parameters:@{@"select":@(selected)}];
    [self.selectedDocsIndexArray removeAllObjects];
    NSMutableArray *editArray = [NSMutableArray array];
    for (DocumentModel *model in  self.homeDataArray) {
        if (!model.isAd) {
            model.selectStatus = selected;
            if (selected) {
                [self.selectedDocsIndexArray addObject:model];
            }
        }
        [editArray addObject:model];
    }
    [self top_RefreshViewWithSelectItem];
    self.collectionView.listArray = editArray;
    [self.collectionView reloadData];
    
    self.tableView.listArray = editArray;
    [self.tableView reloadData];
    
    self.nextCollView.listArray = editArray;
    [self.nextCollView reloadData];
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
#pragma mark -- 根据选中的数据来确定密码视图的展示与否
- (void)top_judgePasswordViewState:(NSInteger)index{
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        NSArray *funcIndexArray = [self top_FuncItems];
        NSNumber *funcNum = funcIndexArray[index];
        if ([funcNum integerValue] == TOPMenuItemsFunctionShare) {
            if (isReopened) {
                [self top_showCellularView];
            }else{
                [self top_wlanOpenedJudgePasswordViewState:index];
            }
        }else{
            [self top_wlanOpenedJudgePasswordViewState:index];
        }
    }];
}
- (void)top_wlanOpenedJudgePasswordViewState:(NSInteger)index{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * passwordArray = [TOPDocumentHelper top_getSelectLockState:self.homeDataArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (passwordArray.count>0) {
                UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
                [keyWindow addSubview:self.coverView];
                [self top_markupCoverMask];
                [keyWindow addSubview:self.passwordView];
                NSArray *funcIndexArray = [self top_FuncItems];
                NSNumber *funcNum = funcIndexArray[index];
                switch ([funcNum integerValue]) {
                    case TOPMenuItemsFunctionShare:
                        self.passwordView.actionType = TOPMenuItemsFunctionShare;
                        break;
                    case TOPMenuItemsFunctionMerge:
                        self.passwordView.actionType = TOPMenuItemsFunctionMerge;
                        break;
                    case TOPMenuItemsFunctionCopyMove:
                        self.passwordView.actionType = TOPMenuItemsFunctionCopyMove;
                        break;
                    case TOPMenuItemsFunctionDelete:
                        self.passwordView.actionType = TOPMenuItemsFunctionDelete;
                        break;
                    case TOPMenuItemsFunctionMore:
                        self.passwordView.actionType = TOPMenuItemsFunctionMore;
                        break;
                    case TOPMenuItemsFunctionRename:
                        self.passwordView.actionType = TOPMenuItemsFunctionRename;
                        break;
                    default:
                        break;
                }
            }else{
                [self top_InvokeMenuFunctionAtIndex:index];
            }
        });
    });
}
#pragma mark -- 点击doc时有无密码的判断
- (void)top_judgeClickDocPasswordState{
    NSString * passwordPath = self.docModel.docPasswordPath;
    if (passwordPath.length>0) {
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        [keyWindow addSubview:self.coverView];
        [self top_markupCoverMask];
        [keyWindow addSubview:self.passwordView];
        self.passwordView.actionType = TOPMenuItemsFunctionPushVC;
    }else{
        [self top_clickDocPushChildVCWithPath];
    }
}

#pragma mark -- 跳转到childVC
- (void)top_clickDocPushChildVCWithPath{
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    childVC.docModel = self.docModel;
    childVC.pathString = self.docModel.path;
    childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
    childVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:childVC animated:YES];
}
#pragma mark -- 长按开始编辑中文件时弹出菜单
- (void)top_ShowPressUpView{
    [FIRAnalytics logEventWithName:@"homeView_ShowPressUpView" parameters:nil];
    weakify(self);
    SS(strongSelf);
    weakSelf.tabBarController.tabBar.hidden = YES;
    weakSelf.ges.enabled = NO;
    [weakSelf top_resetScrollowFatherViewFream:0];
    [weakSelf top_restScrollowFatherViewLayer:0];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    strongSelf.photoView.hidden = YES;
    [TOPScanerShare shared].isEditing = YES;
    [strongSelf top_HideHeaderView];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    if (!strongSelf.pressUpView) {
        strongSelf.pressUpView = [[TOPPhotoLongPressView alloc] initWithPressUpFrame:CGRectMake(0, -TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPNavBarAndStatusBarHeight)];
        strongSelf.pressUpView.top_cancleEditHandler = ^{
            [weakSelf top_CancleSelectAction];
        };
        
        strongSelf.pressUpView.top_selectAllHandler = ^(BOOL selected) {
            [weakSelf top_AllSelectAction:selected];
        };
        
        [window addSubview:strongSelf.pressUpView];
        [strongSelf.pressUpView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(window);
            make.top.equalTo(window).offset(-TOPNavBarAndStatusBarHeight);
            make.height.mas_equalTo(TOPNavBarAndStatusBarHeight);
        }];
    }
    
    if (!strongSelf.pressBootomView) {
        NSArray * sendPicArray = [strongSelf top_SendPicArray];
        NSArray * sendNameArray = [strongSelf top_SendNameArray];
        strongSelf.pressBootomView = [[TOPPhotoLongPressView alloc] initWithPressBottomFrame: CGRectMake(0, TOPScreenHeight, TOPScreenWidth, (60)) sendPicArray:sendPicArray sendNameArray:sendNameArray];
        strongSelf.pressBootomView.selectedImgs = [strongSelf top_SendPicArray];
        strongSelf.pressBootomView.disableImgs = [strongSelf top_PicArray];
        strongSelf.pressBootomView.funcArray = [strongSelf top_FuncItems];
        strongSelf.pressBootomView.top_longPressBootomItemHandler = ^(NSInteger index) {
            __weak typeof(self) weakSelf = self;
            weakSelf.emailType = 0;
            [weakSelf top_judgePasswordViewState:index];
        };
        [self.view addSubview:strongSelf.pressBootomView];
        [strongSelf.pressBootomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(Bottom_H);
            make.height.mas_equalTo(Bottom_H);
        }];
        
        UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, TOPScreenWidth, TOPBottomSafeHeight)];
        bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.bottomView = bottomView;
        [self.view addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(TOPBottomSafeHeight);
            make.height.mas_equalTo(TOPBottomSafeHeight);
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self top_CancleSelectChangeFream];
        }];
    });
}

- (void)top_CancleSelectChangeFream{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [self.pressUpView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(window);
    }];
    if (!self.isBanner) {
        [self.pressBootomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        }];
    }else{
        [self.scBannerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        }];
        [self.pressBootomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
        }];
    }
    
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
    [window layoutIfNeeded];
    [self.view layoutIfNeeded];
}

- (void)top_CancleSelectResetFream{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    if ([window.subviews containsObject:self.pressUpView]&&[self.view.subviews containsObject:self.pressBootomView]&&[self.view.subviews containsObject:self.bottomView]) {
        [self.pressUpView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(window).offset(-TOPNavBarAndStatusBarHeight);
        }];
        if (!self.isBanner) {
            [self.pressBootomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view).offset(Bottom_H);
            }];
        }else{
            [self.scBannerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
            }];
            [self.pressBootomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view).offset(Bottom_H+self.adViewH+TOPBottomSafeHeight);
            }];
        }
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(TOPBottomSafeHeight);
        }];
        [window layoutIfNeeded];
        [self.view layoutIfNeeded];
    }
}

#pragma mark -- 取消选择
- (void)top_CancleSelectAction {
    [FIRAnalytics logEventWithName:@"homeView_CancleSelectAction" parameters:nil];
    [UIView animateWithDuration:0.3 animations:^{
        [self top_CancleSelectResetFream];
    } completion:^(BOOL finished) {
        [self.pressUpView  removeFromSuperview];
        [self.pressBootomView removeFromSuperview];
        [self.bottomView removeFromSuperview];
        self.pressBootomView = nil;
        self.pressUpView = nil;
        self.bottomView = nil;
        self.ges.enabled = YES;
    }];
    self.photoView.hidden = NO;
    [self top_resetScrollowFatherViewFream:self.changeEndY];
    [self top_restScrollowFatherViewLayer:5];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.tabBarController.tabBar.hidden = NO;
    [self top_ShowHeaderView];
    [TOPScanerShare shared].isEditing = NO;
    [self.selectedDocsIndexArray removeAllObjects];
    for (DocumentModel *model in self.homeDataArray) {
        model.selectStatus = NO;
    }
    self.collectionView.listArray = self.homeDataArray;
    [self.collectionView setShowType:[TOPScanerShare top_listType]];
    
    self.tableView.listArray = self.homeDataArray;
    [self.tableView reloadData];
    
    self.nextCollView.listArray = self.homeDataArray;
    [self.nextCollView reloadData];
}

#pragma mark -- 调用底部菜单事件
- (void)top_InvokeMenuFunctionAtIndex:(NSInteger)index {
    [FIRAnalytics logEventWithName:@"homeView_InvokeMenuFunctionAtIndex" parameters:@{@"index":@(index)}];
    NSArray *funcIndexArray = [self top_FuncItems];
    NSNumber *funcNum = funcIndexArray[index];
    switch ([funcNum integerValue]) {
        case TOPMenuItemsFunctionShare:
            [self top_ShareTip];
            break;
        case TOPMenuItemsFunctionMerge:
            [self top_MergeFileMethod];
            break;
        case TOPMenuItemsFunctionCopyMove:
            [self top_EditFileMethod];
            break;
        case TOPMenuItemsFunctionDelete:
            [self top_DeleteTip];
            break;
        case TOPMenuItemsFunctionMore:
            [self top_EditMoreMethod];
            NSLog(@"更多");
            break;
        case TOPMenuItemsFunctionRename:
            [self top_ClickToChangeFolderName];
            break;
        default:
            break;
    }
}
#pragma mark -- 多个doc文档 只要有一个没有被标记 弹框显示的图标就是文档没有被标记的图标
- (NSString *)top_judgeDocCollectionState{
    NSString * collectionIcon = [NSString new];
    BOOL hasCollection = YES;
    for (DocumentModel * model in self.selectedDocsIndexArray) {
        if (!model.collectionstate) {
            hasCollection = NO;
        }
    }
    self.hasCollection = hasCollection;
    if (hasCollection) {
        collectionIcon = @"top_childvc_morehasCollected";
    }else{
        collectionIcon = @"top_childvc_moreCollection";
    }
    return collectionIcon;
}
#define mark -- 底部更多视图
- (void)top_EditMoreMethod{
    [FIRAnalytics logEventWithName:@"homeView_EditMoreMethod" parameters:nil];
    [self.homeMoreArray removeAllObjects];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger moreType = [self top_judgeSetTagsState];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray * titleArray = [NSArray new];
            NSArray * iconArray = [NSArray new];
            NSArray * moreArray = [NSArray new];
            NSString * collectionIcon = [self top_judgeDocCollectionState];
            NSString *passwordTitle = [[TOPScanerShare top_pdfPassword] length] ? NSLocalizedString(@"topscan_pdfpasswordclear", @"") : NSLocalizedString(@"topscan_pdfpassword", @"");
            if (moreType == TOPHomeMoreFunctionTypeSomeDocUnLock) {
                titleArray = @[NSLocalizedString(@"topscan_docpasswordunlockicon", @""),NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_ocr", @""),NSLocalizedString(@"topscan_childimportant", @""),NSLocalizedString(@"topscan_savetogallery", @"")];
                iconArray = @[@"top_unlock",@"top_homemail",@"top_childvc_moreOCR",collectionIcon,@"top_childvc_morepic"];
                moreArray = @[@(TOPHomeMoreFunctionUnLock),@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionDocCollection),@(TOPHomeMoreFunctionSaveToGrallery)];
            }else if(moreType == TOPHomeMoreFunctionTypeSomeDocSetLock){
                titleArray = @[NSLocalizedString(@"topscan_docpasswordicon", @""),NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_ocr", @""),NSLocalizedString(@"topscan_childimportant", @""),NSLocalizedString(@"topscan_savetogallery", @"")];
                iconArray = @[@"top_lock",@"top_homemail",@"top_childvc_moreOCR",collectionIcon,@"top_childvc_morepic",];
                moreArray = @[@(TOPHomeMoreFunctionSetLock),@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionDocCollection),@(TOPHomeMoreFunctionSaveToGrallery)];
            }else if(moreType == TOPHomeMoreFunctionTypeOneDocUnLock){//homeMoreDocRemind
                titleArray = @[NSLocalizedString(@"topscan_docpasswordunlockicon", @""),
                               NSLocalizedString(@"topscan_editpdf", @""),
                               NSLocalizedString(@"topscan_siderename", @""),
                               NSLocalizedString(@"topscan_childimportant", @""),
                               NSLocalizedString(@"topscan_email", @""),
                               NSLocalizedString(@"topscan_homemoredocremind", @""),
                               NSLocalizedString(@"topscan_ocr", @""),
                               NSLocalizedString(@"topscan_savetogallery", @""),
                               passwordTitle];
                iconArray = @[@"top_unlock",@"top_editPDF",@"top_folderRename",collectionIcon,@"top_homemail",@"top_childvc_morebell",@"top_childvc_moreOCR",@"top_childvc_morepic",@"top_menu_pdfPassword"];
                moreArray = @[@(TOPHomeMoreFunctionUnLock),@(TOPHomeMoreFunctionPDF),@(TOPHomeMoreFunctionDocRename),@(TOPHomeMoreFunctionDocCollection),@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionDocRemaind),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery),@(TOPHomeMoreFunctionPDFPassword)];
            }else if(moreType == TOPHomeMoreFunctionTypeOneDocSetLock){
                titleArray = @[NSLocalizedString(@"topscan_docpasswordicon", @""),
                               NSLocalizedString(@"topscan_editpdf", @""),
                               NSLocalizedString(@"topscan_siderename", @""),
                               NSLocalizedString(@"topscan_childimportant", @""),
                               NSLocalizedString(@"topscan_email", @""),
                               NSLocalizedString(@"topscan_homemoredocremind", @""),
                               NSLocalizedString(@"topscan_ocr", @""),
                               NSLocalizedString(@"topscan_savetogallery", @""),
                               passwordTitle];
                iconArray = @[@"top_lock",@"top_editPDF",@"top_folderRename",collectionIcon,@"top_homemail",@"top_childvc_morebell",@"top_childvc_moreOCR",@"top_childvc_morepic",@"top_menu_pdfPassword"];
                moreArray = @[@(TOPHomeMoreFunctionSetLock),@(TOPHomeMoreFunctionPDF),@(TOPHomeMoreFunctionDocRename),@(TOPHomeMoreFunctionDocCollection),@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionDocRemaind),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery),@(TOPHomeMoreFunctionPDFPassword)];
            }else if(moreType == TOPHomeMoreFunctionTypeFolderAndDoc){
                titleArray = @[NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_ocr", @""),NSLocalizedString(@"topscan_savetogallery", @"")];
                iconArray = @[@"top_homemail",@"top_childvc_moreOCR",@"top_childvc_morepic"];
                moreArray = @[@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery)];
            }else if(moreType == TOPHomeMoreFunctionTypeSomeFolder){
                titleArray = @[NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_ocr", @""),NSLocalizedString(@"topscan_savetogallery", @"")];
                iconArray = @[@"top_homemail",@"top_childvc_moreOCR",@"top_childvc_morepic"];
                moreArray = @[@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery)];
            }else if(moreType == TOPHomeMoreFunctionTypeOneFolder){
                titleArray = @[NSLocalizedString(@"topscan_siderename", @""),NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_ocr", @""),NSLocalizedString(@"topscan_savetogallery", @"")];
                iconArray = @[@"top_folderRename",@"top_homemail",@"top_childvc_moreOCR",@"top_childvc_morepic"];
                moreArray = @[@(TOPHomeMoreFunctionFolderRename),@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery)];
            }
            [self.homeMoreArray addObjectsFromArray:moreArray];
            
            DocumentModel * docModel = [DocumentModel new];
            if (self.selectedDocsIndexArray.count == 1) {
                docModel = self.selectedDocsIndexArray[0];
            }
            TOPChildMoreView * moreView = [[TOPChildMoreView alloc]initWithTitleView:[UIView new] optionsArr:titleArray iconArr:iconArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
            } selectBlock:^(NSInteger index) {
                NSNumber * num = weakSelf.homeMoreArray[index];
                [weakSelf top_ClickMoreViewAction:[num integerValue]];
            }];
            moreView.menuItems = moreArray;
            NSArray *menuItems = [self top_headMenuItems:moreType];
            moreView.docModel = docModel;
            moreView.headMenuItems = menuItems;
            moreView.showHeadMenu = YES;
            moreView.top_selectedHeadMenuBlock = ^(NSInteger item) {
                TOPHeadMenuModel *model = menuItems[item];
                [weakSelf top_ClickMoreViewAction:model.functionItem];
            };
            [window addSubview:moreView];
        });
    });
}

- (NSArray *)top_headMenuItems:(TOPHomeMoreFunctionType)moreType {
    BOOL showVip = NO;
    NSArray * headMenuItems = [NSArray new];
    if (moreType == TOPHomeMoreFunctionTypeSomeDocUnLock||moreType == TOPHomeMoreFunctionTypeSomeDocSetLock) {
        NSDictionary *dic1 = @{
            @"functionItem":@(TOPHomeMoreFunctionSetTags),
            @"title":NSLocalizedString(@"topscan_doctag", @""),
            @"iconName":@"top_menu_docTag",
            @"showVip":@(showVip)};
        showVip = ![TOPPermissionManager top_enableByUploadFile];
        NSDictionary *dic2 = @{
            @"functionItem":@(TOPHomeMoreFunctionUpload),
            @"title":NSLocalizedString(@"topscan_upload", @""),
            @"iconName":@"top_homeUpload",
            @"showVip":@(showVip)};
        showVip = NO;
        NSDictionary *dic3 = @{
            @"functionItem":@(TOPHomeMoreFunctionFax),
            @"title":NSLocalizedString(@"topscan_fax", @""),
            @"iconName":@"top_menu_fax_colorful",
            @"showVip":@(showVip)};
        headMenuItems = @[dic1,dic2,dic3];
    }else if(moreType == TOPHomeMoreFunctionTypeOneDocUnLock||moreType == TOPHomeMoreFunctionTypeOneDocSetLock){
        NSDictionary *dic1 = @{
            @"functionItem":@(TOPHomeMoreFunctionSetTags),
            @"title":NSLocalizedString(@"topscan_doctag", @""),
            @"iconName":@"top_menu_docTag",
            @"showVip":@(showVip)};
        showVip = ![TOPPermissionManager top_enableByUploadFile];
        NSDictionary *dic2 = @{
            @"functionItem":@(TOPHomeMoreFunctionUpload),
            @"title":NSLocalizedString(@"topscan_upload", @""),
            @"iconName":@"top_homeUpload",
            @"showVip":@(showVip)};
        showVip = NO;
        NSDictionary *dic3 = @{
            @"functionItem":@(TOPHomeMoreFunctionPrint),
            @"title":NSLocalizedString(@"topscan_printing", @""),
            @"iconName":@"top_menu_print_colorful",
            @"showVip":@(showVip)};
        NSDictionary *dic4 = @{
            @"functionItem":@(TOPHomeMoreFunctionFax),
            @"title":NSLocalizedString(@"topscan_fax", @""),
            @"iconName":@"top_menu_fax_colorful",
            @"showVip":@(showVip)};
        showVip = ![TOPPermissionManager top_enableByCollageSave];
        NSDictionary *dic5 = @{
            @"functionItem":@(TOPHomeMoreFunctionPicCollage),
            @"title":NSLocalizedString(@"topscan_collage", @""),
            @"iconName":@"top_menu_collage",
            @"showVip":@(showVip)};
        headMenuItems = @[dic1,dic2,dic3,dic4,dic5];
    }else if(moreType == TOPHomeMoreFunctionTypeFolderAndDoc||moreType == TOPHomeMoreFunctionTypeSomeFolder||moreType == TOPHomeMoreFunctionTypeOneFolder){
        showVip = ![TOPPermissionManager top_enableByUploadFile];
        NSDictionary *dic1 = @{
            @"functionItem":@(TOPHomeMoreFunctionUpload),
            @"title":NSLocalizedString(@"topscan_upload", @""),
            @"iconName":@"top_homeUpload",
            @"showVip":@(showVip)};
        showVip = NO;
        NSDictionary *dic2 = @{
            @"functionItem":@(TOPHomeMoreFunctionFax),
            @"title":NSLocalizedString(@"topscan_fax", @""),
            @"iconName":@"top_menu_fax_colorful",
            @"showVip":@(showVip)};
        headMenuItems = @[dic1,dic2];
    }
    NSMutableArray *temp = @[].mutableCopy;
    for (NSDictionary *dic in headMenuItems) {
        TOPHeadMenuModel *item1 = [[TOPHeadMenuModel alloc] init];
        item1.functionItem = [dic[@"functionItem"] integerValue];
        item1.title = dic[@"title"];
        item1.iconName = dic[@"iconName"];
        item1.showVip = [dic[@"showVip"] boolValue];
        [temp addObject:item1];
    }
    return temp;
}
#pragma mark -- 底部更多视图点击
- (void)top_ClickMoreViewAction:(TOPHomeMoreFunction)functionType{
    [FIRAnalytics logEventWithName:@"homeView_ClickMoreViewAction" parameters:nil];
    switch (functionType) {
        case TOPHomeMoreFunctionSaveToGrallery:
            [self top_SaveToGalleryTip];
            break;
        case TOPHomeMoreFunctionPDF:
            [self top_jumpToEditPDFVC];
            break;
        case TOPHomeMoreFunctionFax:
            [self top_FaxTip];
            break;
        case TOPHomeMoreFunctionSetTags:
            [self top_SetTag];
            break;
        case TOPHomeMoreFunctionSetLock:
            [self top_judgeSetTagsStateSetLock];
            break;
        case TOPHomeMoreFunctionUnLock:
            [self top_judgeSetTagsStateDocUnlock];
            break;
        case TOPHomeMoreFunctionEmail:
            self.emailType = 1;
            [self top_InvokeMenuFunctionAtIndex:0];
            break;
        case TOPHomeMoreFunctionFolderRename:
        case TOPHomeMoreFunctionDocRename:
            [self top_InvokeMenuFunctionAtIndex:5];
            break;
        case TOPHomeMoreFunctionPDFPassword:
            [self top_showPdfSetView];
            break;
        case TOPHomeMoreFunctionUpload:
            [self top_uploadDrive];
            break;
        case TOPHomeMoreFunctionDownDriveFile:
            [self top_downDriveFile];
            break;
        case TOPHomeMoreFunctionPrint:
            [self top_homeMorePrintFunction];
            break;
        case TOPHomeMoreFunctionPicCollage:
            [self top_homeMoreCollage];
            break;
        case TOPHomeMoreFunctionOCR:
            if (![TOPDocumentHelper top_getSelectFolderDocPicState:self.homeDataArray]) {
                [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
                return;
            }
            [self top_shareText];
            [self top_CancleSelectAction];
            break;
        case TOPHomeMoreFunctionDocRemaind:
            [self top_setDocReminder];
            [self top_CancleSelectAction];
            break;
        case TOPHomeMoreFunctionDocCollection:
            [self top_DocCollection];
            break;
        default:
            break;
    }
}
#pragma mark -- 收藏文档
- (void)top_DocCollection{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (DocumentModel * model in self.selectedDocsIndexArray) {
            if (self.hasCollection) {
                model.collectionstate = 0;
            }else{
                model.collectionstate = 1;
            }
            [TOPEditDBDataHandler top_editDocumentCollectionState:model.collectionstate withId:model.docId];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_CancleSelectAction];
            [self top_LoadSanBoxData:[TOPScanerShare top_sortType]];
        });
    });
    
}
#pragma mark -- 设置文档提醒
- (void)top_setDocReminder{
    DocumentModel * docModel = [DocumentModel new];
    if (self.selectedDocsIndexArray.count>0) {
        docModel = self.selectedDocsIndexArray[0];
    }
    TOPDocumentRemindVC * remindVC = [TOPDocumentRemindVC new];
    remindVC.docModel = docModel;
    remindVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
    remindVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:remindVC animated:YES];
}
#pragma mark -- uploadDrive 上传第三方网盘
- (void)top_uploadDrive{
    if (![TOPDocumentHelper top_getSelectFolderDocPicState:self.homeDataArray]) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
        return;
    }
    [FIRAnalytics logEventWithName:@"homeuploadDrive" parameters:nil];
    TOPLoadSelectDriveViewController *uploadVC = [[TOPLoadSelectDriveViewController alloc] init];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if (model.selectStatus) {
            [tempArray addObject:model];
        }
    }
    uploadVC.uploadDatas = [NSMutableArray arrayWithArray:tempArray];
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:uploadVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- downloadDrive 下载第三方网盘
- (void)top_downDriveFile{
    [FIRAnalytics logEventWithName:@"homedownloadDrive" parameters:nil];
    TOPLoadSelectDriveViewController *uploadVC = [[TOPLoadSelectDriveViewController alloc] init];
    uploadVC.openDrivetype = TOPDriveOpenStyleTypeDownFile;
    uploadVC.downloadFileSavePath = [TOPDocumentHelper top_getDocumentsPathString];
    uploadVC.downloadFileType = TOPDownloadFileToDriveAddPathTypeHome;
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:uploadVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- PDF预览
- (void)top_jumpToEditPDFVC{
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if ([model.type isEqual:@"1"]&&model.selectStatus) {
            [tempArray addObject:model];
        }
    }
    if (tempArray.count == 1) {
        [self top_CancleSelectAction];
        DocumentModel * printModel = tempArray[0];
        TOPEditPDFViewController * pdfVC = [[TOPEditPDFViewController alloc] init];
        pdfVC.docModel = printModel;
        pdfVC.filePath = printModel.path;
        pdfVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pdfVC animated:YES];
    }
}
#pragma mark -- 拼图
- (void)top_homeMoreCollage{
    WS(weakSelf);
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if ([model.type isEqual:@"1"]&&model.selectStatus) {
            [tempArray addObject:model];
        }
    }
    
    if (tempArray.count == 1) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
            DocumentModel * printModel = tempArray[0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [self top_CancleSelectAction];
                TOPCollageViewController *collageVC = [[TOPCollageViewController alloc] init];
                collageVC.filePath = printModel.path;
                collageVC.docModel = printModel;
                collageVC.top_backBtnAction = ^{
                };
                collageVC.top_finishBtnAction = ^{
                    if ([TOPScanerShare shared].isEditing) {
                        [weakSelf top_CancleSelectAction];
                        [self top_LoadSanBoxData:[TOPScanerShare top_sortType]];
                    }
                };
                collageVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:collageVC animated:YES];
            });
        });
    }
}

- (void)top_changeUpDownShowViewState{
    [UIView animateWithDuration:0.3 animations:^{
        [self top_CancleSelectResetFream];
    } completion:^(BOOL finished) {
        [self.pressUpView  removeFromSuperview];
        [self.pressBootomView removeFromSuperview];
        [self.bottomView removeFromSuperview];
        self.pressBootomView = nil;
        self.pressUpView = nil;
        self.bottomView = nil;
    }];
}
#pragma mark -- 开始打印
- (void)top_homeMorePrintFunction{
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self top_dealPrintingData];
        }
    }];
}
- (void)top_dealPrintingData{
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if ([model.type isEqual:@"1"]&&model.selectStatus) {
            [tempArray addObject:model];
        }
    }
    
    if (tempArray.count == 1) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
            NSMutableArray * imgArray = [NSMutableArray new];
            NSString * pdfName = [NSString new];
            DocumentModel * printModel = tempArray[0];
            NSArray * picArray = [TOPDocumentHelper top_sortPicsAtPath:printModel.path];
            
            for (NSString * imgName in picArray) {
                UIImage * img = [UIImage imageWithContentsOfFile:[printModel.path stringByAppendingPathComponent:imgName]];
                if (img) {
                    [imgArray addObject:img];
                }
            }
            pdfName = [NSString stringWithFormat:@"%@-1",printModel.name];
            NSString * path = [TOPDocumentHelper top_creatNOPasswordPDF:imgArray documentName:pdfName progress:^(CGFloat myProgress) {
                [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [self top_showPrintVC:path];
            });
        });
    }
}
#pragma mark -- 打印
- (void)top_showPrintVC:(NSString *)itemPath {
    NSData * imgData = [NSData dataWithContentsOfFile:itemPath];
    NSMutableArray * items = [NSMutableArray new];
    if (imgData) {
        [items addObject:imgData];
    }
    if (!items.count) {
        return;
    }
    UIPrintInteractionController * printVC = [UIPrintInteractionController sharedPrintController];
    if (printVC) {
        UIPrintInfo * printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = @"PDF";
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        printInfo.orientation = UIPrintInfoOrientationPortrait;
        printVC.printInfo = printInfo;
        printVC.delegate = self;
        printVC.printingItems = items;
        
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

#pragma mark --设置pdf密码的弹出视图
- (void)top_showPdfSetView{
    [FIRAnalytics logEventWithName:@"EditPDFVC_pdfPassword" parameters:nil];
    if (![TOPPermissionManager top_enableByEmailMySelf]) {
        [self top_CancleSelectAction];
        [self top_subscriptionService];
        return;
    }
    NSString *pass = [TOPScanerShare top_pdfPassword];
    if ([pass length]) {
        [TOPScanerShare top_writePDFPassword:@""];
        [[TOPCornerToast shareInstance] makeToast:[NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"]];
    } else {
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        if (!_coverView) {
            [keyWindow addSubview:self.coverView];
            [self top_markupCoverMask];
        }
        if (!_passwordView) {
            self.passwordView.actionType = TOPHomeMoreFunctionPDFPassword;
            [keyWindow addSubview:self.passwordView];
        }
    }
}
#pragma mark -- 传真
- (void)top_FaxTip{
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self top_ShowFaxTip];
        }
    }];
}
- (void)top_ShowFaxTip{
    [FIRAnalytics logEventWithName:@"homeView_FaxTip" parameters:nil];
    if (![TOPDocumentHelper top_getSelectFolderDocPicState:self.homeDataArray]) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
        return;
    }
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self top_CalculateSelectNumber];
        CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
        if (freeSize<self.totalSizeNum/1024.0/1024.0+5) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
            });
            return;
        }
        NSString * pdfName;
        NSMutableArray * editArray = [NSMutableArray new];
        for (NSString * pathString in [TOPDocumentHelper top_getSelectFolderPicture:self.homeDataArray]) {
            UIImage * img = [UIImage imageWithContentsOfFile:pathString];
            if (img) {
                [editArray addObject:img];
            }
        }
        
        for (DocumentModel * model in self.homeDataArray) {
            if (model.selectStatus) {
                pdfName = [NSString stringWithFormat:@"%@",model.name];
            }
        }
        [TOPDocumentHelper top_creatPDF:editArray documentName:pdfName pageSizeType:[TOPScanerShare top_pageSizeType] success:^(id  _Nonnull responseObj) {
            NSString * pdfPathString = responseObj;
            [TOPDocumentHelper top_jumpToSimpleFax:pdfPathString];
        }];
    });
}
#pragma mark -- 设置标签
- (void)top_SetTag{
    NSMutableArray * selectDocArray = [NSMutableArray new];
    [selectDocArray addObjectsFromArray:self.selectedDocsIndexArray];
    TOPSetTagViewController * tagVC = [[TOPSetTagViewController alloc]init];
    tagVC.dataArray = selectDocArray;
    tagVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tagVC animated:YES];
    [self top_CancleSelectAction];
}

#pragma mark --判断设置标签按钮的显示与不显示
- (NSInteger)top_judgeSetTagsState{
    NSInteger moreType = TOPHomeMoreFunctionTypeDefault;
    NSMutableArray * selectArray = [NSMutableArray new];
    for (DocumentModel * homeModel in self.homeDataArray) {
        if (homeModel.selectStatus) {
            [selectArray addObject:homeModel];
        }
    }
    
    NSMutableArray * documentArray = [NSMutableArray new];
    for (DocumentModel * docModel in selectArray) {
        if ([docModel.type isEqualToString:@"1"]) {
            [documentArray addObject:docModel];
        }
    }
    
    NSMutableArray * folderArray = [NSMutableArray new];
    for (DocumentModel * docModel in selectArray) {
        if ([docModel.type isEqualToString:@"0"]) {
            [folderArray addObject:docModel];
        }
    }
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * docModel in documentArray) {
        if (docModel.docPasswordPath.length>0) {
            [tempArray addObject:docModel];
        }
    }
    if (selectArray.count == 1) {
        if (documentArray.count == selectArray.count) {
            if (tempArray.count == documentArray.count) {
                moreType = TOPHomeMoreFunctionTypeOneDocUnLock;
            }else{
                moreType = TOPHomeMoreFunctionTypeOneDocSetLock;
            }
        }else{//选中的一个数据是folder文件夹
            moreType= TOPHomeMoreFunctionTypeOneFolder;
        }
    }
    if (selectArray.count>1) {
        if (documentArray.count == selectArray.count&&documentArray.count>0) {
            if (tempArray.count == documentArray.count) {
                moreType = TOPHomeMoreFunctionTypeSomeDocUnLock;
            }else{
                moreType = TOPHomeMoreFunctionTypeSomeDocSetLock;
            }
        }else if (folderArray.count == selectArray.count&&folderArray.count>0){
            moreType = TOPHomeMoreFunctionTypeSomeFolder;
        }else{
            moreType = TOPHomeMoreFunctionTypeFolderAndDoc;
        }
    }
    return moreType;
}

#pragma mark --设置密码
- (void)top_judgeSetTagsStateSetLock{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    NSString * password = [TOPScanerShare top_docPassword];
    if (password.length == 0) {
        [SVProgressHUD show];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TOPDocumentHelper top_defaultPassword];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            NSString * defaultPassword = [TOPScanerShare top_docPassword];
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0);
            if (defaultPassword.length == 0) {
                self.passwordView.actionType = TOPHomeMoreFunctionSetLockFirst;
            }else{
                self.passwordView.actionType = TOPHomeMoreFunctionSetLock;
            }
            [keyWindow addSubview:self.coverView];
            [self top_markupCoverMask];
            [keyWindow addSubview:self.passwordView];
        });
    });
}
#pragma mark -- 清除doc文档密码
- (void)top_judgeSetTagsStateDocUnlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (DocumentModel * selecModel in self.selectedDocsIndexArray) {
            if (selecModel.docPasswordPath.length>0) {
                [TOPWHCFileManager top_removeItemAtPath:selecModel.docPasswordPath];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_successfullyunlocked", @"")];
            [self top_CancleSelectAction];
            [self top_LoadSanBoxData:self.loadType];
        });
    });
    
}
#pragma mark -- 写入密码
- (void)top_judgeSetTagsStateWritePasswordToDoc:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_WritePasswordToDoc" parameters:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * selectArray = [NSMutableArray new];
        for (DocumentModel * homeModel in self.homeDataArray) {
            if (homeModel.selectStatus) {
                [selectArray addObject:homeModel];
            }
        }
        
        for (DocumentModel * docModel in selectArray) {
            if ([docModel.type isEqualToString:@"1"]) {
                NSString * docPasswordPath = docModel.docPasswordPath;
                if (docPasswordPath.length>0) {
                    NSArray * getArray = [docPasswordPath componentsSeparatedByString:TOP_TRDocPasswordPathString];
                    NSString * lastString = getArray.lastObject;
                    if (![lastString isEqualToString:password]) {
                        [TOPWHCFileManager top_removeItemAtPath:docPasswordPath];
                        [TOPDocumentHelper top_creatDocPasswordWithPath:docModel.path withPassword:password];
                    }
                }else{
                    [TOPDocumentHelper top_creatDocPasswordWithPath:docModel.path withPassword:password];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPCornerToast shareInstance]makeToast:[NSString stringWithFormat:@"%@%@",[NSLocalizedString(@"topscan_colletiondocpasswordtitle", @"") stringByAppendingString:@":"],password]];
            [TOPScanerShare top_writeDocPasswordSave:password];
            [self top_CancleSelectAction];
            [self top_LoadSanBoxData:self.loadType];
        });
    });
}

#pragma mark -- doc密码的视图的点击事件
- (void)top_passwordViewActionWithPassword:(NSString *)password WithType:(NSInteger)actionType{
    switch (actionType) {
        case TOPHomeMoreFunctionSetLockFirst:
            [self top_ClickTapAction];
            [self top_judgeSetTagsStateWritePasswordToDoc:password];
            break;
        case TOPHomeMoreFunctionSetLock:
            [self top_judgeSetTagsStateSetLockagain:password];
            break;
        case TOPHomeMoreFunctionPDFPassword:
            [self top_ClickTapAction];
            [self top_CancleSelectAction];
            [self top_setPdfPassword:password];
            break;
        case TOPMenuItemsFunctionShare:
            [self top_judgeSetTagsStateSetLockShare:password];
            break;
        case TOPMenuItemsFunctionMerge:
            [self top_judgeSetTagsStateSetLockMerge:password];
            break;
        case TOPMenuItemsFunctionCopyMove:
            [self top_judgeSetTagsStateSetLockMove:password];
            break;
        case TOPMenuItemsFunctionDelete:
            [self top_judgeSetTagsStateSetLockDelete:password];
            break;
        case TOPMenuItemsFunctionMore:
            [self top_judgeSetTagsStateSetLockMore:password];
            break;
        case TOPMenuItemsFunctionRename:
            [self top_judgeSetTagsStateSetLockRename:password];
            break;
        case TOPMenuItemsFunctionPushVC:
            [self top_judgeSetTagsStateSetLockPushChildVC:password];
            break;
            break;
        default:
            break;
    }
}
#pragma mark -- 设置pdf密码
- (void)top_setPdfPassword:(NSString *)password{
    [TOPScanerShare top_writePDFPassword:password];
    [[TOPCornerToast shareInstance] makeToast:[NSString stringWithFormat:@"%@ %@", [NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"],password]];
}
#pragma mark -- 有默认密码时设置密码
- (void)top_judgeSetTagsStateSetLockagain:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_SetLockagain" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickTapAction];
        [self top_judgeSetTagsStateWritePasswordToDoc:password];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的分享
- (void)top_judgeSetTagsStateSetLockShare:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_SetLockShare" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickTapAction];
        [self top_ShareTip];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的合并
- (void)top_judgeSetTagsStateSetLockMerge:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_SetLockMerge" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickTapAction];
        [self top_MergeFileMethod];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的移动
- (void)top_judgeSetTagsStateSetLockMove:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_SetLockMove" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickTapAction];
        [self top_EditFileMethod];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的删除
- (void)top_judgeSetTagsStateSetLockDelete:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_SetLockDelete" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickTapAction];
        [self top_DeleteTip];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的更多
- (void)top_judgeSetTagsStateSetLockMore:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_SetLockMore" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickTapAction];
        [self top_EditMoreMethod];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的重命名
- (void)top_judgeSetTagsStateSetLockRename:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_SetLockRename" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickTapAction];
        [self top_ClickToChangeFolderName];
    }else{
        [self top_writePasswordFail];
    }
}

#pragma mark -- 有密码时的界面跳转
- (void)top_judgeSetTagsStateSetLockPushChildVC:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_SetLockPushChildVC" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickTapAction];
        [self top_clickDocPushChildVCWithPath];
    }else{
        [self top_writePasswordFail];
    }
}
- (void)top_writePasswordFail{
    if (self.isShowFailToast) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_writepasswordfail", @"") duration:1];
    }
}
#pragma mark -- 文件编辑方式选择
- (void)top_EditFileMethod {
    [FIRAnalytics logEventWithName:@"homeView_EditFileMethod" parameters:nil];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_graffitimoveto", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_MoveToFileSelect];
        [self top_CancleSelectResetFream];
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ocrtextcopy", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_CopyFileSelect];
        [self top_CancleSelectResetFream];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    UIColor * titleColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor];
    UIColor * canelColor = TOPAPPGreenColor;
    [cancelAction setValue:canelColor forKey:@"_titleTextColor"];
    [archiveAction setValue:titleColor forKey:@"_titleTextColor"];
    [otherAction setValue:titleColor forKey:@"_titleTextColor"];
    [alertController addAction:archiveAction];
    [alertController addAction:otherAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- 当前文档的上级目录
- (NSString *)top_currentDocDirectoryAtPath {
    NSMutableArray *selectFile = @[].mutableCopy;
    NSMutableSet *selectParentId = [[NSMutableSet alloc] init];
    for (DocumentModel * model in self.homeDataArray) {
        if (model.selectStatus) {
            TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:model.docId];
            if (doc.parentId) {
                [selectParentId addObject:doc.parentId];
            }
            [selectFile addObject:model];
        }
    }
    NSString *currentFilePath = [TOPDocumentHelper top_getDocumentsPathString];
    if (selectParentId.count == 1) {
        DocumentModel *model = selectFile.firstObject;
        currentFilePath = [TOPWHCFileManager top_directoryAtPath:model.path];
    }
    return currentFilePath;
}

#pragma mark -- 选择移动的终点文件夹
- (void)top_MoveToFileSelect {
    [FIRAnalytics logEventWithName:@"homeView_MoveToFileSelect" parameters:nil];
    __weak typeof(self) weakSelf = self;
    TOPFileTargetListViewController *targetListVC = [[TOPFileTargetListViewController alloc] init];
    targetListVC.currentFilePath = [self top_currentDocDirectoryAtPath];
    targetListVC.fileHandleType = TOPFileHandleTypeMove;
    targetListVC.fileTargetType = TOPFileTargetTypeFolder;
    __weak typeof(targetListVC) weakTargetListVC = targetListVC;
    targetListVC.top_callBackFilePathBlock = ^(NSString * _Nonnull path) {
        [weakTargetListVC dismissViewControllerAnimated:YES completion:nil];
        [weakSelf top_MoveToFileAtPath:path];
    };
    targetListVC.top_clickCancelBlock = ^{
        [weakSelf top_CancleSelectChangeFream];
    };
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:targetListVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- 移动文件
- (void)top_MoveToFileAtPath:(NSString *)path {
    if (path.length) {
        [FIRAnalytics logEventWithName:@"homeView_MoveToFileAtPath" parameters:@{@"path":path}];
        NSMutableArray *selectFiles = [self top_SelectFileArray];
        NSString *showTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(1-%@)",@(selectFiles.count)] : @"";
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_moveprocessing", @""),showTitle]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *paths = @[].mutableCopy;
            NSMutableArray *moveFiles = @[].mutableCopy;
            for (int i = 0; i < selectFiles.count; i ++) {
                @autoreleasepool {
                    DocumentModel *model = selectFiles[i];
                    if ([path isEqualToString:[TOPWHCFileManager top_directoryAtPath:model.path]]) {
                        continue;
                    }
                    NSString * targetPath = [TOPDocumentHelper top_createNewDocument:model.name atFolderPath:path];
                    NSString *progressTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(%@-%@)",@(i +1),@(selectFiles.count)] : @"";
                    [TOPDocumentHelper top_moveFileItemsAtPath:model.path toNewFileAtPath:targetPath progress:^(CGFloat moveProgressValue) {
                        [[TOPProgressStripeView shareInstance] top_showProgress:moveProgressValue withStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_moveprocessing", @""),progressTitle]];
                    }];
                    [paths addObject:targetPath];
                    [moveFiles addObject:model];
                }
            }
            for (int i = 0; i < moveFiles.count; i ++) {
                @autoreleasepool {
                    DocumentModel *model = moveFiles[i];
                    NSString *targetPath = paths[i];
                    NSString *docName = [TOPWHCFileManager top_fileNameAtPath:targetPath suffix:YES];
                    [TOPEditDBDataHandler top_editDocumentPath:docName withParentId:[TOPFileDataManager shareInstance].fileModel.docId withId:model.docId];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                
                [self top_CancleSelectAction];
                [self top_LoadSanBoxData:self.loadType];
            });
        });
    }
}

#pragma mark -- 选择拷贝的终点文件夹
- (void)top_CopyFileSelect {
    [FIRAnalytics logEventWithName:@"homeView_CopyFileSelect" parameters:nil];
    __weak typeof(self) weakSelf = self;
    TOPFileTargetListViewController *targetListVC = [[TOPFileTargetListViewController alloc] init];
    targetListVC.currentFilePath = [TOPDocumentHelper top_getDocumentsPathString];
    targetListVC.fileHandleType = TOPFileHandleTypeCopy;
    targetListVC.fileTargetType = TOPFileTargetTypeFolder;
    __weak typeof(targetListVC) weakTargetListVC = targetListVC;
    targetListVC.top_callBackFilePathBlock = ^(NSString * _Nonnull path) {
        [weakTargetListVC dismissViewControllerAnimated:YES completion:nil];
        [weakSelf top_CopyFileAtPath:path];
    };
    targetListVC.top_clickCancelBlock = ^{
        [weakSelf top_CancleSelectChangeFream];
    };
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:targetListVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- 拷贝文件
- (void)top_CopyFileAtPath:(NSString *)path {
    if (path.length) {
        [FIRAnalytics logEventWithName:@"homeView_CopyFileAtPath" parameters:@{@"topath":path}];
        NSMutableArray *selectFiles = [self top_SelectFileArray];
        NSString *showTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(1-%@)",@(selectFiles.count)] : @"";
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_copyprocessing", @""),showTitle]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < selectFiles.count; i ++) {
                @autoreleasepool {
                    DocumentModel *model = selectFiles[i];
                    NSString * targetPath = [TOPDocumentHelper top_createNewDocument:model.name atFolderPath:path];
                    NSString *progressTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(%@-%@)",@(i +1),@(selectFiles.count)] : @"";
                    [TOPDocumentHelper top_copyFileItemsAtPath:model.path toNewFileAtPath:targetPath progress:^(CGFloat copyProgressValue) {
                        [[TOPProgressStripeView shareInstance] top_showProgress:copyProgressValue withStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_copyprocessing", @""),progressTitle]];
                    }];
                    [TOPEditDBDataHandler top_copyDocument:model.docId atFolder:targetPath WithParentId:[TOPFileDataManager shareInstance].fileModel.docId];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_copysuccess", @"")];
                [SVProgressHUD dismissWithDelay:1];
                [self top_CancleSelectAction];
                [self top_LoadSanBoxData:self.loadType];
            });
        });
    }
}

#pragma mark -- 选中的文件
- (NSMutableArray *)top_SelectFileArray {
    NSMutableArray *selectTempArray = [@[] mutableCopy];
    selectTempArray = [self.selectedDocsIndexArray mutableCopy];
    return selectTempArray;
}
#pragma mark -- 合并方式选择
- (void)top_MergeFileMethod {
    [FIRAnalytics logEventWithName:@"homeView_MergeFileMethod" parameters:nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_mergefilemethodtitle", @"") message:nil preferredStyle:IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_mergefilemethodkeepold", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_MergeAndKeepOldFile];
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_mergefilemethoddeleteold", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_MergeAndDeleteOldFile];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    UIColor * titleColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor];
    UIColor * canelColor = TOPAPPGreenColor;
    [archiveAction setValue:titleColor forKey:@"_titleTextColor"];
    [otherAction setValue:titleColor forKey:@"_titleTextColor"];
    [cancelAction setValue:canelColor forKey:@"_titleTextColor"];
    [alertController addAction:archiveAction];
    [alertController addAction:otherAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- 合并且保留原文件 等同于拷贝文件
- (void)top_MergeAndKeepOldFile {
    [FIRAnalytics logEventWithName:@"homeView_MergeAndKeepOldFile" parameters:nil];
    NSMutableArray *selectFiles = [self top_SelectFileArray];
    NSString *showTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(1-%@)",@(selectFiles.count)] : @"";
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_mergeing", @""),showTitle]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *docPaht = [TOPDocumentHelper top_getDocumentsPathString];
        NSString *mergerFilePath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:docPaht];
        for (int i = 0; i < selectFiles.count; i ++) {
            @autoreleasepool {
                DocumentModel *model = selectFiles[i];
                NSString *progressTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(%@-%@)",@(i +1),@(selectFiles.count)] : @"";
                if (!i) {
                    [TOPDocumentHelper top_copyFileItemsAtPath:model.path toNewFileAtPath:mergerFilePath progress:^(CGFloat copyProgressValue) {
                        [[TOPProgressStripeView shareInstance] top_showProgress:copyProgressValue withStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_mergeing", @""),progressTitle]];
                    }];
                } else {
                    [TOPDocumentHelper top_writeNewPic:model.path toNewFileAtPath:mergerFilePath delete:NO progress:^(CGFloat copyProgressValue) {
                        [[TOPProgressStripeView shareInstance] top_showProgress:copyProgressValue withStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_mergeing", @""),progressTitle]];
                    }];
                }
            }
        }
        TOPAppDocument *appDoc = [TOPEditDBDataHandler top_addDocumentAtFolder:mergerFilePath WithParentId:@"000000"];
        [TOPFileDataManager shareInstance].docModel = [TOPDBDataHandler top_buildDocumentModelWithData:appDoc];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_mergesuccess", @"")];
            [SVProgressHUD dismissWithDelay:1];
            [self top_CancleSelectAction];
            [self top_JumpToHomeChildVC:mergerFilePath];
        });
    });
}
#pragma mark -- 合并且删除原文件 等同往主文件移动文件
- (void)top_MergeAndDeleteOldFile {
    [FIRAnalytics logEventWithName:@"homeView_MergeAndDeleteOldFile" parameters:nil];
    NSMutableArray *selectFiles = [self top_SelectFileArray];
    NSString *showTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(1-%@)",@(selectFiles.count)] : @"";
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_mergeing", @""),showTitle]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *mergerFilePath = @"";
        NSString *mainDocId = @"";
        if (selectFiles.count) {
            DocumentModel *mainDoc = selectFiles[0];
            mergerFilePath = mainDoc.path;
            mainDocId = mainDoc.docId;
        }
        for (int i = 0; i < selectFiles.count; i ++) {
            if (!i) {
                continue;
            }
            @autoreleasepool {
                DocumentModel *model = selectFiles[i];
                NSString *progressTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(%@-%@)",@(i +1),@(selectFiles.count)] : @"";
                NSMutableArray *newImages = [TOPDocumentHelper top_writeNewPic:model.path toNewFileAtPath:mergerFilePath delete:YES progress:^(CGFloat copyProgressValue) {
                    [[TOPProgressStripeView shareInstance] top_showProgress:copyProgressValue withStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_mergeing", @""),progressTitle]];
                }];
                [TOPEditDBDataHandler top_batchEditImagePathWithId:model.docId toNewDoc:mainDocId withImageNames:newImages];
            }
        }
        [TOPFileDataManager shareInstance].docModel = selectFiles[0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_mergesuccess", @"")];
            [SVProgressHUD dismissWithDelay:1];
            [self top_CancleSelectAction];
            [self top_JumpToHomeChildVC:mergerFilePath];
        });
    });
}
#pragma mark -- 跳转到文档详情界面
- (void)top_JumpToHomeChildVC:(NSString *)path {
    if (path.length) {
        [FIRAnalytics logEventWithName:@"homeView_JumpToHomeChildVC" parameters:@{@"path":path}];
        TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
        childVC.docModel = [TOPFileDataManager shareInstance].docModel;
        childVC.pathString = path;
        childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
        childVC.hidesBottomBarWhenPushed = YES;
        childVC.addType = @"add";
        childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
        childVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:childVC animated:YES];
    }
}
#pragma mark --头部视图事件
#pragma mark ---添加文件夹
- (void)top_HomeHeaderAddFolderView{
    [FIRAnalytics logEventWithName:@"homeView_HomeHeaderAddFolder" parameters:nil];
    if ([TOPPermissionManager top_enableByCreateFolder]) {
        [self top_showAddFolderView];
    } else {
        RLMResults<TOPAPPFolder *> *folders = [TOPDBQueryService top_homeFoldersBySorted];
        if (folders.count >= MaxFolderCount) {
            [self top_subscriptionService];
        } else {
            [self top_showAddFolderView];
        }
    }
}

- (void)top_showAddFolderView {
    WS(weakSelf);
    NSString *filePath = [TOPDocumentHelper top_getFoldersPathString];
    TopEditFolderAndDocNameVC * editVC = [TopEditFolderAndDocNameVC new];
    editVC.top_clickToSendString = ^(NSString * _Nonnull nameString) {
        [weakSelf top_HomeHeaderAddFolderAction:nameString];
    };
    editVC.defaultString = [TOPDocumentHelper top_newDefaultFolderNameAtPath:filePath];
    editVC.picName = @"top_changefolder";
    editVC.editing = TopFileNameEditTypeAddFolder;
    editVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)top_HomeHeaderAddFolderAction:(NSString *)name{
    NSString *filePath = [TOPDocumentHelper top_getFoldersPathString];
    NSString *folderPathStr = [NSString new];
    if (name.length>0) {
        folderPathStr = [filePath  stringByAppendingPathComponent:name];
        NSString *isCreate =  [TOPDocumentHelper  top_createFolders:folderPathStr];
        if ([isCreate isEqualToString:@"1"]) {
            [self top_dealWithFolderPathToAddFolder:folderPathStr];
        }else if ([isCreate isEqualToString:@"0"]){
            [self top_FolderAlreadyAlert];
        }else{
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_creationfailed", @"")];
        }
    }else{
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_creationfailed", @"")];
    }
    [SVProgressHUD dismissWithDelay:2];
}

#pragma mark -- 新增文件夹
- (void)top_dealWithFolderPathToAddFolder:(NSString *)folderPath{
    [TOPEditDBDataHandler top_addFolderAtFile:folderPath WithParentId:@"000000"];
    [self top_LoadSanBoxData:self.loadType];
}

#pragma mark ---到系统相册
- (void)top_HomeHeaderCameraPicture{
    CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
    if (freeSize<TOPFreeSize) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
        return;
    }
    [FIRAnalytics logEventWithName:@"homeView_HomeHeaderCameraPicture" parameters:nil];
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:NSIntegerMax columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowTakeVideo = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
- (void)top_saveAssetsRefreshUI:(NSArray *)assets {
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [self top_handleLibiaryPhoto:assets completion:^(NSArray *imagePaths) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (assets.count == 1) {
                [weakSelf top_CreateFolderWithSelectPhotos:imagePaths];
            } else if (assets.count > 1) {
                [weakSelf top_OnlyToSendData:imagePaths];
            }
        });
    }];
}
#pragma mark -TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
    [TOPWHCFileManager top_createDirectoryAtPath:TOPCamerPic_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
    [TOPWHCFileManager top_createDirectoryAtPath:TOPAccidentCamerPic_Path];
    [self top_saveAssetsRefreshUI:assets];
}
#pragma mark -- 处理相册图片 -- 大图压缩控制在1200w像素内，保存，返回图片路径
- (void)top_handleLibiaryPhoto:(NSArray *)assets completion:(void (^)(NSArray *imagePaths))completion {
    WS(weakSelf);
    dispatch_queue_t queueE = dispatch_queue_create("group.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t groupE = dispatch_group_create();
    dispatch_queue_t serialQue= dispatch_queue_create("serial.queue",DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
    for (int i = 0; i < assets.count; i ++) {
        dispatch_async(serialQue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_group_async(groupE, queueE, ^{
                dispatch_group_enter(groupE);
                [[TZImageManager manager] getOriginalPhotoDataWithAsset:assets[i] completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        if ([info[@"PHImageResultIsDegradedKey"] boolValue] == NO) {
                            CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
                            if (freeSize<50) {
                                CGFloat imgSize;
                                if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveNO) {
                                    imgSize = data.length/1024/1024+4;
                                }else{
                                    imgSize = (data.length/1024/1024)*2+4;
                                }
                                if (freeSize<imgSize) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
                                    });
                                }else{
                                    [weakSelf top_savePicData:data index:i];
                                }
                            }else{
                                [weakSelf top_savePicData:data index:i];
                            }
                        }
                        dispatch_semaphore_signal(semaphore);
                        dispatch_group_leave(groupE);
                    });
                }];
            });
            if (i == assets.count - 1) {
                dispatch_group_notify(groupE, dispatch_get_main_queue(), ^{
                    NSArray * array = [TOPDocumentHelper top_sortPicsAtPath:TOPCamerPic_Path];
                    if (array.count) {
                        if (completion) completion(array);
                    } else {
                        [FIRAnalytics logEventWithName:@"HomeView_noJPG" parameters:nil];
                        NSArray * items = [TOPDocumentHelper top_sortItemAthPath:TOPCamerPic_Path];
                        if (items.count) {
                            [FIRAnalytics logEventWithName:@"HomeView_Item" parameters:@{@"content": items[0]}];
                            if (completion) completion(items);
                        } else {
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_savefail", @"")];
                            [SVProgressHUD dismissWithDelay:1];
                        }
                    }
                });
            }
        });
    }
}
#pragma mark -- 保存相册图片数据到本地
- (void)top_savePicData:(NSData *)data index:(NSInteger)i{
    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [TOPCamerPic_Path stringByAppendingPathComponent:fileName];
    NSString *accidentFileEndPath = [TOPAccidentCamerPic_Path stringByAppendingPathComponent:fileName];
    [data writeToFile:accidentFileEndPath atomically:YES];
    
    BOOL result = [data writeToFile:fileEndPath atomically:YES];
    if (!result) {
        if (fileEndPath == nil) {
            fileEndPath = @"";
        }
        [FIRAnalytics logEventWithName:@"HomeView_pathError" parameters:@{@"path": fileEndPath}];
        [FIRAnalytics logEventWithName:@"HomeView_contentError" parameters:@{@"content": @(data.length)}];
    }
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 从相册选择图片 多张图片时
- (void)top_OnlyToSendData:(NSArray *)assets{
    if (assets.count) {
        TOPCamerBatchViewController * scamerBatch = [TOPCamerBatchViewController new];
        scamerBatch.pathString = [TOPDocumentHelper top_appBoxDirectory];
        scamerBatch.fileType = TOPShowFolderCameraType;
        scamerBatch.backType = TOPHomeChildViewControllerBackTypePopRoot;
        
        TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:scamerBatch];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark -- 从相册选择图片 只有一张图片时
- (void)top_CreateFolderWithSelectPhotos:(NSArray *)photos{
    if (photos.count) {
        [FIRAnalytics logEventWithName:@"homeView_CreateFolderWithSelectPhotos" parameters:@{@"photos":photos}];
        TOPSingleBatchViewController * batch = [TOPSingleBatchViewController new];
        batch.pathString = [TOPDocumentHelper top_appBoxDirectory];
        batch.batchArray = [photos mutableCopy];
        batch.fileType = TOPShowFolderCameraType;
        batch.backType = TOPHomeChildViewControllerBackTypePopRoot;
        TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:batch];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}
/*
#pragma mark ---视图显示的样式
- (void)top_HomeHeaderViewType{
    WS(weakSelf)
    if (!self.sortPopView) {
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        self.sortPopView = [[TOPSortTypeView alloc]init];
        self.sortPopView.alpha = 0;
        self.sortPopView.top_topViewAction = ^(NSInteger index) {
            NSArray * tempArray = [weakSelf top_viewTypeArray];
            NSNumber * num = tempArray[index];
            [TOPScanerShare top_writeListType:[num integerValue]];
            if ([TOPScanerShare top_listType] == ShowListGoods) {
                [FIRAnalytics logEventWithName:@"homeView_HeaderViewTypeList" parameters:nil];
                weakSelf.nextCollView.hidden = YES;
                weakSelf.nextListHeaderView.hidden = YES;
                weakSelf.collectionView.hidden = YES;
                weakSelf.tableView.hidden = NO;
                weakSelf.tableView.listArray = weakSelf.homeDataArray;
                [weakSelf.tableView reloadData];
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }else if([TOPScanerShare top_listType] == ShowListNextGoods){
                [FIRAnalytics logEventWithName:@"homeView_HeaderViewTypeListSed" parameters:nil];
                weakSelf.tableView.hidden = YES;
                weakSelf.collectionView.hidden = YES;
                weakSelf.nextListHeaderView.hidden = NO;
                weakSelf.nextCollView.hidden = NO;
                weakSelf.nextCollView.listArray = weakSelf.homeDataArray;
                [weakSelf.nextCollView reloadData];
            }else{
                [FIRAnalytics logEventWithName:@"homeView_HeaderViewTypeColl" parameters:nil];
                weakSelf.collectionView.listArray = weakSelf.homeDataArray;
                weakSelf.collectionView.showType = [TOPScanerShare top_listType];
                weakSelf.tableView.hidden = YES;
                weakSelf.nextCollView.hidden = YES;
                weakSelf.nextListHeaderView.hidden = NO;
                weakSelf.collectionView.hidden = NO;
            }
            [weakSelf top_setContentFatherViewDefaultMask];
            [weakSelf top_sortTap];
            [weakSelf top_sumAllFileSize];
        };
        [keyWindow addSubview:self.sortCoverView];
        [keyWindow addSubview:self.sortPopView];
        [self top_showSortTypeView];
    }
}
 
- (void)top_showSortTypeView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    CGFloat navH = self.navigationController.navigationBar.frame.size.height+TOPStatusBarHeight;
    CGFloat topH = navH+55+self.changeEndY;
    [self.sortCoverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(keyWindow);
        make.top.equalTo(keyWindow).offset(topH);
    }];
    if (IS_IPAD) {
        [self.sortPopView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(keyWindow).offset(topH);
            make.trailing.equalTo(keyWindow);
            make.size.mas_equalTo(CGSizeMake(IPAD_CELLW, 100));
        }];
    }else{
        [self.sortPopView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keyWindow);
            make.top.equalTo(keyWindow).offset(topH);
            make.height.mas_equalTo(100);
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.sortCoverView.alpha = 1.0;
            self.sortPopView.alpha = 1.0;
        }];
    });
}
- (void)top_sortTap{
    [self.sortCoverView removeFromSuperview];
    [self.sortPopView removeFromSuperview];
    self.sortCoverView = nil;
    self.sortPopView = nil;
}
*/
#pragma mark --- 回收站
- (void)top_RecycleBin {
    TOPBinHomeViewController *binHome = [[TOPBinHomeViewController alloc] init];
    binHome.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:binHome animated:YES];
}

#pragma mark ---排列
- (void)top_HomeHeaderSortBy{
    [FIRAnalytics logEventWithName:@"homeView_HomeHeaderSortBy" parameters:nil];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    WS(weakSelf);
    NSArray *titleArray = @[NSLocalizedString(@"topscan_creatdataascend", @""),NSLocalizedString(@"topscan_creatdatadescend", @""),NSLocalizedString(@"topscan_updatedataascend", @""),NSLocalizedString(@"topscan_updatedatadescend", @""),NSLocalizedString(@"topscan_filenameatoz", @""), NSLocalizedString(@"topscan_filenameztoa", @"")];
    NSArray *picArray = @[@"top_docCreatDe",@"top_docCreatAs",@"top_docUpdateDe",@"top_docUpdateAs",@"top_docAZ",@"top_docZA"];
    NSArray *selectArray = @[@"top_docCreatSelectDe",@"top_docCreatSelectAs",@"top_docUpdateSelectDe",@"top_docUpdateSelectAs",@"top_docSelectAZ",@"top_docSelectZA"];
    TOPShareTypeView * sortPopView2 = [[TOPShareTypeView alloc]initWithTitleView:[UIView new] titleArray:titleArray picArray:picArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
        
    } selectBlock:^(NSInteger row, NSString * _Nonnull totalSize) {
        NSArray * tempArray = [weakSelf top_fileOrderTypeArray];
        [TOPScanerShare top_writSortType:[tempArray[row] integerValue]];
        self->_loadType = [tempArray[row] integerValue];
        [self top_LoadSanBoxData:self.loadType];
    }];
    sortPopView2.selectArray = selectArray;
    sortPopView2.popType = TOPPopUpBounceViewTypeSort;
    [window addSubview:sortPopView2];
    [sortPopView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(window);
    }];
}
#pragma mark ---视图选中状态
- (void)top_HomeHeaderSelectState{
    [FIRAnalytics logEventWithName:@"homeView_HomeHeaderSelectState" parameters:nil];
    [TOPScanerShare shared].isEditing = YES;
    [self top_ShowPressUpView];
    [self.pressBootomView top_changePressViewBtnState:TOPItemsSelectedNone];
    self.collectionView.listArray = self.homeDataArray;
    [self.collectionView reloadData];
    
    self.tableView.listArray = self.homeDataArray;
    [self.tableView reloadData];
    
    self.nextCollView.listArray = self.homeDataArray;
    [self.nextCollView reloadData];
}

#pragma mark ---更多
- (void)top_HomeHeaderMore{
    [FIRAnalytics logEventWithName:@"homeView_HomeHeaderMore" parameters:nil];
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.coverView];
    [self top_markupCoverMask];
    self.coverView.backgroundColor = [UIColor clearColor];
    self.coverView.userInteractionEnabled = YES;
    
    NSString * folderLocationString;
    if ([TOPScanerShare top_homeFolderTopOrBottom] == 2) {
        folderLocationString = NSLocalizedString(@"topscan_folderlocationtop", @"");
    }else{
        folderLocationString = NSLocalizedString(@"topscan_folderlocationbottom", @"");
    }
    NSArray * dataArray = @[NSLocalizedString(@"topscan_datarefresh", @""),NSLocalizedString(@"topscan_sortby", @""),NSLocalizedString(@"topscan_tagsentermanager", @""),NSLocalizedString(@"topscan_recyclebin", @""),NSLocalizedString(@"topscan_shareapp", @""),folderLocationString,NSLocalizedString(@"topscan_drivedownloadfiles", @""),NSLocalizedString(@"topscan_more", @"")];
    NSArray * iconArray = @[@"top_dataRefresh",@"top_blackSortBy",@"top_entertags",@"top_home_bin",@"top_shareApp",@"top_viewby",@"top_home_downloadfile_list",@"top_homefunctionMore"];
    [keyWindow addSubview:self.topMoreView];
    
    [self.topMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(keyWindow).offset(-10);
        make.top.equalTo(keyWindow).offset(TOPNavBarAndStatusBarHeight+TopView_H+self.changeEndY);
        make.size.mas_equalTo(CGSizeMake(210, dataArray.count*MoreView_H));
    }];
    self.topMoreView.showType = TOPHomeShowViewLocationTypeTopRight;
    self.topMoreView.dataArray = dataArray;
    self.topMoreView.iconArray = iconArray;
    
    [self.homeMoreArray removeAllObjects];
    NSArray * moreArray = @[@(TOPHomeMoreFunctionDataRefresh),@(TOPHomeMoreFunctionSortBy),@(TOPHomeMoreFunctionEnterTagsManager),@(TOPHomeMoreFunctionRecycleBin),@(TOPHomeMoreFunctionShareAppURL),@(TOPHomeMoreFunctionFolderLocation),@(TOPHomeMoreFunctionDownDriveFile),@(TOPHomeMoreFunctionBox)];
    [self.homeMoreArray addObjectsFromArray:moreArray];
    
}
#pragma mark ---视图显示的样式
- (void)top_HomeHeaderNewViewType{
    if ([TOPScanerShare top_listType] == ShowThreeGoods) {//3个格子
        [TOPScanerShare top_writeListType:ShowListNextGoods];
        [FIRAnalytics logEventWithName:@"homeView_HeaderViewTypeListSed" parameters:nil];
        self.tableView.hidden = YES;
        self.collectionView.hidden = YES;
        self.nextListHeaderView.hidden = NO;
        self.nextCollView.hidden = NO;
        self.nextCollView.listArray = self.homeDataArray;
        [self.nextCollView reloadData];
    }else{
        if ([TOPScanerShare top_listType] == ShowListNextGoods) {
            [TOPScanerShare top_writeListType:ShowThreeGoods];
            [FIRAnalytics logEventWithName:@"homeView_HeaderViewTypeColl" parameters:nil];
            self.collectionView.listArray = self.homeDataArray;
            self.collectionView.showType = [TOPScanerShare top_listType];
            self.tableView.hidden = YES;
            self.nextCollView.hidden = YES;
            self.nextListHeaderView.hidden = NO;
            self.collectionView.hidden = NO;
        }
    }
    
    [self.nextListHeaderView top_refreshViewTypeBtn];
}
#pragma mark -- 顶部点击事件
- (void)top_PresentPopViewWithType:(NSInteger)type selected:(BOOL)selected{
    NSArray *homeArray = [self top_HomeHeaderArray];
    NSNumber *funcNum = homeArray[type];
    switch ([funcNum integerValue]) {
        case TOPHomeHeaderFunctionAddFolder:
//            [self top_sortTap];
            [self top_HomeHeaderAddFolderView];
            break;
        case TOPHomeHeaderFunctionCameraPicture:
//            [self top_sortTap];
            [self top_HomeHeaderCameraPicture];
            break;
        case TOPHomeHeaderFunctionViewType:
            [self top_HomeHeaderNewViewType];
            /*
            if (self.sortPopView) {
                [self top_sortTap];
            }else{
                [self top_HomeHeaderViewType];
            }*/
            break;
        case TOPHomeHeaderFunctionSelectState:
//            [self top_sortTap];
            [self top_HomeHeaderSelectState];
            break;
        case TOPHomeHeaderFunctionMore:
//            [self top_sortTap];
            [self top_HomeHeaderMore];
            break;
        default:
            break;
    }
}

- (void)top_HomeHeaderMoreAction:(NSInteger)row{
    NSNumber * rowNum = self.homeMoreArray[row];
    switch ([rowNum integerValue]) {
        case TOPHomeMoreFunctionShareAppURL:
            [self top_ShareAppURL];
            break;
        case TOPHomeMoreFunctionFolderLocation:
            [self top_DocAndFolferLocation];
            break;
        case TOPHomeMoreFunctionSortBy:
            [self top_HomeHeaderSortBy];
            break;
        case TOPHomeMoreFunctionDownDriveFile:
            [self top_downDriveFile];
            break;
        case TOPHomeMoreFunctionEnterTagsManager:
            [self top_jumpToTagsManagerVC];
            break;
        case TOPHomeMoreFunctionBox:
            [self top_MoreFunction];
            break;
        case TOPHomeMoreFunctionDataRefresh:
            [self top_dataSyncAgain];
            break;
        case TOPHomeMoreFunctionRecycleBin:
            [self top_RecycleBin];
            break;
            
        default:
            break;
    }
}
#pragma mark -- 手动自检 自检完成后重新加载数据并刷新界面
- (void)top_dataSyncAgain{
    BOOL hasData = [[NSUserDefaults standardUserDefaults] boolForKey:@"RealmDataKey"];
    if (hasData) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:NSLocalizedString(@"topscan_showprocess", @"")];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [TOPDBDataHandler top_synchronizeRealmDBDataProgress:^(CGFloat value) {
                [[TOPProgressStripeView shareInstance] top_showProgress:value withStatus:NSLocalizedString(@"topscan_showprocess", @"")];
            }];
            NSMutableArray *tagsListArray = [TOPDataModelHandler top_getTagsListManagerData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [self top_loadDataCompleteRefresh:tagsListArray];
            });
        });
    }
}
- (void)top_DocAndFolferLocation{
    if ([TOPScanerShare top_homeFolderTopOrBottom] == 1) {
        [TOPScanerShare top_writeHomeFolderTopOrBottom:2];
    }else{
        [TOPScanerShare top_writeHomeFolderTopOrBottom:1];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.selectListModel.docArray = [TOPDataModelHandler top_docFolerBeforeAndAfter:[self removeAdModelArray]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_refreshAndShowTagsDoc:self.selectListModel];
            [self top_nativeAdShowState];
        });
    });
}
#pragma mark -- 分享app链接
- (void)top_ShareAppURL{
    NSString * shareText = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"topscan_shareappcontent", @""),TOP_TRAppStroeLink];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareText] applicationActivities:nil];
    if (IS_IPAD) {
        activityVC.popoverPresentationController.sourceView = self.view;
        activityVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:activityVC animated:YES completion:nil];
}
#pragma mark -- 搜索
- (void)top_HomeTopSearch{
    [FIRAnalytics logEventWithName:@"homeView_HomeTopSearch" parameters:nil];
    TOPSearchFileViewController * searchFileVC = [TOPSearchFileViewController new];
    searchFileVC.fatherDocModel = [TOPFileDataManager shareInstance].docModel;
    searchFileVC.pathString = [TOPDocumentHelper top_appBoxDirectory];
    searchFileVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchFileVC animated:NO];
}

- (void)top_HomeTopSetting{
    [FIRAnalytics logEventWithName:@"homeView_HomeTopSetting" parameters:nil];
    TOPSettingViewController * setVC = [TOPSettingViewController new];
    setVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setVC animated:YES];
}

#pragma mark -- 隐藏顶部更多功能视图
- (void)top_ClickTapAction{
    [UIView animateWithDuration:0.3 animations:^{
        self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, TOPScreenHeight, AddFolder_W, AddFolder_H);
        self.addFolderView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, TOPScreenHeight, AddFolder_W, AddFolder_W);
    }completion:^(BOOL finished) {
        [self.topMoreView removeFromSuperview];
        [self.addFolderView removeFromSuperview];
        [self.passwordView removeFromSuperview];
        if (!self->_scoreView) {
            [self.coverView removeFromSuperview];
            self.coverView = nil;
        }
        self.topMoreView = nil;
        self.addFolderView = nil;
        self.passwordView = nil;
    }];
}
#pragma mark -- 隐藏标签列表视图
- (void)top_ClickLeftTapAction{
    [self.leftTagsView removeFromSuperview];
    [self.leftTagsCoverView removeFromSuperview];
    self.leftTagsView = nil;
    self.leftTagsCoverView = nil;
    self.collectionView.headerView.tagBtn.selected = NO;
    self.tableView.tipHeaderView.tagBtn.selected = NO;
    self.nextListHeaderView.tagBtn.selected = NO;
    
    self.collectionView.isTagSelect = NO;
    self.tableView.isTagSelect = NO;
}
#pragma mark -- 删除提示
- (void)top_DeleteTip{
    [FIRAnalytics logEventWithName:@"homeView_DeleteTip" parameters:nil];
    weakify(self);
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_deleteoption", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [weakSelf top_deleteHandle];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 执行删除操作
- (void)top_deleteHandle {
    if (self.selectedDocsIndexArray.count > 5) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:NSLocalizedString(@"topscan_removeing", @"")];
    } else {
        [SVProgressHUD show];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *editArray = [NSMutableArray array];
        int j = 0;
        for (int i = 0; i<self.homeDataArray.count; i++) {
            @autoreleasepool {
                DocumentModel * model = self.homeDataArray[i];
                if (!model.isAd) {
                    if (!model.selectStatus) {
                        [editArray addObject:model];
                    }else{
                        if ([model.type isEqualToString:@"0"]) {
                            [self top_deleteFolderToBin:model];
                        } else {
                            [self top_deleteDocumentToBin:model];
                        }
                        j ++;
                        CGFloat moveProgressValue = j / (self.selectedDocsIndexArray.count * 1.0);
                        [[TOPProgressStripeView shareInstance] top_showProgress:moveProgressValue withStatus:NSLocalizedString(@"topscan_removeing", @"")];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [SVProgressHUD dismiss];
            NSArray * picArray = @[@"top_downview_disableshare",@"top_dissmissEmail",@"top_downview_dissmissSave",@"top_dissmissPrinting",@"top_downview_disabledelete"];
            [self.pressBootomView top_changePressViewBtnStatue:picArray enabled:NO];
            //选中数量为0
            [self.pressUpView top_configureSelectedCount:0];
            [self top_LoadSanBoxData:self.loadType];
            if (editArray.count == 0) {
                self.blankImg.hidden = NO;
                self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
                self.collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
                self.nextCollView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
            }
            [self top_CancleSelectAction];
            [self top_takeTipOfRecycleBin];
        });
    });
}

#pragma mark -- 移动文档到回收站
- (void)top_deleteDocumentToBin:(DocumentModel *)model {
    [TOPWHCFileManager top_removeItemAtPath:model.docPasswordPath];
    NSString *binDocPath = [TOPBinHelper top_moveDocumentToBin:model.path];
    RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:model.docId];
    if (images.count) {
        TOPImageFile *img = images[0];
        [TOPBinEditDataHandler top_saddBinDocWithParentId:img.pathId atPath:binDocPath];
    }
    [TOPEditDBDataHandler top_deleteDocumentWithId:model.docId];
}

#pragma mark -- 移动文件夹到回收站
- (void)top_deleteFolderToBin:(DocumentModel *)model {
    NSString *binDocPath = [TOPBinHelper top_moveFolderToBin:model.path];
    [TOPBinEditDataHandler top_addFolderAtFile:binDocPath WithParentId:model.docId];
    [TOPEditDBDataHandler top_deleteFolderWithId:model.docId];
}

- (void)top_takeTipOfRecycleBin {
    BOOL tipRecycleBin = [[NSUserDefaults standardUserDefaults] boolForKey:@"tipRecycleBinKey"];
    if (!tipRecycleBin) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"tipRecycleBinKey"];
        WS(weakSelf);
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"")
                                                                       message:NSLocalizedString(@"topscan_recyclebininstructions", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_longpresstip", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_recyclebin", @"") style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
            [weakSelf top_RecycleBin];
        }];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark -- new分享
- (void)top_ShareTipNew {
    NSMutableArray *shareDatas = [TOPShareFileDataHandler top_fetchShareFileData:[self removeAdModelArray]];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    WS(weakSelf);
    TOPShareFileView *shareFileView = [[TOPShareFileView alloc] initWithItemArray:shareDatas doneTitle:NSLocalizedString(@"topscan_share", @"") cancelBlock:^{
        
    } selectBlock:^(TOPShareFileModel * cellModel) {
        weakSelf.pdfType = cellModel.fileType;
        [weakSelf top_selectShareFileQuantity:cellModel];
    }];
    [window addSubview:shareFileView];
    [shareFileView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(window);
    }];
    self.shareFilePopView = shareFileView;
}

#pragma mark -- 选中分享图片的质量 文件大于1M时才会弹出
- (void)top_selectShareFileQuantity:(TOPShareFileModel *)cellModel {
    WS(weakSelf);
    float unitRate = 1024.0;
    float foldSize = cellModel.fileSize / (unitRate * unitRate);
    if (foldSize > 1) {
        if (cellModel.fileType == TOPShareFilePDF || cellModel.fileType == TOPShareFileJPG) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            
            NSArray * titleArray = @[NSLocalizedString(@"topscan_originalsize", @""),NSLocalizedString(@"topscan_medium", @""),NSLocalizedString(@"topscan_small", @"")];
            if ([TOPScanerShare top_userDefinedFileSize] > 0) {
                titleArray = @[NSLocalizedString(@"topscan_originalsize", @""),NSLocalizedString(@"topscan_medium", @""),NSLocalizedString(@"topscan_small", @""),NSLocalizedString(@"topscan_userdefinedsize", @"")];
            }
            TOPShareDownSizeView * sizeView = [[TOPShareDownSizeView alloc]initWithTitleView:[UIView new] optionsArr:titleArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
                
            } selectBlock:^(NSMutableArray * shareArray) {
                if (weakSelf.emailType == 1) {
                    [weakSelf top_EmailTip:shareArray];
                } else {
                    if (cellModel.isZip) {
                        [weakSelf top_shareZipFile:shareArray];
                    } else {
                        [weakSelf top_presentActivityVC:shareArray];
                    }
                }
            }];
            
            [window addSubview:sizeView];
            [sizeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.bottom.equalTo(window);
            }];
            NSMutableArray * tempArray = [NSMutableArray new];
            for (DocumentModel * model in weakSelf.homeDataArray) {
                if (model.selectStatus) {
                    [tempArray addObject:model];
                }
            }
            sizeView.compressType = cellModel.fileType;
            sizeView.dataArray = tempArray;
            sizeView.totalNum = cellModel.fileSize;
            sizeView.numberStr = [TOPDocumentHelper top_memorySizeStr:cellModel.fileSize];
        } else if (cellModel.fileType == TOPShareFileLongJPG) {
            [FIRAnalytics logEventWithName:@"homeView_ShareLongImage" parameters:nil];
            [weakSelf top_prejudgeImages];
        } else if (cellModel.fileType == TOPShareFileTxt) {
            [FIRAnalytics logEventWithName:@"homeView_shareText" parameters:nil];
            [weakSelf top_shareText];
            [weakSelf top_CancleSelectAction];
        }
    } else {
        if(cellModel.fileType == TOPShareFilePDF) {
            [SVProgressHUD show];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
                NSArray * pathArray = [NSArray new];
                NSMutableArray * shareArray = [NSMutableArray new];
                for (DocumentModel * model in weakSelf.homeDataArray) {
                    if (model.selectStatus) {
                        NSMutableArray * imgArray = [NSMutableArray new];
                        if ([model.type isEqualToString:@"0"]) {
                            NSMutableArray * documentArray = [NSMutableArray new];
                            NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:model.path documentArray:documentArray];
                            for (NSString * documentPath in getArry) {
                                NSArray * documentArray = [TOPDocumentHelper top_getCurrentFileAndPath:documentPath];
                                for (NSString * picName in documentArray) {
                                    NSString * picPath = [documentPath stringByAppendingPathComponent:picName];
                                    UIImage * img = [UIImage imageWithContentsOfFile:picPath];
                                    if (img) {
                                        [imgArray addObject:img];
                                    }
                                }
                            }
                        }
                        
                        if ([model.type isEqualToString:@"1"]) {
                            pathArray = [TOPDocumentHelper top_getCurrentFileAndPath:model.path];
                            for (NSString * pcStr in pathArray) {
                                NSString * fullPath = [NSString stringWithFormat:@"%@/%@",model.path,pcStr];
                                UIImage * img = [UIImage imageWithContentsOfFile:fullPath];
                                if (img) {
                                    [imgArray addObject:img];
                                }
                            }
                        }
                        NSString * path = [TOPDocumentHelper top_creatPDF:imgArray documentName:model.name];
                        NSURL * file = [NSURL fileURLWithPath:path];
                        if (file) {
                            [shareArray addObject:file];
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (weakSelf.emailType == 1) {
                        [weakSelf top_EmailTip:shareArray];
                    }else{
                        [weakSelf top_presentActivityVC:shareArray];
                    }
                });
            });
        } else if(cellModel.fileType == TOPShareFileJPG){
            [SVProgressHUD show];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray * shareArray = [NSMutableArray new];
                for (DocumentModel * model in weakSelf.homeDataArray) {
                    if (model.selectStatus) {
                        if ([model.type isEqualToString:@"0"]) {
                            [shareArray addObjectsFromArray:[weakSelf top_getFolderShareImgURL:model]];
                        }
                        if ([model.type isEqualToString:@"1"]) {
                            [shareArray addObjectsFromArray:[weakSelf top_getDocumentShareImgURL:model]];
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (weakSelf.emailType == 1) {
                        [weakSelf top_EmailTip:shareArray];
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf top_presentActivityVC:shareArray];
                        });
                    }
                });
            });
        } else if(cellModel.fileType == TOPShareFileLongJPG) {
            [FIRAnalytics logEventWithName:@"homeView_ShareLongImage" parameters:nil];
            [weakSelf top_drawLongImagePreview];
        } else {
            [FIRAnalytics logEventWithName:@"homeView_shareText" parameters:nil];
            [weakSelf top_shareText];
            [weakSelf top_CancleSelectAction];
        }
    }
}

#pragma mark -- 分享
- (void)top_ShareTip{
    if (![TOPDocumentHelper top_getSelectFolderDocPicState:self.homeDataArray]) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
        return;
    }
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self top_ShareTipNew];
        }
    }];
}

#pragma mark -- 分享压缩文件
- (void)top_shareZipFile:(NSMutableArray *)shareArray {
    if ([self top_needCreateZip:shareArray]) {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *shareFiles = [self top_createZipWithShareFile:shareArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self top_presentActivityVC:shareFiles];
            });
        });
    } else {
        [self top_presentActivityVC:shareArray];
    }
}

#pragma mark -- 判断是否需要压缩
- (BOOL)top_needCreateZip:(NSMutableArray *)shareArray {
    BOOL createZip = NO;
    if (self.pdfType == 0) {
        if (shareArray.count > 1) {
            createZip = YES;
        }
    } else {
        if (shareArray.count > 9) {
            createZip = YES;
        }
    }
    return createZip;
}

#pragma mark -- 压缩需要分享的文件
- (NSMutableArray *)top_createZipWithShareFile:(NSMutableArray *)shareArray {
    NSMutableArray *shareFiles = @[].mutableCopy;
    NSString *zipFile = [TOPDocumentHelper top_getBelongTemporaryPathString:NSLocalizedString(@"topscan_sharezipname", @"")];
    NSMutableArray *zipPaths = @[].mutableCopy;
    for (NSURL *url in shareArray) {
        [zipPaths addObject:url.path];
    }
    BOOL successed = [SSZipArchive createZipFileAtPath:zipFile withFilesAtPaths:zipPaths];
    if (successed) {
        [shareFiles addObject:[NSURL fileURLWithPath:zipFile]];
    }
    return shareFiles;
}

#pragma mark -- 弹出系统分享界面
- (void)top_presentActivityVC:(NSMutableArray *)shareArray {
    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:shareArray applicationActivities:nil];
    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    activiVC.excludedActivityTypes = excludedActivityTypes;
    if (IS_IPAD) {
        activiVC.popoverPresentationController.sourceView = self.view;
        activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController: activiVC animated:YES completion:nil];
}

#pragma mark -- 分享图片时folder文件夹下图片的url集合
- (NSMutableArray *)top_getFolderShareImgURL:(DocumentModel *)model{
    NSMutableArray * shareArray = [NSMutableArray new];
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:model.path documentArray:documentArray];
    for (NSString * documentPath in getArry) {
        NSArray * documentArray = [TOPDocumentHelper top_getCurrentFileAndPath:documentPath];
        for (NSString * picName in documentArray) {
            NSString * nameIndex = [NSString stringWithFormat:@"%ld",[documentArray indexOfObject:picName]+1];
            NSString * docName = [documentPath componentsSeparatedByString:@"/"].lastObject;
            NSString * savePath = [NSString stringWithFormat:@"%@_%@.jpg",docName,nameIndex];
            NSString * picPath = [documentPath stringByAppendingPathComponent:picName];
            NSString * compressFile = [NSString new];
            if (documentArray.count > 5) {
                compressFile = [TOPDocumentHelper top_saveCompressPDFImage:picPath savePath:savePath maxCompression:1.0];
            }else{
                compressFile = [TOPDocumentHelper top_saveCompressImage:picPath savePath:savePath maxCompression:1.0];
            }
            if (compressFile.length) {
                NSURL * file = [NSURL fileURLWithPath:compressFile];
                [shareArray addObject:file];
            }
        }
    }
    return shareArray;
}
#pragma mark -- 分享图片时document文件夹下图片的url集合
- (NSMutableArray *)top_getDocumentShareImgURL:(DocumentModel *)model{
    NSArray * pathArray = [TOPDocumentHelper top_getCurrentFileAndPath:model.path];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (NSString * pcStr in pathArray) {
        NSString * nameIndex = [NSString stringWithFormat:@"%ld",[pathArray indexOfObject:pcStr]+1];
        NSString * docName = [model.path componentsSeparatedByString:@"/"].lastObject;
        NSString * savePath = [NSString stringWithFormat:@"%@_%@.jpg",docName,nameIndex];
        NSString * fullPath = [NSString stringWithFormat:@"%@/%@",model.path,pcStr];
        NSString * compressFile = [NSString new];
        if (pathArray.count > 5) {
            compressFile = [TOPDocumentHelper top_saveCompressPDFImage:fullPath savePath:savePath maxCompression:1.0];
            
        }else{
            compressFile = [TOPDocumentHelper top_saveCompressImage:fullPath savePath:savePath maxCompression:1.0];
        }
        if (compressFile.length) {
            NSURL * file = [NSURL fileURLWithPath:compressFile];
            [tempArray addObject:file];
        }
    }
    return tempArray;
}
#pragma mark -- 预判图片数量是否过多
- (void)top_prejudgeImages {
    static NSInteger maxNum = 30;
    NSMutableArray * imgArray = [[NSMutableArray alloc] init];
    for (DocumentModel * model in [self top_SelectFileArray]) {
        NSArray *images = @[];
        if ([model.type isEqualToString:@"0"]) {
            images = [TOPDocumentHelper top_getAllJPEGFileForDeep:model.path];
        }
        if ([model.type isEqualToString:@"1"]) {
            images = [TOPDocumentHelper top_getJPEGFile:model.path];
        }
        for (NSString *content in images) {
            [imgArray addObject:content];
        }
    }
    if (imgArray.count >= maxNum) {
        [self top_phoneMemoryAlert];
    }else{
        [self top_drawLongImagePreview];
    }
}

#pragma mark -- 合成长图并预览
- (void)top_drawLongImagePreview {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *imgArray = [TOPDataModelHandler top_selectedImageArray:[self top_SelectFileArray]];
        UIImage *resultImg = [TOPPictureProcessTool top_mergedImages:imgArray];
        NSString *showPath = [TOPDocumentHelper top_longImageFileString];
        [TOPDocumentHelper top_saveImage:resultImg atPath:showPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self top_CancleSelectAction];
            TOPShowLongImageViewController * longImgVC = [TOPShowLongImageViewController new];
            longImgVC.showPath = showPath;
            longImgVC.pathString = [TOPDocumentHelper top_getDocumentsPathString];
            longImgVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:longImgVC animated:YES];
        });
    });
}

- (void)top_phoneMemoryAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_note", @"")
                                                                   message:NSLocalizedString(@"topscan_phonememoryalert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_continueshare", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [self top_drawLongImagePreview];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark-- 计算选中文件的大小
- (void)top_CalculateSelectNumber{
    [FIRAnalytics logEventWithName:@"homeView_CalculateSelectNumber" parameters:nil];
    CGFloat memorySize = [TOPDocumentHelper top_calculateSelectFilesSize:self.homeDataArray];
    self.totalSizeNum = memorySize;
}
#pragma mark-- 发送email
- (void)top_EmailTip:(NSArray *)emailArray{
    if (emailArray.count) {
        [FIRAnalytics logEventWithName:@"homeView_EmailTip" parameters:@{@"emailArray":emailArray}];
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        
        if (!mailClass) {
            return;
        }
        
        if (![mailClass canSendMail]) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_bind", @"")
                                                                           message:NSLocalizedString(@"topscan_bindcontent", @"")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        self.emailModel = [NSKeyedUnarchiver unarchiveObjectWithFile:TOPSettingEmail_Path];
        [self top_ShowMailCompose:self.emailModel.toEmail array:emailArray];
    }
}
- (void)top_ShowMailCompose:(NSString *)email array:(NSArray *)emailArray{
    MFMailComposeViewController * mailCompose = [[MFMailComposeViewController alloc]init];
    mailCompose.mailComposeDelegate = self;
    NSArray * toRecipients = [NSArray arrayWithObjects:email,nil];
    [mailCompose setToRecipients:toRecipients];
    [mailCompose setSubject:self.emailModel.subject];
    [mailCompose setMessageBody:self.emailModel.body isHTML:YES];
    
    NSLog(@"emailArray==%@",emailArray);
    if (emailArray.count>0) {
        if (self.pdfType == 1) {
            for (int i = 0; i<emailArray.count; i++) {
                NSData * imgData = [NSData dataWithContentsOfURL:emailArray[i]];
                if (imgData) {
                    NSURL * imgPath = emailArray[i];
                    NSString * photoName = [TOPDocumentHelper top_decodeFromPercentEscapeString:[imgPath.absoluteString componentsSeparatedByString:@"/"].lastObject];
                    [mailCompose addAttachmentData:imgData mimeType:@"image" fileName:photoName];
                }
            }
            [self presentViewController:mailCompose animated:YES completion:^{
                
            }];
        }
        
        if (self.pdfType == 0) {
            for (int i = 0; i<emailArray.count; i++) {
                NSData * pdfData = [NSData dataWithContentsOfURL:emailArray[i]];
                if (pdfData) {
                    NSURL * pdfPath = emailArray[i];
                    NSString * photoName = [TOPDocumentHelper top_decodeFromPercentEscapeString:[pdfPath.absoluteString componentsSeparatedByString:@"/"].lastObject];
                    [mailCompose addAttachmentData:pdfData mimeType:@"application/pdf" fileName:photoName];
                }
            }
            [self presentViewController:mailCompose animated:YES completion:^{
                
            }];
        }
        
    }
}
#pragma mark-- 保存到Gallery文件夹
- (void)top_SaveToGalleryTip{
    [FIRAnalytics logEventWithName:@"homeView_SaveToGalleryTip" parameters:nil];
    NSArray * emailArray = [TOPDocumentHelper top_getSelectFolderPicture:self.homeDataArray];
    if (!emailArray.count) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
        return;
    }
    WS(weakSelf);
    [TOPDocumentHelper top_saveImagePathArray:emailArray toFolder:TOPSaveToGallery_Path tipShow:YES showAlter:^(BOOL isExisted) {
        if (!isExisted) {
            [SVProgressHUD dismiss];
            [TOPDocumentHelper top_creatGalleryFolder:TOPSaveToGallery_Path];
             UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_albumpermissiontitle", @"")
                                                                           message:NSLocalizedString(@"topscan_albumpermissionguide", @"")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_setting", @"") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                return;
            }];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * action) {
                return;
            }];
            [alert addAction:okAction];
            [alert addAction:cancelAction];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }
    }];
}
#pragma mark -- 修改文件夹名称
- (void)top_ClickToChangeFolderName{
    [FIRAnalytics logEventWithName:@"homeView_ClickToChangeFolderName" parameters:nil];
    NSString * picName = [NSString new];
    TopFileNameEditType editType;
    DocumentModel * renameModel = [DocumentModel new];
    for (DocumentModel * tempModel in self.homeDataArray) {
        if (tempModel.selectStatus) {
            renameModel = tempModel;
        }
    }
    if ([renameModel.type isEqualToString:@"0"]) {
        picName = @"top_changefolder";
        editType = TopFileNameEditTypeChangeFolderName;
    }else{
        picName = @"top_changedoc";
        editType = TopFileNameEditTypeChangeDocName;
    }
    WS(weakSelf);
    TopEditFolderAndDocNameVC * editName = [TopEditFolderAndDocNameVC new];
    editName.top_clickToSendString = ^(NSString * _Nonnull nameString) {
        [weakSelf top_ClickToChangeFolderNameAction:nameString];
    };
    editName.defaultString = renameModel.name;
    editName.editType = editType;
    editName.picName = picName;
    editName.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editName animated:YES];
}

- (void)top_ClickToChangeFolderNameAction:(NSString *)name{
    DocumentModel * renameModel = [DocumentModel new];
    for (DocumentModel * tempModel in self.homeDataArray) {
        if (tempModel.selectStatus) {
            renameModel = tempModel;
        }
    }
    
    for (DocumentModel * model in self.homeDataArray) {
        if ([model.type isEqual:renameModel.type]&&[model.name isEqualToString:name]) {
            if (![name isEqualToString:renameModel.name]) {
                [self top_FolderAlreadyAlert];
            }
            return;
        }
    }
    
    if (name.length == 0) {
        return;
    }
    [TOPDocumentHelper top_changeDocumentName:renameModel.path folderText:name];
    if ([renameModel.type isEqualToString:@"0"]) {
        [TOPEditDBDataHandler top_editFolderName:name withId:renameModel.docId];
    } else {
        [TOPEditDBDataHandler top_editDocumentName:name withId:renameModel.docId];
    }
    [self top_CancleSelectAction];
    [self top_LoadSanBoxData:self.loadType];
}
- (void)top_FolderAlreadyAlert{
    [FIRAnalytics logEventWithName:@"homeView_FolderAlreadyAlert" parameters:nil];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_hasfolder", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}
- (NSArray *)top_viewTypeArray{
    NSArray * tempArray = [NSArray new];
    if (IS_IPAD) {
        tempArray = @[@(ShowListGoods),@(ShowThreeGoods)];
    }else{
        tempArray = @[@(ShowThreeGoods),@(ShowListNextGoods)];
    }
    return tempArray;
}
- (NSArray *)top_fileOrderTypeArray{
    NSArray * tempArray = @[@(FolderDocumentCreateDescending),@(FolderDocumentCreateAscending),@(FolderDocumentUpdateDescending),@(FolderDocumentUpdateAscending),@(FolderDocumentFileNameAToZ),@(FolderDocumentFileNameZToA)];
    return tempArray;
}

#pragma mark -- 顶部隐藏视图的点击事件
- (void)top_TopHideViewWithType:(NSInteger)type{
    [FIRAnalytics logEventWithName:@"homeView_TopHideViewWithType" parameters:nil];
    NSArray * topArray = [self top_TopHideArray];
    NSNumber * num = topArray[type];
    switch ([num integerValue]) {
        case TOPHomeVCTopHideViewStateBackup:
            [self top_Backup];
            break;
        case TOPHomeVCTopHideViewStateImportPic:
            [self top_ImportPic];
            break;
        case TOPHomeVCTopHideViewStateSyntheticPDF:
            [self top_SyntheticPDF];
            break;
        case TOPHomeVCTopHideViewStateImportDoc:
            [self top_ImportDoc];
            break;
        case TOPHomeVCTopHideViewStateFunctionMore:
            [self top_MoreFunction];
            break;
        default:
            break;
    }
}

#pragma mark --更多功能 
- (void)top_MoreFunction{
    self.tabBarController.selectedIndex = 1;
    TOPMainTabBarController * tabVC = (TOPMainTabBarController *)self.tabBarController;
    TOPMainTabBar * tabbar = (TOPMainTabBar *)self.tabBarController.tabBar;
    tabVC.tabIndex = 2;
    tabbar.tabIndex = 2;
}
#pragma mark -- 备份与还原
- (void)top_Backup{
    [FIRAnalytics logEventWithName:@"homeView_Backup" parameters:nil];
    TOPRestoreViewController * webVC = [TOPRestoreViewController new];
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark -- 导入图片
- (void)top_ImportPic{
    [FIRAnalytics logEventWithName:@"homeView_ImportPic" parameters:nil];
    NSArray *documentTypes = @[@"public.image"];
    [self top_getIcouldView:documentTypes];
}
#pragma mark -- 合并
- (void)top_SyntheticPDF{
    TOPTagsListModel * allListModel = [TOPTagsListModel new];
    if (self.tagsArray.count>0) {
        allListModel = self.tagsArray[0];
    }
    [FIRAnalytics logEventWithName:@"homeView_SyntheticPDF" parameters:nil];
    TOPHomeTopMergeVC * mergeVC = [TOPHomeTopMergeVC new];
    mergeVC.docModel = [TOPFileDataManager shareInstance].docModel;
    mergeVC.addDocArray = [allListModel.docArray mutableCopy];
    mergeVC.pathString = [TOPDocumentHelper top_appBoxDirectory];
    mergeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mergeVC animated:YES];
}
#pragma mark -- 导入文档
- (void)top_ImportDoc{
    [FIRAnalytics logEventWithName:@"homeView_ImportDoc" parameters:nil];
    NSArray *documentTypes = @[@"public.image",@"com.adobe.pdf"];
    [self top_getIcouldView:documentTypes];
}

- (void)top_getIcouldView:(NSArray *)typeArray{
    //开启透明
    [[UINavigationBar appearance] setTranslucent:YES];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc]initWithDocumentTypes:typeArray inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle =  UIModalPresentationFullScreen;
    [self presentViewController:documentPicker animated:YES completion:nil];
}
#pragma mark -- 隐藏头部视图 更改列表坐标
- (void)top_HideHeaderView{
    [FIRAnalytics logEventWithName:@"homeView_HideHeaderView" parameters:nil];
    [UIView animateWithDuration:0.3 animations:^{
        if (!self.isBanner) {
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.equalTo(self.scrollowFatherView);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
            }];
        }else{
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.equalTo(self.scrollowFatherView);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H+self.adViewH));
            }];
        }
        [self.view layoutIfNeeded];
    }];
    
    self.collectionView.isShowHeaderView = NO;
    self.tableView.isShowHeaderView = NO;
    self.nextListHeaderView.hidden = YES;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.nextCollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.collectionView setShowType:[TOPScanerShare top_listType]];
    [self.tableView reloadData];
    [self.nextCollView reloadData];
}
#pragma mark -- 显示头部视图 更改列表坐标
- (void)top_ShowHeaderView{
    [FIRAnalytics logEventWithName:@"homeView_ShowHeaderView" parameters:nil];
    if ([TOPScanerShare top_listType] == ShowListGoods) {
        self.nextListHeaderView.hidden = YES;
    }else{
        self.nextListHeaderView.hidden = NO;
    }
    if (!self.isBanner) {
        if (self.nextListHeaderView.hidden) {
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.bottom.equalTo(self.scrollowFatherView);
                make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight));
            }];
        }else{
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.equalTo(self.scrollowFatherView);
                make.top.equalTo(self.nextListHeaderView.mas_bottom);
                make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight));
            }];
        }
    }else{
        if (self.nextListHeaderView.hidden) {
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.equalTo(self.scrollowFatherView);
                make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight+self.adViewH));
            }];
        }else{
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.scrollowFatherView);
                make.top.equalTo(self.nextListHeaderView.mas_bottom);
                make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight+self.adViewH));
            }];
        }
    }
    
    self.collectionView.isShowHeaderView = YES;
    self.tableView.isShowHeaderView = YES;
    [self.collectionView setShowType:[TOPScanerShare top_listType]];
    [self.tableView reloadData];
    [self.nextCollView reloadData];
}

#pragma mark -- 打开相机
- (void)top_GetCamera{
    [FIRAnalytics logEventWithName:@"homeView_GetCamera" parameters:nil];
    TOPEnterCameraType cameraTpye = TOPShowFolderCameraType;
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = [TOPDocumentHelper top_appBoxDirectory];
    camera.fileType = cameraTpye;
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
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

#pragma mark -- 分享text 即文档的ocr识别
- (void)top_shareText{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * selectArray = [NSMutableArray new];
        for (DocumentModel * allModel in self.homeDataArray) {
            if (allModel.selectStatus) {
                [selectArray addObject:allModel];
            }
        }
        NSMutableArray * documentArray = [NSMutableArray new];
        NSMutableArray * tempArray = [NSMutableArray new];
        for (DocumentModel * selectModel in selectArray) {
            if ([selectModel.type isEqual:@"1"]) {
                [documentArray addObject:selectModel];
            }else{
                NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:selectModel.path documentArray:tempArray];
                for (NSString * docPath in getArry) {
                    DocumentModel *dtModel = [TOPDataModelHandler top_buildDocumentTargetModelWithPath:docPath];
                    [documentArray addObject:dtModel];
                }
            }
        }
        NSMutableArray * childArray = [NSMutableArray new];
        for (DocumentModel * documentModel in documentArray) {
            NSMutableArray *dataArray = [TOPDataModelHandler top_buildDocumentSecondaryDataAtPath:documentModel.path];
            [childArray addObjectsFromArray:dataArray];
        }
        NSMutableArray * ocrArray = [NSMutableArray new];
        for (DocumentModel * ocrModel in childArray) {
            if ([TOPWHCFileManager top_isExistsAtPath:ocrModel.ocrPath]) {
                [ocrArray addObject:ocrModel];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (ocrArray.count == childArray.count) {
                TOPPhotoShowTextAgainVC * ocrTextVC = [TOPPhotoShowTextAgainVC new];
                ocrTextVC.dataArray = ocrArray;
                ocrTextVC.backType = TOPPhotoShowTextAgainVCBackTypePopRoot;
                if (documentArray.count>1) {
                    ocrTextVC.dataType = TOPOCRDataTypeMultipleDocument;
                }else{
                    ocrTextVC.dataType = TOPOCRDataTypeSingleDocument;
                }
                ocrTextVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ocrTextVC animated:YES];
            }else{
                TOPPhotoShowOCRVC * ocrVC = [TOPPhotoShowOCRVC new];
                ocrVC.currentIndex = 0;
                ocrVC.dataArray = childArray;
                ocrVC.backType = TOPPhotoShowTextAgainVCBackTypePopRoot;
                ocrVC.ocrAgain = TOPPhotoShowOCRVCAgainTypeOCRNot;
                ocrVC.finishType = TOPPhotoShowOCRVCAgainFinishNot;
                if (documentArray.count>1) {
                    ocrVC.dataType = TOPOCRDataTypeMultipleDocument;
                }else{
                    ocrVC.dataType = TOPOCRDataTypeSingleDocument;
                }
                ocrVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ocrVC animated:YES];
            }
        });
    });
}

#pragma mark -- UIDocumentPickerDelegate
#pragma mark- iCloud Drive
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(nonnull NSArray<NSURL *> *)urls {
    WS(weakSelf);
    BOOL fileAuthorized = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc]init]; NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) {
            NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:newURL];
            if (error) {
                NSLog(@"读取错误error == %@",error);
            }else {
                NSLog(@"fileName: %@\nfileUrl: %@", fileName, newURL);
                if ([fileName hasSuffix:@".pdf"] || [fileName hasSuffix:@".PDF"]) {
                    CGPDFDocumentRef fromPDFDoc = CGPDFDocumentCreateWithURL((CFURLRef)newURL);
                    if (fromPDFDoc == NULL) {
                        NSLog(@"can't open '%@'", newURL); CFRelease((__bridge CFURLRef)newURL);
                    }else{
                        NSString * sendName = [NSString new];
                        if ([fileName hasSuffix:@".pdf"]) {
                            sendName = [[fileName componentsSeparatedByString:@".pdf"] firstObject];
                        }else{
                            sendName = [[fileName componentsSeparatedByString:@".PDF"] firstObject];
                        }
                        [weakSelf top_dealWithPDF:fromPDFDoc withPath:newURL alertTitle:NSLocalizedString(@"topscan_decryption", @"") alertMessage:@"pdf" fileName:sendName];
                    }
                }
                NSString * lowString = fileName.lowercaseString;
                if ([lowString hasSuffix:@".jpg"] || [lowString hasSuffix:@".png"]|| [lowString hasSuffix:@".jpeg"]) {
                    UIImage *photo = [UIImage imageWithData:fileData];
                    if (photo) {
                        NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [weakSelf top_writeImageDataToDocument:photo withIndex:0 withPath:endPath];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf top_icloudFinishAndPushWithPath:endPath];
                            });
                        });
                    }
                }
            }
        }];
    }
}
- (void)top_dealWithPDF:(CGPDFDocumentRef)fromPDFDoc withPath:(NSURL *)newURL alertTitle:(NSString *)title alertMessage:(NSString *)message fileName:(NSString *)fileName{
    if (CGPDFDocumentIsEncrypted (fromPDFDoc)) {
        WS(weakSelf);
        if (!CGPDFDocumentUnlockWithPassword (fromPDFDoc, "")) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(alert) weakAlert = alert;
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                __strong typeof(weakAlert) strongAlert = weakAlert;
                
                UITextField *  textField=   strongAlert.textFields.firstObject;
                textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if (textField.text != NULL && CGPDFDocumentUnlockWithPassword (fromPDFDoc, [textField.text UTF8String])) {
                    [weakSelf top_pushSendControllerMothodWithPassword:textField.text withPath:fromPDFDoc fileName:fileName];
                }else{
                    [weakSelf top_dealWithPDF:fromPDFDoc withPath:newURL alertTitle:NSLocalizedString(@"topscan_error", @"") alertMessage:NSLocalizedString(@"topscan_pdferror", @"") fileName:fileName];
                }
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_skip", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                return;
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedString(@"topscan_placeholderpassword", @"");
            }];
            [alert addAction:cancelAction];
            
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }else{
        [self top_pushSendControllerMothodWithPassword:nil withPath:fromPDFDoc fileName:fileName];
    }
}

#pragma mark -- 倒入pdf的处理
- (void)top_pushSendControllerMothodWithPassword:(NSString *)passwordStr withPath:(CGPDFDocumentRef)fromPDFDoc fileName:(NSString *)fileName{
    NSString * endPath = [NSString new];
    if (fileName.length>0) {
        NSString *filePath = [[TOPDocumentHelper top_getDocumentsPathString] stringByAppendingPathComponent:fileName];
        endPath = [TOPDocumentHelper top_createDirectoryAtPath:filePath];
    }else{
        endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
    }
    
    WS(weakSelf);
    [[TOPProgressStripeView shareInstance]top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
    [TOPDocumentHelper top_getUIImageFromPDFPageWithpdfpathUrl:fromPDFDoc password:passwordStr docPath:endPath  progress:^(CGFloat progressString) {
        [[TOPProgressStripeView shareInstance]top_showProgress:progressString withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
    } success:^(id  _Nonnull responseObj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [weakSelf top_icloudFinishAndPushWithPath:endPath];
        });
    }];
}

#pragma mark -- icloud图片写入doc文件夹
- (void)top_writeImageDataToDocument:(UIImage *)image withIndex:(NSInteger)index withPath:(NSString *)endPath{
    NSString *imgName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:index],TOP_TRJPGPathSuffixString];
    NSString *oriName = [NSString stringWithFormat:@"%@%@%@%@",TOPRSimpleScanOriginalString,[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:index],TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [endPath stringByAppendingPathComponent:imgName];
    NSString *oriEndPath = [endPath stringByAppendingPathComponent:oriName];
    [UIImageJPEGRepresentation(image,TOP_TRPicScale) writeToFile:fileEndPath atomically:YES];
    [UIImageJPEGRepresentation(image,TOP_TRPicScale) writeToFile:oriEndPath atomically:YES];
}

#pragma mark -- icloud处理完成之后的跳转
- (void)top_icloudFinishAndPushWithPath:(NSString *)endPath{
    DocumentModel *model = [TOPDBDataHandler top_addNewDocModel:endPath];
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    childVC.docModel = model;
    childVC.pathString = endPath;
    childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
    childVC.addType = @"add";
    childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
    childVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:childVC animated:YES];
}

#pragma mark -- Send feedback
- (void)top_settingView_SendFeedback{
    [FIRAnalytics logEventWithName:@"settingView_SendFeedback" parameters:nil];
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        return;
    }
    if (![mailClass canSendMail]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_bind", @"")
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

#pragma mark --UI 布局界面
- (void)top_setupNavBar {
    TOPHomePageHeaderView * homeNavbarView = [self setMyHomeNavbarView];
    self.navigationItem.titleView = homeNavbarView;
    [homeNavbarView top_setupUI];
}

- (void)top_freeSizeState{
    CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
    if (freeSize<200.0) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacetitle", @"") duration:2];
    }
}

- (void)top_hideScoreView{
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha = 0;
        self.scoreView.alpha = 0;
        [self.coverView removeFromSuperview];
        self.coverView = nil;
        [self.scoreView removeFromSuperview];
        self.scoreView = nil;
    }];
}
- (void)top_judgeScoreView{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isThis = [TOPDataModelHandler top_documentIsThereAnyData:[TOPDocumentHelper top_appBoxDirectory]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![TOPScanerShare top_savesScoreBox]) {
                if (isThis) {
                    [self top_showScoreView];
                    [TOPScanerShare top_writeSaveScoreBox:YES];
                }else{
                    if ([TOPScanerShare top_saveScoreBoxNumber] >= 3 && [[TOPDocumentHelper top_getCurrentTimeInterval] integerValue]>[[TOPScanerShare top_saveOneDataLater] integerValue]) {
                        [self top_showScoreView];
                        [TOPScanerShare top_writeSaveScoreBox:YES];
                    }
                }
            }else{
                if ([TOPScanerShare top_saveClickFiveStar]||[TOPScanerShare top_saveClickNotnowBtn]==3) {
                }else{
                    if ([[TOPDocumentHelper top_getCurrentTimeInterval] integerValue]>[[TOPScanerShare top_saveThreeDataLater] integerValue]&&[TOPScanerShare top_saveScoreBoxNumber]>=5) {
                        [self top_showScoreView];
                        [TOPScanerShare top_writeSaveScoreBox:YES];
                    }
                }
            }
            
            static dispatch_once_t nextToken;
            dispatch_once(&nextToken, ^{
                if (!self.isShowSubscriptView) {
                    if (!self->_scoreView) {
                        [self top_showSuggestionToastView];
                    }
                }
            });
        });
    });
}

- (void)top_jumpToNextFolderVC:(DocumentModel *)model {
    TOPNextFolderViewController * nextFonderVC = [TOPNextFolderViewController new];
    nextFonderVC.docModel = model;
    nextFonderVC.pathString = model.path;
    nextFonderVC.homeArray = [self removeAdModelArray];
    [self.navigationController pushViewController:nextFonderVC animated:YES];
}

#pragma mark -- 接收分享数据后刷新数据
- (void)top_saveSharePDFAndImgAndReload{
    [self top_CancleSelectAction];
    [self top_LoadSanBoxData:[TOPScanerShare top_sortType]];
}

- (TOPHomePageHeaderView *)setMyHomeNavbarView{
    WS(weakSelf);
    TOPHomePageHeaderView * homeNavbarView = [[TOPHomePageHeaderView alloc]init];
    homeNavbarView.backgroundColor = [UIColor clearColor];
    homeNavbarView.top_DocumentHeadClickHandler = ^(NSInteger index, BOOL selected) {
        switch (index) {
            case 0:
                [weakSelf top_HomeTopSearch];
                break;
            case 1:
                [weakSelf top_HomeTopSetting];
                break;
            case 2:
                [weakSelf top_HomeTopUpgradeVip];
                break;
            default:
                break;
        }
    };
    return homeNavbarView;
}
- (void)top_sendToSuggestionVC{
    [FIRAnalytics logEventWithName:@"sendToSuggestionVC" parameters:nil];
    TOPSuggestionsVC * suggestionVC = [TOPSuggestionsVC new];
    suggestionVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:suggestionVC animated:YES];
}
#pragma mark -- 是否展示订阅弹框
- (void)top_showSubscriptAlertView
{
    TOPTagsListModel * listModel = self.tagsArray[0];
    NSInteger num = [listModel.tagNum integerValue];
    NSInteger showNum = [TOPScanerShare top_showSubscriptViewNum];
    if (showNum <8) {
        if (showNum == 0) {
            if (num>=3 && [TOPScanerShare top_subscriptBecomeNum]>=5) {
                [self top_showSubscript:showNum];
                [self top_showVipRemindView];
            }else{
                [self top_hideVipRemindView];
            }
        }else{
            if (showNum>3 && [TOPScanerShare top_subscriptBecomeNum]==10) {
                [self top_showSubscript:showNum];
                [self top_showVipRemindView];
            }else{
                [self top_hideVipRemindView];
            }
            if (showNum <=3 && [TOPScanerShare top_subscriptBecomeNum]==5) {
                [self top_showSubscript:showNum];
                [self top_showVipRemindView];
            }else{
                [self top_hideVipRemindView];
            }
        }
    }else{
        [self top_hideVipRemindView];
    }
}
- (void)top_showVipRemindView{
    self.collectionView.isShowVip = YES;
    self.tableView.isShowVip = YES;
    self.nextListHeaderView.isShowVip = YES;
    [self top_listNextViewState:YES];
}
- (void)top_hideVipRemindView{
    self.collectionView.isShowVip = NO;
    self.tableView.isShowVip = NO;
    self.nextListHeaderView.isShowVip = NO;
    [self top_listNextViewState:NO];
}
- (void)top_listNextViewState:(BOOL)isShowVip{
    CGFloat listHeaderH = 0;
    if ([TOPUserInfoManager shareInstance].isVip) {
        listHeaderH = TopView_H;
        isShowVip = NO;
    }else{
        if (isShowVip) {
            listHeaderH = TopView_H+70;
        }else{
            listHeaderH = TopView_H;
        }
    }
    [self top_setListNextViewMask:listHeaderH];
}
- (void)top_showSubscript:(NSInteger)showNum
{
    WS(weakself);
    if (!self.alertTipSubscriptView) {
        [FIRAnalytics logEventWithName:@"showSubscribeView" parameters:nil];
        self.alertTipSubscriptView = [[TOPSubscriptionEYearAlertView alloc] initWithAlertViewSelectBlock:^(TOPSubscriptionEYearAlertView * _Nonnull showAlertView) {
            showAlertView.hidden = YES;
            TOPUnlockFunctionViewController *functionVC = [[TOPUnlockFunctionViewController alloc] init];
            functionVC.purchaseSuecssCloseHomeAlertBlock = ^(BOOL isPurchaseSuecss) {
                if (isPurchaseSuecss) {
                    [showAlertView top_dismissUnBoundView];
                    weakself.isShowSubscriptView = NO;
                }else{
                    showAlertView.hidden = NO;
                }
            };
            functionVC.hidesBottomBarWhenPushed = YES;
            [weakself.navigationController pushViewController:functionVC animated:YES];
        } cancelBlock:^{
            weakself.isShowSubscriptView = NO;
        }];
        [self.alertTipSubscriptView top_showAlertUnBoundView];
    }
    
    self.isShowSubscriptView = YES;
    [TOPScanerShare top_writeSubscriptBecomeNum:0];
    showNum ++;
    [TOPScanerShare top_writeshowSubscriptViewNum:showNum];
}

- (void)top_showSuggestionToastView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    TOPTagsListModel * listModel = self.tagsArray[0];
    NSInteger num = [listModel.tagNum integerValue];
    if ([TOPScanerShare top_theCountSuggestionView]<2) {
        if ([TOPScanerShare top_theCountSuggestionView] == 0) {
            if ([TOPScanerShare top_theCountEnterApp]>1) {
                if (![TOPScanerShare top_onlyOldUserShow]) {
                    [FIRAnalytics logEventWithName:@"showSuggestionToastView" parameters:nil];
                    [keyWindow addSubview:self.suggestionToastView];
                    [TOPScanerShare top_writeSuggestionViewCount:2];
                    [TOPScanerShare top_writeOldUserShow:YES];
                }else{
                    if (num>3&&[TOPScanerShare top_theCountEnterApp]>5) {
                        [FIRAnalytics logEventWithName:@"showSuggestionToastView" parameters:nil];
                        [keyWindow addSubview:self.suggestionToastView];
                        [TOPScanerShare top_writeSuggestionViewCount:1];
                    }
                }
            }else{
                [TOPScanerShare top_writeOldUserShow:YES];
            }
        }else{
            if (num>30&&[TOPScanerShare top_theCountEnterApp]>50) {
                [FIRAnalytics logEventWithName:@"showSuggestionToastView" parameters:nil];
                [keyWindow addSubview:self.suggestionToastView];
                [TOPScanerShare top_writeSuggestionViewCount:2];
            }
        }
    }
}
- (void)top_hideSuggestionView{
    [UIView animateWithDuration:0.3 animations:^{
        self.suggestionToastView.alpha = 0;
    }completion:^(BOOL finished) {
        [self.suggestionToastView removeFromSuperview];
        self.suggestionToastView = nil;
    }];
}
#pragma mark -- 设置约束
- (void)top_markupCoverMask{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}

#pragma mark -- 广告
#pragma mark -- 原生广告
- (void)top_getNativeAd{
    NSString * adID = @"ca-app-pub-3940256099942544/3986624511";
    if ([TOPScanerShare top_listType] == ShowTwoGoods) {
        adID = [TOPDocumentHelper top_nativeAdID][0];
    }else if([TOPScanerShare top_listType] == ShowThreeGoods){
        adID = [TOPDocumentHelper top_nativeAdID][1];
    }else if([TOPScanerShare top_listType] == ShowListGoods){
        adID = [TOPDocumentHelper top_nativeAdID][2];
    }else if([TOPScanerShare top_listType] == ShowListNextGoods){
        adID = [TOPDocumentHelper top_nativeAdID][2];
    }
    GADMultipleAdsAdLoaderOptions *multipleAdsOptions = [[GADMultipleAdsAdLoaderOptions alloc] init];
    multipleAdsOptions.numberOfAds = 1;
    
    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
    videoOptions.startMuted = YES ;
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:adID
                                       rootViewController:self
                                                  adTypes:@[kGADAdLoaderAdTypeNative]
                                                  options:@[multipleAdsOptions,videoOptions]];
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:[GADRequest request]];
    
}
- (void)adLoaderDidFinishLoading:(GADAdLoader *) adLoader {
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error{
}
#pragma mark -- 获取原生广告成功
- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    [FIRAnalytics logEventWithName:@"top_nativeDidReceiveAd" parameters:nil];
    DocumentModel * nativeAdModel = [DocumentModel new];
    nativeAdModel.adModel = nativeAd;
    nativeAdModel.isAd = YES;
    self.nativeAdModel = nativeAdModel;
    [self top_adReceiveFinishAndRefreshUI];
    [self top_refreshUI];
    [self top_sumAllFileSize];//显示文件大小的lab
}
#pragma mark -- 原生广告接收完成并刷新UI
- (void)top_adReceiveFinishAndRefreshUI {
    if (self.nativeAdModel) {
        NSInteger adIndex = 0;
        if (self.navADIndex) {
            if (self.navADIndex>self.homeDataArray.count) {
                self.navADIndex = self.homeDataArray.count;
            }
            adIndex = self.navADIndex;
        }else{
            adIndex = [TOPDocumentHelper top_adMobIndexWithListType:[TOPScanerShare top_listType] byItemCount:self.homeDataArray.count];
            self.navADIndex = adIndex;
        }
        [self.homeDataArray insertObject:self.nativeAdModel atIndex:adIndex];
        self.collectionView.listArray = self.homeDataArray;
        self.tableView.listArray = self.homeDataArray;
        
        [self.tableView reloadData];
        
        self.nextCollView.listArray = self.homeDataArray;
        [self.nextCollView reloadData];
    }
}
- (void)top_refreshUI{
    [self.collectionView setShowType:[TOPScanerShare top_listType]];
    [self.tableView reloadData];
    [self.nextCollView reloadData];
}
#pragma mark -- 横幅广告
- (void)top_AddBannerViewWithSize:(CGSize)currentSize{
    GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(currentSize.width);
    self.adViewH = adSize.size.height;
    NSString * adID = @"ca-app-pub-3940256099942544/2934735716";
    adID = [TOPDocumentHelper top_bannerAdID][0];
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
        make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
    }];
}
#pragma mark -- 获取横幅广告成功
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView{
    [FIRAnalytics logEventWithName:@"top_bannerReceiveAd" parameters:nil];
    if (bannerView) {
        bannerView.hidden = NO;
        self.isBanner = YES;
        [self top_adFinishContentFatherFream];
        [self top_sumAllFileSize];//显示文件大小的lab
    }
}

#pragma mark -- 获取横幅广告失败
- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    [self top_adFailContentFatherFream];
    [self top_sumAllFileSize];//显示文件大小的lab
    self.scBannerView.hidden = YES;
    self.isBanner = NO;
}

- (void)top_adFinishContentFatherFream{
    if ([TOPScanerShare shared].isEditing == YES) {
        [self.pressBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
            make.height.mas_equalTo(60);
        }];
        if (self.nextListHeaderView.hidden) {
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.equalTo(self.scrollowFatherView);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H+self.adViewH));
            }];
        }else{
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.scrollowFatherView);
                make.top.equalTo(self.nextListHeaderView.mas_bottom);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H+self.adViewH));
            }];
        }
        [self.scBannerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        }];
    }else{
        if (self.nextListHeaderView.hidden) {
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.equalTo(self.scrollowFatherView);
                make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight+self.adViewH));
            }];
        }else{
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.scrollowFatherView);
                make.top.equalTo(self.nextListHeaderView.mas_bottom);
                make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight+self.adViewH));
            }];
        }
    }
}
- (void)top_adFailContentFatherFream{
    if ([TOPScanerShare shared].isEditing == YES) {
        [self.pressBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
            make.height.mas_equalTo(60);
        }];
        if (self.nextListHeaderView.hidden) {
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.equalTo(self.scrollowFatherView);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
            }];
        }else{
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.scrollowFatherView);
                make.top.equalTo(self.nextListHeaderView.mas_bottom);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
            }];
        }
    }else{
        if (self.nextListHeaderView.hidden) {
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.equalTo(self.scrollowFatherView);
                make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight));
            }];
        }else{
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.scrollowFatherView);
                make.top.equalTo(self.nextListHeaderView.mas_bottom);
                make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight));
            }];
        }
    }
}
#pragma mark -- 插页广告 1~7的随机数与界面ID相等时才显示插页广告
- (void)top_getInterstitialAd{
    WS(weakSelf);
    GADRequest *request = [GADRequest request];
    NSString * adID = @"ca-app-pub-3940256099942544/4411468910";
    adID = [TOPDocumentHelper top_interstitialAdID][0];
    [GADInterstitialAd loadWithAdUnitID:adID
                                request:request
                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
            [weakSelf top_getInterstitialAd];
            [FIRAnalytics logEventWithName:@"top_getInterstitialAdFailed" parameters:nil];
        }else{
            [FIRAnalytics logEventWithName:@"top_getInterstitialAdSuccessed" parameters:nil];
            weakSelf.interstitial = ad;
            weakSelf.interstitial.fullScreenContentDelegate = weakSelf;
            if (weakSelf.interstitial) {
                [weakSelf.interstitial presentFromRootViewController:weakSelf];
            }
        }
    }];
}
#pragma mark -- 去掉原生广告之后的数据
- (NSMutableArray *)removeAdModelArray{
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if (!model.isAd) {
            [tempArray addObject:model];
        }
    }
    return tempArray;
}
#pragma mark-- 导航栏设置按钮旁边的升级vip按钮的点击事件
- (void)top_HomeTopUpgradeVip{
    if ([TOPUserInfoManager shareInstance].isVip) {
        [self top_userVipDetail];
    }else{
        [self top_userUpGradeVip];
    }
}
#pragma mark -- 用户升级VIP
- (void)top_userUpGradeVip {
    if ([TOPAppTools needShowDiscountThemeView]) {
        [[TOPDiscountThemeView shareInstance] top_showDiscountTheme:@"20211123_year_sub"];
        [TOPDiscountThemeView shareInstance].purchaseSucceed = ^{
            [self top_setupNavBar];
        };
        [TOPDiscountThemeView shareInstance].overTimeBlock = ^{
            [self top_setupNavBar];
        };
    } else {
        TOPSubscriptionPayListViewController *subscriptVC = [[TOPSubscriptionPayListViewController alloc] init];
        subscriptVC.closeType = TOPSubscriptOverCloseTypeDissmiss;
        TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:subscriptVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}
#pragma mark -- 用户订阅详情
- (void)top_userVipDetail{
    TOPUnlockFunctionViewController *functionVC = [[TOPUnlockFunctionViewController alloc] init];
    functionVC.isHiddenBottomSubScript = YES;
    functionVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:functionVC animated:YES];
}

#pragma mark -- lazy
- (UIView *)contentFatherView {
    if (!_contentFatherView) {
        _contentFatherView = [[UIView alloc] init];
        _contentFatherView.backgroundColor = [UIColor clearColor];
    }
    return _contentFatherView;
}
- (UIView *)scrollowFatherView {
    if (!_scrollowFatherView) {
        _scrollowFatherView = [[UIView alloc] initWithFrame:CGRectMake(0, FatherTop_Y, TOPScreenWidth, TOPScreenHeight -TOPNavBarAndStatusBarHeight -FatherTop_Y-TOPTabBarHeight)];
        _scrollowFatherView.backgroundColor = [UIColor clearColor];
        _scrollowFatherView.layer.cornerRadius = 5;
        _scrollowFatherView.layer.masksToBounds = YES;
    }
    return _scrollowFatherView;
}
- (NSMutableArray *)selectedDocsIndexArray {
    if (!_selectedDocsIndexArray) {
        _selectedDocsIndexArray = [@[] mutableCopy];
    }
    return _selectedDocsIndexArray;
}

- (NSMutableArray*)homeDataArray{
    if (!_homeDataArray) {
        _homeDataArray = [NSMutableArray array];
    }
    return _homeDataArray;
}

- (NSMutableArray*)homeMoreArray{
    if (!_homeMoreArray) {
        _homeMoreArray = [NSMutableArray new];
    }
    return _homeMoreArray;
}

- (NSMutableArray*)tagsArray{
    if (!_tagsArray) {
        _tagsArray = [NSMutableArray new];
    }
    return _tagsArray;
}

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_ClickTapAction)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

#pragma mark -- 密码弹框
- (TOPDocPasswordView *)passwordView{
    if (!_passwordView) {
        WS(weakSelf);
        _passwordView = [[TOPDocPasswordView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolderSingle_H)];
        _passwordView.top_sendPassword = ^(NSString * _Nonnull password, NSInteger actionType,BOOL isShowFailToast) {
            weakSelf.isShowFailToast = isShowFailToast;
            [weakSelf top_passwordViewActionWithPassword:password WithType:actionType];
        };
        _passwordView.top_clickToHide = ^{
            [weakSelf top_ClickTapAction];
        };
        
        _passwordView.top_clickToHelp = ^{
            [weakSelf top_settingView_SendFeedback];
        };
    }
    return _passwordView;
}

- (TOPAddFolderView *)addFolderView{
    if (!_addFolderView) {
        WS(weakSelf);
        _addFolderView = [[TOPAddFolderView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolder_W)];
        _addFolderView.top_clickToSendString = ^(NSString * _Nonnull editString) {
            if ([weakSelf.folderViewType isEqualToString:FolderViewTypeAdd]) {
                [weakSelf top_HomeHeaderAddFolderAction:editString];
            }else{
                [weakSelf top_ClickToChangeFolderNameAction:editString];
            }
            [weakSelf top_ClickTapAction];
        };
        
        _addFolderView.top_clickToHide = ^{
            [weakSelf top_ClickTapAction];
        };
    }
    return _addFolderView;
}

#pragma mark -- 评分视图
- (TOPScoreView *)scoreView{
    if (!_scoreView) {
        WS(weakSelf);
        NSString * titleString = NSLocalizedString(@"topscan_scoretitle", @"");
        CGFloat titleH = [TOPDocumentHelper top_getSizeWithStr:titleString Width:TOPScreenWidth-100 Font:17].height+10;
        _scoreView = [[TOPScoreView alloc]initWithFrame:CGRectMake(20, (TOPScreenHeight-(160+titleH))/2, TOPScreenWidth-40, 160+titleH)];
        _scoreView.top_clickCancelBtn = ^{
            [FIRAnalytics logEventWithName:@"scoreCancel" parameters:nil];
            [weakSelf top_hideScoreView];
            NSInteger count = [TOPScanerShare top_saveClickNotnowBtn];
            count++;
            [TOPScanerShare top_writeSaveClickNotnowBtn:count];
            NSString * timeString = [TOPDocumentHelper top_getTimeAfterNowWithDay:3];
            [TOPScanerShare top_writeSaveThreeDataLater:timeString];
            [TOPScanerShare top_writeSaveScoreBoxNumber:0];
        };
        
        _scoreView.top_clickFiveStarBtn = ^{
            [FIRAnalytics logEventWithName:@"scoreFiveStare" parameters:nil];
            [TOPScanerShare top_writeSaveClickFiveStar:YES];
            [weakSelf top_hideScoreView];
            NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", @"1531265666"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
        };
    }
    return _scoreView;
}
- (TOPSuggestionToastView *)suggestionToastView{
    if (!_suggestionToastView) {
        WS(weakSelf);
        _suggestionToastView = [[TOPSuggestionToastView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _suggestionToastView.top_clickContinue = ^{
            [weakSelf top_sendToSuggestionVC];
            [weakSelf top_hideSuggestionView];
        };
        _suggestionToastView.top_clickHideView = ^{
            [weakSelf top_hideSuggestionView];
        };
    }
    return _suggestionToastView;
}

- (UIView *)leftTagsCoverView{
    if (!_leftTagsCoverView) {
        _leftTagsCoverView = [[UIView alloc]init];
        _leftTagsCoverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_ClickLeftTapAction)];
        [_leftTagsCoverView addGestureRecognizer:tap];
    }
    return _leftTagsCoverView;
}
#pragma mark -- 拍照按钮
- (TOPWMDragView*)photoView{
    if (!_photoView) {
        WS(weakSelf);
        _photoView = [[TOPWMDragView alloc] initWithFrame:CGRectZero];
        _photoView.imageView.image = [UIImage imageNamed:@"icon_paizhao_gai"];
        _photoView.backgroundColor = [UIColor clearColor];
        _photoView.layer.cornerRadius = (30);
        _photoView.layer.masksToBounds =  YES;
        _photoView.isKeepBounds = NO;
        _photoView.endDragBlock = ^(TOPWMDragView *dragView) {
            
        };
        
        _photoView.clickDragViewBlock = ^(TOPWMDragView *dragView){
            SS(strongSelf);
            [strongSelf top_GetCamera];
        };
    }
    return _photoView;
}

- (TOPHomeShowView *)topMoreView{
    if (!_topMoreView) {
        WS(weakSelf);
        _topMoreView = [[TOPHomeShowView alloc]init];
        _topMoreView.top_clickCellAction = ^(NSInteger row) {
            [weakSelf top_HomeHeaderMoreAction:row];
            [weakSelf top_ClickTapAction];
        };
        
        _topMoreView.top_clickDismiss = ^{
            
        };
    }
    return _topMoreView;
}

#pragma mark -- 标签的弹出视图
- (TOPHomeShowView *)leftTagsView{
    if (!_leftTagsView) {
        WS(weakSelf);
        _leftTagsView = [[TOPHomeShowView alloc]init];
        _leftTagsView.top_clickTagsCell = ^(TOPTagsListModel * _Nonnull model) {
            [weakSelf top_refreshAndShowTagsDoc:model];
            [weakSelf top_nativeAdShowState];
            [weakSelf top_ClickLeftTapAction];
        };
        _leftTagsView.top_clickTagsFooterBtn = ^{
            [weakSelf top_jumpToTagsManagerVC];
            [weakSelf top_ClickLeftTapAction];
        };
    }
    return _leftTagsView;
}

- (TOPDocumentCollectionView *)collectionView{
    if (!_collectionView) {
        weakify(self);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
        
        _collectionView = [[TOPDocumentCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.isShowHeaderView = YES;
        _collectionView.isMoveState = NO;
        _collectionView.isFromSecondFolderVC = NO;
        _collectionView.top_DocumentHomeHandler = ^(NSInteger index,BOOL selected) {
            [weakSelf top_PresentPopViewWithType:index selected:selected];
        };
        
        _collectionView.top_tagShow = ^(BOOL isSelect) {
            [weakSelf top_showTagsView];
        };
        _collectionView.top_pushNextControllerHandler = ^(DocumentModel * model) {
            if ([model.type isEqualToString:@"0"]) {
                [weakSelf top_jumpToNextFolderVC:model];
            }else{
                weakSelf.docModel = model;
                [weakSelf top_judgeClickDocPasswordState];
            }
        };
        
        _collectionView.top_longPressEditHandler = ^(NSIndexPath * _Nonnull idxPath){
            [weakSelf top_ShowPressUpView];
        };
        _collectionView.top_longPressCheckItemHandler = ^(NSInteger index, BOOL selected) {
            DocumentModel *model = weakSelf.homeDataArray[index];
            if (!model.isAd) {
                model.selectStatus = selected;
                if (selected) {
                    [weakSelf.selectedDocsIndexArray addObject:model];
                } else {
                    [weakSelf.selectedDocsIndexArray removeObject:model];
                }
            }
        };
        //
        _collectionView.top_longPressCalculateSelectedHander = ^{
            [weakSelf top_RefreshViewWithSelectItem];
        };
        _collectionView.top_upGradeVip = ^{
            [weakSelf top_userUpGradeVip];
        };
        _collectionView.top_didScrolInBottom = ^(BOOL isBottom) {
            weakSelf.fileSizeLab.hidden = !isBottom;
        };
        _collectionView.top_scrollAndSendContentOffset = ^(CGFloat contentOffsetY) {
            weakSelf.contentOffSetY = contentOffsetY;
        };
        _collectionView.top_scrollDidEndDecelerating = ^{
            [weakSelf.ges setTranslation:CGPointZero inView:weakSelf.scrollowFatherView];
            weakSelf.containerOrigin = CGPointZero;
        };
        [_collectionView addGestureRecognizer];
    }
    return _collectionView;
}
- (TOPNextCollectionView *)nextCollView{
    if (!_nextCollView) {
        weakify(self);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
        _nextCollView = [[TOPNextCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _nextCollView.isFromSecondFolderVC = NO;
        _nextCollView.top_DocumentHomeHandler = ^(NSInteger index,BOOL selected) {
            [weakSelf top_PresentPopViewWithType:index selected:selected];
        };
        
        _nextCollView.top_tagShow = ^(BOOL isSelect) {
            [weakSelf top_showTagsView];
        };
        _nextCollView.top_pushNextControllerHandler = ^(DocumentModel * model) {
            if ([model.type isEqualToString:@"0"]) {
                [weakSelf top_jumpToNextFolderVC:model];
            }else{
                weakSelf.docModel = model;
                [weakSelf top_judgeClickDocPasswordState];
            }
        };
        
        _nextCollView.top_longPressEditHandler = ^(NSIndexPath * _Nonnull idxPath){
            [weakSelf top_ShowPressUpView];
        };
        _nextCollView.top_longPressCheckItemHandler = ^(DocumentModel * model, BOOL selected) {
            if (!model.isAd) {
                model.selectStatus = selected;
                if (selected) {
                    [weakSelf.selectedDocsIndexArray addObject:model];
                } else {
                    [weakSelf.selectedDocsIndexArray removeObject:model];
                }
            }
        };
        _nextCollView.top_longPressCalculateSelectedHander = ^{
            [weakSelf top_RefreshViewWithSelectItem];
        };
        _nextCollView.top_upGradeVip = ^{
            [weakSelf top_userUpGradeVip];
        };
        _nextCollView.top_didScrolInBottom = ^(BOOL isBottom) {
            weakSelf.fileSizeLab.hidden = !isBottom;
        };
        _nextCollView.top_scrollAndSendContentOffset = ^(CGFloat contentOffsetY) {
            weakSelf.contentOffSetY = contentOffsetY;
        };
        _nextCollView.top_scrollDidEndDecelerating = ^{
            [weakSelf.ges setTranslation:CGPointZero inView:weakSelf.scrollowFatherView];
            weakSelf.containerOrigin = CGPointZero;
        };
        [_nextCollView addGestureRecognizer];
    }
    return _nextCollView;
}

- (TOPDocumentTableView *)tableView{
    if (!_tableView) {
        weakify(self);
        _tableView = [[TOPDocumentTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.isShowHeaderView = YES;
        _tableView.isFromSecondFolderVC = NO;
        _tableView.top_DocumentHomeHandler = ^(NSInteger index,BOOL selected) {
            [weakSelf top_PresentPopViewWithType:index selected:selected];
        };
        _tableView.top_pushNextControllerHandler = ^(DocumentModel * model) {
            if ([model.type isEqualToString:@"0"]) {
                [weakSelf top_jumpToNextFolderVC:model];
            }else{
                weakSelf.docModel = model;
                [weakSelf top_judgeClickDocPasswordState];
            }
        };
        
        _tableView.top_longPressEditHandler = ^(NSIndexPath * _Nonnull idxPath){
            [weakSelf top_ShowPressUpView];
        };
        _tableView.top_longPressCheckItemHandler = ^(NSInteger index, BOOL selected) {
            DocumentModel *model = weakSelf.homeDataArray[index];
            if (!model.isAd) {
                model.selectStatus = selected;
                if (selected) {
                    [weakSelf.selectedDocsIndexArray addObject:model];
                } else {
                    [weakSelf.selectedDocsIndexArray removeObject:model];
                }
            }
        };
        _tableView.top_longPressCalculateSelectedHander = ^{
            [weakSelf top_RefreshViewWithSelectItem];
        };
        
        _tableView.top_clickSideToShare = ^ {
            weakSelf.emailType = 0;
            [weakSelf top_judgePasswordViewState:0];
        };
        
        _tableView.top_clickSideToEmail = ^{
            weakSelf.emailType = 1;
            [weakSelf top_judgePasswordViewState:0];
        };
        
        _tableView.top_clickSideToRename = ^{
            [weakSelf top_judgePasswordViewState:5];
        };
        
        _tableView.top_clickSideToDelete = ^{
            [weakSelf top_judgePasswordViewState:3];
        };
        
        _tableView.top_DocumentHomeHandler = ^(NSInteger index,BOOL selected) {
            [weakSelf top_PresentPopViewWithType:index selected:selected];
        };
        
        _tableView.top_tagShow = ^(BOOL isSelect) {
            [weakSelf top_showTagsView];
        };
        _tableView.top_upGradeVip = ^{
            [weakSelf top_userUpGradeVip];
        };
        _tableView.top_didScrolInBottom = ^(BOOL isBottom) {
            weakSelf.fileSizeLab.hidden = !isBottom;
        };
        _tableView.top_scrollAndSendContentOffset = ^(CGFloat contentOffsetY) {
            weakSelf.contentOffSetY = contentOffsetY;
        };
        _tableView.top_scrollDidEndDecelerating = ^{
            [weakSelf.ges setTranslation:CGPointZero inView:weakSelf.scrollowFatherView];
            weakSelf.containerOrigin = CGPointZero;
        };
        [_tableView addGestureRecognizer];
    }
    return _tableView;
}
- (TOPDocumentHeadReusableView *)nextListHeaderView{
    if (!_nextListHeaderView) {
        _nextListHeaderView = [[TOPDocumentHeadReusableView alloc]initWithFrame:CGRectZero];
        _nextListHeaderView.hidden = YES;
        weakify(self);
        _nextListHeaderView.top_DocumentHeadClickHandler = ^(NSInteger index,BOOL selected) {
            [weakSelf top_PresentPopViewWithType:index selected:selected];
        };
        _nextListHeaderView.top_tagBtnClick = ^(BOOL selected) {
            [weakSelf top_showTagsView];
        };
        _nextListHeaderView.top_freeTrial = ^{
            [weakSelf top_userUpGradeVip];
        };
    }
    return _nextListHeaderView;
}
- (UILabel*)fileSizeLab {
    if (!_fileSizeLab) {
        _fileSizeLab = [[UILabel alloc] initWithFrame:CGRectMake((100) , TOPStatusBarHeight + 8, TOPScreenWidth - (200), (18))];
        _fileSizeLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kTabbarNormal];
        _fileSizeLab.font = [self fontsWithSize:13];
        _fileSizeLab.textAlignment = NSTextAlignmentCenter;
        self.fileSizeLab.hidden = YES;
    }
    return _fileSizeLab;;
}
- (UIView *)sortCoverView{
    if (!_sortCoverView) {
        _sortCoverView = [[UIView alloc]init];
        _sortCoverView.backgroundColor = RGBA(0, 0, 0, 0.4);
        _sortCoverView.alpha = 0;
        _sortCoverView.userInteractionEnabled = YES;
        UITapGestureRecognizer * top_sortTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_sortTap)];
        [_sortCoverView addGestureRecognizer:top_sortTap];
    }
    return _sortCoverView;
}
#pragma mark --顶部视图
- (TOPTopHideView *)topHideView{
    if (!_topHideView) {
        WS(weakSelf);
        _topHideView = [[TOPTopHideView alloc]init];
        _topHideView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAPPGreenColor];;
        _topHideView.top_topViewAction = ^(NSInteger index) {
            [weakSelf top_TopHideViewWithType:index];
        };
    }
    return _topHideView;
}
#pragma mark -- 编辑选中文件时 底部菜单的数据源
- (NSArray *)top_SendPicArray {
    NSArray * temp = @[@"top_downview_share",@"top_downview_merge",@"top_downview_copyFile",@"top_downview_selectdelete",@"top_downview_moreFun"];
    return temp;
}

- (NSArray *)top_PicArray {
    NSArray * temp = @[@"top_downview_disableshare",@"top_downview_disablemerge",@"top_downview_disablecopy",@"top_downview_disabledelete",@"top_downview_disablemorefun"];
    return temp;
}

- (NSArray *)top_FuncItems {
    NSArray * temp = @[@(TOPMenuItemsFunctionShare),@(TOPMenuItemsFunctionMerge),@(TOPMenuItemsFunctionCopyMove),@(TOPMenuItemsFunctionDelete),@(TOPMenuItemsFunctionMore),@(TOPMenuItemsFunctionRename)];
    return temp;
}

- (NSArray *)top_SendNameArray {//
    NSArray * temp = @[NSLocalizedString(@"topscan_share", @""),NSLocalizedString(@"topscan_merge", @""),NSLocalizedString(@"topscan_copy", @""),NSLocalizedString(@"topscan_delete", @""),NSLocalizedString(@"topscan_more", @"")];
    return temp;
}

- (NSArray *)top_HomeHeaderArray{
    NSArray * homeArray = @[@(TOPHomeHeaderFunctionMore),@(TOPHomeHeaderFunctionSelectState),@(TOPHomeHeaderFunctionViewType),@(TOPHomeHeaderFunctionCameraPicture),@(TOPHomeHeaderFunctionAddFolder)];
    
    return homeArray;
}

- (NSArray *)top_TopHideArray{
    NSArray * hideArray = @[@(TOPHomeVCTopHideViewStateBackup),@(TOPHomeVCTopHideViewStateImportPic),@(TOPHomeVCTopHideViewStateSyntheticPDF),@(TOPHomeVCTopHideViewStateImportDoc),@(TOPHomeVCTopHideViewStateFunctionMore)];
    return hideArray;
}

-(void)top_createDispatch_source_t {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _sourceTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    NSTimeInterval delayTime = 1.0f;
    NSTimeInterval timeInterval = 1.0f;
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    dispatch_source_set_timer(_sourceTimer,startDelayTime,timeInterval*NSEC_PER_SEC,0.1*NSEC_PER_SEC);
    __block int i = 1;
    dispatch_source_set_event_handler(_sourceTimer,^{
        if (i>0) {
            [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%@(%@s)",NSLocalizedString(@"topscan_loading", @""),@(i)]];
        }
        i ++;
    });
    dispatch_resume(_sourceTimer);
}

- (void)top_destroyTimer {
    dispatch_source_cancel(_sourceTimer);
    _sourceTimer = nil;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
