#import "TOPImageWaterMarkController.h"
#import "TOPPhotoLongPressView.h"
#import "UIImageView+WaterMark.h"
#import "TOPMarkTextInputView.h"
#import "TOPWaterMark.h"
#import "TOPShareTypeView.h"
#import "TOPShareDownSizeView.h"
#import "TOPDataModelHandler.h"
#import "TOPSettingEmailModel.h"
#import "TOPWatermarkSettingView.h"

@interface TOPImageWaterMarkController ()<MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) UIImageView *bgSuperView;
@property (strong, nonatomic) TOPPhotoLongPressView *barBootomView;
@property (strong, nonatomic) UIImageView *waterMarkImgView;
@property (strong, nonatomic) UIView *contentView;
@property (assign, nonatomic) BOOL brushPop;
@property (assign, nonatomic) CGFloat fontScale;
@property (strong, nonatomic) TOPMarkTextInputView *inputTextView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, assign) NSInteger emailType;
@property (nonatomic, assign) NSInteger pdfType;
@property (nonatomic, strong) TOPShareTypeView * shareAction;
@property (nonatomic, copy) NSString * totalSizeString;
@property (nonatomic, assign) CGFloat totalSizeNum;
@property (nonatomic, strong) DocumentModel * imageModel;
@property (nonatomic, strong) TOPSettingEmailModel * emailModel;
@property (nonatomic, strong) TOPWatermarkSettingView *watermarkSettingView;

