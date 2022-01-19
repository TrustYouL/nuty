#import "TOPPDFSignatureViewController.h"
#import "TOPEditPDFModel.h"
#import "TOPEditPDFHandler.h"
#import "TOPEditPDFViewCell.h"
#import "TOPSignatureMenuView.h"
#import "TOPChildMoreView.h"
#import "TOPSCameraViewController.h"
#import "TOPSignatureViewController.h"
#import "TOPUIThroughSuperView.h"
#import "StickerView.h"
#import "TOPSingleBatchViewController.h"
#import "UIImage+resetColor.h"
#import "TOPPDFSignatureSettingView.h"
#import "TOPFunctionColletionListVC.h"

#define Bottom_H 90
#define SSCelInterSpacing 10

@interface TOPPDFSignatureViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TZImagePickerControllerDelegate, StickerViewDelegate>

@property (nonatomic, strong)  UICollectionView *collectionView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *contentView;
@property (strong, nonatomic) UILabel *pageLab;//总页数
@property (weak, nonatomic) TOPSignatureMenuView *signautreMenuView;
@property (strong, nonatomic) TOPUIThroughSuperView *contrlView;
@property (strong, nonatomic) TOPPDFSignatureSettingView *signatureSettingView;
@property (assign, nonatomic) NSInteger currentPage;//当前页码
@property (nonatomic, strong) TOPEditPDFHandler *editPDFHandler;
@property (nonatomic ,strong) CIContext * context;//Core Image上下文
@property (nonatomic ,strong) CIFilter * sharpenFilter;//滤镜
@property (assign, nonatomic) CGFloat contrastValue;//对比度

@end

@implementation TOPPDFSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"topscan_colletionpdfsignaturetitle", @"");
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:ViewBgColor];
    self.currentPage = 1;
    [self top_setupSubViews];
    [self top_setupDatas];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:TOP_TRNewSignatureKey];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self top_initNavBar];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    NSString *newSignature = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRNewSignatureKey];
    if ([newSignature length] && _signautreMenuView) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:TOP_TRNewSignatureKey];
        [self.signautreMenuView top_configContentData];
        [self top_selectSignatureImage:newSignature];
    }
    [self top_setRigthButton:@"top_vip_logo" withSelector:@selector(top_pdfSignatureVC_saveDone)];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
#pragma mark -- 导航栏
- (void)top_initNavBar {
    self.navigationController.navigationBar.titleTextAttributes=
    @{NSForegroundColorAttributeName:[UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor],
    NSFontAttributeName:[UIFont systemFontOfSize:18]};
    [self.navigationController.navigationBar setBarTintColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor]];
    if (isRTL()) {
        [self top_setBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_setBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
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

- (void)top_setRigthButton:(nullable NSString *)imgName withSelector:(SEL)selector {
    if (![TOPPermissionManager top_enableByCollageSave]) {
        TOPImageTitleButton * btn = [[TOPImageTitleButton alloc] initWithStyle:(ETitleLeftImageRightCenter)];
        btn.frame = CGRectMake(0, 0, 64, 30);
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        [btn setTitle:NSLocalizedString(@"topscan_batchsave", @"") forState:UIControlStateNormal];
        [btn setTextFont: PingFang_R_FONT_(12)];
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:kTopicBlueColor];
        btn.layer.cornerRadius = 5;
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = barItem;
    } else {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 30)];
        [btn setTitle:NSLocalizedString(@"topscan_batchsave", @"") forState:UIControlStateNormal];
        [btn.titleLabel setFont:PingFang_R_FONT_(12)];
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:kTopicBlueColor];
        btn.layer.cornerRadius = 5;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = barItem;
    }
}

- (void)top_setupSubViews {
    [self.contentView addSubview:self.collectionView];
    [self top_pdfSignatureMenuBottomView];
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
}

- (void)top_setupDatas {
    BOOL isHaveFolders = [TOPWHCFileManager top_isExistsAtPath:TOPSignationImagePath];
    if (!isHaveFolders) {
        [TOPWHCFileManager top_createDirectoryAtPath:TOPSignationImagePath];
    }
    self.contrastValue = 1.0;
    self.context = [CIContext contextWithOptions:nil];
    self.sharpenFilter = [CIFilter filterWithName:@"CIColorControls"];//CISharpenLuminance
    CGRect current = [TOPDocumentHelper top_getPdfsizeWithType:[TOPScanerShare top_pageSizeType]];
    self.editPDFHandler = [[TOPEditPDFHandler alloc] init];
    self.editPDFHandler.filePath = self.filePath;
    self.editPDFHandler.imagePathArr = self.imagePathArr;
    self.editPDFHandler.aspectRatio = CGRectGetHeight(current) / CGRectGetWidth(current);
    if (self.dataArray.count) {
        [self top_beingEditPdf];
    } else {
        [self top_refreshPDF];
    }
}

