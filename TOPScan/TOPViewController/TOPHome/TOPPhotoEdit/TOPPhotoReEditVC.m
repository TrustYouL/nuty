#define AdjustView_H 120

#import "TOPPhotoReEditVC.h"
#import "TOPScameraBatchBottomView.h"
#import "AppDelegate.h"
#import "TOPHomeChildViewController.h"
#import "TOPReEditCollectionViewCell.h"
#import "TOPPhotoEditScrollView.h"
#import "TOPPhotoAdjustView.h"
#import "TOPDataTool.h"
#import "TOPReEditModel.h"
#import "TOPSignatureViewController.h"
#import "TOPPhotoCombineSignatureVC.h"
#import "TOPGraffitiViewController.h"
#import "TOPGraffitiLabelViewController.h"
#import "TOPPhotoShowOCRVC.h"
#import "TOPCornerToast.h"
#import "UIButton+LongTap.h"
#import "TOPTrackingSliderView.h"
#import "TOPBaseNavViewController.h"
#import "TOPPhotoReEditFinishVC.h"
@interface TOPPhotoReEditVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TOPTrackingSliderViewDelegate>{
}
@property (nonatomic ,strong)CIContext * context;
@property (nonatomic ,strong)CIFilter * colorControlsFilter;
@property (nonatomic ,strong)TOPPhotoEditScrollView * showImgView;
@property (nonatomic ,strong)TOPScameraBatchBottomView *bottomView;
@property (nonatomic ,strong)TOPTrackingSliderView * brightnessSliderView;
@property (nonatomic ,strong)TOPTrackingSliderView * contrastSliderView;
@property (nonatomic ,strong)UIView * brightnessBackView;
@property (nonatomic ,strong)UIView * contrastBackView;
@property (nonatomic ,strong)UICollectionView * myCollectionView;
@property (nonatomic ,strong)NSMutableDictionary * saveShowDic;
@property (nonatomic ,assign)BOOL isNewDocument;
@property (nonatomic ,strong)GPUImagePicture * imageSource;
@property (nonatomic ,copy)NSString * addStr;
@property (nonatomic ,assign)NSInteger lastRow;
@property (nonatomic ,strong)DocumentModel * ocrModel;
@property (nonatomic ,assign)BOOL isOCRImg;
@property (nonatomic ,assign)BOOL isCIContextDispath;
@end

@implementation TOPPhotoReEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(top_receiveNofitication:) name:TOP_TRPhotoReEditVCNotification object:nil];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    
    [self top_elementDefault];
    [self top_setupUI];
    [self top_controlsFilterDefaultState];
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBelongTemporaryPathString:TOP_TRDrawingImageFileString]];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TOP_TRSaveSignatureImageKey];
    [self top_loadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    BOOL refresh = [[NSUserDefaults standardUserDefaults] boolForKey:TOP_TRSaveSignatureImageKey];
    if (refresh) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TOP_TRSaveSignatureImageKey];
        [self top_refreshDrawingImage];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
