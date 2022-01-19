#import "TOPCollageViewController.h"
#import "TOPPhotoLongPressView.h"
#import "StickerView.h"
#import "TOPSettingShowView.h"
#import "TOPCollageModel.h"
#import "TOPCollageHandler.h"
#import "TOPCollageCollectionView.h"
#import "TOPMarkTextInputView.h"
#import "TOPWaterMark.h"
#import "TOPCollageTemplateView.h"
#import "TOPCollageTemplateModel.h"
#import "TOPHomeChildViewController.h"

#import "TOPBatchEditModel.h"
#import "TOPBatchViewController.h"
#import "TOPCropEditModel.h"
#import "TOPTabBarModel.h"

#import "TOPSubscriptionPayListViewController.h"

@interface TOPCollageViewController ()<StickerViewDelegate>
@property (strong, nonatomic) TOPSettingShowView *showView;
@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) TOPPhotoLongPressView *barBootomView;
@property (assign, nonatomic) CGFloat imageScale;
@property (strong, nonatomic) TOPCollageHandler *collageHandler;
@property (strong, nonatomic) TOPCollageCollectionView *collageCollectionView;
@property (strong, nonatomic) TOPMarkTextInputView *inputTextView;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) TOPCollageTemplateView *collageTemplateView;
@property (assign, nonatomic) BOOL showTemplate;
@property (strong, nonatomic) NSMutableArray *sendNameArray;
@property (strong, nonatomic) UILabel *pageLab;
@property (assign, nonatomic) CGFloat paperSizeRate;
@property (assign, nonatomic) CGSize itemSize;
@end
#define Bottom_H 60
#define TemplateView_H 106
@implementation TOPCollageViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.collageTemplate = TOPCollageTemplateTypeVerticalHalf;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.title = NSLocalizedString(@"topscan_collage", @"");
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:ViewBgColor];
    [TOPScanerShare top_writeCollagePageSizeValue:TOPCollagePageSizeTypeA4];
    [[NSUserDefaults standardUserDefaults] setFloat:23 forKey:TOP_TRWatermarkTextFontValueKey];
    [[NSUserDefaults standardUserDefaults] setFloat:0.2 forKey:TOP_TRWatermarkTextOpacityKey];
    [self top_configContentView];
    [self top_initData];
    [self top_clickTemplateMenuItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self top_initNavBar];
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_collageImageFileString]];
    [self top_setRigthButton:@"top_vip_logo" withSelector:@selector(top_collageVC_saveDone)];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (self.enterCameraType > 0) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }else{
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}
#pragma mark -- 导航栏
- (void)top_initNavBar {
    self.navigationController.navigationBar.titleTextAttributes=
    @{NSForegroundColorAttributeName:kWhiteColor,
    NSFontAttributeName:[UIFont systemFontOfSize:18]};
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self top_configWhiteBgDarkTitle];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    [self top_setBackButtonwithSelector:@selector(top_collageVC_goBack)];
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

#pragma mark -- 主视图
- (void)top_configContentView {
    CGFloat rate = 106/75.00;
    CGFloat imageH = (TOPScreenWidth - 20) * rate;
    self.itemSize = CGSizeMake(TOPScreenWidth - 20, imageH);
    [self.view addSubview:self.collageCollectionView];
    [self.collageCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, Bottom_H + TOPBottomSafeHeight, 0));
    }];
    [self top_collageMenuBottomView];
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPBottomSafeHeight - TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
}

- (void)top_initData {
    if ([TOPWHCFileManager top_isExistsAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]]) {
        [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]];
    }
    self.paperSizeRate = (floorf(75/106.00*100))/100;
    self.collageHandler = [[TOPCollageHandler alloc] init];
    self.collageHandler.filePath = self.filePath;
    self.collageHandler.imagePathArr = self.imagePathArr;
    self.collageHandler.templateType = self.collageTemplate;
    [self top_reloadDataRefreshUI];
}

- (void)top_reloadDataRefreshUI {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *data = [self.collageHandler collageViewDatas];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            self.collageCollectionView.dataArray = data;
        });
    });
}

