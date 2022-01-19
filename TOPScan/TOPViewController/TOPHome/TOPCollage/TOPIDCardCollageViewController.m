#import "TOPIDCardCollageViewController.h"
#import "TOPPhotoLongPressView.h"
#import "StickerView.h"
#import "TOPCollageModel.h"
#import "TOPCollageHandler.h"
#import "TOPCollageCollectionView.h"
#import "TOPMarkTextInputView.h"
#import "TOPWaterMark.h"
#import "TOPCollageTemplateView.h"
#import "TOPCollageTemplateModel.h"
#import "TOPHomeChildViewController.h"
#import "TOPScameraBatchBottomView.h"
#import "TOPReEditCollectionViewCell.h"
#import "TOPCameraFilterView.h"
#import "TOPBatchViewController.h"
#import "TOPDataTool.h"
#import "TOPCropEditModel.h"
#import "TOPCameraBatchModel.h"
@interface TOPIDCardCollageViewController ()<StickerViewDelegate,UIGestureRecognizerDelegate>
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

@property (nonatomic, strong) TOPScameraBatchBottomView *bottomView;
@property (nonatomic ,strong) TOPCameraFilterView * filterView;
@property (nonatomic ,strong) UIView * coverView;
@property (assign, nonatomic) TOPCollageTemplateType collageTemplate;
@property (nonatomic, assign) NSInteger bottomFuncIndex;
@property (nonatomic, assign) BOOL isFilterShow;
@property (nonatomic ,assign) NSInteger lastProcessType;
@property (strong, nonatomic) NSMutableArray * batchArray;
@property (nonatomic ,assign) NSInteger selectPicTag;
@property (nonatomic ,assign) NSInteger currentIndex;
@end

#define PageViewH   25
#define FilterShow_H 130
#define Bottom_H 60
@implementation TOPIDCardCollageViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.collageTemplate = TOPCollageTemplateTypeIDCard;
        self.lastProcessType = [TOPScanerShare top_defaultProcessType];
        self.selectPicTag = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.title = NSLocalizedString(@"topscan_collageidcard", @"");
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:ViewBgColor];
    [TOPScanerShare top_writeCollagePageSizeValue:TOPCollagePageSizeTypeA4];
    [[NSUserDefaults standardUserDefaults] setFloat:23 forKey:TOP_TRWatermarkTextFontValueKey];
    [[NSUserDefaults standardUserDefaults] setFloat:0.2 forKey:TOP_TRWatermarkTextOpacityKey];
    [self top_configContentView];
    [self top_initData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self top_initNavBar];
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_collageImageFileString]];
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
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
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
    if (!_bottomView) {
        WS(weakSelf);
        NSArray * picArray = @[@"top_collage_waterMark",@"top_scamerbatch_crop",@"top_scamerbatch_filter",@"top_scamerbatch_reEditAffirm"];
        NSArray * reEditArray = @[@"top_collage_waterMark",@"top_scamerbatch_crop",@"top_scamerbatch_filter",@"top_scamerbatch_reEditAffirm"];
        NSArray * titles = @[NSLocalizedString(@"topscan_idcardanti", @""),NSLocalizedString(@"topscan_ocrtexttdit", @""),NSLocalizedString(@"topscan_filter", @"")];
        TOPScameraBatchBottomView * bottomView = [[TOPScameraBatchBottomView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight - TOPTabBarHeight-TOPNavBarAndStatusBarHeight, TOPScreenWidth, 49) sendPic:picArray itemNames:titles];
        bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        bottomView.normalArray = picArray;
        bottomView.reEditArray = reEditArray;
        bottomView.selectFilterItem = @"top_scamerbatch_filterSelect";
        bottomView.top_longPressBootomItemHandler = ^(NSInteger index) {
            [weakSelf top_bottomViewFunctionTip:index];
        };
        self.bottomView = bottomView;
        [self.view addSubview:self.bottomView];
    }
}

