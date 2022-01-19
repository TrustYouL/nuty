#define TopView_H 0
#define Bottom_H 60
#define SortView_H 60
#define AddFolder_W 310
#define AddFolder_H 240
#define AddFolderSingle_H 190
#define MoreView_H 45
#define MoreTopView_H 55
#define FolderViewTypeAdd @"FolderViewTypeAdd"
#define FolderViewTypeChange @"FolderViewTypeChange"
#define FolderViewTypeCurrentChange @"FolderViewTypeCurrentChange"

#import "TOPNextFolderViewController.h"
#import "TOPHomeChildViewController.h"
#import "TOPSearchFileViewController.h"
#import "TOPFileTargetListViewController.h"
#import "TOPPhotoShowTextAgainVC.h"
#import "TOPPhotoShowOCRVC.h"
#import "TOPShowLongImageViewController.h"
#import "TOPSCameraViewController.h"
#import "TOPSetTagViewController.h"
#import "TOPSingleBatchViewController.h"
#import "TOPSearchFileViewController.h"
#import "TOPCamerBatchViewController.h"
#import "TOPDocumentRemindVC.h"

#import "TOPDocumentCollectionView.h"
#import "TOPDocumentTableView.h"
#import "TOPHomeModel.h"
#import "TOPPhotoLongPressView.h"
#import "TOPWMDragView.h"
#import "TOPDocumentHeadReusableView.h"
#import "TOPShareTypeView.h"
#import "TOPShareDownSizeView.h"
#import "TOPDataModelHandler.h"
#import "TOPChildMoreView.h"
#import "TopScanner-Swift.h"
#import "TOPAddFolderView.h"
#import "TOPHomeShowView.h"
#import "TOPFolderVCTopView.h"
#import "TOPAPPFolder.h"
#import "TOPDBDataHandler.h"
#import "TOPHeadMenuModel.h"
#import "TOPLoadSelectDriveViewController.h"
#import "TOPShareFileView.h"
#import "TOPShareFileModel.h"
#import "TOPShareFileDataHandler.h"
#import "TOPSortTypeView.h"
#import "TOPBinHomeViewController.h"
#import "TOPNextCollectionView.h"

@interface TOPNextFolderViewController ()<UINavigationControllerDelegate,UISearchBarDelegate,MFMailComposeViewControllerDelegate,TZImagePickerControllerDelegate,UIDocumentPickerDelegate,UIPrintInteractionControllerDelegate,GADAdLoaderDelegate,GADNativeAdLoaderDelegate,GADVideoControllerDelegate,GADBannerViewDelegate,GADFullScreenContentDelegate>
@property (nonatomic, copy)NSString * addStr;
@property (nonatomic, strong) UILabel  *fileSizeLab;
@property (nonatomic, strong) UIView * contentFatherView;
@property (nonatomic, strong) TOPDocumentCollectionView *collectionView;
@property (nonatomic, strong) TOPNextCollectionView *nextCollView;
@property (nonatomic, strong) TOPDocumentTableView *tableView;
@property (nonatomic, strong) TOPAddFolderView * addFolderView;
@property (nonatomic, strong) TOPHomeShowView * topMoreView;
@property (nonatomic, strong) TOPDocPasswordView * passwordView;
@property (nonatomic, strong) TOPFolderVCTopView * topNavView;
@property (nonatomic, copy) NSString * folderViewType;
@property (nonatomic, strong) DocumentModel * subDocModel;
@property (nonatomic, strong) UIView * coverView;
@property (nonatomic, strong) UIView * sortCoverView;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) UIView * topLineView;
@property (nonatomic, strong) UIImageView * blankImg;
@property (nonatomic, strong) NSMutableArray  *homeDataArray;
@property (nonatomic, assign) int folderNum;
@property (nonatomic, assign) BOOL isNewFolder;
@property (nonatomic, assign) int documentNum;
@property (nonatomic, assign) BOOL isNewDocument;
@property (nonatomic, assign) BOOL isShowFailToast;
@property (nonatomic, strong) NSMutableArray *folderIndexArray;
@property (nonatomic, strong) NSMutableArray *documentIndexArray;
@property (nonatomic, strong) UIButton *allSelctBtn;
@property (nonatomic, strong) UIButton *showBtn;
@property (nonatomic, strong) TOPPhotoLongPressView *pressUpView;
@property (nonatomic, strong) TOPPhotoLongPressView *pressBootomView;
@property (nonatomic, strong) TOPSortTypeView *sortPopView;
@property (nonatomic, strong) TOPShareTypeView *shareAction;
@property (nonatomic, strong) TOPShareTypeView *sortPopView2;
@property (nonatomic, strong) TOPWMDragView *photoView;
@property (nonatomic, assign) NSInteger loadType;
@property (nonatomic, assign) BOOL enterInCamera;
@property (nonatomic, assign) NSInteger emailType;
@property (nonatomic, assign) NSInteger pdfType;
@property (nonatomic, copy) NSString * totalSizeString;
@property (nonatomic, assign) CGFloat  totalSizeNum;
@property (nonatomic, strong)TOPSettingEmailModel * emailModel;
@property (nonatomic, strong) NSMutableArray *docsIndexArray;
@property (strong, nonatomic) NSMutableArray *selectedDocsIndexArray;
@property (nonatomic, strong) NSMutableArray *homeMoreArray;
@property (nonatomic, strong) DocumentModel * nativeAdModel;
@property (nonatomic, strong) GADAdLoader *adLoader;
@property (nonatomic, strong) GADBannerView * scBannerView;
@property (nonatomic, strong) GADInterstitialAd *interstitial;
@property (nonatomic, strong) TOPShareFileView *shareFilePopView;
@property (nonatomic, assign) CGFloat adViewH;
@property (nonatomic, assign) BOOL isBanner;
@property (nonatomic, assign) BOOL hasCollection;

@end

@implementation TOPNextFolderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [TOPWHCFileManager top_fileNameAtPath:self.pathString suffix:YES];
    [TOPScanerShare shared].isEditing = NO;
    _loadType = [TOPScanerShare top_sortType];
    _emailType = 0;
    _enterInCamera = NO;
    self.isBanner = NO;
    self.adViewH = 0.0;
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    self.edgesForExtendedLayout =  UIRectEdgeBottom;
    
    NSString * documentStr = [TOPDocumentHelper top_appBoxDirectory];
    NSString * addStr = [[self.pathString componentsSeparatedByString:documentStr] lastObject];
    self.addStr = addStr;
    [self top_setUI];
    [self top_showTopNavView];
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self top_restoreBannerAD:size];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self top_setMyTopNavView:CGRectMake(0, 0, size.width, size.height)];
    self.navigationItem.titleView = self.topNavView;
    if (self.homeDataArray.count) {
        [self.collectionView reloadData];
    }
    if (_shareFilePopView) {
        [self.shareFilePopView top_updateSubViewsLayout];
    }
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
    if (![TOPPermissionManager top_enableByAdvertising]) {
        if (!self.isBanner) {
            [self nextView_AddBannerViewWithSize:size];
        }else{
            [self top_bannerViewSuccessViewFream];
        }
    }
}
- (void)top_setUI{
    UIView * lineView = [[UIView alloc]init];
    lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:[UIColor whiteColor]];
    self.topLineView = lineView;
    
    [self.view addSubview:self.contentFatherView];
    [self.view addSubview:lineView];
    [self.contentFatherView addSubview:self.collectionView];
    [self.contentFatherView addSubview:self.nextCollView];
    [self.contentFatherView addSubview:self.tableView];
    [self.contentFatherView addSubview:self.fileSizeLab];

    UIImageView * blankImg = [[UIImageView alloc]initWithFrame:CGRectMake((TOPScreenWidth-100)/2, (TOPScreenHeight-(266*100)/325-100)/2, 100, (266*100)/325)];
    blankImg.backgroundColor = [UIColor clearColor];
    blankImg.image = [UIImage imageNamed:@"top_blankView"];
    self.blankImg = blankImg;
    [self.view addSubview:blankImg];
    [lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.mas_equalTo(1.0);
    }];
    [self.contentFatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(self.contentFatherView);
    }];
    [self.nextCollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(self.contentFatherView);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(self.contentFatherView);
    }];
    [blankImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
//        make.size.mas_equalTo(CGSizeMake(100, (266*100)/325));
    }];
    [self.fileSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentFatherView);
        make.height.mas_equalTo(30);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(top_GetCamera) name:TOP_TRCenterBtnGetCamera object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(top_downloadFileDrivesSusess:) name:@"downDrives" object:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
    [self.navigationItem setHidesBackButton:YES];
    [[UINavigationBar appearance] setTranslucent:NO];
    [TOPFileDataManager shareInstance].docModel = self.docModel;
    if (![TOPScanerShare shared].isEditing) {
        [self top_LoadSanBoxData:_loadType];
    }
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self top_loadDocDataAndAD];
            });
        }];
    } else {
        [self top_loadDocDataAndAD];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([TOPScanerShare shared].isEditing) {
        [self top_ShowPressUpView];
        [self top_closePopGestureRecognizer];
    }else{
        [self top_openPopGestureRecognizer];
    }
}
#pragma mark -- 打开侧滑
- (void)top_openPopGestureRecognizer{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
#pragma mark -- 关闭侧滑
- (void)top_closePopGestureRecognizer{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)top_loadDocDataAndAD{
    if (![TOPPermissionManager top_enableByAdvertising]) {
        if (!self.interstitial) {
            [self top_getInterstitialAd];
        }
    }
    [self top_bannerViewFailViewFream];
    [self top_changeBannerViewFream:self.view.size];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if (![TOPScanerShare shared].isEditing) {
        self.nativeAdModel = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)top_showTopNavView {
    [self top_setMyTopNavView:CGRectMake(0, 0, TOPScreenWidth, TOPNavBarHeight)];
    self.navigationItem.titleView = self.topNavView;
}

- (void)top_setMyTopNavView:(CGRect)fream{
    WS(weakSelf);
    TOPFolderVCTopView * topNavView = [[TOPFolderVCTopView alloc]initWithFrame:fream];
    topNavView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
    topNavView.top_DocumentHeadClickHandler = ^(NSInteger index,BOOL selected) {
        NSLog(@"---- %ld",index);
        [weakSelf top_PresentPopViewWithType:index selected:selected];
    };
    topNavView.backgroundColor = [UIColor clearColor];
    topNavView.top_clickTap = ^{
        [weakSelf top_ClickToChangeCurrentFolderName];
    };
    self.topNavView = topNavView;
}
#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    if (self.addFolderView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            self.addFolderView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_W, AddFolder_W, AddFolder_W);
        }];
    }
    
    if (self.passwordView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            if (self.passwordView.actionType == TOPHomeMoreFunctionSetLockFirst||self.passwordView.actionType == TOPHomeMoreFunctionPDFPassword) {
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
        if (![self.passwordView.tField isFirstResponder]&&![self.passwordView.againField isFirstResponder]&&![self.addFolderView.tField  isFirstResponder]) {
            [self top_ClickToHide];
        }
    }
    if (_addFolderView) {
        if (![self.addFolderView.tField  isFirstResponder]) {
            [self top_ClickToHide];
        }
    }
}
#pragma mark -- 网盘批量下载成功通知