- (NSMutableArray *)sendNameArray {
    if (!_sendNameArray) {
        _sendNameArray = [@[NSLocalizedString(@"topscan_addpage", @""), NSLocalizedString(@"topscan_addwatermark", @""), NSLocalizedString(@"topscan_settingtemplate", @""), @"A4"] mutableCopy];
    }
    return _sendNameArray;
}

#pragma mark -- 菜单栏
- (void)top_collageMenuBottomView {
    NSArray * sendPicArray = @[@"top_collage_blank",@"top_collage_waterMark",@"top_collage_template",@"top_collage_paperSize"];
    NSArray *selectPicArray = @[@"top_collage_blank",@"top_collage_waterMark",@"top_collage_template_selected",@"top_collage_paperSize"];
    TOPPhotoLongPressView *pressBootomView = [[TOPPhotoLongPressView alloc] initWithPressBottomFrame: CGRectMake(0, TOPScreenHeight  -TOPBottomSafeHeight - Bottom_H - TOPNavBarAndStatusBarHeight, TOPScreenWidth, Bottom_H) sendPicArray:sendPicArray sendNameArray:self.sendNameArray];
    pressBootomView.funcArray = [self toolItems];
    pressBootomView.highlightImgs = selectPicArray;
    pressBootomView.highlightItems = @[@(TOPCollageFunctionTypeTemplate)];
    WS(weakSelf);
    pressBootomView.top_longPressBootomItemHandler = ^(NSInteger index) {
        [FIRAnalytics logEventWithName:@"top_longPressBootomItemHandler" parameters:@{@"longPress":@(index)}];
        [weakSelf top_pressBottomViewWithIndex:index];
    };
    [self.view addSubview:pressBootomView];
    self.barBootomView = pressBootomView;
    [self.barBootomView top_setHighlightItem:@(TOPCollageFunctionTypeTemplate)];
    [pressBootomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(Bottom_H);
    }];
}

- (NSArray *)toolItems {
    NSArray *tools = @[@(TOPCollageFunctionTypeAddBlank),
                       @(TOPCollageFunctionTypeWaterMark),
                       @(TOPCollageFunctionTypeTemplate),
                       @(TOPCollageFunctionTypePaperSize)];    
    return tools;
}

#pragma mark -- 菜单执行事件
- (void)top_pressBottomViewWithIndex:(NSInteger)index {
    NSInteger toolType = [[self toolItems][index] integerValue];
    switch (toolType) {
        case TOPCollageFunctionTypeAddBlank:
            [self top_addBlankPage];
            break;
        case TOPCollageFunctionTypeWaterMark:
            [self top_addWaterMark];
            break;
        case TOPCollageFunctionTypeTemplate:
            [self top_clickTemplateMenuItem];
            break;
        case TOPCollageFunctionTypePaperSize:
            [self top_showPaperSize];
            break;
        
        default:
            break;
    }
}

#pragma mark -- 返回
- (void)top_collageVC_goBack {
    [self top_saveImageAlert];
    
}

