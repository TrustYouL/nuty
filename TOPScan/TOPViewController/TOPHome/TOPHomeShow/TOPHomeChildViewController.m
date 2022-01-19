#define Bottom_H 60
#define AddFolder_W 310
#define AddFolder_H 240
#define AddFolderSingle_H 190
#define SSCountScroll 20
#import "TOPHomeChildViewController.h"
#import "TOPDocumentCollectionView.h"
#import "TOPPhotoShowViewController.h"
#import "TOPHomeViewController.h"
#import "TOPPhotoShowTextAgainVC.h"
#import "TOPPhotoShowOCRVC.h"
#import "TOPSetTagViewController.h"
#import "TOPSCameraViewController.h"
#import "TOPFileTargetListViewController.h"
#import "TOPShowLongImageViewController.h"
#import "TOPEditPDFViewController.h"
#import "TOPNextFolderViewController.h"
#import "TOPHomeChildBatchViewController.h"
#import "TOPFunctionColletionListVC.h"
#import "TOPDocumentRemindVC.h"
#import "TOPBinHomeViewController.h"
#import "TOPSuggestionsVC.h"

#import "TOPShareDownSizeView.h"
#import "TOPChildMoreView.h"
#import "TOPSettingEmailModel.h"
#import "TOPSettingEmailAgainView.h"
#import "TOPGridTwoCollectionViewCell.h"
#import "TOPWMDragView.h"
#import "TOPPhotoLongPressView.h"
#import "TopScanner-Swift.h"
#import "TOPDataTool.h"
#import "TOPDataModelHandler.h"
#import "TOPDBDataHandler.h"
#import "TOPUserDefinedSizeView.h"
#import "TOPHeadMenuModel.h"
#import "TOPCollageViewController.h"
#import "TOPAddFolderView.h"
#import "TOPChildTipView.h"
#import "TOPFunctionChildBottomView.h"
#import "TOPFunctionChildAdjustBottomView.h"
#import "TOPLoadSelectDriveViewController.h"
#import "TOPChildSettingVC.h"
#import "AppDelegate.h"
#import "TOPAppDocument.h"
#import "TOPEditDBDataHandler.h"
#import "TOPShareFileView.h"
#import "TOPShareFileModel.h"
#import "TOPShareFileDataHandler.h"
#import "TOPCropTipView.h"
#import "TOPVerticalSlider.h"
#import "TOPNewScoreView.h"
#import "TOPPicDetailView.h"
@interface TOPHomeChildViewController ()<
MFMailComposeViewControllerDelegate,
UIPrintInteractionControllerDelegate,
TZImagePickerControllerDelegate,
GADBannerViewDelegate,GADFullScreenContentDelegate, UIScrollViewDelegate>
{
    int folderType;
    int documentType;
    NSArray *blDtArray;
}
@property (nonatomic, strong) UILabel *fileSizeLab;
@property (nonatomic, strong) UIView * contentFatherView;
@property (nonatomic, strong) TOPDocumentCollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray  *homeDataArray;
@property (nonatomic, strong) NSMutableArray  *scanDataArray;
@property (nonatomic, strong) NSMutableArray  *emailArray;
@property (nonatomic, strong) TOPPhotoShowViewController *imageBraowerVC;
@property (nonatomic, strong) UIButton *allSelctBtn;
@property (nonatomic, strong) UIButton *showBtn;
@property (nonatomic, strong) TOPPhotoLongPressView *tabbarBottomView;
@property (nonatomic, strong) TOPPhotoLongPressView *pressUpView;
@property (nonatomic, strong) TOPPhotoLongPressView *pressBootomView;
@property (nonatomic, strong) TOPFunctionChildBottomView *boxBootomView;
@property (nonatomic, strong) TOPFunctionChildAdjustBottomView *boxAdjustBootomView;
@property (nonatomic, strong) TOPSettingEmailAgainView * emailAgainView;
@property (nonatomic, strong) TOPAddFolderView * addFolderView;
@property (nonatomic, strong) TOPDocPasswordView * passwordView;
@property (nonatomic, strong) UIView * coverView;
@property (nonatomic, strong) UIView * manualSortingHeaderView;
@property (nonatomic, strong) TOPUserDefinedSizeView * userDefinedsizeView;
@property (nonatomic, copy) NSString *addEndPath;
@property (nonatomic, strong) NSMutableArray * upperArray;
@property (nonatomic, assign) NSInteger emailType;
@property (nonatomic, assign) NSInteger pdfType;
@property (nonatomic, copy) NSString * totalSizeString;
@property (nonatomic, strong) TOPSettingEmailModel * emailModel;
@property (strong, nonatomic) NSMutableArray *selectedDocsIndexArray;
@property (nonatomic, strong) NSMutableArray *moreArray;
@property (nonatomic, assign) BOOL isShowFailToast;
@property (nonatomic, assign) BOOL isBoxEnter;
@property (nonatomic, strong) NSMutableArray *addNewImageArr;
@property (nonatomic, strong) DocumentModel * saveModel;
@property (nonatomic, strong) TOPShareFileView *shareFilePopView;
@property (nonatomic, strong) DocumentModel * imgModel;
@property (nonatomic, strong) GADBannerView * scBannerView;
@property (nonatomic, strong) GADInterstitialAd *interstitial;
@property (nonatomic, assign) CGFloat adViewH;
@property (nonatomic, assign) BOOL isBanner;
@property (nonatomic, strong) TOPVerticalSlider *scrollIndicator;
@property (nonatomic, assign) BOOL scrollMark;
@property (nonatomic, strong) TOPImageTitleButton * listTypeBtn;
@end

@implementation TOPHomeChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.saveModel = [TOPFileDataManager shareInstance].docModel;
    self.isBoxEnter = YES;
    self.isBanner = NO;
    self.adViewH = 0.0;
    [self top_removeBannerView];
    [self top_loadAdData];
    [self top_SetupTopAndBottomView];
    [self top_setupUI];
    [TOPScanerShare shared].isEditing = YES;
    [TOPScanerShare shared].isManualSorting = NO;
    [TOPEditDBDataHandler top_editDocumentReadingTimeWithId:self.docModel.docId];
    [self top_LoadAssetsArryData];
}
- (void)top_loadAdData{
    CGFloat navH = self.navigationController.navigationBar.frame.size.height;
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![TOPPermissionManager top_enableByAdvertising]) {
                    [self top_AddBannerViewWithSize:CGSizeMake(self.view.width, self.view.height-TOPStatusBarHeight-navH)];
                    [self top_getInterstitialAd];
                }
            });
        }];
    } else {
        if (![TOPPermissionManager top_enableByAdvertising]) {
            [self top_AddBannerViewWithSize:CGSizeMake(self.view.width, self.view.height-TOPStatusBarHeight-navH)];
            [self top_getInterstitialAd];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [TOPFileDataManager shareInstance].docModel = self.docModel;
    if (!self.selectBoxModel) {
        if (![TOPScanerShare shared].isEditing) {
            [self top_changeScanPicName];
            [self top_LoadSanBoxData];
        }
    }else{
        self.isBoxEnter = YES;
        [self top_changeScanPicName];
        [self top_LoadSanBoxData];
    }
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(top_downloadFileDrivesSusess:) name:@"downDrives" object:nil];

    if (self.selectBoxModel&&self.isBoxEnter) {
        if (self.selectBoxModel.functionType == TopFunctionTypeDocPassword) {
            self.isBoxEnter = NO;
            NSString * passwordString = [TOPDocumentHelper top_getDocPasswordPathString:self.pathString];
            if ([TOPWHCFileManager top_isExistsAtPath:passwordString]) {
                [self top_BottomViewWithMore];
            }else{
                UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
                NSString * defaultPassword = [TOPScanerShare top_docPassword];
                if (defaultPassword.length == 0) {
                    self.passwordView.actionType = TOPHomeMoreFunctionSetLockFirst;
                }else{
                    self.passwordView.actionType = TOPHomeMoreFunctionSetLock;
                }
                [keyWindow addSubview:self.coverView];
                [self top_markupCoverMask];
                [keyWindow addSubview:self.passwordView];
            }
        }
    }
}
#pragma mark -- 横竖屏切换时重新设置titleView
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self top_restoreBannerAD:size];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
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
        [self top_removeBannerView];
        [self top_AddBannerViewWithSize:size];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if (self.isAppDelegate) {
        [TOPFileDataManager shareInstance].docModel = self.saveModel;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self top_reductionEditViewFream];
    if ([TOPScanerShare shared].isEditing) {
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
            if (self.passwordView.actionType == TOPHomeMoreFunctionSetLockFirst || self.passwordView.actionType == TOPHomeMoreFunctionPDFPassword) {
                self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_H, AddFolder_W, AddFolder_H);
            }else{
                self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolderSingle_H, AddFolder_W, AddFolderSingle_H);
            }
        }];
    }
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    if (![self.passwordView.tField isFirstResponder]&&![self.passwordView.againField isFirstResponder]&&![self.addFolderView.tField  isFirstResponder]) {
        [self top_ClickToHide];
    }
}
#pragma mark -- 网盘批量下载成功通知
- (void)top_downloadFileDrivesSusess:(NSNotificationCenter *)notification
{
    [self top_LoadSanBoxData];

}
-(NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath
{
    NSArray *fileList = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil]
                         pathsMatchingExtensions:[NSArray arrayWithObject:type]];
    return fileList;
}

- (void)top_changeScanPicName{
    if (![TOPScanerShare shared].isEditing) {
        [self top_SortPicName];
    }
}

#pragma mark -- 图片排序重命名
- (void)top_SortPicName {
    if (self.scanDataArray.count) {
        static NSString *tempFile = @"TongRuanTempFolder";
        NSString *tempFolder = [self.pathString stringByAppendingPathComponent:tempFile];
        [TOPWHCFileManager top_createDirectoryAtPath:tempFolder];
        [self top_WriteNewPicsToNewFileAtPath:tempFolder];
        [TOPDocumentHelper top_moveFileItemsAtPath:tempFolder toNewFileAtPath:self.pathString];
        [TOPWHCFileManager top_removeItemAtPath:tempFolder];
        [self top_updateDocumentImagesSort];
        [self.scanDataArray removeAllObjects];
    }
}

- (void)top_updateDocumentImagesSort {
    NSMutableArray *ids = @[].mutableCopy;
    for (DocumentModel *model in self.scanDataArray) {
        [ids addObject:model.docId];
    }
    [TOPEditDBDataHandler top_updateDocumentImagesSortWithIds:ids byDoc:self.pathString];
}

#pragma mark -- 图片写入到临时文件
- (void)top_WriteNewPicsToNewFileAtPath:(NSString *)tempFolder {
    for (DocumentModel *model in self.scanDataArray) {
        NSString *originalPath = [NSString stringWithFormat:@"%@/%@%@",model.movePath,TOPRSimpleScanOriginalString,model.photoName];
        NSString *notePath = [TOPDocumentHelper top_originalNote:model.imagePath];
        NSString *ocrPath = [TOPDocumentHelper top_originalOcr:model.imagePath];
        [TOPWHCFileManager top_removeItemAtPath:model.coverImagePath];
        if ([TOPWHCFileManager top_isExistsAtPath:model.imagePath]) {
            NSString * tempSubString = [model.photoName substringToIndex:14];
            NSInteger index = 0;
            if ([TOPScanerShare top_childViewByType] == 1) {//升序
                index = [self.scanDataArray indexOfObject:model];
            }else{
                index = self.scanDataArray.count - [self.scanDataArray indexOfObject:model] - 1;
            }
            NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",tempSubString,[TOPDocumentHelper top_getFileNameNumber: index],TOP_TRJPGPathSuffixString];
            NSString *txtName = [NSString stringWithFormat:@"%@%@%@",tempSubString,[TOPDocumentHelper top_getFileNameNumber: index],TOP_TRTXTPathSuffixString];
            NSString *tempImgPath = [NSString stringWithFormat:@"%@/%@",tempFolder,fileName];
            NSString *tempOriginalImgPath = [NSString stringWithFormat:@"%@/%@%@",tempFolder,TOPRSimpleScanOriginalString,fileName];
            NSString *noteContentPath = [tempFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",TOPRSimpleScanNoteString,txtName]];
            NSString *ocrContentPath = [tempFolder stringByAppendingPathComponent:txtName];

            [TOPWHCFileManager top_moveItemAtPath:model.imagePath toPath:tempImgPath];
            if ([TOPWHCFileManager top_isExistsAtPath:originalPath]) {
                [TOPWHCFileManager top_moveItemAtPath:originalPath toPath:tempOriginalImgPath];
            }
            if ([TOPWHCFileManager top_isExistsAtPath:notePath]) {
                [TOPWHCFileManager top_moveItemAtPath:notePath toPath:noteContentPath];
            }
            if ([TOPWHCFileManager top_isExistsAtPath:ocrPath]) {
                [TOPWHCFileManager top_moveItemAtPath:ocrPath toPath:ocrContentPath];
            }
        }
    }
}

- (void)top_ClickRightItems:(UIButton *)sender{
    [FIRAnalytics logEventWithName:@"top_ClickRightItems" parameters:@{@"tag":@(sender.tag)}];
    sender.selected = YES;
    if (sender.tag == 10) {
        TOPChildSettingVC * settingVC = [TOPChildSettingVC new];
        settingVC.pathString = self.pathString;
        [self.navigationController pushViewController:settingVC animated:YES];
    }else if (sender.tag == 11){
        [TOPScanerShare shared].isEditing = YES;
        [self top_ShowPressUpView];
        [self.pressBootomView top_changePressViewBtnState:TOPItemsSelectedNone];
        self.collectionView.listArray = self.homeDataArray;
        [self.collectionView reloadData];
    }else if (sender.tag == 12){
        [self top_ShareShowTip];
    }
}
#pragma mark -- 修改文件名
- (void)top_ClickToChangeFolderName{
    WS(weakSelf);
    TopEditFolderAndDocNameVC * editName = [TopEditFolderAndDocNameVC new];
    editName.top_clickToSendString = ^(NSString * _Nonnull nameString) {
        [weakSelf top_ClickToChangeFolderNameAction:nameString];
    };
    editName.defaultString = [TOPWHCFileManager top_fileNameAtPath:self.pathString suffix:YES];
    editName.editType = TopFileNameEditTypeChangeDocName;
    editName.picName = @"top_changedoc";
    editName.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editName animated:YES];
}