- (void)top_beingEditPdf {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (TOPEditPDFModel *model in self.dataArray) {
            if (model.picArr.count) {
                for (SSPDFSignaturePic *pic in model.picArr) {
                    pic.enabledInteraction = YES;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}

- (void)top_refreshPDF {
    NSArray *temp = self.imagePathArr.count ? self.imagePathArr : [TOPDocumentHelper top_showPicArrayAtPath:self.filePath];
    if (temp.count > 200) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.dataArray = [self.editPDFHandler setupPdfDatasProgress:^(CGFloat myProgress) {
            [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [self.collectionView reloadData];
        });
    });
}

- (void)top_pdfSignatureMenuBottomView {
    __weak typeof(self) weakSelf = self;
    TOPSignatureMenuView *menuView = [[TOPSignatureMenuView alloc] initWithFrame:CGRectMake(0, TOPScreenHeight - Bottom_H - TOPBottomSafeHeight - TOPNavBarAndStatusBarHeight, TOPScreenWidth, Bottom_H)];
    menuView.top_clickAddBtnBlock = ^{
        [weakSelf top_selectSignatureMethod];
    };
    menuView.top_selectSignatureBlock = ^(NSString * _Nonnull imgPath) {
        [weakSelf top_selectSignatureImage:imgPath];
    };
    menuView.superVC = weakSelf;
    [self.view addSubview:menuView];
    self.signautreMenuView = menuView;
    [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(Bottom_H);
    }];
}

#pragma mark -- 返回
- (void)top_backHomeAction {
    if ([self top_saveChange]) {
        [self top_saveImageAlert];
    } else {
        [self top_popBack];
    }
}

- (void)top_popBack {
    NSArray *vcs = self.navigationController.viewControllers;
    if (vcs.count > 3) {
        UIViewController *temp = vcs[vcs.count-3];//从应用菜单入口进入
        if ([temp isKindOfClass:[TOPFunctionColletionListVC class]]) {
            [self.navigationController popToViewController:temp animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -- 是否有签名加入
- (BOOL)top_saveChange {
    for (UIView *subView in _contrlView.subviews) {
        if ([subView isKindOfClass:[StickerView class]]) {
            return YES;
        }
    }
    for (TOPEditPDFModel *model in self.dataArray) {
        if (model.picArr.count) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- 关闭交互
- (void)top_closeInteraction {
    for (TOPEditPDFModel *model in self.dataArray) {
        for (SSPDFSignaturePic *pic in model.picArr) {
            pic.enabledInteraction = NO;
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

#pragma mark -- 保存
- (void)top_pdfSignatureVC_saveDone {
    [FIRAnalytics logEventWithName:@"PDFSignatureVC_saveDone" parameters:nil];
    if (![TOPPermissionManager top_enableByPDFSignature]) {
        [self top_subscriptionService];
        return;
    }
    if ([self top_saveChange]) {
        [self top_hiddenCtrlTap];
        [self top_closeInteraction];
        if (self.top_savePDFSignatureBlock) {
            self.top_savePDFSignatureBlock(self.dataArray);
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 保存提示
- (void)top_saveImageAlert {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_note", @"")
                                                                   message:NSLocalizedString(@"topscan_savealert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_discard", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        
        [self top_popBack];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 选择签名图片
- (void)top_selectSignatureImage:(NSString *)imgPath {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentPage - 1 inSection:0];
    [self top_updatePDFDataSource:imgPath];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark -- 刷新加入签名图片后的数据源
- (void)top_updatePDFDataSource:(NSString *)imgPath {
    [self top_hiddenCtrlTap];
    if (self.dataArray.count > self.currentPage - 1) {
        TOPEditPDFModel *model = self.dataArray[self.currentPage - 1];
        if (model.picArr.count < 3) {
            [model.picArr addObject:[self top_buildPicModel:imgPath]];
        } else {
            [self top_takeAttentionMaxSignature];
        }
    }
}

#pragma mark -- 构造签名图的数据模型
- (SSPDFSignaturePic *)top_buildPicModel:(NSString *)picPath {
    TOPEditPDFModel *model = self.dataArray[self.currentPage - 1];
    CGFloat min_h = model.cellSize.height / 4.0;
    static int index = 0;
    CGFloat rate = [UIScreen mainScreen].scale > 2 ? 0.25 : 0.3;
    UIImage *subImage = [UIImage imageNamed:picPath];
    UIImage *scaleImage = [TOPPictureProcessTool top_scaleImageWithData:[NSData dataWithContentsOfFile:picPath] withSize:CGSizeMake(subImage.size.width * rate, subImage.size.height * rate)];
    CGFloat scale = subImage.size.width / 100.0;
    CGRect imgViewRect = CGRectMake(arc4random()%(51)+50, arc4random()%(100)+min_h, subImage.size.width / scale, subImage.size.height / scale);
    CGRect subViewRect = CGRectMake(imgViewRect.origin.x*scale, imgViewRect.origin.y*scale, CGRectGetWidth(imgViewRect) *scale, CGRectGetHeight(imgViewRect) *scale);
    SSPDFSignaturePic *picModel = [[SSPDFSignaturePic alloc] initWithImage:scaleImage imgRect:subViewRect];
    picModel.imgViewRect = imgViewRect;
    picModel.isEditing = YES;
    picModel.imgIndex = index;
    picModel.picScale = scale;
    index ++;
    return picModel;
}

#pragma mark -- 每页只能加三张签名图片
- (void)top_takeAttentionMaxSignature {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"")
                                                                   message:NSLocalizedString(@"topscan_maxsignatures", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
    }];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 选择添加签名入口
- (void)top_selectSignatureMethod {
    NSArray *titleArray = @[
          NSLocalizedString(@"topscan_scansignature", @""),
          NSLocalizedString(@"topscan_importsignature", @""),
          NSLocalizedString(@"topscan_writesignature", @"")];
    NSArray *iconArray = @[@"top_pdf_scan_signature", @"top_childvc_morepic", @"top_folderRename"];//folderRename  childmorepic
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    __weak typeof(self) weakSelf = self;
    TOPChildMoreView * moreView = [[TOPChildMoreView alloc]initWithTitleView:[UIView new] optionsArr:titleArray iconArr:iconArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
        
    } selectBlock:^(NSInteger index) {
        [weakSelf top_editPDF_ClickMoreViewAction:index];
    }];
    
    [window addSubview:moreView];
}

- (NSArray *)homeMoreArray {
    return @[@(TOPSignaturePDFMoreMenuScan), @(TOPSignaturePDFMoreMenuAlbum), @(TOPSignaturePDFMoreWrite)];
}

#pragma mark -- 底部更多视图点击
- (void)top_editPDF_ClickMoreViewAction:(NSInteger)index{
    [FIRAnalytics logEventWithName:@"homeView_ClickMoreViewAction" parameters:@{@"index":@(index)}];
    NSNumber * num = self.homeMoreArray[index];
    switch ([num integerValue]) {
        case TOPSignaturePDFMoreMenuScan:
            [self top_pdfSignature_BottomViewWithphotograph];
            break;
        case TOPSignaturePDFMoreMenuAlbum:
            [self top_pdfSignature_MoreViewImportPic];
            break;
        case TOPSignaturePDFMoreWrite:
            [self top_pdfSignature_manuallyOnImage];
            break;
        default:
            break;
    }
}

#pragma mark -- 手动签名
- (void)top_pdfSignature_manuallyOnImage {
    [FIRAnalytics logEventWithName:@"photoShow_signatureOnImage" parameters:nil];
    __weak typeof(self) weakSelf = self;
    TOPSignatureViewController *signVC = [[TOPSignatureViewController alloc] init];
    signVC.top_saveSignatureBlock = ^(UIImage * _Nonnull signatureImg) {
        [weakSelf top_saveSignatureImage:UIImagePNGRepresentation(signatureImg)];
    };
    signVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:signVC animated:YES];
}

#pragma mark -- 拍照取签名
- (void)top_pdfSignature_BottomViewWithphotograph {
    [FIRAnalytics logEventWithName:@"pdfSignature_BottomViewWithphotograph" parameters:nil];
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = self.filePath;
    camera.fileType = TOPEnterCameraTypePDFSignature;
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- 从图库导入
- (void)top_pdfSignature_MoreViewImportPic {
    [FIRAnalytics logEventWithName:@"pdfSignature_MoreViewImportPic" parameters:nil];
    //到相册选取图片
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
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
    if (assets.count) {
        __weak typeof(self) weakSelf = self;
        [[TZImageManager manager] getOriginalPhotoDataWithAsset:assets[0] completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if ([info[@"PHImageResultIsDegradedKey"] boolValue] == NO) {
                    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:0],TOP_TRJPGPathSuffixString];
                    NSString *fileEndPath =  [TOPCamerPic_Path stringByAppendingPathComponent:fileName];
                    //写入显示的图片
                    BOOL result = [data writeToFile:fileEndPath atomically:YES];
                    if (result) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf top_pdfSignature_CropPhotos:@[fileName]];
                        });
                    }
                }
            });
        }];
    }
}

#pragma mark -- 跳转去裁剪界面
- (void)top_pdfSignature_CropPhotos:(NSArray *)photos {
    TOPSingleBatchViewController * batch = [[TOPSingleBatchViewController alloc] init];
    batch.pathString = self.filePath;
    batch.batchArray = [photos mutableCopy];
    batch.fileType = TOPEnterCameraTypePDFSignature;
    batch.backType = TOPHomeChildViewControllerBackTypePopVC;
    batch.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:batch animated:YES];
}

#pragma mark -- 保存图片到签名文件夹下
- (void)top_saveSignatureImage:(NSData *)data {
    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:[TOPDocumentHelper top_maxImageNumIndexAtPath:TOPSignationImagePath]],TOP_TRPNGPathSuffixString];
    NSString *fileEndPath =  [TOPSignationImagePath stringByAppendingPathComponent:fileName];
    BOOL reslut = [data writeToFile:fileEndPath atomically:YES];
    if (reslut) {
        [self top_selectSignatureImage:fileEndPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.signautreMenuView top_configContentData];
        });
    }
}

