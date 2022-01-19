#define Bottom_H 60
#define Middle_H 60
#import "TOPPhotoShowTextTranslationVC.h"
#import "TOPSettingDocumentFormatterView.h"
#import "TOPTranslationView.h"
#import "TOPPhotoLongPressView.h"
#import "TOPTextView.h"
#import <MLKitTranslate/MLKTranslateLanguage.h>
#import <MLKitTranslate/MLKTranslator.h>
#import <MLKitTranslate/MLKTranslatorOptions.h>
#import <MLKitLanguageID/MLKitLanguageID.h>
#import <MLKitCommon/MLKitCommon.h>
#import <MLKitTranslate/MLKitTranslate.h>
#import "TOPTranslateModelsViewController.h"

@interface TOPPhotoShowTextTranslationVC ()<UITextViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic ,strong) TOPSettingDocumentFormatterView * exportView;
@property (nonatomic ,strong) TOPTranslationView * translationView;
@property (nonatomic ,strong) TOPTextView * ocrTextView;
@property (nonatomic ,strong) UIButton * returnBtn;
@property (nonatomic ,assign) CGPoint containerOrigin;
@property (nonatomic ,strong) UIView * backView;
@property (nonatomic ,strong) MLKTranslator *translator;
@property (nonatomic ,copy) NSArray<MLKTranslateLanguage> *allLanguages;
@property (nonatomic ,copy) MLKTranslateLanguage sourceLanguage;
@property (nonatomic ,copy) MLKTranslateLanguage targetLanguage;
@property (nonatomic ,strong) NSProgress *progress;
@property (nonatomic ,assign) TOPFormatterViewEnterType formatterType;

@end

@implementation TOPPhotoShowTextTranslationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"TranslationVC_enterTranslationView" parameters:nil];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    [self top_initNavBar];
    [self.view addSubview:self.ocrTextView];
    [self.view addSubview:self.translationView];
    [self top_addUIPanGestureRecognizer];
    [self top_creatBottomView];
    [self top_loadData];
    [self top_languageIdentify];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController interactivePopGestureRecognizer]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)top_initNavBar {
    if (isRTL()) {//黑色
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    [self top_setRightButtons:@[@"top_translate_share",@"top_translate_clear"]];
}

- (void)top_setRightButtons:(NSArray *)imgNames {
    if (imgNames.count) {
        NSString *imgName = imgNames[0];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(top_rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        NSString *imgName2 = imgNames[1];
        UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [btn2 setImage:[UIImage imageNamed:imgName2] forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(top_clearOriginalContent) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barItem2 = [[UIBarButtonItem alloc] initWithCustomView:btn2];
        
        self.navigationItem.rightBarButtonItems = @[barItem,barItem2];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)top_clearOriginalContent {
    [self.ocrTextView becomeFirstResponder];
    self.ocrTextView.text = @"";
}

- (void)top_languageIdentify {
    __weak typeof(self) weakSelf = self;
    MLKLanguageIdentification *languageId = [MLKLanguageIdentification languageIdentification];
    NSString *text = self.ocrTextView.text;
    if (text == nil) {
        text = @"";
    }
    [languageId identifyLanguageForText:text
                             completion:^(NSString * _Nullable languageCode,
                                          NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Failed with error: %@", error.localizedDescription);
            return;
        }
        if ([languageCode isEqualToString:@"und"] ) {
            languageCode = MLKTranslateLanguageEnglish;
        }
        weakSelf.sourceLanguage = languageCode;
        [TOPScanerShare top_writeSourceLanguageSave:languageCode];
        
        [weakSelf top_getLocale];
        [weakSelf top_createTranslator];
        [weakSelf top_setoutLanguageModel];
    }];
}

- (void)top_getLocale {
    NSString *targetLan = [TOPScanerShare top_targetLanguage];
    if (!targetLan.length) {//英语为默认目标语言
        targetLan = MLKTranslateLanguageEnglish;
        [TOPScanerShare top_writeTargetLanguageSave:targetLan];
    }
    if ([self.sourceLanguage isEqualToString:targetLan]) {
        if ([self.sourceLanguage isEqualToString:MLKTranslateLanguageEnglish]) {
            targetLan = MLKTranslateLanguageChinese;
        } else {
            targetLan = MLKTranslateLanguageEnglish;
        }
        [TOPScanerShare top_writeTargetLanguageSave:targetLan];
    }
    self.allLanguages = [MLKTranslateAllLanguages().allObjects mutableCopy];
    self.targetLanguage = targetLan;
    [self top_buildCodeLanguageMap];
    self.translationView.sourceTitle = [NSLocale.currentLocale localizedStringForLanguageCode:self.sourceLanguage];
    self.translationView.targetTitle = [NSLocale.currentLocale localizedStringForLanguageCode:self.targetLanguage];
}

#pragma mark -- 创建翻译器
- (void)top_createTranslator {
    MLKTranslatorOptions *options = [[MLKTranslatorOptions alloc] initWithSourceLanguage:self.sourceLanguage targetLanguage:self.targetLanguage];
    self.translator = [MLKTranslator translatorWithOptions:options];
}

#pragma mark -- 开始翻译
- (void)top_startTranslate {
    [FIRAnalytics logEventWithName:@"TranslationVC_startTranslate" parameters:nil];
    NSString *text = self.ocrTextView.text;
    if (text == nil) {
        text = @"";
    }
    __weak typeof(self) weakSelf = self;
    [self.translator translateText:text completion:^(NSString * _Nullable result, NSError * _Nullable error) {
        if (result == nil || error != nil) {
            return;
        }
        weakSelf.translationView.translationString = result;
    }];
}

#pragma mark -- 确认语言模型
- (void)top_setoutLanguageModel {
    BOOL hasSourceLanguageModel = [self top_isLanguageDownloaded:self.sourceLanguage];
    BOOL hasTargetLanguageModel = [self top_isLanguageDownloaded:self.targetLanguage];
    if (hasSourceLanguageModel && hasTargetLanguageModel) {
        [self top_startTranslate];
    } else {
        __weak typeof(self) weakSelf = self;
        MLKModelDownloadConditions *conditions = [[MLKModelDownloadConditions alloc] initWithAllowsCellularAccess:NO allowsBackgroundDownloading:YES];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_downloadlanguage", @"")];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [self.translator downloadModelIfNeededWithConditions:conditions completion:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            if (error != nil) {
                return;
            }
            [weakSelf top_startTranslate];
        }];
    }
}

- (BOOL)top_isLanguageDownloaded:(MLKTranslateLanguage)language {
  MLKTranslateRemoteModel *model = [self modelForLanguage:language];
  MLKModelManager *modelManager = [MLKModelManager modelManager];
  return [modelManager isModelDownloaded:model];
}

- (MLKTranslateRemoteModel *)modelForLanguage:(MLKTranslateLanguage)language {
  return [MLKTranslateRemoteModel translateRemoteModelWithLanguage:language];
}

- (void)top_creatBottomView{
    __weak typeof(self) weakSelf = self;
    NSArray * sendPicArray = @[@"top_downview_share",@"top_ocr_textcopy"];
    NSArray * sendNameArray = @[NSLocalizedString(@"topscan_share", @""),NSLocalizedString(@"topscan_ocrtextcopy", @"")];
    TOPPhotoLongPressView *tabbarBottomView = [[TOPPhotoLongPressView alloc] initWithPressBottomFrame: CGRectMake(0, TOPScreenHeight -TOPNavBarAndStatusBarHeight -TOPBottomSafeHeight - (Bottom_H), TOPScreenWidth, (Bottom_H)) sendPicArray:sendPicArray sendNameArray:sendNameArray];
    tabbarBottomView.top_longPressBootomItemHandler = ^(NSInteger index) {
        [weakSelf top_botomViewFunction:index];
    };
    [self.view addSubview:tabbarBottomView];
    [tabbarBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(Bottom_H);
    }];
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight -TOPNavBarAndStatusBarHeight -TOPBottomSafeHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
}