- (void)top_ClickToChangeFolderNameAction:(NSString *)name{
    if ([name isEqualToString:self.title]) {
        return;
    }

    NSString *filePath = [[TOPWHCFileManager top_directoryAtPath:self.pathString] stringByAppendingPathComponent:name];
    if ([TOPWHCFileManager top_isExistsAtPath:filePath]) {
        [self top_FolderAlreadyAlert];
        return;
    }
    if (name.length == 0) {
        return;
    }
    //把文件移到新目录下
    [TOPDocumentHelper top_moveFileItemsAtPath:self.pathString toNewFileAtPath:filePath];
    [TOPEditDBDataHandler top_editDocumentName:name withId:self.docModel.docId];
    self.docModel.path = filePath;
    self.docModel.name = name;
    [self.showBtn setTitle:name forState:UIControlStateNormal];
    self.title = name;
    self.pathString = filePath;
    [self top_LoadSanBoxData];
}
- (void)top_FolderAlreadyAlert{
    //提示框添加文本输入框
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_hasfolder", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)top_SetupTopAndBottomView{
    self.title =  [TOPWHCFileManager top_fileNameAtPath:self.pathString suffix:YES];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    TOPImageTitleButton * showBtn = [[TOPImageTitleButton alloc]initWithStyle:ETitleLeftImageRightCenter];
    showBtn.padding = CGSizeMake(2, 2);
    showBtn.frame = CGRectMake(0, 0, TOPScreenWidth-100, 44);
    showBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    showBtn.titleLabel.minimumScaleFactor = 0.8;
    showBtn.titleLabel.numberOfLines = 1;
    [showBtn setTitle:self.title forState:UIControlStateNormal];
    [showBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:[UIColor blackColor]] forState:UIControlStateNormal];
    [showBtn setImage:[UIImage imageNamed:@"top_changeFolder"] forState:UIControlStateNormal];
    [showBtn addTarget:self action:@selector(top_ClickToChangeFolderName) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = showBtn;
    self.showBtn = showBtn;
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_BackHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_BackHomeAction)];
    }
    NSString * lastBtnIcon;
    if ([TOPScanerShare top_saveChildVCListType] == TOPChildVCListTypeFirst) {
        lastBtnIcon = @"top_childListTypesecond";
    }else if([TOPScanerShare top_saveChildVCListType] == TOPChildVCListTypeSecond){
        lastBtnIcon = @"top_childListTypethird";
    }else{
        lastBtnIcon = @"top_childListTypefirst";
    }
    NSArray * imageArray = [NSArray new];
    imageArray = @[@"top_childvcsetting",@"top_ziyuan",@"top_tz-pdf"];
    NSMutableArray * btnArray = [NSMutableArray new];
    for (int i = 0; i<imageArray.count; i++) {
        TOPImageTitleButton * btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
        btn.frame = CGRectMake(0, 0, 18, 40);
        btn.tag = i+10;
        [btn setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(top_ClickRightItems:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * barItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        [btnArray addObject:barItem];
        if (i == 2) {
            self.listTypeBtn = btn;
        }
    }
    self.navigationItem.rightBarButtonItems = btnArray;

    NSArray * sendPicArray = @[@"top_addto",@"top_downview_share",@"top_sendToEmail",@"top_downview_selectdelete",@"top_morefunction"];
    NSArray * sendNameArray = @[NSLocalizedString(@"topscan_addto", @""),NSLocalizedString(@"topscan_share", @""),NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_delete", @""),NSLocalizedString(@"topscan_more", @"")];
    self.tabbarBottomView = [[TOPPhotoLongPressView alloc] initWithPressBottomFrame: CGRectMake(0, TOPScreenHeight -TOPNavBarAndStatusBarHeight -TOPBottomSafeHeight - (Bottom_H), TOPScreenWidth, (Bottom_H)) sendPicArray:sendPicArray sendNameArray:sendNameArray];
    WS(weakSelf);
    self.tabbarBottomView.top_longPressBootomItemHandler = ^(NSInteger index) {
        [FIRAnalytics logEventWithName:@"top_longPressBootomItemHandler" parameters:@{@"longPress":@(index)}];
        if (index == 0) {
            [weakSelf top_BottomViewWithAdd];
        }else if (index == 1){
            weakSelf.emailType = 0;
            [weakSelf top_BottomViewWithShare];
        }else if (index == 2){
            weakSelf.emailType = 1;
            [weakSelf top_BottomViewWithShare];
        }else if (index == 3){
            [weakSelf top_MoreViewDeleteAllPic];
        }else{
            [weakSelf top_BottomViewWithMore];
        }
    };
    
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight -TOPNavBarAndStatusBarHeight -TOPBottomSafeHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];

    [self.view addSubview:self.tabbarBottomView];
    [self.view addSubview:bottomView];
    if (!self.isBanner) {
        [self.tabbarBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
            make.height.mas_equalTo(Bottom_H);
        }];
    }else{
        [self.tabbarBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
            make.height.mas_equalTo(Bottom_H);
        }];
    }
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
}

- (void)top_setupUI{
    weakify(self);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
     
    NSLog(@"%@",self.docModel.mj_keyValues);
    self.collectionView = [[TOPDocumentCollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-(Bottom_H)) collectionViewLayout:layout];
    self.collectionView.isShowHeaderView = NO;
    self.collectionView.isFromSecondFolderVC = NO;
    self.collectionView.top_movePhotoIndexPathHandler = ^(NSInteger from, NSInteger to, NSMutableArray * _Nonnull sourceArray) {
        SS(strongSelf);
        NSMutableArray *arr = [NSMutableArray array];
        strongSelf.scanDataArray = sourceArray;
        arr = [sourceArray mutableCopy];
        strongSelf.collectionView.listArray = arr;
        strongSelf.homeDataArray = arr;
        [strongSelf performSelector:@selector(top_RefreshData) withObject:nil afterDelay:0.4];
    };
    
    self.collectionView.top_longPressEditHandler = ^(NSIndexPath * _Nonnull idxPath){
        [weakSelf top_ShowPressUpView];
    };
    
    self.collectionView.top_longPressCheckItemHandler = ^(NSInteger index, BOOL selected) {
        DocumentModel *model = weakSelf.homeDataArray[index];
        model.selectStatus = selected;
        if (selected) {
            [weakSelf.selectedDocsIndexArray addObject:model];
        } else {
            [weakSelf.selectedDocsIndexArray removeObject:model];
        }
    };
    
    self.collectionView.top_longPressCalculateSelectedHander = ^{
        [weakSelf top_RefreshViewWithSelectItem];
    };
    
    self.collectionView.top_showPhotoHandler = ^(NSMutableArray * _Nonnull pathArray, NSIndexPath * _Nonnull idxPath) {
        [FIRAnalytics logEventWithName:@"showPhotoHandler" parameters:nil];
        [weakSelf top_checkDetailWithImages:pathArray atIndex:idxPath enterType:TOPHomeChildCellClickEnterType];
    };
    
    self.collectionView.top_clickTxtNote = ^(NSMutableArray * _Nonnull pathArray, NSIndexPath * _Nonnull idxPath) {
        [FIRAnalytics logEventWithName:@"clickTxtNote" parameters:nil];
        weakSelf.imgModel = weakSelf.homeDataArray[idxPath.item];
        [weakSelf top_checkDetailWithImages:pathArray atIndex:idxPath enterType:TOPHomeChildCellShowBackBtnType];
        [weakSelf.collectionView reloadData];
    };
    
    self.collectionView.top_clickTxtOCR = ^(NSMutableArray * _Nonnull pathArray, NSIndexPath * _Nonnull idxPath) {
        weakSelf.imgModel = weakSelf.homeDataArray[idxPath.item];
        TOPPhotoShowTextAgainVC * ocrTextVC = [TOPPhotoShowTextAgainVC new];
        [ocrTextVC.dataArray addObject:pathArray[idxPath.item]];
        ocrTextVC.backType = TOPPhotoShowTextAgainVCBackTypePopChild;
        ocrTextVC.hidesBottomBarWhenPushed = YES;

        [weakSelf.navigationController pushViewController:ocrTextVC animated:YES];
    };
    self.collectionView.top_didScrolInBottom = ^(BOOL isBottom) {
        weakSelf.fileSizeLab.hidden = !isBottom;
    };
    [self.view addSubview:self.contentFatherView];
    [self.contentFatherView addSubview:self.collectionView];
    [self.contentFatherView addSubview:self.fileSizeLab];
    [self.collectionView addGestureRecognizer];
    [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+(Bottom_H)));
    }];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentFatherView);
    }];
    [self.fileSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentFatherView);
        make.height.mas_equalTo(30);
    }];
    self.collectionView.top_didScrollBlock = ^{
        [weakSelf top_didScroll];
    };
    self.collectionView.top_endDraggingBlock = ^{
        [weakSelf didEndDecelerating];
    };
}
#pragma mark -- ShareText
- (void)top_shareText{
    NSMutableArray * selectArray = [NSMutableArray new];
    NSMutableArray * ocrArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if (model.selectStatus) {
            [selectArray addObject:model];
            if ([TOPWHCFileManager top_isExistsAtPath:model.ocrPath]) {
                [ocrArray addObject:model];
            }
        }
    }
    
    if (selectArray.count == ocrArray.count&&selectArray.count) {
        TOPPhotoShowTextAgainVC * ocrTextVC = [TOPPhotoShowTextAgainVC new];
        ocrTextVC.dataArray = ocrArray;
        ocrTextVC.backType = TOPPhotoShowTextAgainVCBackTypePopChild;
        ocrTextVC.dataType = TOPOCRDataTypeSingleDocument;
        ocrTextVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ocrTextVC animated:YES];
    }else{
        TOPPhotoShowOCRVC * ocrVC = [TOPPhotoShowOCRVC new];
        ocrVC.currentIndex = 0;
        ocrVC.dataArray = selectArray;
        ocrVC.backType = TOPPhotoShowTextAgainVCBackTypePopChild;
        ocrVC.ocrAgain = TOPPhotoShowOCRVCAgainTypeOCRNot;
        ocrVC.finishType = TOPPhotoShowOCRVCAgainFinishNot;
        ocrVC.dataType = TOPOCRDataTypeSingleDocument;
        ocrVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ocrVC animated:YES];
    }
}

#pragma mark -- 查看图片详情
- (void)top_checkDetailWithImages:(NSArray *)images atIndex:(NSIndexPath *)idxPath enterType:(NSInteger)enterType{
    __weak typeof(self) weakSelf = self;
    TOPPhotoShowViewController * imageBraowerVC = [[TOPPhotoShowViewController alloc]init];
    imageBraowerVC.pathString = weakSelf.pathString;
    imageBraowerVC.images = images;
    imageBraowerVC.currentIndex = idxPath.item;
    imageBraowerVC.enterType = enterType;
    imageBraowerVC.top_DeleteAllData = ^{
        [weakSelf top_deleteCurrentDocument];
        [weakSelf.pressUpView  removeFromSuperview];
        [weakSelf.pressBootomView removeFromSuperview];
        weakSelf.pressBootomView = nil;
        weakSelf.pressUpView = nil;
        [weakSelf top_BackHomeAction];
    };
    imageBraowerVC.top_DismissBlock = ^(DocumentModel * _Nonnull sendModel) {
        weakSelf.imgModel = sendModel;
    };
    imageBraowerVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:imageBraowerVC animated:YES];
}

#pragma mark -- 选中文件并刷新界面
- (void)top_RefreshViewWithSelectItem {
    [FIRAnalytics logEventWithName:@"homeChild_RefreshViewWithSelectItem" parameters:nil];
    [TOPScanerShare shared].isEditing = YES;
    TOPItemsSelectedState selectedState = TOPItemsSelectedNone;
    NSMutableArray *selectedArray = [NSMutableArray array];
    for (DocumentModel *model in self.homeDataArray) {
        if (model.selectStatus == YES) {
            [selectedArray addObject:model];
        }
    }
    NSInteger picCount = selectedArray.count;
    if (!selectedArray.count) {
        selectedState = TOPItemsSelectedNone;
        self.boxBootomView.myBtn.enabled = NO;
        self.boxBootomView.myBtn.alpha = 0.6;
    } else {
        self.boxBootomView.myBtn.enabled = YES;
        self.boxBootomView.myBtn.alpha = 1.0;
        if (picCount == 1) {
            selectedState = TOPItemsSelectedOnePic;
        } else if (picCount > 1) {
            selectedState = TOPItemsSelectedSomePic;
        }
    }
    [self.pressUpView top_configureSelectedCount:selectedArray.count];
    if (selectedArray.count == self.homeDataArray.count) {
        self.pressUpView.allSelectBtn.selected = YES;
    }else{
        self.pressUpView.allSelectBtn.selected = NO;
    }
    [self.pressBootomView top_changePressViewBtnState:selectedState];
    [self.boxAdjustBootomView top_changePressViewBtnState:selectedState];
}

- (void)top_LoadAssetsArryData{
    if (self.assetsArray.count>0) {
        NSString * documentStr = [TOPDocumentHelper top_appBoxDirectory];
        NSString * addStr = [[self.upperPathString componentsSeparatedByString:documentStr] objectAtIndex:1];
        NSString * componentDocumentsStr = [NSString new];

        if (self.fileType == TOPShowFolderCameraType) {
            componentDocumentsStr = [NSString stringWithFormat:@"%@/%@",addStr,@"Documents"];
        }
        if (self.fileType == TOPShowNextFolderCameraType) {
            componentDocumentsStr = addStr;
        }
        
        NSString *filePath = [TOPDocumentHelper top_getBelongDocumentPathString:componentDocumentsStr];

        NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:filePath];
        self.pathString = endPath;
        self.fileNameString = [TOPWHCFileManager top_fileNameAtPath:endPath suffix:YES];
        self.startPath = filePath;
        self.title = self.fileNameString;
        [self.showBtn setTitle:self.title forState:UIControlStateNormal];
        
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];

        dispatch_queue_t queueE = dispatch_queue_create("group.queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t groupE = dispatch_group_create();
        dispatch_queue_t serialQue= dispatch_queue_create("serial.queue",DISPATCH_QUEUE_SERIAL);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
        for (int i = 0; i < self.assetsArray.count; i ++) {
            dispatch_async(serialQue, ^{
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_group_async(groupE, queueE, ^{
                    dispatch_group_enter(groupE);
                    @autoreleasepool {
                        NSString *fileName = self.assetsArray[i];
                        [self top_saveCamerPic:fileName atIndex:i];
                    }
                    dispatch_semaphore_signal(semaphore);
                    dispatch_group_leave(groupE);
                });
                if (i == self.assetsArray.count - 1) {
                    dispatch_group_notify(groupE, dispatch_get_main_queue(), ^{
                        [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
                        [SVProgressHUD dismiss];
                        [TOPScanerShare shared].isEditing = NO;
                        [self top_LoadSanBoxData];
                    });
                }
            });
        }
    } else {
        [TOPScanerShare shared].isEditing = NO;
    }
}

#pragma mark -- 保存相册中取出的图片，同时根据设置处理源图的保存
- (void)top_saveCamerPic:(NSString *)fileName atIndex:(int)i {
    NSString *filePath = [TOPCamerPic_Path stringByAppendingPathComponent:fileName];
    NSData *imgData = [NSData dataWithContentsOfFile:filePath];
    NSString *imgName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [self.pathString stringByAppendingPathComponent:imgName];
    UIImage *image = [TOPPictureProcessTool top_fetchOriginalImageWithData:imgData];
    [TOPDocumentHelper top_saveImage:image atPath:fileEndPath];
    if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveYES) {
        NSString *originalPath = [TOPDocumentHelper top_getSourceFilePath:self.pathString fileName:imgName];
        if ([TOPWHCFileManager top_isExistsAtPath:fileEndPath]) {
            [TOPWHCFileManager top_copyItemAtPath:fileEndPath toPath:originalPath];
        }
    }
}

