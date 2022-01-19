#import "TOPMainTabBarController.h"
#import "TOPMainTabBar.h"
#import "TOPHomeViewController.h"
#import "SCRecentPreviewViewController.h"
#import "SCHomeListViewController.h"
#import "TOPFunctionCollectionVC.h"

#import "TOPScreenShotView.h"
#import "TOPHomeChildViewController.h"
#import "TOPSuggestionsVC.h"
#import "TOPSettingGeneralVC.h"
#import "TOPShareTypeView.h"
#import "TOPScreenshotHelper.h"
@interface TOPMainTabBarController ()<UINavigationControllerDelegate>
@property (nonatomic ,strong)TOPMainTabBar *mainTabBar;
@property (nonatomic ,strong)TOPScreenShotView * shotView;
@property (nonatomic ,strong)TOPShareTypeView * shareAction;
@property (nonatomic ,copy)NSString * shotUrl;//分享时的url
@property (nonatomic ,strong)UIImage * shotImg;
@property (nonatomic ,strong)DocumentModel *saveModel;//保留进入TOPHomeChildViewController之前单利模型数据
@end

@implementation TOPMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setValue:self.mainTabBar forKey:@"tabBar"];
    [self top_setUpChildVC];
    self.tabIndex = 0;
}
-(void)top_setUpChildVC{
    TOPHomeViewController *homeVC = [TOPHomeViewController new];
    TOPBaseNavViewController *nav3 = [[TOPBaseNavViewController alloc] initWithRootViewController:homeVC];
    [self addChildViewController:nav3];
    
    TOPFunctionCollectionVC *functionVC = [TOPFunctionCollectionVC new];
    functionVC.navigationItem.title = NSLocalizedString(@"topscan_tabbartitleapplication", @"");//应用
    TOPBaseNavViewController *nav4 = [[TOPBaseNavViewController alloc] initWithRootViewController:functionVC];
    [self addChildViewController:nav4];
}

-(TOPMainTabBar *)mainTabBar{
    if (!_mainTabBar) {
        NSArray *titArr = @[NSLocalizedString(@"topscan_tabbartitledocs", @""),@"",NSLocalizedString(@"topscan_tabbartitleapplication", @"")];
        NSArray *imgArr = @[@"top_tab_allDoc",@"top_paizhao_icon",@"top_tab_moreFunction"];
        NSArray *sImgArr = @[@"top_tab_allDocSelect",@"top_paizhao_icon",@"top_tab_moreFunctionSelect"];
        TOPMainTabBar *mainTabBar = [[TOPMainTabBar alloc]initWithTitArr:titArr imgArr:imgArr sImgArr:sImgArr];
        mainTabBar.delegate = self;
        mainTabBar.changeIndex = ^(NSInteger index){
            [self top_changeIndexdd:index];
        };
        _mainTabBar = mainTabBar;
    }
    return _mainTabBar;
}
#pragma mark -TabBar Delegate
-(void)top_changeIndexdd:(NSInteger)index{
    if (index == 1) {
        [FIRAnalytics logEventWithName:@"tab_camera" parameters:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:TOP_TRCenterBtnGetCamera object:nil];
        [_mainTabBar top_currentSelect:self.tabIndex];
        if (self.tabIndex>1) {
            self.selectedIndex = self.tabIndex-1;
        }else{
            self.selectedIndex = self.tabIndex;
        }
    }else{
        self.tabIndex = index;
        if (index>1) {
            self.selectedIndex = index-1;
        }else{
            self.selectedIndex = index;
        }
        NSString * firString = @"";
        if (self.selectedIndex == 0) {
            firString = @"tab_doc";
        }else{
            firString = @"tab_application";
        }
        [FIRAnalytics logEventWithName:firString parameters:nil];
    }
}