#pragma mark -- 设置一些属性的初始值
- (void)top_elementDefault{
    _isOCRImg = NO;
    _lastRow = [TOPScanerShare top_defaultProcessType];
    self.isCIContextDispath = NO;
    if (self.model.docId) {
        TOPImageFile *imgFile = [TOPDBQueryService top_imageFileById:self.model.docId];
        if (imgFile.filterMode) {
            self.lastRow = imgFile.filterMode;
        }
    }
    if (self.pathString.length>0) {
        self.isNewDocument = YES;
        NSString * documentStr = [TOPDocumentHelper top_appBoxDirectory];
        NSString * addStr = [[self.pathString componentsSeparatedByString:documentStr] lastObject];
        self.addStr = addStr;
    }
}
- (void)top_controlsFilterDefaultState{
    self.context = [CIContext contextWithOptions:nil];
    self.colorControlsFilter = [CIFilter filterWithName:@"CIColorControls"];
    GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:self.cropImage];
    if (imageSource) {
        self.imageSource = imageSource;
        if (self.lastRow == TOPProcessTypeOriginal) {
            self.showImgView.mainImage = self.cropImage;
            [self top_updateControlsFilter];
            return;
        }
        [self top_drawingPhotoFirstTime];
    }
}
- (void)top_receiveNofitication:(NSNotification *)not{
    NSString *filePath = [TOPDocumentHelper top_getBelongTemporaryPathString:TOP_TROCRDrawingImageFileString];
    DocumentModel *dtModel = [TOPDataModelHandler top_buildImageModelWithName:TOP_TRDrawingImageJPGString atPath:filePath];
    self.ocrModel = dtModel;
}
- (void)top_setupUI{
    TOPImageTitleButton * backBtn = [[TOPImageTitleButton alloc]initWithFrame:CGRectMake(0, TOPStatusBarHeight, 44, 44)];
    backBtn.backgroundColor = [UIColor clearColor];
    if (isRTL()) {
        [backBtn setImage:[UIImage imageNamed:@"top_RTLbackItem"] forState:UIControlStateNormal];
        backBtn.style = EImageLeftTitleRightCenter;
    }else{
        [backBtn setImage:[UIImage imageNamed:@"top_backItem"] forState:UIControlStateNormal];
        backBtn.style = EImageLeftTitleRightLeft;
    }
    [backBtn addTarget:self action:@selector(top_backNextAction) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 25)];
    UIBarButtonItem * leftBarItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    [self top_configNavRightItems];
    [self top_addBottomView];
    UIView * safeView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    safeView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    
    UIView * collectionBackView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight-100-49,TOPScreenWidth , 100)];
    collectionBackView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
    
    [self.view addSubview:collectionBackView];
    [self.view addSubview:self.myCollectionView];
    [self.view addSubview:self.showImgView];
    [self.view addSubview:safeView];


    [collectionBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+49));
        make.height.mas_equalTo(100);
    }];
    if (IS_IPAD) {
        [self.myCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+49));
            make.height.mas_equalTo(100);
            make.width.mas_equalTo([TOPPictureProcessTool top_processTypeArray].count*90);
        }];
    }else{
        [self.myCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+49));
            make.height.mas_equalTo(100);
        }];
    }
    
    [self.showImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(- (TOPBottomSafeHeight+49+100));
    }];
    
    [safeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
    self.originImage = [TOPDocumentHelper top_cropOriginalImage];
    self.cropImage = [TOPDocumentHelper top_cropShowImage];
}
#pragma mark -- 底部试图
- (void)top_addBottomView{
    if (!_bottomView) {
        WS(weakSelf);
        NSArray * picArray = @[@"top_reEdit_rote",@"top_reEdit_Addtext",@"top_reEdit_signature",@"top_reEdit_graffiti",@"top_scamerbatch_reEditAffirm"];
        NSArray * titles = @[NSLocalizedString(@"topscan_rotate", @""),NSLocalizedString(@"topscan_docaddtext", @""),NSLocalizedString(@"topscan_writesignature", @""),NSLocalizedString(@"topscan_graffiti", @""),@""];
        TOPScameraBatchBottomView * bottomView = [[TOPScameraBatchBottomView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight - TOPTabBarHeight-TOPNavBarAndStatusBarHeight, TOPScreenWidth, 49) sendPic:picArray itemNames:titles];
        bottomView.normalStateColor = kCommonBlackTextColor;
        bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        bottomView.normalArray = picArray;
        bottomView.top_longPressBootomItemHandler = ^(NSInteger index) {
            [weakSelf top_bottomViewFunctionTip:index];
        };
        self.bottomView = bottomView;
        [self.view addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
            make.height.mas_equalTo(49);
        }];
    }
}
#pragma mark -- 添加左右两边的调节试图
- (void)top_addSliderBackView{
    UIView * brightnessBackView = [[UIView alloc]initWithFrame:CGRectZero];
    brightnessBackView.layer.cornerRadius = 10;
    brightnessBackView.layer.masksToBounds = YES;
    self.brightnessBackView = brightnessBackView;
    
    UIView * contrastBackView = [[UIView alloc]initWithFrame:CGRectZero];
    contrastBackView.layer.cornerRadius = 10;
    contrastBackView.layer.masksToBounds = YES;
    self.contrastBackView = contrastBackView;
    if ([TOPDocumentHelper top_isdark]) {
        brightnessBackView.backgroundColor = RGBA(0, 0, 0, 0.7);
        contrastBackView.backgroundColor = RGBA(0, 0, 0, 0.7);
    }else{
        brightnessBackView.backgroundColor = RGBA(0, 0, 0, 0.5);
        contrastBackView.backgroundColor = RGBA(0, 0, 0, 0.5);
    }
    [self.view addSubview:brightnessBackView];
    [self.view addSubview:contrastBackView];
    [brightnessBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(-50);
        make.trailing.equalTo(self.view.mas_leading);
        make.size.mas_equalTo(CGSizeMake(80, 350));
    }];
    
    [contrastBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(-50);
        make.leading.equalTo(self.view.mas_trailing);
        make.size.mas_equalTo(CGSizeMake(80, 350));
    }];
}
- (void)top_setBrightnessBackViewChild{
    UIImageView * brightImg = [[UIImageView alloc]initWithFrame:CGRectMake(29, 35, 22, 22)];
    brightImg.image = [UIImage imageNamed:@"top_sliderbright"];
    [self.brightnessBackView addSubview:brightImg];
    [self.brightnessBackView addSubview:self.brightnessSliderView];
}
- (void)top_setcontrastBackViewChild{
    UIImageView * contrastImg = [[UIImageView alloc]initWithFrame:CGRectMake(29, 35, 22, 22)];
    contrastImg.image = [UIImage imageNamed:@"top_slidercontrast"];
    [self.contrastBackView addSubview:contrastImg];
    [self.contrastBackView addSubview:self.contrastSliderView];
}
#pragma mark -- TOPTrackingSliderViewDelegate
- (void)top_topCurrentSlider:(TOPTrackingSlider *)slider{
    if (self.brightnessSliderView.uiSlider == slider) {
        [self.colorControlsFilter setValue:[NSNumber numberWithFloat:slider.value] forKey:@"inputBrightness"];//设置滤镜参数
        [self top_setImage];
    }
    if (self.contrastSliderView.uiSlider == slider) {
        [self.colorControlsFilter setValue:[NSNumber numberWithFloat:slider.value] forKey:@"inputContrast"];
        [self top_setImage];
    }
    NSLog(@"slider===%f",slider.value);
}
#pragma mark -- 重置sdlider的初始值
- (void)top_resetSliderValue{
    self.brightnessSliderView.defaultValue = 0;
    self.contrastSliderView.defaultValue = 1;
}
- (void)top_bottomViewFunctionTip:(NSInteger)index{
    NSArray * num = [self top_bottomFunctionArray];
    switch ([num[index] integerValue]) {
        case TopReEditFinishBottomFunctionTypeRotate:
            [self top_ClickRotateBtn];
            break;
        case TopReEditFinishBottomFunctionTypeAddtext:
            [TOPDocumentHelper top_saveImage:self.showImgView.mainImage atPath:[TOPDocumentHelper top_drawingImageFileString]];
            [self top_photoShow_graffitiLabelVC];
            break;
        case TopReEditFinishBottomFunctionTypeSignature:
            [TOPDocumentHelper top_saveImage:self.showImgView.mainImage atPath:[TOPDocumentHelper top_drawingImageFileString]];
            [self top_jumpSignatureVC];
            break;
        case TopReEditFinishBottomFunctionTypeGraffiti:
            [TOPDocumentHelper top_saveImage:self.showImgView.mainImage atPath:[TOPDocumentHelper top_drawingImageFileString]];
            [self top_jumpGraffitiVC];
            break;
        case TopReEditFinishBottomFunctionTypeFinish:
            [self top_ClickFinishBtn];
            break;
        default:
            break;
    }
}
#pragma mark -- 导航栏按钮
- (void)top_configNavRightItems {
    NSArray * imageArray = @[@"top_childvc_moreOCR",@"top_scamerbatch_adjust"];
    NSMutableArray * btnArray = [NSMutableArray new];
    for (int i = 0; i<imageArray.count; i++) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        btn.tag = i+10;
        btn.selected = NO;
        [btn setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(top_ClickRightItems:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * barItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        [btnArray addObject:barItem];
        if (i == 1) {
            [btn setImage:[UIImage imageNamed:@"top_scamerbatch_AdjustSelect"] forState:UIControlStateSelected];
        }
    }
    self.navigationItem.rightBarButtonItems = btnArray;
}

#pragma mark -- toast label
- (void)top_tipLabelBut:(UILongPressGestureRecognizer *)gestureRecognizer {
    [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_docaddtext", @"")];
}

#pragma mark -- toast 签名
- (void)top_tipSignatureBut:(UILongPressGestureRecognizer *)gestureRecognizer {
    [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_writesignature", @"")];
}

#pragma mark -- toast 涂鸦
- (void)top_tipGraffitiBut:(UILongPressGestureRecognizer *)gestureRecognizer {
    [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_docgraffiti", @"")];
}

#pragma mark -- toast ocr
- (void)top_tipOcrBut:(UILongPressGestureRecognizer *)gestureRecognizer {
    [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_graffititextrecognition", @"")];
}

#pragma mark -- 加载第一张渲染图 渲染模式根据设置中心的配置项
- (void)top_drawingPhotoFirstTime {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage * image = [self top_processPictureWityType:self.lastRow];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (image) {
                NSInteger objIndex = [[TOPPictureProcessTool top_processTypeArray] indexOfObject:@(self.lastRow)];
                NSString *dicKey = [NSString stringWithFormat:@"%@",@(objIndex)];
                self.saveShowDic[dicKey] = image;
                self.showImgView.mainImage = image;
            } else {
                self.showImgView.mainImage = self.cropImage;
            }
            [self top_updateControlsFilter];
        });
    });
}

#pragma mark -- 根据所选模式进行渲染图片
- (UIImage *)top_processPictureWityType:(NSInteger)processType {
    UIImage * sendImg = self.cropImage;
    UIImage *image = [TOPDataTool top_pictureProcessData:self.imageSource withImg:sendImg withItem:processType];
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
    return image;
}

#pragma mark -- 涂鸦、签名后刷新渲染图
- (void)top_refreshDrawingImage {
    UIImage *editNewImg = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_drawingImageFileString]];
    if (editNewImg) {
        self.showImgView.mainImage = editNewImg;
        [self top_updateControlsFilter];
    }
}

