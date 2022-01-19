#define AddFolder_W 310
#define AddFolder_H 240

#import "TOPPhotoReEditFinishVC.h"
#import "TOPHomeChildViewController.h"
#import "TOPShowLongImageViewController.h"
#import "TOPPhotoShowTextAgainVC.h"
#import "TOPPhotoReEditView.h"
#import "TOPShareFileDataHandler.h"
#import "TOPShareFileView.h"
#import "TOPShareDownSizeView.h"
#import "TOPTransferNativeAdView.h"
#import "TOPShareFileModel.h"
#import "TOPAddFolderView.h"

@interface TOPPhotoReEditFinishVC ()<MFMailComposeViewControllerDelegate,TZImagePickerControllerDelegate,GADAdLoaderDelegate,GADNativeAdLoaderDelegate>
@property (nonatomic, copy) NSString * totalSizeString;
@property (nonatomic, assign) NSInteger emailType;
@property (nonatomic, assign) NSInteger pdfType;
@property (nonatomic, strong) TOPPhotoReEditView * showView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) TOPShareFileView *shareFilePopView;
@property (nonatomic, strong) TOPSettingEmailModel * emailModel;
@property (nonatomic, strong) GADAdLoader *adLoader;
@property (nonatomic, strong) GADNativeAd * adModel;
@property (nonatomic, strong) TOPTransferNativeAdView * adView;
@property (nonatomic, strong) TOPAddFolderView * addFolderView;
@property (nonatomic, strong) UIButton *showBtn;
@property (nonatomic, strong) UIView * coverView;

@end

@implementation TOPPhotoReEditFinishVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    [self top_setBarItemView];
    [self top_setMainView];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    [TOPFileDataManager shareInstance].docModel = self.docModel;
    [self top_LoadSanBoxData];
    [self top_nativeAdConditions];
}
#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    if (self.addFolderView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            self.addFolderView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_W, AddFolder_W, AddFolder_W);
        }];
    }
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    if ([self.addFolderView.tField  isFirstResponder]) {
        [self top_ClickToHide];
    }
}
- (void)top_ClickToHide{
    [UIView animateWithDuration:0.3 animations:^{
        [self.coverView removeFromSuperview];
        [self.addFolderView removeFromSuperview];
        self.coverView = nil;
        self.addFolderView = nil;
    }];
}
#pragma mark -- 组装数据 从沙盒里面获取数据
- (void)top_LoadSanBoxData{
    TOPAppDocument *docObj = [TOPDBQueryService top_appDocumentById:self.docModel.docId];
    if (docObj.costTime > 500) {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:self.docModel.docId];
        appDoc.filePath = self.pathString;
        NSMutableArray *dataArray = [TOPDBDataHandler top_buildDocumentDataWithDB:appDoc];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            self.dataArray = dataArray;
            self.showView.dataArray = dataArray;
        });
    });
}

