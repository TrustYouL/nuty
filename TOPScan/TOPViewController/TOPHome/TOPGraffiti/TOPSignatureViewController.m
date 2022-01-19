#import "TOPSignatureViewController.h"
#import "TOPSignatureView.h"
#import "TOPSelectLineWithAlertView.h"
#import "TOPSelectColorAlertView.h"
#import "TOPSelectEraserAlertView.h"
#import "AppDelegate.h"
#import "TOPPhotoCombineSignatureVC.h"
#import "UIDevice+SSDevice.h"
#import "TOPCornerToast.h"
#import "UIButton+LongTap.h"

@interface TOPSignatureViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong)UIColor *currentDefaultColor;
@property (nonatomic,assign)NSInteger currentDefaultlineWidth;
@property (nonatomic,strong)TOPSignatureView *signatureView;
@property (nonatomic,strong)UIView *dashLineView;
@property (nonatomic,strong)UIImageView *resestImageView;
@property (nonatomic,strong)UIImageView *guideImageView;
@property (nonatomic,assign)BOOL isBackClick;
@property (nonatomic,assign)CGFloat topH;
@property (nonatomic,assign)CGFloat statusBarHeight;
@property (nonatomic,assign)CGFloat bottomSafeHeight;

@end

@implementation TOPSignatureViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationNone;
} 
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.statusBarHeight = TOPStatusBarHeight;
    self.bottomSafeHeight = TOPBottomSafeHeight;
    [self top_setLandscapeRight];
    
    self.topH = 0.0;
    if (IS_IPAD) {
        self.topH = TOPStatusBarHeight;
    }
    UIView *customNavView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 44+self.topH)];
    customNavView.backgroundColor = TOPAPPGreenColor;
    [self.view addSubview:customNavView];
    customNavView.tag = 1599;
    [customNavView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.mas_equalTo(44+self.topH);
    }];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"top_return_white_icon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    backButton.frame =  CGRectMake(self.statusBarHeight, self.topH+2, 40, 40);
    [customNavView addSubview:backButton];
    [backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(customNavView).offset(self.statusBarHeight);
        make.top.equalTo(customNavView).offset(self.topH+2);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    NSArray *colorArrays = @[UIColorFromRGB(0x000000),UIColorFromRGB(0xFF7979),UIColorFromRGB(0xD02C25),UIColorFromRGB(0xFFF132),UIColorFromRGB(0xF6B61D),UIColorFromRGB(0xBB1DF6),UIColorFromRGB(0x79F61D),UIColorFromRGB(0x1DF6DF),UIColorFromRGB(0x00964C),UIColorFromRGB(0x1DB6F6),UIColorFromRGB(0x1D41F6),UIColorFromRGB(0x5F1DF6)];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRDefaultSignatureColor] == nil) {
        
        self.currentDefaultColor = [UIColor blackColor];
    }else{
        NSInteger index =  [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRDefaultSignatureColor] integerValue];
        if (index<=colorArrays.count-1) {
            self.currentDefaultColor = colorArrays[index];
        }
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRDefaultSignatureLineWitdth] == nil) {
        self.currentDefaultlineWidth = 3;
    }else{
        NSInteger currentLineWidth = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRDefaultSignatureLineWitdth] integerValue];
        self.currentDefaultlineWidth = currentLineWidth;
    }
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E6E6E6"];
    self.dashLineView = [[UIView alloc] initWithFrame:CGRectMake(self.statusBarHeight, 44 + 10+self.topH,  TOPScreenWidth- self.statusBarHeight*2,TOPScreenHeight-44-20-self.bottomSafeHeight-self.topH)];
    self.dashLineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.dashLineView];
    [self.dashLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(self.statusBarHeight);
        make.trailing.equalTo(self.view).offset(-self.statusBarHeight);
        make.top.equalTo(self.view).offset(44+10+self.topH);
        make.bottom.equalTo(self.view).offset(-(10+self.bottomSafeHeight));
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self top_drawDashLine:self.dashLineView lineLength:4 lineSpacing:2 lineColor:kTopicBlueColor];
    });
    
    self.signatureView = [[TOPSignatureView alloc] init];
    self.signatureView.color =self.currentDefaultColor;
    self.signatureView.lineWidth = self.currentDefaultlineWidth;
    self.signatureView.hidden = YES;
    [self.view addSubview:self.signatureView ];
    self.signatureView .backgroundColor = [UIColor clearColor];
    self.signatureView .frame = CGRectMake(self.statusBarHeight, 44 + 10+self.topH,  TOPScreenWidth- self.statusBarHeight*2,TOPScreenHeight-44-20-self.bottomSafeHeight-self.topH);
    [self.signatureView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(self.statusBarHeight);
        make.trailing.equalTo(self.view).offset(-self.statusBarHeight);
        make.top.equalTo(self.view).offset(44+10+self.topH);
        make.bottom.equalTo(self.view).offset(-(10+self.bottomSafeHeight));
    }];
    [self.view addSubview:self.guideImageView];
    self.guideImageView.hidden = YES;
    __weak typeof(self) weakSelf = self;
    self.signatureView.addDrawPathBlock = ^{
        weakSelf.guideImageView.hidden = YES;
    };
    
    if (self.openSignatureStyle == TRSignatureEditStyleReset) {
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearButton setImage:[UIImage imageNamed:@"top_graffiti_trash"] forState:UIControlStateNormal];
        clearButton.contentMode = UIViewContentModeScaleAspectFit;
        [clearButton addTarget:self action:@selector(top_resetSignatureImgaeViewClick:) forControlEvents:UIControlEventTouchUpInside];
        clearButton.tag= 1252;
        [customNavView addSubview:clearButton];
        clearButton.frame = CGRectMake(CGRectGetWidth(customNavView.frame)-60, self.topH+2, 40, 40);
        
        UIImage *sigImage = [UIImage imageWithContentsOfFile:[TOPSignationImagePath stringByAppendingPathComponent:TOP_TRSignationImageName]];
        self.resestImageView = [[UIImageView alloc] initWithImage:sigImage];
        self.resestImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.signatureView.hidden = YES;
        self.dashLineView.hidden = YES;
        self.view.backgroundColor = kWhiteColor;
        
        [self.view addSubview:self.resestImageView];
        self.resestImageView .backgroundColor = [UIColor clearColor];
        CGFloat imgScale = [UIScreen mainScreen].scale;
        CGFloat imageW = sigImage.size.width/imgScale;
        CGFloat imageH = sigImage.size.height/imgScale;
        self.resestImageView .frame = CGRectMake((CGRectGetHeight(self.view.frame) - imageW)/2, (CGRectGetWidth(self.view.frame) - imageH)/2,  imageW, imageH);
        
    }else{
        self.signatureView.hidden = NO;
        self.guideImageView.hidden = NO;
        [self top_addTopHeaderItemView:customNavView];
    }
    
    [self top_setupBack];
}