#pragma mark -- 组装数据 从沙盒里面获取数据
- (void)top_LoadSanBoxData{
    TOPAppDocument *docObj = [TOPDBQueryService top_appDocumentById:self.docModel.docId];
    if (docObj.costTime > 500) {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:self.docModel.docId];
        appDoc.filePath = self.pathString;
        CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
        NSMutableArray *dataArray = [TOPDBDataHandler top_buildDocumentDataWithDB:appDoc];
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        int costTime = linkTime * 1000;
        [self top_logLoadTime:costTime];
        [TOPEditDBDataHandler top_editDocumentCostTime:costTime withId:appDoc.Id];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self top_printImgCount:dataArray];
            if (dataArray.count > SSCountScroll) {
                self.scrollIndicator.hidden = YES;
                self.scrollIndicator.itemCount = dataArray.count;
            }
            self.collectionView.listArray  = dataArray;
            self.homeDataArray =  dataArray;
            if (self.imgModel.docId) {
                self.collectionView.markCellId = self.imgModel.docId;
            }
            self.collectionView.isMoveState = YES;
            self.collectionView.selectBoxModel = self.selectBoxModel;
            [self.collectionView setShowType:ShowListDetailGoods];
            [self top_enterBoxState];
            [self top_sumAllFileSize];
            if (self.showMoreView) {
                [self top_BottomViewWithMore];
            }
        });
    });
}
- (void)top_logLoadTime:(int)num{
    NSString * sendString = [NSString new];
    if (num>6000) {
        sendString = @"MoreThan5000";
    }else{
        NSInteger sendNum = (num/500+1)*500;
        sendString = [NSString stringWithFormat:@"%ld",sendNum];
    }
    [FIRAnalytics logEventWithName:[NSString stringWithFormat:@"loadTime_%@",sendString] parameters:nil];
}
- (void)top_printImgCount:(NSMutableArray *)dataArray{
    if (dataArray.count>=2000) {
        [FIRAnalytics logEventWithName:@"DocImgCount_MoreThan2000" parameters:nil];
    }else{
        NSInteger sendNum = 0;
        if (dataArray.count>1000) {
            sendNum = ((dataArray.count-1000)/100+1)*100+1000;
        }else{
            sendNum = (dataArray.count/100+1)*100;
        }
        NSString * sendString = [NSString stringWithFormat:@"DocImgCount_%ld",sendNum];
        [FIRAnalytics logEventWithName:sendString parameters:nil];
    }
}
#pragma mark -- 显示文件大小的lab
- (void)top_sumAllFileSize {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        long total = [TOPDocumentHelper top_calculateAllFilesSize:@[self.docModel]];
        NSString *sizeStr = [TOPDocumentHelper top_memorySizeStr:(total *1.0)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BOOL isShow = self.collectionView.contentSize.height > (self.collectionView.bounds.size.height - 30) ? YES : NO;
            if (!self.homeDataArray.count) {
                self.fileSizeLab.hidden = YES;
            }else{
                self.fileSizeLab.hidden = isShow;
            }
            self.fileSizeLab.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"topscan_filesize", @""), sizeStr];
        });
    
    });
}
#pragma mark-- 入口是工具箱时数据加载完成之后的处理
- (void)top_enterBoxState{
    if (self.selectBoxModel&&self.isBoxEnter) {
        if (self.selectBoxModel.functionType == TopFunctionTypePDFExtract||self.selectBoxModel.functionType == TopFunctionTypePDFPageAdjustment){
            self.isBoxEnter = NO;
            [TOPScanerShare shared].isEditing = YES;
            [self top_ShowPressUpView];
            if (self.homeDataArray.count>0) {
                DocumentModel *model = self.homeDataArray[0];
                model.selectStatus = YES;
                [self.selectedDocsIndexArray addObject:model];
                [self top_RefreshViewWithSelectItem];
                [self.collectionView setShowType:ShowListDetailGoods];
            }
        }
    }
}
- (void)top_whenCreatDocumentAddTags:(NSString *)docPath{
    NSString * tagsName = [TOPScanerShare top_saveTagsName];
    NSString * docTagsPath = [docPath stringByAppendingPathComponent:TOP_TRTagsPathString];
    NSString * tagsPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",TOP_TRTagsPathString,tagsName]];
    [TOPWHCFileManager top_removeItemAtPath:docTagsPath];
    if (![tagsName isEqualToString:TOP_TRTagsAllDocesKey]&&![tagsName isEqualToString:TOP_TRTagsUngroupedKey]&&![TOPWHCFileManager top_isExistsAtPath:tagsPath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:tagsPath];
    }
}

- (void)top_RefreshData {
    [self.collectionView reloadData];
}

#pragma mark -- 编辑选中文件时 底部菜单的数据源
- (NSArray *)sendPicArray {
    NSArray * temp = @[@"top_downview_share",@"top_downview_copyFile",@"top_saveToFolder",@"top_downview_selectdelete",@"top_morefunction"];
    return temp;
}

- (NSArray *)picArray {
    NSArray * temp = @[@"top_downview_disableshare",@"top_downview_disablecopy",@"top_downview_dissmissSave",@"top_downview_disabledelete",@"top_downview_disablemorefun"];
    return temp;
}

- (NSArray *)funcItems {
    NSArray * temp = @[@(TOPMenuItemsFunctionShare),@(TOPMenuItemsFunctionCopyMove),@(TOPMenuItemsFunctionSaveToGallery),@(TOPMenuItemsFunctionDelete),@(TOPMenuItemsFunctionMore)];//,@(TOPMenuItemsFunctionMore)
    return temp;
}

- (NSArray *)sendNameArray{
    NSArray * temp = @[NSLocalizedString(@"topscan_share", @""),NSLocalizedString(@"topscan_copy", @""),NSLocalizedString(@"topscan_savetogallery", @""),NSLocalizedString(@"topscan_delete", @""),NSLocalizedString(@"topscan_more", @"")];
    return temp;
}
//
- (NSArray *)sendAdjustPicArray {
    NSArray * temp = @[@"top_addto",@"top_downview_share",@"top_adjustExtract",@"top_downview_selectdelete",@"top_scamerbatch_reEditAffirm"];
    return temp;
}

- (NSArray *)picAdjustArray {
    NSArray * temp = @[@"top_addto",@"top_downview_disableshare",@"top_disadjustExtract",@"top_downview_disabledelete",@"top_scamerbatch_reEditAffirm"];
    return temp;
}
- (NSArray *)adjustFuncItems {
    NSArray * temp = @[@(TOPMenuItemsFunctionAddto),@(TOPMenuItemsFunctionShare),@(TOPMenuItemsFunctionExtract),@(TOPMenuItemsFunctionDelete),@(TOPMenuItemsFunctionAdjustSave)];//,@(TOPMenuItemsFunctionMore)
    return temp;
}

- (NSArray *)sendAdjustNameArray{
    NSArray * temp = @[NSLocalizedString(@"topscan_addto", @""),NSLocalizedString(@"topscan_share", @""),NSLocalizedString(@"topscan_colletionbottomtitle", @""),NSLocalizedString(@"topscan_delete", @"")];
    return temp;
}

- (void)top_ShowPressUpView{
    [FIRAnalytics logEventWithName:@"homeChild_ShowPressUpView" parameters:nil];
    [self top_closePopGestureRecognizer];
    weakify(self);
    SS(strongSelf);
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    if (!strongSelf.pressUpView) {
        strongSelf.pressUpView = [[TOPPhotoLongPressView alloc] initWithPressUpFrame:CGRectMake(0, -TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPNavBarAndStatusBarHeight)];
        if (weakSelf.selectBoxModel.functionType == TopFunctionTypePDFExtract||weakSelf.selectBoxModel.functionType == TopFunctionTypePDFPageAdjustment) {
            [strongSelf.pressUpView top_changeUPViewState];
        }
        strongSelf.pressUpView.top_cancleEditHandler = ^{
            if (weakSelf.selectBoxModel.functionType == TopFunctionTypePDFExtract||weakSelf.selectBoxModel.functionType == TopFunctionTypePDFPageAdjustment) {
                [weakSelf top_BoxCancleSelectAction];
            }else{
                [weakSelf top_CancleSelectAction];
            }
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
        [UIView animateWithDuration:0.3 animations:^{
            [self top_pressUpViewFreamChange];
        }];
    }
    if (!strongSelf.pressBootomView) {
        NSArray * sendPicArray = [strongSelf sendPicArray];
        NSArray * sendNameArray = [strongSelf sendNameArray];
        strongSelf.pressBootomView = [[TOPPhotoLongPressView alloc] initWithPressBottomFrame: CGRectMake(0, TOPScreenHeight, TOPScreenWidth, (Bottom_H)) sendPicArray:sendPicArray sendNameArray:sendNameArray];
        strongSelf.pressBootomView.selectedImgs = [strongSelf sendPicArray];
        strongSelf.pressBootomView.disableImgs = [strongSelf picArray];
        strongSelf.pressBootomView.funcArray = [strongSelf funcItems];
        strongSelf.pressBootomView.top_longPressBootomItemHandler = ^(NSInteger index) {
            [weakSelf top_InvokeMenuFunctionAtIndex:index];
        };
    }
    ///工具箱的页面提取时的底部菜单
    if (!strongSelf.boxBootomView) {
        strongSelf.boxBootomView = [[TOPFunctionChildBottomView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, TOPScreenWidth, TOPBottomSafeHeight+Bottom_H)];
        strongSelf.boxBootomView.top_clickBtnBlock = ^{
            [weakSelf top_clickBtnToExtractDoc];
        };
    }
    ///工具箱的页面调整时的底部菜单
    if (!strongSelf.boxAdjustBootomView) {
        NSArray * sendPicArray = [self sendAdjustPicArray];
        NSArray * sendTitleArray = [self sendAdjustNameArray];
        strongSelf.boxAdjustBootomView = [[TOPFunctionChildAdjustBottomView alloc] initWithFrame:CGRectMake(0, TOPScreenHeight, TOPScreenWidth, Bottom_H) sendPicArray:sendPicArray sendTitleArray:sendTitleArray];
        strongSelf.boxAdjustBootomView.disableArray = [[self picAdjustArray] mutableCopy];
        strongSelf.boxAdjustBootomView.top_clickSendBtnTag = ^(NSInteger tag) {
            [weakSelf top_InvokeMenuFunctionAtIndex:tag];
        };
    }
    ///不同入口 添加不同的底部菜单
    if (weakSelf.selectBoxModel.functionType == TopFunctionTypePDFExtract) {
        [self.view addSubview:strongSelf.boxBootomView];
        [strongSelf.boxBootomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(Bottom_H+TOPBottomSafeHeight);
            make.height.mas_equalTo(Bottom_H+TOPBottomSafeHeight);
        }];
        if (!self.isBanner) {
            [UIView animateWithDuration:0.3 animations:^{
                [self top_boxBootomViewFreamChange];
            }];
        }else{
            [self.boxBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
                make.height.mas_equalTo(Bottom_H);
            }];
        }
    }else if(weakSelf.selectBoxModel.functionType == TopFunctionTypePDFPageAdjustment){
        [self.view addSubview:strongSelf.boxAdjustBootomView];
        [strongSelf.boxAdjustBootomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(Bottom_H+TOPBottomSafeHeight);
            make.height.mas_equalTo(Bottom_H+TOPBottomSafeHeight);
        }];
        if (!self.isBanner) {
            [UIView animateWithDuration:0.3 animations:^{
                [self top_boxAdjustBootomViewFreamChange];
            }];
        }else{
            [self.boxAdjustBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
                make.height.mas_equalTo(Bottom_H);
            }];
        }
    }else{
        [self top_resetColectionViewFream];
        [self.view addSubview:strongSelf.pressBootomView];
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
    }
}

- (void)top_pressUpViewFreamChange{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    if ([window.subviews containsObject:self.pressUpView]) {
        [self.pressUpView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(window);
            make.height.mas_equalTo(TOPNavBarAndStatusBarHeight);
        }];
        [window layoutIfNeeded];
    }
}

- (void)top_pressUpViewFreamRestore{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    if ([window.subviews containsObject:self.pressUpView]) {
        [self.pressUpView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(window);
            make.top.equalTo(window).offset(-TOPNavBarAndStatusBarHeight);
            make.height.mas_equalTo(TOPNavBarAndStatusBarHeight);
        }];
        [window layoutIfNeeded];
    }
}

- (void)top_pressBootomViewFreamRestore{
    UIView *window = self.view;
    if ([window.subviews containsObject:self.pressBootomView]) {
        [self.pressBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(window);
            make.bottom.equalTo(window).offset(Bottom_H);
            make.height.mas_equalTo(Bottom_H);
        }];
        [window layoutIfNeeded];
    }
}

- (void)top_boxBootomViewFreamChange{
    UIView *window = self.view;
    [self.boxBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(window);
        make.height.mas_equalTo(TOPBottomSafeHeight+Bottom_H);
    }];
    [window layoutIfNeeded];
}

- (void)top_boxBootomViewFreamRestore{
    UIView *window = self.view;
    [self.boxBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(window);
        make.bottom.equalTo(window).offset(Bottom_H+TOPBottomSafeHeight);
        make.height.mas_equalTo(Bottom_H+TOPBottomSafeHeight);
    }];
    [window layoutIfNeeded];
}
- (void)top_boxAdjustBootomViewFreamChange{
    UIView *window = self.view;
    [self.boxAdjustBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(window);
        make.height.mas_equalTo(TOPBottomSafeHeight+Bottom_H);
    }];
    [window layoutIfNeeded];
}

- (void)top_boxAdjustBootomViewFreamRestore{
    UIView *window = self.view;
    [self.boxAdjustBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(window);
        make.bottom.equalTo(window).offset(Bottom_H+TOPBottomSafeHeight);
        make.height.mas_equalTo(Bottom_H+TOPBottomSafeHeight);
    }];
    [window layoutIfNeeded];
}
#pragma mark -- 取消选择
- (void)top_CancleSelectAction {
    [FIRAnalytics logEventWithName:@"top_CancleSelectAction" parameters:nil];
    [UIView animateWithDuration:0.3 animations:^{
        [self top_pressUpViewFreamRestore];
        [self top_pressBootomViewFreamRestore];
    } completion:^(BOOL finished) {
        [self.pressUpView  removeFromSuperview];
        [self.pressBootomView removeFromSuperview];
        self.pressBootomView = nil;
        self.pressUpView = nil;
    }];
    
    [self top_resetColectionViewFream];
    [TOPScanerShare shared].isEditing = NO;
    [self.selectedDocsIndexArray removeAllObjects];
    NSMutableArray *editArray = [NSMutableArray array];
    for (DocumentModel *model in self.homeDataArray) {
        model.selectStatus = NO;
        [editArray addObject:model];
    }
    self.collectionView.listArray = editArray;
    [self.collectionView reloadData];
    [self top_openPopGestureRecognizer];
}