- (void)top_downloadFileDrivesSusess:(NSNotificationCenter *)notification
{
    [self top_LoadSanBoxData:_loadType];

}
- (void)top_ClickRightItems:(UIButton *)sender{
    [FIRAnalytics logEventWithName:@"top_ClickRightItems" parameters:@{@"tag":@(sender.tag)}];
    sender.selected = !sender.selected;
    if (sender.tag == 10) {
        NSLog(@"selectAll");
        [TOPScanerShare shared].isEditing = YES;
        [self top_ShowPressUpView];
        [self.pressBootomView top_changePressViewBtnState:TOPItemsSelectedNone];
        self.collectionView.listArray = self.homeDataArray;
        [self.collectionView reloadData];
        
        self.tableView.listArray = self.homeDataArray;
        [self.tableView reloadData];
       
        self.nextCollView.listArray = self.homeDataArray;
        [self.nextCollView reloadData];
    }else if (sender.tag == 11){
        NSLog(@"添加文件夹");
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        self.coverView.backgroundColor = RGBA(51, 51, 51, 0);
        [keyWindow addSubview:self.coverView];
        [keyWindow addSubview:self.addFolderView];
        [self top_markupCoverMask];
        NSString * componentFondersStr = self.addStr;
        NSString *filePath = [TOPDocumentHelper top_getBelongDocumentPathString:componentFondersStr];
        self.addFolderView.tagsName = [TOPDocumentHelper top_newDefaultFolderNameAtPath:filePath];
        self.addFolderView.picName = @"top_wenjianjia_icon";
        self.folderViewType = FolderViewTypeAdd;
    }
}