#pragma mark -- 底部视图的功能
- (void)top_botomViewFunction:(NSInteger)index{
    NSNumber * num = [self top_bottomFunctionArray][index];
    switch ([num integerValue]) {
        case TOPPhotoShowViewImageTopViewActionShareText:
            [self top_shareAction];
            break;
        case TOPPhotoShowViewImageBottomViewActionCopy:
            [self top_bottomCopyFunction];
            break;
        default:
            break;
    }
}

#pragma mark -- 拷贝
- (void)top_bottomCopyFunction{
    [FIRAnalytics logEventWithName:@"TranslationVC_bottomCopyFunction" parameters:nil];
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.translationView.translationString;
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 260)];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_ocrexportcopy", @"")];
    [SVProgressHUD dismissWithDelay:1.5];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 0)];
    });
}

- (void)top_loadData{
    if (self.dataArray.count>0) {
        DocumentModel * model = self.dataArray[0];        
        NSMutableParagraphStyle *muParagraph = [[NSMutableParagraphStyle alloc]init];
        muParagraph.lineSpacing = 2;
        NSString * textString = [NSString new];
        if ([TOPWHCFileManager top_isExistsAtPath:model.ocrPath]) {
            textString = [TOPDocumentHelper top_getTxtContent:model.ocrPath];
        }else{
            textString = @"";
        }
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[textString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType } documentAttributes:nil error:nil];
        NSRange range = NSMakeRange(0, attrStr.length);
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] range:range];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
        [attrStr addAttribute:NSParagraphStyleAttributeName value:muParagraph range:range];
        [attrStr addAttribute:NSBaselineOffsetAttributeName value:@(-2) range:range];
        self.ocrTextView.attributedText = attrStr;
        self.translationView.translationString = textString;
    }
}

- (void)top_addUIPanGestureRecognizer{
    UIPanGestureRecognizer * ges = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(top_panGestureRecognized:)];
    ges.delegate = self;
    [self.translationView addGestureRecognizer:ges];
}

- (void)top_panGestureRecognized:(UIPanGestureRecognizer *)recognizer{
    CGPoint point = [recognizer translationInView:self.translationView];
    CGFloat headMenuViewH = (TOPScreenHeight -TOPNavBarAndStatusBarHeight -TOPBottomSafeHeight -Bottom_H)/3 * 2 - Middle_H;
    CGFloat topViewH = self.ocrTextView.frame.origin.y;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.containerOrigin = recognizer.view.frame.origin;
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGRect frame = recognizer.view.frame;
        frame.origin.y = self.containerOrigin.y + point.y;
        if (frame.origin.y > headMenuViewH) {
            frame.origin.y = headMenuViewH;
        }
        if (frame.origin.y < topViewH) {
            frame.origin.y = topViewH;
        }
        recognizer.view.frame = CGRectMake(0, frame.origin.y, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-Bottom_H-frame.origin.y);
    }
}

#pragma mark -- 选择语言
- (void)top_selectLanguage:(BOOL)source {
    if ([TOPDocumentHelper top_isdark]) {
        [UIApplication sharedApplication].windows[0].backgroundColor = TOPAppDarkBackgroundColor;
    }else{
        [UIApplication sharedApplication].windows[0].backgroundColor = [UIColor whiteColor];
    }
    __weak typeof(self) weakSelf = self;
    TOPTranslateModelsViewController *translateModelsVC = [[TOPTranslateModelsViewController alloc] init];
    if (source) {
        translateModelsVC.sourceLanguage = self.sourceLanguage;
        translateModelsVC.top_selectedLanguageBlock = ^(NSString * _Nonnull languageCode) {
            [weakSelf top_resetSourceLanguage:languageCode];
            [weakSelf top_createTranslator];
        };
    } else {
        translateModelsVC.targetLanguage = self.targetLanguage;
        translateModelsVC.top_selectedLanguageBlock = ^(NSString * _Nonnull languageCode) {
            [weakSelf top_resetTragetLanguage:languageCode];
            [weakSelf top_createTranslator];
        };
    }
    [self presentViewController:translateModelsVC animated:YES completion:nil];
}

