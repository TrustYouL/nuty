#import "TOPFunctionCollectionVC.h"
#import "TOPFunctionColletionModel.h"
#import "TOPFunctionCollectionCell.h"
#import "TOPHomeChildViewController.h"
#import "TOPEditPDFViewController.h"
#import "TOPSettingViewController.h"

#import "TOPHomePageHeaderView.h"
#import "TOPHomeTopMergeVC.h"
#import "TOPRestoreViewController.h"
#import "TOPFunctionColletionListVC.h"
#import "TOPCamerBatchViewController.h"
#import "TOPSingleBatchViewController.h"
#import "TOPSCameraViewController.h"
#import "TOPLoadSelectDriveViewController.h"
#import "TOPBinHomeViewController.h"
#import "TOPFunctionImportantVC.h"
#import "TOPFuncModel.h"
#import "TOPFunctionHeaderView.h"
#import "TOPDocumentFooterReusableView.h"
@interface TOPFunctionCollectionVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIDocumentPickerDelegate,TZImagePickerControllerDelegate,GADBannerViewDelegate>
@property (nonatomic ,strong)NSMutableArray * dataArray;
@property (nonatomic ,strong)UICollectionView * collectionView;
@property (nonatomic ,strong)TOPFunctionColletionModel * selectModel;
@property (nonatomic ,strong)GADBannerView * scBannerView;
@property (nonatomic ,assign)BOOL isBanner;
@property (nonatomic ,assign)CGFloat adViewH;
@end

@implementation TOPFunctionCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];

    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
    }];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    self.collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
}
#pragma mark -- 构建数据模型
- (void)top_loadData{
    NSMutableArray * modelArray = [NSMutableArray new];
    for (int i = 0; i<[self iconImgArray].count; i++) {
        NSArray * iconArray = [self iconImgArray][i];
        NSArray * titleArray = [self titleArray][i];
        NSArray * funcArray = [self functionTypeArray][i];
        NSMutableArray * tempArray = [NSMutableArray new];
        for (int j = 0; j<iconArray.count; j++) {
            TOPFunctionColletionModel * model = [TOPFunctionColletionModel new];
            model.iconString = iconArray[j];
            model.titleString = titleArray[j];
            model.functionType = [funcArray[j] integerValue];
            [tempArray addObject:model];
        }
        TOPFuncModel * topModel = [TOPFuncModel new];
        topModel.modelArray = [tempArray copy];
        topModel.titleString = [self sectionTitleArray][i];
        [modelArray addObject:topModel];
    }
    self.dataArray = modelArray;
    [self.collectionView reloadData];
}
#pragma mark -- 横竖屏切换时重新设置titleView
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self top_setupNavBar];
    [self.collectionView reloadData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(top_function_GetCamera) name:TOP_TRCenterBtnGetCamera object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(top_downloadFileDrivesSusess:) name:@"downDrives" object:nil];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
    [self top_setupNavBar];
    [self top_initFileManager];
    [self top_loadData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self top_restoreBannerAD:self.view.size];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    };
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.tabBarController.selectedIndex != 1) {
        [self top_removeBannerView];
    }
}
- (void)top_function_GetCamera{
    [FIRAnalytics logEventWithName:@"homeView_GetCamera" parameters:nil];
    TOPEnterCameraType cameraTpye = TOPShowFolderCameraType;
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = [TOPDocumentHelper top_appBoxDirectory];
    camera.fileType = cameraTpye;
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)top_backHomeAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)top_restoreBannerAD:(CGSize)size{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self top_changeBannerViewFream:size];
            });
        }];
    } else {
        [self top_changeBannerViewFream:size];
    }
}
#pragma mark --UI 布局界面
- (void)top_setupNavBar {
    TOPHomePageHeaderView * homeHeaderView = [self setMyHomeHeaderView];
    self.navigationItem.titleView = homeHeaderView;
    [homeHeaderView top_setupUI];
    [homeHeaderView top_changeChildHideState:NSLocalizedString(@"topscan_tabbartitleapplication", @"")];
}
- (void)top_functionView_HomeTopSetting{
    TOPSettingViewController * setVC = [TOPSettingViewController new];
    setVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setVC animated:YES];
}
- (void)top_initFileManager {
    DocumentModel *model = [[DocumentModel alloc] init];
    model.docId = @"000000";
    model.type = @"0";
    model.path = [TOPDocumentHelper top_getDocumentsPathString];
    [TOPFileDataManager shareInstance].docModel = model;
}

