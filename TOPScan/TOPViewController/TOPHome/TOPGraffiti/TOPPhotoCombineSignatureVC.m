#import "TOPPhotoCombineSignatureVC.h"
#import "TOPSignatureViewController.h"
#import "StickerView.h"
#import "TOPPhotoShowViewController.h"
#import "TOPPhotoReEditVC.h"

@interface TOPPhotoCombineSignatureVC ()<StickerViewDelegate>
@property (strong, nonatomic) StickerView *selectedSticker;
@property (strong,nonatomic) UIDynamicAnimator * animator;
@property (weak, nonatomic) IBOutlet UIView *backImageSuperView;
@property (strong, nonatomic) UIImageView *currnetImageView;
@end

@implementation TOPPhotoCombineSignatureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"topscan_writesignature", @"");
    self.backImageSuperView.backgroundColor = [UIColor clearColor];
    [self.backImageSuperView addSubview:self.currnetImageView];
    UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
    CGFloat imgMul = image.size.height/image.size.width;
    [self.currnetImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.backImageSuperView);
        make.height.mas_equalTo(self.currnetImageView.mas_width).multipliedBy(imgMul);
        make.height.lessThanOrEqualTo(self.backImageSuperView.mas_height);
        make.width.lessThanOrEqualTo(self.backImageSuperView.mas_width);
    }];
    
    [self top_initNavBar];
    [self.selectedSticker performTapOperation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = ViewBgColor;
    [self.navigationController setNavigationBarHidden:NO];
    [self top_configWhiteBgDarkTitle];
    [self top_setRigthButton:@"top_vip_logo" withSelector:@selector(top_saveImageClick:)];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
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

#pragma mark -- 导航栏
- (void)top_initNavBar {
    [self top_setBackButtonwithSelector:@selector(top_Back)];
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
        btn.tag= 115;
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
        btn.tag= 115;
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = barItem;
    }
}

#pragma mark -- 合成图片并保存
- (void)top_saveImageClick:(UIButton *)sender {
    if ([TOPPermissionManager top_enableByImageSign]) {
        [self top_mergeSignatureImage];
    } else {
        [self top_subscriptionService];
    }
}

- (void)top_mergeSignatureImage {
    UIImageView *subImageView = [self.selectedSticker viewWithTag:1234];
    UIImage *subImage = [self top_getrotationImageWithImageView:subImageView];
    UIImage *bgImage = self.currnetImageView.image;
    CGRect subViewRect = [self top_smallImageViewFrame:subImageView];
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *resultImg = [TOPPictureProcessTool top_waterMarkWithImage:bgImage andWaterImage:subImage withRect:subViewRect];
        [TOPDocumentHelper top_saveImage:resultImg atPath:self.imagePath];
        [self top_deleteCoverImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            self.selectedSticker.hidden = YES;
            if (self.top_saveSignatureImgBlick) {
                self.top_saveSignatureImgBlick();
            } else {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TOP_TRSaveSignatureImageKey];
            }
            [self top_saveCompleteBack];
        });
    });
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

- (void)top_saveCompleteBack {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[TOPPhotoShowViewController class]] || [vc isKindOfClass:[TOPPhotoReEditVC class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

#pragma mark -- 签名在底图中的frame 根据底图的缩放比例
- (CGRect)top_smallImageViewFrame:(UIImageView *)subImageView {
    CGFloat subViewWidth = CGRectGetWidth(subImageView.frame);
    CGFloat subViewHeight = CGRectGetHeight(subImageView.frame);
    CGFloat scale = self.currnetImageView.image.size.width / self.currnetImageView.frame.size.width;
    CGPoint centerPoint = [self.currnetImageView convertPoint:subImageView.center fromView:self.selectedSticker];
    CGRect newRect = CGRectMake((centerPoint.x - subViewWidth/2)*scale, (centerPoint.y - subViewHeight/2)*scale, subViewWidth *scale, subViewHeight *scale);
    return newRect;
}

#pragma mark -- 删除缩略图
- (void)top_deleteCoverImage {
    NSString *path = [TOPWHCFileManager top_directoryAtPath:self.imagePath];
    NSString *imgName = [TOPWHCFileManager top_fileNameAtPath:self.imagePath suffix:YES];
    NSString *coverName = [NSString stringWithFormat:@"%@_%@",[path stringByReplacingOccurrencesOfString:@"/" withString:@""],imgName];
    NSString *coverImagePath = [TOPDocumentHelper top_coverImageFile:coverName];
    [TOPWHCFileManager top_removeItemAtPath:coverImagePath];
}

#pragma mark - 返回按钮
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

#pragma mark -- 返回
- (void)top_Back {
    if ([TOPWHCFileManager top_isExistsAtPath:[TOPSignationImagePath stringByAppendingPathComponent:TOP_TRSignationImageName]]) {
        [self top_saveImageAlert];
    } else {
        [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_drawingImageFileString]];
        [self top_saveCompleteBack];
    }
}

#pragma mark -- 保存提示
- (void)top_saveImageAlert {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_note", @"")
                                                                   message:NSLocalizedString(@"topscan_savealert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_discard", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_drawingImageFileString]];
        [self top_saveCompleteBack];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - StickerViewDelegate
#pragma mark -- 编辑按钮
- (UIImage *)stickerView:(StickerView *)stickerView imageForRightTopControl:(CGSize)recommendedSize {
    return [UIImage imageNamed:@"top_signature_edit"];
    
}

- (void)top_stickerViewDidTapContentView:(StickerView *)stickerView {
    self.selectedSticker = stickerView;
    self.selectedSticker.enabledBorder = YES;
    self.selectedSticker.enabledControl = YES;
}

#pragma mark -- 删除按钮
- (void)top_stickerViewDidTapDeleteControl:(StickerView *)stickerView {
    NSLog(@"Tap[%zd] DeleteControl", stickerView.tag);
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[StickerView class]]) {
            [(StickerView *)subView performTapOperation];
            break;
        }
    }
}