- (void)top_resetSourceLanguage:(NSString *)languageCode {
    if ([self.targetLanguage isEqualToString:languageCode]) {
        self.targetLanguage = self.sourceLanguage;
        [TOPScanerShare top_writeTargetLanguageSave:self.targetLanguage];
        self.translationView.targetTitle = [NSLocale.currentLocale localizedStringForLanguageCode:self.targetLanguage];
    }
    self.sourceLanguage = languageCode;
    [TOPScanerShare top_writeSourceLanguageSave:self.sourceLanguage];
    self.translationView.sourceTitle = [NSLocale.currentLocale localizedStringForLanguageCode:self.sourceLanguage];
    
    NSMutableArray *temps = [[TOPScanerShare top_recentLanguageModels] mutableCopy];
    NSInteger isRencent = [self top_containsRencentLanguage:languageCode];
    if (isRencent == -1) {
        [temps removeObjectAtIndex:0];
        [temps insertObject:languageCode atIndex:0];
    } else {
        if (isRencent != 0) {
            [temps exchangeObjectAtIndex:isRencent withObjectAtIndex:0];
        }
    }
    [TOPScanerShare top_writeLanguageModelsSave:temps];
}

- (void)top_resetTragetLanguage:(NSString *)languageCode {
    if ([self.sourceLanguage isEqualToString:languageCode]) {
        self.sourceLanguage = self.targetLanguage;
        [TOPScanerShare top_writeSourceLanguageSave:self.sourceLanguage];
        self.translationView.sourceTitle = [NSLocale.currentLocale localizedStringForLanguageCode:self.sourceLanguage];
    }
    self.targetLanguage = languageCode;
    [TOPScanerShare top_writeTargetLanguageSave:self.targetLanguage];
    self.translationView.targetTitle = [NSLocale.currentLocale localizedStringForLanguageCode:self.targetLanguage];
    
    NSInteger isRencent = [self top_containsRencentLanguage:languageCode];
    NSMutableArray *temps = [[TOPScanerShare top_recentLanguageModels] mutableCopy];
    if (isRencent == -1) {
        [temps removeLastObject];
        [temps insertObject:languageCode atIndex:1];
    } else {
        if (isRencent != 1) {
            [temps exchangeObjectAtIndex:isRencent withObjectAtIndex:1];
        }
    }
    [TOPScanerShare top_writeLanguageModelsSave:temps];
}

- (NSInteger)top_containsRencentLanguage:(NSString *)languageCode {
    NSArray *recentArr = [TOPScanerShare top_recentLanguageModels];
    for (int i = 0; i < recentArr.count; i ++) {
        NSString *temp = recentArr[i];
        if ([temp isEqualToString:languageCode]) {//在最近的语言范围内
            return i;
        }
    }
    return -1;
}

#pragma mark -- UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0 && [textView isFirstResponder]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self top_setoutLanguageModel];
        });
    }
}

#pragma mark -- 键盘监听
- (void)keyboardwill:(NSNotification *)notification{
    NSDictionary * info = [notification userInfo];
    NSLog(@"%@", info);
    CGRect rect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyOriginY = rect.origin.y;
    
    if (!self.returnBtn) {
        UIButton * returnBtn = [[UIButton alloc] init];
        returnBtn.backgroundColor = RGBA(212, 216, 222, 1.0);
        [returnBtn setImage:[UIImage imageNamed:@"top_downKeyboard"] forState:UIControlStateNormal];
        [returnBtn addTarget:self action:@selector(top_clickReturnToHide) forControlEvents:UIControlEventTouchUpInside];
        returnBtn.layer.masksToBounds = YES;
        returnBtn.layer.cornerRadius = 3;
        self.returnBtn = returnBtn;
        [self.view addSubview:self.returnBtn];
    }
    
    if (keyOriginY == TOPScreenHeight) {
        self.returnBtn.hidden = YES;
    }else{
        self.returnBtn.frame = CGRectMake(TOPScreenWidth-55, keyOriginY-TOPNavBarAndStatusBarHeight-48, 53, 47);
        self.returnBtn.hidden = NO;
        
        CGFloat content_H = (keyOriginY - TOPNavBarAndStatusBarHeight - 10  - 70) / 2;
        [UIView animateWithDuration:0.3 animations:^{
            self.translationView.frame = CGRectMake(0, keyOriginY - content_H - 70 - TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-Bottom_H);
        }];

    }
}