#pragma mark -- 导航栏右侧按钮
- (void)top_ClickRightItems:(UIButton *)sender{
    if (sender.tag == 10) {
        sender.selected = YES;
        [TOPDocumentHelper top_saveImage:self.showImgView.mainImage atPath:[TOPDocumentHelper top_drawingOCRImageFileString]];
        [self top_jumpOCRVC];
    } else if (sender.tag == 11){
        [self top_ClickAdjustBtn:sender];
    }
}

- (void)top_jumpOCRVC{
    [FIRAnalytics logEventWithName:@"photoReEdit_jumpOCRVC" parameters:nil];
    NSString *filePath = [TOPDocumentHelper top_getBelongTemporaryPathString:TOP_TROCRDrawingImageFileString];
    NSLog(@"filePath==%@",filePath);
    NSMutableArray *dataArray = [NSMutableArray new];
    DocumentModel *dtModel = [TOPDataModelHandler top_buildImageModelWithName:TOP_TRDrawingImageJPGString atPath:filePath];
    [dataArray addObject:dtModel];
    NSLog(@"dtModel==%@",dtModel);
    UIImage * img = [[UIImage alloc]initWithContentsOfFile:dtModel.imagePath];

    if (img) {
        TOPPhotoShowOCRVC * ocrVC = [TOPPhotoShowOCRVC new];
        ocrVC.currentIndex = 0;
        ocrVC.dataArray = dataArray;
        ocrVC.backType = TOPPhotoShowTextAgainVCBackTypePopReEdit;
        ocrVC.ocrAgain = TOPPhotoShowOCRVCAgainTypeOCRAgain;
        ocrVC.finishType = TOPPhotoShowOCRVCAgainFinishNot;
        ocrVC.dataType = TOPOCRDataTypeSingleDocument;
        ocrVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ocrVC animated:YES];
    }
}
#pragma mark -- 跳转到涂鸦模块
- (void)top_jumpGraffitiVC {
    [FIRAnalytics logEventWithName:@"photoReEdit_jumpGraffitiVC" parameters:nil];
    TOPGraffitiViewController *singVC = [[TOPGraffitiViewController alloc] init];
    singVC.imagePath = [TOPDocumentHelper top_drawingImageFileString];
    singVC.noCreateFile = YES;
    singVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:singVC animated:YES];
    __weak typeof(self) weakSelf = self;
    singVC.top_saveGraffitiImgBlick = ^{
        [weakSelf top_refreshDrawingImage];
    };
}

#pragma mark -- 跳转到签名模块
- (void)top_jumpSignatureVC {
    [FIRAnalytics logEventWithName:@"photoReEdit_jumpSignatureVC" parameters:nil];
    NSData *signatureData = [NSData dataWithContentsOfFile:[TOPSignationImagePath stringByAppendingPathComponent:TOP_TRSignationImageName]];
    if (signatureData.length) {
        [self top_photoShow_signaturePreView];
    } else {
        [self top_photoShow_signatureOnImage];
    }
}

#pragma mark -- 签名
- (void)top_photoShow_signatureOnImage {
    [FIRAnalytics logEventWithName:@"photoReEdit_signatureOnImage" parameters:nil];
    TOPSignatureViewController *singVC = [[TOPSignatureViewController alloc] init];
    singVC.imagePath = [TOPDocumentHelper top_drawingImageFileString];
    singVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:singVC animated:YES];
}

#pragma mark -- 签名预览
- (void)top_photoShow_signaturePreView {
    [FIRAnalytics logEventWithName:@"photoReEdit_signaturePreView" parameters:nil];
    TOPPhotoCombineSignatureVC *photoeditSign = [[TOPPhotoCombineSignatureVC alloc] init];
    photoeditSign.imagePath = [TOPDocumentHelper top_drawingImageFileString];
    photoeditSign.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:photoeditSign animated:YES];
    __weak typeof(self) weakSelf = self;
    photoeditSign.top_saveSignatureImgBlick = ^{
        [weakSelf top_refreshDrawingImage];
    };
}

