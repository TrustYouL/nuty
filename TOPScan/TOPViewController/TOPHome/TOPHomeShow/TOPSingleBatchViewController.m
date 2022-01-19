#define kCameraToolsViewHeight 128 * (TOPScreenHeight / 667.)
#define CropView_Y 45
#define CropView_X 15
#import "TOPSingleBatchViewController.h"
#import "TOPHomeChildViewController.h"
#import "TopScanner-Swift.h"
#import "TOPDataTool.h"
#import "TOPPhotoReEditVC.h"
#import "TOPMagnifierView.h"
#import "TOPReEditModel.h"
#import "TOPPictureProcessTool.h"
#import "TOPSCameraViewController.h"

@interface TOPSingleBatchViewController ()<CropViewDelegate> {
    NSInteger clickCount;
}
@property (nonatomic ,assign)NSInteger clickNum;
@property (nonatomic ,assign)NSInteger drawIndex;
@property (nonatomic ,strong)TOPCropView * cropView;
@property (nonatomic ,strong)TOPMagnifierView *magnifierView;
@property (nonatomic ,strong)NSMutableArray * reEditAllPic;
@property (nonatomic ,copy)NSString * addStr;
@property (nonatomic ,strong) UILabel *pageLabel;
@property (nonatomic ,strong) UIButton *rightBtn;
@property (nonatomic ,assign) BOOL isAutomatic;
@property (nonatomic ,strong)UIButton * drawTypeBtn;
@property (nonatomic ,strong)UIButton * finishAllBtn;
@property (nonatomic ,strong)NSArray * titleArray;
@property (nonatomic ,strong)UIImage *cropShowImage;
@property (nonatomic ,strong)UIButton * leftCropBtn;
@property (nonatomic ,copy)  NSArray  *leftCropBtnStates;
@property (nonatomic ,strong) NSMutableArray * cropFitPoints;
@property (nonatomic ,strong) NSMutableArray * cropAutoPoints;
@property (nonatomic ,strong) NSMutableArray * cropFullPoints;

@end

@implementation TOPSingleBatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _clickNum = 0;
    clickCount = 0;
    _isAutomatic = YES;
    NSInteger processType = [TOPScanerShare top_defaultProcessType];
    _drawIndex = [[TOPPictureProcessTool top_processTypeArray] indexOfObject:@(processType)];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_batchView_ClickToBack)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_batchView_ClickToBack)];
    }

    self.titleArray = [TOPPictureProcessTool top_processTitles];
    
    NSString * documentStr = [TOPDocumentHelper top_appBoxDirectory];
    NSString * addStr = [[self.pathString componentsSeparatedByString:documentStr] objectAtIndex:1];
    self.addStr = addStr;
    
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPTabBarHeight, TOPScreenWidth, 49)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    
    UIView * safeView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    safeView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(TOPScreenWidth-75, 5, 60, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"top_right_next"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(top_batchView_ClickAndFinish:) forControlEvents:UIControlEventTouchUpInside];
    self.rightBtn = rightBtn;
    
    TOPImageTitleButton * leftBtn = [[TOPImageTitleButton alloc] initWithStyle:(EImageTopTitleBottom)];
    leftBtn.tapAnimationDuration = 0.0;
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    leftBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [leftBtn setImage:[UIImage imageNamed:@"top_cropFull"] forState:UIControlStateNormal];
    [leftBtn setTitle:NSLocalizedString(@"topscan_batchall", @"") forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(top_batchView_ClickLeftBtn:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.selected = NO;
    leftBtn.backgroundColor = [UIColor clearColor];
    self.leftCropBtn = leftBtn;
    [bottomView addSubview:rightBtn];
    [bottomView addSubview:leftBtn];
    [self.view addSubview:self.cropView];
    [self.view addSubview:bottomView];
    [self.view addSubview:safeView];
    [self.view addSubview:self.pageLabel];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(55);
    }];
    
    [safeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
    
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomView);
        make.trailing.equalTo(bottomView).offset(-15);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(60);
    }];
    
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomView);
        make.leading.equalTo(bottomView).offset(15);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(80);
    }];
    [self top_createCropImage];
    self.pageLabel.text = [NSString stringWithFormat:@"%ld/%lu",(_clickNum+1),(unsigned long)self.batchArray.count];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