#pragma mark -- tableViewDelegate datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    TOPFuncModel * topModel = self.dataArray[section];
    return topModel.modelArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPFuncModel * topModel = self.dataArray[indexPath.section];
    TOPFunctionColletionModel * model = topModel.modelArray[indexPath.row];
    TOPFunctionCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPFunctionCollectionCell class])  forIndexPath:indexPath];
    cell.model = model;
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    TOPFuncModel * topModel = self.dataArray[indexPath.section];
    if (kind == UICollectionElementKindSectionHeader) {
        TOPFunctionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([TOPFunctionHeaderView class]) forIndexPath:indexPath];
        headerView.titleLab.text = topModel.titleString;
        reusableview = headerView;
    }else{
        TOPDocumentFooterReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([TOPDocumentFooterReusableView class]) forIndexPath:indexPath];
        reusableview = footerView;
    }
    return reusableview;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(TOPScreenWidth, 40);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(TOPScreenWidth, 0.01);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger cellW = (TOPScreenWidth-([self top_getDefaultParamete]-1)*5-20*2)/([self top_getDefaultParamete]);
    return CGSizeMake(cellW, 90);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 20, 0, 20);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPFuncModel * topModel = self.dataArray[indexPath.section];
    TOPFunctionColletionModel * model = topModel.modelArray[indexPath.row];
    self.selectModel = model;
    [self top_clickCellAction:model];
}

