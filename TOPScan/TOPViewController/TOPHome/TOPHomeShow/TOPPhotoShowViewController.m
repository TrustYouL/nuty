#define kPanHeight 250
#define kMaxZoom 3.0
#define TopView_H 44
#define Bottom_H 60
#define NoteView_H 300
#define WhiteView_W 250
#define WhiteView_H 300
#import "TOPPhotoShowViewController.h"
#import "TOPPhotoEditView.h"
#import "TOPPhotoEditScrollView.h"
#import "TOPScrollChooseView.h"
#import "TOPPhotoReEditVC.h"
#import "TOPSingleBatchViewController.h"
#import "TOPShowPicCollectionViewCell.h"
#import "TOPSettingDocumentFormatterView.h"
#import "TOPPhotoShowOCRVC.h"
#import "TOPChildMoreView.h"
#import "TOPPicDetailView.h"
#import "TOPNextSettingShowView.h"

#import "TOPDataTool.h"
#import "TOPShareTypeView.h"
#import "TOPShareDownSizeView.h"
#import "TOPPhotoShowNoteView.h"
#import "TOPPhotoShowChildImageView.h"
#import "TOPPhotoShowTextAgainVC.h"
#import "TOPSwitch.h"

#import "TOPSignatureViewController.h"
#import "TOPPhotoCombineSignatureVC.h"
#import "TOPGraffitiViewController.h"
#import "TOPDataModelHandler.h"
#import "TOPGraffitiLabelViewController.h"
#import "TOPPhotoShowTextTranslationVC.h"
#import "TOPSCameraViewController.h"
#import "TOPImageWaterMarkController.h"
#import "TOPLoadSelectDriveViewController.h"
#import "TOPCropTipView.h"
#import "TOPAlertController.h"
#import "TOPBinHomeViewController.h"

@interface TOPPhotoShowViewController ()<UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate,UIPrintInteractionControllerDelegate,TOPPhotoShowChildImageViewDelegate,GADBannerViewDelegate,GADFullScreenContentDelegate>
@property (nonatomic, strong) TOPShareTypeView * shareAction;
@property (nonatomic, strong) TOPPhotoShowNoteView * noteView;
@property (nonatomic, strong) TOPPhotoShowChildImageView * childImgView;
@property (nonatomic, strong) TOPPhotoShowChildImageView * childTextView;
@property (nonatomic, strong) TOPSettingDocumentFormatterView * exportView;
@property (nonatomic, strong) TOPScrollChooseView * scrollChooseView;
@property (nonatomic, strong) TOPNextSettingShowView * imgMoreView;
@property (nonatomic, strong) TOPSwitch * mySwitch;
@property (nonatomic, strong) UIView * coverView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger emailType;
@property (nonatomic, assign) NSInteger pdfType;
@property (nonatomic, copy) NSString * totalSizeString;
@property (nonatomic, assign) CGFloat totalSizeNum;
@property (nonatomic, strong) TOPSettingEmailModel * emailModel;
@property (nonatomic, copy) NSString * saveTextString;
@property (nonatomic, assign) BOOL mySwitchState;
@property (nonatomic, strong) GADBannerView * scBannerView;
@property (nonatomic, strong) GADInterstitialAd *interstitial;
@property (nonatomic, assign) CGFloat adViewH;
@property (nonatomic, assign) BOOL isBanner;
@end

@implementation TOPPhotoShowViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.mySwitchState = NO;
    self.isBanner = NO;
    self.adViewH = 0.0;
    [self top_setupUI];
    [self top_loadAdData];
}

- (void)top_loadAdData{
    CGFloat navH = self.navigationController.navigationBar.frame.size.height;
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![TOPPermissionManager top_enableByAdvertising]) {
                    [self top_photoShow_AddBannerViewWithSize:CGSizeMake(self.view.width, self.view.height+TOPStatusBarHeight+navH)];
                    [self top_getInterstitialAd];
                }
            });
        }];
    } else {
        if (![TOPPermissionManager top_enableByAdvertising]) {
            [self top_photoShow_AddBannerViewWithSize:CGSizeMake(self.view.width, self.view.height+TOPStatusBarHeight+navH)];
            [self top_getInterstitialAd];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    [self.navigationController setNavigationBarHidden:YES];
    self.childImgView.collectionView.frame = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight);
    [TOPFileDataManager shareInstance].docModel = self.dataArray[self.currentIndex];
    BOOL isAdd = [[NSUserDefaults standardUserDefaults] boolForKey:TOP_TRAddNewSignatureImageKey];
    if (isAdd) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TOP_TRAddNewSignatureImageKey];
        [self top_photoShow_LoadSanBoxData];
    } else {
        if (!self.mySwitchState) {
            [self.childImgView top_loadCurrentData];
        }else{
            [self.childTextView top_loadCurrentData];
        }
    }

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (IS_IPAD) {
            [self top_setCollectionViewContentOffset:size.width];
        }else{
            [self.childImgView top_resetcollectionViewContent];
        }
        [self top_restoreBannerAD:size];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (IS_IPAD) {
        [self top_setCollectionViewContentOffset:size.width];
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
        [self top_photoShow_AddBannerViewWithSize:size];
    }
}
- (void)top_setCollectionViewContentOffset:(CGFloat)setX{
    if (!self.mySwitchState) {
        [self.childImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(self.view);
        }];
        [self.childImgView.collectionView reloadData];
        self.childImgView.collectionView.scrollEnabled = YES;
        [self.childImgView.collectionView setContentOffset:CGPointMake(self.currentIndex * setX, 0) animated:NO];
    }else{
        [self.childTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(self.view);
        }];
        [self.childTextView.collectionView reloadData];
        [self.childTextView.collectionView setContentOffset:CGPointMake(self.currentIndex * setX, 0) animated:NO];
    }
}
- (void)setImages:(NSArray *)images{
    _images = images;
    [self.dataArray addObjectsFromArray:_images];
}

- (void)top_clickToHide{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha = 0;
        self.exportView.alpha = 0;
        if (_noteView) {
            [self.noteView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.top.equalTo(self.view.mas_bottom);
                make.height.mas_equalTo(NoteView_H);
            }];
            [self.view layoutIfNeeded];
        }
        if (_imgMoreView) {
            [self imgMoreViewHideFream];
            [keyWindow layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        [self.coverView removeFromSuperview];
        [self.exportView removeFromSuperview];
        [self.noteView removeFromSuperview];
        [self.imgMoreView removeFromSuperview];
        
        self.coverView = nil;
        self.exportView = nil;
        self.noteView = nil;
        self.imgMoreView = nil;
    }];
}