#pragma mark -- 入口在工具箱时的取消选择
- (void)top_BoxCancleSelectAction{
    [UIView animateWithDuration:0.3 animations:^{
        [self top_pressUpViewFreamRestore];
        if (self.selectBoxModel.functionType == TopFunctionTypePDFExtract) {
            [self top_boxBootomViewFreamRestore];
        }
        
        if (self.selectBoxModel.functionType == TopFunctionTypePDFPageAdjustment) {
            [self top_boxAdjustBootomViewFreamRestore];
        }
    } completion:^(BOOL finished) {
        [self.pressUpView  removeFromSuperview];
        [self.boxBootomView removeFromSuperview];
        [self.boxAdjustBootomView removeFromSuperview];

        self.pressUpView = nil;
        self.boxBootomView = nil;
        self.boxAdjustBootomView = nil;
    }];
    
    [self top_BackHomeAction];
    [TOPScanerShare shared].isEditing = NO;
}
#pragma mark -- 入口在工具箱时的提取文档的功能 相当于拷贝
- (void)top_clickBtnToExtractDoc{
    [FIRAnalytics logEventWithName:@"homeChild_clickBtnToExtractDoc" parameters:nil];
    NSString *endPath = [NSString new];
    if ([self.upperPathString isEqualToString:[TOPDocumentHelper top_appBoxDirectory]]) {
        endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
    }else{
        endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:self.upperPathString];
    }
    NSString * path = endPath;
    if (path.length) {
        [self top_whenCreatDocumentAddTags:path];
        NSMutableArray *selectFiles = [self selectFileArray];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSInteger index = [TOPDocumentHelper top_maxImageNumIndexAtPath:path];
            NSInteger start = 0;
            for (int i = 0; i < selectFiles.count; i ++) {
                @autoreleasepool {
                    start ++;
                    DocumentModel *model = selectFiles[i];
                    [TOPDocumentHelper top_writeImage:model.path atIndex:(index + i) toTargetFile:path delete:NO];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self top_extractDocjumpActionWithPath:endPath];
            });
        });
    }
}
#pragma mark -- 提取文档的功能的跳转
- (void)top_extractDocjumpActionWithPath:(NSString *)endPath{
    [UIView animateWithDuration:0.3 animations:^{
        [self top_pressUpViewFreamRestore];
        if (self.selectBoxModel.functionType == TopFunctionTypePDFExtract) {
            [self top_boxBootomViewFreamRestore];
        }
        
        if (self.selectBoxModel.functionType == TopFunctionTypePDFPageAdjustment) {
            [self top_boxAdjustBootomViewFreamRestore];
        }
    } completion:^(BOOL finished) {
        [self.pressUpView  removeFromSuperview];
        [self.boxBootomView removeFromSuperview];
        [self.boxAdjustBootomView removeFromSuperview];
        
        self.pressUpView = nil;
        self.boxBootomView = nil;
        self.boxAdjustBootomView = nil;
    }];
    
    [TOPScanerShare shared].isEditing = NO;
    [TOPScanerShare shared].isRefresh = YES;
    [self.navigationController popViewControllerAnimated:NO];
    if (self.top_pdfExtractAction) {
        self.top_pdfExtractAction(endPath, self.upperPathString);
    }
}
#pragma mark --离开界面时 不退出图片的编辑状态 只改变顶部和底部视图的坐标
- (void)top_pushVAndChangeEditViewFream{
    [FIRAnalytics logEventWithName:@"top_CancleSelectAction" parameters:nil];
    [UIView animateWithDuration:0.3 animations:^{
        [self top_pressUpViewFreamRestore];
    } completion:^(BOOL finished) {
    }];
}

- (void)top_reductionEditViewFream{
    [FIRAnalytics logEventWithName:@"top_CancleSelectAction" parameters:nil];
    [UIView animateWithDuration:0.3 animations:^{
        [self top_pressUpViewFreamChange];
    } completion:^(BOOL finished) {
    }];
}
#pragma mark -- 清除编辑状态
- (void)top_clearEditState{
    [self.pressUpView  removeFromSuperview];
    [self.pressBootomView removeFromSuperview];
    self.pressBootomView = nil;
    self.pressUpView = nil;
        
    [TOPScanerShare shared].isEditing = NO;
    [self.selectedDocsIndexArray removeAllObjects];
    NSMutableArray *editArray = [NSMutableArray array];
    for (DocumentModel *model in self.homeDataArray) {
        model.selectStatus = NO;
        [editArray addObject:model];
    }
    self.collectionView.listArray = editArray;
    [self.collectionView reloadData];
}
#pragma mark -- 全选
- (void)top_AllSelectAction:(BOOL)selected {
    [FIRAnalytics logEventWithName:@"homeChild_AllSelectAction" parameters:nil];
    [self.selectedDocsIndexArray removeAllObjects];
    NSMutableArray *editArray = [NSMutableArray array];
    for (DocumentModel *model in  self.homeDataArray) {
        model.selectStatus = selected;
        [editArray addObject:model];
        if (selected) {
            [self.selectedDocsIndexArray addObject:model];
        }
    }
    [self top_RefreshViewWithSelectItem];
    self.collectionView.listArray = editArray;
    [self.collectionView reloadData];
}

#pragma mark -- 调用底部菜单事件
- (void)top_InvokeMenuFunctionAtIndex:(NSInteger)index {
    [FIRAnalytics logEventWithName:@"homeChild_InvokeMenuFunctionAtIndex" parameters:@{@"index":@(index)}];
    NSMutableArray * selectTempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if (model.selectStatus) {
            [selectTempArray addObject:model];
        }
    }
    
    if (selectTempArray.count == 0) {
        if (!self.selectBoxModel) {
            return;
        }
    }
    NSArray *funcIndexArray = [NSArray new];
    if (!self.selectBoxModel) {
        funcIndexArray = [self funcItems];
    }else{
        funcIndexArray = [self adjustFuncItems];
    }
    NSNumber *funcNum = funcIndexArray[index];
    switch ([funcNum integerValue]) {
        case TOPMenuItemsFunctionShare:
            self.emailType = 0;
            [self top_ShareTip];
            break;
        case TOPMenuItemsFunctionCopyMove:
            [self top_EditFileMethod];
            break;
        case TOPMenuItemsFunctionSaveToGallery:
            [self top_SaveToGalleryTip];
            break;
        case TOPMenuItemsFunctionPrint:
            [self top_PrintAction];
            break;
        case TOPMenuItemsFunctionDelete:
            [self top_DeleteTip];
            break;
        case TOPMenuItemsFunctionMore:
            [self top_MenuItemsMore];
            break;
        case TOPMenuItemsFunctionAddto:
            [self top_BottomViewWithAdd];
            break;
        case TOPMenuItemsFunctionExtract:
            [self top_clickBtnToExtractDoc];
            break;
        case TOPMenuItemsFunctionAdjustSave:
            [self top_AdjustSave];
            break;
        default:
            break;
    }
}
#pragma mark -- 页面调整的处理
- (void)top_AdjustSave{
    self.selectBoxModel = [TOPFunctionColletionModel new];
    [self top_changeScanPicName];
    [self top_LoadSanBoxData];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self top_pressUpViewFreamRestore];
        if (self.selectBoxModel.functionType == TopFunctionTypePDFExtract) {
            [self top_boxBootomViewFreamRestore];
        }
        
        if (self.selectBoxModel.functionType == TopFunctionTypePDFPageAdjustment) {
            [self top_boxAdjustBootomViewFreamRestore];
        }
    } completion:^(BOOL finished) {
        [self.pressUpView  removeFromSuperview];
        [self.boxBootomView removeFromSuperview];
        [self.boxAdjustBootomView removeFromSuperview];

        self.pressUpView = nil;
        self.boxBootomView = nil;
        self.boxAdjustBootomView = nil;
    }];
    
    [TOPScanerShare shared].isEditing = NO;
}
#pragma mark--编辑状态时的更多弹框
- (void)top_MenuItemsMore{
    WS(weakSelf);
    NSArray * moreArray = [NSArray new];
    NSArray * titleArray = [NSArray new];
    NSArray * iconArray = [NSArray new];
    if (self.selectedDocsIndexArray.count>1) {
        moreArray = @[@(TOPHomeMoreFunctionBatchEdit),@(TOPHomeMoreFunctionEmailMySelef),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery),@(TOPHomeMoreFunctionUpload)];
        titleArray = @[NSLocalizedString(@"topscan_batchedit", @""),
                       NSLocalizedString(@"topscan_emailmyself", @""),
                       NSLocalizedString(@"topscan_ocr", @""),
                       NSLocalizedString(@"topscan_savetogallery", @""),
                       NSLocalizedString(@"topscan_upload", @"")];
        iconArray = @[@"top_childvc_batchedit",@"top_childvc_moreemail",@"top_childvc_moreOCR",@"top_childvc_morepic",@"top_childvc_upload"];
    }else{
        moreArray = @[@(TOPHomeMoreFunctionEmailMySelef),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery),@(TOPHomeMoreFunctionUpload),@(TOPHomeMoreFunctionPicDetail)];
        titleArray = @[NSLocalizedString(@"topscan_emailmyself", @""),
                       NSLocalizedString(@"topscan_ocr", @""),
                       NSLocalizedString(@"topscan_savetogallery", @""),
                       NSLocalizedString(@"topscan_upload", @""),
                       NSLocalizedString(@"topscan_picdetailtitle", @"")];
        iconArray = @[@"top_childvc_moreemail",@"top_childvc_moreOCR",@"top_childvc_morepic",@"top_childvc_upload",@"top_photoshow_picdetail"];
    }
    [self.moreArray removeAllObjects];
    [self.moreArray addObjectsFromArray:moreArray];
    
    TOPChildMoreView * moreView = [[TOPChildMoreView alloc]initWithTitleView:[UIView new] optionsArr:titleArray iconArr:iconArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
    } selectBlock:^(NSInteger index) {
        NSNumber *num =weakSelf.moreArray[index];
        [weakSelf top_MoreViewAction:num.integerValue];
    }];
    moreView.menuItems = moreArray;
    NSArray *menuItems = [self top_headMenuSelectItems];
    moreView.headMenuItems = menuItems;
    moreView.showHeadMenu = YES;
    moreView.top_selectedHeadMenuBlock = ^(NSInteger item) {
        TOPHeadMenuModel *model = menuItems[item];
        [weakSelf top_MoreViewAction:model.functionItem];
    };
}
#pragma mark -- 文件编辑方式选择
- (void)top_EditFileMethod {
    [FIRAnalytics logEventWithName:@"homeChild_EditFileMethod" parameters:nil];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_graffitimoveto", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_MoveToFileSelect];
        [self top_pressUpViewFreamRestore];
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ocrtextcopy", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_CopyFileSelect];
        [self top_pressUpViewFreamRestore];
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
    [FIRAnalytics logEventWithName:@"homeChild_MoveToFileSelect" parameters:nil];
    WS(weakSelf);
    TOPFileTargetListViewController *targetListVC = [[TOPFileTargetListViewController alloc] init];
    targetListVC.currentFilePath = self.pathString;
    targetListVC.fileHandleType = TOPFileHandleTypeMove;
    targetListVC.fileTargetType = TOPFileTargetTypeDocument;
    __weak typeof(targetListVC) weakTargetListVC = targetListVC;
    targetListVC.top_callBackFilePathBlock = ^(NSString * _Nonnull path) {
        [weakTargetListVC dismissViewControllerAnimated:YES completion:nil];
        [weakSelf top_MoveToFileAtPath:path];
    };
    targetListVC.top_clickCancelBlock = ^{
        [weakSelf top_pressUpViewFreamChange];
    };
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:targetListVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- 移动图片
- (void)top_MoveToFileAtPath:(NSString *)path {
    if (path.length) {
        NSMutableArray *selectFiles = [self selectFileArray];
        [[TOPProgressStripeView shareInstance] top_showWithStatus:NSLocalizedString(@"topscan_moveprocessing", @"")];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSInteger index = [TOPDocumentHelper top_maxImageNumIndexAtPath:path];
            NSInteger start = 0;
            NSInteger total = selectFiles.count;
            NSMutableArray *imageNames = @[].mutableCopy;
            NSMutableArray *imageIds = @[].mutableCopy;
            for (int i = 0; i < selectFiles.count; i ++) {
                @autoreleasepool {
                    start ++;
                    DocumentModel *model = selectFiles[i];
                    NSString *fileName = [TOPDocumentHelper top_writeImage:model.path atIndex:(index + i) toTargetFile:path delete:YES];
                    CGFloat progressValue = (start * 10.0) / (total * 10.0);
                    [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:NSLocalizedString(@"topscan_moveprocessing", @"")];
                    [imageNames addObject:fileName];
                    [imageIds addObject:model.docId];
                }
            }
            [TOPEditDBDataHandler top_batchMoveImageWithIds:imageIds withImageNames:imageNames toNewDoc:[TOPFileDataManager shareInstance].fileModel.docId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [self top_moveTip];
                [self top_CancleSelectAction];
                if (selectFiles.count == self.homeDataArray.count) {
                    [self top_deleteCurrentDocument];
                    [self top_BackHomeAction];
                } else {
                    [self top_LoadSanBoxData];
                }
            });
        });
    }
}

- (void)top_moveTip{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_movesuccess", @"")];
    [SVProgressHUD dismissWithDelay:1.5];
}
#pragma mark -- 选择拷贝的终点文件夹
- (void)top_CopyFileSelect {
    [FIRAnalytics logEventWithName:@"homeChild_CopyFileSelect" parameters:nil];
    WS(weakSelf);
    TOPFileTargetListViewController *targetListVC = [[TOPFileTargetListViewController alloc] init];
    targetListVC.currentFilePath = self.pathString;
    targetListVC.fileHandleType = TOPFileHandleTypeCopy;
    targetListVC.fileTargetType = TOPFileTargetTypeDocument;
    __weak typeof(targetListVC) weakTargetListVC = targetListVC;
    targetListVC.top_callBackFilePathBlock = ^(NSString * _Nonnull path) {
        [weakTargetListVC dismissViewControllerAnimated:YES completion:nil];
        [weakSelf top_CopyFileAtPath:path];
    };
    targetListVC.top_clickCancelBlock = ^{
        [weakSelf top_pressUpViewFreamChange];
    };
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:targetListVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- 拷贝图片
- (void)top_CopyFileAtPath:(NSString *)path {
    if (path.length) {
        [FIRAnalytics logEventWithName:@"homeChild_CopyFileAtPath" parameters:@{@"path":path}];
        [self top_whenCreatDocumentAddTags:path];
        NSMutableArray *selectFiles = [self selectFileArray];
        [[TOPProgressStripeView shareInstance] top_showWithStatus:NSLocalizedString(@"topscan_copyprocessing", @"")];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSInteger index = [TOPDocumentHelper top_maxImageNumIndexAtPath:path];
            NSInteger start = 0;
            NSInteger total = selectFiles.count;
            NSMutableArray *imageNames = @[].mutableCopy;
            NSMutableArray *imageIds = @[].mutableCopy;
            for (int i = 0; i < selectFiles.count; i ++) {
                @autoreleasepool {
                    start ++;
                    DocumentModel *model = selectFiles[i];
                    NSString *fileName = [TOPDocumentHelper top_writeImage:model.path atIndex:(index + i) toTargetFile:path delete:NO];
                    CGFloat progressValue = (start * 10.0) / (total * 10.0);
                    [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:NSLocalizedString(@"topscan_copyprocessing", @"")];
                    [imageNames addObject:fileName];
                    [imageIds addObject:model.docId];
                }
            }
            [TOPEditDBDataHandler top_batchCopyImageWithIds:imageIds withImageNames:imageNames toNewDoc:[TOPFileDataManager shareInstance].fileModel.docId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [self top_copTip];
                [self top_CancleSelectAction];
                [self top_LoadSanBoxData];
            });
        });
    }
}