#pragma mark -- 根据列表的排列方式 确定横竖屏对应的列数
- (NSInteger)top_getDefaultParamete{
    NSInteger kColumnCount = 0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown) {
        kColumnCount = 4;
    }else{
        kColumnCount = 5;
    }
    return kColumnCount;
}
- (void)top_clickCellAction:(TOPFunctionColletionModel *)model{
    switch (model.functionType) {
        case TopFunctionTypePDFToLongPicture:
            [FIRAnalytics logEventWithName:@"FunctionVC_pdfToLongPicture" parameters:nil];
            [self top_pdfExportToLongPicture];
            break;
        case TopFunctionTypePDFToImage:
            [FIRAnalytics logEventWithName:@"FunctionVC_pdfToImage" parameters:nil];
            [self top_pdfToImage];
            break;
        case TopFunctionTypePDFPassword:
            [FIRAnalytics logEventWithName:@"FunctionVC_pdfSetPassword" parameters:nil];
            [self top_pdfSetPassword];
            break;
        case TopFunctionTypePDFExtract:
            [FIRAnalytics logEventWithName:@"FunctionVC_pdfExtract" parameters:nil];
            [self top_pdfExtract];
            break;
        case TopFunctionTypePDFPageAdjustment:
            [FIRAnalytics logEventWithName:@"FunctionVC_pdfPageAdjustment" parameters:nil];
            [self top_pdfPageAdjustment];
            break;
        case TopFunctionTypeImportImage:
            [FIRAnalytics logEventWithName:@"FunctionVC_importImageFromIcloud" parameters:nil];
            [self top_importImageFromIcloud];
            break;
        case TopFunctionTypeBackup:
            [FIRAnalytics logEventWithName:@"FunctionVC_backupAction" parameters:nil];
            [self top_backupAction];
            break;
        case TopFunctionTypeImportFile:
            [FIRAnalytics logEventWithName:@"FunctionVC_importFileFromIcloud" parameters:nil];
            [self top_importFileFromIcloud];
            break;
        case TopFunctionTypeImageToPDF:
            [FIRAnalytics logEventWithName:@"FunctionVC_importToPDF" parameters:nil];
            [self top_importToPDF];
            break;
        case TopFunctionTypeDocPassword:
            [FIRAnalytics logEventWithName:@"FunctionVC_docSetPassword" parameters:nil];
            [self top_docSetPassword];
            break;
        case TopFunctionTypeScanIDCard:
            [FIRAnalytics logEventWithName:@"FunctionVC_scanIDCardAction" parameters:nil];
            [self top_scanIDCardAction];
            break;
        case TopFunctionTypeBatchEdit:
            [FIRAnalytics logEventWithName:@"FunctionVC_batchEditAction" parameters:nil];
            [self top_batchEditAction];
            break;
        case TopFunctionTypeMergePDF:
            [FIRAnalytics logEventWithName:@"FunctionVC_mergePDFAction" parameters:nil];
            [self top_mergePDFAction];
            break;
        case TopFunctionTypePDFAddWatermark:
            [FIRAnalytics logEventWithName:@"FunctionVC_pdfAddWatermark" parameters:nil];
            [self top_pdfAddWatermark];
            break;
        case TopFunctionTypeSetTags:
            [FIRAnalytics logEventWithName:@"FunctionVC_documnentSetTags" parameters:nil];
            [self top_documnentSetTags];
            break;
        case TopFunctionTypePDFSignature:
            [FIRAnalytics logEventWithName:@"FunctionVC_pdfSignatureAction" parameters:nil];
            [self top_pdfSignatureAction];
            break;
        case TopFunctionTypeOCR:
            [FIRAnalytics logEventWithName:@"FunctionVC_functionToOCR" parameters:nil];
            [self top_functionToOCR];
            break;
        case TopFunctionTypeQRBarCode:
            [FIRAnalytics logEventWithName:@"FunctionVC_functionToQRBarCode" parameters:nil];
            [self top_functionToQRBarCode];
            break;
        case TopFunctionTypeDriveDownloadFile:
            [FIRAnalytics logEventWithName:@"FunctionVC_functionToDriveDownload" parameters:nil];
            [self top_functionTodownDriveFile];
            break;
        case TopFunctionTypeRecycelBin:
            [FIRAnalytics logEventWithName:@"FunctionVC_functionToRecycleBin" parameters:nil];
            [self top_functions_RecycleBin];
            break;
        case TopFunctionTypeDocCollection:
            [FIRAnalytics logEventWithName:@"FunctionVC_functionDocCollection" parameters:nil];
            [self top_docCollection];
            break;
        default:
            break;
    }
}
- (void)top_docCollection{
    TOPFunctionImportantVC * importVC = [TOPFunctionImportantVC new];
    importVC.selectModel = self.selectModel;
    importVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:importVC animated:YES];
}
#pragma mark -- pdf转长图
- (void)top_pdfExportToLongPicture{
    [self top_clickToPushDataListVC];
}
#pragma mark -- pdf转图片
- (void)top_pdfToImage{
    NSArray *documentTypes = @[@"com.adobe.pdf"];
    [self top_getIcouldView:documentTypes];
}
#pragma mark -- pdf设置密码
- (void)top_pdfSetPassword{
    [self top_clickToPushDataListVC];
}
#pragma mark -- import To PDF
- (void)top_importToPDF{
    [self top_clickToSystemPhotoAlbum];
}
#pragma mark -- doc文档设置密码
- (void)top_docSetPassword{
    [self top_clickToPushDataListVC];
}
#pragma mark -- icloud导入图片
- (void)top_importImageFromIcloud{
    NSArray *documentTypes = @[@"public.image"];
    [self top_getIcouldView:documentTypes];
}
#pragma mark -- icloud导入文档
- (void)top_importFileFromIcloud{
    NSArray *documentTypes = @[@"public.image",@"com.adobe.pdf"];
    [self top_getIcouldView:documentTypes];
}
#pragma mark -- 第三方网盘
- (void)top_backupAction{
    TOPRestoreViewController * webVC = [TOPRestoreViewController new];
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark -- 身份证模式
- (void)top_scanIDCardAction{
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = [TOPDocumentHelper top_appBoxDirectory];
    camera.fileType = TOPShowIDCardCameraType;
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- 批量处理
- (void)top_batchEditAction{
    [self top_clickToPushDataListVC];
}
#pragma mark -- 文档合并
- (void)top_mergePDFAction{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *dataArray = [TOPDBDataHandler top_buildHomeDataWithDB];//[TOPDataModelHandler buildHomeData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            TOPHomeTopMergeVC * mergeVC = [TOPHomeTopMergeVC new];
            mergeVC.addDocArray = dataArray;
            mergeVC.pathString = [TOPDocumentHelper top_appBoxDirectory];
            mergeVC.docModel = [TOPFileDataManager shareInstance].docModel;
            mergeVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:mergeVC animated:YES];
        });
    });
}
#pragma mark -- pdf加水印
- (void)top_pdfAddWatermark{
    [self top_clickToPushDataListVC];
}
#pragma mark -- 文档设置标签
- (void)top_documnentSetTags{
    [self top_clickToPushDataListVC];
}
#pragma mark -- pdf签名
- (void)top_pdfSignatureAction{
    [self top_clickToPushDataListVC];
}
#pragma mark --OCR
- (void)top_functionToOCR{
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = [TOPDocumentHelper top_appBoxDirectory];
    camera.fileType = TOPShowToTextCameraType;
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark --QR Bar Code(二维码扫描)
- (void)top_functionToQRBarCode{
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = [TOPDocumentHelper top_appBoxDirectory];
    camera.fileType = TOPEnterCameraTypeQRCode;
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- downloadDrive 下载第三方网盘
- (void)top_functionTodownDriveFile{
    TOPLoadSelectDriveViewController *uploadVC = [[TOPLoadSelectDriveViewController alloc] init];
    uploadVC.openDrivetype = TOPDriveOpenStyleTypeDownFile;
    uploadVC.downloadFileSavePath = [TOPDocumentHelper top_getDocumentsPathString];
    uploadVC.downloadFileType = TOPDownloadFileToDriveAddPathTypeHome;
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:uploadVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- pdf Page Adjustment
- (void)top_pdfPageAdjustment{
    [self top_clickToPushDataListVC];
}
#pragma mark --文档提取
- (void)top_pdfExtract{
    [self top_clickToPushDataListVC];
}
#pragma mark -- 跳转数据列表界面
- (void)top_clickToPushDataListVC{
    TOPFunctionColletionListVC * listVC = [TOPFunctionColletionListVC new];
    listVC.selectModel = self.selectModel;
    listVC.docModel = [TOPFileDataManager shareInstance].docModel;
    listVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listVC animated:YES];
}
#pragma mark -- 显示icloud界面
- (void)top_getIcouldView:(NSArray *)typeArray{
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc]initWithDocumentTypes:typeArray inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle =  UIModalPresentationFullScreen;
    [self presentViewController:documentPicker animated:YES completion:nil];
}
#pragma mark --- 回收站
- (void)top_functions_RecycleBin {
    TOPBinHomeViewController *binHome = [[TOPBinHomeViewController alloc] init];
    binHome.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:binHome animated:YES];
}
#pragma mark -- UIDocumentPickerDelegate
#pragma mark- iCloud Drive
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(nonnull NSArray<NSURL *> *)urls {
    //授权
    WS(weakSelf);
    BOOL fileAuthorized = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc]init]; NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) { //读取文件
            NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:newURL];
            if (error) {
                NSLog(@"读取错误error == %@",error);
            }else {
                NSLog(@"fileName: %@\nfileUrl: %@", fileName, newURL);
                if ([fileName hasSuffix:@".pdf"] || [fileName hasSuffix:@".PDF"]) {
                    CGPDFDocumentRef fromPDFDoc = CGPDFDocumentCreateWithURL((CFURLRef)newURL);
                    if (fromPDFDoc == NULL) {
                        NSLog(@"can't open '%@'", newURL); CFRelease((__bridge CFURLRef)newURL);
                    }else{
                        NSString * sendName = [NSString new];
                        if ([fileName hasSuffix:@".pdf"]) {
                            sendName = [[fileName componentsSeparatedByString:@".pdf"] firstObject];
                        }else{
                            sendName = [[fileName componentsSeparatedByString:@".PDF"] firstObject];
                        }
                        [weakSelf top_dealWithPDF:fromPDFDoc withPath:newURL alertTitle:NSLocalizedString(@"topscan_decryption", @"") alertMessage:@"pdf" fileName:sendName];
                    }
                }
                NSString * lowString = fileName.lowercaseString;
                if ([lowString hasSuffix:@".jpg"] || [lowString hasSuffix:@".png"]|| [lowString hasSuffix:@".jpeg"]) {
                    UIImage *photo = [UIImage imageWithData:fileData];
                    if (photo) {
                        NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
                        [weakSelf top_writeImageDataToDocument:photo withIndex:0 withPath:endPath];
                        [weakSelf top_icloudFinishAndPushWithPath:endPath];
                    }
                }
            }
        }];
    }
}
- (void)top_dealWithPDF:(CGPDFDocumentRef)fromPDFDoc withPath:(NSURL *)newURL alertTitle:(NSString *)title alertMessage:(NSString *)message fileName:(NSString *)fileName{
    if (CGPDFDocumentIsEncrypted (fromPDFDoc)) {
        WS(weakSelf);
        if (!CGPDFDocumentUnlockWithPassword (fromPDFDoc, "")) {
            TOPSCAlertController *alert = [TOPSCAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(alert) weakAlert = alert;
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                __strong typeof(weakAlert) strongAlert = weakAlert;

                UITextField *  textField=   strongAlert.textFields.firstObject;
                textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if (textField.text != NULL && CGPDFDocumentUnlockWithPassword (fromPDFDoc, [textField.text UTF8String])) {
                    [weakSelf top_pushSendControllerMothodWithPassword:textField.text withPath:fromPDFDoc fileName:fileName];
                }else{
                    [weakSelf top_dealWithPDF:fromPDFDoc withPath:newURL alertTitle:NSLocalizedString(@"topscan_error", @"") alertMessage:NSLocalizedString(@"topscan_pdferror", @"") fileName:fileName];
                }
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_skip", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                return;
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedString(@"topscan_placeholderpassword", @"");
            }];
            [alert addAction:cancelAction];
            
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }else{
        [self top_pushSendControllerMothodWithPassword:nil withPath:fromPDFDoc fileName:fileName];
    }
}
 