- (void)top_clickBtn:(UIButton *)sender{
    if (sender.tag == 1001) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else if (sender.tag == 1002){
        [self top_pushDocDetailVC];
    }
}
- (void)top_pushDocDetailVC{
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    childVC.docModel = self.docModel;
    childVC.pathString = self.pathString;
    childVC.addType = @"add";
    childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
    childVC.hidesBottomBarWhenPushed = YES;
    [[TOPDocumentHelper top_getPushVC].navigationController pushViewController:childVC animated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -- 功能集合
- (void)top_FunctionTag:(NSInteger)tag{
    NSNumber * num = [self functionType][tag];
    switch ([num integerValue]) {
        case TOPPhotoReEditFinishFunctionTypeCamera:
            [self top_ContinueTakepPhotos];
            break;
        case TOPPhotoReEditFinishFunctionTypeImport:
            [self top_ImportPicture];
            break;
        case TOPPhotoReEditFinishFunctionTypePDF:
            [self top_EditPDF];
            break;
        case TOPPhotoReEditFinishFunctionTypeEmail:
            [self top_Email];
            break;
        case TOPPhotoReEditFinishFunctionTypeShare:
            [self top_Share];
            break;
        case TOPPhotoReEditFinishFunctionTypeMore:
            [self top_More];
            break;
        case TOPPhotoReEditFinishFunctionTypeDocDetail:
            [self top_pushDocDetailVC];
            break;
        default:
            break;
    }
}
#pragma mark -- 继续拍照
- (void)top_ContinueTakepPhotos{
    [FIRAnalytics logEventWithName:@"photoReEditFinish_ContinueTakepPhotos" parameters:nil];
    [TOPScanerShare shared].isPush = YES;
    TOPEnterCameraType cameraTpye = TOPShowDocumentCameraType;
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = self.pathString;
    camera.fileType = cameraTpye;;
    camera.dataArray = self.dataArray;
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- 图库导入
- (void)top_ImportPicture{
    [FIRAnalytics logEventWithName:@"photoReEditFinish_ImportPicture" parameters:nil];
    [self top_MoreViewImportPic];
}
#pragma mark -- 编辑pdf
- (void)top_EditPDF{
    [FIRAnalytics logEventWithName:@"photoReEditFinish_EditPDF" parameters:nil];
    WS(weakSelf);
    TOPEditPDFViewController * pdfVC = [[TOPEditPDFViewController alloc] init];
    pdfVC.docModel = self.docModel;
    pdfVC.filePath = self.pathString;
    pdfVC.top_editDocNameBlock = ^(NSString * _Nonnull path) {
        NSString *name = [TOPWHCFileManager top_fileNameAtPath:path suffix:YES];
        weakSelf.title = name;
        weakSelf.pathString = path;
        [weakSelf.showBtn setTitle:weakSelf.title forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:pdfVC animated:YES];
}
#pragma mark -- 邮件
- (void)top_Email{
    self.emailType = 1;
    [FIRAnalytics logEventWithName:@"photoReEditFinish_Email" parameters:nil];
    [self top_BottomViewWithShare];
}
#pragma mark -- 分享
- (void)top_Share{
    self.emailType = 0;
    [FIRAnalytics logEventWithName:@"photoReEditFinish_Share" parameters:nil];
    [self top_BottomViewWithShare];
}
#pragma mark -- 更多
- (void)top_More{
    [FIRAnalytics logEventWithName:@"photoReEditFinish_More" parameters:nil];
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    childVC.docModel = self.docModel;
    childVC.pathString = self.pathString;
    childVC.addType = @"add";
    childVC.showMoreView = YES;
    childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
    childVC.hidesBottomBarWhenPushed = YES;
    [[TOPDocumentHelper top_getPushVC].navigationController pushViewController:childVC animated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
- (void)top_BottomViewWithShare{
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self top_AllShare];
        }
    }];
}
- (void)top_AllShare{
    for (DocumentModel * model in self.dataArray) {
        model.selectStatus = YES;
    }
    [self top_calculateSelectNumber];
    [self top_ShareTipNew];
}
- (void)top_calculateSelectNumber{
    NSMutableArray * tempPathArray = [NSMutableArray new];
    for (DocumentModel * model in self.dataArray) {
        [tempPathArray addObject:model.imagePath];
    }
    NSString * totalSize = [TOPDocumentHelper top_getFileTotalMemorySize:tempPathArray];
    self.totalSizeString = totalSize;
}
#pragma mark -- new分享
- (void)top_ShareTipNew {
    NSMutableArray *shareDatas = [TOPShareFileDataHandler top_fetchShareImageData:self.dataArray];
    if (shareDatas.count) {
        UIWindow *window = [UIApplication sharedApplication].windows[0];
        WS(weakSelf);
        TOPShareFileView *shareFileView = [[TOPShareFileView alloc] initWithItemArray:shareDatas doneTitle:NSLocalizedString(@"topscan_share", @"") cancelBlock:^{
        } selectBlock:^(TOPShareFileModel * cellModel) {
            weakSelf.pdfType = cellModel.fileType;
            [weakSelf top_selectShareFileQuantity:cellModel];
        }];
        [window addSubview:shareFileView];
        [shareFileView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(window);
        }];
        self.shareFilePopView = shareFileView;
    }
}
#pragma mark -- 选中分享图片的质量 文件大于1M时才会弹出
- (void)top_selectShareFileQuantity:(TOPShareFileModel *)cellModel {
    NSMutableArray * shareArray = [NSMutableArray new];
    WS(weakSelf);
    float unitRate = 1024.0;
    float foldSize = cellModel.fileSize / (unitRate * unitRate);
    if (foldSize > 1) {
        if (cellModel.fileType == TOPShareFilePDF || cellModel.fileType == TOPShareFileJPG) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            
            NSArray * titleArray = @[NSLocalizedString(@"topscan_originalsize", @""),NSLocalizedString(@"topscan_medium", @""),NSLocalizedString(@"topscan_small", @"")];
            if ([TOPScanerShare top_userDefinedFileSize] > 0) {
                titleArray = @[NSLocalizedString(@"topscan_originalsize", @""),NSLocalizedString(@"topscan_medium", @""),NSLocalizedString(@"topscan_small", @""),NSLocalizedString(@"topscan_userdefinedsize", @"")];
            }
            TOPShareDownSizeView * sizeView = [[TOPShareDownSizeView alloc]initWithTitleView:[UIView new]  optionsArr:titleArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
                
            } selectBlock:^(NSMutableArray * shareArray) {
                if (weakSelf.emailType == 1) {
                    [weakSelf top_BottomViewWithEmail:shareArray];
                }
                if(weakSelf.emailType == 0){
                    if (cellModel.isZip) {
                        [weakSelf top_shareZipFile:shareArray];
                    } else {
                        [weakSelf top_showAcivityVC:shareArray];
                    }
                }
            }];
            NSMutableArray * sortFdArray = [NSMutableArray new];
            if ([TOPScanerShare top_childViewByType] == 2) {
               sortFdArray = [TOPDocumentHelper top_sortByNameAZ:weakSelf.dataArray];
            }else{
                sortFdArray = weakSelf.dataArray;
            }
            [window addSubview:sizeView];
            [sizeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.bottom.equalTo(window);
            }];
            sizeView.compressType = cellModel.fileType;
            sizeView.childArray = sortFdArray;
            sizeView.totalNum = cellModel.fileSize;
            sizeView.numberStr = [TOPDocumentHelper top_memorySizeStr:cellModel.fileSize];
        } else if (cellModel.fileType == TOPShareFileLongJPG) {
            [FIRAnalytics logEventWithName:@"photoReEditFinish_ShareLongImage" parameters:nil];
            [weakSelf top_prejudgeImages];
        } else if (cellModel.fileType == TOPShareFileTxt) {
            [FIRAnalytics logEventWithName:@"photoReEditFinish_shareText" parameters:nil];
            [weakSelf top_shareText];
        }
    } else {
        if(cellModel.fileType == TOPShareFilePDF) {
            [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
            NSMutableArray * imgArray = [NSMutableArray new];
            NSMutableArray * selectArray = [NSMutableArray new];
            NSString * pdfName = [NSString new];
            for (DocumentModel * model in weakSelf.dataArray) {
                UIImage * img = [UIImage imageWithContentsOfFile:model.imagePath];
                if (img) {
                    [imgArray addObject:img];
                }
                [selectArray addObject:model];
            }
            
            if (selectArray.count == 1) {
                DocumentModel * model = selectArray[0];
                pdfName = [NSString stringWithFormat:@"%@-%@",model.fileName,model.name];
            }
            
            if (selectArray.count>1){
                DocumentModel * model = selectArray[0];
                pdfName = [NSString stringWithFormat:@"%@",model.fileName];
            }
            
            NSString * path = [TOPDocumentHelper top_creatPDF:imgArray documentName:pdfName];
            NSURL * file = [NSURL fileURLWithPath:path];
            if (file) {
                [shareArray addObject:file];
            }
            
            if (weakSelf.emailType == 1 || weakSelf.emailType == 2) {
                [weakSelf top_BottomViewWithEmail:shareArray];
            }
            
            if(weakSelf.emailType == 0){
                [weakSelf top_showAcivityVC:shareArray];
            }
        } else if(cellModel.fileType == TOPShareFileJPG){
            NSMutableArray * shareArray = [NSMutableArray new];
            NSMutableArray * selectArray = [NSMutableArray new];
            for (DocumentModel * model in weakSelf.dataArray) {
                [selectArray addObject:model];
            }
            [shareArray addObjectsFromArray:[weakSelf top_getShareImgRUL:selectArray]];

            if (weakSelf.emailType == 1 || weakSelf.emailType == 2) {
                [weakSelf top_BottomViewWithEmail:shareArray];
            }
            
            if(weakSelf.emailType == 0){
                [weakSelf top_showAcivityVC:shareArray];
            }
        } else if(cellModel.fileType == TOPShareFileLongJPG) {
            [FIRAnalytics logEventWithName:@"photoReEditFinish_ShareLongImage" parameters:nil];
            [weakSelf top_drawLongImagePreview];
        } else {
            [FIRAnalytics logEventWithName:@"photoReEditFinish_shareText" parameters:nil];
            [weakSelf top_shareText];
        }
    }
}
#pragma mark -- 分享图片时生成分享图片的url集合
- (NSMutableArray *)top_getShareImgRUL:(NSMutableArray *)childArray{
    NSMutableArray *shareArray = @[].mutableCopy;
    for (DocumentModel * model in childArray) {
        NSArray * pathArray = [model.path componentsSeparatedByString:@"/"];
        NSString * docName = [NSString new];
        if (pathArray.count>0) {
            docName = pathArray[pathArray.count-2];
        }
        NSString * savePath = [NSString stringWithFormat:@"%@_%@.jpg",docName,model.name];
        NSString * compressFile = [NSString new];
        if (childArray.count > 5) {
            compressFile = [TOPDocumentHelper top_saveCompressPDFImage:model.imagePath savePath:savePath maxCompression:1.0];
        }else{
            compressFile = [TOPDocumentHelper top_saveCompressImage:model.imagePath savePath:savePath maxCompression:1.0];
        }
        if (compressFile.length) {
            NSURL * file = [NSURL fileURLWithPath:compressFile];
            [shareArray addObject:file];
        }
    }
    return shareArray;
}
#pragma mark -- ShareText
- (void)top_shareText{
    NSMutableArray * selectArray = [NSMutableArray new];
    NSMutableArray * ocrArray = [NSMutableArray new];
    for (DocumentModel * model in self.dataArray) {
        [selectArray addObject:model];
        if ([TOPWHCFileManager top_isExistsAtPath:model.ocrPath]) {
            [ocrArray addObject:model];
        }
    }
    
    if (selectArray.count == ocrArray.count&&selectArray.count) {
        TOPPhotoShowTextAgainVC * ocrTextVC = [TOPPhotoShowTextAgainVC new];
        ocrTextVC.dataArray = ocrArray;
        ocrTextVC.backType = TOPPhotoShowTextAgainVCBackTypePopRoot;
        ocrTextVC.dataType = TOPOCRDataTypeSingleDocument;
        [self.navigationController pushViewController:ocrTextVC animated:YES];
    }else{
        TOPPhotoShowOCRVC * ocrVC = [TOPPhotoShowOCRVC new];
        ocrVC.currentIndex = 0;
        ocrVC.dataArray = selectArray;
        ocrVC.backType = TOPPhotoShowTextAgainVCBackTypePopRoot;
        ocrVC.ocrAgain = TOPPhotoShowOCRVCAgainTypeOCRNot;
        ocrVC.finishType = TOPPhotoShowOCRVCAgainFinishNot;
        ocrVC.dataType = TOPOCRDataTypeSingleDocument;
        [self.navigationController pushViewController:ocrVC animated:YES];
    }
}
#pragma mark -- 预判图片数量是否过多
- (void)top_prejudgeImages {
    static NSInteger maxNum = 30;
    NSMutableArray *imgArray = [NSMutableArray new];
    for (DocumentModel * model in self.dataArray) {
        [imgArray addObject:model.imagePath];
    }
    if (imgArray.count >= maxNum) {
        [self top_phoneMemoryAlert];
    } else {
        [self top_drawLongImagePreview];
    }
}
- (void)top_phoneMemoryAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_note", @"")
                                                                   message:NSLocalizedString(@"topscan_phonememoryalert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_continueshare", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [self top_drawLongImagePreview];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark -- 合成长图并预览
- (void)top_drawLongImagePreview {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * imgArray = [NSMutableArray new];
        for (DocumentModel * model in self.dataArray) {
            UIImage * img = [UIImage imageWithContentsOfFile:model.imagePath];
            if (img) {
                [imgArray addObject:img];
            }
        }
       
        UIImage * resultImg = [TOPPictureProcessTool top_mergedImages:imgArray];
        NSString *showPath = [TOPDocumentHelper top_longImageFileString];
        [TOPWHCFileManager top_removeItemAtPath:showPath];
        [TOPDocumentHelper top_saveImage:resultImg atPath:showPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            TOPShowLongImageViewController * longImgVC = [TOPShowLongImageViewController new];
            longImgVC.showPath = showPath;
            longImgVC.pathString = self.pathString;
            longImgVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:longImgVC animated:YES];
        });
    });
}
#pragma mark -- 分享压缩文件
- (void)top_shareZipFile:(NSMutableArray *)shareArray {
    if ([self top_needCreateZip:shareArray]) {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *shareFiles = [self top_createZipWithShareFile:shareArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self top_showAcivityVC:shareFiles];
            });
        });
    } else {
        [self top_showAcivityVC:shareArray];
    }
}
#pragma mark -- 判断是否需要压缩
- (BOOL)top_needCreateZip:(NSMutableArray *)shareArray {
    BOOL createZip = NO;
    if (self.pdfType == 0) {
        if (shareArray.count > 1) {
            createZip = YES;
        }
    } else {
        if (shareArray.count > 9) {
            createZip = YES;
        }
    }
    return createZip;
}
#pragma mark -- 压缩需要分享的文件
- (NSMutableArray *)top_createZipWithShareFile:(NSMutableArray *)shareArray {
    NSMutableArray *shareFiles = @[].mutableCopy;
    NSString *zipFile = [TOPDocumentHelper top_getBelongTemporaryPathString:NSLocalizedString(@"topscan_sharezipname", @"")];
    NSMutableArray *zipPaths = @[].mutableCopy;
    for (NSURL *url in shareArray) {
        [zipPaths addObject:url.path];
    }
    BOOL successed = [SSZipArchive createZipFileAtPath:zipFile withFilesAtPaths:zipPaths];
    if (successed) {
        [shareFiles addObject:[NSURL fileURLWithPath:zipFile]];
    }
    return shareFiles;
}
#pragma mark -- 弹出系统分享视图
- (void)top_showAcivityVC:(NSArray *)shareItems {
    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:shareItems applicationActivities:nil];
    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    activiVC.excludedActivityTypes = excludedActivityTypes;
    if (IS_IPAD) {
        activiVC.popoverPresentationController.sourceView = self.view;
        activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController: activiVC animated:YES completion:nil];
}
- (void)top_BottomViewWithEmail:(NSMutableArray *)emailArray{
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        return;
    }
    
    if (![mailClass canSendMail]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_bind", @"")
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
    if (self.emailType == 1) {
        [self top_ShowMailCompose:self.emailModel.toEmail array:emailArray];
    }
}