#pragma mark -- 保存提示
- (void)top_saveImageAlert {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_note", @"")
                                                                   message:NSLocalizedString(@"topscan_savealert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_discard", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        if (self.top_backBtnAction) {
            self.top_backBtnAction();
        }
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

#pragma mark -- 保存后返回
- (void)top_collageVC_CompleteBack {
    if (self.top_finishBtnAction) {
        self.top_finishBtnAction();
    }
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_collageImageFileString]];
    if (self.enterCameraType == TOPShowFolderCameraType||self.enterCameraType == TOPEnterHomeCameraTypeLibrary) {
        [self top_jumpHomeChildVC];
    } else if (self.enterCameraType == TOPShowNextFolderCameraType||self.enterCameraType == TOPEnterNextFolderCameraTypeLibrary) {
        [self top_jumpHomeChildVC];
    } else if(self.enterCameraType == TOPShowIDCardCameraType||self.enterCameraType == TOPShowToTextCameraType){
        [self top_jumpHomeChildVC];
    } else if (self.enterCameraType == TOPShowDocumentCameraType) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)top_jumpHomeChildVC {
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    TOPAppDocument *doc = [TOPEditDBDataHandler top_addDocumentAtFolder:self.filePath WithParentId:self.docModel.docId];
    DocumentModel *model = [TOPDBDataHandler top_buildDocumentModelWithData:doc];
    childVC.docModel = model;
    childVC.pathString = self.filePath;
    childVC.upperPathString = self.filePath;
    childVC.fileNameString = [TOPWHCFileManager top_fileNameAtPath:self.filePath suffix:YES];
    childVC.startPath = self.filePath;
    childVC.addType = @"add";
    childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
    childVC.hidesBottomBarWhenPushed = YES;
    [[TOPDocumentHelper top_getPushVC].navigationController pushViewController:childVC animated:YES];
    [self.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 保存
- (void)top_collageVC_saveDone {
    if ([TOPPermissionManager top_enableByCollageSave]) {
        [self.collageCollectionView top_hiddenCtrlTap];
        [self top_collagedVC_createNewImage];
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

#pragma mark -- 生成新图片，返回上个界面
- (void)top_collagedVC_createNewImage {
    [self.collageHandler top_reloadPicData];
    [[TOPProgressStripeView shareInstance] top_showWithStatus:NSLocalizedString(@"topscan_collageimage", @"")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int progress = 0;
        CGFloat rate = 0;
        for (int i = 0; i < self.collageHandler.dataArray.count; i++) {
            @autoreleasepool {
                TOPCollageModel *model = self.collageHandler.dataArray[i];
                [self.collageHandler top_createCollage:model];
                progress ++;
                rate = (progress * 10.0) / (self.collageHandler.dataArray.count * 10.0);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TOPProgressStripeView shareInstance] top_showProgress:rate withStatus:NSLocalizedString(@"topscan_collageimage", @"")];
                });
            }
        }
        [self.collageHandler top_saveCollageImages];
        [self top_writeDataToDB];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
            [self top_collageVC_CompleteBack];
        });
    });
}

#pragma mark -- 文档数据写入数据库
- (void)top_writeDataToDB {
    if ([self.docModel.type isEqualToString:@"1"]) {
        NSArray *newImages = [TOPDocumentHelper top_sortPicsAtPath:[TOPDocumentHelper top_collageImageFileString]];
        [TOPEditDBDataHandler top_addImageFileAtDocument:newImages WithId:self.docModel.docId];
    }
}

#pragma mark -- 增加空白页
- (void)top_addBlankPage {
    [FIRAnalytics logEventWithName:@"Collage_addBlankPage" parameters:nil];
    TOPCollageModel *model = [self.collageHandler addCollageModel];
    [self.collageHandler.dataArray addObject:model];
    self.collageCollectionView.dataArray = self.collageHandler.dataArray;
    [self.collageCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.collageCollectionView.dataArray.count -1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    [self.collageCollectionView top_hiddenCtrlTap];
}

#pragma mark -- 点击模板选项
- (void)top_clickTemplateMenuItem {
    [FIRAnalytics logEventWithName:@"Collage_TemplateMenuItem" parameters:nil];
    if (self.showTemplate) {
        [self top_hiddenTemplateList];
    } else {
        if (!self.collageHandler.templateArray.count) {
            [self.view addSubview:self.collageTemplateView];
            self.collageTemplateView.templateItems = [self.collageHandler collageTemplateDatas];
            [self.collageTemplateView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.top.equalTo(self.view.mas_bottom);
                make.height.mas_equalTo(TemplateView_H);
            }];
        }
        [self top_shwoTemplateList];
    }
}

#pragma mark -- 弹出模板列表
- (void)top_shwoTemplateList {
    self.showTemplate = YES;
    [UIView animateWithDuration:0.3
                     animations:^{
        [self.collageTemplateView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(Bottom_H + TOPBottomSafeHeight));
            make.height.mas_equalTo(TemplateView_H);
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark -- 收起模板列表
- (void)top_hiddenTemplateList {
    self.showTemplate = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
        [self.collageTemplateView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view.mas_bottom);
            make.height.mas_equalTo(TemplateView_H);
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark -- 根据模板刷新界面
- (void)top_refreshUIWithTemplate:(NSInteger)item {
    TOPCollageTemplateModel *model = self.collageHandler.templateArray[item];
    self.collageHandler.templateType = model.templateType;
    [self.collageCollectionView top_hiddenCtrlTap];
    [self top_reloadDataRefreshUI];
}

#pragma mark -- 添加/删除水印
- (void)top_addWaterMark {
    [FIRAnalytics logEventWithName:@"Collage_addWaterMark" parameters:nil];
    if (![TOPWHCFileManager top_isExistsAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]]) {
        [self top_showInputView];
    } else {
        [self top_removeWaterMark];
    }
}

- (void)top_removeWaterMark {
    self.collageCollectionView.showWaterMark = NO;
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]];
    self.sendNameArray[1] = NSLocalizedString(@"topscan_addwatermark", @"");
    self.barBootomView.funcTitles = self.sendNameArray;
}

#pragma mark -- 设置水印文字
- (NSString *)markText {
    NSString *markText = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRWatermarkTextkey];
    if (!markText) {
        markText = @"";
    }
    return markText;
}