#pragma mark -- 倒入pdf的处理
- (void)top_pushSendControllerMothodWithPassword:(NSString *)passwordStr withPath:(CGPDFDocumentRef)fromPDFDoc fileName:(NSString *)fileName{
    NSString * endPath = [NSString new];
    if (fileName.length>0) {
        NSString *filePath = [[TOPDocumentHelper top_getDocumentsPathString] stringByAppendingPathComponent:fileName];
        endPath = [TOPDocumentHelper top_createDirectoryAtPath:filePath];
    }else{
        endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
    }
    WS(weakSelf);
    [[TOPProgressStripeView shareInstance]top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
    [TOPDocumentHelper top_getUIImageFromPDFPageWithpdfpathUrl:fromPDFDoc password:passwordStr docPath:endPath  progress:^(CGFloat progressString) {
        //拆分成pdf的进度条
        [[TOPProgressStripeView shareInstance]top_showProgress:progressString withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
    } success:^(id  _Nonnull responseObj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [weakSelf top_icloudFinishAndPushWithPath:endPath];
        });
    }];
}

#pragma mark -- icloud图片写入doc文件夹
- (void)top_writeImageDataToDocument:(UIImage *)image withIndex:(NSInteger)index withPath:(NSString *)endPath{
    NSString *imgName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:index],TOP_TRJPGPathSuffixString];
    NSString *oriName = [NSString stringWithFormat:@"%@%@%@%@",TOPRSimpleScanOriginalString,[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:index],TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [endPath stringByAppendingPathComponent:imgName];
    NSString *oriEndPath = [endPath stringByAppendingPathComponent:oriName];
    [UIImageJPEGRepresentation(image,TOP_TRPicScale) writeToFile:fileEndPath atomically:YES];
    [UIImageJPEGRepresentation(image,TOP_TRPicScale) writeToFile:oriEndPath atomically:YES];
}