#pragma mark -- 组装数据 从沙盒里面获取数据
- (void)top_photoShow_LoadSanBoxData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TOPImageFile *imageFile = [TOPDBQueryService top_imageFileById:[TOPFileDataManager shareInstance].docModel.docId];
        TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:imageFile.parentId];
        appDoc.filePath = self.pathString;
        NSMutableArray *dataArray = [TOPDBDataHandler top_buildDocumentDataWithDB:appDoc];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataArray = dataArray;
            self.currentIndex = dataArray.count - 1;
            self.childImgView.currentIndex = self.currentIndex;
            self.childImgView.dataArray = self.dataArray;
            self.childTextView.currentIndex = self.currentIndex;
            self.childTextView.dataArray = self.dataArray;
            [TOPFileDataManager shareInstance].docModel = self.dataArray[self.currentIndex];
            [self.childImgView top_loadCurrentData];
            [self.childTextView top_loadCurrentData];
        });
    });
}

- (void)top_setupUI{
    [self top_setupChildImageView];
    [self top_setupChilTextView];
    [self top_setupmySwitch];
}

#pragma mark -- 图片滑动的视图
- (void)top_setupChildImageView{
    TOPPhotoShowChildImageView * childImgView = [[TOPPhotoShowChildImageView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
    childImgView.currentIndex = self.currentIndex;
    childImgView.dataArray = self.dataArray;
    childImgView.showType = TOPPhotoShowViewImageType;
    childImgView.delegate = self;
    self.childImgView = childImgView;
    [childImgView top_loadCurrentData];
    [self.view addSubview:childImgView];
    [childImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
}
#pragma mark -- txt文档滑动的视图
- (void)top_setupChilTextView{
    TOPPhotoShowChildImageView * childTextView = [[TOPPhotoShowChildImageView alloc]initWithFrame:CGRectMake(TOPScreenWidth, 0, TOPScreenWidth, TOPScreenHeight)];
    childTextView.currentIndex = self.currentIndex;
    childTextView.dataArray = self.dataArray;
    childTextView.showType = TOPPhotoShowViewTextType;
    childTextView.delegate = self;
    self.childTextView = childTextView;
    [childTextView top_loadCurrentData];
    [self.view addSubview:childTextView];
    
    [childTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.view);
        make.leading.equalTo(self.view.mas_trailing);
        make.width.mas_equalTo(self.view.mas_width);
    }];
    childTextView.hidden = YES;
}

#pragma mark --图片和文档互相切换的视图
- (void)top_setupmySwitch{
    WS(weakSelf);
    TOPSwitch * mySwitch = [[TOPSwitch alloc]initWithFrame:CGRectMake((TOPScreenWidth-150)/2, TOPStatusBarHeight+TopView_H+10, 150, 35)];
    mySwitch.leftString = NSLocalizedString(@"topscan_image", @"");
    mySwitch.rightString = NSLocalizedString(@"topscan_graffititext", @"");
    [mySwitch setSwitchState:weakSelf.mySwitchState animation:NO];
    [mySwitch setTextFont:[UIFont systemFontOfSize:15]];
    mySwitch.block = ^(BOOL state) {
        weakSelf.mySwitchState = state;
        if (!state) {
            [weakSelf top_switchShowImageView];
        }else{
            [weakSelf top_switchShowTextView];
        }
    };
    weakSelf.mySwitch = mySwitch;
    [weakSelf.view addSubview:weakSelf.mySwitch];
    [mySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).offset(TOPStatusBarHeight+TopView_H+10);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(35);
    }];
}

#pragma mark --文档编辑的视图
- (void)top_setupNotView{
    WS(weakSelf);
    TOPPhotoShowNoteView * noteView = [[TOPPhotoShowNoteView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight,TOPScreenWidth , (NoteView_H))];
    noteView.top_sendTextViewContent = ^(NSString * _Nonnull contentString) {
        [weakSelf top_writeNote:contentString];
    };
    self.noteView = noteView;
    [self.view addSubview:noteView];
    [noteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view.mas_bottom);
        make.height.mas_equalTo(NoteView_H);
    }];
}

#pragma mark --覆盖层
- (void)top_setupCoverView{
    if (!_coverView) {
        UIView * coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        coverView.backgroundColor = RGBA(0, 0, 0, 1);
        coverView.alpha = 0;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickToHide)];
        [coverView addGestureRecognizer:tap];
        [self.view addSubview:coverView];
        self.coverView = coverView;
        [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(self.view);
        }];
    }
}

#pragma mark --导出的视图
- (void)top_setupExportView {
    WS(weakSelf);
    TOPSettingDocumentFormatterView * exportView = [[TOPSettingDocumentFormatterView alloc]initWithFrame:CGRectMake(20, (TOPScreenHeight-200)/2, TOPScreenWidth-40, 200)];
    exportView.alpha = 0;
    exportView.layer.masksToBounds = YES;
    exportView.layer.cornerRadius = 5;
    exportView.enterType = TOPFormatterViewEnterTypeTextAgainExport;
    exportView.top_clickToDismiss = ^{
        [weakSelf top_clickToHide];
    };
    
    exportView.top_clickCellSendExportType = ^(BOOL allBtnSelect, NSInteger row) {
        [weakSelf top_clickToHide];
        [weakSelf top_getSelectExportType:allBtnSelect index:row];
    };
     
    self.exportView = exportView;
    [self.view addSubview:exportView];
    if (IS_IPAD) {
        [exportView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view);
            make.height.mas_equalTo(200);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [exportView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(20);
            make.trailing.equalTo(self.view).offset(-20);
            make.centerY.equalTo(self.view);
            make.height.mas_equalTo(200);
        }];
    }
}

#pragma mark --视图的位置变换
- (void)top_switchShowImageView{
    [UIView animateWithDuration:0.3 animations:^{
        self.childImgView.hidden = NO;
        [self.childImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(self.view);
        }];
        self.childImgView.currentIndex = self.currentIndex;
        self.childImgView.dataArray = self.dataArray;
        [self.childImgView top_loadCurrentData];
        [self.childTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.view);
            make.leading.equalTo(self.view.mas_trailing);
            make.width.mas_equalTo(self.view.mas_width);
        }];
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        self.childTextView.hidden = YES;
    }];
}