@end
#define Bottom_H 60
@implementation TOPImageWaterMarkController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"topscan_watermarktitle", @"");
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:ViewBgColor];
    [self top_initNavBar];
    [self top_configContentView];
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]];
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_copyImageFileString]];
    self.fontScale = 3.0;
    [self top_showInputView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.titleTextAttributes=
    @{NSForegroundColorAttributeName:[UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor],
    NSFontAttributeName:[UIFont systemFontOfSize:18]};
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
#pragma mark -- 导航栏
- (void)top_initNavBar {
    if (isRTL()) {//黑色
        [self top_setBackButton:@"top_RTLbackItem" withSelector:@selector(top_waterMarkVC_goBack)];
    }else{
        [self top_setBackButton:@"top_backItem" withSelector:@selector(top_waterMarkVC_goBack)];
    }
    [self top_setRigthButton:NSLocalizedString(@"topscan_tagsdone", @"") withSelector:@selector(top_waterMarkVC_saveDone)];
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

- (void)top_setRigthButton:(nullable NSString *)title withSelector:(SEL)selector {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
}


#pragma mark -- 主视图
- (void)top_configContentView {
    [self.contentView addSubview:self.bgSuperView];
    [self top_waterMarkMenuView];
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight - TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
}

#pragma mark -- 涂鸦工具栏
- (void)top_waterMarkMenuView {
    NSArray * sendPicArray = @[@"top_collage_waterMark",@"top_waterMark_clear",@"top_downview_share"];
    NSArray * sendNameArray = @[NSLocalizedString(@"topscan_addwatermark", @""), NSLocalizedString(@"topscan_clearwatermark", @""), NSLocalizedString(@"topscan_share", @"")];
    TOPPhotoLongPressView *pressBootomView = [[TOPPhotoLongPressView alloc] initWithPressBottomFrame: CGRectMake(0, TOPScreenHeight  -TOPBottomSafeHeight - Bottom_H - TOPNavBarAndStatusBarHeight, TOPScreenWidth, Bottom_H) sendPicArray:sendPicArray sendNameArray:sendNameArray];
    pressBootomView.funcArray = [self toolItems];
    WS(weakSelf);
    pressBootomView.top_longPressBootomItemHandler = ^(NSInteger index) {
        [FIRAnalytics logEventWithName:@"top_longPressBootomItemHandler" parameters:@{@"longPress":@(index)}];
        [weakSelf top_pressBottomViewWithIndex:index];
    };
    [self.view addSubview:pressBootomView];
    self.barBootomView = pressBootomView;
}

- (NSArray *)toolItems {
    NSArray *tools = @[@(TOPWaterMarkFunctionTypeAdd),
                       @(TOPWaterMarkFunctionTypeClear),
                       @(TOPWaterMarkFunctionTypeShare)];
    return tools;
}


#pragma mark -- 工具执行事件
- (void)top_pressBottomViewWithIndex:(NSInteger)index {
    NSInteger toolType = [[self toolItems][index] integerValue];
    switch (toolType) {
        case TOPWaterMarkFunctionTypeAdd:
            [self top_showInputView];
            break;
        case TOPWaterMarkFunctionTypeClear:
            [self top_clearWaterMark];
            break;
        case TOPWaterMarkFunctionTypeShare:
            [self top_watermark_ShareTip];
            break;
        default:
            break;
    }
}

#pragma mark -- 返回
- (void)top_waterMarkVC_goBack {
    if ([TOPWHCFileManager top_isExistsAtPath:[TOPDocumentHelper top_copyImageFileString]]) {
        [TOPWHCFileManager top_moveItemAtPath:[TOPDocumentHelper top_copyImageFileString] toPath:self.imagePath overwrite:YES];
    }
    if ([TOPWHCFileManager top_isExistsAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]]) {
        [self top_saveImageAlert];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -- 保存提示
- (void)top_saveImageAlert {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_note", @"")
                                                                   message:NSLocalizedString(@"topscan_savealert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_discard", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        
        [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 保存
- (void)top_waterMarkVC_saveDone {
    [self top_saveWaterMarkImg];
}

#pragma mark -- 水印文字
- (NSString *)markText {
    NSString *markText = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRWatermarkTextkey];
    if (!markText) {
        markText = @"";
    }
    return markText;
}

- (void)top_setMarkTextColor:(UIColor *)textColor {
    //默认水印颜色
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:textColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:TOP_TRWatermarkTextColorKey];
}

#pragma mark -- 清除水印
- (void)top_clearWaterMark {
    [self.waterMarkImgView removeFromSuperview];
    self.waterMarkImgView = nil;
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]];
    self.barBootomView.funcTitles = @[NSLocalizedString(@"topscan_addwatermark", @""), NSLocalizedString(@"topscan_clearwatermark", @""),  NSLocalizedString(@"topscan_share", @"")];
}

#pragma mark -- 生成水印
- (void)top_createMarkImage:(NSString *)text {
    if (text.length) {
        if ([TOPWHCFileManager top_isExistsAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]]) {
            [self.waterMarkImgView removeFromSuperview];
            self.waterMarkImgView = nil;
        }
        [[NSUserDefaults standardUserDefaults] setObject:text forKey:TOP_TRWatermarkTextkey];
        CGFloat scale = [UIScreen mainScreen].scale;
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.bgSuperView.bounds) * scale, CGRectGetHeight(self.bgSuperView.bounds) * scale);
        UIImageView *waterMarkView = [[UIImageView alloc] initWithFrame:frame];
        UIImage *mark = [TOPWaterMark view:waterMarkView WaterImageWithImage:[UIImage imageNamed:@""] text:text];
        self.waterMarkImgView.image = mark;
        [self.bgSuperView addSubview:self.waterMarkImgView];
        self.barBootomView.funcTitles = @[NSLocalizedString(@"topscan_editwatermark", @""), NSLocalizedString(@"topscan_clearwatermark", @""), NSLocalizedString(@"topscan_share", @"")];
    }
}

#pragma mark -- 弹出输入框、键盘
- (void)top_showInputView {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_watermarktitle", @"")
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(alert) weakAlert = alert;
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        __strong typeof(weakAlert) strongAlert = weakAlert;
        if (!strongAlert.textFields.firstObject.text.length) {
            return;
        }
        NSString *text = strongAlert.textFields.firstObject.text;
        [[NSUserDefaults standardUserDefaults] setObject:text forKey:TOP_TRWatermarkTextkey];
        [self top_createMarkImage:text];
        [self top_showWatermarkSettingView];
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tintColor = TOPAPPGreenColor;
        textField.text = [self markText];
    }];
    UIColor * titleColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:TOPAPPGreenColor];
    [okAction setValue:titleColor forKey:@"_titleTextColor"];
    [cancelAction setValue:titleColor forKey:@"_titleTextColor"];
    [alert addAction:okAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 输入控件消失
- (void)top_hiddenInputView {
    [UIView animateWithDuration:0.3
                     animations:^{
        self.maskView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 1.5);
    } completion:^(BOOL finished) {
        [self.inputTextView removeFromSuperview];
        self.inputTextView = nil;
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }];
}