- (void)top_FolderAddAction:(NSString *)name{
    NSString * componentFondersStr = self.addStr;
    NSString *filePath = [TOPDocumentHelper top_getBelongDocumentPathString:componentFondersStr];
    if (name.length>0) {
        NSString * folderPathStr = [filePath  stringByAppendingPathComponent:name];
        NSString * isCreate =  [TOPDocumentHelper  top_createFolders:folderPathStr];
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
- (void)top_dealWithFolderPathToAddFolder:(NSString *)folderPath{
    [TOPEditDBDataHandler top_addFolderAtFile:folderPath WithParentId:self.docModel.docId];
    [self top_LoadSanBoxData:self.loadType];
}

- (void)top_FolderAlreadyAlert{
    [FIRAnalytics logEventWithName:@"top_FolderAlreadyAlert" parameters:nil];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_hasfolder", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)top_JudgeFolder{
    [FIRAnalytics logEventWithName:@"top_JudgeFolder" parameters:nil];
    [TOPDocumentHelper top_initializationFolder];
}
#pragma mark -- 修改当前文件夹的名称试图
- (void)top_ClickToChangeCurrentFolderName{
    [FIRAnalytics logEventWithName:@"top_ClickToChangeCurrentFolderName" parameters:nil];
    WS(weakSelf);
    TopEditFolderAndDocNameVC * editName = [TopEditFolderAndDocNameVC new];
    editName.top_clickToSendString = ^(NSString * _Nonnull nameString) {
        [weakSelf top_ClickToChangeCurrentFolderNameAction:nameString];
    };
    editName.defaultString = self.title;
    editName.editType = TopFileNameEditTypeChangeFolderName;
    editName.picName = @"top_changefolder";
    editName.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editName animated:YES];
}
#pragma mark -- 修改当前文件夹的名称事件
- (void)top_ClickToChangeCurrentFolderNameAction:(NSString *)name{
    if ([name isEqualToString:self.title]) {
        return;
    }
    
    for (DocumentModel * model in self.homeArray) {
        NSLog(@"name==%@",model.name);
        if ([model.name isEqualToString:name]) {
            if (![name isEqualToString:[[self.pathString componentsSeparatedByString:@"/"] lastObject]]) {
                [self top_FolderAlreadyAlert];
            }
            return;
        }
    }
    
    if (name.length == 0) {
        return;
    }
    self.pathString = [TOPDocumentHelper top_changeDocumentName:self.pathString folderText:name];
    [self.showBtn setTitle:name forState:UIControlStateNormal];
    self.title = name;
    NSString * documentStr = [TOPDocumentHelper top_appBoxDirectory];
    NSString * addStr = [[self.pathString componentsSeparatedByString:documentStr] objectAtIndex:1];
    self.addStr = addStr;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TOPEditDBDataHandler top_editFolderName:name withId:self.docModel.docId];
        TOPAPPFolder *appfld = [TOPDBQueryService top_appFolderById:self.docModel.docId];
        appfld.filePath = self.pathString;
        [TOPFileDataManager shareInstance].docModel.path = self.pathString;
        self.docModel.path = self.pathString;
        self.docModel.name = name;
        NSMutableArray *dataArray = [TOPDBDataHandler top_buildFolderSecondaryDataWithDB:appfld];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_onlyChangeDataArray:dataArray];
        });
    });
}
#pragma mark -- 选中文件夹名称的修改弹框
- (void)top_ClickToChangeSelectFolderName{
    [FIRAnalytics logEventWithName:@"top_ClickToChangeSelectFolderName" parameters:nil];
    WS(weakSelf);
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
    TopEditFolderAndDocNameVC * editName = [TopEditFolderAndDocNameVC new];
    editName.top_clickToSendString = ^(NSString * _Nonnull nameString) {
        [weakSelf top_ClickToChangeSelectFolderNameAction:nameString];
    };
    editName.defaultString = renameModel.name;
    editName.editType = editType;
    editName.picName = picName;
    editName.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editName animated:YES];
}
#pragma mark -- 选中文件夹名称的修改事件
- (void)top_ClickToChangeSelectFolderNameAction:(NSString *)name{
    DocumentModel * renameModel = [DocumentModel new];
    for (DocumentModel * tempModel in self.homeDataArray) {
        if (tempModel.selectStatus) {
            renameModel = tempModel;
        }
    }
    
    for (DocumentModel * model in self.homeDataArray) {
        if ([model.name isEqualToString:name]) {
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
    [self top_LoadSanBoxData:[TOPScanerShare top_sortType]];
}
#pragma mark --从沙盒里面获取数据
- (void)top_LoadSanBoxData:(NSInteger)type{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TOPAPPFolder *appfld = [TOPDBQueryService top_appFolderById:self.docModel.docId];
        appfld.filePath = self.pathString;
        NSMutableArray *dataArray = [TOPDBDataHandler top_buildFolderSecondaryDataWithDB:appfld];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_refreshUI:dataArray];
            if (dataArray.count) {
                [self top_restoreNativeAd];
            }
        });
    });
}
- (void)top_restoreNativeAd{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self top_determiNenativeAdState];
            });
        }];
    } else {
        [self top_determiNenativeAdState];
    }
}
- (void)top_determiNenativeAdState{
    if (![TOPPermissionManager top_enableByAdvertising]) {
        if (!self.nativeAdModel) {
            [self top_getNativeAd];
        }else{
            [self top_adReceiveFinishAndRefreshUI];
        }
    }
}
#pragma mark -- 添加数据源 刷新界面
- (void)top_refreshUI:(NSMutableArray *)dataArray{
    self.collectionView.showName = [TOPDocumentHelper top_getFolderShowName:self.pathString];
    self.collectionView.listArray = dataArray;
    self.tableView.showName = [TOPDocumentHelper top_getFolderShowName:self.pathString];
    self.tableView.listArray = dataArray;
    self.nextCollView.showName = [TOPDocumentHelper top_getFolderShowName:self.pathString];
    self.nextCollView.listArray = dataArray;
    self.topNavView.titleString = [TOPDocumentHelper top_getFolderShowName:self.pathString];
    self.homeDataArray = dataArray;
    [self.collectionView setShowType:[TOPScanerShare top_listType]];
    [self.tableView reloadData];
    [self.nextCollView reloadData];
    [self top_sumAllFileSize];

    if ([TOPScanerShare top_listType] == ShowListGoods) {
        self.tableView.hidden = NO;
        self.nextCollView.hidden = YES;
        self.topLineView.hidden = YES;
        self.collectionView.hidden = YES;
    }else if([TOPScanerShare top_listType] == ShowListNextGoods){
        self.tableView.hidden = YES;
        self.nextCollView.hidden = NO;
        self.topLineView.hidden = NO;
        self.collectionView.hidden = YES;
    }else{
        self.tableView.hidden = YES;
        self.nextCollView.hidden = YES;
        self.topLineView.hidden = YES;
        self.collectionView.hidden = NO;
    }
    
    if(self.homeDataArray.count == 0){
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
#pragma mark -- 改变数据源 界面做局部刷新
- (void)top_onlyChangeDataArray:(NSMutableArray *)dataArray{
    BOOL isChange = NO;
    if ([self removeAdModelArray].count != dataArray.count) {
        isChange = YES;
    }
    self.collectionView.showName = [TOPDocumentHelper top_getFolderShowName:self.pathString];
    self.tableView.showName = [TOPDocumentHelper top_getFolderShowName:self.pathString];
    self.nextCollView.showName = [TOPDocumentHelper top_getFolderShowName:self.pathString];
    self.topNavView.titleString = [TOPDocumentHelper top_getFolderShowName:self.pathString];
    self.homeDataArray = dataArray;
    if (dataArray.count) {
        if (![TOPPermissionManager top_enableByAdvertising]) {
            if (!self.nativeAdModel) {
                [self top_getNativeAd];
            }else{
                [self top_adReceiveFinishAndRefreshUI];
            }
        }
    }
    if (!isChange){
        [self.collectionView reloadData];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.nextCollView reloadData];
    }else{
        [self.collectionView reloadData];
        [self.tableView reloadData];
        [self.nextCollView reloadData];
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
- (TOPDocumentCollectionView *)collectionView{
    if (!_collectionView) {
        weakify(self);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
        _collectionView = [[TOPDocumentCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.isMoveState = NO;
        _collectionView.isShowHeaderView = NO;
        _collectionView.isFromSecondFolderVC = YES;
        _collectionView.top_DocumentHomeHandler = ^(NSInteger index,BOOL selected) {
            NSLog(@"---- %ld",index);
            [weakSelf top_PresentPopViewWithType:index selected:selected];
        };
        
        _collectionView.top_pushNextControllerHandler = ^(DocumentModel * model) {
            if ([model.type isEqualToString:@"0"]) {
                [weakSelf top_jumpToNextFolderVC:model];
            }else{
                weakSelf.subDocModel = model;
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
        
        _collectionView.top_longPressCalculateSelectedHander = ^{
            [weakSelf top_RefreshViewWithSelectItem];
        };
        
        _collectionView.top_clickToChangeName = ^{
            [weakSelf top_ClickToChangeCurrentFolderName];
        };
        
        _collectionView.top_scrollAndSendContentOffset = ^(CGFloat contentOffsetY) {
            [weakSelf top_getContentOffsetY:contentOffsetY];
        };
        _collectionView.top_didScrolInBottom = ^(BOOL isBottom) {
            weakSelf.fileSizeLab.hidden = !isBottom;
        };
        [_collectionView addGestureRecognizer];
    }
    return _collectionView;
}
- (TOPDocumentTableView *)tableView{
    if (!_tableView) {
        WS(weakSelf);
        _tableView = [[TOPDocumentTableView alloc]initWithFrame:CGRectMake(0, TOPNavBarAndStatusBarHeight+TopView_H, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight-TopView_H) style:UITableViewStylePlain];
        _tableView.isShowHeaderView = NO;
        _tableView.isFromSecondFolderVC = YES;
        _tableView.top_DocumentHomeHandler = ^(NSInteger index,BOOL selected) {
            NSLog(@"---- %ld",index);
            [weakSelf top_PresentPopViewWithType:index selected:selected];
        };
        
        _tableView.top_pushNextControllerHandler = ^(DocumentModel * model) {
            if ([model.type isEqualToString:@"0"]) {
                [weakSelf top_jumpToNextFolderVC:model];
            }else{
                weakSelf.subDocModel = model;
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
        _tableView.top_clickSideToShare = ^{
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
        
        _tableView.top_clickToChangeName = ^{
            [weakSelf top_ClickToChangeCurrentFolderName];
        };
        
        _tableView.top_scrollAndSendContentOffset = ^(CGFloat contentOffsetY) {
            [weakSelf top_getContentOffsetY:contentOffsetY];
        };
        _tableView.top_didScrolInBottom = ^(BOOL isBottom) {
            weakSelf.fileSizeLab.hidden = !isBottom;
        };
        [_tableView addGestureRecognizer];
    }
    return _tableView;
}
- (TOPNextCollectionView *)nextCollView{
    if (!_nextCollView) {
        weakify(self);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _nextCollView = [[TOPNextCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _nextCollView.isFromSecondFolderVC = YES;
        _nextCollView.top_DocumentHomeHandler = ^(NSInteger index,BOOL selected) {
            NSLog(@"---- %ld",index);
            [weakSelf top_PresentPopViewWithType:index selected:selected];
        };
        
        _nextCollView.top_pushNextControllerHandler = ^(DocumentModel * model) {
            if ([model.type isEqualToString:@"0"]) {
                [weakSelf top_jumpToNextFolderVC:model];
            }else{
                weakSelf.subDocModel = model;
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
        
        _nextCollView.top_clickToChangeName = ^{
            [weakSelf top_ClickToChangeCurrentFolderName];
        };
        
        _nextCollView.top_scrollAndSendContentOffset = ^(CGFloat contentOffsetY) {
            [weakSelf top_getContentOffsetY:contentOffsetY];
        };
        _nextCollView.top_didScrolInBottom = ^(BOOL isBottom) {
            weakSelf.fileSizeLab.hidden = !isBottom;
        };
        [_collectionView addGestureRecognizer];
    }
    return _nextCollView;
}
- (void)top_getContentOffsetY:(CGFloat)contentOffsetY{
    NSLog(@"contentOffsetY==%f",contentOffsetY);
    if (contentOffsetY>0) {
        [self.topNavView top_setupUITopHAgain];
        self.topNavView.titleString = [TOPDocumentHelper top_getFolderShowName:self.pathString];
    }else{
        [self.topNavView top_setupUITopHRestore];
    }
}

#pragma mark -- 跳转去次级界面
- (void)top_jumpToNextFolderVC:(DocumentModel *)model {
    TOPNextFolderViewController * nextFonderVC = [TOPNextFolderViewController new];
    nextFonderVC.docModel = model;
    nextFonderVC.pathString = model.path;
    nextFonderVC.homeArray = [self removeAdModelArray];
    [self.navigationController pushViewController:nextFonderVC animated:YES];
}

#pragma mark -- 点击doc时有无密码的判断
- (void)top_judgeClickDocPasswordState{
    NSString * passwordPath = self.subDocModel.docPasswordPath;
    if (passwordPath.length>0) {
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        [keyWindow addSubview:self.coverView];
        [keyWindow addSubview:self.passwordView];
        [self top_markupCoverMask];
        self.passwordView.actionType = TOPMenuItemsFunctionPushVC;
    }else{
        [self top_clickDocPushChildVCWithPath];
    }
}

#pragma mark -- 跳转到childVC
- (void)top_clickDocPushChildVCWithPath{
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    childVC.docModel = self.subDocModel;
    childVC.pathString = self.subDocModel.path;
    childVC.upperPathString = self.pathString;
    childVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:childVC animated:YES];
}

#pragma mark -- 根据选中的文件来刷新界面
- (void)top_RefreshViewWithSelectItem {
    [FIRAnalytics logEventWithName:@"top_RefreshViewWithSelectItem" parameters:nil];
    [TOPScanerShare shared].isEditing = YES;
    NSInteger docCount = 0;
    NSInteger folderCount = 0;
    TOPItemsSelectedState selectedState = TOPItemsSelectedNone;
    NSMutableArray *selectedArray = [NSMutableArray array];
    for (DocumentModel *model in self.homeDataArray) {
        if (model.selectStatus == YES) {
            [selectedArray addObject:model];
            if ([model.type isEqualToString:@"1"]) {
                docCount ++;
            }
            if ([model.type isEqualToString:@"0"]) {
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

- (NSArray *)top_HomeHeaderArray{
    NSArray * homeArray = @[@(TOPHomeHeaderFunctionMore),@(TOPHomeHeaderFunctionSelectState),@(TOPHomeHeaderFunctionViewType),@(TOPHomeHeaderFunctionCameraPicture),@(TOPHomeHeaderFunctionAddFolder),@(TOPHomeHeaderFunctionPop)];
    
    return homeArray;
}

- (NSArray *)top_viewTypeArray{
    NSArray * tempArray = [NSArray new];
    if (IS_IPAD) {
        tempArray = @[@(ShowListGoods),@(ShowThreeGoods)];
    }else{
        tempArray = @[@(ShowListGoods),@(ShowTwoGoods),@(ShowThreeGoods),@(ShowListNextGoods)];
    }
    return tempArray;
}

- (NSArray *)top_fileOrderTypeArray{
    NSArray * tempArray = @[@(FolderDocumentCreateDescending),@(FolderDocumentCreateAscending),@(FolderDocumentUpdateDescending),@(FolderDocumentUpdateAscending),@(FolderDocumentFileNameAToZ),@(FolderDocumentFileNameZToA)];
    return tempArray;
}

- (NSArray *)top_SendNameArray {
    NSArray * temp = @[NSLocalizedString(@"topscan_share", @""),NSLocalizedString(@"topscan_merge", @""),NSLocalizedString(@"topscan_copy", @""),NSLocalizedString(@"topscan_delete", @""),NSLocalizedString(@"topscan_more", @"")];
    return temp;
}

- (void)top_ShowPressUpView{
    [FIRAnalytics logEventWithName:@"top_ShowPressUpView" parameters:nil];
    [self top_closePopGestureRecognizer];
    weakify(self);
    SS(strongSelf);
    weakSelf.tabBarController.tabBar.hidden = YES;
    strongSelf.photoView.hidden = YES;
    [TOPScanerShare shared].isEditing = YES;
    [strongSelf top_HideHeaderView];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
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
        strongSelf.pressBootomView = [[TOPPhotoLongPressView alloc] initWithPressBottomFrame: CGRectMake(0, TOPScreenHeight, TOPScreenWidth, (Bottom_H)) sendPicArray:sendPicArray sendNameArray:sendNameArray];
        strongSelf.pressBootomView.selectedImgs = [strongSelf top_SendPicArray];
        strongSelf.pressBootomView.disableImgs = [strongSelf top_PicArray];
        strongSelf.pressBootomView.funcArray = [strongSelf top_FuncItems];
        strongSelf.pressBootomView.top_longPressBootomItemHandler = ^(NSInteger index) {
            __weak typeof(self) weakSelf = self;
            [weakSelf top_judgePasswordViewState:index];
            
        };
        [self.view addSubview:strongSelf.pressBootomView];
        
        UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, TOPScreenWidth, TOPBottomSafeHeight)];
        bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.bottomView = bottomView;
        [self.view addSubview:bottomView];
        if (!self.isBanner) {
            [strongSelf.pressBootomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
                make.height.mas_equalTo(Bottom_H);
            }];
        }else{
            [strongSelf.pressBootomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
                make.height.mas_equalTo(Bottom_H);
            }];
        }
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
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
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
}

- (void)top_CancleSelectResetFream{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
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
    }
    
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
                [keyWindow addSubview:self.passwordView];
                [self top_markupCoverMask];
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
#pragma mark -- 取消选择
- (void)top_CancleSelectAction {
    [FIRAnalytics logEventWithName:@"top_CancleSelectAction" parameters:nil];
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
    self.photoView.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    
    [TOPScanerShare shared].isEditing = NO;
    [self top_ShowHeaderView];
    [self.selectedDocsIndexArray removeAllObjects];
    for (DocumentModel *model in self.homeDataArray) {
        model.selectStatus = NO;
    }
    self.collectionView.listArray = self.homeDataArray;
    [self.collectionView reloadData];
    
    self.tableView.listArray = self.homeDataArray;
    [self.tableView reloadData];
   
    self.nextCollView.listArray = self.homeDataArray;
    [self.nextCollView reloadData];
    [self top_openPopGestureRecognizer];
}

#pragma mark -- 全选
- (void)top_AllSelectAction:(BOOL)selected {
    [FIRAnalytics logEventWithName:@"top_AllSelectAction" parameters:nil];
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

#pragma mark -- 调用底部菜单事件
- (void)top_InvokeMenuFunctionAtIndex:(NSInteger)index {
    [FIRAnalytics logEventWithName:@"top_InvokeMenuFunctionAtIndex" parameters:@{@"index":@(index)}];
    NSArray *funcIndexArray = [self top_FuncItems];
    NSNumber *funcNum = funcIndexArray[index];
    switch ([funcNum integerValue]) {
        case TOPMenuItemsFunctionShare:
            self.emailType = 0;
            [self top_ShareTip];
            break;
        case TOPMenuItemsFunctionMerge:
            [self top_MergeFileMethod];;
            break;
        case TOPMenuItemsFunctionCopyMove:
            [self top_EditFileMethod];
            break;
        case TOPMenuItemsFunctionDelete:
            [self top_DeleteTip];
            break;
        case TOPMenuItemsFunctionMore:
            [self top_EditMoreMethod];
            break;
        case TOPMenuItemsFunctionRename:
            [self top_ClickToChangeSelectFolderName];
        default:
            break;
    }
}

#pragma mark -- doc密码的视图的点击事件
- (void)top_passwordViewActionWithPassword:(NSString *)password WithType:(NSInteger)actionType{
    switch (actionType) {
        case TOPHomeMoreFunctionSetLockFirst:
            [self top_ClickToHide];
            [self top_WritePasswordToDoc:password];
            break;
        case TOPHomeMoreFunctionSetLock:
            [self top_SetLockagain:password];
            break;
        case TOPHomeMoreFunctionPDFPassword:
            [self top_ClickToHide];
            [self top_CancleSelectAction];
            [self top_setPdfPassword:password];
            break;
        case TOPMenuItemsFunctionShare:
            [self top_SetLockShare:password];
            break;
        case TOPMenuItemsFunctionMerge:
            [self top_SetLockMerge:password];
            break;
        case TOPMenuItemsFunctionCopyMove:
            [self top_SetLockMove:password];
            break;
        case TOPMenuItemsFunctionDelete:
            [self top_SetLockDelete:password];
            break;
        case TOPMenuItemsFunctionMore:
            [self top_SetLockMore:password];
            break;
        case TOPMenuItemsFunctionRename:
            [self top_SetLockRename:password];
            break;
        case TOPMenuItemsFunctionPushVC:
            [self top_SetLockPushChildVC:password];
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
- (void)top_SetLockagain:(NSString *)password{
    [FIRAnalytics logEventWithName:@"top_SetLockagain" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickToHide];
        [self top_WritePasswordToDoc:password];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的分享
- (void)top_SetLockShare:(NSString *)password{
    [FIRAnalytics logEventWithName:@"top_SetLockShare" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickToHide];
        [self top_ShareTip];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的合并
- (void)top_SetLockMerge:(NSString *)password{
    [FIRAnalytics logEventWithName:@"top_SetLockMerge" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickToHide];
        [self top_MergeFileMethod];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的移动
- (void)top_SetLockMove:(NSString *)password{
    [FIRAnalytics logEventWithName:@"top_SetLockMove" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickToHide];
        [self top_EditFileMethod];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的删除
- (void)top_SetLockDelete:(NSString *)password{
    [FIRAnalytics logEventWithName:@"top_SetLockDelete" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickToHide];
        [self top_DeleteTip];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的更多
- (void)top_SetLockMore:(NSString *)password{
    [FIRAnalytics logEventWithName:@"top_SetLockMore" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickToHide];
        [self top_EditMoreMethod];
    }else{
        [self top_writePasswordFail];
    }
}

#pragma mark -- 有密码时的重命名
- (void)top_SetLockRename:(NSString *)password{
    [FIRAnalytics logEventWithName:@"top_SetLockRename" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickToHide];
        [self top_ClickToChangeSelectFolderName];
    }else{
        [self top_writePasswordFail];
    }
}

#pragma mark -- 有密码时的界面跳转
- (void)top_SetLockPushChildVC:(NSString *)password{
    [FIRAnalytics logEventWithName:@"top_SetLockPushChildVC" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickToHide];
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
                titleArray = @[NSLocalizedString(@"topscan_docpasswordunlockicon", @""),
                               NSLocalizedString(@"topscan_email", @""),
                               NSLocalizedString(@"topscan_ocr", @""),
                               NSLocalizedString(@"topscan_childimportant", @""),
                               NSLocalizedString(@"topscan_savetogallery", @"")];
                iconArray = @[@"top_unlock",@"top_homemail",@"top_childvc_moreOCR",collectionIcon,@"top_childvc_morepic"];
                moreArray = @[@(TOPHomeMoreFunctionUnLock),@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionDocCollection),@(TOPHomeMoreFunctionSaveToGrallery)];
            }else if(moreType == TOPHomeMoreFunctionTypeSomeDocSetLock){
                titleArray = @[NSLocalizedString(@"topscan_docpasswordicon", @""),
                               NSLocalizedString(@"topscan_email", @""),
                               NSLocalizedString(@"topscan_ocr", @""),
                               NSLocalizedString(@"topscan_childimportant", @""),
                               NSLocalizedString(@"topscan_savetogallery", @"")];
                iconArray = @[@"top_lock",@"top_homemail",@"top_childvc_moreOCR",collectionIcon,@"top_childvc_morepic"];
                moreArray = @[@(TOPHomeMoreFunctionSetLock),@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionDocCollection),@(TOPHomeMoreFunctionSaveToGrallery)];
            }else if(moreType == TOPHomeMoreFunctionTypeOneDocUnLock){
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
- (void)top_ClickMoreViewAction:(TOPHomeMoreFunction)functionType{
    [FIRAnalytics logEventWithName:@"nextFloder_ClickMoreViewAction" parameters:nil];
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
            [self top_SetLock];
            break;
        case TOPHomeMoreFunctionUnLock:
            [self top_DocUnlock];
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
    remindVC.upperPathString = self.pathString;
    remindVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:remindVC animated:YES];
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
- (void)top_uploadDrive{
    [FIRAnalytics logEventWithName:@"nextFolderuploadDrive" parameters:nil];
    if (![TOPDocumentHelper top_getSelectFolderDocPicState:self.homeDataArray]) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
        return;
    }
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
#pragma mark -- uploadDrive 下载第三方网盘
- (void)top_downDriveFile{
    [FIRAnalytics logEventWithName:@"nextFolderDownloadDrive" parameters:nil];
    TOPLoadSelectDriveViewController *uploadVC = [[TOPLoadSelectDriveViewController alloc] init];
    uploadVC.openDrivetype = TOPDriveOpenStyleTypeDownFile;
    uploadVC.downloadFileSavePath = self.docModel.path;
    uploadVC.docId = self.docModel.docId;
    uploadVC.downloadFileType = TOPDownloadFileToDriveAddPathTypeNextFolder;

    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:uploadVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
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
                [self top_changeUpDownShowViewState];
                TOPCollageViewController *collageVC = [[TOPCollageViewController alloc] init];
                collageVC.filePath = printModel.path;
                collageVC.docModel = printModel;
                collageVC.top_backBtnAction = ^{
                };
                collageVC.top_finishBtnAction = ^{
                    if ([TOPScanerShare shared].isEditing) {
                        [weakSelf top_CancleSelectAction];
                        [weakSelf top_LoadSanBoxData:self->_loadType];
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
    if (![TOPPermissionManager top_enableByPDFPassword]) {
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
    [FIRAnalytics logEventWithName:@"top_FaxTip" parameters:nil];
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
        
        NSLog(@"editArray==%@",editArray);
        [TOPDocumentHelper top_creatPDF:editArray documentName:pdfName pageSizeType:[TOPScanerShare top_pageSizeType] success:^(id  _Nonnull responseObj) {
            NSString * pdfPathString = responseObj;
            [TOPDocumentHelper top_jumpToSimpleFax:pdfPathString];
        }];
    });
}
#pragma mark --设置标签的点击事件
- (void)top_SetTag{
    NSMutableArray * selectDocArray = [NSMutableArray new];
    [selectDocArray addObjectsFromArray:self.selectedDocsIndexArray];
    TOPSetTagViewController * tagVC = [[TOPSetTagViewController alloc]init];
    tagVC.dataArray = selectDocArray;
    tagVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tagVC animated:YES];
    [self top_CancleSelectAction];
}

#pragma mark --设置密码的点击事件
- (void)top_SetLock{
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
            [keyWindow addSubview:self.passwordView];
            [self top_markupCoverMask];
        });
    });
}

#pragma mark -- 写入密码
- (void)top_WritePasswordToDoc:(NSString *)password{
    [FIRAnalytics logEventWithName:@"top_WritePasswordToDoc" parameters:nil];
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

#pragma mark -- 清除doc文档密码
- (void)top_DocUnlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (DocumentModel * selecModel in self.selectedDocsIndexArray) {
            if (selecModel.docPasswordPath.length>0) {
                [TOPWHCFileManager top_removeItemAtPath:selecModel.docPasswordPath];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_CancleSelectAction];
            [self top_LoadSanBoxData:self.loadType];
        });
    });
}

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
        }else{
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

#pragma mark -- 文件编辑方式选择
- (void)top_EditFileMethod {
    [FIRAnalytics logEventWithName:@"top_EditFileMethod" parameters:nil];
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

#pragma mark -- 选择移动的终点文件夹
- (void)top_MoveToFileSelect {
    __weak typeof(self) weakSelf = self;
    TOPFileTargetListViewController *targetListVC = [[TOPFileTargetListViewController alloc] init];
    targetListVC.currentFilePath = self.pathString;
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
        [FIRAnalytics logEventWithName:@"top_MoveToFileAtPath" parameters:@{@"path":path}];
        NSMutableArray *selectFiles = [self selectFileArray];
        NSString *showTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(1-%@)",@(selectFiles.count)] : @"";
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_moveprocessing", @""),showTitle]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *paths = @[].mutableCopy;
            for (int i = 0; i < selectFiles.count; i ++) {
                @autoreleasepool {
                    DocumentModel *model = selectFiles[i];
                    NSString * targetPath = [TOPDocumentHelper top_createNewDocument:model.name atFolderPath:path];
                    NSString *progressTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(%@-%@)",@(i +1),@(selectFiles.count)] : @"";
                    [TOPDocumentHelper top_moveFileItemsAtPath:model.path toNewFileAtPath:targetPath progress:^(CGFloat moveProgressValue) {
                        [[TOPProgressStripeView shareInstance] top_showProgress:moveProgressValue withStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_moveprocessing", @""),progressTitle]];
                    }];
                    [paths addObject:targetPath];
                }
            }
            for (int i = 0; i < selectFiles.count; i ++) {
                DocumentModel *model = selectFiles[i];
                NSString *targetPath = paths[i];
                NSString *docName = [TOPWHCFileManager top_fileNameAtPath:targetPath suffix:YES];
                [TOPEditDBDataHandler top_editDocumentPath:docName withParentId:[TOPFileDataManager shareInstance].fileModel.docId withId:model.docId];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];

                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_movesuccess", @"")];
                [SVProgressHUD dismissWithDelay:1.0];
                [self top_CancleSelectAction];
                [self top_LoadSanBoxData:self.loadType];
            });
        });
    }
}

#pragma mark -- 选择拷贝的终点文件夹
- (void)top_CopyFileSelect {
    [FIRAnalytics logEventWithName:@"top_CopyFileSelect" parameters:nil];
    WS(weakSelf);
    TOPFileTargetListViewController *targetListVC = [[TOPFileTargetListViewController alloc] init];
    targetListVC.currentFilePath = self.pathString;
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
        [FIRAnalytics logEventWithName:@"top_CopyFileAtPath" parameters:@{@"path":path}];
        NSMutableArray *selectFiles = [self selectFileArray];
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
                [self top_CancleSelectAction];

                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_copysuccess", @"")];
                [SVProgressHUD dismissWithDelay:1.0];
                [self top_LoadSanBoxData:self.loadType];
            });
        });
    }
}

#pragma mark -- 选中的文件
- (NSMutableArray *)selectFileArray {
    NSMutableArray *selectTempArray = [@[] mutableCopy];
    selectTempArray = [self.selectedDocsIndexArray mutableCopy];
    return selectTempArray;
}

#pragma mark -- 合并方式选择
- (void)top_MergeFileMethod {
    [FIRAnalytics logEventWithName:@"top_MergeFileMethod" parameters:nil];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_mergefilemethodtitle", @"") message:nil preferredStyle: IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_mergefilemethodkeepold", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_MergeAndKeepOldFile];
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_mergefilemethoddeleteold", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_MergeAndDeleteOldFile];
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

#pragma mark -- 合并且保留原文件 等同于拷贝文件
- (void)top_MergeAndKeepOldFile {
    [FIRAnalytics logEventWithName:@"top_MergeAndKeepOldFile" parameters:nil];
    NSMutableArray *selectFiles = [self selectFileArray];
    NSString *showTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(1-%@)",@(selectFiles.count)] : @"";
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_mergeing", @""),showTitle]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *mergerFilePath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:self.pathString];
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
        TOPAppDocument *appDoc = [TOPEditDBDataHandler top_addDocumentAtFolder:mergerFilePath WithParentId:self.docModel.docId];
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

#pragma mark -- 合并且删除原文件 等同于移动文件
- (void)top_MergeAndDeleteOldFile {
    [FIRAnalytics logEventWithName:@"top_MergeAndDeleteOldFile" parameters:nil];
    NSMutableArray *selectFiles = [self selectFileArray];
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
            @autoreleasepool {
                if (!i) {
                    continue;
                }
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
        [FIRAnalytics logEventWithName:@"top_JumpToHomeChildVC" parameters:@{@"toPath":path}];
        TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
        childVC.docModel = [TOPFileDataManager shareInstance].docModel;
        childVC.pathString = path;
        childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
        childVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:childVC animated:YES];
    }
}

#pragma mark -- 删除文档
- (void)top_DeleteTip{
    [FIRAnalytics logEventWithName:@"top_DeleteTip" parameters:nil];
    
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

#pragma mark -- 删除操作
- (void)top_deleteHandle {
    if (self.selectedDocsIndexArray.count > 5) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:NSLocalizedString(@"topscan_removeing", @"")];
    } else {
        [SVProgressHUD show];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *editArray = [NSMutableArray array];
        int i = 0;
        for (DocumentModel *model in  self.homeDataArray) {
            if (!model.isAd) {
                if (!model.selectStatus) {
                    [editArray addObject:model];
                }else{
                    if ([model.type isEqualToString:@"0"]) {
                        [self top_deleteFolderToBin:model];
                    } else {
                        [self top_deleteDocumentToBin:model];
                    }
                    i ++;
                    CGFloat moveProgressValue = i / (self.selectedDocsIndexArray.count * 1.0);
                    [[TOPProgressStripeView shareInstance] top_showProgress:moveProgressValue withStatus:NSLocalizedString(@"topscan_removeing", @"")];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [SVProgressHUD dismiss];
            NSArray * picArray = @[@"top_downview_disableshare",@"top_dissmissEmail",@"top_downview_dissmissSave",@"top_dissmissPrinting",@"top_downview_disabledelete"];
            [self.pressBootomView top_changePressViewBtnStatue:picArray enabled:NO];
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

#pragma mark --- 回收站
- (void)top_RecycleBin {
    TOPBinHomeViewController *binHome = [[TOPBinHomeViewController alloc] init];
    binHome.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:binHome animated:YES];
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
                    if (weakSelf.emailType == 1) {
                        [weakSelf top_EmailTip:shareArray];
                    }else{
                        [weakSelf top_presentActivityVC:shareArray];
                    }
                });
            });
        } else if(cellModel.fileType == TOPShareFileLongJPG) {
            [FIRAnalytics logEventWithName:@"top_ShareLongImage" parameters:nil];
            [weakSelf top_drawLongImagePreview];
        } else {
            [FIRAnalytics logEventWithName:@"top_shareText" parameters:nil];
            [weakSelf top_shareText];
            [weakSelf top_CancleSelectAction];
        }
    }
}