- (void)top_switchShowTextView{
    [UIView animateWithDuration:0.3 animations:^{
        self.childTextView.hidden = NO;
        [self.childTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(self.view);
        }];
        self.childTextView.currentIndex = self.currentIndex;
        self.childTextView.dataArray = self.dataArray;
        [self.childTextView top_loadCurrentData];
        [self.childImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.view);
            make.trailing.equalTo(self.view.mas_leading);
            make.width.mas_equalTo(self.view.mas_width);
        }];
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        self.childImgView.hidden = YES;
    }];

}
- (void)top_showExportView{
    [self top_setupCoverView];
    [self top_setupExportView];
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha = 0.5;
        self.exportView.alpha = 1;
    }];
}
#pragma mark -- ExportViewAction
- (void)top_getSelectExportType:(BOOL)allPageSelect index:(NSInteger)row{
    NSNumber * num = [self top_exportArray][row];
    switch ([num integerValue]) {
        case TOPExportTypeTxt:
            [self top_photoShow_exportTxtAction:allPageSelect];
            break;
        case TOPExportTypeText:
            [self top_photoShow_exportTextAction:allPageSelect];
            break;
        case TOPExportTypeCopyToClipboard:
            [self top_photoShow_exportTxtActionClipboard:allPageSelect];
            break;
        default:
            break;
    }
}
#pragma mark--分享txt文档
- (void)top_photoShow_exportTxtAction:(BOOL)allPageSelect{
    [FIRAnalytics logEventWithName:@"photoShow_exportTxtAction" parameters:nil];
    //ocr导出时生成的txt文档路径
    NSString * homePath = [TOPDocumentHelper top_appBoxDirectory];
    DocumentModel * model = self.dataArray[self.currentIndex];
    NSString * shareString = [TOPDocumentHelper top_getTxtContent:model.ocrPath];
    NSString * filePath = [homePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.txt",model.fileName,model.name]];
    [shareString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSURL * shareURL = [NSURL fileURLWithPath:filePath];
    //分享功能
    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:@[shareURL] applicationActivities:nil];
    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    activiVC.excludedActivityTypes = excludedActivityTypes;
    if (IS_IPAD) {
        activiVC.popoverPresentationController.sourceView = self.view;
        activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController: activiVC animated:YES completion:nil];
}

#pragma mark--分享字符串
- (void)top_photoShow_exportTextAction:(BOOL)allPageSelect{
    [FIRAnalytics logEventWithName:@"photoShow_exportTextAction" parameters:nil];
    DocumentModel * model = self.dataArray[self.currentIndex];
    NSString * shareString = [TOPDocumentHelper top_getTxtContent:model.ocrPath];
    
    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:@[shareString] applicationActivities:nil];
    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    activiVC.excludedActivityTypes = excludedActivityTypes;
    if (IS_IPAD) {
        activiVC.popoverPresentationController.sourceView = self.view;
        activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController: activiVC animated:YES completion:nil];
}

#pragma mark -- 复制到粘贴板
- (void)top_photoShow_exportTxtActionClipboard:(BOOL)allPageSelect{
    [FIRAnalytics logEventWithName:@"photoShow_exportTxtActionClipboard" parameters:nil];
    DocumentModel * model = self.dataArray[self.currentIndex];
    NSString * shareString = [TOPDocumentHelper top_getTxtContent:model.ocrPath];
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = shareString;
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 260)];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_ocrexportcopy", @"")];
    [SVProgressHUD dismissWithDelay:1.5];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 0)];
    });
}