#pragma mark -- icloud处理完成之后的跳转
- (void)top_icloudFinishAndPushWithPath:(NSString *)endPath{
    if (self.selectModel.functionType == TopFunctionTypePDFToLongPicture) {
        [self top_icloudFinishPushEditPDFWithPath:endPath];
    }else{
        [self top_icloudFinishPushChildVCWithPath:endPath];
    }
}

#pragma mark -- icloud完成跳转到childVC
- (void)top_icloudFinishPushChildVCWithPath:(NSString *)endPath{
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    childVC.docModel = [TOPDBDataHandler top_addNewDocModel:endPath];
    childVC.pathString = endPath;
    childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
    childVC.addType = @"add";
    childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
    childVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:childVC animated:YES];
}

#pragma mark -- icloud完成跳转到EditPDFVC
- (void)top_icloudFinishPushEditPDFWithPath:(NSString *)endPath{
    TOPEditPDFViewController * pdfVC = [[TOPEditPDFViewController alloc] init];
    DocumentModel *docModel = [TOPDBDataHandler top_addNewDocModel:endPath];
    pdfVC.docModel = docModel;
    pdfVC.filePath = endPath;
    pdfVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pdfVC animated:YES];
}

#pragma mark ---到系统相册
- (void)top_clickToSystemPhotoAlbum{
    CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
    if (freeSize<TOPFreeSize) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
        return;
    }
    [FIRAnalytics logEventWithName:@"FunctionVC_CameraPicture" parameters:nil];
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:NSIntegerMax columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowTakeVideo = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)top_saveAssetsRefreshUI:(NSArray *)assets {
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [self top_handleLibiaryPhoto:assets completion:^(NSArray *imagePaths) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (assets.count == 1) {
                [SVProgressHUD dismiss];
                [weakSelf top_CreateFolderWithSelectPhotos:imagePaths];
            } else if (assets.count > 1) {
                [SVProgressHUD dismiss];
                [weakSelf top_OnlyToSendData:imagePaths];
            }
        });
    }];
}