#pragma mark -- 文字label
- (void)top_photoShow_graffitiLabelVC {
    [FIRAnalytics logEventWithName:@"photoReEdit_graffitiLabelVC" parameters:nil];
    TOPGraffitiLabelViewController *labelVC = [[TOPGraffitiLabelViewController alloc] init];
    labelVC.imagePath = [TOPDocumentHelper top_drawingImageFileString];
    labelVC.noCreateFile = YES;
    labelVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:labelVC animated:YES];
    __weak typeof(self) weakSelf = self;
    labelVC.top_saveEditedImgBlick = ^{
        [weakSelf top_refreshDrawingImage];
    };
}

- (void)top_loadData{
    NSInteger currentIndex = 0;
    NSArray * compareArray = [TOPDocumentHelper top_sortPicsAtPath:TOPDefaultDraw_Path];
    for (int i = 0; i < [TOPPictureProcessTool top_processTypeArray].count; i++) {
        NSInteger processType = [[TOPPictureProcessTool top_processTypeArray][i] integerValue];
        TOPReEditModel * model = [[TOPReEditModel alloc] init];
        UIImage * getImg = nil;
        if (i < compareArray.count) {
            getImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@",TOPDefaultDraw_Path,compareArray[i]]];
        }
        if (!getImg) {
            NSString *path = [[TOPDocumentHelper top_getCropImageFileString] stringByAppendingPathComponent:TOP_TRCropShowImageString];
            NSData *imgData = [NSData dataWithContentsOfFile:path];
            UIImage * drawImg = [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(80*3, 90*3)];
            GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:drawImg];
            getImg = [TOPDataTool top_pictureProcessData:imageSource withImg:drawImg withItem:processType];
            [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
        }
        if (getImg) {
            model.dic = [TOPDataTool top_pictureProcessDatawithImg:getImg currentItem:processType];
        }
        if (processType == self.lastRow) {
            model.isSelect = YES;
            currentIndex = i;
        }else{
            model.isSelect = NO;
        }
        model.processType = processType;
        [self.showArray addObject:model];
        getImg = nil;
    }
    [self.myCollectionView reloadData];
    [self.myCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

#pragma mark -UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.showArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPReEditCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPReEditCollectionViewCell class]) forIndexPath:indexPath];
    TOPReEditModel * model = self.showArray[indexPath.item];
    cell.model = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.showImgView.zoomScale = 1.0;
    NSInteger processType = [[TOPPictureProcessTool top_processTypeArray][indexPath.item] integerValue];
    NSInteger filterIndex= [[TOPPictureProcessTool top_processTypeArray] indexOfObject:@(self.lastRow)];
    NSString *filterKey = [NSString stringWithFormat:@"isfilter%@",@(filterIndex)];
    NSInteger isfilter = [self.saveShowDic[filterKey] integerValue];
    [self top_addFIRAnalytics:processType];
    if (processType == self.lastRow&&!isfilter) {
        return;
    }
    UIImage *editNewImg = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_drawingImageFileString]];
    if (editNewImg) {
        [self top_clearMarksAlert:indexPath];
    } else {
        [self top_handleShowPhoto:indexPath];
    }
}

#pragma mark -- 添加埋点
- (void)top_addFIRAnalytics:(NSInteger)processType{
    switch (processType) {
        case TOPProcessTypeOriginal:
            [FIRAnalytics logEventWithName:@"photoReEdit_ProcessTypeOriginal" parameters:nil];
            break;
        case TOPProcessTypeMagicColor:
            [FIRAnalytics logEventWithName:@"photoReEdit_ProcessTypeMagicColor" parameters:nil];
            break;
        case TOPProcessTypeBW:
            [FIRAnalytics logEventWithName:@"photoReEdit_ProcessTypeBW" parameters:nil];
            break;
        case TOPProcessTypeBW2:
            [FIRAnalytics logEventWithName:@"photoReEdit_ProcessTypeBW2" parameters:nil];
            break;
        case TOPProcessTypeGrayscale:
            [FIRAnalytics logEventWithName:@"photoReEdit_ProcessTypeGrayscale" parameters:nil];
            break;
        case TOPProcessTypeNostalgic:
            [FIRAnalytics logEventWithName:@"photoReEdit_ProcessTypeNostalgic" parameters:nil];
            break;
        default:
            break;
    }
}
#pragma mark -- 是否清除签名、涂鸦后的图片
- (void)top_clearMarksAlert:(NSIndexPath *)indexPath {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_clearmarks", @"")
                                                                   message:NSLocalizedString(@"topscan_markstip", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_clear", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_drawingImageFileString]];
        [self top_handleShowPhoto:indexPath];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 处理加载当前渲染模式的图片
- (void)top_handleShowPhoto:(NSIndexPath *)indexPath {
    if ([TOPPictureProcessTool top_processTypeArray].count > indexPath.item) {
        NSInteger processType = [[TOPPictureProcessTool top_processTypeArray][indexPath.item] integerValue];
        NSString *dicKey = [NSString stringWithFormat:@"%@",@(indexPath.item)];
        NSString *filterKey = [NSString stringWithFormat:@"isfilter%@",@(indexPath.item)];
        UIImage *selectImg = self.saveShowDic[dicKey];
        NSInteger isfilter = [self.saveShowDic[filterKey] integerValue];
        self.lastRow = processType;
        if (selectImg&&!isfilter) {
            self.showImgView.mainImage = selectImg;
            [self top_resetSliderValue];
            [self top_refreshProcessSelected:indexPath.item];
        } else {
            [SVProgressHUD show];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [self top_processPictureWityType:processType];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (image) {
                        self.saveShowDic[dicKey] = image;
                        self.saveShowDic[filterKey] = @(0);
                        self.showImgView.mainImage = image;
                    } else {
                        self.showImgView.mainImage = self.cropImage;
                    }
                    [self top_resetSliderValue];
                    [self top_refreshProcessSelected:indexPath.item];
                    [self top_updateControlsFilter];
                });
            });
        }
    }
}