- (void)addChildControllers:(Class)class title:(NSString *)title imageName:(NSString *)imageName selectImageName:(NSString *)selectImageName
{
    UIViewController *oneVC = [[class alloc]init];
    oneVC.title = title;
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:oneVC];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"a1a8b2"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:11],NSFontAttributeName, nil]forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"1f98f7"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:11],NSFontAttributeName, nil]forState:UIControlStateSelected];
    [navC.tabBarController.tabBar setTranslucent:NO];
    navC.tabBarItem.image = [UIImage imageNamed:imageName];
    navC.tabBarItem.selectedImage = [[UIImage imageNamed:selectImageName] imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
    [self addChildViewController:navC];
}

#pragma mark - 设置状态栏的颜色
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL) prefersStatusBarHidden {
    return NO;
}

#pragma mark - UITabbarController
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController NS_AVAILABLE_IOS(3_0) {
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}
- (BOOL)shouldAutorotate{
    return [TOPDocumentHelper top_getInterfaceOrientationState]; 
}
#pragma mark -- 注册截屏的通知
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //由于截屏通知是在navVC里实现的 有可能会出现截屏通知走多次的情况 这是需要进行控制处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(top_didTakeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    //截屏的数据分享完成之后取消弹出的截屏试图
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(top_TOP_TRRemoveScreenhostView) name:TOP_TRRemoveScreenhostView object:nil];
}
#pragma mark -- 获取截屏通知后操作
- (void)top_didTakeScreenshot:(NSNotification *)notification{
    [FIRAnalytics logEventWithName:@"takeScreenshot" parameters:nil];
    if (![TOPScanerShare top_screenshotEventState]) {
        [FIRAnalytics logEventWithName:@"takeScreenshotopen" parameters:nil];
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.shotView) {
                WS(weakSelf);
                TOPScreenShotView * shotView = [[TOPScreenShotView alloc]initWithFrame:CGRectZero];
                shotView.top_functionBlock = ^(NSInteger index) {
                    [weakSelf top_shotFunction:index];
                };
                [weakSelf.shotView removeFromSuperview];
                weakSelf.shotView = nil;
                shotView.hidden = YES;
                [keyWindow addSubview:shotView];
                self.shotView = shotView;
                
                [self.shotView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.top.bottom.equalTo(keyWindow);
                }];
                
                PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
                if (status == PHAuthorizationStatusAuthorized) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        PHAsset * asset = [self top_latestAsset];
                        PHImageManager * imageManager = [PHImageManager defaultManager];
                        [imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                            UIImage * image = [UIImage imageWithData:imageData];
                            [self top_dealImgData:image];
                        }];
                    });
                }else{
                    UIImage * shotImg = [TOPScreenshotHelper top_screenshotWithStatusBar:YES];
                    [self top_dealImgData:shotImg];
                }
            }
        });
    }
}
#pragma mark -- 获取最新图片
- (PHAsset *)top_latestAsset {
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    return [assetsFetchResults firstObject];
}
#pragma mark -- 最后图片处理
- (void)top_dealImgData:(UIImage *)shotImg{
    if (shotImg) {
        [self top_assignShotView:shotImg];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self top_savePicTempPath:shotImg];
        });
    }
}
#pragma mark -- 将图片保存到本地 分享时用到
- (void)top_savePicTempPath:(UIImage *)img{
    if (![TOPWHCFileManager top_isExistsAtPath:TOPCompress_Path]) {
        [TOPWHCFileManager top_createDirectoryAtPath:TOPCompress_Path];
    }
    NSString *imgName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:0],TOP_TRJPGPathSuffixString];
    NSString * compressFile = [NSString stringWithFormat:@"%@/%@",TOPCompress_Path, imgName];
    NSData *data = UIImageJPEGRepresentation(img, TOP_TRPicScale);
    [data writeToFile:compressFile atomically:YES];
    self.shotUrl = compressFile;
}
#pragma mark -- 截屏的弹出试图赋值
- (void)top_assignShotView:(UIImage *)image{
    self.shotImg = image;
    self.shotView.showImage = image;
    self.shotView.hidden = NO;
}
#pragma mark -- 取消截屏试图
- (void)top_TOP_TRRemoveScreenhostView{
    [self.shotView removeFromSuperview];
    self.shotView = nil;
}
#pragma mark -- 功能集
- (void)top_shotFunction:(NSInteger)index{
    NSNumber * num = [self top_functionArray][index];
    switch ([num integerValue]) {
        case TOPDeviceShotFinctionSaveDoc:
            [self top_shotSaveDoc];
            break;
        case TOPDeviceShotFinctionOCR:
            [self top_shotOCR];
            break;
        case TOPDeviceShotFinctionQuestion:
            [self top_shotCancel];
            [self top_shotQuestion];
            break;
        case TOPDeviceShotFinctionShare:
            [self top_shotShare];
            [self top_calculateSelectNumber];
            break;
        case TOPDeviceShotFinctionCancel:
            [self top_shotCancel];
            break;
        case TOPDeviceShotFinctionSetting:
            [self top_shotCancel];
            [self top_shotSetting];
            break;
        default:
            break;
    }
}
#pragma mark -- 保存文档
- (void)top_shotSaveDoc{
    if (self.shotImg) {
        WS(weakSelf);
        NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            DocumentModel *model = [self top_setDataModel:endPath];
            self.saveModel = [TOPFileDataManager shareInstance].docModel;//进入TOPHomeChildViewController之后单利模型数据会被修改 所以要把没修改之前的单利数据模型保留起来
            dispatch_async(dispatch_get_main_queue(), ^{
                TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
                childVC.top_backScreenshotAction = ^{
                    [TOPFileDataManager shareInstance].docModel = weakSelf.saveModel;//返回之后将保留的模型数据重新赋值给单利模型 否则拍照流程会出问题
                };
                childVC.docModel = model;
                childVC.pathString = endPath;
                childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
                childVC.addType = @"add";
                childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
                childVC.hidesBottomBarWhenPushed = YES;
                [[TOPDocumentHelper top_topViewController].navigationController pushViewController:childVC animated:YES];
                [self top_shotCancel];
            });
        });
    }
}
#pragma mark -- 将截图保存到起来 并生成对应的模型
- (DocumentModel *)top_setDataModel:(NSString *)endPath{
    NSString *imgName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:0],TOP_TRJPGPathSuffixString];
    NSString *oriName = [NSString stringWithFormat:@"%@%@%@%@",TOPRSimpleScanOriginalString,[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:0],TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [endPath stringByAppendingPathComponent:imgName];
    NSString *oriEndPath = [endPath stringByAppendingPathComponent:oriName];
    [UIImageJPEGRepresentation(self.shotImg,TOP_TRPicScale) writeToFile:fileEndPath atomically:YES];
    [UIImageJPEGRepresentation(self.shotImg,TOP_TRPicScale) writeToFile:oriEndPath atomically:YES];
    DocumentModel *model = [TOPDBDataHandler top_addNewDocModel:endPath];
    return model;
}
#pragma mark -- ocr识别
- (void)top_shotOCR{
    if (self.shotImg) {
        NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            DocumentModel *model = [self top_setDataModel:endPath];
            NSMutableArray *dataArray = [TOPDataModelHandler top_buildDocumentSecondaryDataAtPath:model.path];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self top_shotCancel];
                TOPPhotoShowOCRVC * ocrVC = [TOPPhotoShowOCRVC new];
                ocrVC.currentIndex = 0;
                ocrVC.docModel = [TOPFileDataManager shareInstance].docModel;
                ocrVC.dataArray = dataArray;//DocumentModel
                ocrVC.backType = TOPPhotoShowTextAgainVCBackTypePopRoot;
                ocrVC.ocrAgain = TOPPhotoShowOCRVCAgainTypeOCRNot;
                ocrVC.finishType = TOPPhotoShowOCRVCAgainFinishNot;
                ocrVC.dataType = TOPOCRDataTypeSingleDocument;
                ocrVC.hidesBottomBarWhenPushed = YES;
                [[TOPDocumentHelper top_topViewController].navigationController pushViewController:ocrVC animated:YES];
            });
        });
    }
}
#pragma mark -- 意见反馈
- (void)top_shotQuestion{
    TOPSuggestionsVC * suVC = [TOPSuggestionsVC new];
    suVC.picArray = @[self.shotImg];
    suVC.hidesBottomBarWhenPushed = YES;
    [[TOPDocumentHelper top_topViewController].navigationController pushViewController:suVC animated:YES];
}
#pragma mark -- 分享
- (void)top_shotShare{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    WS(weakSelf);
    NSArray * titleArray = @[NSLocalizedString(@"topscan_pdffile", @""),NSLocalizedString(@"topscan_image_jpg", @"")];
    NSArray * picArray = @[@"top_SharePDF",@"top_ShareJPG"];

    TOPShareTypeView *shareAction = [[TOPShareTypeView alloc] initWithTitleView:[UIView new] titleArray: titleArray picArray:picArray  cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
        weakSelf.shotView.backView.hidden = NO;
    } selectBlock:^(NSInteger row, NSString * _Nonnull totalSize) {
        weakSelf.shotView.backView.hidden = NO;
        [self top_sendShareData:row];
    }];
    shareAction.backView.backgroundColor = TOPAppDarkBackgroundColor;
    shareAction.maskView.backgroundColor = [UIColor clearColor];
    self.shareAction = shareAction;
    [window addSubview:shareAction];
    [shareAction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(window);
    }];
}