#pragma mark -TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
    [TOPWHCFileManager top_createDirectoryAtPath:TOPCamerPic_Path];
    [self top_saveAssetsRefreshUI:assets];
}

#pragma mark -- 处理相册图片 -- 大图压缩控制在1200w像素内，保存，返回图片路径
- (void)top_handleLibiaryPhoto:(NSArray *)assets completion:(void (^)(NSArray *imagePaths))completion {
    WS(weakSelf);
    dispatch_queue_t queueE = dispatch_queue_create("group.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t groupE = dispatch_group_create();
    dispatch_queue_t serialQue= dispatch_queue_create("serial.queue",DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
    for (int i = 0; i < assets.count; i ++) {
        dispatch_async(serialQue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_group_async(groupE, queueE, ^{
                dispatch_group_enter(groupE);
                [[TZImageManager manager] getOriginalPhotoDataWithAsset:assets[i] completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        if ([info[@"PHImageResultIsDegradedKey"] boolValue] == NO) {
                            CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
                            if (freeSize<50) {
                                CGFloat imgSize;
                                if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveNO) {
                                    imgSize = data.length/1024/1024+4;
                                }else{
                                    imgSize = (data.length/1024/1024)*2+4;
                                }
                                if (freeSize<imgSize) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
                                    });
                                }else{
                                    [weakSelf top_savePicData:data index:i];
                                }
                            }else{
                                [weakSelf top_savePicData:data index:i];
                            }
                        }
                        dispatch_semaphore_signal(semaphore);
                        dispatch_group_leave(groupE);
                    });
                }];
            });
            if (i == assets.count - 1) {
                dispatch_group_notify(groupE, dispatch_get_main_queue(), ^{
                    NSArray * array = [TOPDocumentHelper top_sortPicsAtPath:TOPCamerPic_Path];
                    if (array.count) {
                        if (completion) completion(array);
                    } else {
                        [FIRAnalytics logEventWithName:@"FunctionVC_noJPG" parameters:nil];
                        NSArray * items = [TOPDocumentHelper top_sortItemAthPath:TOPCamerPic_Path];
                        if (items.count) {
                            [FIRAnalytics logEventWithName:@"FunctionVC_Item" parameters:@{@"content": items[0]}];
                            if (completion) completion(items);
                        } else {
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_savefail", @"")];
                            [SVProgressHUD dismissWithDelay:1];
                        }
                    }
                });
            }
        });
    }
}
- (void)top_savePicData:(NSData *)data index:(NSInteger)i{
    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [TOPCamerPic_Path stringByAppendingPathComponent:fileName];
    BOOL result = [data writeToFile:fileEndPath atomically:YES];
    if (!result) {
        if (fileEndPath == nil) {
            fileEndPath = @"";
        }
        [FIRAnalytics logEventWithName:@"FunctionVC_pathError" parameters:@{@"path": fileEndPath}];
        [FIRAnalytics logEventWithName:@"FunctionVC_contentError" parameters:@{@"content": @(data.length)}];
    }
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)top_OnlyToSendData:(NSArray *)assets{
    if (assets.count) {
        TOPCamerBatchViewController * scamerBatch = [TOPCamerBatchViewController new];
        scamerBatch.pathString = [TOPDocumentHelper top_appBoxDirectory];
        scamerBatch.fileType = TOPShowFolderCameraType;
        scamerBatch.backType = TOPHomeChildViewControllerBackTypePopRoot;
        TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:scamerBatch];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)top_CreateFolderWithSelectPhotos:(NSArray *)photos{
    if (photos.count) {
        [FIRAnalytics logEventWithName:@"FunctionVC_CreateFolderWithPhotos" parameters:@{@"photos":photos}];
        TOPSingleBatchViewController * batch = [TOPSingleBatchViewController new];
        batch.pathString = [TOPDocumentHelper top_appBoxDirectory];
        batch.batchArray = [photos mutableCopy];
        batch.fileType = TOPShowFolderCameraType;
        batch.backType = TOPHomeChildViewControllerBackTypePopRoot;
        TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:batch];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}
