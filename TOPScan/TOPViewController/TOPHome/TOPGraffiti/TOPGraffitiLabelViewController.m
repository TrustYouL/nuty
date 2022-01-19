#import "TOPGraffitiLabelViewController.h"
#import "TOPColorMenuView.h"
#import "TOPStickerLabelView.h"

@interface TOPGraffitiLabelViewController ()
@property (strong, nonatomic) UIView *bgImageSuperView;
@property (strong, nonatomic) UIImageView *currnetImageView;
@property (strong, nonatomic) TOPColorMenuView *colorMenuView;
@property (strong, nonatomic) NSMutableArray *textLabArray;

@end
#define Bottom_H 60
#define LabelTextMaxNum 3
#define KLabelDistance  40
@implementation TOPGraffitiLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"topscan_docaddtext", @"");
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:kWhiteColor];
    [self top_initNavBar];
    [self top_configContentView];
    [self top_setInputText];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self top_configWhiteBgDarkTitle];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.titleTextAttributes=
    @{NSForegroundColorAttributeName:[UIColor top_textColor:kWhiteColor defaultColor:RGBA(51, 51, 51, 1.0)],
    NSFontAttributeName:[UIFont systemFontOfSize:18]};
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
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
#pragma mark -- 导航栏 TOPAPPGreenColor
- (void)top_initNavBar {
    [self top_setBackButtonwithSelector:@selector(top_graffitiVC_Back)];
    [self top_setRightButtons:@[@"top_ocr_savetext",@"top_reEdit_Addtext"]];//top_ocr_savetext
}

- (void)top_setBackButtonwithSelector:(SEL)selector {
    TOPImageTitleButton * btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
    btn.frame = CGRectMake(0, 0, 44, 44);
    if (isRTL()) {
        [btn setImage:[UIImage imageNamed:@"top_RTLbackItem"] forState:UIControlStateNormal];
        btn.style = EImageLeftTitleRightCenter;
    }else{
        [btn setImage:[UIImage imageNamed:@"top_backItem"] forState:UIControlStateNormal];
        btn.style = EImageLeftTitleRightLeft;
    }
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

- (void)top_setRightButtons:(NSArray *)imgNames {
    if (imgNames.count) {
        NSString *imgName = imgNames[0];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(top_saveGraffititImage) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        NSString *imgName2 = imgNames[1];
        UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [btn2 setImage:[UIImage imageNamed:imgName2] forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(top_setInputText) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barItem2 = [[UIBarButtonItem alloc] initWithCustomView:btn2];
        
        self.navigationItem.rightBarButtonItems = @[barItem,barItem2];
    }
}

#pragma mark -- 涂鸦底图
- (void)top_configContentView {
    [self.bgImageSuperView addSubview:self.currnetImageView];
    UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
    CGFloat imgMul = image.size.height/image.size.width;
    [self.currnetImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bgImageSuperView);
        make.height.mas_equalTo(self.currnetImageView.mas_width).multipliedBy(imgMul);
        make.height.lessThanOrEqualTo(self.bgImageSuperView.mas_height);
        make.width.lessThanOrEqualTo(self.bgImageSuperView.mas_width);
    }];

    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight - TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
}