#pragma mark -- 写入输入内容
- (void)top_writeNote:(NSString *)contentString{
    self.noteView.textView.text = contentString;
    self.saveTextString = contentString;

    DocumentModel * model = self.dataArray[self.currentIndex];
    NSString *noteFilePath = [TOPDocumentHelper top_getTxtPath:model.movePath imgName:model.photoIndex txtType:TOPRSimpleScanNoteString];
    if (self.saveTextString.length>0) {
        [self.saveTextString writeToFile:noteFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    else{
        [TOPWHCFileManager top_removeItemAtPath:noteFilePath];
    }
}

#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    int height=keyboardrect.size.height;
    if (_noteView) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.noteView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-(height-20));
                make.top.equalTo(self.view).offset(TOPStatusBarHeight);
            }];
            [self.view layoutIfNeeded];
        }];
    }
    
    if (_scrollChooseView) {
        if (_scrollChooseView.whiteView.origin.y+WhiteView_H>keyboardrect.origin.y) {
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollChooseView.whiteView.frame = CGRectMake((TOPScreenWidth-WhiteView_W)/2, keyboardrect.origin.y-WhiteView_H, WhiteView_W, WhiteView_H);
            }];
        }
    }
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    [UIView animateWithDuration:0.3 animations:^{
        [self.noteView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.height.mas_equalTo(NoteView_H);
        }];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark --TOPPhotoShowChildImageViewDelegate
- (void)top_photoShowChildImageViewCurrentLocation:(NSInteger)index{
    self.currentIndex = index;
    [TOPFileDataManager shareInstance].docModel = self.dataArray[self.currentIndex];
}
#pragma mark -- text文档滑动时隐藏上方的切换按钮
- (void)top_photoShowChildImageViewScrollBeginHide{
    self.mySwitch.hidden = YES;
}
#pragma mark -- text文档滑动停止时显示上方按钮
- (void)top_photoShowChildImageViewScrollEndShow{
    self.mySwitch.hidden = NO;
}
#pragma mark -- 返回
- (void)top_photoShowChildImageViewBackHomeVC{
    DocumentModel * sendModel = self.dataArray[self.currentIndex]; 
    if (self.top_DismissBlock) {
        self.top_DismissBlock(sendModel);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 再次剪裁
- (void)top_photoShowChildImageViewTailoringAgain:(NSArray *)dataArray{
    [FIRAnalytics logEventWithName:@"ToEdit" parameters:nil];
    [self top_showCropTip:dataArray];
}

- (void)top_jumpToBachVC:(NSArray *)dataArray {
    if (dataArray.count>0) {
        DocumentModel * sendModel = self.dataArray[self.currentIndex];
        TOPSingleBatchViewController * batch = [TOPSingleBatchViewController new];
        batch.batchArray = dataArray;
        batch.model = sendModel;
        batch.backType = TOPHomeChildViewControllerBackTypeDismiss;
        batch.fileType = TOPShowPhotoShowReEditType;

        TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:batch];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)top_showCropTip:(NSArray *)dataArray {
    BOOL showTip = [[NSUserDefaults standardUserDefaults] boolForKey:@"cropTipAsk"];
    if (!showTip) {
        UIWindow *window = [UIApplication sharedApplication].windows[0];
        WS(weakSelf);
        TOPCropTipView *tipView = [[TOPCropTipView alloc] initWithTipMessage:NSLocalizedString(@"topscan_croptipmsg", @"")];
        tipView.okBlock = ^{
            [weakSelf top_jumpToBachVC:dataArray];
        };
        [window addSubview:tipView];
        [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(window);
        }];
    } else {
        [self top_jumpToBachVC:dataArray];
    }
}
#pragma mark --  选择图片位置的视图
- (void)top_photoShowChildImageViewScrollViewToSelect:(NSInteger)index{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [FIRAnalytics logEventWithName:@"scrollViewToSelect" parameters:nil];
    TOPScrollChooseView *scrollChooseView = [[TOPScrollChooseView alloc] initWithQuestionArray:self.dataArray withDefaultDesc:index];
    [scrollChooseView top_showView];
    __weak typeof(self) weakSelf = self;
    scrollChooseView.confirmBlock = ^(NSInteger selectedValue) {
        weakSelf.currentIndex = selectedValue;
        weakSelf.childImgView.currentIndex = selectedValue;
        [weakSelf.childImgView top_loadCurrentData];
    };
    [keyWindow addSubview:scrollChooseView];
    self.scrollChooseView = scrollChooseView;
    [scrollChooseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(keyWindow);
    }];
}
#pragma mark -- note
- (void)top_photoShowChildImageViewShowEditNote:(NSInteger)index{
    self.currentIndex = index;
    [self top_photoShow_EditNote];
}
#pragma mark -- share and Email
- (void)top_photoShowChildImageViewShowShareView:(NSInteger)shareType currentIndex:(NSInteger)index{
    self.currentIndex = index;
    self.emailType = shareType;
    [self top_photoShow_ShareTip];
}
#pragma mark --SaveToGallery
- (void)top_photoShowChildImageViewSaveToGallery:(NSInteger)index{
    self.currentIndex = index;
    [self top_photoShow_SaveToGalleryTip];
}
#pragma mark --more
- (void)top_photoShowChildImageViewMore:(NSInteger)index{
    self.currentIndex = index;
    [FIRAnalytics logEventWithName:@"photoShow_EditMoreMethod" parameters:nil];
    [self top_setupCoverView];
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.imgMoreView];
    [self imgMoreViewHideFream];
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha = 0.5;
        [self imgMoreViewShowFream];
        [keyWindow layoutIfNeeded];
    }];
}
- (void)imgMoreViewHideFream{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    if (IS_IPAD) {
        [self.imgMoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(keyWindow);
            make.top.equalTo(keyWindow.mas_bottom);
            make.height.mas_equalTo(50*8+TOPBottomSafeHeight+10);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.imgMoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keyWindow);
            make.top.equalTo(keyWindow.mas_bottom);
            make.height.mas_equalTo(50*8+TOPBottomSafeHeight+10);
        }];
    }
}
- (void)imgMoreViewShowFream{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    if (IS_IPAD) {
        [self.imgMoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(keyWindow);
            make.bottom.equalTo(keyWindow).offset(10);
            make.height.mas_equalTo(50*8+TOPBottomSafeHeight+10);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.imgMoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keyWindow);
            make.bottom.equalTo(keyWindow).offset(10);
            make.height.mas_equalTo(50*8+TOPBottomSafeHeight+10);
        }];
    }
}
- (void)top_moreAction:(NSDictionary *)dic{
    WS(weakSelf);
    switch ([dic[@"type"] integerValue]) {
        case TOPPhotoShowViewImageBottomViewActionPrint:
            [weakSelf top_clickToHide];
            [weakSelf top_photoShow_PdfPrint];
            break;
        case TOPPhotoShowViewImageBottomViewActionNote:
            [self top_photoShowNote];
            break;
        case TOPPhotoShowViewImageBottomViewActionUpload:
            [weakSelf top_clickToHide];
            [weakSelf top_photoShow_BottomViewWithUpload];
            break;
        case TOPPhotoShowViewImageBottomViewActionOcrRecognizer:
            [weakSelf top_clickToHide];
            [weakSelf top_photoShowChildImageViewOcrAgain:0];
            break;
        case TOPPhotoShowViewImageBottomViewActionRetake:
            [weakSelf top_clickToHide];
            [weakSelf top_photoShow_BottomViewWithRetake];
            break;
        case TOPPhotoShowViewImageBottomViewActionWatermark:
            [weakSelf top_clickToHide];
            [weakSelf top_photoShow_BottomViewWithAddWatermark];
            break;
        case TOPHomeMoreFunctionPicDetail:
            [self top_photoShowImgDetail];
            break;
        default:
            break;
    }
}
#pragma mark -- 点击更多里的note
- (void)top_photoShowNote{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [UIView animateWithDuration:0.3 animations:^{
        if (self.imgMoreView) {
            [self imgMoreViewHideFream];
            [keyWindow layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        [self.imgMoreView removeFromSuperview];
        self.imgMoreView = nil;
        [self top_photoShow_EditNote];
    }];
}
#pragma mark -- 点击更多里的图片详情
- (void)top_photoShowImgDetail{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha = 0;
        if (self.imgMoreView) {
            [self imgMoreViewHideFream];
            [keyWindow layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        [self.imgMoreView removeFromSuperview];
        [self.coverView removeFromSuperview];
        
        self.imgMoreView = nil;
        self.coverView = nil;
        [self top_photoShow_picDetail];
    }];
}
#pragma mark -- 图片的详细信息展示的数据
- (NSArray *)top_creatPicDetailData{
    NSArray * arr = [NSArray new];
    DocumentModel * picModel = self.dataArray[self.currentIndex];
    if ([TOPWHCFileManager top_isExistsAtPath:picModel.path]) {
        UIImage * picImg = [UIImage imageWithContentsOfFile:picModel.path];
        NSString * sizeString = [NSString stringWithFormat:@"%dx%d",(int)picImg.size.width,(int)picImg.size.height];
        NSString * imgLength = [TOPDocumentHelper top_memorySizeStr:[[TOPWHCFileManager top_sizeOfFileAtPath:picModel.path] floatValue]];
        
        NSDictionary * dic1 = @{NSLocalizedString(@"topscan_size", @""):[NSString stringWithFormat:@"%@, %@",imgLength,sizeString]};
        NSDictionary * dic2 = @{NSLocalizedString(@"topscan_piccreattime", @""):picModel.picCreateDate};
        NSDictionary * dic3 = @{NSLocalizedString(@"topscan_picupdatetime", @""):[TOPAppTools timeStringFromDate:[TOPDBDataHandler top_updateTimeOfFile:picModel.path]]};
        arr = @[dic1,dic2,dic3];
    }
    return arr;
}
- (void)top_photoShow_picDetail{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * tempArray = [self top_creatPicDetailData];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *window = [UIApplication sharedApplication].windows[0];
            TOPPicDetailView * picDetailView = [[TOPPicDetailView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight) dataArray:tempArray];
            DocumentModel * picModel = self.dataArray[self.currentIndex];
            picDetailView.imgPath = picModel.path;
            [window addSubview:picDetailView];
            [picDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.bottom.equalTo(window);
            }];
        });
    });
}
#pragma mark -- 上传网盘
- (void)top_photoShow_BottomViewWithUpload {
    [FIRAnalytics logEventWithName:@"photoShowuploadDrive" parameters:nil];
    DocumentModel *model = self.dataArray[self.currentIndex];
    TOPLoadSelectDriveViewController *uploadVC = [[TOPLoadSelectDriveViewController alloc] init];
    NSMutableArray * tempArray = [NSMutableArray new];
    uploadVC.isSingleUpload = YES;
    [tempArray addObject:model];
    uploadVC.uploadDatas = [NSMutableArray arrayWithArray:tempArray];
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:uploadVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark -- 添加水印
- (void)top_photoShow_BottomViewWithAddWatermark {
    DocumentModel *model = self.dataArray[self.currentIndex];
    TOPImageWaterMarkController *watermarkVC = [[TOPImageWaterMarkController alloc] init];
    watermarkVC.imagePath = model.imagePath;
    watermarkVC.top_saveWatermarkBlock = ^{
        [TOPWHCFileManager top_removeItemAtPath:model.coverImagePath];//删除旧的缩率图
    };
    watermarkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:watermarkVC animated:YES];
}
#pragma mark --打印
- (void)top_photoShowChildImageViewPrint:(NSInteger)index{
    self.currentIndex = index;
    [self top_photoShow_PdfPrint];
}
#pragma mark --删除
- (void)top_photoShowChildImageViewDelete:(NSInteger)index{
    self.currentIndex = index;
    [self top_photoShow_PhotoEditToDelete];
}
#pragma mark --再次识别
- (void)top_photoShowChildImageViewOcrAgain:(NSInteger)index{
    [FIRAnalytics logEventWithName:@"photoShow_OcrAgain" parameters:nil];
    TOPPhotoShowOCRVC * ocrVC = [TOPPhotoShowOCRVC new];
    [ocrVC.dataArray addObject:self.dataArray[self.currentIndex]];
    ocrVC.backType = TOPPhotoShowTextAgainVCBackTypePopPhotoShow;
    ocrVC.ocrAgain = TOPPhotoShowOCRVCAgainTypeOCRAgain;
    ocrVC.finishType = TOPPhotoShowOCRVCAgainFinishNot;
    ocrVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:ocrVC animated:YES];
}
#pragma mark -- 重拍
- (void)top_photoShow_BottomViewWithRetake{
    [FIRAnalytics logEventWithName:@"homeChild_BottomViewWithAdd" parameters:nil];
    [TOPFileDataManager shareInstance].docModel = self.dataArray[self.currentIndex];
    TOPEnterCameraType cameraTpye = TOPShowPhotoShowCameraType;
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = self.pathString;
    camera.fileType = cameraTpye;;
    camera.dataArray = self.dataArray;
    camera.sendModel = self.dataArray[self.currentIndex];
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- 涂鸦
- (void)top_photoShowChildImageViewShowSignatureImage:(NSInteger)index {
    [self top_photoShow_signMethod];
}
#pragma mark --Edit
- (void)top_photoShowChildImageViewEditAgain:(NSInteger)index{
    TOPPhotoShowTextAgainVC * againVC = [[TOPPhotoShowTextAgainVC alloc]init];
    [againVC.dataArray addObject:self.dataArray[self.currentIndex]];
    againVC.backType = TOPPhotoShowTextAgainVCBackTypePopVC;
    againVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:againVC animated:YES];
}
#pragma mark --copy
- (void)top_photoShowChildImageViewCopy:(NSInteger)index{
    [self top_photoShow_exportTxtActionClipboard:NO];
}
#pragma mark --Export
- (void)top_photoShowChildImageViewExport:(NSInteger)index{
    [self top_showExportView];
}
#pragma mark --Transelation
- (void)top_photoShowChildImageViewTranlation:(NSInteger)index{
    NSMutableArray * tempArray = [NSMutableArray new];
    DocumentModel * currentModel = self.dataArray[self.currentIndex];
    [tempArray addObject:currentModel];
    
    TOPPhotoShowTextTranslationVC * translationVC = [TOPPhotoShowTextTranslationVC new];
    translationVC.dataArray = tempArray;
    translationVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:translationVC animated:YES];
}
#pragma mark -- shareText
- (void)top_shareText{
    DocumentModel * currentModel = self.dataArray[self.currentIndex];
    if ([TOPWHCFileManager top_isExistsAtPath:currentModel.ocrPath]) {
        TOPPhotoShowTextAgainVC * againVC = [[TOPPhotoShowTextAgainVC alloc]init];
        [againVC.dataArray addObject:self.dataArray[self.currentIndex]];
        againVC.backType = TOPPhotoShowTextAgainVCBackTypePopVC;
        againVC.hidesBottomBarWhenPushed = YES;

        [self.navigationController pushViewController:againVC animated:YES];
    }else{
        [FIRAnalytics logEventWithName:@"photoShow_OcrAgain" parameters:nil];
        TOPPhotoShowOCRVC * ocrVC = [TOPPhotoShowOCRVC new];
        [ocrVC.dataArray addObject:self.dataArray[self.currentIndex]];
        ocrVC.backType = TOPPhotoShowTextAgainVCBackTypePopPhotoShow;
        ocrVC.ocrAgain = TOPPhotoShowOCRVCAgainTypeOCRAgain;
        ocrVC.finishType = TOPPhotoShowOCRVCAgainFinishNot;
        ocrVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ocrVC animated:YES];
    }
}
- (void)top_photoShowChildImageViewSwitchShowType:(BOOL)isShow{
    if (isShow) {
        self.mySwitch.hidden = YES;
    }else{
        self.mySwitch.hidden = NO;
    }
    [self top_bannerShowChangeBottomViewFream];
}