- (void)top_copTip{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_copysuccess", @"")];
    [SVProgressHUD dismissWithDelay:1];
}
#pragma mark -- 打印
- (void)top_PrintAction {
    [FIRAnalytics logEventWithName:@"homeChild_PrintAction" parameters:nil];
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self top_BottomViewWithPrinting:[TOPScanerShare shared].isEditing];
        }
    }];
}
#pragma mark -- 选中的文件
- (NSMutableArray *)selectFileArray {
    NSMutableArray *selectTempArray = [@[] mutableCopy];
    selectTempArray = [self.selectedDocsIndexArray mutableCopy];
    return selectTempArray;
}

#pragma mark -- 预判图片数量是否过多
- (void)top_prejudgeImages {
    static NSInteger maxNum = 30;
    NSMutableArray *imgArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if (model.selectStatus) {
            [imgArray addObject:model.imagePath];
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
        NSMutableArray * imgArray = [NSMutableArray new];
        for (DocumentModel * model in self.homeDataArray) {
            if (model.selectStatus) {
                UIImage * img = [UIImage imageWithContentsOfFile:model.imagePath];
                if (img) {
                    [imgArray addObject:img];
                }
            }
        }
       
        UIImage * resultImg = [TOPPictureProcessTool top_mergedImages:imgArray];
        NSString *showPath = [TOPDocumentHelper top_longImageFileString];
        [TOPWHCFileManager top_removeItemAtPath:showPath];
        [TOPDocumentHelper top_saveImage:resultImg atPath:showPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self top_CancleSelectAction];
            TOPShowLongImageViewController * longImgVC = [TOPShowLongImageViewController new];
            longImgVC.showPath = showPath;
            longImgVC.pathString = self.pathString;
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

#pragma mark -- new分享
- (void)top_ShareTipNew {
    NSMutableArray *shareDatas = [TOPShareFileDataHandler top_fetchShareImageData:self.homeDataArray];

    if (shareDatas.count) {
        UIWindow *window = [UIApplication sharedApplication].windows[0];
        WS(weakSelf);
        TOPShareFileView *shareFileView = [[TOPShareFileView alloc] initWithItemArray:shareDatas doneTitle:NSLocalizedString(@"topscan_share", @"") cancelBlock:^{
            if (![TOPScanerShare shared].isEditing) {
                for (DocumentModel * model in weakSelf.homeDataArray) {
                    model.selectStatus = NO;
                }
            }
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
}

#pragma mark -- 选中分享图片的质量 文件大于1M时才会弹出
- (void)top_selectShareFileQuantity:(TOPShareFileModel *)cellModel {
    NSMutableArray * shareArray = [NSMutableArray new];
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
                if (weakSelf.emailType == 1||weakSelf.emailType == 2) {
                    [weakSelf top_BottomViewWithEmail:shareArray];
                }
                if(weakSelf.emailType == 0){
                    if (cellModel.isZip) {
                        [weakSelf top_shareZipFile:shareArray];
                    } else {
                        [weakSelf top_showAcivityVC:shareArray];
                    }
                }
            }];
            NSMutableArray * sortFdArray = [NSMutableArray new];
            if ([TOPScanerShare top_childViewByType] == 2) {
               sortFdArray = [TOPDocumentHelper top_sortByNameAZ:weakSelf.homeDataArray];
            }else{
                sortFdArray = weakSelf.homeDataArray;
            }
            [window addSubview:sizeView];
            [sizeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.bottom.equalTo(window);
            }];
            sizeView.compressType = cellModel.fileType;
            sizeView.childArray = sortFdArray;
            sizeView.totalNum = cellModel.fileSize;
            sizeView.numberStr = [TOPDocumentHelper top_memorySizeStr:cellModel.fileSize];
        } else if (cellModel.fileType == TOPShareFileLongJPG) {
            [FIRAnalytics logEventWithName:@"homeChild_ShareLongImage" parameters:nil];
            [weakSelf top_prejudgeImages];
        } else if (cellModel.fileType == TOPShareFileTxt) {
            [FIRAnalytics logEventWithName:@"homeChild_shareText" parameters:nil];
            [weakSelf top_shareText];
            [weakSelf top_CancleSelectAction];
        }
    } else {
        if(cellModel.fileType == TOPShareFilePDF) {
            [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
            NSMutableArray * imgArray = [NSMutableArray new];
            NSMutableArray * selectArray = [NSMutableArray new];
            NSString * pdfName = [NSString new];
            for (DocumentModel * model in weakSelf.homeDataArray) {
                if (model.selectStatus) {
                    UIImage * img = [UIImage imageWithContentsOfFile:model.imagePath];
                    if (img) {
                        [imgArray addObject:img];
                    }
                    [selectArray addObject:model];
                }
            }
            
            if (selectArray.count == 1) {
                DocumentModel * model = selectArray[0];
                pdfName = [NSString stringWithFormat:@"%@-%@",model.fileName,model.name];
            }
            
            if (selectArray.count>1){
                DocumentModel * model = selectArray[0];
                pdfName = [NSString stringWithFormat:@"%@",model.fileName];
            }
            
            NSString * path = [TOPDocumentHelper top_creatPDF:imgArray documentName:pdfName];
            NSURL * file = [NSURL fileURLWithPath:path];
            if (file) {
                [shareArray addObject:file];
            }
            
            if (weakSelf.emailType == 1 || weakSelf.emailType == 2) {
                [weakSelf top_BottomViewWithEmail:shareArray];
            }
            
            if(weakSelf.emailType == 0){
                [weakSelf top_showAcivityVC:shareArray];
            }
        } else if(cellModel.fileType == TOPShareFileJPG){
            NSMutableArray * shareArray = [NSMutableArray new];
            NSMutableArray * selectArray = [NSMutableArray new];
            for (DocumentModel * model in weakSelf.homeDataArray) {
                if (model.selectStatus) {
                    [selectArray addObject:model];
                }
            }
            [shareArray addObjectsFromArray:[weakSelf top_getShareImgRUL:selectArray]];

            if (weakSelf.emailType == 1 || weakSelf.emailType == 2) {
                [weakSelf top_BottomViewWithEmail:shareArray];
            }
            
            if(weakSelf.emailType == 0){
                [weakSelf top_showAcivityVC:shareArray];
            }
        } else if(cellModel.fileType == TOPShareFileLongJPG) {
            [FIRAnalytics logEventWithName:@"homeChild_ShareLongImage" parameters:nil];
            [weakSelf top_drawLongImagePreview];
        } else {
            [FIRAnalytics logEventWithName:@"homeChild_shareText" parameters:nil];
            [weakSelf top_shareText];
            [weakSelf top_CancleSelectAction];
        }
    }
}


#pragma mark -- 分享弹窗
- (void)top_AddLZShareView{
    [self top_ShareTipNew];
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
                [self top_showAcivityVC:shareFiles];
            });
        });
    } else {
        [self top_showAcivityVC:shareArray];
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
#pragma mark -- 分享图片时生成分享图片的url集合
- (NSMutableArray *)top_getShareImgRUL:(NSMutableArray *)childArray{
    NSMutableArray *shareArray = @[].mutableCopy;
    for (DocumentModel * model in childArray) {
        if (model.selectStatus) {
            NSArray * pathArray = [model.path componentsSeparatedByString:@"/"];
            NSString * docName = [NSString new];
            if (pathArray.count>0) {
                docName = pathArray[pathArray.count-2];
            }
            NSString * savePath = [NSString stringWithFormat:@"%@_%@.jpg",docName,model.name];
            NSString * compressFile = [NSString new];
            if (childArray.count > 5) {
                compressFile = [TOPDocumentHelper top_saveCompressPDFImage:model.imagePath savePath:savePath maxCompression:1.0];
            }else{
                compressFile = [TOPDocumentHelper top_saveCompressImage:model.imagePath savePath:savePath maxCompression:1.0];
            }
            if (compressFile.length) {
                NSURL * file = [NSURL fileURLWithPath:compressFile];
                [shareArray addObject:file];
            }
        }
    }
    return shareArray;
}
#pragma mark -- 压缩图片分享 ：后期优化将view中的业务代码抽移至vc中
- (void)top_compressShareImage:(CGFloat)rate {
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *shareArray = @[].mutableCopy;
        for (int i = 0; i < self.homeDataArray.count; i ++) {
            DocumentModel *model = self.homeDataArray[i];
            NSString * compressFile = [TOPDocumentHelper top_saveCompressPDFImage:model.imagePath maxCompression:rate];
            if (compressFile.length) {
                NSURL * file = [NSURL fileURLWithPath:compressFile];
                [shareArray addObject:file];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self top_showAcivityVC:shareArray];
        });
    });
}

#pragma mark -- 弹出系统分享视图
- (void)top_showAcivityVC:(NSArray *)shareItems {
    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:shareItems applicationActivities:nil];
    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    activiVC.excludedActivityTypes = excludedActivityTypes;
    if (IS_IPAD) {
        activiVC.popoverPresentationController.sourceView = self.view;
        activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController: activiVC animated:YES completion:nil];
}

- (void)top_SaveToGalleryTip{
    [FIRAnalytics logEventWithName:@"homeChild_SaveToGalleryTip" parameters:nil];
    NSArray * emailArray = [TOPDocumentHelper top_getSelectPicture:self.homeDataArray];
    //保存
    WS(weakSelf);
    [TOPDocumentHelper top_saveImagePathArray:emailArray toFolder:TOPSaveToGallery_Path tipShow:YES showAlter:^(BOOL isExisted) {
        if (!isExisted) {
            [SVProgressHUD dismiss];
            [TOPDocumentHelper top_creatGalleryFolder:TOPSaveToGallery_Path];
            //提示框添加文本输入框
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

#pragma mark - 删除提示
- (void)top_DeleteTip{
    [FIRAnalytics logEventWithName:@"homeChild_DeleteTip" parameters:nil];
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

#pragma mark - 图片删除->移到回收站
- (void)top_deleteHandle {
    if (self.selectedDocsIndexArray.count > 200) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:NSLocalizedString(@"topscan_removeing", @"")];
    } else {
        [SVProgressHUD show];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *editArray = [NSMutableArray array];
        NSMutableArray *deleteIds = @[].mutableCopy;
        NSMutableArray *deleteArray = @[].mutableCopy;
        for (DocumentModel *model in  self.homeDataArray) {
            if (!model.selectStatus) {
                [editArray addObject:model];
            }else{
                [deleteArray addObject:model];
                [deleteIds addObject:model.docId];
            }
        }
        [self top_deleteImages:deleteArray];
        if (editArray.count > 0) {
            [TOPEditDBDataHandler top_deleteImagesWithIds:deleteIds];
            NSMutableArray *dataArray = [editArray mutableCopy];
            [self.selectedDocsIndexArray removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [SVProgressHUD dismiss];
                [self.boxAdjustBootomView top_changeBottonBtnState:[self picAdjustArray] withEnable:NO];
                [self.pressBootomView top_changePressViewBtnStatue:[self picArray] enabled:NO];
                [self.pressUpView top_configureSelectedCount:0];
                self.collectionView.listArray = [dataArray mutableCopy];
                self.homeDataArray = [dataArray mutableCopy];
                if (self.scanDataArray.count) {
                    self.scanDataArray = [dataArray mutableCopy];
                }
                [self.collectionView reloadData];
                [self top_takeTipOfRecycleBin];
                [self top_sumAllFileSize];
            });
        }else{
            [self top_deleteCurrentDocument];
            self.scanDataArray = @[].mutableCopy;
            [TOPScanerShare shared].isEditing = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [SVProgressHUD dismiss];
                [self.pressUpView  removeFromSuperview];
                [self.pressBootomView removeFromSuperview];
                self.pressBootomView = nil;
                self.pressUpView = nil;
                [self top_BackHomeAction];
            });
        }
    });
}

- (void)top_deleteImages:(NSArray *)dataArray {
    if (dataArray) {
        DocumentModel *tempModel = dataArray[0];
        BOOL newDoc = [TOPBinDataHandler top_needCreateBinDocument:tempModel.docId];
        NSMutableArray *filePathArr = @[].mutableCopy;
        for (int i = 0; i < dataArray.count; i ++ ) {
            BOOL isNew = newDoc;
            if (i>0) {
                isNew = NO;
            }
            DocumentModel *model = dataArray[i];
            NSString *binImgPath = [TOPBinHelper top_moveImageToBin:model.path atNewDoc:isNew];//图片在回收站的路径
            [filePathArr addObject:binImgPath];
            CGFloat moveProgressValue = i / (dataArray.count * 1.0);
            [[TOPProgressStripeView shareInstance] top_showProgress:moveProgressValue withStatus:NSLocalizedString(@"topscan_removeing", @"")];
        }
        TOPImageFile *imgFile = [TOPDBQueryService top_imageFileById:tempModel.docId];
        if (filePathArr.count) {
            if (newDoc) {
                NSString *binImgPath = filePathArr[0];
                NSString *docPath = [TOPWHCFileManager top_directoryAtPath:binImgPath];
                [TOPBinEditDataHandler top_saddBinDocWithParentId:imgFile.pathId atPath:docPath];
            } else {
                NSMutableArray *fileArr = @[].mutableCopy;
                for (NSString *binImgPath in filePathArr) {
                    NSString *fileName = [TOPWHCFileManager top_fileNameAtPath:binImgPath suffix:YES];
                    [fileArr addObject:fileName];
                }
                TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:imgFile.parentId];
                [TOPBinEditDataHandler top_addBinImageAtDocument:fileArr WithId:doc.pathId];
            }
        }
    }
}

#pragma mark -- 删除当前文档
- (void)top_deleteCurrentDocument {
    [TOPWHCFileManager top_removeItemAtPath:self.pathString];
    [TOPEditDBDataHandler top_deleteDocumentWithId:self.docModel.docId];
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

- (void)top_AllShare{
    NSMutableArray * tempPathArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        model.selectStatus = YES;
        [tempPathArray addObject:model.imagePath];
    }
    [self top_AddLZShareView];
}

#pragma mark -- 计算选中图片大小
- (CGFloat)top_calculatePicSize {
    CGFloat memorySize = [TOPDocumentHelper top_calculateSelectImagesSize:self.homeDataArray];
    return memorySize;
}

- (void)top_ShareTip{
    [FIRAnalytics logEventWithName:@"homeChild_ShareTip" parameters:nil];
    [self top_AddLZShareView];
    [self top_calculateSelectNumber];
}

- (void)top_calculateSelectNumber{
    NSMutableArray * tempPathArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if (model.selectStatus) {
            [tempPathArray addObject:model.imagePath];
        }
    }
    NSString * totalSize = [TOPDocumentHelper top_getFileTotalMemorySize:tempPathArray];
    self.totalSizeString = totalSize;
}

- (void)top_ShareShowTip{
    [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
    CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
    CGFloat totalNum = [self top_calculatePicSize];
    if (freeSize<totalNum/1024.0/1024.0+5) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self top_changeScanPicName];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_jumpToEditPDFVC];
        });
    });
}