- (void)top_setMarkTextColor:(UIColor *)textColor {
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:textColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:TOP_TRWatermarkTextColorKey];
}

#pragma mark -- 弹出输入框、键盘
- (void)top_showInputView {
    self.inputTextView.textFld.text = [self markText];
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRWatermarkTextColorKey];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    self.inputTextView.currentColor = color;
    [self.maskView addSubview:self.inputTextView];
    [UIView animateWithDuration:0.3
                     animations:^{
        self.maskView.alpha = 1.0;
        [self.inputTextView top_beginEditing];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -- 输入控件消失
- (void)top_hiddenInputView {
    [UIView animateWithDuration:0.3
                     animations:^{
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.inputTextView removeFromSuperview];
        self.inputTextView = nil;
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }];
}

- (void)top_createWaterMarkImage:(NSString *)text textColor:(UIColor *)textColor fontValue:(CGFloat)fontValue opacity:(CGFloat)opacity {
    if (!text.length) {
        return;
    }
    [self top_setMarkTextColor:textColor];
    [[NSUserDefaults standardUserDefaults] setObject:text forKey:TOP_TRWatermarkTextkey];
    [[NSUserDefaults standardUserDefaults] setFloat:fontValue forKey:TOP_TRWatermarkTextFontValueKey];
    [[NSUserDefaults standardUserDefaults] setFloat:opacity forKey:TOP_TRWatermarkTextOpacityKey];
    CGFloat scale = [UIScreen mainScreen].scale;
    UIImageView *waterMarkView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth*scale, (TOPScreenHeight - TOPNavBarAndStatusBarHeight - Bottom_H)*scale)];
    [TOPWaterMark view:waterMarkView WaterImageWithImage:[UIImage imageNamed:@""] text:text];
    self.collageCollectionView.showWaterMark = YES;
    self.sendNameArray[1] = NSLocalizedString(@"topscan_removewatermark", @"");
    self.barBootomView.funcTitles = self.sendNameArray;
}

- (NSArray *)paperSizeTitles {
    NSArray *titles = @[@"A3", @"A4", @"A5", @"B4", @"B5"];
    return titles;
}

- (NSArray *)sizeTypeArray {
    NSArray *arr = @[@(TOPCollagePageSizeTypeA3), @(TOPCollagePageSizeTypeA4), @(TOPCollagePageSizeTypeA5), @(TOPCollagePageSizeTypeB4), @(TOPCollagePageSizeTypeB5)];
    return arr;
}

#pragma mark -- 选择纸张大小弹窗
- (void)top_showPaperSize {
    [FIRAnalytics logEventWithName:@"Collage_showPaperSize" parameters:nil];
    NSArray *pageSizeArray = @[NSLocalizedString(@"topscan_a3", @""),
                               NSLocalizedString(@"topscan_a4", @""),
                               NSLocalizedString(@"topscan_a5", @""),
                               NSLocalizedString(@"topscan_b4", @""),
                               NSLocalizedString(@"topscan_b5", @"")];
    CGFloat viewHeight = 45*(pageSizeArray.count+2);
    self.showView.frame = CGRectMake(20, (TOPScreenHeight-viewHeight)/2, TOPScreenWidth-40, viewHeight);
    self.showView.showType = TOPCollagePageSize;
    self.showView.dataArray = pageSizeArray;
    self.showView.pdfSizeArray = [self sizeTypeArray];
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.backView];
    [keyWindow addSubview:self.showView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(keyWindow);
    }];
    
    [self.showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(keyWindow);
        make.leading.equalTo(keyWindow).offset(20);
        make.trailing.equalTo(keyWindow).offset(-20);
        make.height.mas_equalTo(viewHeight);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0.5;
        self.showView.alpha = 1;
    }];
}