#pragma mark -- back
- (void)top_graffitiVC_Back {
    if (self.textLabArray.count) {
        [self top_saveImageAlert];
    } else {
        [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_drawingImageFileString]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -- 保存提示
- (void)top_saveImageAlert {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"")
                                                                   message:NSLocalizedString(@"topscan_savealert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_discard", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_drawingImageFileString]];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- done
- (void)top_saveGraffititImage {
    if (!self.textLabArray.count) {
        [self top_graffitiVC_Back];
        return;
    }
    if (self.noCreateFile) {
        [self top_graffitiLabVC_changeCurrentFile];
    } else {
        [self top_graffitiLavVC_saveImageMethod];
    }
}

#pragma mark -- 改变当前图片
- (void)top_graffitiLavVC_saveImageMethod {
    TOPSCAlertController *alertController = [TOPSCAlertController alertControllerWithTitle:nil message:nil preferredStyle: IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_graffitireplacefile", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_graffitiLabVC_changeCurrentFile];
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_graffiticreatefile", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_graffitiLabVC_createNewFile];
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

- (UIImage *)top_waterMarkWithImage:(UIImage *)backgroundImage scale:(CGFloat)scale points:(NSArray *)points  {
    UIGraphicsBeginImageContextWithOptions(backgroundImage.size, NO, 1.0);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    for (int i = 0; i < self.textLabArray.count; i ++) {
        TOPStickerLabelView *stickerLab = self.textLabArray[i];
        CGPoint center = CGPointFromString(points[i]);
        center = CGPointMake(center.x * scale, center.y * scale);
        UIFont * font = [UIFont systemFontOfSize:(stickerLab.fontsize *scale)]; //水印文字大小
        UIColor *textColor = stickerLab.textColor;
        NSString *text = stickerLab.labText;
        CGFloat rotation = stickerLab.totalRotation;
        NSDictionary * attr = @{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor};
        NSMutableAttributedString * attr_str =[[NSMutableAttributedString alloc]initWithString:text attributes:attr];
        
        CGSize textSize = [self top_contentLabSize:text fontSize:stickerLab.fontsize];
        CGFloat maxWidth = (TOPScreenWidth - KLabelDistance)*scale;
        CGFloat str_w = attr_str.size.width > maxWidth ? maxWidth : attr_str.size.width;
        CGFloat str_h = attr_str.size.width > maxWidth ? textSize.height * scale : attr_str.size.height;
        CGPoint textOrigin = CGPointMake(center.x - str_w *0.5, center.y - str_h *0.5);
        CGRect textRect = CGRectMake(center.x - str_w *0.5, center.y - str_h *0.5, str_w, str_h);
        
        CGPoint translateOrignal = center;
        textOrigin = CGPointMake(- str_w *0.5, - str_h *0.5);
        textRect.origin = CGPointMake(textOrigin.x, textOrigin.y);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, translateOrignal.x,translateOrignal.y);
        CGContextRotateCTM(context, rotation);
        
        [text drawInRect:textRect withAttributes:attr];
        
        //复原
        CGContextRotateCTM(context, -rotation);
        CGContextTranslateCTM(context, -translateOrignal.x,-translateOrignal.y);
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (CGSize)top_contentLabSize:(NSString *)labStr fontSize:(CGFloat)fontSize {
    CGFloat width = 0, height = 36, margin = 0;
    CGSize size = [TOPAppTools sizeWithFont:fontSize textSizeWidht:width textSizeHeight:height text:labStr];
    if (size.width > TOPScreenWidth - KLabelDistance || ([labStr rangeOfString:@"\n"].location !=NSNotFound)) {
        CGFloat maxW = [TOPAppTools labMaxWidth:labStr withFontSize:fontSize];
        width =  MIN((TOPScreenWidth - KLabelDistance), maxW);
        CGSize size2 = [TOPAppTools sizeWithFont:fontSize textSizeWidht:width textSizeHeight:0 text:labStr];
        height = size2.height - margin;
    } else {
        width = size.width - margin;
    }
    return CGSizeMake(width, height);
}

- (CGPoint)top_strickLabelFrame:(TOPStickerLabelView *)stickerLabel {
    UIView *subView = stickerLabel.contentView;
    CGPoint centerPoint = [self.currnetImageView convertPoint:subView.center fromView:stickerLabel];
    centerPoint = CGPointMake(centerPoint.x, centerPoint.y);
    return centerPoint;
}

#pragma mark -- 改变当前图片
- (void)top_graffitiLabVC_changeCurrentFile {
    [self top_hiddenStickerCtrl];
    CGFloat scale = self.currnetImageView.image.size.width / self.currnetImageView.frame.size.width;
    NSMutableArray *points = @[].mutableCopy;
    for (TOPStickerLabelView *stickerLab in self.textLabArray) {
        CGPoint center = [self top_strickLabelFrame:stickerLab];
        [points addObject:NSStringFromCGPoint(center)];
    }
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
        UIImage *resultImg = [self top_waterMarkWithImage:image scale:scale points:points];
        [TOPDocumentHelper top_saveImage:resultImg atPath:self.imagePath];
        [TOPEditDBDataHandler top_updateImageWithId:[TOPFileDataManager shareInstance].docModel.docId];
        [self top_deleteCoverImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (self.top_saveEditedImgBlick) {
                self.top_saveEditedImgBlick();
            }
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

#pragma mark -- 新建图片
- (void)top_graffitiLabVC_createNewFile {
    [self top_hiddenStickerCtrl];
    CGFloat scale = self.currnetImageView.image.size.width / self.currnetImageView.frame.size.width;
    NSMutableArray *points = @[].mutableCopy;
    for (TOPStickerLabelView *stickerLab in self.textLabArray) {
        CGPoint center = [self top_strickLabelFrame:stickerLab];
        [points addObject:NSStringFromCGPoint(center)];
    }
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
        UIImage *resultImg = [self top_waterMarkWithImage:image scale:scale points:points];
        NSString *newImgPath = [self top_newImagePath];
        [TOPDocumentHelper top_saveImage:resultImg atPath:newImgPath];
        [TOPEditDBDataHandler top_createImageById:[TOPFileDataManager shareInstance].docModel.docId WithName:[TOPWHCFileManager top_fileNameAtPath:newImgPath suffix:YES]];
        [self top_saveOriginalImageWithNewImage:newImgPath];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TOP_TRAddNewSignatureImageKey];//新增图片标记更新
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

- (NSString *)top_newImagePath {
    NSString *docPath = [TOPWHCFileManager top_directoryAtPath:self.imagePath];
    NSString *fileName = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:[TOPDocumentHelper top_maxImageNumIndexAtPath:docPath]],TOP_TRJPGPathSuffixString];
    NSString *newImgPath = [docPath stringByAppendingPathComponent:fileName];
    return newImgPath;
}

#pragma mark -- 拷贝源图、ocr、note
- (void)top_saveOriginalImageWithNewImage:(NSString *)newPath {
    NSString *originalImgPath = [TOPDocumentHelper top_originalImage:self.imagePath];
    if ([TOPWHCFileManager top_isExistsAtPath:originalImgPath]) {
        NSString *newOriginalPath = [TOPDocumentHelper top_originalImage:newPath];
        [TOPWHCFileManager top_copyItemAtPath:originalImgPath toPath:newOriginalPath];
    }
    NSString *originalOcrPath = [TOPDocumentHelper top_originalOcr:self.imagePath];
    if ([TOPWHCFileManager top_isExistsAtPath:originalOcrPath]) {
        NSString *newOriginalPath = [TOPDocumentHelper top_originalOcr:newPath];
        [TOPWHCFileManager top_copyItemAtPath:originalOcrPath toPath:newOriginalPath];
    }
    NSString *originalNotePath = [TOPDocumentHelper top_originalNote:self.imagePath];
    if ([TOPWHCFileManager top_isExistsAtPath:originalNotePath]) {
        NSString *newOriginalPath = [TOPDocumentHelper top_originalNote:newPath];
        [TOPWHCFileManager top_copyItemAtPath:originalNotePath toPath:newOriginalPath];
    }
}

#pragma mark -- 删除缩略图
- (void)top_deleteCoverImage {
    NSString *path = [TOPWHCFileManager top_directoryAtPath:self.imagePath];
    NSString *imgName = [TOPWHCFileManager top_fileNameAtPath:self.imagePath suffix:YES];
    NSString *coverName = [NSString stringWithFormat:@"%@_%@",[path stringByReplacingOccurrencesOfString:@"/" withString:@""],imgName];
    NSString *coverImagePath = [TOPDocumentHelper top_coverImageFile:coverName];
    [TOPWHCFileManager top_removeItemAtPath:coverImagePath];
}

#pragma mark -- 获取涂鸦后的合成图片
- (UIImage*)top_drawGraffitiImage{
    CGFloat scaleSuper = self.currnetImageView.image.size.width / self.currnetImageView.frame.size.width;
    CGFloat suprerViewWidth = self.bgImageSuperView.frame.size.width * scaleSuper;
    CGFloat suprerViewHeight = self.bgImageSuperView.frame.size.height * scaleSuper;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(suprerViewWidth, suprerViewHeight), NO, 1);
    [self.bgImageSuperView drawViewHierarchyInRect:CGRectMake(0, 0, suprerViewWidth, suprerViewHeight) afterScreenUpdates:YES];
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect rect = self.currnetImageView.frame;
    rect.origin.x *= scaleSuper;
    rect.origin.y *= scaleSuper;
    rect.size.width *= scaleSuper;
    rect.size.height *= scaleSuper;
    CGImageRef imageRef = CGImageCreateWithImageInRect(resultImg.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return image;
}

#pragma mark -- 添加文本标签
- (void)top_setInputText {
    if (self.textLabArray.count >= LabelTextMaxNum) {
        return;
    }
    NSString *graffitiText = [[NSUserDefaults standardUserDefaults] stringForKey:TOP_TRGraffitiLabelTextKey];
    TOPStickerLabelView *stickerView = [[TOPStickerLabelView alloc] init];
    stickerView.labText = graffitiText;
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRGraffitiLabelTextColorKey];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    stickerView.textColor = color;
    [self.bgImageSuperView addSubview:stickerView];
    stickerView.tag = self.textLabArray.count;
    [self.textLabArray addObject:stickerView];
    __weak typeof(self) weakSelf = self;
    __weak typeof(stickerView) weakSticker = stickerView;
    stickerView.deleteTextLabBlock = ^{
        __strong typeof(stickerView) strongSticker = weakSticker;
        [weakSelf.textLabArray removeObject:strongSticker];
    };
}

#pragma mark - 关闭编辑状态
- (void)top_hiddenCtrlTap:(UITapGestureRecognizer *)gesture {
    [self top_hiddenStickerCtrl];
}

#pragma mark -- 隐藏标签的控制按钮和边框
- (void)top_hiddenStickerCtrl {
    for (UIView *subView in self.bgImageSuperView.subviews) {
        if ([subView isKindOfClass:[TOPStickerLabelView class]]) {
            TOPStickerLabelView *sticker = (TOPStickerLabelView *)subView;
            [sticker hiddenCtrl];
        }
    }
}

#pragma mark -- 底图frame
- (CGRect)top_adaptiveBGImage:(UIImage *)image {
    UIImage *imageTy = image;
    float imgWidth = 0;
    float imgHeight = 0;

    CGFloat fatherWidth = TOPScreenWidth;
    CGFloat fatherHeight = CGRectGetHeight(self.bgImageSuperView.frame);
    if  (imageTy.size.width/imageTy.size.height >= fatherWidth/fatherHeight) {
        imgWidth = fatherWidth;
        imgHeight = imgWidth / imageTy.size.width * imageTy.size.height;
    } else {
        imgHeight = fatherHeight;
        imgWidth = imgHeight / imageTy.size.height * imageTy.size.width;
    }
    return CGRectMake((fatherWidth-imgWidth)/2, (fatherHeight-imgHeight)/2, imgWidth, imgHeight);
}

#pragma mark -- lazy
- (UIImageView *)currnetImageView {
    if (!_currnetImageView) {
        UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
        _currnetImageView = [[UIImageView alloc] initWithFrame:[self top_adaptiveBGImage:image]];
        _currnetImageView.image = image;
        _currnetImageView.contentMode = UIViewContentModeScaleAspectFit;
        _currnetImageView.userInteractionEnabled = YES;
    
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(top_hiddenCtrlTap:)];
        [_currnetImageView addGestureRecognizer:tapGesture];
    }
    return _currnetImageView;
}

- (UIView *)bgImageSuperView {
    if (!_bgImageSuperView) {
        CGFloat imageH = TOPScreenHeight - TOPNavBarAndStatusBarHeight - TOPBottomSafeHeight;
        _bgImageSuperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth, imageH)];
        _bgImageSuperView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:ViewBgColor];
        [self.view addSubview:_bgImageSuperView];
        [[NSUserDefaults standardUserDefaults] setFloat:imageH forKey:@"superViewHeight"];
        [_bgImageSuperView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        }];
    }
    return _bgImageSuperView;
}

- (NSMutableArray *)textLabArray {
    if (!_textLabArray) {
        _textLabArray = [[NSMutableArray alloc] init];
    }
    return _textLabArray;
}

@end