#pragma mark -- PDF编辑预览
- (void)top_jumpToEditPDFVC {
    WS(weakSelf);
    TOPEditPDFViewController * pdfVC = [[TOPEditPDFViewController alloc] init];
    pdfVC.docModel = self.docModel;
    pdfVC.filePath = self.pathString;
    pdfVC.imagePathArr = [self selectImages];
    if ([TOPScanerShare shared].isEditing) {
        [self top_pushVAndChangeEditViewFream];
    }
    pdfVC.top_backBtnAction = ^{
        if ([[TOPFileDataManager shareInstance].allListModel.tagNum integerValue]>=10&& [TOPScanerShare top_saveInterstitialAdCount]>=10) {
            if (![TOPScanerShare top_saveNewScoreState]) {
                [weakSelf top_showNewScoreView];
                [TOPScanerShare top_writeSaveNewScoreState:YES];
            }
        }
    };
    pdfVC.top_editDocNameBlock = ^(NSString * _Nonnull path) {
        NSString *name = [TOPWHCFileManager top_fileNameAtPath:path suffix:YES];
        [weakSelf.showBtn setTitle:name forState:UIControlStateNormal];
        weakSelf.title = name;
        weakSelf.pathString = path;
    };
    pdfVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pdfVC animated:YES];
}
#pragma mark -- pdf预览界面返回是弹出评论框
- (void)top_showNewScoreView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    TOPNewScoreView * scoreView = [[TOPNewScoreView alloc]init];
    scoreView.top_submitScore = ^(NSInteger score) {
        if (score == 5) {
            NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", @"1531265666"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
        }else{
            TOPSuggestionsVC * suVC = [TOPSuggestionsVC new];
            [self.navigationController pushViewController:suVC animated:YES];
        }
    };
    [keyWindow addSubview:scoreView];
    [scoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(keyWindow);
    }];
}
#pragma mark--返回界面的操作
- (void)top_BackHomeAction{
    if (![self.addType isEqualToString:@"add"]) {
        [self top_BackNextAction];
    }else{
        if (self.scanDataArray.count>0) {
            [SVProgressHUD show];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        }
        WS(weakSelf);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf top_changeScanPicName];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if (weakSelf.backType == TOPHomeChildViewControllerBackTypeDismiss) {
                    if (![weakSelf isBeingDismissed]) {
                        [weakSelf.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:nil];
                    }
                }else if(weakSelf.backType == TOPHomeChildViewControllerBackTypePopFolder){
                    NSMutableArray * tempArray = [NSMutableArray new];
                    for (UIViewController * vc in weakSelf.navigationController.viewControllers) {
                        if ([vc isKindOfClass:[TOPNextFolderViewController class]]) {
                            [tempArray addObject:vc];
                        }
                    }
                    TOPNextFolderViewController * backVC = tempArray.lastObject;
                    [weakSelf.navigationController popToViewController:backVC animated:YES];
                }else if(weakSelf.backType ==TOPHomeChildViewControllerBackTypePopRoot){
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                }else if(weakSelf.backType ==TOPHomeChildViewControllerBackTypePopCollList){
                    NSMutableArray * tempArray = [NSMutableArray new];
                    for (UIViewController * vc in weakSelf.navigationController.viewControllers) {
                        if ([vc isKindOfClass:[TOPFunctionColletionListVC class]]) {
                            [tempArray addObject:vc];
                        }
                    }
                    TOPFunctionColletionListVC * backVC = tempArray.lastObject;
                    [TOPScanerShare shared].isRefresh = YES;//让backVC刷新数据
                    [weakSelf.navigationController popToViewController:backVC animated:YES];
                }else{
                    if (weakSelf.top_backBtnAction) {
                        weakSelf.top_backBtnAction();
                    }
                    if (weakSelf.top_backScreenshotAction) {
                        weakSelf.top_backScreenshotAction();
                    }
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            });
        });
    }
}

- (void)top_BackNextAction{
    if (self.scanDataArray.count>0) {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf top_changeScanPicName];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (weakSelf.top_backBtnAction) {
                weakSelf.top_backBtnAction();
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    });
}

#pragma mark -- 开启排序模式
- (void)top_ManualSortingPattern {
    self.tabbarBottomView.hidden = YES;
    [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight-self.adViewH);
    }];
    [self top_showManualSortingHeader];
}

#pragma mark -- 退出排序模式
- (void)top_CancelManualSorting {
    [TOPScanerShare shared].isManualSorting = NO;
    self.tabbarBottomView.hidden = NO;
    [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H+self.adViewH));
    }];
    [self top_hiddenManualSortingHeader];
}

#pragma mark -- 显示排序模式的导航栏视图
- (void)top_showManualSortingHeader {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.manualSortingHeaderView];
    if (![TOPScanerShare top_firstManualSorting]) {
        TOPChildTipView * tipView = [[TOPChildTipView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        [window addSubview:tipView];
    }
}

#pragma mark -- 隐藏排序模式的导航栏视图
- (void)top_hiddenManualSortingHeader {
    [self.manualSortingHeaderView removeFromSuperview];
    self.manualSortingHeaderView = nil;
}

#pragma mark--底部视图的点击
- (void)top_BottomViewWithAdd{
    [FIRAnalytics logEventWithName:@"homeChild_BottomViewWithAdd" parameters:nil];
    TOPEnterCameraType cameraTpye = TOPShowDocumentCameraType;
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = self.pathString;
    camera.fileType = cameraTpye;;
    camera.dataArray = self.homeDataArray;
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    WS(weakSelf);
    camera.top_sCamerDissmissToReloadData = ^(NSArray * _Nonnull assets) {
        [weakSelf top_saveAssetsRefreshUI:assets];
    };
    
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (NSInteger)top_maxPicNumIndex {
    NSArray *imageArray = [TOPDocumentHelper top_getJPEGFile:self.pathString];
    if (imageArray.count) {
        NSMutableArray *temp = @[].mutableCopy;
        for (NSString *picName in imageArray) {
            NSString *numberIndex = [picName substringFromIndex:14];
            [temp addObject:numberIndex];
        }
        NSInteger maxNum = [[temp valueForKeyPath:@"@max.integerValue"] integerValue];
        if (maxNum >= 10000) {
            maxNum = maxNum - 10000;
        } else if (maxNum >= 1000) {
            maxNum = maxNum - 1000;
        }
        return maxNum + 1;
    }
    return 0;
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
- (void)top_BottomViewWithShare{
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self top_AllShare];
        }
    }];
}

- (void)top_BottomViewWithEmail:(NSMutableArray *)emailArray{
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
    if (self.emailType == 1) {
        [self top_ShowMailCompose:self.emailModel.toEmail array:emailArray];
    }
    if (self.emailType == 2) {
        if (self.emailModel.myselfEmail.length>0) {
            [self top_ShowMailCompose:self.emailModel.myselfEmail array:emailArray];
        }else{
            self.emailArray = emailArray;
            [self top_ShowEmailArray];
        }
    }
}

- (void)top_ShowMailCompose:(NSString *)email array:(NSMutableArray *)emailArray{
    MFMailComposeViewController * mailCompose = [[MFMailComposeViewController alloc]init];
    mailCompose.mailComposeDelegate = self;
    NSArray * toRecipients = [NSArray arrayWithObjects:email,nil];
    [mailCompose setToRecipients:toRecipients];
    [mailCompose setSubject:self.emailModel.subject];
    [mailCompose setMessageBody:self.emailModel.body isHTML:YES];

    if (emailArray.count>0) {
        if (self.pdfType == 1) {
            for (int i = 0; i<emailArray.count; i++) {
                NSData * imgData = [NSData dataWithContentsOfURL:emailArray[i]];
                NSURL * imgPath = emailArray[i];
                NSString * photoName = [TOPDocumentHelper top_decodeFromPercentEscapeString:[imgPath.absoluteString componentsSeparatedByString:@"/"].lastObject];
                if (imgData) {
                    [mailCompose addAttachmentData:imgData mimeType:@"image" fileName:photoName];
                }
            }
            [self presentViewController:mailCompose animated:YES completion:^{
                
            }];
        }
        
        if (self.pdfType == 0) {
            for (int i = 0; i<emailArray.count; i++) {
                NSData * pdfData = [NSData dataWithContentsOfURL:emailArray[i]];
                NSURL * pdfPath = emailArray[i];
                NSString * photoName = [TOPDocumentHelper top_decodeFromPercentEscapeString:[pdfPath.absoluteString componentsSeparatedByString:@"/"].lastObject];
                if (pdfData) {
                    [mailCompose addAttachmentData:pdfData mimeType:@"application/pdf" fileName:photoName];
                }
            }
            [self presentViewController:mailCompose animated:YES completion:^{
                
            }];
        }
    }
}

- (void)top_ClickToHide{
    [self top_RemoveCurrentView];
}

- (void)top_RemoveCurrentView{
    [UIView animateWithDuration:0.3 animations:^{
        [self.coverView removeFromSuperview];
        [self.emailAgainView removeFromSuperview];
        [self.addFolderView removeFromSuperview];
        [self.passwordView removeFromSuperview];
        self.coverView = nil;
        self.emailAgainView = nil;
        self.addFolderView = nil;
        self.passwordView = nil;
    }];
}

- (void)top_ShowEmailArray{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:self.coverView];
    [self top_markupCoverMask];
    [window addSubview:self.emailAgainView];
}

- (void)top_BottomViewWithPrinting:(BOOL)isEdit{
    NSMutableArray * printingArray = [NSMutableArray new];
    if (isEdit) {
        printingArray = self.selectedDocsIndexArray;
    }else{
        printingArray = self.homeDataArray;
    }
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
        NSMutableArray * imgArray = [NSMutableArray new];
        NSString * pdfName = [NSString new];
        for (DocumentModel * model in printingArray) {
            UIImage * img = [UIImage imageWithContentsOfFile:model.imagePath];
            if (img) {
                [imgArray addObject:img];
            }
            pdfName = [NSString stringWithFormat:@"%@-1",model.fileName];
        }
        NSString * path = [TOPDocumentHelper top_creatNOPasswordPDF:imgArray documentName:pdfName progress:^(CGFloat myProgress) {
            [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [self top_showPrintVC:path];
        });
    });
}

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

#pragma mark -- more 菜单
- (void)top_BottomViewWithMore{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    WS(weakSelf);
    NSArray * moreArray = [NSArray new];
    NSArray * titleArray = [NSArray new];
    NSArray * iconArray = [NSArray new];
    NSString * collectionIcon = [NSString new];
    if (self.docModel.collectionstate) {
        collectionIcon = @"top_childvc_morehasCollected";
    }else{
        collectionIcon = @"top_childvc_moreCollection";
    }
    if (self.homeDataArray.count>1) {
        moreArray = @[@(TOPHomeMoreFunctionBatchEdit),@(TOPHomeMoreFunctionEmailMySelef),@(TOPHomeMoreFunctionUpload),@(TOPHomeMoreFunctionDocCollection),@(TOPHomeMoreFunctionDocRemaind),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery),@(TOPHomeMoreFunctionManualSorting),@(TOPHomeMoreFunctionUserDefinedSize)];
    }else{
        moreArray = @[@(TOPHomeMoreFunctionEmailMySelef),@(TOPHomeMoreFunctionDocRemaind),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionDocCollection),@(TOPHomeMoreFunctionSaveToGrallery),@(TOPHomeMoreFunctionUpload),@(TOPHomeMoreFunctionManualSorting),@(TOPHomeMoreFunctionUserDefinedSize)];
    }
    if (self.homeDataArray.count>1) {
        titleArray = @[NSLocalizedString(@"topscan_batchedit", @""),
                       NSLocalizedString(@"topscan_emailmyself", @""),
                       NSLocalizedString(@"topscan_upload", @""),
                       NSLocalizedString(@"topscan_childimportant", @""),
                       NSLocalizedString(@"topscan_homemoredocremind", @""),
                       NSLocalizedString(@"topscan_ocr",@""),
                       NSLocalizedString(@"topscan_savetogallery", @""),
                       NSLocalizedString(@"topscan_manualsorting", @""),
                       NSLocalizedString(@"topscan_userdefinedsize", @"")];
        iconArray = @[@"top_childvc_batchedit",@"top_childvc_moreemail",@"top_childvc_upload",collectionIcon,@"top_childvc_morebell",@"top_childvc_moreOCR",@"top_childvc_morepic",@"top_childvc_manualSorting",@"top_childvc_userdefine_filesize"];
    }else{
        titleArray = @[NSLocalizedString(@"topscan_emailmyself", @""),
                       NSLocalizedString(@"topscan_homemoredocremind", @""),
                       NSLocalizedString(@"topscan_ocr",@""),
                       NSLocalizedString(@"topscan_childimportant", @""),
                       NSLocalizedString(@"topscan_savetogallery", @""),
                       NSLocalizedString(@"topscan_upload", @""),
                       NSLocalizedString(@"topscan_manualsorting", @""),
                       NSLocalizedString(@"topscan_userdefinedsize", @"")];
        iconArray = @[@"top_childvc_moreemail",@"top_childvc_morebell",@"top_childvc_moreOCR",collectionIcon,@"top_childvc_morepic",@"top_childvc_upload",@"top_childvc_manualSorting",@"top_childvc_userdefine_filesize"];
    }
    
    
    [self.moreArray removeAllObjects];
    [self.moreArray addObjectsFromArray:moreArray];
    
    TOPChildMoreView * moreView = [[TOPChildMoreView alloc]initWithTitleView:[UIView new] optionsArr:titleArray iconArr:iconArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
        weakSelf.showMoreView = NO;
    } selectBlock:^(NSInteger index) {
        NSNumber *num =weakSelf.moreArray[index];
        [weakSelf top_MoreViewAction:num.integerValue];
    }];
    moreView.menuItems = moreArray;
    NSArray *menuItems = [self top_headMenuItems];
    moreView.docModel = self.docModel;
    moreView.headMenuItems = menuItems;
    moreView.showHeadMenu = YES;
    moreView.top_selectedHeadMenuBlock = ^(NSInteger item) {
        TOPHeadMenuModel *model = menuItems[item];
        [weakSelf top_MoreViewAction:model.functionItem];
    };
    [window addSubview:moreView];
}

- (NSArray *)top_headMenuItems {
    BOOL showVip = NO;
    NSDictionary *dic1 = @{
        @"functionItem":@(TOPHomeMoreFunctionImportFromGallery),
        @"title":NSLocalizedString(@"topscan_importpic", @""),
        @"iconName":@"top_menu_importPic",
        @"showVip":@(showVip)};
    NSDictionary *dic2 = @{
        @"functionItem":@(TOPHomeMoreFunctionDocTag),
        @"title":NSLocalizedString(@"topscan_doctag", @""),
        @"iconName":@"top_menu_docTag",
        @"showVip":@(showVip)};
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
    NSDictionary *dic6 = @{
        @"functionItem":@(TOPHomeMoreFunctionDownDriveFile),
        @"title":NSLocalizedString(@"topscan_drivedownloadfiles", @""),
        @"iconName":@"top_menu_download",
        @"showVip":@(showVip)};
    showVip = ![TOPPermissionManager top_enableByCollageSave];
    NSDictionary *dic5 = @{
        @"functionItem":@(TOPHomeMoreFunctionPicCollage),
        @"title":NSLocalizedString(@"topscan_collage", @""),
        @"iconName":@"top_menu_collage",
        @"showVip":@(showVip)};
    

    
    NSArray *dics = @[dic1, dic2, dic6,dic3, dic4, dic5];
    NSMutableArray *temp = @[].mutableCopy;
    for (NSDictionary *dic in dics) {
        TOPHeadMenuModel *item1 = [[TOPHeadMenuModel alloc] init];
        item1.functionItem = [dic[@"functionItem"] integerValue];
        item1.title = dic[@"title"];
        item1.iconName = dic[@"iconName"];
        item1.showVip = [dic[@"showVip"] boolValue];
        [temp addObject:item1];
    }
    return temp;
}