- (void)top_ShowMailCompose:(NSString *)email array:(NSMutableArray *)emailArray{
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
                NSURL * imgPath = emailArray[i];
                NSString * photoName = [TOPDocumentHelper top_decodeFromPercentEscapeString:[imgPath.absoluteString componentsSeparatedByString:@"/"].lastObject];
                if (imgData) {
                    [mailCompose addAttachmentData:imgData mimeType:@"image" fileName:photoName];
                }
            }
            [self presentViewController:mailCompose animated:YES completion:^{
                
            }];
        }
        
        if (self.pdfType == 0) {
            for (int i = 0; i<emailArray.count; i++) {
                NSData * pdfData = [NSData dataWithContentsOfURL:emailArray[i]];
                NSURL * pdfPath = emailArray[i];
                NSString * photoName = [TOPDocumentHelper top_decodeFromPercentEscapeString:[pdfPath.absoluteString componentsSeparatedByString:@"/"].lastObject];
                if (pdfData) {
                    [mailCompose addAttachmentData:pdfData mimeType:@"application/pdf" fileName:photoName];
                }
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
#pragma mark -- 从图库导入
- (void)top_MoreViewImportPic {
    [FIRAnalytics logEventWithName:@"photoReEditFinish_ImportPic" parameters:nil];
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:NSIntegerMax columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowTakeVideo = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO;
    
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
            [SVProgressHUD dismiss];
            if (assets.count == 1) {
                [weakSelf top_CreateFolderWithSelectPhotos:imagePaths];
            } else if (assets.count > 1) {
                [weakSelf top_OnlyToSendData:imagePaths];
            }
        });
    }];
}