#pragma mark -- 刷新渲染模式选中项
- (void)top_refreshProcessSelected:(NSInteger)selectIndex {
    for (TOPReEditModel * model in self.showArray) {
        if ([self.showArray indexOfObject:model] == selectIndex) {
            model.isSelect = YES;
        }else{
            model.isSelect = NO;
        }
    }
    [self.myCollectionView reloadData];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (void)top_ClickFinishBtn{
    [FIRAnalytics logEventWithName:@"photoReEdit_ClickFinishBtn" parameters:nil];
    [self top_writeToFile];
}

- (void)top_ClickAdjustBtn:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (!self.brightnessBackView||!self.contrastBackView) {
        [self top_addSliderBackView];
        [self top_setBrightnessBackViewChild];
        [self top_setcontrastBackViewChild];
    }
    if (sender.selected) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                [self.brightnessBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.view).offset(-50);
                    make.leading.equalTo(self.view).offset(-10);
                    make.size.mas_equalTo(CGSizeMake(80, 350));
                }];
                [self.contrastBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.view).offset(-50);
                    make.trailing.equalTo(self.view).offset(10);
                    make.size.mas_equalTo(CGSizeMake(80, 350));
                }];
                [self.view layoutIfNeeded];
            }];
        });
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                [self.brightnessBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.view).offset(-50);
                    make.trailing.equalTo(self.view.mas_leading);
                    make.size.mas_equalTo(CGSizeMake(80, 350));
                }];
                [self.contrastBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.view).offset(-50);
                    make.leading.equalTo(self.view.mas_trailing);
                    make.size.mas_equalTo(CGSizeMake(80, 350));
                }];
                [self.view layoutIfNeeded];
            }];
        });
    }
}
#pragma mark -- 更新滤镜
- (void)top_updateControlsFilter {
    UIImage * contextImg = self.showImgView.mainImage;
    NSData * imgData = UIImageJPEGRepresentation(contextImg, TOP_TRPicScale);
    if (imgData) {
        CIImage * get = [CIImage imageWithData:imgData];
        [self.colorControlsFilter setValue:get forKey:@"inputImage"];
    }
}

#pragma mark -- 点击旋转按钮
- (void)top_ClickRotateBtn{
    [FIRAnalytics logEventWithName:@"photoReEdit_ClickRotateBtn" parameters:nil];
    UIImage *editNewImg = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_drawingImageFileString]];
    if (editNewImg) {
        [self top_clearEditImageAlert];
    } else {
        [self top_rotateShowImage];
    }
}

#pragma mark -- 旋转图片
- (void)top_rotateShowImage {
    UIImage *showImage = [self top_currentDrawingShowImage];
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage * rotationImg = [TOPDocumentHelper top_image:showImage rotation:UIImageOrientationRight];
        UIImage * cropImg = [TOPDocumentHelper top_image:self.cropImage rotation:UIImageOrientationRight];
        for (TOPReEditModel * model in self.showArray) {
            UIImage * image = model.dic[@"image"];
            UIImage * showRotaImg = [TOPDocumentHelper top_image:image rotation:UIImageOrientationRight];
            model.dic = [TOPDataTool top_pictureProcessDatawithImg:showRotaImg currentItem:model.processType];
        }
        
        for (int i = 0; i < [TOPPictureProcessTool top_processTypeArray].count; i++) {
            NSString *dicKey = [NSString stringWithFormat:@"%@",@(i)];
            [self.saveShowDic removeObjectForKey:dicKey];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            self.showImgView.mainImage = rotationImg;
            [self top_saveDrawingShowImage:rotationImg];
            self.cropImage = cropImg;
            self.imageSource = [[GPUImagePicture alloc] initWithImage:self.cropImage];
            [self.myCollectionView reloadData];
            [self top_updateControlsFilter];
        });
    });
}

#pragma mark -- 是否清除签名、涂鸦后的图片
- (void)top_clearEditImageAlert {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_clearmarks", @"")
                                                                   message:NSLocalizedString(@"topscan_markstip", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_clear", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_drawingImageFileString]];
        [self top_rotateShowImage];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 亮度 对比度调节
- (void)top_setImage{
    if (!self.isCIContextDispath) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.isCIContextDispath = YES;
            UIImage *currentImg = [self top_currentDrawingShowImage];
            CIImage * outputImage = [self.colorControlsFilter outputImage];
            CGImageRef temp = [self.context createCGImage:outputImage fromRect:[outputImage extent]];
            UIImage * showImage = [UIImage imageWithCGImage:temp];
            UIImage * saveImg = [UIImage imageWithCGImage:showImage.CGImage scale:showImage.scale orientation:currentImg.imageOrientation];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isCIContextDispath = NO;
                NSInteger processIndex= [[TOPPictureProcessTool top_processTypeArray] indexOfObject:@(self.lastRow)];
                NSString *dicKey = [NSString stringWithFormat:@"%@",@(processIndex)];
                NSString *filterKey = [NSString stringWithFormat:@"isfilter%@",@(processIndex)];

                self.saveShowDic[dicKey] = saveImg;
                self.saveShowDic[filterKey] = @(1);
                self.showImgView.mainImage = saveImg;
                CGImageRelease(temp);
            });
        });
    }
}

- (void)top_writeToFile{
    WS(weakSelf);
    if ([TOPScanerShare top_saveToGallery] == TOPSettingSaveYES) {
        [TOPDocumentHelper top_saveImagePathArray:@[self.showImgView.mainImage] toFolder:TOPSaveToGallery_Path tipShow:NO showAlter:^(BOOL isExisted) {
            if (!isExisted) {
                [SVProgressHUD dismiss];
                [TOPDocumentHelper top_creatGalleryFolder:TOPSaveToGallery_Path];
                TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_albumpermissiontitle", @"")
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
            }else{
                [weakSelf top_saveFile];
            }
        }];
    }else{
        [self top_saveFile];
    }
}