- (NSArray *)top_headMenuSelectItems {
    BOOL showVip = NO;
    NSDictionary *dic1 = @{
        @"functionItem":@(TOPHomeMoreFunctionPrint),
        @"title":NSLocalizedString(@"topscan_printing", @""),
        @"iconName":@"top_menu_print_colorful",
        @"showVip":@(showVip)};
    NSDictionary *dic2 = @{
        @"functionItem":@(TOPHomeMoreFunctionFax),
        @"title":NSLocalizedString(@"topscan_fax", @""),
        @"iconName":@"top_menu_fax_colorful",
        @"showVip":@(showVip)};
    showVip = ![TOPPermissionManager top_enableByCollageSave];
    NSDictionary *dic3 = @{
        @"functionItem":@(TOPHomeMoreFunctionPicCollage),
        @"title":NSLocalizedString(@"topscan_collage", @""),
        @"iconName":@"top_menu_collage",
        @"showVip":@(showVip)};
    showVip = NO;
    NSDictionary *dic4 = @{
        @"functionItem":@(TOPHomeMoreFunctionPDF),
        @"title":NSLocalizedString(@"topscan_pdf", @""),
        @"iconName":@"top_menu_pdf",
        @"showVip":@(showVip)};
    NSArray *dics = @[dic1, dic2, dic3, dic4];
    NSMutableArray *temp = @[].mutableCopy;
    for (NSDictionary *dic in dics) {
        TOPHeadMenuModel *item1 = [[TOPHeadMenuModel alloc] init];
        item1.functionItem = [dic[@"functionItem"] integerValue];
        item1.title = dic[@"title"];
        item1.iconName = dic[@"iconName"];
        item1.showVip = [dic[@"showVip"] boolValue];
        [temp addObject:item1];
    }
    return temp;
}
#pragma mark -- 底部更多视图的点击
- (void)top_MoreViewAction:(NSInteger)index{
    switch (index) {
        case TOPHomeMoreFunctionEmailMySelef:
            [self top_MoreViewEmailMySelef:[TOPScanerShare shared].isEditing];
            break;
        case TOPHomeMoreFunctionSaveToGrallery:
            [self top_MoreViewSaveGallery:[TOPScanerShare shared].isEditing];
            break;
        case TOPHomeMoreFunctionviewby:
            [self top_MoreViewSortBy];
            break;
        case TOPHomeMoreFunctionHidePage:
            [self top_MoreViewHideOrShowDetail];
            break;
        case TOPHomeMoreFunctionFax:
            [self top_MoreViewFax:[TOPScanerShare shared].isEditing];
            break;
        case TOPHomeMoreFunctionPrint:
            [self top_PrintAction];
            break;
        case TOPHomeMoreFunctionManualSorting:
            [self  top_MoreViewManualSorting];
            break;
        case TOPHomeMoreFunctionUserDefinedSize:
            [self  top_MoreViewUserDefinedSize];
            break;
        case TOPHomeMoreFunctionImportFromGallery:
            [self  top_MoreViewImportPic];
            break;
        case TOPHomeMoreFunctionDocTag:
            [self  top_MoreViewSetTag];
            break;
        case TOPHomeMoreFunctionPicCollage:
            [self  top_MoreViewCollage];
            break;
        case TOPHomeMoreFunctionSetLock:
            [self  top_MoreViewSetLock];
            break;
        case TOPHomeMoreFunctionUnLock:
            [self  top_MoreViewUnlock];
            break;
        case TOPHomeMoreFunctionPDFPassword:
            [self  top_MoreViewPDFPassword];
            break;
        case TOPHomeMoreFunctionBatchEdit:
            [self top_showCropTip];
            break;
        case TOPHomeMoreFunctionPDF:
            [self top_ShareShowTip];
            break;
        case TOPHomeMoreFunctionUpload:
            [self top_uploadDrive];
            break;
        case TOPHomeMoreFunctionDownDriveFile:
            [self top_downDriveFile];
            break;
        case TOPHomeMoreFunctionDocRemaind:
            [self top_setDocReminder];
            break;
        case TOPHomeMoreFunctionOCR:
            if (!self.selectedDocsIndexArray.count) {
                for (DocumentModel * model in self.homeDataArray) {
                    model.selectStatus = YES;
                }
            }
            [self top_shareText];
            [self top_CancleSelectAction];
            break;
        case TOPHomeMoreFunctionPicDetail:
            [self top_picDetail];
            break;
        case TOPHomeMoreFunctionDocCollection:
            if (self.docModel.collectionstate) {
                self.docModel.collectionstate = 0;
            }else{
                self.docModel.collectionstate = 1;
            }
            [TOPEditDBDataHandler top_editDocumentCollectionState:self.docModel.collectionstate withId:self.docModel.docId];
            break;
        default:
            break;
    }
}
#pragma mark -- 图片的详细信息展示的数据
- (NSArray *)top_creatPicDetailData{
    NSArray * arr = [NSArray new];
    DocumentModel * picModel = [DocumentModel new];
    if (self.selectedDocsIndexArray.count) {
        picModel = self.selectedDocsIndexArray[0];
        if ([TOPWHCFileManager top_isExistsAtPath:picModel.path]) {
            UIImage * picImg = [UIImage imageWithContentsOfFile:picModel.path];
            NSString * imgLength = [TOPDocumentHelper top_memorySizeStr:[[TOPWHCFileManager top_sizeOfFileAtPath:picModel.path] floatValue]];
            NSString * sizeString = [NSString stringWithFormat:@"%dx%d",(int)picImg.size.width,(int)picImg.size.height];
    
            NSDictionary * dic1 = @{NSLocalizedString(@"topscan_size", @""):[NSString stringWithFormat:@"%@, %@",imgLength,sizeString]};
            NSDictionary * dic2 = @{NSLocalizedString(@"topscan_piccreattime", @""):picModel.picCreateDate};
            NSDictionary * dic3 = @{NSLocalizedString(@"topscan_picupdatetime", @""):[TOPAppTools timeStringFromDate:[TOPDBDataHandler top_updateTimeOfFile:picModel.path]]};
            arr = @[dic1,dic2,dic3];
        }
    }
    return arr;
}
#pragma mark -- 图片的详细信息
- (void)top_picDetail{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * tempArray = [self top_creatPicDetailData];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *window = [UIApplication sharedApplication].windows[0];
            TOPPicDetailView * picDetailView = [[TOPPicDetailView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight) dataArray:tempArray];
            if (self.selectedDocsIndexArray.count) {
                DocumentModel *picModel = self.selectedDocsIndexArray[0];
                picDetailView.imgPath = picModel.path;
            }
            [window addSubview:picDetailView];
            [picDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.bottom.equalTo(window);
            }];
        });
    });
}
#pragma mark -- 设置文档提醒
- (void)top_setDocReminder{
    TOPDocumentRemindVC * remindVC = [TOPDocumentRemindVC new];
    remindVC.docModel = self.docModel;
    remindVC.upperPathString = self.upperPathString;
    remindVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:remindVC animated:YES];
}
#pragma mark -- 网盘上传
- (void)top_uploadDrive{
    [FIRAnalytics logEventWithName:@"childuploadDrive" parameters:nil];
    TOPLoadSelectDriveViewController *uploadVC = [[TOPLoadSelectDriveViewController alloc] init];
    NSMutableArray * tempArray = [NSMutableArray new];
    if (self.selectedDocsIndexArray.count) {
        [self.selectedDocsIndexArray enumerateObjectsUsingBlock:^(DocumentModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        }];
        
    }
    if ([TOPScanerShare shared].isEditing) {
        [tempArray addObjectsFromArray:self.selectedDocsIndexArray];
        uploadVC.isSingleUpload = YES;
    }else{
        [tempArray addObject:self.docModel];
        uploadVC.isSingleUpload = NO;
    }
    uploadVC.uploadDatas = [NSMutableArray arrayWithArray:tempArray];
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:uploadVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- uploadDrive 下载第三方网盘
- (void)top_downDriveFile{
    [FIRAnalytics logEventWithName:@"childdownloadDrive" parameters:nil];
    TOPLoadSelectDriveViewController *uploadVC = [[TOPLoadSelectDriveViewController alloc] init];
    uploadVC.openDrivetype = TOPDriveOpenStyleTypeDownFile;
    uploadVC.downloadFileSavePath = self.docModel.path;
    uploadVC.docId = self.docModel.docId;
    uploadVC.downloadFileType = TOPDownloadFileToDriveAddPathTypeHomeChild;

    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:uploadVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark -- PDF 密码
- (void)top_MoreViewPDFPassword {
    if (![TOPPermissionManager top_enableByPDFPassword]) {
        [self top_subscriptionService];
        return;
    }
    if ([[TOPScanerShare top_pdfPassword] length] > 0) {
        [TOPScanerShare top_writePDFPassword:@""];
        [[TOPCornerToast shareInstance] makeToast:[NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"]];
    } else {
        [self top_showPasswordView];
    }
}

- (void)top_showCropTip {
    BOOL showTip = [[NSUserDefaults standardUserDefaults] boolForKey:@"cropTipAsk"];
    if (!showTip) {
        UIWindow *window = [UIApplication sharedApplication].windows[0];
        WS(weakSelf);
        TOPCropTipView *tipView = [[TOPCropTipView alloc] initWithTipMessage:NSLocalizedString(@"topscan_croptipmsg", @"")];
        tipView.okBlock = ^{
            [weakSelf top_MoreViewBatchEdit];
        };
        [window addSubview:tipView];
        [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(window);
        }];
    } else {
        [self top_MoreViewBatchEdit];
    }
}

- (void)top_MoreViewBatchEdit{
    WS(weakSelf);
    NSMutableArray * tempArray = [NSMutableArray new];
    BOOL isAllData = NO;
    if ([TOPScanerShare shared].isEditing) {
        [tempArray addObjectsFromArray:self.selectedDocsIndexArray];
    }else{
        tempArray = self.homeDataArray;
    }
    if (tempArray.count == self.homeDataArray.count) {
        isAllData = YES;
    }
    [self top_CancleSelectAction];
    TOPHomeChildBatchViewController * batchVC = [TOPHomeChildBatchViewController new];
    batchVC.top_dataChangeAndLoadData = ^{
        [weakSelf top_LoadSanBoxData];
    };
    batchVC.dataArray = tempArray;
    batchVC.isAllData = isAllData;
    batchVC.addType = self.addType;
    batchVC.childVCPath = self.pathString;
    batchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:batchVC animated:YES];
}
#pragma mark -- 创建密码
- (void)top_showPasswordView {
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    if (!_coverView) {
        self.coverView.alpha = 0.5;
        [keyWindow addSubview:self.coverView];
        [self top_markupCoverMask];
    }
    if (!_passwordView) {
        self.passwordView.actionType = TOPHomeMoreFunctionPDFPassword;
        [keyWindow addSubview:self.passwordView];
    }
}

- (void)top_addPDFPassword:(NSString *)password {
    [TOPScanerShare top_writePDFPassword:password];
    [[TOPCornerToast shareInstance] makeToast:[NSString stringWithFormat:@"%@ %@",[NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"], password]];
}

#pragma mark -- 设置文档密码
- (void)top_MoreViewSetLock{
    [FIRAnalytics logEventWithName:@"homeChild_MoreViewSetLock" parameters:nil];
    NSString * passwordString = [TOPDocumentHelper top_getDocPasswordPathString:self.pathString];
    if (![TOPWHCFileManager top_isExistsAtPath:passwordString]) {
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
}
#pragma mark -- 解除密码
- (void)top_MoreViewUnlock{
    [FIRAnalytics logEventWithName:@"homeChild_MoreViewUnlock" parameters:nil];
    NSString * passwordString = [TOPDocumentHelper top_getDocPasswordPathString:self.pathString];
    if ([TOPWHCFileManager top_isExistsAtPath:passwordString]) {
        [TOPWHCFileManager top_removeItemAtPath:passwordString];
        [TOPScanerShare shared].isRefresh = YES;
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_successfullyunlocked", @"")];
    }
}
#pragma mark -- 拼图
- (void)top_MoreViewCollage {
    [FIRAnalytics logEventWithName:@"homeChild_MoreViewCollage" parameters:nil];
    WS(weakSelf);
    if (self.scanDataArray.count>0) {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self top_changeScanPicName];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if ([TOPScanerShare shared].isEditing) {
                [self top_pushVAndChangeEditViewFream];
            }
            TOPCollageViewController *collageVC = [[TOPCollageViewController alloc] init];
            collageVC.docModel = self.docModel;
            collageVC.filePath = self.pathString;
            collageVC.imagePathArr = [self selectImages];
            collageVC.top_backBtnAction = ^{
            };
            collageVC.top_finishBtnAction = ^{
                if ([TOPScanerShare shared].isEditing) {
                    [weakSelf top_clearEditState];
                }
            };
            collageVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:collageVC animated:YES];
        });
    });
}

- (NSArray *)selectImages {
    NSMutableArray *imgs = @[].mutableCopy;
    for (DocumentModel *model in self.selectedDocsIndexArray) {
        [imgs addObject:model.photoName];
    }
    return [NSArray arrayWithArray:imgs];
}

#pragma mark -- 设置标签
- (void)top_MoreViewSetTag {
    [FIRAnalytics logEventWithName:@"homeChild_MoreViewSetTag" parameters:nil];
    NSMutableArray * dataArray = [NSMutableArray new];
    DocumentModel * docModel = self.docModel;
    if (docModel) {
        [dataArray addObject:docModel];
    }
    WS(weakSelf);
    TOPSetTagViewController * tagVC = [[TOPSetTagViewController alloc]init];
    tagVC.top_saveFinishAction = ^{
        weakSelf.docModel.tagsArray = [TOPDataModelHandler top_getDocumentTagsArrayWithPath:weakSelf.docModel.path];
    };
    tagVC.dataArray = dataArray;
    tagVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tagVC animated:YES];
}

#pragma mark -- 从图库导入
- (void)top_MoreViewImportPic {
    [FIRAnalytics logEventWithName:@"ImportPic" parameters:nil];
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
    [self.addNewImageArr removeAllObjects];
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
    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:(i + [self top_maxPicNumIndex])],TOP_TRJPGPathSuffixString];
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
        scamerBatch.pathString = self.pathString;
        scamerBatch.fileType = TOPShowDocumentCameraType;
        scamerBatch.backType = TOPHomeChildViewControllerBackTypeDismiss;
        scamerBatch.dataArray = self.homeDataArray;
        
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
        batch.pathString = self.pathString;
        batch.batchArray = [photos mutableCopy];
        batch.dataArray = self.homeDataArray;
        batch.fileType = TOPShowDocumentCameraType;
        batch.backType = TOPHomeChildViewControllerBackTypeDismiss;
        TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:batch];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark -- 删除文档警告
- (void)top_deleteDocAlert {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"topscan_deletecurrentdoc", @"") preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf top_deleteDocHandle];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:archiveAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)top_deleteDocHandle {
    if (self.homeDataArray.count > 200) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:NSLocalizedString(@"topscan_removeing", @"")];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self top_deleteDocumentToBin:self.docModel];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [self top_BackHomeAction];
        });
    });
}