- (void)top_stickerViewDidTapRightTopControl:(StickerView *)stickerView {
    [self top_pushSignatureVCAnimated:YES];
}

- (void)top_pushSignatureVCAnimated:(BOOL)animated {
    TOPSignatureViewController *photoeditSign = [[TOPSignatureViewController alloc] init];
    photoeditSign.imagePath = self.imagePath;
    photoeditSign.openSignatureStyle = TRSignatureEditStyleReset;
    photoeditSign.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:photoeditSign animated:animated];
}

#pragma mark -- 获取imageView 旋转和缩放后的image图片对象
- (UIImage *)top_getrotationImageWithImageView:(UIImageView *)subImageView {
    UIImage *newImage = [TOPPictureProcessTool top_rotationScaleImageWithImageView:subImageView];
    return newImage;
}

#pragma mark - 关闭编辑状态
- (void)top_hiddenCtrlTap:(UITapGestureRecognizer *)gesture {
    [self.selectedSticker hiddenCtrl];
}

#pragma mark -- 调整签名图的frame 居中显示
- (CGRect)top_adaptiveSignatureImage:(UIImage *)image {
    UIImage *imageTy = image;
    float imgWidth = 0;
    float imgHeight = 0;

    CGFloat fatherWidth = TOPScreenWidth;
    CGFloat fatherHeight = TOPScreenHeight-TOPNavBarAndStatusBarHeight;
    if  (imageTy.size.width/imageTy.size.height >= fatherWidth/fatherHeight) {
        imgWidth = fatherWidth/2;
        imgHeight = imgWidth / imageTy.size.width * imageTy.size.height;
    } else {
        imgHeight = fatherHeight/2;
        imgWidth = imgHeight / imageTy.size.height * imageTy.size.width;
    }
    return CGRectMake((fatherWidth-imgWidth)/2, (fatherHeight-imgHeight)/2, imgWidth, imgHeight);
}

#pragma mark -- 底图
- (CGRect)top_adaptiveBGImage:(UIImage *)image {
    UIImage *imageTy = image;
    float imgWidth = 0;
    float imgHeight = 0;

    CGFloat fatherWidth = TOPScreenWidth;
    CGFloat fatherHeight = TOPScreenHeight-TOPNavBarAndStatusBarHeight;
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
- (StickerView *)selectedSticker {
    if (!_selectedSticker) {
        UIImage * imageTy = [UIImage imageWithContentsOfFile:[TOPSignationImagePath stringByAppendingPathComponent:TOP_TRSignationImageName]];
        CGRect imageFrame = [self top_adaptiveSignatureImage:imageTy];
        StickerView *sticker1 = [[StickerView alloc] initWithContentFrame:imageFrame contentImage:imageTy];
        sticker1.backgroundColor = [UIColor clearColor];
        sticker1.enabledControl = NO;
        sticker1.enabledBorder = NO;
        sticker1.enabledDeleteControl = NO;
        sticker1.delegate = self;
        sticker1.tag = 1;
        [self.backImageSuperView addSubview:sticker1];
        _selectedSticker = sticker1;
    }
    return _selectedSticker;
}

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

- (void)dealloc {
    NSLog(@"photoCombine dealloc");
}

@end