- (void)top_drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setFrame:lineView.bounds];
    shapeLayer.path = [UIBezierPath bezierPathWithRect:lineView.bounds].CGPath;
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    [shapeLayer setStrokeColor:lineColor.CGColor];
    [shapeLayer setLineWidth:1];
    [shapeLayer setLineDashPattern:@[@(lineLength), @(lineSpacing)]];
    [lineView.layer addSublayer:shapeLayer];
}

- (void)top_setLandscapeRight {
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = YES;
    [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)top_addTopHeaderItemView:(UIView *)cusNavView
{
    if (self.openSignatureStyle == TRSignatureEditStyleReset) {
        UIButton *resetButton = [cusNavView viewWithTag:1252];
        [resetButton removeFromSuperview];
    }
    
    CGFloat intervalValue = 15.0;
    CGFloat buttonW = 40.0;
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"top_ocr_savetext-1"] forState:UIControlStateNormal];
    clearButton.contentMode = UIViewContentModeScaleAspectFit;
    [clearButton addTarget:self action:@selector(top_saveImageClick:) forControlEvents:UIControlEventTouchUpInside];
    clearButton.tag= 110;
    [cusNavView addSubview:clearButton];
    clearButton.frame = CGRectMake(CGRectGetWidth(cusNavView.frame)-buttonW-intervalValue, self.topH+2, buttonW, buttonW);
    [clearButton addLongTapWithTarget:self action:@selector(top_saveLongBut:)];

    UIButton *saveSigntureBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveSigntureBut setImage:[UIImage imageNamed:@"top_graffiti_smallEraser-1"] forState:UIControlStateNormal];
    [saveSigntureBut addTarget:self action:@selector(top_saveImageClick:) forControlEvents:UIControlEventTouchUpInside];
    saveSigntureBut.tag= 111;
    [cusNavView addSubview:saveSigntureBut];
    saveSigntureBut.frame = CGRectMake(CGRectGetMinX(clearButton.frame)-intervalValue-buttonW, self.topH+2, buttonW, buttonW);
    [saveSigntureBut addLongTapWithTarget:self action:@selector(top_eraserLongBut:)];

    UIButton *eraserSigntureBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [eraserSigntureBut setImage:[UIImage imageNamed:@"top_graffiti_smallBrush-1"] forState:UIControlStateNormal];
    [eraserSigntureBut addTarget:self action:@selector(top_saveImageClick:) forControlEvents:UIControlEventTouchUpInside];
    eraserSigntureBut.tag= 112;
    [cusNavView addSubview:eraserSigntureBut];
    eraserSigntureBut.frame = CGRectMake(CGRectGetMinX(saveSigntureBut.frame)-intervalValue-buttonW, self.topH+2, buttonW, buttonW);
    [eraserSigntureBut addLongTapWithTarget:self action:@selector(top_colorLongBut:)];
    
    UIButton *colorSigntureBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [colorSigntureBut setImage:[UIImage imageNamed:@"top_graffiti_paintbrush"] forState:UIControlStateNormal];
    [colorSigntureBut addTarget:self action:@selector(top_saveImageClick:) forControlEvents:UIControlEventTouchUpInside];
    colorSigntureBut.tag= 113;
    [cusNavView addSubview:colorSigntureBut];
    colorSigntureBut.frame = CGRectMake(CGRectGetMinX(eraserSigntureBut.frame)-intervalValue-buttonW, self.topH+2, buttonW, buttonW);
    [colorSigntureBut addLongTapWithTarget:self action:@selector(top_paintbrushLongBut:)];

    UIButton *paintbrushSigntureBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [paintbrushSigntureBut setImage:[UIImage imageNamed:@"top_graffiti_smallUndo-1"] forState:UIControlStateNormal];
    [paintbrushSigntureBut addTarget:self action:@selector(top_saveImageClick:) forControlEvents:UIControlEventTouchUpInside];
    paintbrushSigntureBut.tag= 114;
    [cusNavView addSubview:paintbrushSigntureBut];
    paintbrushSigntureBut.frame = CGRectMake(CGRectGetMinX(colorSigntureBut.frame)-intervalValue-buttonW, self.topH+2, buttonW, buttonW);
    [paintbrushSigntureBut addLongTapWithTarget:self action:@selector(top_undoLongBut:)];

    UIButton *withdrawSigntureBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [withdrawSigntureBut setImage:[UIImage imageNamed:@"top_graffiti_trash"] forState:UIControlStateNormal];
    [withdrawSigntureBut addTarget:self action:@selector(top_saveImageClick:) forControlEvents:UIControlEventTouchUpInside];
    withdrawSigntureBut.tag= 115;
    [cusNavView addSubview:withdrawSigntureBut];
    withdrawSigntureBut.frame = CGRectMake(CGRectGetMinX(paintbrushSigntureBut.frame)-intervalValue-buttonW, self.topH+2, buttonW, buttonW);
    [withdrawSigntureBut addLongTapWithTarget:self action:@selector(top_clearLongBut:)];
    
}