#pragma mark -- 弹出设置水印菜单视图
- (void)top_showWatermarkSettingView {
    [self.view addSubview:self.watermarkSettingView];
    [UIView animateWithDuration:0.3
                     animations:^{
        self.watermarkSettingView.frame = CGRectMake(0, TOPScreenHeight - self.watermarkSettingView.frame.size.height - TOPBottomSafeHeight - TOPNavBarAndStatusBarHeight, TOPScreenWidth, self.watermarkSettingView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark -- 收起设置水印菜单视图
- (void)top_hiddenWatermarkSettingView {
    [UIView animateWithDuration:0.3
                     animations:^{
        self.watermarkSettingView.frame = CGRectMake(0, TOPScreenHeight, TOPScreenWidth, self.watermarkSettingView.frame.size.height);
    } completion:^(BOOL finished) {
        [self.watermarkSettingView removeFromSuperview];
        self.watermarkSettingView = nil;
    }];
}

- (void)top_createWaterMarkImage:(NSString *)text textColor:(UIColor *)textColor fontValue:(CGFloat)fontValue opacity:(CGFloat)opacity {
    [self top_setMarkTextColor:textColor];
    [[NSUserDefaults standardUserDefaults] setObject:text forKey:TOP_TRWatermarkTextkey];
    [[NSUserDefaults standardUserDefaults] setFloat:fontValue forKey:TOP_TRWatermarkTextFontValueKey];
    [[NSUserDefaults standardUserDefaults] setFloat:opacity forKey:TOP_TRWatermarkTextOpacityKey];
    [self top_createMarkImage:text];
}

- (void)top_updateWatermarkImageWithTextColor:(UIColor *)textColor fontValue:(CGFloat)fontValue opacity:(CGFloat)opacity {
    [self top_setMarkTextColor:textColor];
    [[NSUserDefaults standardUserDefaults] setFloat:fontValue forKey:TOP_TRWatermarkTextFontValueKey];
    [[NSUserDefaults standardUserDefaults] setFloat:opacity forKey:TOP_TRWatermarkTextOpacityKey];
    NSString *text = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRWatermarkTextkey];
    [self top_createMarkImage:text];
}

#pragma mark -- 保存水印并更新图片
- (void)top_saveWaterMarkImg {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [self top_handleWatermarkImageComplection:^{
        [SVProgressHUD dismiss];
        if (weakSelf.top_saveWatermarkBlock) {
            weakSelf.top_saveWatermarkBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)top_handleWatermarkImageComplection:(void (^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([TOPWHCFileManager top_isExistsAtPath:[TOPDocumentHelper top_copyImageFileString]]) {//
            [TOPWHCFileManager top_removeItemAtPath:self.imagePath];
            [TOPWHCFileManager top_copyItemAtPath:[TOPDocumentHelper top_copyImageFileString] toPath:self.imagePath];
        }
        UIImage *bgImg = [UIImage imageWithContentsOfFile:self.imagePath];
        UIImage *markImg = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_waterMarkTextImagePath]];
        UIImage *resultImg = [TOPPictureProcessTool top_waterMarkWithImage:bgImg andWaterImage:markImg withRect:CGRectMake(0, 0, bgImg.size.width, bgImg.size.height)];
        [TOPDocumentHelper top_saveImage:resultImg atPath:self.imagePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    });
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
- (void)top_watermark_ShareTip {
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self top_watermark_ShowShareView];
        }
    }];
}
- (void)top_watermark_ShowShareView{
    [FIRAnalytics logEventWithName:@"watermark_ShareTip" parameters:nil];
    NSString *fileName = [TOPWHCFileManager top_fileNameAtPath:self.imagePath suffix:YES];
    NSString *docPath = [TOPWHCFileManager top_directoryAtPath:self.imagePath];
    self.imageModel = [TOPDataModelHandler top_buildImageModelWithName:fileName atPath:docPath];
    self.emailType = 0;
    if (![TOPWHCFileManager top_isExistsAtPath:[TOPDocumentHelper top_copyImageFileString]]) {//
        [TOPWHCFileManager top_copyItemAtPath:self.imagePath toPath:[TOPDocumentHelper top_copyImageFileString]];
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [self top_handleWatermarkImageComplection:^{
        [SVProgressHUD dismiss];
        [weakSelf top_addShareAction];
        [weakSelf top_calculateSelectNumber];
    }];
}
- (void)top_addShareAction {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    WS(weakSelf);
    NSArray * titleArray = @[NSLocalizedString(@"topscan_pdffile", @""),NSLocalizedString(@"topscan_image_jpg", @"")];
    NSArray * picArray = @[@"top_SharePDF",@"top_ShareJPG"];
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
                        [weakSelf presentViewController: activiVC animated:YES completion:nil];
                    }
                }];
                
                NSMutableArray * currentArray = [NSMutableArray new];
                weakSelf.imageModel.selectStatus = YES;
                [currentArray addObject:weakSelf.imageModel];
                
                [weakSelf.view addSubview:sizeView];
                sizeView.compressType = row;
                sizeView.childArray = currentArray;
                sizeView.totalNum = weakSelf.totalSizeNum;
                sizeView.numberStr = weakSelf.totalSizeString;
            }else{
            }
        }else{
            if(row == 0) {
                [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
                NSMutableArray * imgArray = [NSMutableArray new];
                NSString * pdfName = [NSString new];
                
                UIImage * img = [UIImage imageWithContentsOfFile:weakSelf.imagePath];
                if ([TOPScanerShare top_singleFileUserDefinedFileSizeState] && ([TOPScanerShare top_userDefinedFileSize] > 0)) {
                    NSString * compressFile = [TOPDocumentHelper top_saveCompressImage:weakSelf.imagePath maxCompression:([TOPScanerShare top_userDefinedFileSize]/100.0)];
                    if (compressFile.length) {
                        img = [UIImage imageWithContentsOfFile:compressFile];
                    }
                }
                if (img) {
                    [imgArray addObject:img];
                }
                pdfName = [NSString stringWithFormat:@"%@-1",weakSelf.imageModel.fileName];
                
                //合成pdf图片
                NSString * path = [TOPDocumentHelper top_creatPDF:imgArray documentName:pdfName];
                NSURL * file = [NSURL fileURLWithPath:path];
                
                if (weakSelf.emailType == 1) {
                    [weakSelf top_sendEmail:@[file]];
                }else{
                    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:@[file] applicationActivities:nil];
                    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
                    activiVC.excludedActivityTypes = excludedActivityTypes;
                    [weakSelf presentViewController: activiVC animated:YES completion:nil];
                }
            }else if(row == 1){
                NSURL * file = [NSURL fileURLWithPath:weakSelf.imagePath];
                if ([TOPScanerShare top_singleFileUserDefinedFileSizeState] && ([TOPScanerShare top_userDefinedFileSize] > 0)) {
                    NSString * compressFile = [TOPDocumentHelper top_saveCompressImage:weakSelf.imagePath maxCompression:([TOPScanerShare top_userDefinedFileSize]/100.0)];
                    if (compressFile.length) {
                        file = [NSURL fileURLWithPath:compressFile];
                    }
                }
                if (weakSelf.emailType == 1) {
                    [weakSelf top_sendEmail:@[file]];
                }else{
                    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:@[file] applicationActivities:nil];
                    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
                    activiVC.excludedActivityTypes = excludedActivityTypes;
                    [weakSelf presentViewController: activiVC animated:YES completion:nil];
                }
            }else{
            }
        }
    }];
    self.shareAction = shareAction;
    [window addSubview:shareAction];
}