- (NSArray *)toolItems {
    NSArray *tools = @[@(TOPCollageFunctionTypeAddBlank),
                       @(TOPCollageFunctionTypeWaterMark),
                       @(TOPCollageFunctionTypeTemplate),
                       @(TOPCollageFunctionTypePaperSize)];
    return tools;
}

#pragma mark -- 底部菜单执行事件
- (void)top_bottomViewFunctionTip:(NSInteger)index{
    NSArray * num = [self top_bottomFunctionArray];
    self.bottomFuncIndex = index;
    switch ([num[index] integerValue]) {
        case TOPScamerBatchBottomViewFunctionWatermark:
            [self top_addWaterMark];
            break;
        case TOPScamerBatchBottomViewFunctionEdit:
            [self top_bottomFunctionEdit];
            break;
        case TOPScamerBatchBottomViewFunctionFilter:
            [self top_bottomFunctionFilter];
            break;
        case TOPScamerBatchBottomViewFunctionFinish:
            [self top_bottomFunctionFinish];
            break;
        default:
            break;
    }
}

#pragma mark -- 弹出渲染菜单
- (void)top_showFilterView {
    if (!_filterView) {
        [self.view addSubview:self.filterView];
    }else{
        [self.filterView.filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.bottomView top_changeFilterBtnSelectState:YES atIndex:self.bottomFuncIndex];
        self.filterView.alpha = 1;
    }];
}

#pragma mark -- 收起渲染菜单
- (void)top_hideFilterView {
    [UIView animateWithDuration:0.2 animations:^{
        self.filterView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.bottomView top_changeFilterBtnSelectState:NO atIndex:self.bottomFuncIndex];
    }];
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
        [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]];
        
        if ([self.docModel.type isEqualToString:@"1"]) {
            for (NSString *fileName in self.imagePathArr) {
                NSString *imgPath = [self.filePath stringByAppendingPathComponent:fileName];
                [TOPWHCFileManager top_removeItemAtPath:imgPath];
                [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_originalImage:imgPath]];
                [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_backupImage:imgPath]];
            }
        } else {
            [TOPWHCFileManager top_removeItemAtPath:self.filePath];
        }
        
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
    if (self.top_finishBtnAction) {//完成之后的回调
        self.top_finishBtnAction();
    }
    [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_collageImageFileString]];
    if (self.enterCameraType == TOPShowFolderCameraType||self.enterCameraType == TOPEnterHomeCameraTypeLibrary) {
        [self top_jumpHomeChildVC];
    } else if (self.enterCameraType == TOPShowNextFolderCameraType||self.enterCameraType == TOPEnterNextFolderCameraTypeLibrary) {
        [self top_jumpHomeChildVC];
    } else if(self.enterCameraType == TOPShowIDCardCameraType||self.enterCameraType == TOPShowToTextCameraType){
        [self top_jumpHomeChildVC];
    } else if (self.enterCameraType == TOPShowDocumentCameraType) {//入口在docment文档详情的相机
        if ([TOPScanerShare shared].isPush) {
            [TOPScanerShare shared].isPush = NO;
            TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
            childVC.docModel = [TOPFileDataManager shareInstance].docModel;
            childVC.pathString = self.filePath;
            childVC.addType = @"add";
            childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
            childVC.hidesBottomBarWhenPushed = YES;
            [[TOPDocumentHelper top_getPushVC].navigationController pushViewController:childVC animated:YES];
            [[TOPDocumentHelper top_getPushVC].navigationController dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController.viewControllers[0] dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)top_jumpHomeChildVC {
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    TOPAppDocument *doc = [TOPEditDBDataHandler top_addDocumentAtFolder:self.filePath WithParentId:self.docModel.docId];
    [self top_writeImageFilterData:doc];
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
        
        [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
        [self top_removeBackupImages];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [self top_collageVC_CompleteBack];
        });
    });
}