- (void)top_photoShow_EditNote{
    [FIRAnalytics logEventWithName:@"photoShow_EditNote" parameters:nil];
    DocumentModel * model = self.dataArray[self.currentIndex];
    [self top_setupCoverView];
    [self top_setupNotView];
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha = 0.5;
        [self.noteView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.height.mas_equalTo(NoteView_H);
        }];
        [self.view layoutIfNeeded];
        if ([TOPWHCFileManager top_isExistsAtPath:model.notePath]) {
            self.noteView.noteString = [TOPDocumentHelper top_getTxtContent:model.notePath];
        }
    }];
}

#pragma mark--保存到Gallery文件夹
- (void)top_photoShow_SaveToGalleryTip{
    [FIRAnalytics logEventWithName:@"photoShow_SaveToGalleryTip" parameters:nil];
    NSMutableArray * emailArray = [NSMutableArray new];
    DocumentModel * model = self.dataArray[self.currentIndex];
    [emailArray addObject:model.imagePath];
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

#pragma mark--打印
- (void)top_photoShow_PdfPrint{
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self top_dealPdfPrintData];
        }
    }];
}
- (void)top_dealPdfPrintData{
    [FIRAnalytics logEventWithName:@"photoShow_PdfPrint" parameters:nil];
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
        NSMutableArray * imgArray = [NSMutableArray new];
        NSString * pdfName = [NSString new];
        
        DocumentModel * model = self.dataArray[self.currentIndex];
        UIImage * img = [UIImage imageWithContentsOfFile:model.imagePath];
        if (img) {
            [imgArray addObject:img];
        }
        pdfName = [NSString stringWithFormat:@"%@-1",model.fileName];
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

#pragma mark -- 涂鸦方式选择
- (void)top_photoShow_signMethod {
    [FIRAnalytics logEventWithName:@"photoShow_signMethod" parameters:nil];
    NSString *str = [NSString stringWithFormat:@"%@  ",NSLocalizedString(@"topscan_writesignature", @"")];
    TOPAlertControllerStyle style = TOPAlertControllerStyleActionSheet;
    TOPAlertController *alertController = [TOPAlertController alertControllerWithTitle:nil message:nil preferredStyle:style];

    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, alertController.actionSize.width, alertController.actionSize.height)];
    redView.userInteractionEnabled = YES;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, alertController.actionSize.width, alertController.actionSize.height)];
    label.font = PingFang_R_FONT_(17);
    label.text = str;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
    redView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
    [redView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(redView);
    }];
    if (![TOPPermissionManager top_enableByImageSign]) {
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_vip_logo"]];
        [redView addSubview:logo];
        [logo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(label.mas_trailing).offset(10);
            make.centerY.equalTo(label);
        }];
    }
    [alertController addAction:[TOPAlertAction actionWithCustomView:redView style:TOPAlertActionStyleDestructive handler:^(TOPAlertAction * _Nonnull action) {
        [self top_jumpSignatureVC];
    }]];
    
    [alertController addAction:[TOPAlertAction actionWithTitle:NSLocalizedString(@"topscan_docgraffiti", @"") style:TOPAlertActionStyleDefault handler:^(TOPAlertAction * _Nonnull action) {
        [self top_jumpGraffitiVC];
    }]];
            
    [alertController addAction:[TOPAlertAction actionWithTitle:NSLocalizedString(@"topscan_docaddtext", @"") style:TOPAlertActionStyleDefault handler:^(TOPAlertAction * _Nonnull action) {
        [self top_photoShow_graffitiLabelVC];
    }]];
    
    [alertController addAction:[TOPAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:TOPAlertActionStyleCancel handler:nil]];
    [alertController showInViewController:self];
}