#pragma mark -- 组头的标题
- (NSArray * )sectionTitleArray{
    NSArray * tempArray = @[NSLocalizedString(@"topscan_functionscan", @""),
                            NSLocalizedString(@"topscan_functionpdfconversion", @""),
                            NSLocalizedString(@"topscan_functionprocessfiles", @""),
                            NSLocalizedString(@"topscan_functionotherservices", @"")];
    return tempArray;
}
#pragma mark -- 图片 标签的数据源
- (NSArray *)iconImgArray{
    NSArray * tempArray = @[@[
//                              @"TopFunction-ScanIDCard",
//                              @"TopFunction-OCR",
                              @"TopFunction-ImportToPDF"
//                              ,@"TopFunction-QRBarCode"
                                                         ],
                            @[@"TopFunction-PDFToImg",
                              @"TopFunction-PDFToLongImg"],
                            @[@"TopFunction-ImportFile",
                              @"TopFunction-PDFSignature",
                              @"TopFunction-PDFAddWatermark",
                              @"TopFunction-MergePDF",
                              @"TopFunction-PDFPassword",
                              @"TopFunction-PDFPAgeAdjustment",
                              @"TopFunction-ImportImg",
                              @"TopFunction-PDFExtract",
                              @"TopFunction-BatchEdit",
                              @"TopFunction-DocPassword"],
                            @[@"TopFunction-Backup",
                              @"TopFunction-CloudImport",
                              @"TopFunction-SetTags",
                              @"TopFunction-RecycleBin",
                              @"TopFunction-Important"]];
    return tempArray;
}

- (NSArray *)titleArray{
    NSArray * tempArray = @[@[
//                              NSLocalizedString(@"topscan_colletionscanidcardtitle", @""),
//                              NSLocalizedString(@"topscan_ocr", @""),
                              NSLocalizedString(@"topscan_colletionimagetopdf", @"")
//                              ,NSLocalizedString(@"topscan_cameratypeqrbarcode", @"")
                                                                                           ],
                            @[NSLocalizedString(@"topscan_colletionpdftopictitle", @""),
                              NSLocalizedString(@"topscan_colletionpdftolongpictitle", @"")],
                            @[NSLocalizedString(@"topscan_importfile", @""),
                              NSLocalizedString(@"topscan_colletionpdfsignaturetitle", @""),
                              NSLocalizedString(@"topscan_colletionpdfaddwatermarktitle", @""),
                              NSLocalizedString(@"topscan_mergepdf", @""),
                              NSLocalizedString(@"topscan_setpdfpasswordtitle", @""),
                              NSLocalizedString(@"topscan_colletionpdfpageadjustment", @""),
                              NSLocalizedString(@"topscan_importimage", @""),
                              NSLocalizedString(@"topscan_colletionpdfextracttitle", @""),
                              NSLocalizedString(@"topscan_batchedit", @""),
                              NSLocalizedString(@"topscan_colletiondocpasswordtitle", @""),],
                            @[NSLocalizedString(@"topscan_icouldbackup", @""),
                              NSLocalizedString(@"topscan_drivedownloadfiles", @""),
                              NSLocalizedString(@"topscan_tagsentermanager", @""),
                              NSLocalizedString(@"topscan_recyclebin", @""),
                              NSLocalizedString(@"topscan_childimportant", @"")]];
    return tempArray;
}