- (void)top_removeBackupImages {
    for (NSString *picName in self.imagePathArr) {
        NSString *picPath = [self.filePath stringByAppendingPathComponent:picName];
        NSString *backupPic = [TOPDocumentHelper top_backupImage:picPath];
        if ([TOPWHCFileManager top_isExistsAtPath:backupPic]) {
            [TOPWHCFileManager top_removeItemAtPath:backupPic];
        }
    }
}

#pragma mark -- 文档数据写入数据库
- (void)top_writeDataToDB {
    if ([self.docModel.type isEqualToString:@"1"]) {
        NSArray *newImages = [TOPDocumentHelper top_sortPicsAtPath:[TOPDocumentHelper top_collageImageFileString]];
        [TOPEditDBDataHandler top_addImageFileAtDocument:newImages WithId:self.docModel.docId];
        [TOPEditDBDataHandler top_addImageFileAtDocument:self.imagePathArr WithId:self.docModel.docId];
        for (NSString *fileName in self.imagePathArr) {
            RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:self.docModel.docId withName:fileName];
            if (images.count) {
                [self top_updateFilterData:images.firstObject];
            }
        }
    }
}

#pragma mark -- 写入图片的裁剪、渲染、朝向数据
- (void)top_writeImageFilterData:(TOPAppDocument *)appDoc {
    if (appDoc.images.count) {
        for (int i = 0; i < (appDoc.images.count - 1); i ++) {
            TOPImageFile *imgFile = appDoc.images[i];
            [self top_updateFilterData:imgFile];
        }
    }
}

- (void)top_updateFilterData:(TOPImageFile *)imgFile {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"PicName = %@",imgFile.fileName];
    NSArray *results = [self.cameraArray filteredArrayUsingPredicate:predicate];
    if (results.count) {
        TOPCameraBatchModel * model = results.firstObject;
        NSMutableArray *points = [TOPDataModelHandler top_pointsFromModel:model.elementModel];
    
        TOPSaveElementModel * elementModel = [TOPDataModelHandler top_getBatchSavePointData:model.autoEndPoinArray imgPath:model.originalImgPath imgRect:model.cropImgViewRect];
        NSMutableArray *autoPoints = [TOPDataModelHandler top_pointsFromModel:elementModel];
        
        NSDictionary *param = @{@"orientation":@(0),
                                @"filter":@(self.lastProcessType),
                                @"points":points,
                                @"autoPoints":autoPoints};
        [TOPEditDBDataHandler top_updateImageWithHandler:param byId:imgFile.Id];
    }
}

#pragma mark -- 完成
- (void)top_bottomFunctionFinish{
    [self.collageCollectionView top_hiddenCtrlTap];
    [self top_collagedVC_createNewImage];
}


#pragma mark -- 渲染
- (void)top_bottomFunctionFilter {
    self.isFilterShow = !self.isFilterShow;
    if (self.isFilterShow) {
        [self top_showFilterView];
    }else{
        [self top_hideFilterView];
    }
}

#pragma mark -- 编辑图片
- (void)top_bottomFunctionEdit {
    WS(weakSelf);
    TOPBatchViewController * batchVC = [TOPBatchViewController new];
    batchVC.currentIndex = self.selectPicTag;
    batchVC.cameraArray = self.cameraArray;
    batchVC.batchCropType = TOPBatchCropTypeCamera;
    batchVC.top_returnAndReloadData = ^(NSMutableArray * _Nonnull dataArray) {
        BOOL ischange = NO;
        for (TOPCropEditModel * cropModel in dataArray) {
            for (TOPCameraBatchModel * model in weakSelf.cameraArray) {
                if ([model.PicName isEqualToString:cropModel.picName]&&cropModel.isChange) {
                    ischange = YES;
                    model.endPoinArray = cropModel.endPoinArray;
                    TOPSaveElementModel * eleModel = [TOPDataModelHandler top_getBatchSavePointData:model.endPoinArray imgPath:model.originalImgPath imgRect:model.cropImgViewRect];
                    model.elementModel = eleModel;
                    NSString *picPath = model.imgPath;
                    NSString *backupPic = [TOPDocumentHelper top_backupImage:picPath];
                    [TOPWHCFileManager top_copyItemAtPath:picPath toPath:backupPic overwrite:YES];
                }
            }
        }
        if (ischange) {
            [weakSelf top_editCompletedRefresh];
        }
    };
    batchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:batchVC animated:YES];
}