#pragma mark -TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
    [TOPWHCFileManager top_createDirectoryAtPath:TOPCamerPic_Path];
    [TOPWHCFileManager top_removeItemAtPath:TOPAccidentCamerPic_Path];
    [TOPWHCFileManager top_createDirectoryAtPath:TOPAccidentCamerPic_Path];
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
                        [FIRAnalytics logEventWithName:@"HomeView_noJPG" parameters:nil];
                        NSArray * items = [TOPDocumentHelper top_sortItemAthPath:TOPCamerPic_Path];
                        if (items.count) {
                            [FIRAnalytics logEventWithName:@"HomeView_Item" parameters:@{@"content": items[0]}];
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
#pragma mark -- 当前文档中图片名下标最大值 1001、1002
- (NSInteger)top_maxPicNumIndex {
    NSArray *imageArray = [TOPDocumentHelper top_getJPEGFile:self.pathString];
    if (imageArray.count) {
        NSMutableArray *temp = @[].mutableCopy;
        for (NSString *picName in imageArray) {
            NSString *numberIndex = [picName substringFromIndex:14];
            [temp addObject:numberIndex];
        }
        NSInteger maxNum = [[temp valueForKeyPath:@"@max.integerValue"] integerValue];
        if (maxNum >= 10000) {
            maxNum = maxNum - 10000;
        } else if (maxNum >= 1000) {
            maxNum = maxNum - 1000;
        }
        return maxNum + 1;
    }
    return 0;
}
- (void)top_savePicData:(NSData *)data index:(NSInteger)i{
    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:(i + [self top_maxPicNumIndex])],TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [TOPCamerPic_Path stringByAppendingPathComponent:fileName];
    NSString *accidentFileEndPath = [TOPAccidentCamerPic_Path stringByAppendingPathComponent:fileName];
    [data writeToFile:accidentFileEndPath atomically:YES];

    BOOL result = [data writeToFile:fileEndPath atomically:YES];
    if (!result) {
        if (fileEndPath == nil) {
            fileEndPath = @"";
        }
        [FIRAnalytics logEventWithName:@"HomeView_pathError" parameters:@{@"path": fileEndPath}];
        [FIRAnalytics logEventWithName:@"HomeView_contentError" parameters:@{@"content": @(data.length)}];
    }
}
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 从相册选择图片 多张图片时
- (void)top_OnlyToSendData:(NSArray *)assets{
    if (assets.count) {
        [TOPScanerShare shared].isPush = YES;
        TOPCamerBatchViewController * scamerBatch = [TOPCamerBatchViewController new];
        scamerBatch.pathString = self.pathString;
        scamerBatch.fileType = TOPShowDocumentCameraType;
        scamerBatch.backType = TOPHomeChildViewControllerBackTypeDismiss;
        scamerBatch.dataArray = self.dataArray;
        
        TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:scamerBatch];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark -- 从相册选择图片 只有一张图片时
- (void)top_CreateFolderWithSelectPhotos:(NSArray *)photos{
    if (photos.count) {
        [TOPScanerShare shared].isPush = YES;
        [FIRAnalytics logEventWithName:@"photoReEditFinish_CreateFolderPhotos" parameters:@{@"photos":photos}];
        TOPSingleBatchViewController * batch = [TOPSingleBatchViewController new];
        batch.pathString = self.pathString;
        batch.batchArray = [photos mutableCopy];
        batch.dataArray = self.dataArray;
        batch.fileType = TOPShowDocumentCameraType;
        batch.backType = TOPHomeChildViewControllerBackTypeDismiss;
        TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:batch];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}
- (void)top_nativeAdConditions{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    [FIRAnalytics logEventWithName:@"ATTrackingManagerAuthorized" parameters:nil];
                }else{
                    [FIRAnalytics logEventWithName:@"ATTrackingManagerDenied" parameters:nil];
                }
                if (![TOPPermissionManager top_enableByAdvertising]) {
                    [self top_getNativeAd];
                }
            });
        }];
    } else {
        if (![TOPPermissionManager top_enableByAdvertising]) {
            [self top_getNativeAd];
        }
    }
}
#pragma mark -- 原生广告
- (void)top_getNativeAd{
    NSString * adID = @"ca-app-pub-3940256099942544/3986624511";
    adID = [TOPDocumentHelper top_nativeAdID][4];
    GADMultipleAdsAdLoaderOptions *multipleAdsOptions = [[GADMultipleAdsAdLoaderOptions alloc] init];
    multipleAdsOptions.numberOfAds = 1;
    
    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
    videoOptions.startMuted = YES ;
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:adID
                                       rootViewController:self
                                                  adTypes:@[kGADAdLoaderAdTypeNative]
                                                  options:@[multipleAdsOptions,videoOptions]];
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:[GADRequest request]];
}
- (void)adLoaderDidFinishLoading:(GADAdLoader *) adLoader {
    // The adLoader has finished loading ads, and a new request can be sent.
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error{
}
#pragma mark -- 获取原生广告成功
- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    [FIRAnalytics logEventWithName:@"photoReEditFinish_nativeDidReceiveAd" parameters:nil];
    self.adModel = nativeAd;
    [self top_showNativeAdView];
}
#pragma mark -- 展示广告
- (void)top_showNativeAdView{
    [self.view addSubview:self.adView];
    self.adView.nativeAd = self.adModel;
    CGFloat adH;
    if (IS_IPAD) {
        adH = 280;
    }else{
        if (TOPBottomSafeHeight>0) {
            adH = 280;
        }else{
            adH = 200;
        }
    }
   
    [self.adView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(adH);
    }];
}