- (NSArray *)functionTypeArray{
    NSArray * tempArray = @[@[
//                              @(TopFunctionTypeScanIDCard),
//                              @(TopFunctionTypeOCR),
                              @(TopFunctionTypeImageToPDF)
//                              ,@(TopFunctionTypeQRBarCode)
                                                           ],
                            @[@(TopFunctionTypePDFToImage),
                              @(TopFunctionTypePDFToLongPicture)],
                            @[@(TopFunctionTypeImportFile),
                              @(TopFunctionTypePDFSignature),
                              @(TopFunctionTypePDFAddWatermark),
                              @(TopFunctionTypeMergePDF),
                              @(TopFunctionTypePDFPassword),
                              @(TopFunctionTypePDFPageAdjustment),
                              @(TopFunctionTypeImportImage),
                              @(TopFunctionTypePDFExtract),
                              @(TopFunctionTypeBatchEdit),
                              @(TopFunctionTypeDocPassword),],
                            @[@(TopFunctionTypeBackup),
                              @(TopFunctionTypeDriveDownloadFile),
                              @(TopFunctionTypeSetTags),
                              @(TopFunctionTypeRecycelBin),
                              @(TopFunctionTypeDocCollection)]];
    return tempArray;
}
#pragma mark -- lazy
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[TOPFunctionCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPFunctionCollectionCell class])];
        [_collectionView registerClass:[TOPFunctionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([TOPFunctionHeaderView class])];
        [_collectionView registerClass:[TOPDocumentFooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([TOPDocumentFooterReusableView class])];

    }
    return _collectionView;
}
#pragma mark -- 加载横幅广告
- (void)top_changeBannerViewFream:(CGSize)size{
    if (![TOPPermissionManager top_enableByAdvertising]) {//不是会员，要展示广告
        if (!self.isBanner) {
            [self top_previewView_AddBannerViewWithSize:size];
        }
    } else {
        [self top_removeBannerView];
        [self top_changeTabFreamWhenBannerFail];
    }
}
#pragma mark -- 隐藏横幅广告视图
- (void)top_removeBannerView{
    [self.scBannerView removeFromSuperview];
    self.scBannerView = nil;
    self.isBanner = NO;
}
#pragma mark -- 横幅广告
- (void)top_previewView_AddBannerViewWithSize:(CGSize)currentSize{
    GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(currentSize.width);
    self.adViewH = adSize.size.height;
    NSString * adID = @"ca-app-pub-3940256099942544/2934735716";
    adID = [TOPDocumentHelper top_bannerAdID][0];
    GADBannerView * scbannerView = [[GADBannerView alloc] init];
    scbannerView.adSize = adSize;
    scbannerView.delegate = self;
    scbannerView.adUnitID = adID;
    scbannerView.rootViewController = self;
    self.scBannerView = scbannerView;
    [self.view addSubview:self.scBannerView];
    [self.scBannerView loadRequest:[GADRequest request]];
    self.scBannerView.hidden = YES;
    [self.scBannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
    }];
}
- (TOPHomePageHeaderView *)setMyHomeHeaderView{
    WS(weakSelf);
    TOPHomePageHeaderView * homeHeaderView = [[TOPHomePageHeaderView alloc]init];
    homeHeaderView.backgroundColor = [UIColor clearColor];
    homeHeaderView.top_DocumentHeadClickHandler = ^(NSInteger index, BOOL selected) {
        switch (index) {
            case 0:
                break;
            case 1:
                [weakSelf top_functionView_HomeTopSetting];
                break;
            case 2:
                break;
            default:
                break;
        }
    };
    return homeHeaderView;
}
#pragma mark -- 获取横幅广告成功
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView{
    [FIRAnalytics logEventWithName:@"homeView_bannerReceiveAd" parameters:nil];
    if (bannerView) {
        bannerView.hidden = NO;
        self.isBanner = YES;
        [self top_changeTabFreamWhenBannerSuccess];
    }
}
#pragma mark -- 获取横幅广告失败
- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    self.scBannerView.hidden = YES;
    self.isBanner = NO;
    [self top_changeTabFreamWhenBannerFail];
}
- (void)top_changeTabFreamWhenBannerSuccess{
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight+self.adViewH));
    }];
}
- (void)top_changeTabFreamWhenBannerFail{
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
    }];
}
#pragma mark -- 网盘批量下载成功通知
- (void)top_downloadFileDrivesSusess:(NSNotificationCenter *)notification
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