#pragma mark -- 文字label
- (void)top_photoShow_graffitiLabelVC {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [FIRAnalytics logEventWithName:@"photoShow_graffitiLabelVC" parameters:nil];
    TOPGraffitiLabelViewController *labelVC = [[TOPGraffitiLabelViewController alloc] init];
    DocumentModel * model = self.dataArray[self.currentIndex];
    labelVC.imagePath = model.imagePath;
    labelVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:labelVC animated:YES];
}

#pragma mark -- 跳转到涂鸦模块
- (void)top_jumpGraffitiVC {
    [FIRAnalytics logEventWithName:@"photoShow_graffiti" parameters:nil];
    TOPGraffitiViewController *singVC = [[TOPGraffitiViewController alloc] init];
    DocumentModel * model = self.dataArray[self.currentIndex];
    singVC.imagePath = model.imagePath;
    singVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:singVC animated:YES];
}

#pragma mark -- 跳转到签名模块
- (void)top_jumpSignatureVC {
    [FIRAnalytics logEventWithName:@"photoShow_signature" parameters:nil];
    NSData *signatureData = [NSData dataWithContentsOfFile:[TOPSignationImagePath stringByAppendingPathComponent:TOP_TRSignationImageName]];
    if (signatureData.length) {
        [self top_photoShow_signaturePreView];
    } else {
        [self top_photoShow_signatureOnImage];
    }
}

#pragma mark -- 签名
- (void)top_photoShow_signatureOnImage {
    [FIRAnalytics logEventWithName:@"photoShow_signatureOnImage" parameters:nil];
    TOPSignatureViewController *singVC = [[TOPSignatureViewController alloc] init];
    DocumentModel * model = self.dataArray[self.currentIndex];
    singVC.imagePath = model.imagePath;
    singVC.top_backToResetContentoffset = ^{
    };
    singVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:singVC animated:YES];
}

#pragma mark -- 签名预览
- (void)top_photoShow_signaturePreView {
    [FIRAnalytics logEventWithName:@"photoShow_signaturePreView" parameters:nil];
    TOPPhotoCombineSignatureVC *photoeditSign = [[TOPPhotoCombineSignatureVC alloc] init];
    DocumentModel * model = self.dataArray[self.currentIndex];
    photoeditSign.imagePath = model.imagePath;
    photoeditSign.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:photoeditSign animated:YES];
}