- (void)top_ClickToChangeFolderName{
    WS(weakSelf);
    TopEditFolderAndDocNameVC * editName = [TopEditFolderAndDocNameVC new];
    editName.top_clickToSendString = ^(NSString * _Nonnull nameString) {
        [weakSelf top_ClickToChangeFolderNameAction:nameString];
    };
    editName.defaultString = [TOPWHCFileManager top_fileNameAtPath:self.pathString suffix:YES];
    editName.editType = TopFileNameEditTypeChangeDocName;
    editName.picName = @"top_changedoc";
    editName.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editName animated:YES];
}
- (void)top_ClickToChangeFolderNameAction:(NSString *)name{
    if ([name isEqualToString:self.title]) {
        return;
    }

    NSString *filePath = [[TOPWHCFileManager top_directoryAtPath:self.pathString] stringByAppendingPathComponent:name];
    if ([TOPWHCFileManager top_isExistsAtPath:filePath]) {//重名
        [self top_FolderAlreadyAlert];
        return;
    }
    if (name.length == 0) {
        return;
    }
    //把文件移到新目录下
    [TOPDocumentHelper top_moveFileItemsAtPath:self.pathString toNewFileAtPath:filePath];
    [TOPEditDBDataHandler top_editDocumentName:name withId:self.docModel.docId];
    self.docModel.path = filePath;
    self.docModel.name = name;
    [self.showBtn setTitle:name forState:UIControlStateNormal];
    self.title = name;
    self.pathString = filePath;
    [self top_LoadSanBoxData];
}
- (void)top_FolderAlreadyAlert{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_hasfolder", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)top_setBarItemView{
    self.title = [TOPWHCFileManager top_fileNameAtPath:self.pathString suffix:YES];
    TOPImageTitleButton * showBtn = [[TOPImageTitleButton alloc]initWithStyle:ETitleLeftImageRightCenter];
    showBtn.padding = CGSizeMake(2, 2);
    showBtn.frame = CGRectMake(0, 0, TOPScreenWidth-100, 44);
    showBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    showBtn.titleLabel.minimumScaleFactor = 0.8;
    showBtn.titleLabel.numberOfLines = 1;
    [showBtn setTitle:self.title forState:UIControlStateNormal];
    [showBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:[UIColor blackColor]] forState:UIControlStateNormal];
    [showBtn setImage:[UIImage imageNamed:@"top_changeFolder"] forState:UIControlStateNormal];
    [showBtn addTarget:self action:@selector(top_ClickToChangeFolderName) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = showBtn;
    self.showBtn = showBtn;
    
    TOPImageTitleButtonStyle titleButtonStyle;
    if (isRTL()) {
        titleButtonStyle = EImageLeftTitleRightCenter;
    }else{
        titleButtonStyle = EImageLeftTitleRightLeft;
    }
    TOPImageTitleButton * leftBtn = [[TOPImageTitleButton alloc] initWithStyle:(titleButtonStyle)];
    leftBtn.backgroundColor = [UIColor clearColor];
    leftBtn.tag = 1000+1;
    leftBtn.frame = CGRectMake(0, 0, 44, 60);
    [leftBtn setImage:[UIImage imageNamed:@"top_backhomeicon"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    TOPImageTitleButton * rightBtn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
    rightBtn.backgroundColor = [UIColor clearColor];
    rightBtn.tag = 1000+2;
    rightBtn.frame = CGRectMake(0, 0, 35, 60);
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightBtn setTitle:NSLocalizedString(@"topscan_tagsdone", @"") forState:UIControlStateNormal];
    [rightBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}
- (void)top_setMainView{
    NSArray * iconArray = @[@"top_photo_reEdit_camera",@"top_photo_reEdit_import",@"top_photo_reEdit_pdf",@"top_photo_reEdit_email",@"top_photo_reEdit_share",@"top_photo_reEdit_more"];
    NSArray * titleArray = @[NSLocalizedString(@"topscan_takephoto", @""),
                             NSLocalizedString(@"topscan_importpic", @""),
                             NSLocalizedString(@"topscan_editpdf", @""),
                             NSLocalizedString(@"topscan_email", @""),
                             NSLocalizedString(@"topscan_share", @""),
                             NSLocalizedString(@"topscan_more", @"")];
    WS(weakSelf);
    TOPPhotoReEditView * showView = [[TOPPhotoReEditView alloc]initWithFrame:CGRectMake(0, 10, TOPScreenWidth, 300) iconArray:iconArray titleArray:titleArray];
    showView.dataArray = self.dataArray;
    showView.top_clickBtnBlock = ^(NSInteger tag) {
        [weakSelf top_FunctionTag:tag];
    };
    [self.view addSubview:showView];
    self.showView = showView;
    [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(10);
    }];
}
#pragma mark -- 设置约束
- (void)top_markupCoverMask{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}
#pragma mark -- lazy
- (TOPAddFolderView *)addFolderView{
    if (!_addFolderView) {
        WS(weakSelf);
        _addFolderView = [[TOPAddFolderView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolder_W)];
        _addFolderView.top_clickToSendString = ^(NSString * _Nonnull editString) {
            [weakSelf top_ClickToChangeFolderNameAction:editString];
            [weakSelf top_ClickToHide];
        };
        
        _addFolderView.top_clickToHide = ^{
            [weakSelf top_ClickToHide];
        };
    }
    return _addFolderView;
}
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_ClickToHide)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}
- (TOPTransferNativeAdView *)adView{
    if (!_adView) {
        _adView = [[TOPTransferNativeAdView alloc]initWithFrame:CGRectZero];
    }
    return _adView;
}
- (NSArray *)functionType{
    NSArray * tempArray = @[@(TOPPhotoReEditFinishFunctionTypeCamera),@(TOPPhotoReEditFinishFunctionTypeImport),@(TOPPhotoReEditFinishFunctionTypePDF),@(TOPPhotoReEditFinishFunctionTypeEmail),@(TOPPhotoReEditFinishFunctionTypeShare),@(TOPPhotoReEditFinishFunctionTypeMore),@(TOPPhotoReEditFinishFunctionTypeDocDetail)];
    return tempArray;
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}
@end
