#import "TOPGraffitiViewController.h"
#import "TOPStickerLabelView.h"
#import "TOPBrushSettingView.h"
#import "TOPPhotoLongPressView.h"
#import "TOPSignatureView.h"
#import "TOPEraserSettingView.h"
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define InputViewHeight 160
#define KLabelDistance  40

typedef NS_ENUM(NSUInteger, GraffitiItemType) {
    GraffitiItemTypeText,
    GraffitiItemTypeBrush,
};

@interface GraffitiItemModel : NSObject
@property (assign, nonatomic) GraffitiItemType itemType;
@property (assign, nonatomic) NSInteger modelIndex;
@end

@implementation GraffitiItemModel

- (instancetype)initWithType:(GraffitiItemType)type graffitiModel:(NSInteger)index {
    self = [super init];
    if (self) {
        _itemType = type;
        _modelIndex = index;
    }
    return self;
}

@end

@interface TOPGraffitiViewController ()
@property (strong, nonatomic) UIView *bgImageSuperView;
@property (strong, nonatomic) UIImageView *currnetImageView;
@property (copy, nonatomic) NSString *textStr;
@property (strong, nonatomic) TOPEraserSettingView *eraserSettingView;
@property (strong, nonatomic) TOPBrushSettingView *brushSettingView;
@property (strong, nonatomic) TOPSignatureView *signatureView;
@property (strong, nonatomic) NSMutableArray *graffitiItems;
@property (strong, nonatomic) NSMutableArray *reDoItems;
@property (strong, nonatomic) NSMutableArray *textLabArray;
@property (strong, nonatomic) NSMutableArray *textLabRedoArray;
@property (strong, nonatomic) UIColor *signatureColor;
@property (assign, nonatomic) CGFloat brushOpacity;
@property (assign, nonatomic) CGFloat brushSize;
@property (assign, nonatomic) CGFloat eraserSize;
@property (assign, nonatomic) BOOL brushPop;
@property (assign, nonatomic) BOOL eraserPop;
@property (assign, nonatomic) CGRect labelFrame;
@property (strong, nonatomic) TOPStickerLabelView * stickerLab;

@end
#define Bottom_H 60
@implementation TOPGraffitiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"topscan_docgraffiti", @"");
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:kWhiteColor];
    self.brushPop = NO;
    self.eraserPop = NO;
    self.eraserSize = 10;
    [self top_initNavBar];
    [self top_configContentView];
    [self top_graffitiVC_SetBrush];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
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
#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        self.stickerLab.inputTextView.frame = CGRectMake(20, keyboardrect.origin.y-15-InputViewHeight, TOPScreenWidth - 20*2, InputViewHeight);
    }];
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
}
#pragma mark -- 导航栏
- (void)top_initNavBar {
    [self top_setBackButtonwithSelector:@selector(top_graffitiVC_Back)];
    [self top_setRigthButton:@"top_vip_logo" withSelector:@selector(top_saveGraffititImage)];
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

- (void)top_setRigthButton:(nullable NSString *)imgName withSelector:(SEL)selector {
    if (![TOPPermissionManager top_enableByImageGraffiti]) {
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
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:kTopicBlueColor];
        btn.layer.cornerRadius = 5;
        btn.tag= 115;
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = barItem;
    }
}

#pragma mark -- 涂鸦底图
- (void)top_configContentView {
    [self.bgImageSuperView addSubview:self.currnetImageView];
    [self.bgImageSuperView addSubview:self.signatureView];
    UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
    CGFloat imgMul = image.size.height/image.size.width;
    [self.currnetImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bgImageSuperView);
        make.height.mas_equalTo(self.currnetImageView.mas_width).multipliedBy(imgMul);
        make.height.lessThanOrEqualTo(self.bgImageSuperView.mas_height);
        make.width.lessThanOrEqualTo(self.bgImageSuperView.mas_width);
    }];
    __weak typeof(self) weakSelf = self;
    self.signatureView.addDrawPathBlock = ^{
        GraffitiItemModel *model = [[GraffitiItemModel alloc] initWithType:GraffitiItemTypeBrush graffitiModel:0];
        [weakSelf.graffitiItems addObject:model];
    };
    self.signatureView.touchBeginBlock = ^{
        [weakSelf top_hiddenStickerCtrl];
    };
    [self top_graffitiToolView];
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
}