- (void)keybaordhide:(NSNotification *)info{
    [UIView animateWithDuration:0.2 animations:^{
        self.returnBtn.hidden = YES;
    }];
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _backView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTap)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

- (TOPTextView *)ocrTextView{
    if (!_ocrTextView) {
        _ocrTextView = [[TOPTextView alloc]initWithFrame:CGRectMake(0, 10, TOPScreenWidth, (TOPScreenHeight -TOPNavBarAndStatusBarHeight -TOPBottomSafeHeight -Bottom_H)/3 * 2 -Middle_H-10)];
        _ocrTextView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        _ocrTextView.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _ocrTextView.font = [UIFont systemFontOfSize:16];
        _ocrTextView.textAlignment = NSTextAlignmentNatural;
        _ocrTextView.editable = YES;
        _ocrTextView.scrollEnabled = YES;
        _ocrTextView.delegate = self;
        _ocrTextView.returnKeyType = UIReturnKeyDefault;
        _ocrTextView.keyboardType = UIKeyboardTypeDefault;
        _ocrTextView.inputAccessoryView = [UIView new];
    }
    return _ocrTextView;
}

- (TOPTranslationView *)translationView {
    if (!_translationView) {
        _translationView = [[TOPTranslationView alloc]initWithFrame:CGRectMake(0, (TOPScreenHeight -TOPNavBarAndStatusBarHeight -TOPBottomSafeHeight -Bottom_H)/2-Middle_H, TOPScreenWidth, (TOPScreenHeight -TOPNavBarAndStatusBarHeight -TOPBottomSafeHeight -Bottom_H)/2+Middle_H)];
        __weak typeof(self) weakSelf = self;
        _translationView.top_beginTranslateBlock = ^{
            [weakSelf top_setoutLanguageModel];
        };
        _translationView.top_showSourceLanguageBlock = ^{
            [weakSelf top_selectLanguage:YES];
        };
        _translationView.top_showTargetLanguageBlock = ^{
            [weakSelf top_selectLanguage:NO];
        };
    }
    return _translationView;
}

- (TOPSettingDocumentFormatterView *)exportView{
    WS(weakSelf);
    if (!_exportView) {
        _exportView = [[TOPSettingDocumentFormatterView alloc]initWithFrame:CGRectMake(20, (TOPScreenHeight-200)/2, TOPScreenWidth-40, 200)];
        _exportView.layer.masksToBounds = YES;
        _exportView.layer.cornerRadius = 5;
        _exportView.dataArray = weakSelf.dataArray;
        _exportView.enterType = self.formatterType;
        _exportView.top_clickToDismiss = ^{
            [weakSelf top_clickTap];
        };
        
        _exportView.top_clickCellSendExportType = ^(BOOL allBtnSelect, NSInteger row) {
            [weakSelf top_clickTap];
            [weakSelf top_getSelectExportType:allBtnSelect index:row];
        };
    }
    return _exportView;
}

- (NSArray *)top_exportArray{
    NSArray * tempArray = @[@(TOPExportTypeTxt),@(TOPExportTypeText),@(TOPExportTypeCopyToClipboard)];
    return tempArray;
}

- (NSArray *)top_bottomFunctionArray{
    NSArray * tempArray = @[@(TOPPhotoShowViewImageTopViewActionShareText),@(TOPPhotoShowViewImageBottomViewActionCopy)];
    return tempArray;
}
#pragma mark -- 键盘return
- (void)top_clickReturnToHide{
    [self.ocrTextView resignFirstResponder];
}