#pragma mark -TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
    [TOPWHCFileManager top_createDirectoryAtPath:TOPCamerPic_Path];
    [self top_saveAssetsRefreshUI:assets];
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 把图片加载到最上层图层便于操作
- (void)top_bringToTopLayer:(StickerView *)sticker atCellIndex:(NSInteger)cellIndex {
    sticker.delegate = self;
    if (_contrlView) {
        for (UIView *subView in self.contrlView.subviews) {
            if ([subView isKindOfClass:[StickerView class]]) {
                return;
            }
        }
    }
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:cellIndex inSection:0]];
    TOPEditPDFModel *model = self.dataArray[cellIndex];
    sticker.delegate = self;
    CGPoint centerAfter = CGPointMake(sticker.center.x, sticker.center.y + cell.frame.origin.y);
    sticker.center = centerAfter;
    [self.contrlView addSubview:sticker];
    [self top_updateControlsFilter:sticker.contentImage];
    for (SSPDFSignaturePic *pic in model.picArr) {
        if (pic.imgIndex == sticker.tag) {
            pic.isEditing = YES;
            if (!_signatureSettingView) {
                [self.view addSubview:self.signatureSettingView];
            }
            [self top_showSignatureSettingView];
            __weak typeof(self) weakSelf = self;
            self.signatureSettingView.top_changeColorBlock = ^(UIColor * _Nonnull color) {
                UIImage *colorImg = [sticker.contentImage imageChangeColor:color];
                sticker.contentImage = colorImg;
                [weakSelf top_updateControlsFilter:colorImg];
                pic.img = colorImg;
            };
            self.signatureSettingView.top_changeSaturationValueBlock = ^(CGFloat saturation) {
                weakSelf.contrastValue = saturation;
                [weakSelf.sharpenFilter setValue:@(saturation) forKey:@"inputContrast"];//inputSharpness
                sticker.contentImage = [weakSelf top_outFilerImage];
            };
            break;
        }
    }
}