#pragma mark -- 移动文档到回收站
- (void)top_deleteDocumentToBin:(DocumentModel *)model {
    [TOPWHCFileManager top_removeItemAtPath:model.docPasswordPath];
    NSString *binDocPath = [TOPBinHelper top_moveDocumentToBin:model.path progress:^(CGFloat moveProgressValue) {
        [[TOPProgressStripeView shareInstance] top_showProgress:moveProgressValue withStatus:NSLocalizedString(@"topscan_removeing", @"")];
    }];
    RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:model.docId];
    if (images.count) {
        TOPImageFile *img = images[0];
        [TOPBinEditDataHandler top_saddBinDocWithParentId:img.pathId atPath:binDocPath];
    }
    [self top_deleteCurrentDocument];
}

#pragma mark -- 自定义文件大小
- (void)top_MoreViewUserDefinedSize {
    [FIRAnalytics logEventWithName:@"UserDefinedSize" parameters:nil];
    [self top_AddUserDefinedFileSizeView];
}

#pragma mark -- 拖拽排序
- (void)top_MoreViewManualSorting {
    [FIRAnalytics logEventWithName:@"ManualSorting" parameters:nil];
    [TOPScanerShare shared].isManualSorting = YES;
    [self top_ManualSortingPattern];
}

#pragma mark -- DeleteAllPic 删除所有图片
- (void)top_MoreViewDeleteAllPic {
    [FIRAnalytics logEventWithName:@"DeleteAllPic" parameters:nil];
    [self top_deleteDocAlert];
}

#pragma mark -- 去订阅
- (void)top_subscriptionService {
    [self top_CancleSelectAction];
    if ([TOPAppTools needShowDiscountThemeView]) {
        [[TOPDiscountThemeView shareInstance] top_showDiscountTheme:@"20211123_year_sub"];
        return;
    } 
    TOPSubscriptionPayListViewController * generalVC = [[TOPSubscriptionPayListViewController alloc] init];
    generalVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:generalVC animated:YES];
}

#pragma mark -- Email Myself
- (void)top_MoreViewEmailMySelef:(BOOL)isEdit{
    if (![TOPPermissionManager top_enableByEmailMySelf]) {
        [self top_subscriptionService];
        return;
    }
    [FIRAnalytics logEventWithName:@"EmailMySelf" parameters:nil];
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            self.emailType = 2;
            if (isEdit) {
                [self top_ShareTip];
            }else{
                [self top_BottomViewWithShare];
            }
        }
    }];
}
#pragma mark -- Save To Gallery

- (void)top_MoreViewSaveGallery:(BOOL)isEdit{
    [FIRAnalytics logEventWithName:@"homeChild_MoreViewSaveGallery" parameters:nil];
    NSMutableArray * emailArray = [NSMutableArray new];
    NSMutableArray * tempArray = [NSMutableArray new];
    if (isEdit) {
        tempArray = self.selectedDocsIndexArray;
    }else{
        tempArray = self.homeDataArray;
    }
    
    for (DocumentModel * model in tempArray) {
        [emailArray addObject:model.imagePath];
    }
    WS(weakSelf);
    [TOPDocumentHelper top_saveImagePathArray:emailArray toFolder:TOPSaveToGallery_Path tipShow:YES showAlter:^(BOOL isExisted) {
        if (!isExisted) {
            [SVProgressHUD dismiss];
            [TOPDocumentHelper top_creatGalleryFolder:TOPSaveToGallery_Path];
            //提示框添加文本输入框
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
#pragma mark -- 排序
- (void)top_MoreViewSortBy{
    [FIRAnalytics logEventWithName:@"homeChild_MoreViewSortBy" parameters:nil];
    if ([TOPScanerShare top_childViewByType] == 1) {
        [TOPScanerShare top_writeChildViewByType:2];
    }else{
        [TOPScanerShare top_writeChildViewByType:1];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * sortArray = [TOPDataModelHandler top_imageSortWithData:[self.homeDataArray copy]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.collectionView.listArray  = [sortArray mutableCopy];
            self.homeDataArray =  [sortArray mutableCopy];
            self.collectionView.isMoveState = YES;
            [self.collectionView setShowType:ShowListDetailGoods];
        });
    });
}
#pragma mark -- 图片详情的隐藏与显示
- (void)top_MoreViewHideOrShowDetail{
    [FIRAnalytics logEventWithName:@"homeChild_MoreViewHideOrShowDetail" parameters:nil];
    if ([TOPScanerShare top_childHideDetailType] == 1) {
        [TOPScanerShare top_writeChildHideDetailType:2];
    }else{
        [TOPScanerShare top_writeChildHideDetailType:1];
    }
    [self.collectionView reloadData];
}
#pragma mark -- 传真
- (void)top_MoreViewFax:(BOOL)isEdit{
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self top_ShowMoreViewFax:isEdit];
        }
    }];
}
- (void)top_ShowMoreViewFax:(BOOL)isEdit{
    [FIRAnalytics logEventWithName:@"homeChild_MoreViewFaxTip" parameters:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
        CGFloat totalNum = [self top_calculatePicSize];
        if (freeSize<totalNum/1024.0/1024.0+5) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
            });
            return;
        }
        NSString * pdfName;
        NSMutableArray * imgArray = [NSMutableArray new];
        NSMutableArray * tempArray = [NSMutableArray new];
        if (isEdit) {
            tempArray = self.selectedDocsIndexArray;
        }else{
            tempArray = self.homeDataArray;
        }
        for (DocumentModel * model in tempArray) {
            UIImage * img = [UIImage imageWithContentsOfFile:model.imagePath];
            if (img) {
                [imgArray addObject:img];
            }
            pdfName = [NSString stringWithFormat:@"%@-1",model.fileName];
        }
        
        [TOPDocumentHelper top_creatPDF:imgArray documentName:pdfName pageSizeType:[TOPScanerShare top_pageSizeType] success:^(id  _Nonnull responseObj) {
            NSString * pdfPathString = responseObj;
            [TOPDocumentHelper top_jumpToSimpleFax:pdfPathString];
        }];
    });
}
#pragma mark --window上的底部视图的点击
- (void)top_WindowAndBottomViewWithEmail{
    NSMutableArray * editArray = [NSMutableArray new];
    for (DocumentModel *model in  self.homeDataArray) {
        if (model.selectStatus) {
            [editArray addObject:model];
        }
    }
    if (editArray.count>0) {
        [self top_BottomViewWithEmail:editArray];
    }
}

#pragma mark -- 设置文件大小弹窗
- (void)top_AddUserDefinedFileSizeView {
    [FIRAnalytics logEventWithName:@"homeChild_AddUserDefinedFileSizeView" parameters:nil];
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.userDefinedsizeView];
}

#pragma mark -- 隐藏设置文件大小弹窗
- (void)top_hiddenUserDefinedFileSizeView {
    [UIView animateWithDuration:0.3 animations:^{
        self.userDefinedsizeView.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self.userDefinedsizeView removeFromSuperview];
        self.userDefinedsizeView = nil;
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
            [self top_addPDFPassword:password];
        default:
            break;
    }
}

- (void)top_WritePasswordToDoc:(NSString *)password{
    [TOPDocumentHelper top_creatDocPasswordWithPath:self.pathString withPassword:password];
    [[TOPCornerToast shareInstance]makeToast:[NSString stringWithFormat:@"%@%@",[NSLocalizedString(@"topscan_colletiondocpasswordtitle", @"") stringByAppendingString:@":"],password]];
    [TOPScanerShare top_writeDocPasswordSave:password];
}

- (void)top_SetLockagain:(NSString *)password{
    [FIRAnalytics logEventWithName:@"top_SetLockagain" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickToHide];
        [self top_WritePasswordToDoc:password];
    }else{
        [self top_writePasswordFail];
    }
}
- (void)top_writePasswordFail{
    if (self.isShowFailToast) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_writepasswordfail", @"") duration:1];
    }
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

#pragma mark scrollview Delegate block
- (void)top_didScroll {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endScrollingAnimationDelay) object:nil];
    if (self.homeDataArray.count <= SSCountScroll) {
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
    if (bottomOffset <= height) {
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
}

#pragma mark 拖动滑块结束
- (void)scrollDidEnd:(float)value {
    self.scrollMark = NO;
    self.scrollIndicator.valueLabel.hidden = YES;
}

- (void)endScrollingAnimationDelay {
    self.scrollIndicator.hidden = YES;
}
    
#pragma mark lazy
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

- (NSMutableArray *)addNewImageArr {
    if (!_addNewImageArr) {
        _addNewImageArr = [@[] mutableCopy];
    }
    return _addNewImageArr;
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

- (NSMutableArray *)scanDataArray{
    if (!_scanDataArray) {
        _scanDataArray = [NSMutableArray array];
    }
    return _scanDataArray;
}

- (NSMutableArray *)moreArray{
    if (!_moreArray) {
        _moreArray = [NSMutableArray new];
    }
    return _moreArray;
}

- (NSMutableArray *)emailArray{
    if (!_emailArray) {
        _emailArray = [NSMutableArray new];
    }
    return _emailArray;
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

- (TOPSettingEmailAgainView *)emailAgainView{
    WS(weakSelf);
    if (!_emailAgainView) {
        _emailAgainView = [[TOPSettingEmailAgainView alloc]initWithFrame:CGRectMake(20, (TOPScreenHeight-210)/2, TOPScreenWidth-40, 210)];
        _emailAgainView.contentType = weakSelf.emailType;
        _emailAgainView.top_sendBackEmail = ^(NSString * _Nonnull email) {
            [weakSelf top_ShowMailCompose:email array:weakSelf.emailArray];
        };
        
        _emailAgainView.top_returnEdit = ^{
            [weakSelf top_RemoveCurrentView];
        };
    }
    return _emailAgainView;
}

- (TOPAddFolderView *)addFolderView{
    if (!_addFolderView) {
        WS(weakSelf);
        _addFolderView = [[TOPAddFolderView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolder_W)];
        _addFolderView.top_clickToSendString = ^(NSString * _Nonnull editString) {
            [weakSelf top_ClickToChangeFolderNameAction:editString];
            [weakSelf top_RemoveCurrentView];
        };
        
        _addFolderView.top_clickToHide = ^{
            [weakSelf top_RemoveCurrentView];
        };
    }
    return _addFolderView;
}

- (UIView *)manualSortingHeaderView {
    if (!_manualSortingHeaderView) {
        _manualSortingHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, TOPStatusBarHeight, TOPScreenWidth, TOPNavBarHeight)];
        _manualSortingHeaderView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 44, 44);
        [btn setImage:[UIImage imageNamed:@"top_backItem"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(top_CancelManualSorting) forControlEvents:UIControlEventTouchUpInside];
        [_manualSortingHeaderView addSubview:btn];
        
        UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, TOPScreenWidth - 120, TOPNavBarHeight)];
        noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor];
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_M_FONT_(18);
        noClassLab.text = NSLocalizedString(@"topscan_manualsorttitle", @"");
        [_manualSortingHeaderView addSubview:noClassLab];
    }
    return _manualSortingHeaderView;
}

#pragma mark -- 自定义文件大小弹窗
- (TOPUserDefinedSizeView *)userDefinedsizeView {
    __weak typeof(self) weakSelf = self;
    if (!_userDefinedsizeView) {
        _userDefinedsizeView = [[TOPUserDefinedSizeView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _userDefinedsizeView.percentValue = [TOPScanerShare top_userDefinedFileSize];
        _userDefinedsizeView.fileSize = [self top_calculatePicSize];
        _userDefinedsizeView.top_clickCancelBtnBlock = ^{
            [weakSelf top_hiddenUserDefinedFileSizeView];
        };
        _userDefinedsizeView.top_clickResultBtnBlock = ^(NSInteger percentVal) {
            [TOPScanerShare top_writeUserDefinedFileSizePercent:percentVal];
            [weakSelf top_hiddenUserDefinedFileSizeView];
        };
    }
    return _userDefinedsizeView;
}

#pragma mark -- 密码弹框
- (TOPDocPasswordView *)passwordView{
    if (!_passwordView) {
        WS(weakSelf);
        _passwordView = [[TOPDocPasswordView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolderSingle_H)];
        _passwordView.top_sendPassword = ^(NSString * _Nonnull password, NSInteger actionType ,BOOL isShowFailToast) {
            weakSelf.isShowFailToast = isShowFailToast;
            [weakSelf top_passwordViewActionWithPassword:password WithType:actionType];
            [TOPScanerShare shared].isRefresh = YES;
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
#pragma mark -- 设置约束
- (void)top_markupCoverMask{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}

#pragma mark -- 横幅广告
- (void)top_AddBannerViewWithSize:(CGSize)currentSize{
    GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(currentSize.width);
    self.adViewH = adSize.size.height;
    NSString * adID = @"ca-app-pub-3940256099942544/2934735716";
    adID = [TOPDocumentHelper top_bannerAdID][2];
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
        bannerView.hidden = NO;
        self.isBanner = YES;
        [self top_bannerViewSuccessViewFream];
        [self top_sumAllFileSize];
    }
}
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
    [self.tabbarBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
        make.height.mas_equalTo(Bottom_H);
    }];
    if (self.selectBoxModel.functionType == TopFunctionTypePDFExtract) {
        if ([self.view.subviews containsObject:self.boxBootomView]) {
            [self.boxBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
                make.height.mas_equalTo(Bottom_H);
            }];
        }
    }else if(self.selectBoxModel.functionType == TopFunctionTypePDFPageAdjustment){
        if ([self.view.subviews containsObject:self.boxAdjustBootomView]) {
            [self.boxAdjustBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
                make.height.mas_equalTo(Bottom_H);
            }];
        }
    }else{
        if ([TOPScanerShare shared].isEditing == YES) {
            if ([self.view.subviews containsObject:self.pressBootomView]) {
                [self.pressBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(self.view);
                    make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
                    make.height.mas_equalTo(Bottom_H);
                }];
            }
        }
    }
    [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H+self.adViewH));
    }];
}
#pragma mark -- 获取横幅广告失败试图时 重置试图坐标位置
- (void)top_bannerViewFailViewFream{
    if (self.selectBoxModel.functionType == TopFunctionTypePDFExtract) {
        if ([self.view.subviews containsObject:self.boxBootomView]) {
            [self.boxBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
                make.height.mas_equalTo(Bottom_H);
            }];
        }
    }else if(self.selectBoxModel.functionType == TopFunctionTypePDFPageAdjustment){
        if ([self.view.subviews containsObject:self.boxAdjustBootomView]) {
            [self.boxAdjustBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
                make.height.mas_equalTo(Bottom_H);
            }];
        }
    }else{
        if ([self.view.subviews containsObject:self.pressBootomView]) {
            [self.pressBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
                make.height.mas_equalTo(Bottom_H);
            }];
        }
    }
    [self.tabbarBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(Bottom_H);
    }];
}
#pragma mark -- 插页广告 1~12的随机数与界面ID相等时才显示插页广告
- (void)top_getInterstitialAd{
    int index = [TOPDocumentHelper top_interstitialAdRandomNumber];
    if (index == TOPAppInterfaceIDChild) {
        WS(weakSelf);
        GADRequest *request = [GADRequest request];
        NSString * adID = @"ca-app-pub-3940256099942544/4411468910";
        adID = [TOPDocumentHelper top_interstitialAdID][2];
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
#pragma mark -- 长按或者取消时调用
- (void)top_resetColectionViewFream{
    if (!self.isBanner) {
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
        }];
    }else{
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H+self.adViewH));
        }];
    }
}

-(void)dealloc{
    
    
}
@end