#pragma mark -- 生成剪裁展示图和应用源图
- (void)top_createCropImage {
    UIImage * showImg = nil;
    if (self.batchArray.count>0) {
        if ([self.batchArray[_clickNum] isKindOfClass:DocumentModel.class]) {
            DocumentModel *model = self.batchArray[_clickNum];
            NSData *imgData = [NSData dataWithContentsOfFile:model.originalImagePath];
            self.cropView.originalImage = [UIImage imageWithContentsOfFile:model.originalImagePath];
            showImg = [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(CGRectGetWidth(self.cropView.frame), CGRectGetHeight(self.cropView.frame))];
            CGRect imgRect = [TOPDataModelHandler top_adaptiveBGImage:showImg fatherW:CGRectGetWidth(self.cropView.frame) fatherH:CGRectGetHeight(self.cropView.frame)];
            [self top_setCropViewPoints:model withRect:imgRect];
            BOOL potEqual = [TOPDataModelHandler top_pointEqual:model.docId];
            self.leftCropBtnStates = potEqual ? @[@(TOPCropBtnStateFull), @(TOPCropBtnStateAuto)] : @[@(TOPCropBtnStateAuto), @(TOPCropBtnStateFull), @(TOPCropBtnStateFit)];
        } else {
            self.leftCropBtnStates = @[@(TOPCropBtnStateFull), @(TOPCropBtnStateAuto)];
            NSString *imagePath = [NSString stringWithFormat:@"%@/%@",TOPCamerPic_Path,self.batchArray[_clickNum]];
            NSData *imgData = [NSData dataWithContentsOfFile:imagePath];
            self.cropView.originalImage = [TOPPictureProcessTool top_fetchOriginalImageWithData:imgData];
            [TOPDocumentHelper top_saveCropOriginalImage:self.cropView.originalImage];
            showImg = [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(CGRectGetWidth(self.cropView.frame), CGRectGetHeight(self.cropView.frame))];
        }
    }
    if (showImg) {
        self.cropShowImage = showImg;
        [TOPDocumentHelper top_saveCropShowImage:showImg];
        [self.cropView setUpImageWithImage:showImg isAutomatic:_isAutomatic];
        if (!self.cropAutoPoints.count) {
            self.cropAutoPoints = [[self.cropView top_saveChangeEndPointArray] mutableCopy];
            [self top_initFullPointsWithFrame:self.cropView.cropImageView.frame];
        }
    }
    [self top_updateCropBtnState:[self.leftCropBtnStates.firstObject integerValue]];
}

- (void)top_initFullPointsWithFrame:(CGRect)imgRect {
    [self.cropFullPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    [self.cropFullPoints addObject:[NSValue valueWithCGPoint:CGPointMake(imgRect.size.width, 0)]];
    [self.cropFullPoints addObject:[NSValue valueWithCGPoint:CGPointMake(imgRect.size.width, imgRect.size.height)]];
    [self.cropFullPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0, imgRect.size.height)]];
}