#pragma mark -- Export
- (void)top_rightBtnAction{
    [FIRAnalytics logEventWithName:@"TranslationVC_export" parameters:nil];
    [self.ocrTextView resignFirstResponder];
    self.formatterType = TOPFormatterViewEnterTypeTextAgainExport;
    [self top_showExportView];
}

- (void)top_shareAction {
    [FIRAnalytics logEventWithName:@"TranslationVC_share" parameters:nil];
    [self.ocrTextView resignFirstResponder];
    self.formatterType = TOPFormatterViewEnterTypeTextAgainShare;
    [self top_showExportView];
    
}

- (void)top_backHomeAction{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark --覆盖层手势
- (void)top_clickTap{
    [UIView animateWithDuration:0.3 animations:^{
        [self.backView removeFromSuperview];
        [self.exportView removeFromSuperview];
        self.backView = nil;
        self.exportView = nil;
    }];
}
- (void)top_showExportView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.backView];
    [keyWindow addSubview:self.exportView];
    if (IS_IPAD) {
        [self.exportView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view);
            make.height.mas_equalTo(200);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.exportView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(20);
            make.trailing.equalTo(self.view).offset(-20);
            make.centerY.equalTo(self.view);
            make.height.mas_equalTo(200);
        }];
    }
}

#pragma mark -- ExportViewAction
- (void)top_getSelectExportType:(BOOL)allPageSelect index:(NSInteger)row{
    NSNumber * num = [self top_exportArray][row];
    switch ([num integerValue]) {
        case TOPExportTypeTxt:
            [self top_exportTxtAction];
            break;
        case TOPExportTypeText:
            [self top_exportTextAction];
            break;
        case TOPExportTypeCopyToClipboard:
            [self top_exportTxtActionClipboard];
            break;
        default:
            break;
    }
}

- (void)top_exportTxtAction{
    [FIRAnalytics logEventWithName:@"TranslationVC_exportTxtAction" parameters:nil];
    NSString * homePath = [TOPDocumentHelper top_getTxtPathString];
    if (self.dataArray.count>0) {
        DocumentModel * model = self.dataArray[0];
        NSString * nameSuffix = [NSString new];
        if (!model.name) {
            nameSuffix = [NSString stringWithFormat:@"0%@",@(1)];
        }else{
            nameSuffix = model.name;
        }
        NSString * filePath = [homePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.txt",model.fileName,nameSuffix]];
        [self.translationView.translationString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSURL * shareURL = [NSURL fileURLWithPath:filePath];
        
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
    
}

- (void)top_exportTextAction{
    [FIRAnalytics logEventWithName:@"TranslationVC_exportTextAction" parameters:nil];
    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:@[self.translationView.translationString] applicationActivities:nil];
    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    activiVC.excludedActivityTypes = excludedActivityTypes;
    if (IS_IPAD) {
        activiVC.popoverPresentationController.sourceView = self.view;
        activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController: activiVC animated:YES completion:nil];
}

- (void)top_exportTxtActionClipboard{
    [FIRAnalytics logEventWithName:@"TranslationVC_exportTxtActionClipboard" parameters:nil];
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.translationView.translationString;
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_ocrexportcopy", @"")];
    [SVProgressHUD dismissWithDelay:1.5];
}

#pragma mark -- BCP-47 Code 映射表
- (void)top_buildCodeLanguageMap {
    NSDictionary *map = [TOPScanerShare top_codeLanguageMap];
    if (!map) {
        NSMutableDictionary *codeDic = @{}.mutableCopy;
        NSArray *models = MLKTranslateAllLanguages().allObjects;
        for (MLKTranslateLanguage model in models) {
            NSString *languageName = [NSLocale.currentLocale localizedStringForLanguageCode:model];
            [codeDic setValue:languageName forKey:model];
        }
        [TOPScanerShare top_writeCodeLanguageMapSave:codeDic];
    }
}

@end