- (void)top_ShareTip{
    [FIRAnalytics logEventWithName:@"top_ShareTip" parameters:nil];
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
    for (DocumentModel * model in [self selectFileArray]) {
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
    } else {
        [self top_drawLongImagePreview];
    }
}

#pragma mark -- 合成长图并预览
- (void)top_drawLongImagePreview {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *imgArray = [TOPDataModelHandler top_selectedImageArray:[self selectFileArray]];
        UIImage * resultImg = [TOPPictureProcessTool top_mergedImages:imgArray];
        NSString *showPath = [TOPDocumentHelper top_longImageFileString];
        [TOPDocumentHelper top_saveImage:resultImg atPath:showPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self top_CancleSelectAction];
            TOPShowLongImageViewController * longImgVC = [TOPShowLongImageViewController new];
            longImgVC.showPath = showPath;
            longImgVC.pathString = [TOPDocumentHelper top_getFoldersPathString];
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

#pragma 计算选中文件的大小
- (void)top_CalculateSelectNumber{
    CGFloat memorySize = [TOPDocumentHelper top_calculateSelectFilesSize:self.homeDataArray];
    self.totalSizeNum = memorySize;
    NSString * totalSize = [TOPDocumentHelper top_memorySizeStr:memorySize];
    self.totalSizeString = totalSize;
}

- (void)top_EmailTip:(NSArray * )emailArray{
    if (emailArray.count) {
        [FIRAnalytics logEventWithName:@"top_EmailTip" parameters:@{@"emailArray":emailArray}];
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
    if (emailArray.count>0) {
        if (self.pdfType == 1) {
            for (int i = 0; i<emailArray.count; i++) {
                NSData * imgData = UIImageJPEGRepresentation(emailArray[i], TOP_TRPicScale);
                NSURL * imgPath = emailArray[i];
                NSString * photoName = [TOPDocumentHelper top_decodeFromPercentEscapeString:[imgPath.absoluteString componentsSeparatedByString:@"/"].lastObject];
                [mailCompose addAttachmentData:imgData mimeType:@"image" fileName:photoName];
            }
            [self presentViewController:mailCompose animated:YES completion:^{
                
            }];
        }
        
        if (self.pdfType == 0) {
            for (int i = 0; i<emailArray.count; i++) {
                NSData * pdfData = [NSData dataWithContentsOfURL:emailArray[i]];
                NSURL * pdfPath = emailArray[i];
                NSString * photoName = [TOPDocumentHelper top_decodeFromPercentEscapeString:[pdfPath.absoluteString componentsSeparatedByString:@"/"].lastObject];
                [mailCompose addAttachmentData:pdfData mimeType:@"application/pdf" fileName:photoName];
            }
            [self presentViewController:mailCompose animated:YES completion:^{
                
            }];
        }
    }
}

- (void)top_ClickToHide{
    [UIView animateWithDuration:0.3 animations:^{
        [self.addFolderView removeFromSuperview];
        [self.coverView removeFromSuperview];
        [self.passwordView removeFromSuperview];
        [self.topMoreView removeFromSuperview];
        
        self.addFolderView = nil;
        self.coverView = nil;
        self.passwordView = nil;
        self.topMoreView = nil;
    }];
}

- (void)top_ClickMoreRenameToHide{
    [UIView animateWithDuration:0.3 animations:^{
        [self.coverView removeFromSuperview];
        [self.topMoreView removeFromSuperview];
        
        self.coverView = nil;
        self.topMoreView = nil;
    }];
}
- (void)top_SaveToGalleryTip{
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
#pragma mark -- 更多视图的功能
- (void)top_HomeHeaderMoreAction:(NSInteger)row{
    NSNumber * rowNum = self.homeMoreArray[row];
    switch ([rowNum integerValue]) {
        case TOPHomeMoreFunctionShareAppURL:
            [self top_ClickToHide];
            [self top_ShareAppURL];
            break;
        case TOPHomeMoreFunctionFolderLocation:
            [self top_ClickToHide];
            [self top_ImportDoc];
            break;
        case TOPHomeMoreFunctionSortBy:
            [self top_ClickToHide];
            [self top_HomeHeaderSortBy];
            break;
        case TOPHomeMoreFunctionDownDriveFile:
            [self top_ClickToHide];
            [self top_downDriveFile];
            break;
        case TOPHomeMoreFunctionEnterTagsManager:
            [self top_ClickToHide];
            [self top_ImportPic];
            break;
        case TOPHomeMoreFunctionFolderRename:
            [self top_ClickMoreRenameToHide];
            [self top_ClickToChangeCurrentFolderName];
            break;
        case TOPHomeMoreFunctionSearch:
            [self top_ClickToHide];
            [self top_Search];
            break;
        case TOPHomeMoreFunctionDataRefresh:
            [self top_ClickToHide];
            [self top_dataSyncAgain];
            break;
        default:
            break;
    }
}
#pragma mark -- 手动自检
- (void)top_dataSyncAgain{
    BOOL hasData = [[NSUserDefaults standardUserDefaults] boolForKey:@"RealmDataKey"];
    if (hasData) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:NSLocalizedString(@"topscan_showprocess", @"")];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [TOPDBDataHandler top_synchronizeDBDataWithFolder:self.docModel.docId progress:^(CGFloat value) {
                [[TOPProgressStripeView shareInstance] top_showProgress:value withStatus:NSLocalizedString(@"topscan_showprocess", @"")];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
            });
        });
    }
}
#pragma mark -- 搜索
- (void)top_Search{
    TOPSearchFileViewController * searchVC = [TOPSearchFileViewController new];
    searchVC.hidesBottomBarWhenPushed = YES;
    searchVC.fatherDocModel = self.docModel;
    searchVC.pathString = self.pathString;
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark -- 分享app地址
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
#pragma mark -- 导入图片
- (void)top_ImportPic{
    [FIRAnalytics logEventWithName:@"homeView_ImportPic" parameters:nil];
    NSArray *documentTypes = @[ @"public.image"];
    [self top_getIcouldView:documentTypes];
}
#pragma mark -- 导入pdf
- (void)top_ImportDoc{
    [FIRAnalytics logEventWithName:@"homeView_ImportDoc" parameters:nil];
    NSArray *documentTypes = @[ @"public.image",@"com.adobe.pdf"];
    [self top_getIcouldView:documentTypes];
}
- (void)top_getIcouldView:(NSArray *)typeArray{
    [[UINavigationBar appearance] setTranslucent:YES];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc]initWithDocumentTypes:typeArray inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle =  UIModalPresentationFullScreen;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark -- UIDocumentPickerDelegate
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
                        NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:self.pathString];
                        [weakSelf top_writeImageDataToDocument:photo withIndex:0 withPath:endPath];
                        [weakSelf top_icloudFinishAndPushWithPath:endPath];
                    }
                }
            }
        }];
    }
}
- (void)top_dealWithPDF:(CGPDFDocumentRef)fromPDFDoc withPath:(NSURL *)newURL alertTitle:(NSString *)title alertMessage:(NSString *)message fileName:(NSString *)fileName{
    if (CGPDFDocumentIsEncrypted (fromPDFDoc)) {//判断pdf是否加密
        WS(weakSelf);
        if (!CGPDFDocumentUnlockWithPassword (fromPDFDoc, "")) {//判断密码是否为""
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
        NSString *filePath = [self.pathString stringByAppendingPathComponent:fileName];
        endPath = [TOPDocumentHelper top_createDirectoryAtPath:filePath];
    }else{
        endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:self.pathString];
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
    TOPAppDocument *doc = [TOPEditDBDataHandler top_addDocumentAtFolder:endPath WithParentId:self.docModel.docId];
    DocumentModel *model = [TOPDBDataHandler top_buildDocumentModelWithData:doc];
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    childVC.docModel = model;
    childVC.pathString = endPath;
    childVC.upperPathString = self.pathString;
    childVC.hidesBottomBarWhenPushed = YES;
    childVC.addType = @"add";
    childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
    [self.navigationController pushViewController:childVC animated:YES];
}
#pragma mark -- 排序
- (void)top_HomeHeaderSortBy{
    [FIRAnalytics logEventWithName:@"top_HomeHeaderSortBy" parameters:nil];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    WS(weakSelf);
    NSArray *titleArray = @[NSLocalizedString(@"topscan_creatdataascend", @""),NSLocalizedString(@"topscan_creatdatadescend", @""),NSLocalizedString(@"topscan_updatedataascend", @""),NSLocalizedString(@"topscan_updatedatadescend", @""),NSLocalizedString(@"topscan_filenameatoz", @""), NSLocalizedString(@"topscan_filenameztoa", @"")];
    NSArray *picArray = @[@"top_docCreatDe",@"top_docCreatAs",@"top_docUpdateDe",@"top_docUpdateAs",@"top_docAZ",@"top_docZA"];
    NSArray *selectArray = @[@"top_docCreatSelectDe",@"top_docCreatSelectAs",@"top_docUpdateSelectDe",@"top_docUpdateSelectAs",@"top_docSelectAZ",@"top_docSelectZA"];
    TOPShareTypeView * sortPopView2 = [[TOPShareTypeView alloc]initWithTitleView:[UIView new] titleArray:titleArray picArray:picArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
        
    } selectBlock:^(NSInteger row, NSString * _Nonnull totalSize) {
        NSArray * tempArray = [weakSelf top_fileOrderTypeArray];
        [TOPScanerShare top_writSortType:[tempArray[row] integerValue]];
        weakSelf.loadType = [tempArray[row] integerValue];
        [weakSelf top_LoadSanBoxData:weakSelf.loadType];
    }];
    sortPopView2.selectArray = selectArray;
    sortPopView2.popType = TOPPopUpBounceViewTypeSort;
    [window addSubview:sortPopView2];
    [sortPopView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(window);
    }];
}
#pragma mark ---更多
- (void)top_HomeHeaderMore{
    [FIRAnalytics logEventWithName:@"top_HomeHeaderMore" parameters:nil];
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.coverView];
    [self top_markupCoverMask];
    self.coverView.backgroundColor = [UIColor clearColor];
    self.coverView.userInteractionEnabled = YES;
    [keyWindow addSubview:self.topMoreView];
    
    NSArray * dataArray = @[NSLocalizedString(@"topscan_datarefresh", @""),NSLocalizedString(@"topscan_sortby", @""),NSLocalizedString(@"topscan_importimage", @""),NSLocalizedString(@"topscan_importfile", @""),NSLocalizedString(@"topscan_siderename", @""),NSLocalizedString(@"topscan_shareapp", @""),NSLocalizedString(@"topscan_drivedownloadfiles", @""),NSLocalizedString(@"topscan_search", @"")];
    NSArray * iconArray = @[@"top_dataRefresh",@"top_blackSortBy",@"top_icloudimportimage",@"top_icloudimportfile",@"top_folderRename",@"top_shareApp",@"top_home_downloadfile_list",@"top_icloudsearch"];
    [self.topMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(keyWindow).offset(-10);
        make.top.equalTo(keyWindow).offset(TOPNavBarAndStatusBarHeight+15);
        make.width.mas_equalTo(210);
        make.height.mas_equalTo(dataArray.count*MoreView_H);
    }];
    self.topMoreView.showType = TOPHomeShowViewLocationTypeTopRight;
    self.topMoreView.dataArray = dataArray;
    self.topMoreView.iconArray = iconArray;
    
    [self.homeMoreArray removeAllObjects];
    NSArray * moreArray = @[@(TOPHomeMoreFunctionDataRefresh),@(TOPHomeMoreFunctionSortBy),@(TOPHomeMoreFunctionEnterTagsManager),@(TOPHomeMoreFunctionFolderLocation),@(TOPHomeMoreFunctionFolderRename),@(TOPHomeMoreFunctionShareAppURL),@(TOPHomeMoreFunctionDownDriveFile),@(TOPHomeMoreFunctionSearch)];
    [self.homeMoreArray addObjectsFromArray:moreArray];
}