#pragma mark -- 获取数据库保存的裁剪坐标
- (void)top_setCropViewPoints:(DocumentModel *)docModel withRect:(CGRect)imgRect {
    TOPImageFile *imgFile = [TOPDBQueryService top_imageFileById:docModel.docId];
    NSData *data;
    NSData *autoData;
    UIInterfaceOrientation faceOr = [[UIApplication sharedApplication] statusBarOrientation];
    if (faceOr == UIInterfaceOrientationLandscapeLeft || faceOr == UIInterfaceOrientationLandscapeRight) {
        data = imgFile.landscapePoints;
        autoData = imgFile.autoLandscapePoints;
    } else {
        data = imgFile.portraitPoints;
        autoData = imgFile.atuoPortraitPoints;
    }
    UIImage *originalImg = [UIImage imageWithContentsOfFile:docModel.originalImagePath];
    CGFloat scaleW = originalImg.size.width / CGRectGetWidth(imgRect);
    CGFloat scaleH = originalImg.size.height / CGRectGetHeight(imgRect);
    [self top_initFullPointsWithFrame:imgRect];
    if (data.length) {
        NSArray *points = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if ([self top_validatePoints:points]) {
            NSMutableArray *temp = @[].mutableCopy;
            for (int i = 1; i < points.count; i ++) {
                NSString *pStr = points[i];
                CGPoint point = CGPointFromString(pStr);
                CGPoint cropPoint = CGPointMake(point.x / scaleW, point.y / scaleH);
                [temp addObject:[NSValue valueWithCGPoint:cropPoint]];
            }
            self.cropView.defaultPoints = temp;
            self.cropFitPoints = temp.mutableCopy;
        }
    }
    if (autoData.length) {
        NSArray *points = [NSJSONSerialization JSONObjectWithData:autoData options:NSJSONReadingMutableLeaves error:nil];
        if ([self top_validatePoints:points]) {
            NSMutableArray *temp = @[].mutableCopy;
            for (int i = 1; i < points.count; i ++) {
                NSString *pStr = points[i];
                CGPoint point = CGPointFromString(pStr);
                CGPoint cropPoint = CGPointMake(point.x / scaleW, point.y / scaleH);
                [temp addObject:[NSValue valueWithCGPoint:cropPoint]];
            }
            self.cropView.autoCropPoints = temp;
            self.cropAutoPoints = temp.mutableCopy;
        }
    }
}

- (BOOL)top_validatePoints:(NSArray *)points {
    if (points.count > 4) {
        NSString *pStr = points[0];
        CGPoint point = CGPointFromString(pStr);
        if (point.x > 0 && point.y > 0) {
            NSString *pStr3 = points[3];
            CGPoint point3 = CGPointFromString(pStr3);
            if (point3.x > 0 && point3.y > 0) {
                return YES;
            }
        } else {
            return NO;
        }
    }
    return NO;
}

#pragma mark--CropViewDelegate
- (void)panChangePoint:(CGPoint)point{
    [self magnifierPosition:point];
    [self.magnifierView makeKeyAndVisible];
}

- (void)panChangePointEnd{
    self.magnifierView.hidden = YES;
}

-(void)magnifierPosition:(CGPoint )position
{
    CGPoint sendPoint = position;
    self.magnifierView.pointTomagnify = sendPoint;  
}

- (void)top_updateCropBtnState:(NSInteger)state {
    NSString *btnImage = @"";
    NSString *btnTitle = @"";
    switch (state) {
        case TOPCropBtnStateAuto:
            btnImage = @"top_cropAuto";
            btnTitle = NSLocalizedString(@"topscan_batchauto", @"");
            break;
        case TOPCropBtnStateFull:
            btnImage = @"top_cropFull";
            btnTitle = NSLocalizedString(@"topscan_batchall", @"");
            break;
        case TOPCropBtnStateFit:
            btnImage = @"top_cropFit";
            btnTitle = NSLocalizedString(@"topscan_batchfit", @"");
            break;
        default:
            break;
    }
    [self.leftCropBtn setImage:[UIImage imageNamed:btnImage] forState:UIControlStateNormal];
    [self.leftCropBtn setTitle:btnTitle forState:UIControlStateNormal];
}

- (void)top_batchView_ClickLeftBtn:(UIButton *)sender{
    [FIRAnalytics logEventWithName:@"batchView_ClickLeftBtn" parameters:nil];
    [self top_updateCropViewPointsData];
    clickCount ++;
    NSInteger index = clickCount % self.leftCropBtnStates.count;
    if (index < self.leftCropBtnStates.count) {
        NSInteger state = [self.leftCropBtnStates[index] integerValue];
        [self top_updateCropBtnState:state];
    } else {
        NSLog(@"btn error");
    }
    if (self.cropShowImage) {
        [self.cropView setUpImageWithImage:self.cropShowImage isAutomatic:_isAutomatic];
    }
}