#pragma mark -- 编辑后刷新
- (void)top_editCompletedRefresh {
    [self top_reloadNewFilterPic:self.lastProcessType];
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

#pragma mark -- 渲染模式列表cell的点击事件
- (void)top_filterViewCellAction:(TOPReEditModel *)model{
    self.isFilterShow = NO;
    [self top_hideFilterView];
    if (model.processType != self.lastProcessType) {
        self.lastProcessType = model.processType;
        [self top_reloadNewFilterPic:self.lastProcessType];
    }
}

#pragma mark -- 重新渲染
- (void)top_reloadNewFilterPic:(NSInteger)processType {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (NSString *picName in self.imagePathArr) {
            NSString *picPath = [self.filePath stringByAppendingPathComponent:picName];
            NSString *backupPic = [TOPDocumentHelper top_backupImage:picPath];
            UIImage *originImage = [UIImage imageWithContentsOfFile:backupPic];
            if (originImage) {
                GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:originImage];
                UIImage *image = [TOPDataTool top_pictureProcessData:imageSource withImg:originImage withItem:processType];
                [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
                [TOPDocumentHelper top_saveImage:image atPath:picPath];
                NSMutableArray *data = [self.collageHandler collageViewDatas];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [self.collageCollectionView top_hiddenCtrlTap];
                    self.collageCollectionView.dataArray = data;
                });
            }
        }
    });
}

#pragma mark -- 蒙版点击消失
- (void)top_backView_ClickTap {
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backView removeFromSuperview];
        self.backView = nil;
    }];
}

#pragma mark -- lazy
- (NSMutableArray *)batchArray{
    if (!_batchArray) {
        _batchArray = [NSMutableArray new];
    }
    return _batchArray;
}
#pragma mark -- 蒙层
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = [UIColor clearColor];
    }
    return _coverView;
}

#pragma mark -- 渲染菜单视图
- (TOPCameraFilterView *)filterView{
    WS(weakSelf);
    if (!_filterView) {
        _filterView = [[TOPCameraFilterView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPNavBarAndStatusBarHeight - 49 - 100 - TOPBottomSafeHeight, TOPScreenWidth, 100)];
        _filterView.alpha = 0;
        _filterView.top_sendProcessStateTip = ^(TOPReEditModel * _Nonnull model, NSInteger index) {
            weakSelf.currentIndex = index;
            [weakSelf top_filterViewCellAction:model];
        };
    }
    return _filterView;
}


- (NSArray *)top_bottomFunctionArray{
    NSArray * tempArray = @[@(TOPScamerBatchBottomViewFunctionWatermark),@(TOPScamerBatchBottomViewFunctionEdit),@(TOPScamerBatchBottomViewFunctionFilter),@(TOPScamerBatchBottomViewFunctionFinish)];
    return tempArray;
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
        _collageCollectionView.idCardModel = YES;
        _collageCollectionView.top_didScrollBlock = ^(NSInteger page) {
            if (weakSelf.collageHandler.dataArray.count > 1) {
                weakSelf.pageLab.text = [NSString stringWithFormat:@"%@/%@",@(page),@(weakSelf.collageHandler.dataArray.count)];
            }
        };
        _collageCollectionView.top_changeEditingPicBlock = ^(NSInteger tag) {
            weakSelf.collageHandler.editingImageIndex = tag;
        };
        _collageCollectionView.top_selectPicEditBlock = ^(NSInteger tag) {
            weakSelf.selectPicTag = tag;
            [weakSelf top_bottomFunctionEdit];
        };
    }
    return _collageCollectionView;
}

//遮罩层
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