#pragma mark -- 更新滤镜
- (void)top_updateControlsFilter:(UIImage *)contextImg {
    if (contextImg.CGImage) {
        CIImage * get = [CIImage imageWithCGImage:contextImg.CGImage];
        [self.sharpenFilter setValue:get forKey:@"inputImage"];
    }
}

#pragma mark -- 输出图片
- (UIImage *)top_outFilerImage {
    CIImage * outputImage = [self.sharpenFilter outputImage];
    CGImageRef temp = [self.context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage * showImage = [UIImage imageWithCGImage:temp];
    CGImageRelease(temp);
    return showImage;
}


#pragma mark -- sticker delegate
- (void)top_stickerViewDidTapRightTopControl:(StickerView *)stickerView {
    [stickerView removeFromSuperview];
    for (TOPEditPDFModel *pdfModel in self.dataArray) {
        for (int i = 0; i<pdfModel.picArr.count; i++) {
            SSPDFSignaturePic *pic = pdfModel.picArr[i];
            if (pic.imgIndex == stickerView.tag) {
                [pdfModel.picArr removeObject:pic];
                break;
            }
        }
    }
    [self top_hiddenSignatureSettingView];
}


#pragma mark -- 把图片放回到cell中
- (void)top_insertToCellView:(StickerView *)stickerView {
    for (TOPEditPDFModel *pdfModel in self.dataArray) {
        for (SSPDFSignaturePic *pic in pdfModel.picArr) {
            if (pic.imgIndex == stickerView.tag) {
                [pdfModel.picArr removeObject:pic];
                break;
            }
        }
    }
    CGPoint postion = stickerView.center;
    NSIndexPath *rowIndex = [self top_cellIndexForPostion:postion];
    TOPEditPDFModel *model = self.dataArray[rowIndex.item];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:rowIndex];
    if ([cell isKindOfClass:[TOPEditPDFViewCell class]]) {
        TOPEditPDFViewCell *collageCell = (TOPEditPDFViewCell *)cell;
        stickerView.center = CGPointMake(postion.x, postion.y - collageCell.frame.origin.y);
        [collageCell top_addStickerView:stickerView];
    } else {
        CGFloat originY = 0;
        if (rowIndex.item > 0) {
            for (int i = 0; i < rowIndex.item; i++) {
                TOPEditPDFModel *model = self.dataArray[i];
                originY += model.cellSize.height;
            }
        }
        stickerView.center = CGPointMake(postion.x, postion.y - originY);
    }
    
    UIImageView *subImageView = [stickerView viewWithTag:1234];
    CGFloat scale = subImageView.image.size.width / 100.0;;
    CGRect imgViewRect = CGRectMake(stickerView.center.x - CGRectGetWidth(subImageView.frame)/2.0, stickerView.center.y - CGRectGetHeight(subImageView.frame)/2.0, CGRectGetWidth(subImageView.frame), CGRectGetHeight(subImageView.frame));
    CGRect subViewRect = CGRectMake(imgViewRect.origin.x*scale, imgViewRect.origin.y*scale, CGRectGetWidth(imgViewRect) *scale, CGRectGetHeight(imgViewRect) *scale);
    SSPDFSignaturePic *pic = [[SSPDFSignaturePic alloc] initWithImage:subImageView.image imgRect:subViewRect];
    pic.imgIndex = stickerView.tag;
    pic.imgViewRect = imgViewRect;
    pic.picScale = scale;
    pic.isEditing = NO;
    pic.picRotation = [[subImageView.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    if (pic.picRotation != 0) {
        pic.img = [TOPPictureProcessTool top_rotationScaleImageWithImageView:subImageView];
    }
    [model.picArr addObject:pic];
}

- (NSIndexPath *)top_cellIndexForPostion:(CGPoint)postion {
    NSIndexPath *rowIndex = [self.collectionView indexPathForItemAtPoint:postion];
    if (!rowIndex) {
        CGPoint tempPoint = CGPointMake(postion.x, postion.y + SSCelInterSpacing);
        rowIndex = [self.collectionView indexPathForItemAtPoint:tempPoint];
    }
    return rowIndex;
}

- (void)top_hiddenCtrlTap {
    if (_contrlView) {
        for (UIView *subView in self.contrlView.subviews) {
            if ([subView isKindOfClass:[StickerView class]]) {
                StickerView *sticker = (StickerView *)subView;
                [sticker hiddenCtrl];
                sticker.enabledMove = NO;
                [sticker removeFromSuperview];
                [self top_insertToCellView:sticker];
                break;
            }
        }
        [self.contrlView removeFromSuperview];
        self.contrlView = nil;
    }
}

#pragma mark -- 弹出签名设置视图
- (void)top_showSignatureSettingView {
    [UIView animateWithDuration:0.3
                     animations:^{
        CGRect currentFrame = self.signatureSettingView.frame;
        currentFrame.origin.y -= (CGRectGetHeight(self.signatureSettingView.frame) + TOPBottomSafeHeight + TOPNavBarAndStatusBarHeight);
        self.signatureSettingView.frame = currentFrame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark -- 收起签名设置视图
- (void)top_hiddenSignatureSettingView {
    [UIView animateWithDuration:0.3
                     animations:^{
        CGRect currentFrame = self.signatureSettingView.frame;
        currentFrame.origin.y = TOPScreenHeight;
        self.signatureSettingView.frame = currentFrame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark -- scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_collectionView) {
        return;
    }
    NSInteger page = 1;
    NSArray *items = [self.collectionView indexPathsForVisibleItems];
    if (items.count == 1) {
        page = 1;
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
            if ((rectInSuperview.origin.y + lastCell.frame.size.height / 3 * 2) <= (TOPScreenHeight - Bottom_H - TOPBottomSafeHeight)) {
                page = indexPath.item + 1;
            } else {
                page = indexPath.item;
            }
        } else {
            return;
        }
    }
    if (self.dataArray.count > 1) {
        self.currentPage = page;
        self.pageLab.text = [NSString stringWithFormat:@"%@/%@",@(page),@(self.dataArray.count)];
    }
}

#pragma mark - UICollectionViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        return self.contentView;
    }
    return nil;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (scrollView == self.scrollView) {
        CGSize endScaleContentSize = scrollView.contentSize;
        CGFloat insetBottom = (endScaleContentSize.height - scrollView.bounds.size.height) / scale;
        self.collectionView.contentInset = UIEdgeInsetsMake(10, 15, insetBottom, 15);//UIEdgeInsetsMake(0, 0, insetBottom, 0);
        CGSize zeroSize = CGSizeMake(endScaleContentSize.width, 0);
        CGPoint lastOffset = self.scrollView.contentOffset;
        self.scrollView.contentSize = zeroSize;
        // 修复偏移
        CGFloat newOffsetX = self.collectionView.contentOffset.x;
        CGFloat newOffsetY = self.collectionView.contentOffset.y + lastOffset.y / scale;
        CGPoint newOffset = CGPointMake(newOffsetX, newOffsetY);
        [self.collectionView setContentOffset:newOffset animated:NO];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TOPEditPDFViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPEditPDFViewCell class]) forIndexPath:indexPath];
    cell.contentView.backgroundColor = kWhiteColor;
    TOPEditPDFModel *picModel = self.dataArray[indexPath.item];
    __weak typeof(self) weakSelf = self;
    cell.top_beginReformBlock = ^(StickerView * _Nonnull dragView) {
        [weakSelf top_bringToTopLayer:dragView atCellIndex:indexPath.item];
    };
    [cell top_configCellWithData:picModel];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TOPEditPDFModel *model = self.dataArray[indexPath.item];
    return model.cellSize;
}

#pragma mark -- lazy
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = 3.0;
        scrollView.bouncesZoom = NO;
        scrollView.bounces = NO;
        scrollView.delegate = self;
        scrollView.frame = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight - Bottom_H - TOPBottomSafeHeight);
        [self.view addSubview:scrollView];
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(Bottom_H + TOPBottomSafeHeight));
        }];
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.frame = self.scrollView.bounds;
        [self.scrollView addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 10;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        collectionView.bouncesZoom = NO;
        collectionView.bounces = NO;
        collectionView.frame = self.contentView.bounds;
        collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:ViewBgColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.contentInset = UIEdgeInsetsMake(10, 15, 10, 15);
        _collectionView = collectionView;
        [_collectionView registerClass:[TOPEditPDFViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPEditPDFViewCell class])];
    }
    return _collectionView;
}