- (void)top_saveFile{
    switch (self.fileType) {
        case TOPShowFolderCameraType:
        case TOPShowNextFolderCameraType:
        case TOPEnterHomeCameraTypeLibrary:
        case TOPEnterNextFolderCameraTypeLibrary:
        case TOPShowToTextCameraType:
        case TOPShowIDCardCameraType:
        {
            [self top_goBackFromFolderCameraVC];
            [self top_removeSaveFile];
        }
            break;
        case TOPShowDocumentCameraType:
        {
            [self top_goBackFromDocumentCameraVC];
            [self top_removeSaveFile];
        }
            break;
        case TOPShowPhotoShowReEditType:
        {
            [self top_goBackFromPhotoShowVC];
        }
            break;
        case TOPShowPhotoShowCameraType:
        {
            [self top_goBackFromPhotoShowVC];
            [self top_removeSaveFile];
        }
            break;
        default:
            break;
    }
}
#pragma mark -- 渲染完成返回
#pragma mark -- 在Folder从相机入口进入
- (void)top_goBackFromFolderCameraVC {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DocumentModel *fileModel = [TOPFileDataManager shareInstance].docModel;
        NSString *filePath = fileModel.path;
        NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:filePath];
        
        NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:0],TOP_TRJPGPathSuffixString];
        NSString *fileEndPath =  [endPath stringByAppendingPathComponent:fileName];
        NSString *soureFileEndPath =  [TOPDocumentHelper top_originalImage:fileEndPath];

        BOOL result = [self top_saveDrawingShowImageAtPath:fileEndPath];
        if ([TOPWHCFileManager top_isExistsAtPath:self.ocrModel.ocrPath]) {
            NSString * ocrString = [TOPDocumentHelper top_getTxtContent:self.ocrModel.ocrPath];
            NSString * ocrPath = [TOPDocumentHelper top_getTxtPath:endPath imgPriName:fileName txtType:@""];
            [ocrString writeToFile:ocrPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveYES) {
            [TOPDocumentHelper top_saveImage:self.originImage atPath:soureFileEndPath];
        }
        
        UIImage *editNewImg = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_drawingImageFileString]];
        if (editNewImg) {
            NSString *fileName1  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:1],TOP_TRJPGPathSuffixString];
            NSString *newImgPath = [endPath stringByAppendingPathComponent:fileName1];
            [TOPDocumentHelper top_saveImage:self.showImgView.mainImage atPath:newImgPath];
            if ([TOPWHCFileManager top_isExistsAtPath:self.ocrModel.ocrPath]) {
                NSString * ocrString = [TOPDocumentHelper top_getTxtContent:self.ocrModel.ocrPath];
                NSString * ocrPath = [TOPDocumentHelper top_getTxtPath:endPath imgPriName:fileName1 txtType:@""];
                [ocrString writeToFile:ocrPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
            if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveYES) {
                NSString *newOriginalPath = [TOPDocumentHelper top_originalImage:newImgPath];
                if ([TOPWHCFileManager top_isExistsAtPath:soureFileEndPath]) {
                    [TOPWHCFileManager top_copyItemAtPath:soureFileEndPath toPath:newOriginalPath];
                }
            }
        }
        TOPAppDocument *appDoc = [TOPEditDBDataHandler top_addDocumentAtFolder:endPath WithParentId:fileModel.docId];
        DocumentModel *newDoc = [TOPDBDataHandler top_buildDocumentModelWithData:appDoc];
        [TOPDocumentHelper top_createDocumentAddTags:endPath];
        [self top_writeImageFilterData:appDoc];
        
        NSString *tagsPaht = [endPath stringByAppendingPathComponent:TOP_TRTagsPathString];
        NSArray *contents = [TOPWHCFileManager top_listFilesInDirectoryAtPath:tagsPaht deep:NO];
        if (contents.count) {
            NSString *tag = contents.firstObject;
            [TOPEditDBDataHandler top_updateDocumentTags:@{@"tags": [NSString stringWithFormat:@"%@/",tag]} byDocIds:@[appDoc.Id]];
        }
        if(result ==YES){
            NSLog(@"保存成功");
            [TOPWHCFileManager top_removeItemAtPath:TOPDefaultDraw_Path];
        }
        
        if ([TOPScanerShare top_lastFilterType] !=0) {
            [TOPScanerShare top_writeDefaultProcessType:self->_lastRow];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            TOPPhotoReEditFinishVC * reEditVC = [TOPPhotoReEditFinishVC new];
            reEditVC.pathString = endPath;
            reEditVC.docModel = newDoc;
           
            TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:reEditVC];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:nil];
            [[TOPDocumentHelper top_getPushVC].navigationController presentViewController:nav animated:YES completion:nil];
        });
    });
}

#pragma mark -- 写入图片的裁剪、渲染、朝向数据
- (void)top_writeImageFilterData:(TOPAppDocument *)appDoc {
    if (appDoc.images.count) {
        for (TOPImageFile *imgFile in appDoc.images) {
            [self top_updateFilterData:imgFile];
        }
    }
}

- (void)top_updateFilterData:(TOPImageFile *)imgFile {
    NSDictionary *param = @{@"orientation":@(self.cropImage.imageOrientation),
                            @"filter":@(self.lastRow),
                            @"points":self.cropPoints,
                            @"autoPoints":self.autoCropPoints};
    [TOPEditDBDataHandler top_updateImageWithHandler:param byId:imgFile.Id];
}