- (NSArray *)toolItems {
    NSArray *tools = @[@(TOPGraffitiToolTypeText),
                       @(TOPGraffitiToolTypeBrush),
                       @(TOPGraffitiToolTypeEraser),
                       @(TOPGraffitiToolTypeUndo),
                       @(TOPGraffitiToolTypeRedo)];
    return tools;
}

#pragma mark -- 涂鸦工具栏
- (void)top_graffitiToolView {
    NSArray * sendPicArray = @[@"top_graffiti_smallText",@"top_graffiti_smallBrush",@"top_graffiti_smallEraser",@"top_graffiti_smallUndo",@"top_graffiti_smallNext"];
    NSArray * sendNameArray = @[NSLocalizedString(@"topscan_graffititext", @""), NSLocalizedString(@"topscan_graffitibrush", @""), NSLocalizedString(@"topscan_graffitieraser", @""), NSLocalizedString(@"topscan_graffitiundo", @""), NSLocalizedString(@"topscan_graffitiredo", @"")];
    NSArray *selectPicArray = @[@"top_graffiti_selectSmallText",@"top_graffiti_selectSmallBrush",@"top_graffiti_selectSmallEraser",@"top_graffiti_smallUndo",@"top_graffiti_smallNext"];
    TOPPhotoLongPressView *pressBootomView = [[TOPPhotoLongPressView alloc] initWithPressBottomFrame: CGRectMake(0, TOPScreenHeight  -TOPBottomSafeHeight - Bottom_H - TOPNavBarAndStatusBarHeight, TOPScreenWidth, Bottom_H) sendPicArray:sendPicArray sendNameArray:sendNameArray];
    pressBootomView.funcArray = [self toolItems];
    pressBootomView.highlightImgs = selectPicArray;
    WS(weakSelf);
    pressBootomView.top_longPressBootomItemHandler = ^(NSInteger index) {
        [FIRAnalytics logEventWithName:@"top_longPressBootomItemHandler" parameters:@{@"longPress":@(index)}];
        [weakSelf top_pressBottomViewWithIndex:index];
    };
    [self.view addSubview:pressBootomView];
    [pressBootomView top_didSelectedFunction:@(TOPGraffitiToolTypeBrush)];
    [pressBootomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(Bottom_H);
    }];
}

#pragma mark -- 工具执行事件
- (void)top_pressBottomViewWithIndex:(NSInteger)index {
    NSInteger toolType = [[self toolItems][index] integerValue];
    switch (toolType) {
        case TOPGraffitiToolTypeText:
            [self top_popMenuHandle];
            self.signatureView.enableDrawing = NO;
            [self top_graffitiVC_SetInputText];
            break;
        case TOPGraffitiToolTypeBrush:
            [self top_graffitiVC_SetBrush];
            break;
        case TOPGraffitiToolTypeEraser:
            [self top_graffitiVC_SetEraser];
            break;
        case TOPGraffitiToolTypeUndo:
            [self top_popMenuHandle];
            [self top_graffitiVC_Undo];
            break;
        case TOPGraffitiToolTypeRedo:
            [self top_popMenuHandle];
            [self top_graffitiVC_Redo];
            break;
        default:
            break;
    }
}