- (void)top_updateCropViewPointsData {
    NSInteger index = clickCount % self.leftCropBtnStates.count;
    if (index < self.leftCropBtnStates.count) {
        NSInteger state = [self.leftCropBtnStates[index] integerValue];
        switch (state) {
            case TOPCropBtnStateAuto:
                _isAutomatic = YES;
                self.cropView.defaultPoints = self.cropAutoPoints.mutableCopy;
                break;
            case TOPCropBtnStateFull:
                _isAutomatic = NO;
                self.cropView.defaultPoints = self.cropFullPoints.mutableCopy;
                break;
            case TOPCropBtnStateFit:
                _isAutomatic = NO;
                self.cropView.defaultPoints = self.cropFitPoints.mutableCopy;
                break;
                
            default:
                break;
        }
    }
}

#pragma mark -- 当前文档中图片名下标最大值 1001、1002
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

#pragma mark -- 保存签名照
- (void)top_saveSignatureImage:(UIImage *)img {
    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:[TOPDocumentHelper top_maxImageNumIndexAtPath:TOPSignationImagePath]],TOP_TRPNGPathSuffixString];
    NSString *fileEndPath =  [TOPSignationImagePath stringByAppendingPathComponent:fileName];
    NSData *data = UIImagePNGRepresentation(img);
    [data writeToFile:fileEndPath atomically:YES];
    [[NSUserDefaults standardUserDefaults] setObject:fileEndPath forKey:TOP_TRNewSignatureKey];
}

#pragma mark -- 处理pdf签名图
- (void)top_handlePDFSignature:(UIImage *)imageOne {
    GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:imageOne];
    UIImage * drawImage = [TOPDataTool top_pictureProcessData:imageSource withImg:imageOne withItem:TOPProcessTypeBW];
    UIImage * signatureImg  = [TOPPictureProcessTool top_removeWhiteColorWithImage:drawImage];
    if (signatureImg) {
        [self top_saveSignatureImage:signatureImg];
        if (self.backType == TOPHomeChildViewControllerBackTypePopVC) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark -- 图片单张依次渲染的点击事件
- (void)top_batchView_ClickAndFinish:(UIButton *)sender{
    [FIRAnalytics logEventWithName:@"batchView_ClickAndFinish" parameters:nil];
    UIImage *imageOne =  [self.cropView cropAndTransform];
    if (imageOne.size.width>0&&imageOne.size.height>0) {
        if (self.fileType == TOPEnterCameraTypePDFSignature) {
            [self top_handlePDFSignature:imageOne];
        } else {
            if (self.model.docId) {
                TOPImageFile *imgFile = [TOPDBQueryService top_imageFileById:self.model.docId];
                if (imgFile) {
                    imageOne = [UIImage imageWithCGImage:[imageOne CGImage] scale:[imageOne scale] orientation: imgFile.orientation];
                }
            }
            if (self.batchArray.count<2) {
                self.rightBtn.enabled = NO;
                [TOPDocumentHelper top_saveCropShowImage:imageOne];
                [self top_jumpToPhotoReEditVCWithImage:imageOne];
            }
        }
    }
}

#pragma mark -- 跳转到渲染图片界面
- (void)top_jumpToPhotoReEditVCWithImage:(UIImage *)imageOne {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imgData = [TOPDocumentHelper top_saveImageForData:imageOne];
        UIImage * drawImg = [UIImage new];
        UIImage * sizeImg = [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(80*3, 90*3)];
        if (sizeImg.size.width>0&&sizeImg.size.height>0) {
            drawImg = sizeImg;
        }else{
            drawImg = imageOne;
        }
        [TOPWHCFileManager top_removeItemAtPath:TOPDefaultDraw_Path];
        [TOPWHCFileManager top_createDirectoryAtPath:TOPDefaultDraw_Path];
        GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:drawImg];
        NSArray *processArray = [TOPPictureProcessTool top_processTypeArray];
        for (int i = 0; i<processArray.count; i++) {
            @autoreleasepool {
                NSInteger processType = [processArray[i] integerValue];
                UIImage * drawImage = [TOPDataTool top_pictureProcessData:imageSource withImg:drawImg withItem:processType];
                [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
                NSData *drawData = UIImageJPEGRepresentation(drawImage, TOP_TRPicScale);
                if (!drawData) {
                    drawData = [[NSData alloc] init];
                }
                NSString * fileName = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
                NSString *fileEndPath =  [TOPDefaultDraw_Path stringByAppendingPathComponent:fileName];
                [drawData writeToFile:fileEndPath atomically:YES];
            }
        }
         
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self top_removeMagnifierView];
            self.cropFitPoints = [self.cropView top_saveChangeEndPointArray].mutableCopy;
            NSArray *points = [self.cropView cropOriginalImagePoints];
            NSArray *autoPoints = [self.cropView autoOriginalImagePoints];
            BOOL potEqual = ![TOPDataModelHandler top_compareArray:points.mutableCopy withArray:autoPoints.mutableCopy];
            self.leftCropBtnStates = potEqual ? @[@(TOPCropBtnStateFull), @(TOPCropBtnStateAuto)] : @[@(TOPCropBtnStateAuto), @(TOPCropBtnStateFull), @(TOPCropBtnStateFit)];
            [self top_updateCropBtnState:[self.leftCropBtnStates.firstObject integerValue]];
            self->clickCount = 0;
            TOPPhotoReEditVC * vc = [[TOPPhotoReEditVC alloc]init];
            vc.pathString = self.pathString;
            vc.fileType = self.fileType;
            vc.dataArray = self.dataArray;
            vc.backType = self.backType;
            vc.model = self.model;
            vc.cropPoints = points;
            vc.autoCropPoints = autoPoints;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            self.rightBtn.enabled = YES;
        });
    });
}