- (UILabel *)pageLab {
    if (!_pageLab) {
        UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 32, 20)];
        noClassLab.textColor = kTopicBlueColor;
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_R_FONT_(11);
        noClassLab.text = @"";
        noClassLab.backgroundColor = RGBA(36, 196, 164, 0.2);
        noClassLab.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:noClassLab];
        _pageLab = noClassLab;
    }
    return _pageLab;
}

#pragma mark -- lazy
- (TOPUIThroughSuperView *)contrlView {
    __weak typeof(self) weakSelf = self;
    if (!_contrlView) {
        _contrlView = [[TOPUIThroughSuperView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.contentSize.width, self.collectionView.contentSize.height)];
        _contrlView.backgroundColor = [UIColor clearColor];
        [self.collectionView addSubview:_contrlView];
        _contrlView.tapViewBlock = ^{
            [weakSelf top_hiddenCtrlTap];
            [weakSelf top_hiddenSignatureSettingView];
        };
    }
    return _contrlView;
}

- (TOPPDFSignatureSettingView *)signatureSettingView {
    if (!_signatureSettingView) {
        _signatureSettingView = [[TOPPDFSignatureSettingView alloc] init];
        _signatureSettingView.saturationValue = self.contrastValue;
        _signatureSettingView.currentColor = [UIColor blackColor];
    }
    return _signatureSettingView;
}

@end