#pragma mark -- 计算图片大小
- (void)top_calculateSelectNumber{
    NSMutableArray * tempPathArray = [NSMutableArray new];
    [tempPathArray addObject:self.imagePath];
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
        TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_bind", @"")
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
                NSString * photoName = [NSString stringWithFormat:@"%@%@.jpg",[TOPDocumentHelper top_getFormatCurrentTime],emailArray[i]];
                [mailCompose addAttachmentData:imgData mimeType:@"image" fileName:photoName];
            }
            [self presentViewController:mailCompose animated:YES completion:^{
                
            }];
        }
        
        if (self.pdfType == 0) {
            for (int i = 0; i<emailArray.count; i++) {
                NSData * pdfData = [NSData dataWithContentsOfURL:emailArray[i]];
                NSString * photoName = [NSString stringWithFormat:@"%@%@",[TOPDocumentHelper top_getFormatCurrentTime],emailArray[i]];
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

- (void)top_handleTap:(UITapGestureRecognizer *)tapGesture {
    [self top_hiddenWatermarkSettingView];
}

#pragma mark -- 底图frame
- (CGRect)top_adaptiveBGImage:(UIImage *)image {
    UIImage *imageTy = image;
    float imgWidth = 0;
    float imgHeight = 0;

    CGFloat fatherWidth = TOPScreenWidth;
    CGFloat fatherHeight = TOPScreenHeight - TOPNavBarAndStatusBarHeight - Bottom_H - TOPBottomSafeHeight;
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
- (TOPWatermarkSettingView *)watermarkSettingView {
    if (!_watermarkSettingView) {
        __weak typeof(self) weakSelf = self;
        CGFloat font = [[NSUserDefaults standardUserDefaults] floatForKey:TOP_TRWatermarkTextFontValueKey];
        CGFloat opacity = [[NSUserDefaults standardUserDefaults] floatForKey:TOP_TRWatermarkTextOpacityKey];
        _watermarkSettingView = [[TOPWatermarkSettingView alloc] initWithFontSie:font opacity:opacity];
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRWatermarkTextColorKey];
        UIColor *textColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        _watermarkSettingView.currentColor = textColor;
        _watermarkSettingView.top_changeSettingBlock = ^(UIColor * _Nonnull textColor, CGFloat fontValue, CGFloat opacity) {
            [weakSelf top_updateWatermarkImageWithTextColor:textColor fontValue:fontValue opacity:opacity];
        };
    }
    return _watermarkSettingView;
}

- (TOPMarkTextInputView *)inputTextView {
    if (!_inputTextView) {
        __weak typeof(self) weakSelf = self;
        CGFloat font = [[NSUserDefaults standardUserDefaults] floatForKey:TOP_TRWatermarkTextFontValueKey];
        CGFloat opacity = [[NSUserDefaults standardUserDefaults] floatForKey:TOP_TRWatermarkTextOpacityKey];
        _inputTextView = [[TOPMarkTextInputView alloc] initWithFontSie:font opacity:opacity];
        _inputTextView.top_callTextCompleteBlock = ^(NSString * _Nonnull text, UIColor * _Nonnull textColor, CGFloat fontValue, CGFloat opacity) {
            [weakSelf top_hiddenInputView];
            [weakSelf top_createWaterMarkImage:text textColor:textColor fontValue:fontValue opacity:opacity];
        };
        _inputTextView.top_clickCancelBlock = ^{
            [weakSelf top_hiddenInputView];
        };
    }
    return _inputTextView;
}

//遮罩层
- (UIView *)maskView {
    if (!_maskView) {
        UIView *mask = [[UIView alloc] init];
        mask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:mask];
        mask.frame = window.bounds;
        _maskView = mask;
    }
    return _maskView;
}
- (UIImageView *)bgSuperView {
    if (!_bgSuperView) {
        UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
        _bgSuperView = [[UIImageView alloc] initWithFrame:[self top_adaptiveBGImage:image]];
        _bgSuperView.image = image;
        _bgSuperView.contentMode = UIViewContentModeScaleAspectFit;
        _bgSuperView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(top_handleTap:)];
        [_bgSuperView addGestureRecognizer:tapRecognizer];
    }
    return _bgSuperView;
}

- (UIView *)contentView {
    if (!_contentView) {
        CGFloat imageH = TOPScreenHeight - TOPNavBarAndStatusBarHeight - Bottom_H - TOPBottomSafeHeight;
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth, imageH)];
        _contentView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_contentView];
    }
    return _contentView;
}

- (UIImageView *)waterMarkImgView {
    if (!_waterMarkImgView) {
        _waterMarkImgView = [[UIImageView alloc] initWithFrame:self.bgSuperView.bounds];
        _waterMarkImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _waterMarkImgView;
}

@end