- (void)top_PresentPopViewWithType:(NSInteger)type selected:(BOOL)selected{
    [FIRAnalytics logEventWithName:@"top_PresentPopViewWithType" parameters:@{@"type":@(type)}];
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
            /*
            if (self.sortPopView) {
                [self top_sortTap];
            }else{
                [self top_HomeHeaderViewType];
            }*/
            [self top_NextFolderHeaderNewViewType];
            break;
        case TOPHomeHeaderFunctionSelectState:
//            [self top_sortTap];
            [self top_HomeHeaderSelectState];
            break;
        case TOPHomeHeaderFunctionMore:
//            [self top_sortTap];
            [self top_HomeHeaderMore];
            break;
        case TOPHomeHeaderFunctionPop:
//            [self top_sortTap];
            [self top_BackNextAction];
        default:
            break;
    }
}
#pragma mark --头部视图事件
#pragma mark ---视图显示的样式
- (void)top_NextFolderHeaderNewViewType{
    if ([TOPScanerShare top_listType] == ShowThreeGoods) {//3个格子
        [TOPScanerShare top_writeListType:ShowListNextGoods];
        [FIRAnalytics logEventWithName:@"homeView_HeaderViewTypeListSed" parameters:nil];
        self.tableView.hidden = YES;
        self.collectionView.hidden = YES;
        self.nextCollView.hidden = NO;
        self.topLineView.hidden = NO;
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
            self.topLineView.hidden = YES;
            self.collectionView.hidden = NO;
        }
    }
    
    [self.topNavView top_refreshViewTypeBtn];
}
#pragma mark -- 添加文件夹
- (void)top_HomeHeaderAddFolderView{
    if ([TOPPermissionManager top_enableByCreateFolder]) {
        WS(weakSelf);
        NSString * componentFondersStr = self.addStr;
        NSString *filePath = [TOPDocumentHelper top_getBelongDocumentPathString:componentFondersStr];
        TopEditFolderAndDocNameVC * editVC = [TopEditFolderAndDocNameVC new];
        editVC.top_clickToSendString = ^(NSString * _Nonnull nameString) {
            [weakSelf top_FolderAddAction:nameString];
        };
        editVC.defaultString = [TOPDocumentHelper top_newDefaultFolderNameAtPath:filePath];
        editVC.picName = @"top_changefolder";
        editVC.editing = TopFileNameEditTypeAddFolder;
        editVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editVC animated:YES];
    } else {//会员才能加文件夹
        [self top_subscriptionService];
    }
}
#pragma mark -- 选中状态
- (void)top_HomeHeaderSelectState{
    NSLog(@"selectAll");
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
/*
#pragma mark --排列样式
- (void)top_HomeHeaderViewType{
    [FIRAnalytics logEventWithName:@"top_HomeHeaderViewType" parameters:nil];
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
                weakSelf.nextCollView.hidden = YES;
                weakSelf.topLineView.hidden = YES;
                weakSelf.collectionView.hidden = YES;
                weakSelf.tableView.hidden = NO;
                weakSelf.tableView.listArray = weakSelf.homeDataArray;
                [weakSelf.tableView reloadData];
            }else if([TOPScanerShare top_listType] == ShowListNextGoods){
                weakSelf.tableView.hidden = YES;
                weakSelf.collectionView.hidden = YES;
                weakSelf.nextCollView.hidden = NO;
                weakSelf.topLineView.hidden = NO;
                weakSelf.nextCollView.listArray = weakSelf.homeDataArray;
                [weakSelf.nextCollView reloadData];
            }else{
                weakSelf.collectionView.listArray = weakSelf.homeDataArray;
                weakSelf.collectionView.showType = [TOPScanerShare top_listType];
                weakSelf.tableView.hidden = YES;
                weakSelf.nextCollView.hidden = YES;
                weakSelf.topLineView.hidden = YES;
                weakSelf.collectionView.hidden = NO;
            }
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
    CGFloat topH = navH;
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
#pragma mark -- 到相册
- (void)top_HomeHeaderCameraPicture{
    CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
    if (freeSize<TOPFreeSize) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
        return;
    }
    [FIRAnalytics logEventWithName:@"top_HomeHeaderCameraPicture" parameters:nil];
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
                                if (freeSize<imgSize) {//手机剩余空间不足
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

- (void)top_saveAssetsRefreshUI:(NSArray *)assets {
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [self top_handleLibiaryPhoto:assets completion:^(NSArray *imagePaths) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (assets.count == 1) {
                [SVProgressHUD dismiss];
                [weakSelf top_CreateFolderWithSelectPhotos:imagePaths];
            } else if (assets.count > 1) {//选择多张图片时先不做剪裁处理
                [SVProgressHUD dismiss];
                [weakSelf top_OnlyToSendData:imagePaths];
            }
        });
    }];
}

#pragma mark -- 相册选择只有一张图片时
- (void)top_CreateFolderWithSelectPhotos:(NSArray *)photos{
    if (photos.count) {
        [FIRAnalytics logEventWithName:@"homeView_CreateFolderWithSelectPhotos" parameters:@{@"photos":photos}];
        TOPSingleBatchViewController * batch = [TOPSingleBatchViewController new];
        batch.pathString = self.pathString;
        batch.batchArray = [photos mutableCopy];
        batch.fileType = TOPShowNextFolderCameraType;
        batch.backType = TOPHomeChildViewControllerBackTypePopFolder;
        TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:batch];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}
#pragma mark -- 相册选择多张图片时
- (void)top_OnlyToSendData:(NSArray *)assets{
    if (assets.count) {
        [FIRAnalytics logEventWithName:@"top_OnlyToSendData" parameters:@{@"assets":assets}];
        TOPCamerBatchViewController * scamerBatch = [TOPCamerBatchViewController new];
        scamerBatch.pathString = self.pathString;
        scamerBatch.fileType = TOPShowNextFolderCameraType;
        scamerBatch.backType = TOPHomeChildViewControllerBackTypePopFolder;
        scamerBatch.dataArray = self.documentIndexArray;
        TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:scamerBatch];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)top_HideHeaderView{
    [FIRAnalytics logEventWithName:@"top_HideHeaderView" parameters:nil];
    [UIView animateWithDuration:0.3 animations:^{
        if (!self.isBanner) {
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, TOPBottomSafeHeight+Bottom_H, 0));
            }];
        }else{
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, TOPBottomSafeHeight+Bottom_H+self.adViewH, 0));
            }];
        }
        [self.view layoutIfNeeded];
    }];
    self.collectionView.isFromSecondFolderVC = NO;
    self.tableView.isFromSecondFolderVC = NO;
    self.nextCollView.isFromSecondFolderVC = NO;
    [self.collectionView setShowType:[TOPScanerShare top_listType]];
    [self.tableView reloadData];
    [self.nextCollView reloadData];
}

- (void)top_ShowHeaderView{
    [FIRAnalytics logEventWithName:@"top_ShowHeaderView" parameters:nil];
    [UIView animateWithDuration:0.3 animations:^{
        if (!self.isBanner) {
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, TOPTabBarHeight, 0));
            }];
        }else{
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, TOPTabBarHeight+self.adViewH, 0));
            }];
        }
        [self.view layoutIfNeeded];
    }];
    self.collectionView.isFromSecondFolderVC = YES;
    self.tableView.isFromSecondFolderVC = YES;
    self.nextCollView.isFromSecondFolderVC = YES;
    [self.collectionView setShowType:[TOPScanerShare top_listType]];
    [self.tableView reloadData];
    [self.nextCollView reloadData];
}
- (void)top_GetCamera{
    [FIRAnalytics logEventWithName:@"top_GetCamera" parameters:nil];
    TOPEnterCameraType cameraTpye = TOPShowNextFolderCameraType;
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = self.pathString;
    camera.fileType = cameraTpye;
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    camera.dataArray = self.documentIndexArray;
    
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)top_BackNextAction{
    [self.navigationController popViewControllerAnimated:YES];
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
                ocrTextVC.backType = TOPPhotoShowTextAgainVCBackTypePopFolder;
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
                ocrVC.backType = TOPPhotoShowTextAgainVCBackTypePopFolder;
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
#pragma mark -- lazy
- (NSMutableArray *)selectedDocsIndexArray {
    if (!_selectedDocsIndexArray) {
        _selectedDocsIndexArray = [@[] mutableCopy];
    }
    return _selectedDocsIndexArray;
}
#pragma mark -- 设置约束
- (void)top_markupCoverMask{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}
- (NSMutableArray*)homeMoreArray{
    if (!_homeMoreArray) {
        _homeMoreArray = [NSMutableArray new];
    }
    return _homeMoreArray;
}
- (NSMutableArray*)homeDataArray{
    if (!_homeDataArray) {
        _homeDataArray = [NSMutableArray array];
    }
    return _homeDataArray;
}
- (TOPHomeShowView *)topMoreView{
    if (!_topMoreView) {
        WS(weakSelf);
        _topMoreView = [[TOPHomeShowView alloc]initWithFrame:CGRectZero];
        _topMoreView.top_clickCellAction = ^(NSInteger row) {
            [weakSelf top_HomeHeaderMoreAction:row];
        };
        _topMoreView.top_clickDismiss = ^{
        };
    }
    return _topMoreView;
}

- (TOPWMDragView*)photoView{
    if (!_photoView) {
        WS(weakSelf);
        _photoView = [[TOPWMDragView alloc] initWithFrame:CGRectMake(TOPScreenWidth - (95), TOPScreenHeight - TOPNavBarAndStatusBarHeight - (100), (50), (50))];
        _photoView.imageView.image = [UIImage imageNamed:@"icon_paizhao_gai"];
        _photoView.backgroundColor = [UIColor clearColor];
        _photoView.layer.cornerRadius = (30);
        _photoView.layer.masksToBounds =  YES;
        _photoView.isKeepBounds = NO;
        _photoView.dragEnable = NO;
        _photoView.clickDragViewBlock = ^(TOPWMDragView *dragView) {
            [weakSelf top_GetCamera];
        };
    }
    return _photoView;
}

- (TOPAddFolderView *)addFolderView{
    if (!_addFolderView) {
        WS(weakSelf);
        _addFolderView = [[TOPAddFolderView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolder_W)];
        _addFolderView.top_clickToSendString = ^(NSString * _Nonnull editString) {
            if ([weakSelf.folderViewType isEqualToString:FolderViewTypeAdd]) {
                [weakSelf top_FolderAddAction:editString];
            }else if([weakSelf.folderViewType isEqualToString:FolderViewTypeChange]){
                [weakSelf top_ClickToChangeSelectFolderNameAction:editString];
            }else{
                [weakSelf top_ClickToChangeCurrentFolderNameAction:editString];
            }
            [weakSelf top_ClickToHide];
        };
        
        _addFolderView.top_clickToHide = ^{
            [weakSelf top_ClickToHide];
        };
    }
    return _addFolderView;
}

#pragma mark -- 密码弹框
- (TOPDocPasswordView *)passwordView{
    if (!_passwordView) {
        WS(weakSelf);
        _passwordView = [[TOPDocPasswordView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolderSingle_H)];
        _passwordView.top_sendPassword = ^(NSString * _Nonnull password, NSInteger actionType ,BOOL isShowFailToast) {
            weakSelf.isShowFailToast = isShowFailToast;
            [weakSelf top_passwordViewActionWithPassword:password WithType:actionType];
        };
        _passwordView.top_clickToHide = ^{
            [weakSelf top_ClickToHide];
        };
        _passwordView.top_clickToHelp = ^{
            [weakSelf top_settingView_SendFeedback];
        };
    }
    return _passwordView;
}
#pragma mark -- lazy
- (UIView *)contentFatherView {
    if (!_contentFatherView) {
        _contentFatherView = [[UIView alloc] init];
        _contentFatherView.backgroundColor = [UIColor clearColor];
    }
    return _contentFatherView;
}
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_ClickToHide)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}
- (UIView *)sortCoverView{
    if (!_sortCoverView) {
        _sortCoverView = [[UIView alloc]init];
        _sortCoverView.backgroundColor = RGBA(0, 0, 0, 0.4);
        _sortCoverView.alpha = 0;
        UITapGestureRecognizer * top_sortTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_sortTap)];
        [_sortCoverView addGestureRecognizer:top_sortTap];
    }
    return _sortCoverView;
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
  // The adLoader has finished loading ads, and a new request can be sent.
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error{

}
#pragma mark -- 获取原生广告成功
- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    NSLog(@"nativeAd==%@ images==%@",nativeAd,nativeAd.images);
    DocumentModel * nativeAdModel = [DocumentModel new];
    nativeAdModel.adModel = nativeAd;
    nativeAdModel.isAd = YES;
    self.nativeAdModel = nativeAdModel;
    [self top_adReceiveFinishAndRefreshUI];
    [self top_sumAllFileSize];//显示文件大小的lab
}

#pragma mark -- 原生广告接收完成并刷新UI
- (void)top_adReceiveFinishAndRefreshUI{
    if (self.nativeAdModel) {
        NSInteger adIndex = [TOPDocumentHelper top_adMobIndexWithListType:[TOPScanerShare top_listType] byItemCount:self.homeDataArray.count];
        [self.homeDataArray insertObject:self.nativeAdModel atIndex:adIndex];
        self.collectionView.listArray = self.homeDataArray;
        [self.collectionView setShowType:[TOPScanerShare top_listType]];
        self.tableView.listArray = self.homeDataArray;
        [self.tableView reloadData];
        
        self.nextCollView.listArray = self.homeDataArray;
        [self.nextCollView reloadData];
    }
}

#pragma mark -- 横幅广告
- (void)nextView_AddBannerViewWithSize:(CGSize)currentSize{
    GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(currentSize.width);
    self.adViewH = adSize.size.height;
    NSString * adID = @"ca-app-pub-3940256099942544/2934735716";
    adID = [TOPDocumentHelper top_bannerAdID][1];
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
        make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
        make.height.mas_equalTo(adSize.size.height);
    }];
}
#pragma mark -- 获取横幅广告成功
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView{
    if (bannerView) {
        bannerView.hidden = NO;
        self.isBanner = YES;
        [self top_bannerViewSuccessViewFream];
        [self top_sumAllFileSize];
    }
}
#pragma mark -- 获取横幅广告失败
- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    if (!self.isBanner) {
        self.isBanner = NO;
        bannerView.hidden = YES;
        [self top_bannerViewFailViewFream];
        [self top_sumAllFileSize];
    }
}
#pragma mark -- 获取横幅广告成功试图时 重置试图坐标位置
- (void)top_bannerViewSuccessViewFream{
    if ([TOPScanerShare shared].isEditing == YES) {
        [self.pressBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
            make.height.mas_equalTo(60);
        }];
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, TOPBottomSafeHeight+Bottom_H+self.adViewH, 0));
        }];
        [self.scBannerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        }];
    }else{
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, TOPTabBarHeight+self.adViewH, 0));
        }];
    }
}
#pragma mark -- 获取横幅广告失败试图时 重置试图坐标位置
- (void)top_bannerViewFailViewFream{
    if ([TOPScanerShare shared].isEditing) {
        [self.pressBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
            make.height.mas_equalTo(60);
        }];
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, TOPBottomSafeHeight+Bottom_H, 0));
        }];
    }else{
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight));
        }];
    }
}
#pragma mark -- 插页广告 1~12的随机数与界面ID相等时才显示插页广告
- (void)top_getInterstitialAd{
    int index = [TOPDocumentHelper top_interstitialAdRandomNumber];
    if (index == TOPAppInterfaceIDNextFolder) {
        WS(weakSelf);
        GADRequest *request = [GADRequest request];
        NSString * adID = @"ca-app-pub-3940256099942544/4411468910";
        adID = [TOPDocumentHelper top_interstitialAdID][1];
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
- (void)dealloc{
    NSLog(@"NextFolder dealloc");
}

@end