#pragma mark -- 移除放大镜
- (void)top_removeMagnifierView{
    [self.magnifierView removeFromSuperview];
    self.magnifierView = nil;
}
- (void)top_batchView_ClickToBack{
    [self top_removeMagnifierView];
    
    if (self.fileType == TOPShowPhotoShowCameraType||self.fileType == TOPEnterCameraTypePDFSignature) {
        [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSMutableArray * tempArray = [NSMutableArray new];
        BOOL isHave = NO;
        tempArray = [self.navigationController.viewControllers mutableCopy];
        for (UIViewController * vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[TOPSCameraViewController class]]) {
                isHave = YES;
                break;
            }
        }
        if (!isHave) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark lazy laod cropFullPoints
- (NSMutableArray *)cropFullPoints {
    if (!_cropFullPoints) {
        _cropFullPoints = @[].mutableCopy;
    }
    return _cropFullPoints;
}

- (NSMutableArray *)cropAutoPoints {
    if (!_cropAutoPoints) {
        _cropAutoPoints = @[].mutableCopy;
    }
    return _cropAutoPoints;
}

- (NSMutableArray *)cropFitPoints {
    if (!_cropFitPoints) {
        _cropFitPoints = @[].mutableCopy;
    }
    return _cropFitPoints;
}

- (NSMutableArray *)reEditAllPic{
    if (!_reEditAllPic) {
        _reEditAllPic = [NSMutableArray new];
    }
    return _reEditAllPic;
}

- (TOPCropView*)cropView{
    if (!_cropView){
        _cropView  = [[TOPCropView alloc]initWithFrame:CGRectMake(CropView_X, CropView_Y , TOPScreenWidth-30, ((TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight)*(TOPScreenWidth-30))/TOPScreenWidth)];
        _cropView.cropViewDelegate = self;
    }
    return _cropView;
}

-(TOPMagnifierView *)magnifierView{
    if (! _magnifierView) {
        _magnifierView = [[TOPMagnifierView alloc]init];
        _magnifierView.magnifyView = self.cropView;
    }
    return _magnifierView;
}

- (UILabel *)pageLabel{
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPTabBarHeight-(50), TOPScreenWidth - 200, (50))];
        _pageLabel.font = [self fontsWithSize:18];
        _pageLabel.textAlignment = NSTextAlignmentCenter ;
        _pageLabel.textColor = TOPAPPGreenColor;
        [self.view addSubview:_pageLabel];
    }
    return _pageLabel;
}


- (void)dealloc{
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getCropImageFileString]];
    NSLog(@"batch dealloc");
}

@end