#pragma mark -- back
- (void)top_graffitiVC_Back {
    if (self.graffitiItems.count) {
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

#pragma mark -- 删除缩略图
- (void)top_deleteCoverImage {
    NSString *path = [TOPWHCFileManager top_directoryAtPath:self.imagePath];
    NSString *imgName = [TOPWHCFileManager top_fileNameAtPath:self.imagePath suffix:YES];
    NSString *coverName = [NSString stringWithFormat:@"%@_%@",[path stringByReplacingOccurrencesOfString:@"/" withString:@""],imgName];
    NSString *coverImagePath = [TOPDocumentHelper top_coverImageFile:coverName];
    [TOPWHCFileManager top_removeItemAtPath:coverImagePath];
}

#pragma mark -- done
- (void)top_saveGraffititImage {
    if ([TOPPermissionManager top_enableByImageGraffiti]) {
        if (!self.graffitiItems.count) {
            [self top_graffitiVC_Back];
            return;
        }
        if (self.noCreateFile) {
            [self top_graffitiVC_changeCurrentFile];
        } else {
            [self top_graffitiVC_saveImageMethod];
        }
    } else {
        [self top_subscriptionService];
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

#pragma mark -- 截取涂鸦生成图片
- (UIImage*)top_createBrushImage {
    CGFloat scaleSuper = self.currnetImageView.image.size.width / self.currnetImageView.frame.size.width;
    UIGraphicsBeginImageContextWithOptions(self.signatureView.frame.size, NO, scaleSuper);
    [self.signatureView.layer drawInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect rect = self.currnetImageView.frame;
    rect.origin.x *= scaleSuper;
    rect.origin.y *= scaleSuper;
    rect.size.width *= scaleSuper;
    rect.size.height *= scaleSuper;
    CGImageRef imageRef = CGImageCreateWithImageInRect(resultImg.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image;
}

#pragma mark -- 保存方式选择
- (void)top_graffitiVC_saveImageMethod {
    [FIRAnalytics logEventWithName:@"photoShow_signMethod" parameters:nil];
    TOPSCAlertController *alertController = [TOPSCAlertController alertControllerWithTitle:nil message:nil preferredStyle: IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_graffitireplacefile", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_graffitiVC_changeCurrentFile];
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_graffiticreatefile", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_graffitiVC_createNewFile];
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

#pragma mark -- 改变当前图片
- (void)top_graffitiVC_changeCurrentFile {
    [self top_hiddenStickerCtrl];
    UIImage *brushImage = [self top_createBrushImage];
    self.labelFrame = CGRectZero;
    CGPoint point = CGPointZero;
    if (self.textLabArray.count) {
        TOPStickerLabelView *stickerLab = self.textLabArray.lastObject;
        point = [self top_strickLabelFrame:stickerLab];
    }
    CGFloat scale = self.currnetImageView.image.size.width / self.currnetImageView.frame.size.width;
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
        UIImage *resultImg = [self top_waterMarkWithImage:image andWaterImage:brushImage withRect:CGRectMake(0, 0, image.size.width, image.size.height) scale:scale center:point];
        [TOPDocumentHelper top_saveImage:resultImg atPath:self.imagePath];
        [TOPEditDBDataHandler top_updateImageWithId:[TOPFileDataManager shareInstance].docModel.docId];
        [self top_deleteCoverImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (self.top_saveGraffitiImgBlick) {
                self.top_saveGraffitiImgBlick();
            }
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

#pragma mark -- 新建图片
- (void)top_graffitiVC_createNewFile {
    [self top_hiddenStickerCtrl];
    UIImage *brushImage = [self top_createBrushImage];
    self.labelFrame = CGRectZero;
    CGPoint point = CGPointZero;
    if (self.textLabArray.count) {
        TOPStickerLabelView *stickerLab = self.textLabArray.lastObject;
        point = [self top_strickLabelFrame:stickerLab];
    }
    CGFloat scale = self.currnetImageView.image.size.width / self.currnetImageView.frame.size.width;

    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
        UIImage *resultImg = [self top_waterMarkWithImage:image andWaterImage:brushImage withRect:CGRectMake(0, 0, image.size.width, image.size.height) scale:scale center:point];
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

#pragma mark -- 合并图片
- (UIImage *)top_waterMarkWithImage:(UIImage *)backgroundImage andWaterImage:(UIImage *)waterImage labelImg:(UIImage *)labelImg withRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(backgroundImage.size, NO, 1.0);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    [waterImage drawInRect:rect];
    [labelImg drawInRect:rect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)top_waterMarkWithImage:(UIImage *)backgroundImage andWaterImage:(UIImage *)waterImage withRect:(CGRect)rect scale:(CGFloat)scale center:(CGPoint)center {
    UIGraphicsBeginImageContextWithOptions(backgroundImage.size, NO, 1.0);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    [waterImage drawInRect:rect];
    
    if (self.textLabArray.count) {
        TOPStickerLabelView *stickerLab = self.textLabArray.lastObject;
        UIFont * font = [UIFont systemFontOfSize:(stickerLab.fontsize *scale)];
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
    CGFloat scale = self.currnetImageView.image.size.width / self.currnetImageView.frame.size.width;
    CGPoint centerPoint = [self.currnetImageView convertPoint:subView.center fromView:stickerLabel];
    centerPoint = CGPointMake(centerPoint.x * scale, centerPoint.y * scale);
    return centerPoint;
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

- (NSString *)top_newImagePath {
    NSString *docPath = [TOPWHCFileManager top_directoryAtPath:self.imagePath];
    NSString *fileName = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:[TOPDocumentHelper top_maxImageNumIndexAtPath:docPath]],TOP_TRJPGPathSuffixString];
    NSString *newImgPath = [docPath stringByAppendingPathComponent:fileName];
    return newImgPath;
}

#pragma mark -- 拷贝源图、ocr、note
- (void)top_saveOriginalImageWithNewImage:(NSString *)newPath {
    NSString *originalImgPath = [TOPDocumentHelper top_originalImage:self.imagePath];
    if ([TOPWHCFileManager top_isExistsAtPath:originalImgPath] && [TOPScanerShare top_saveOriginalImage]) {
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

#pragma mark -- 文字
- (void)top_graffitiVC_SetInputText {
    if (self.textLabArray.count > 0) {
        return;
    }
    static NSInteger labIndex = 1;
    NSString *graffitiText = [[NSUserDefaults standardUserDefaults] stringForKey:TOP_TRGraffitiLabelTextKey];
    self.textStr = graffitiText.length ? graffitiText : @"";
    TOPStickerLabelView *stickerLab = [[TOPStickerLabelView alloc] init];
    stickerLab.labText = self.textStr;
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRGraffitiLabelTextColorKey];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    stickerLab.textColor = color;
    [self.bgImageSuperView addSubview:stickerLab];
    stickerLab.tag = labIndex;
    GraffitiItemModel *itemModel = [[GraffitiItemModel alloc] initWithType:GraffitiItemTypeText graffitiModel:labIndex];
    __weak typeof(self) weakSelf = self;
    __weak typeof(stickerLab) weakSticker = stickerLab;
    stickerLab.deleteTextLabBlock = ^{
        __strong typeof(stickerLab) strongSticker = weakSticker;
        [weakSelf.textLabRedoArray addObject:strongSticker];
        [weakSelf.textLabArray removeObject:strongSticker];
        for (int i = 0; i < weakSelf.graffitiItems.count; i++) {
            GraffitiItemModel *model = weakSelf.graffitiItems[i];
            if (model.modelIndex == strongSticker.tag) {
                [weakSelf.reDoItems addObject:model];
                [weakSelf.graffitiItems removeObjectAtIndex:i];
                break;
            }
        }
    };
    [self.graffitiItems addObject:itemModel];
    [self.textLabArray addObject:stickerLab];
    self.stickerLab = stickerLab;
    labIndex ++;
}

#pragma mark -- 画笔
- (void)top_graffitiVC_SetBrush {
    if (self.eraserPop) {
        self.signatureView.lineWidth = self.eraserSettingView.eraserWidth;
        [self top_hiddenEraserSettingView];
    }
    if (self.brushPop) {
        [self top_resetSignatureViewColor:self.brushSettingView.currentColor brush:self.brushSettingView.brushSize opacity:self.brushSettingView.opacityValue];
        [self top_hiddenBrushSettingView];
        return;
    }
    self.signatureView.enableDrawing = YES;
    self.signatureView.hidden = NO;
    if (self.signatureColor) {
        self.brushSettingView.currentColor = self.signatureColor;
        self.signatureView.color = self.signatureColor;
    }
    if (self.brushSize) {
        self.brushSettingView.brushSize = self.brushSize;
    }
    if (self.brushOpacity) {
        self.brushSettingView.opacityValue = self.brushOpacity;
    }
    [self.view addSubview:self.brushSettingView];
    [self.brushSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view.mas_bottom);
        make.height.equalTo(self.view.mas_height).offset(Bottom_H+TOPBottomSafeHeight);
    }];
    [self top_showBrushSettingView];
    __weak typeof(self) weakSelf = self;
    self.brushSettingView.callSetCompleteBlock = ^(UIColor * _Nonnull textColor, CGFloat brush, CGFloat opacity) {
        [weakSelf top_hiddenBrushSettingView];
        [weakSelf top_resetSignatureViewColor:textColor brush:brush opacity:opacity];
    };
}

- (void)top_resetSignatureViewColor:(UIColor *)textColor brush:(CGFloat)brush opacity:(CGFloat)opacity  {
    self.signatureView.color = [textColor colorWithAlphaComponent:opacity];
    self.signatureView.lineWidth = brush;
    self.signatureColor = textColor;
    self.brushOpacity = opacity;
    self.brushSize = brush;
}

- (UIColor *)top_opacityColor:(UIColor *)color opacity:(CGFloat)opacity {
    CGFloat hue, saturation, brightness, alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    UIColor *newColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:opacity];
    return newColor;
}

#pragma mark -- 弹出画笔设置视图
- (void)top_showBrushSettingView {
    self.brushPop = YES;
    [UIView animateWithDuration:0.3
                     animations:^{
        [self.brushSettingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(Bottom_H+TOPBottomSafeHeight));
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark -- 收起画笔设置视图
- (void)top_hiddenBrushSettingView {
    self.brushPop = NO;
    CGRect frame = self.brushSettingView.frame;
    frame.origin.y = TOPScreenHeight;
    [UIView animateWithDuration:0.3
                     animations:^{
        [self.brushSettingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view.mas_bottom);
            make.height.equalTo(self.view.mas_height).offset(Bottom_H+TOPBottomSafeHeight);
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.brushSettingView removeFromSuperview];
        self.brushSettingView = nil;
    }];
}

#pragma mark -- 橡皮擦
- (void)top_graffitiVC_SetEraser {
    if (self.brushPop) {
        [self top_resetSignatureViewColor:self.brushSettingView.currentColor brush:self.brushSettingView.brushSize opacity:self.brushSettingView.opacityValue];
        [self top_hiddenBrushSettingView];
    }
    if (self.eraserPop) {
        self.signatureView.lineWidth = self.eraserSettingView.eraserWidth;
        [self top_hiddenEraserSettingView];
        return;
    }
    self.signatureView.userInteractionEnabled = YES;
    self.signatureView.color = [UIColor clearColor];
    [self.view addSubview:self.eraserSettingView];
    [self.eraserSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view.mas_bottom);
        make.height.equalTo(self.view.mas_height).offset(80+TOPBottomSafeHeight);
    }];
    [self top_showEraserSettingView];
    __weak typeof(self) weakSelf = self;
    self.eraserSettingView.callSetCompleteBlock = ^(CGFloat width) {
        weakSelf.eraserSize = width;
        weakSelf.signatureView.lineWidth = width;
        [weakSelf top_hiddenEraserSettingView];
    };
}

#pragma mark -- 处理悬浮菜单
- (void)top_popMenuHandle {
    if (self.eraserPop) {
        self.signatureView.lineWidth = self.eraserSettingView.eraserWidth;
        [self top_hiddenEraserSettingView];
    }
    if (self.brushPop) {
        [self top_resetSignatureViewColor:self.brushSettingView.currentColor brush:self.brushSettingView.brushSize opacity:self.brushSettingView.opacityValue];
        [self top_hiddenBrushSettingView];
    }
}

#pragma mark -- 弹出橡皮擦设置视图
- (void)top_showEraserSettingView {
    self.eraserPop = YES;
    CGRect frame = self.eraserSettingView.frame;
    frame.origin.y = -TOPNavBarAndStatusBarHeight;
    [UIView animateWithDuration:0.3
                     animations:^{
        [self.eraserSettingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(80+TOPBottomSafeHeight));
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark -- 收起橡皮擦设置视图
- (void)top_hiddenEraserSettingView {
    self.eraserPop = NO;
    CGRect frame = self.eraserSettingView.frame;
    frame.origin.y = TOPScreenHeight;
    [UIView animateWithDuration:0.3
                     animations:^{
        [self.eraserSettingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view.mas_bottom);
            make.height.equalTo(self.view.mas_height).offset(80+TOPBottomSafeHeight);
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.eraserSettingView removeFromSuperview];
        self.eraserSettingView = nil;
    }];
}

#pragma mark -- 撤销到上一步
- (void)top_graffitiVC_Undo {
    if (self.graffitiItems.count) {
        GraffitiItemModel *itemTypeModel = self.graffitiItems.lastObject;
        switch (itemTypeModel.itemType) {
            case GraffitiItemTypeText:
                [self top_textDrawUndo];
                break;
            case GraffitiItemTypeBrush:
                [self top_brushDrawUndo];
                break;
                
            default:
                break;
        }
        [self.reDoItems addObject:itemTypeModel];
        [self.graffitiItems removeLastObject];
    }
}

#pragma mark -- 恢复撤销
- (void)top_graffitiVC_Redo {
    if (self.reDoItems.count) {
        GraffitiItemModel *itemTypeModel = self.reDoItems.lastObject;
        switch (itemTypeModel.itemType) {
            case GraffitiItemTypeText:
                [self top_textDrawRedo];
                break;
            case GraffitiItemTypeBrush:
                [self top_brushDrawRedo];
                break;
                
            default:
                break;
        }
        [self.graffitiItems addObject:itemTypeModel];
        [self.reDoItems removeLastObject];
    }
}

#pragma mark -- 文字撤销
- (void)top_textDrawUndo {
    if (self.textLabArray.count) {
        TOPStickerLabelView *stickerLab = self.textLabArray.lastObject;
        [self.textLabRedoArray addObject:stickerLab];
        [stickerLab removeFromSuperview];
        [self.textLabArray removeLastObject];
    }
}

#pragma mark -- 笔画撤销
- (void)top_brushDrawUndo {
    [self.signatureView undo];
}

#pragma mark -- 文字恢复
- (void)top_textDrawRedo {
    if (self.textLabRedoArray.count) {
        TOPStickerLabelView *stickerLab = self.textLabRedoArray.lastObject;
        [self.textLabArray addObject:stickerLab];
        [self.bgImageSuperView addSubview:stickerLab];
        [self.textLabRedoArray removeLastObject];
    }
}

#pragma mark -- 笔画恢复
- (void)top_brushDrawRedo {
    [self.signatureView redo];
}

#pragma mark -- 橡皮擦大小
- (void)top_sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.signatureView.lineWidth = slider.value;
}

#pragma mark -- 底图frame
- (CGRect)top_adaptiveBGImage:(UIImage *)image {
    UIImage *imageTy = image;
    float imgWidth = 0;
    float imgHeight = 0;

    CGFloat fatherWidth = TOPScreenWidth;
    CGFloat fatherHeight = TOPScreenHeight - TOPNavBarAndStatusBarHeight - TOPBottomSafeHeight-Bottom_H;
    if (!imageTy.size.width || !imageTy.size.height) {
        return CGRectMake(0, 0, fatherWidth, fatherHeight);
    }
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
        CGFloat imageH = TOPScreenHeight - TOPNavBarAndStatusBarHeight - TOPBottomSafeHeight-Bottom_H;
        _bgImageSuperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth, imageH)];
        _bgImageSuperView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:ViewBgColor];
        [self.view addSubview:_bgImageSuperView];
        [[NSUserDefaults standardUserDefaults] setFloat:imageH forKey:@"superViewHeight"];
        [_bgImageSuperView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
        }];
    }
    return _bgImageSuperView;
}

- (TOPEraserSettingView *)eraserSettingView {
    if (!_eraserSettingView) {
        _eraserSettingView = [[TOPEraserSettingView alloc] initWithEarserValue:self.eraserSize];
    }
    return _eraserSettingView;
}

- (TOPBrushSettingView *)brushSettingView {
    if (!_brushSettingView) {
        _brushSettingView = [[TOPBrushSettingView alloc] init];
        _brushSettingView.brushSize = 3;
        _brushSettingView.opacityValue = 1;
        _brushSettingView.currentColor = [UIColor blackColor];
    }
    return _brushSettingView;
}

- (TOPSignatureView *)signatureView {
    if (!_signatureView) {
        _signatureView = [[TOPSignatureView alloc] init];
        _signatureView.color = [UIColor blackColor];
        _signatureView.lineWidth = 3;
        _signatureView.hidden = YES;
        _signatureView.backgroundColor = [UIColor clearColor];
        _signatureView.frame = self.bgImageSuperView.bounds;
    }
    return _signatureView;
}

- (NSMutableArray *)graffitiItems {
    if (!_graffitiItems) {
        _graffitiItems = [[NSMutableArray alloc] init];
    }
    return _graffitiItems;
}

- (NSMutableArray *)reDoItems {
    if (!_reDoItems) {
        _reDoItems = [[NSMutableArray alloc] init];
    }
    return _reDoItems;
}

- (NSMutableArray *)textLabArray {
    if (!_textLabArray) {
        _textLabArray = [[NSMutableArray alloc] init];
    }
    return _textLabArray;
}

- (NSMutableArray *)textLabRedoArray {
    if (!_textLabRedoArray) {
        _textLabRedoArray = [[NSMutableArray alloc] init];
    }
    return _textLabRedoArray;
}

@end