#pragma mark -- 在Document从相机入口进入
- (void)top_goBackFromDocumentCameraVC {
    NSArray *sortArray = [self.dataArray sortedArrayUsingComparator:^NSComparisonResult(DocumentModel *model1, DocumentModel *model2) {
        return [model1.numberIndex compare:model2.numberIndex options:NSNumericSearch];
    }];
    DocumentModel *model  = sortArray.lastObject;
    
    NSLog(@"最后一个 %@",model.numberIndex);
    NSString *endNum = [NSString stringWithFormat:@"%ld",[model.numberIndex integerValue] + 1];
    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],endNum,TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [self.pathString stringByAppendingPathComponent:fileName];
    NSString *soureFileEndPath =  [TOPDocumentHelper top_originalImage:fileEndPath];
    BOOL result = [self top_saveDrawingShowImageAtPath:fileEndPath];
    if ([TOPWHCFileManager top_isExistsAtPath:self.ocrModel.ocrPath]) {
        NSString * ocrString = [TOPDocumentHelper top_getTxtContent:self.ocrModel.ocrPath];
        NSString * ocrPath = [TOPDocumentHelper top_getTxtPath:self.pathString imgPriName:fileName txtType:@""];
        [ocrString writeToFile:ocrPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveYES) {
        [TOPDocumentHelper top_saveImage:self.originImage atPath:soureFileEndPath];
    }
    UIImage *editNewImg = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_drawingImageFileString]];
    if (editNewImg) {
        NSString *endNum1 = [NSString stringWithFormat:@"%ld",[model.numberIndex integerValue] + 2];
        NSString *fileName1  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],endNum1,TOP_TRJPGPathSuffixString];
        NSString *newImgPath = [self.pathString stringByAppendingPathComponent:fileName1];
        [TOPDocumentHelper top_saveImage:self.showImgView.mainImage atPath:newImgPath];
        [self top_addImageData:fileName1 withDocId:[TOPFileDataManager shareInstance].docModel.docId];
        if ([TOPWHCFileManager top_isExistsAtPath:self.ocrModel.ocrPath]) {
            NSString * ocrString = [TOPDocumentHelper top_getTxtContent:self.ocrModel.ocrPath];
            NSString * ocrPath = [TOPDocumentHelper top_getTxtPath:self.pathString imgPriName:fileName1 txtType:@""];
            [ocrString writeToFile:ocrPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveYES) {
            NSString *newOriginalPath = [TOPDocumentHelper top_originalImage:newImgPath];
            if ([TOPWHCFileManager top_isExistsAtPath:soureFileEndPath]) {
                [TOPWHCFileManager top_copyItemAtPath:soureFileEndPath toPath:newOriginalPath];
            }
        }
    }
 
    if ([TOPScanerShare top_lastFilterType] !=0) {
        [TOPScanerShare top_writeDefaultProcessType:_lastRow];
    }
    
    if(result == YES){
        [TOPWHCFileManager top_removeItemAtPath:TOPDefaultDraw_Path];
        [self top_addImageData:fileName withDocId:[TOPFileDataManager shareInstance].docModel.docId];
        if ([TOPScanerShare shared].isPush) {
            [TOPScanerShare shared].isPush = NO;
            TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
            childVC.docModel = [TOPFileDataManager shareInstance].docModel;
            childVC.pathString = self.pathString;
            childVC.addType = @"add";
            childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
            childVC.hidesBottomBarWhenPushed = YES;
            [[TOPDocumentHelper top_getPushVC].navigationController pushViewController:childVC animated:YES];
            [[TOPDocumentHelper top_getPushVC].navigationController dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark -- 增加新图片数据
- (void)top_addImageData:(NSString *)fileName withDocId:(NSString *)docId {
    [TOPEditDBDataHandler top_addImageFileAtDocument:@[fileName] WithId:docId];
    RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:docId withName:fileName];
    if (images.count) {
        [self top_updateFilterData:images.firstObject];
    }
}

#pragma mark -- 从图片详情界面进入
- (void)top_goBackFromPhotoShowVC {
    [TOPWHCFileManager top_removeItemAtPath:self.model.coverImagePath];
    [self top_saveNewGraffitiImage];
    BOOL result = [self top_saveDrawingShowImageAtPath:self.model.imagePath];
    if ([TOPWHCFileManager top_isExistsAtPath:self.ocrModel.ocrPath]) {
        NSString * ocrString = [TOPDocumentHelper top_getTxtContent:self.ocrModel.ocrPath];
        NSString * ocrPath = [TOPDocumentHelper top_getTxtPath:self.model.movePath imgName:self.model.photoIndex txtType:@""];
        [ocrString writeToFile:ocrPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    if (self.fileType == TOPShowPhotoShowCameraType) {
        if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveYES) {
            [TOPDocumentHelper top_saveImage:self.originImage atPath:self.model.originalImagePath];
        }
    }
    
    if ([TOPScanerShare top_lastFilterType] !=0) {
        [TOPScanerShare top_writeDefaultProcessType:_lastRow];
    }
    
    if(result){
        [TOPEditDBDataHandler top_updateImageWithId:[TOPFileDataManager shareInstance].docModel.docId];
        TOPImageFile *imgFile = [TOPDBQueryService top_imageFileById:[TOPFileDataManager shareInstance].docModel.docId];
        [self top_updateFilterData:imgFile];
        [TOPWHCFileManager top_removeItemAtPath:TOPDefaultDraw_Path];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -- 保存渲染图
- (BOOL)top_saveDrawingShowImageAtPath:(NSString *)path {
    UIImage *selectImg = [self top_currentDrawingShowImage];
    if (![TOPWHCFileManager top_isExistsAtPath:[TOPDocumentHelper top_drawingImageFileString]]) {
        selectImg = self.showImgView.mainImage;
    }
    BOOL result = [TOPDocumentHelper top_saveImage:selectImg atPath:path];
    return result;
}

#pragma mark -- 当前渲染模式的渲染图
- (UIImage *)top_currentDrawingShowImage {
    NSInteger processIndex= [[TOPPictureProcessTool top_processTypeArray] indexOfObject:@(self.lastRow)];
    NSString *dicKey = [NSString stringWithFormat:@"%@",@(processIndex)];
    UIImage *selectImg = self.saveShowDic[dicKey];
    if (!selectImg) {
        selectImg = self.cropImage;
    }
    return selectImg;
}

- (void)top_saveDrawingShowImage:(UIImage *)img {
    if (img) {
        NSInteger processIndex= [[TOPPictureProcessTool top_processTypeArray] indexOfObject:@(self.lastRow)];
        NSString *dicKey = [NSString stringWithFormat:@"%@",@(processIndex)];
        self.saveShowDic[dicKey] = img;
    }
}

#pragma mark -- 新增一张涂鸦、签名照并保存源图
- (void)top_saveNewGraffitiImage {
    UIImage *editNewImg = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_drawingImageFileString]];
    if (editNewImg) {
        [self top_saveNewGraffitiImageAndOCRTxt:self.showImgView.mainImage];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TOP_TRAddNewSignatureImageKey];
    }
}

- (NSString *)top_newImagePath {
    NSString *docPath = [TOPWHCFileManager top_directoryAtPath:self.model.imagePath];
    NSString *fileName = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:[TOPDocumentHelper top_maxImageNumIndexAtPath:docPath]],TOP_TRJPGPathSuffixString];
    NSString *newImgPath = [docPath stringByAppendingPathComponent:fileName];
    return newImgPath;
}