#pragma mark -- 删除
- (void)top_photoShow_PhotoEditToDelete {
    NSLog(@"index==%lu",self.currentIndex);
    [FIRAnalytics logEventWithName:@"photoShow_PhotoEditToDelete" parameters:nil];

    WS(weakSelf);
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_deletecurrentpage", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [weakSelf top_photoShow_deleteHandle];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark -- 删除单张图片处理
- (void)top_photoShow_deleteHandle {
    [self top_photoShow_deleteImage];
    [self.dataArray removeObjectAtIndex:self.currentIndex];
    
    if (self.dataArray.count>0) {
        if (self.currentIndex == 0) {
            self.currentIndex = 0;
        }else{
            self.currentIndex -=1 ;
        }
        [TOPFileDataManager shareInstance].docModel = self.dataArray[self.currentIndex];
        self.childImgView.currentIndex = self.currentIndex;
        self.childImgView.dataArray = self.dataArray;
        self.childTextView.currentIndex = self.currentIndex;
        self.childTextView.dataArray = self.dataArray;
        [self.childImgView top_loadCurrentData];
        [self.childTextView top_loadCurrentData];
        [self top_takeTipOfRecycleBin];
    }else{
        if (self.top_DeleteAllData) {
            self.top_DeleteAllData();
        }
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)top_takeTipOfRecycleBin {
    BOOL tipRecycleBin = [[NSUserDefaults standardUserDefaults] boolForKey:@"tipRecycleBinKey"];
    if (!tipRecycleBin) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"tipRecycleBinKey"];
        
        WS(weakSelf);
        //提示框添加文本输入框
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

#pragma mark -- 删除图片->转移至回收站
- (void)top_photoShow_deleteImage {
    DocumentModel * model = self.dataArray[self.currentIndex];
    TOPImageFile *imgFile = [TOPDBQueryService top_imageFileById:model.docId];
    BOOL newDoc = [TOPBinDataHandler top_needCreateBinDocument:model.docId];
    NSString *binImgPath = [TOPBinHelper top_moveImageToBin:model.path atNewDoc:newDoc];
    if (binImgPath.length) {
        if (newDoc) {
            NSString *docPath = [TOPWHCFileManager top_directoryAtPath:binImgPath];
            [TOPBinEditDataHandler top_saddBinDocWithParentId:imgFile.pathId atPath:docPath];
        } else {
            NSString *fileName = [TOPWHCFileManager top_fileNameAtPath:binImgPath suffix:YES];
            TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:imgFile.parentId];
            [TOPBinEditDataHandler top_addBinImageAtDocument:@[fileName] WithId:doc.pathId];
        }
    }
    [TOPEditDBDataHandler top_deleteImagesWithIds:@[model.docId]];
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
#pragma mark --点击分享按钮
- (void)top_photoShow_ShareTip{
    [FIRAnalytics logEventWithName:@"photoShow_ShareTip" parameters:nil];
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self top_addShareAction];
            [self top_calculateSelectNumber];
        }
    }];
}

- (void)top_addShareAction{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    WS(weakSelf);
    NSArray * titleArray = @[NSLocalizedString(@"topscan_pdffile", @""),NSLocalizedString(@"topscan_image_jpg", @""),NSLocalizedString(@"topscan_txt", @"")];
    NSArray * picArray = @[@"top_SharePDF",@"top_ShareJPG",@"top_ShareTXT"];

    TOPShareTypeView *shareAction = [[TOPShareTypeView alloc] initWithTitleView:[UIView new] titleArray: titleArray picArray:picArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
    } selectBlock:^(NSInteger row, NSString * _Nonnull totalSize) {
        weakSelf.pdfType = row;
        if ([totalSize containsString:@"M"]||[totalSize containsString:@"G"]) {
            if (row == 0 || row == 1) {
                NSArray * titleArray = @[NSLocalizedString(@"topscan_originalsize", @""),NSLocalizedString(@"topscan_medium", @""),NSLocalizedString(@"topscan_small", @"")];
                if ([TOPScanerShare top_userDefinedFileSize] > 0) {
                    titleArray = @[NSLocalizedString(@"topscan_originalsize", @""),NSLocalizedString(@"topscan_medium", @""),NSLocalizedString(@"topscan_small", @""),NSLocalizedString(@"topscan_userdefinedsize", @"")];
                }
                TOPShareDownSizeView * sizeView = [[TOPShareDownSizeView alloc]initWithTitleView:[UIView new] optionsArr:titleArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
                    
                } selectBlock:^(NSMutableArray * shareArray) {
                    if (weakSelf.emailType == 1) {
                        [weakSelf top_sendEmail:shareArray];
                    }else{
                        //分享功能
                        UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:shareArray applicationActivities:nil];
                        NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
                        activiVC.excludedActivityTypes = excludedActivityTypes;
                        if (IS_IPAD) {
                            activiVC.popoverPresentationController.sourceView = weakSelf.view;
                            activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
                            activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                        }
                        [weakSelf presentViewController: activiVC animated:YES completion:nil];
                    }
                }];
                
                NSMutableArray * currentArray = [NSMutableArray new];
                DocumentModel * model = [DocumentModel new];
                model = weakSelf.dataArray[weakSelf.currentIndex];
                model.selectStatus = YES;
                [currentArray addObject:model];
                
                [weakSelf.view addSubview:sizeView];
                sizeView.compressType = row;
                sizeView.childArray = currentArray;
                sizeView.totalNum = weakSelf.totalSizeNum;
                sizeView.numberStr = weakSelf.totalSizeString;
            }else{
                [weakSelf top_shareText];
            }
            
        }else{
            if(row == 0) {
                [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
                NSMutableArray * imgArray = [NSMutableArray new];
                NSString * pdfName = [NSString new];
                
                DocumentModel * model = weakSelf.dataArray[weakSelf.currentIndex];
                UIImage * img = [UIImage imageWithContentsOfFile:model.imagePath];
                if ([TOPScanerShare top_singleFileUserDefinedFileSizeState] && ([TOPScanerShare top_userDefinedFileSize] > 0)) {
                    NSString * compressFile = [TOPDocumentHelper top_saveCompressImage:model.imagePath maxCompression:([TOPScanerShare top_userDefinedFileSize]/100.0)];
                    if (compressFile.length) {
                        img = [UIImage imageWithContentsOfFile:compressFile];
                    }
                }
                if (img) {
                    [imgArray addObject:img];
                }
                pdfName = [NSString stringWithFormat:@"%@-1",model.fileName];
                NSString * path = [TOPDocumentHelper top_creatPDF:imgArray documentName:pdfName];
                NSURL * file = [NSURL fileURLWithPath:path];
                
                if (weakSelf.emailType == 1) {
                    [weakSelf top_sendEmail:@[file]];
                }else{
                    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:@[file] applicationActivities:nil];
                    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
                    activiVC.excludedActivityTypes = excludedActivityTypes;
                    if (IS_IPAD) {
                        activiVC.popoverPresentationController.sourceView = weakSelf.view;
                        activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
                        activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                    }
                    [weakSelf presentViewController: activiVC animated:YES completion:nil];
                }
            }else if(row == 1){
                DocumentModel * model = weakSelf.dataArray[weakSelf.currentIndex];
                NSURL * file = [NSURL fileURLWithPath:model.imagePath];
                CGFloat max = 0.0;
                if ([TOPScanerShare top_singleFileUserDefinedFileSizeState] && ([TOPScanerShare top_userDefinedFileSize] > 0)) {
                    max = [TOPScanerShare top_userDefinedFileSize]/100.0;
                }else{
                    max = 1.0;
                }
                
                NSArray * pathArray = [model.path componentsSeparatedByString:@"/"];
                NSString * docName = [NSString new];
                if (pathArray.count>0) {
                    docName = pathArray[pathArray.count-2];
                }
                NSString * savePath = [NSString stringWithFormat:@"%@_%@.jpg",docName,model.name];//保存压缩后的图片路的径最后一部分
                NSString * compressFile = [TOPDocumentHelper top_saveCompressImage:model.imagePath savePath:savePath maxCompression:max];
                if (compressFile.length) {
                    file = [NSURL fileURLWithPath:compressFile];
                }
                
                if (weakSelf.emailType == 1) {
                    [weakSelf top_sendEmail:@[file]];
                }else{
                    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:@[file] applicationActivities:nil];
                    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
                    activiVC.excludedActivityTypes = excludedActivityTypes;
                    if (IS_IPAD) {
                        activiVC.popoverPresentationController.sourceView = weakSelf.view;
                        activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
                        activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                    }
                    [weakSelf presentViewController: activiVC animated:YES completion:nil];
                }
            }else{
                [weakSelf top_shareText];
            }
        }
    }];
    self.shareAction = shareAction;
    [window addSubview:shareAction];
    [shareAction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(window);
    }];
}