- (void)top_sendShareData:(NSInteger)index{
    NSString *imgName  = [NSString stringWithFormat:@"%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:0]];
    __block NSArray * shareArray = [NSArray new];
    NSNumber * num = [self shareType][index];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([num integerValue] == TOPShareFilePDF) {//分享pdf
            NSString * pdfPathString = [TOPDocumentHelper top_creatPDF:@[self.shotImg] documentName:imgName];
            shareArray = @[[NSURL fileURLWithPath:pdfPathString]];
        }else{
            shareArray = @[[NSURL fileURLWithPath:self.shotUrl]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:shareArray applicationActivities:nil];
            NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
            activiVC.excludedActivityTypes = excludedActivityTypes;
            if (IS_IPAD) {
                activiVC.popoverPresentationController.sourceView = self.view;
                activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
                activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            [[TOPDocumentHelper top_topViewController] presentViewController: activiVC animated:YES completion:nil];
        });
    });
}
#pragma mark -- 计算图片大小
- (void)top_calculateSelectNumber{
    if (self.shotImg) {
        NSData * imgData = UIImageJPEGRepresentation(self.shotImg, TOP_TRPicScale);
        double imgLength = [imgData length] * 1.0;
        NSString * totalSize = [TOPDocumentHelper top_memorySizeStr:imgLength];
        self.shareAction.numberStr = totalSize;
    }
}
#pragma mark -- 取消
- (void)top_shotCancel{
    [self.shotView removeFromSuperview];
    self.shotView = nil;
}
#pragma mark -- 设置
- (void)top_shotSetting{
    TOPSettingGeneralVC * generalVC = [TOPSettingGeneralVC new];
    [[TOPDocumentHelper top_topViewController].navigationController pushViewController:generalVC animated:YES];
}
#pragma mark -- 生成截屏图片
- (NSData*)top_screenshotWithRect{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen  mainScreen].bounds.size;
    }else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height,  [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize,  NO,  0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft){
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }else if (orientation == UIInterfaceOrientationLandscapeRight){
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        }else if (orientation == UIInterfaceOrientationPortraitUpsideDown){
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]){
            [window  drawViewHierarchyInRect:window.bounds  afterScreenUpdates:YES];
        }else{
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(image, TOP_TRPicScale);
}
- (NSArray *)top_functionArray{
    NSArray * array = @[@(TOPDeviceShotFinctionSaveDoc),@(TOPDeviceShotFinctionOCR),@(TOPDeviceShotFinctionQuestion),@(TOPDeviceShotFinctionShare),@(TOPDeviceShotFinctionCancel),@(TOPDeviceShotFinctionSetting)];
    return array;
}
- (NSArray *)shareType{
    NSArray * array = @[@(TOPShareFilePDF),@(TOPShareFileJPG)];
    return array;
}
@end