#pragma mark - 返回按钮
- (void)top_setupBack {
    NSString *imageName = @"top_return_white_icon";
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, (52), 44)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 25)];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItems = @[barItem];
}
- (void)back
{
    [self top_setLandscapePortrait];
    self.isBackClick = YES;
    
    if (![TOPWHCFileManager top_isExistsAtPath:[TOPSignationImagePath stringByAppendingPathComponent:TOP_TRSignationImageName]]) {
        [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_drawingImageFileString]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)top_setLandscapePortrait {
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = NO;
    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    
    if (self.top_backToResetContentoffset) {
        self.top_backToResetContentoffset();
    }
}
- (void)top_clearLongBut:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_clear", @"")];
    }
}

- (void)top_saveLongBut:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_batchsave", @"")];
    }
    
}
- (void)top_eraserLongBut:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_graffitieraser", @"")];
    }
}
- (void)top_colorLongBut:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_graffiticolor", @"")];
    }
}
- (void)top_paintbrushLongBut:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_graffitibrush", @"")];
    }
}
- (void)top_undoLongBut:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_graffitiundo", @"")];
    }
}

- (void)top_saveImageClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 110:
        {
            if (self.signatureView.isAlreadySignture == NO) {
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_nosignture", @"")];
                return;
            }
            UIImage *imageqianming = [self.signatureView getDrawingImg];
            if (self.top_saveSignatureBlock) {
                self.top_saveSignatureBlock(imageqianming);
                [self back];
            } else {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if(![fileManager fileExistsAtPath:TOPSignationImagePath]){
                    [fileManager createDirectoryAtPath:TOPSignationImagePath withIntermediateDirectories:YES attributes:nil error:nil];
                }
                [UIImagePNGRepresentation(imageqianming) writeToFile:[TOPSignationImagePath stringByAppendingPathComponent:TOP_TRSignationImageName] atomically:YES];
                
                self.isBackClick = YES;
                
                [self top_setLandscapePortrait];
                TOPPhotoCombineSignatureVC *photoeditSign = [[TOPPhotoCombineSignatureVC alloc] init];
                photoeditSign.imagePath = self.imagePath;
                photoeditSign.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:photoeditSign animated:YES];
            }
        }
            break;
        case 111:
        {
            TOPSelectEraserAlertView *eraserView = [TOPSelectEraserAlertView top_creatXIB];
            WeakSelf(ws);
            eraserView.saveLineWidthSelectBlock = ^(NSInteger currentLineWidth) {
                if (self.signatureView.isAlreadySignture == NO) {
                    [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_nosignture", @"")];
                    return;;
                }
                ws.signatureView.color = [UIColor clearColor];
                ws.signatureView.lineWidth = currentLineWidth;
            };
            [eraserView top_showXib];
        }
            break;
        case 112:
        {
            TOPSelectColorAlertView *colorView = [TOPSelectColorAlertView top_creatXIB];
            WeakSelf(ws);
            colorView.saveColorSelectBlock = ^(UIColor *currentColor) {
                ws.signatureView.color = currentColor;
                ws.currentDefaultColor = currentColor;
                ws.signatureView.lineWidth = ws.currentDefaultlineWidth;
            };
            
            [colorView top_showXib];
            
        }
            break;
        case 113:
        {
            WeakSelf(ws);
            
            TOPSelectLineWithAlertView *colorView = [TOPSelectLineWithAlertView top_creatXIB];
            colorView.saveLineWidthSelectBlock = ^(NSInteger currentLineWidth) {
                ws.signatureView.lineWidth = currentLineWidth;
                ws.currentDefaultlineWidth = currentLineWidth;
                ws.signatureView.color = ws.currentDefaultColor;
            };
            [colorView top_showXib];
        }
            break;
        case 114:
        {
            if (self.signatureView.isAlreadySignture == NO) {
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_nosignture", @"")];
                return;;
            }
            
            [self.signatureView undo];
        }
            break;
        case 115:
        {
            if (self.signatureView.isAlreadySignture == NO) {
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_nosignture", @"")];
                return;
            }
            [self.signatureView clear];
        }
            break;
        default:
            break;
    }
    
}

- (void)top_resetSignatureImgaeViewClick:(UIButton *)sender
{
    [self.resestImageView removeFromSuperview];
    self.resestImageView = nil;
    UIView *customNavView = [self.view viewWithTag:1599];
    [self top_addTopHeaderItemView:customNavView];
    self.signatureView.hidden = NO;
    self.guideImageView.hidden = NO;
    self.dashLineView.hidden = NO;
    self.view.backgroundColor = [UIColor colorWithHexString:@"E6E6E6"];
}
- (NSString *)getDateNumberNameString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSString *dateStr = [formatter  stringFromDate:[NSDate date]];
    return dateStr;
}

- (UIImageView *)guideImageView {
    if (!_guideImageView) {
        _guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 135, 161)];
        _guideImageView.center = self.signatureView.center;
        _guideImageView.image = [UIImage imageNamed:@"top_signature_here"];
        _guideImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _guideImageView;
}

@end