#pragma mark -- 选择纸张大小
- (void)top_collageVC_selectedPaperSize:(NSInteger)row  {
    [self top_backView_ClickTap];
    if (row > 0 && (row - 1) < [[self paperSizeTitles] count]) {
        self.sendNameArray[3] = [self paperSizeTitles][row - 1];
        self.barBootomView.funcTitles =  self.sendNameArray;
        TOPCollagePageSizeType sizeType = [[self sizeTypeArray][row - 1] integerValue];
        self.collageHandler.paperType = sizeType;
        CGFloat rate = 1;
        BOOL isSpecial = NO;
        if (self.collageHandler.templateType == TOPCollageTemplateTypeDriverLicense || self.collageHandler.templateType == TOPCollageTemplateTypeIDCard ||
            self.collageHandler.templateType == TOPCollageTemplateTypePassport ||
            self.collageHandler.templateType == TOPCollageTemplateTypeAccountBook) {
            isSpecial = YES;
        }
        if (sizeType == TOPCollagePageSizeTypeA3 || sizeType == TOPCollagePageSizeTypeA4 || sizeType == TOPCollagePageSizeTypeA5 || sizeType == TOPCollagePageSizeTypeB4 || sizeType == TOPCollagePageSizeTypeB5) {
            rate = (floorf(75/106.00*100))/100;
        } else {
            rate = 0.5;
        }
        if (self.paperSizeRate != rate || isSpecial) {
            self.paperSizeRate = rate;
            [self.collageCollectionView top_hiddenCtrlTap];
            [self top_reloadDataRefreshUI];
        }
    }
}

#pragma mark -- 蒙版点击消失
- (void)top_backView_ClickTap {
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0;
        self.showView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backView removeFromSuperview];
        [self.showView removeFromSuperview];
        self.backView = nil;
        self.showView = nil;
    }];
}

#pragma mark -- lazy

#pragma mark -- 纸张大小
- (TOPSettingShowView *)showView{
    if (!_showView) {
        WS(weakSelf);
        _showView = [TOPSettingShowView new];
        _showView.layer.masksToBounds = YES;
        _showView.layer.cornerRadius = 5;
        _showView.alpha = 0;
        _showView.top_clickDismiss = ^(NSInteger row ,NSString * type) {
            [weakSelf top_collageVC_selectedPaperSize:row];
        };
    }
    return _showView;
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_backView_ClickTap)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

- (TOPCollageCollectionView *)collageCollectionView {
    __weak typeof(self) weakSelf = self;
    if (!_collageCollectionView) {
        CGRect frame = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight - Bottom_H - TOPBottomSafeHeight);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = self.itemSize;
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collageCollectionView = [[TOPCollageCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _collageCollectionView.top_didScrollBlock = ^(NSInteger page) {
            if (weakSelf.collageHandler.dataArray.count > 1) {
                weakSelf.pageLab.text = [NSString stringWithFormat:@"%@/%@",@(page),@(weakSelf.collageHandler.dataArray.count)];
            }
        };
        _collageCollectionView.top_changeEditingPicBlock = ^(NSInteger tag) {
            weakSelf.collageHandler.editingImageIndex = tag;
        };
    }
    return _collageCollectionView;
}

     - (UIView *)maskView {
    if (!_maskView) {
        UIView *mask = [[UIView alloc] init];
        mask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        mask.alpha = 0;
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:mask];
        mask.frame = window.bounds;
        _maskView = mask;
        [mask mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(window);
        }];
    }
    return _maskView;
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

- (TOPCollageTemplateView *)collageTemplateView {
    __weak typeof(self) weakSelf = self;
    if (!_collageTemplateView) {
        _collageTemplateView = [[TOPCollageTemplateView alloc] initWithFrame:CGRectMake(0, TOPScreenHeight, TOPScreenWidth, TemplateView_H)];
        _collageTemplateView.top_selectedHeadMenuBlock = ^(NSInteger item) {
            [weakSelf top_refreshUIWithTemplate:item];
        };
    }
    return _collageTemplateView;
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

@end