#pragma mark -- 计算图片大小
- (void)top_calculateSelectNumber{
    NSMutableArray * tempPathArray = [NSMutableArray new];
    DocumentModel * model = self.dataArray[self.currentIndex];
    [tempPathArray addObject:model.imagePath];
    CGFloat memorySize = [TOPDocumentHelper top_totalMemorySize:tempPathArray];
    self.totalSizeNum = memorySize;
    NSString * totalSize = [TOPDocumentHelper top_memorySizeStr:memorySize];
    self.shareAction.totalSizeNum = self.totalSizeNum;
    self.shareAction.numberStr = totalSize;
    self.shareAction.showSectionHeader = ([TOPScanerShare top_userDefinedFileSize]>0 && self.totalSizeNum < 1000000) ? YES : NO;
    self.totalSizeString = totalSize;
}


- (void)top_sendEmail:(NSArray *)emailArray{
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
    [self top_showMailCompose:self.emailModel.toEmail array:emailArray];
}

- (void)top_showMailCompose:(NSString *)email array:(NSArray *)emailArray{
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

#pragma mark -- 进入界面时是否显示note试图的判定
- (void)setEnterType:(NSInteger)enterType{
    _enterType = enterType;
    if (self.enterType == TOPHomeChildCellShowBackBtnType) {
        [self top_photoShow_EditNote];
    }
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;;
}

- (NSArray *)top_exportArray{
    NSArray * tempArray = @[@(TOPExportTypeTxt),@(TOPExportTypeText),@(TOPExportTypeCopyToClipboard)];
    return tempArray;
}

- (NSArray *)moreArray{
    NSArray * tempArray = @[@(TOPPhotoShowViewImageBottomViewActionRetake),@(TOPPhotoShowViewImageBottomViewActionWatermark),@(TOPPhotoShowViewImageBottomViewActionUpload),@(TOPPhotoShowViewImageBottomViewActionOcrRecognizer),@(TOPPhotoShowViewImageBottomViewActionPrint),@(TOPPhotoShowViewImageBottomViewActionNote),@(TOPHomeMoreFunctionPicDetail)];
    return tempArray;
}
- (TOPNextSettingShowView *)imgMoreView{
    WS(weakSelf);
    if (!_imgMoreView) {
        _imgMoreView = [[TOPNextSettingShowView alloc]initWithFrame:CGRectMake(0,TOPScreenHeight, TOPScreenWidth, 50*7+TOPBottomSafeHeight+10)];
        _imgMoreView.enterType = TOPFormatterViewEnterTypeImgMore;
        _imgMoreView.top_clickToDismiss = ^{
            [weakSelf top_clickToHide];
        };
        _imgMoreView.top_imgMoreBlock = ^(NSDictionary * _Nonnull dic) {
            [weakSelf top_moreAction:dic];
        };
    }
    return _imgMoreView;
}
#pragma mark -- 横幅广告
- (void)top_photoShow_AddBannerViewWithSize:(CGSize)currentSize{
    GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(currentSize.width);
    self.adViewH = adSize.size.height;
    NSString * adID = @"ca-app-pub-3940256099942544/2934735716";
    adID = [TOPDocumentHelper top_bannerAdID][3];
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
        CGRect frame = self.view.frame;
        if (@available(iOS 11.0, *)) {
            frame = UIEdgeInsetsInsetRect(self.view.frame, self.view.safeAreaInsets);
        }
        CGFloat viewWith = frame.size.width;
        GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWith);
        self.adViewH = adSize.size.height;
        bannerView.hidden = NO;
        [self top_bannerShowChangeBottomViewFream];
    }
}
#pragma mark -- 获取横幅广告失败
- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    if (!self.isBanner) {
        self.isBanner = NO;
        bannerView.hidden = YES;
        [self top_bannerShowChangeBottomViewFream];
    }
}
- (void)top_bannerShowChangeBottomViewFream{
    CGFloat adSizeH = 0;
    if (self.isBanner) {
        adSizeH = self.adViewH;
    }
    self.childImgView.adSizeH = adSizeH;
    self.childTextView.adSizeH = adSizeH;
}
#pragma mark -- 插页广告 1~12的随机数与界面ID相等时才显示插页广告
- (void)top_getInterstitialAd{
    int index = [TOPDocumentHelper top_interstitialAdRandomNumber];
    if (index == TOPAppInterfaceIDShowView) {
        WS(weakSelf);
        GADRequest *request = [GADRequest request];
        NSString * adID = @"ca-app-pub-3940256099942544/4411468910";
        adID = [TOPDocumentHelper top_interstitialAdID][3];
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

- (void)dealloc{
    NSLog(@"--photo show dealloc");
}
@end