- (void)top_saveNewGraffitiImageAndOCRTxt:(UIImage *)editNewImg{
    NSString *docPath = [TOPWHCFileManager top_directoryAtPath:self.model.imagePath];
    NSString *fileName = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:[TOPDocumentHelper top_maxImageNumIndexAtPath:docPath]],TOP_TRJPGPathSuffixString];
    NSString *newImgPath = [docPath stringByAppendingPathComponent:fileName];
    [TOPDocumentHelper top_saveImage:editNewImg atPath:newImgPath];

    TOPImageFile *img = [TOPDBQueryService top_imageFileById:[TOPFileDataManager shareInstance].docModel.docId];
    [self top_addImageData:fileName withDocId:img.parentId];
    if ([TOPWHCFileManager top_isExistsAtPath:self.ocrModel.ocrPath]) {
        NSString * ocrString = [TOPDocumentHelper top_getTxtContent:self.ocrModel.ocrPath];
        NSString * ocrPath = [TOPDocumentHelper top_getTxtPath:docPath imgPriName:fileName txtType:@""];
        [ocrString writeToFile:ocrPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveYES) {
        NSString *newOriginalPath = [TOPDocumentHelper top_originalImage:newImgPath];
        NSString *originalImgPath = self.model.originalImagePath;
        if ([TOPWHCFileManager top_isExistsAtPath:originalImgPath]) {
            [TOPWHCFileManager top_copyItemAtPath:originalImgPath toPath:newOriginalPath];
        }
    }
}
- (void)top_backNextAction{
    UIImage *editNewImg = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_drawingImageFileString]];
    if (editNewImg) {
        [self top_clearSaveImageAlert];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -- 返回时是否清除签名、涂鸦后的图片
- (void)top_clearSaveImageAlert {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_clearmarks", @"")
                                                                   message:NSLocalizedString(@"topscan_markstip", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_clear", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- lazy
- (UICollectionView *)myCollectionView{
    if (!_myCollectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(90, 90);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _myCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight-100-49,TOPScreenWidth , 100) collectionViewLayout:layout];
        _myCollectionView.dataSource = self;
        _myCollectionView.delegate = self;
        _myCollectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _myCollectionView.showsVerticalScrollIndicator = NO;
        _myCollectionView.showsHorizontalScrollIndicator = NO;
        if (IS_IPAD) {
            _myCollectionView.scrollEnabled = NO;
        }
        [_myCollectionView registerClass:[TOPReEditCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPReEditCollectionViewCell class])];
    }
    return _myCollectionView;
}

- (TOPPhotoEditScrollView *)showImgView{
    if (!_showImgView) {
        _showImgView = [[TOPPhotoEditScrollView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavAndTabHeight-100)];
        _showImgView.userInteractionEnabled = YES;
        _showImgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    }
    return _showImgView;
}
- (TOPTrackingSliderView *)brightnessSliderView{
    if (!_brightnessSliderView) {
        _brightnessSliderView = [[TOPTrackingSliderView alloc]initWithFrame:CGRectMake(-250/2+40, 350/2, 250, 50)];
        _brightnessSliderView.minValue = -1;
        _brightnessSliderView.maxValue = 1;
        _brightnessSliderView.defaultValue = 0;
        _brightnessSliderView.isVertical = YES;
        _brightnessSliderView.delegate = self;
        _brightnessSliderView.maxmumTrackTintColor = [UIColor whiteColor];
        _brightnessSliderView.minimumTrackTintColor = TOPAPPGreenColor;
        _brightnessSliderView.circleImg = [UIImage imageNamed:@"top_slidercircle"];
    }
    return _brightnessSliderView;
}

- (TOPTrackingSliderView *)contrastSliderView{
    if (!_contrastSliderView) {
        _contrastSliderView = [[TOPTrackingSliderView alloc]initWithFrame:CGRectMake(-250/2+40, 350/2, 250, 50)];
        _contrastSliderView.minValue = 0;
        _contrastSliderView.maxValue = 2;
        _contrastSliderView.defaultValue = 1;
        _contrastSliderView.isVertical = YES;
        _contrastSliderView.delegate = self;
        _contrastSliderView.maxmumTrackTintColor = [UIColor whiteColor];
        _contrastSliderView.minimumTrackTintColor = TOPAPPGreenColor;
        _contrastSliderView.circleImg = [UIImage imageNamed:@"top_slidercircle"];
    }
    return _contrastSliderView;
}
- (NSMutableArray *)showArray{
    if (!_showArray) {
        _showArray = [NSMutableArray new];
    }
    return _showArray;
}

- (NSMutableDictionary *)saveShowDic {
    if (!_saveShowDic) {
        _saveShowDic = [[NSMutableDictionary alloc] init];
        _saveShowDic[@"0"] = self.cropImage;
        _saveShowDic[@"isfilter"] = @(0);
    }
    return _saveShowDic;
}

- (void)top_removeSaveFile{
    [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchDefaultDraw_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchAdjustDraw_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchCropDraw_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchCropDefaultDraw_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPCameraBatchProcessIcon_Path];
    
    [[TOPScameraBatchSave save].images removeAllObjects];
    [[TOPScameraBatchSave save].saveShowDic removeAllObjects];
    
    NSLog(@"save==%@",[TOPScameraBatchSave save].images);
}
- (NSArray *)top_bottomFunctionArray{
    NSArray * tempArray = @[@(TopReEditFinishBottomFunctionTypeRotate),@(TopReEditFinishBottomFunctionTypeAddtext),@(TopReEditFinishBottomFunctionTypeSignature),@(TopReEditFinishBottomFunctionTypeGraffiti),@(TopReEditFinishBottomFunctionTypeFinish)];
    return tempArray;
}
- (void)dealloc{
    NSLog(@"photo edit dealloc");
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBelongTemporaryPathString:TOP_TRDrawingImageFileString]];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
