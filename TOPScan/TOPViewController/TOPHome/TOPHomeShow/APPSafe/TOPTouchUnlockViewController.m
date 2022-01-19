#define ShareAppGroup @"group.tongsoft.simple.scanner"
#define sharePdfType @"com.adobe.pdf"
#define shareImgType @"public.image"
#import "TOPFileTargetListViewController.h"
#import "TOPBaseNavViewController.h"
#import "TOPHomeViewController.h"
#import "TOPTouchUnlockViewController.h"
#import "TOPTouchIDRecognitionManager.h"
#import "TOPAppSafeShowPasswordVC.h"
#import "TOPEditPDFViewController.h"
#import "TOPActionExtensionHandler.h"
#import "TOPPhotoShowOCRVC.h"
#import "TOPNextFolderViewController.h"
#import "TOPHomeChildViewController.h"
@interface TOPTouchUnlockViewController ()
@property (weak, nonatomic) IBOutlet UILabel *unlockTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *validationBut;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *subTitleBut;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (nonatomic,assign ) TOPLAContextSupportType currentDeviceType;
@property (nonatomic ,assign)NSInteger count;
@property (nonatomic ,strong)NSMutableArray * shareArray;
@property (nonatomic ,assign)BOOL isSkip;
@property (nonatomic ,strong)NSMutableArray * skipArray;
@property (nonatomic ,assign)NSInteger pdfCount;
@property (nonatomic ,strong)TOPFileTargetListViewController * fileVC;

@end

@implementation TOPTouchUnlockViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.closeButton.hidden = NO;
    self.unlockTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    self.navigationController.navigationBarHidden = YES;

    [self top_getCurrentDeviceTouchOrFaceStates];

    switch (self.systomUnlockType) {
        case TOPAppSetTouchAFaceStateLocalInput:
        {
            self.closeButton.hidden = YES;
        }
            break;
        default:
            break;
    }
  
    switch (self.unlockType) {
        case TOPAppSetSafeUnlockTypeFaceID:{
          
            self.unlockTitleLabel.text = @"Face ID";
            [self.validationBut setImage:[UIImage imageNamed:@"top_face_ID"] forState:UIControlStateNormal];
        }
            break;
        case TOPAppSetSafeUnlockTypeTouchID:
        {
            self.unlockTitleLabel.text = @"Touch";
            [self.validationBut setImage:[UIImage imageNamed:@"top_touch_id"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (NSMutableArray *)shareArray{
    if (!_shareArray) {
        _shareArray = [NSMutableArray new];
    }
    return _shareArray;
}
- (NSMutableArray *)skipArray{
    if (!_skipArray) {
        _skipArray = [NSMutableArray new];
    }
    return _skipArray;
}

- (void)top_getCurrentDeviceTouchOrFaceStates
{
    self.currentDeviceType =   [TOPDocumentHelper top_getBiometryType];
    switch (self.currentDeviceType) {
        case TOPLAContextSupportTypeNone:
        {
        }
            break;
        case TOPLAContextSupportTypeTouchIDNotEnrolled:
        {
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_touchidnotenrolled", @"")];
            self.subTitleBut.hidden = NO;
            self.subTitleLabel.hidden = NO;
            self.subTitleLabel.text = NSLocalizedString(@"topscan_opensysset", @"");
        }
            break;
        case TOPLAContextSupportTypeFaceIDNotEnrolled:
        {
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_faceidnotenrolled", @"")];
            self.subTitleBut.hidden = NO;
            self.subTitleLabel.hidden = NO;
            self.subTitleLabel.text = NSLocalizedString(@"topscan_opensysset", @"");
        }
        case TOPLAContextSupportTypeFaceID:
        {
            self.subTitleBut.hidden = NO;
            self.subTitleLabel.hidden = NO;
            self.subTitleLabel.text = NSLocalizedString(@"topscan_againvafaceid", @"");
            [self top_startValidationTouch];
        }
            break;
        case TOPLAContextSupportTypeTouchID:
        {
            self.subTitleBut.hidden = NO;
            self.subTitleLabel.hidden = NO;
            self.subTitleLabel.text = NSLocalizedString(@"topscan_againvatouchid", @"");
            [self top_startValidationTouch];
        }
            break;
            
        default:
            break;
    }
}

- (void)top_startValidationTouch
{
    TOPTouchIDRecognitionManager *touchManger = [[TOPTouchIDRecognitionManager alloc] init];
    [touchManger loadAuthentication:self.unlockType];
    touchManger.top_touchIDBlock = ^(NSDictionary * _Nonnull callBackDic) {
        NSInteger code = [callBackDic[@"code"] integerValue];
        if (code == 1002) {
            switch (self.systomUnlockType) {
                case TOPAppSetTouchAFaceStateLocalInput:
                {
                    [TOPScanerShare top_writeAppLockState:YES];
                    NSURL * url = [TOPScanerShare top_isShareExtension];
                    if (url != nil && url.absoluteString.length>0) {
                        if ([url.absoluteString hasSuffix:@"PreviewPDF"]) {
                            [FIRAnalytics logEventWithName:@"Action_CreatePDF" parameters:nil];
                            [self top_actionExtensionDataHandle];
                        } else if ([url.absoluteString hasSuffix:@"OCR"]) {
                            [FIRAnalytics logEventWithName:@"Action_OCR" parameters:nil];
                            [self top_ocrActionDataHandle];
                        } else if ([url.absoluteString rangeOfString:@"ImportPic_"].location != NSNotFound) {
                            [FIRAnalytics logEventWithName:@"Action_Import" parameters:nil];
                            NSString *tempUrlStr = [url.absoluteString stringByReplacingOccurrencesOfString:@"ImportPic_" withString:@""];
                            url = [NSURL URLWithString:tempUrlStr];
                            [TOPScanerShare top_writeIsShareExtension:url];
                            [self top_dealShareExtensionData];
                        }  else {
                            [FIRAnalytics logEventWithName:@"Share_Import" parameters:nil];
                            [self top_dealShareExtensionData];
                        }
                    }else{
                        [self top_dismissAndDealData];
                    }
                }
                    break;
                case TOPAppSetTouchAFaceStateOpen:
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TOP_TRAppSafeStates];
                    switch (self.unlockType) {
                        case TOPAppSetSafeUnlockTypeTouchID:
                            [[NSUserDefaults standardUserDefaults] setInteger:TOPAppSetSafeUnlockTypeTouchID forKey:TOP_TRAppSafeUnLockType];
                            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:TOP_TRAppSafeCurrentPWDKey];
                            
                            break;
                        case TOPAppSetSafeUnlockTypeFaceID:
                            [[NSUserDefaults standardUserDefaults] setInteger:TOPAppSetSafeUnlockTypeFaceID forKey:TOP_TRAppSafeUnLockType];
                            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:TOP_TRAppSafeCurrentPWDKey];
                            
                            break;
                        default:
                            break;
                    }
                    [self top_dismissAndDealData];
                }
                    break;
                case TOPAppSetTouchAFaceStateClose:
                {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TOP_TRAppSafeStates];
                    switch (self.unlockType) {
                        case TOPAppSetSafeUnlockTypeTouchID:
                            [[NSUserDefaults standardUserDefaults] setInteger:TOPAppSetSafeUnlockTypeTouchID forKey:TOP_TRAppSafeUnLockType];
                            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:TOP_TRAppSafeCurrentPWDKey];
                            
                            break;
                        case TOPAppSetSafeUnlockTypeFaceID:
                            [[NSUserDefaults standardUserDefaults] setInteger:TOPAppSetSafeUnlockTypeFaceID forKey:TOP_TRAppSafeUnLockType];
                            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:TOP_TRAppSafeCurrentPWDKey];
                            
                            break;
                        default:
                            break;
                    }
                    [self top_dismissAndDealData];
                }
                    break;
                case TOPAppSetTouchAFaceStateChangePassWord:
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TOP_TRAppSafeStates];
                    [[NSUserDefaults standardUserDefaults] setInteger:TOPAppSetSafeUnlockTypePwd forKey:TOP_TRAppSafeUnLockType];
                    [self top_dismissAndDealData];
                }
                    break;
                case TOPAppSetTouchAFaceStateChangeCreatNewPassWord:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        TOPAppSafeShowPasswordVC *setpwdVC = [[TOPAppSafeShowPasswordVC alloc] init];
                        setpwdVC.setSafePsdState = TOPAppSetSafePasswordStateFirstSetSafe;
                        setpwdVC.hidesBottomBarWhenPushed = YES;

                        [self.navigationController pushViewController:setpwdVC animated:YES];
                    });
                    return;
                }
                    break;
                    
                default:
                    break;
            }
        }
    };
}

- (void)top_dismissAndDealData{
    WeakSelf(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
        [TOPScanerShare shared].isFirstShow = YES;
        [ws dismissViewControllerAnimated:YES completion:^{
        }];
    });
}
- (IBAction)validationClick:(id)sender {
    [self top_getCurrentDeviceTouchOrFaceStates];
}

- (IBAction)openSystomSetingClick:(UIButton *)sender {
    self.currentDeviceType =   [TOPDocumentHelper top_getBiometryType];
    if (self.currentDeviceType == TOPLAContextSupportTypeTouchIDNotEnrolled || self.currentDeviceType == TOPLAContextSupportTypeFaceIDNotEnrolled  ) {
        switch (self.unlockType) {
            case TOPAppSetSafeUnlockTypeFaceID:
            case TOPAppSetSafeUnlockTypeTouchID:
            {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url])
                {
                    [[UIApplication sharedApplication] openURL:url options:@{}  completionHandler:nil];
                }
            }
                break;
            default:
                break;
        }
    }
}
- (IBAction)closeClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 跳转到OCR识别界面
- (void)top_jumpToOcrVC:(NSMutableArray *)dataArr {
    TOPPhotoShowOCRVC * ocrVC = [TOPPhotoShowOCRVC new];
    ocrVC.currentIndex = 0;
    ocrVC.dataArray = dataArr;
    ocrVC.backType = TOPPhotoShowTextAgainVCBackTypePopRoot;
    ocrVC.ocrAgain = TOPPhotoShowOCRVCAgainTypeOCRNot;
    ocrVC.finishType = TOPPhotoShowOCRVCAgainFinishNot;
    ocrVC.dataType = TOPOCRDataTypeSingleDocument;
    UIViewController *rootVC = [TOPDocumentHelper top_appRootViewController];
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        TOPBaseNavViewController *nav = (TOPBaseNavViewController *)rootVC;
        [nav pushViewController:ocrVC animated:YES];
    } else {
        TOPBaseNavViewController *nav = [[TOPBaseNavViewController alloc] initWithRootViewController:rootVC];
        [nav pushViewController:ocrVC animated:YES];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -- OCR Action Extension 数据处理
- (void)top_ocrActionDataHandle {
    [TOPActionExtensionHandler top_parsingDataBuildModelsSuccess:^(NSMutableArray * _Nonnull dataArr, NSString * _Nonnull filePath) {
        [self top_jumpToOcrVC:dataArr];
    }];
}
#pragma mark -- PDF actionExtension分享数据的处理
- (void)top_actionExtensionDataHandle {
    [TOPActionExtensionHandler top_parsingDataSuccess:^(NSMutableArray * _Nonnull dataArr, NSString * _Nonnull filePath) {
        [self top_jumpToEditPDFVC:dataArr atPath:filePath];
    }];
}
#pragma mark -- 跳转PDF编辑预览
- (void)top_jumpToEditPDFVC:(NSArray *)imageArr atPath:(NSString *)filePath {
    TOPEditPDFViewController * pdfVC = [[TOPEditPDFViewController alloc] init];
    pdfVC.docModel = [TOPDBDataHandler top_addNewDocModel:filePath];
    pdfVC.filePath = filePath;
    pdfVC.imagePathArr = imageArr;
    UIViewController *rootVC = [TOPDocumentHelper top_appRootViewController];
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        TOPBaseNavViewController *nav = (TOPBaseNavViewController *)rootVC;
        [nav pushViewController:pdfVC animated:YES];
    } else {
        TOPBaseNavViewController *nav = [[TOPBaseNavViewController alloc] initWithRootViewController:rootVC];
        [nav pushViewController:pdfVC animated:YES];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -- shareExtension分享数据的处理
- (void)top_dealShareExtensionData{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL * url = [TOPScanerShare top_isShareExtension];
        self.isSkip = NO;
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString * shareTypessssss = [[url.absoluteString componentsSeparatedByString:@"-"] lastObject];
            NSURL * groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:ShareAppGroup];
            NSError * error;
            NSError * error1;
            NSArray * folderList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[groupURL path] error:&error];

            self.count = 0;
            NSMutableArray * dataArray = [NSMutableArray array];
            for (NSString  * tempstr in folderList) {
                if ([tempstr.lowercaseString hasSuffix:@".jpg"]|| [tempstr.lowercaseString hasSuffix:@".png"] || [tempstr.lowercaseString hasSuffix:@".jpeg"]||[tempstr.lowercaseString hasSuffix:@".pdf"]||[tempstr.lowercaseString hasSuffix:@".PDF"]) {
                    NSString * newFilePath = [[groupURL path] stringByAppendingPathComponent:tempstr];
                    NSData * getData = [NSData dataWithContentsOfFile:newFilePath];
                    if (getData) {
                        if ([shareTypessssss isEqualToString:shareImgType]) {
                            [dataArray addObject:getData];
                        }
                        if ([shareTypessssss isEqualToString:sharePdfType]) {
                            NSString* encodedString = [TOPDocumentHelper top_decodeFromPercentEscapeString:tempstr];
                            NSString* fileName = [NSString new];
                            if ([tempstr.lowercaseString hasSuffix:@".pdf"]) {
                                fileName = [[encodedString componentsSeparatedByString:@".pdf"] firstObject];
                            }
                            if ([tempstr.lowercaseString hasSuffix:@".PDF"]) {
                                fileName = [[encodedString componentsSeparatedByString:@".PDF"] firstObject];
                            }
                            NSDictionary * dic = @{fileName:getData};
                            [dataArray addObject:dic];
                        }
                    }
                    [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:&error1];
                }
            }
            self.shareArray = dataArray;
            self.pdfCount = dataArray.count;
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self top_creatRootVC:[dataArray copy] shareType:shareTypessssss];
            });
        });
    });
}

- (void)top_creatRootVC:(NSArray *)array shareType:(NSString *)shareType{
        TOPFileTargetListViewController *targetListVC = [[TOPFileTargetListViewController alloc] init];
        targetListVC.currentFilePath = [TOPDocumentHelper top_getDocumentsPathString];
        targetListVC.fileHandleType = TOPFileHandleTypeCopy;
        targetListVC.fileTargetType = TOPFileTargetTypeFolder;
        self.fileVC = targetListVC;
        WS(weakSelf);
        targetListVC.top_callBackFilePathBlock = ^(NSString * _Nonnull path) {
            [TOPScanerShare shared].isReceive = NO;
            [TOPDocumentHelper top_initializationFolder];
            if ([shareType isEqualToString:shareImgType]) {
                [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingjpg", @"")]];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:path];
                    for (int i = 0; i<array.count; i++) {
                        if (array[i]) {
                            UIImage * img = [UIImage imageWithData:array[i]];
                            NSString *imgName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
                            NSString *oriName = [NSString stringWithFormat:@"%@%@%@%@",TOPRSimpleScanOriginalString,[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
                            NSString *fileEndPath =  [endPath stringByAppendingPathComponent:imgName];
                            NSString *oriEndPath = [endPath stringByAppendingPathComponent:oriName];
                            NSLog(@"fileEndPath==%@",fileEndPath);
                            [UIImageJPEGRepresentation(img, TOP_TRPicScale) writeToFile:fileEndPath atomically:YES];
                            [UIImageJPEGRepresentation(img, TOP_TRPicScale) writeToFile:oriEndPath atomically:YES];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                CGFloat myProgress = ((i+1)*10.0)/(array.count * 10.0);
                                [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingjpg", @"")]];
                            });
                        }
                    }
                    [TOPEditDBDataHandler top_addDocumentAtFolder:endPath WithParentId:[TOPFileDataManager shareInstance].fileModel.docId];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [TOPScanerShare shared].isReceive = YES;
                        [SVProgressHUD dismiss];
                        [[TOPProgressStripeView shareInstance]dismiss];
                        [weakSelf top_getRootVC];
                    });
                });
            }

            if ([shareType isEqualToString:sharePdfType]) {
                if (weakSelf.pdfCount>1) {
                    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...(%@-%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(weakSelf.count+1),@(weakSelf.pdfCount)]];
                }else{
                    if (weakSelf.pdfCount>0) {
                        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
                    }else{
                        [TOPScanerShare top_writeIsShareExtension:[NSURL new]];
                    }
                }
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    AutoRelease_for (NSDictionary * tempDic in array)  {
                        NSData * data = [NSData new];
                        NSString * docName = [NSString new];
                        if (tempDic.allValues.count>0) {
                            data = tempDic.allValues[0];
                        }
                        if (tempDic.allKeys.count>0) {
                            docName = tempDic.allKeys[0];
                        }
                        if (data) {
                            NSString * docPath = [TOPDocumentHelper top_createNewDocument:docName atFolderPath:path];
                            [weakSelf top_breakupPDF:data shareType:docPath dispatch:semaphore alertTitle:NSLocalizedString(@"topscan_decryption", @"") alertMessage:@"pdf"];
                        }
                    }
                });
            }
        };
        
        targetListVC.top_clickCancelBlock = ^{
            [TOPScanerShare top_writeIsShareExtension:[NSURL new]];
        };
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            targetListVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:targetListVC animated:YES];
        });
}

- (void)top_breakupPDF:(NSData *)data shareType:(NSString *)shareType dispatch:(dispatch_semaphore_t)semaphore alertTitle:(NSString *)title alertMessage:(NSString *)message{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data );
    WS(weakSelf);
    CGPDFDocumentRef fromPDFDoc =  CGPDFDocumentCreateWithProvider(provider);
    if (fromPDFDoc == NULL) {
    }else{
        if (CGPDFDocumentIsEncrypted (fromPDFDoc)) {
            if (!CGPDFDocumentUnlockWithPassword (fromPDFDoc, "")) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TOPProgressStripeView shareInstance] dismiss];
                    UIAlertController *col = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                    __weak typeof(col) weakAlert = col;
                    
                    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        __strong typeof(weakAlert) strongAlert = weakAlert;
                        UITextField *  textField=   strongAlert.textFields.firstObject;
                        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        
                        if (textField.text != NULL && CGPDFDocumentUnlockWithPassword (fromPDFDoc, [textField.text UTF8String])) {
                            if (weakSelf.pdfCount>1) {
                                [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...(%@-%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(weakSelf.count+1),@(weakSelf.pdfCount)]];
                            }else{
                                [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
                            }
                            [weakSelf top_presentSendControllerMothodWith:fromPDFDoc password:textField.text shareType:shareType dispatch:(dispatch_semaphore_t)semaphore];
                        }else{
                            col.title = NSLocalizedString(@"topscan_error", @"");
                            col.message = NSLocalizedString(@"topscan_pdferror", @"");
                            col.textFields.firstObject.text = @"";
                            [self.fileVC presentViewController:col animated:YES completion:nil];
                            return;
                        }
                    }];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_skip", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            for (NSData * tempData in weakSelf.shareArray) {
                                CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)tempData );
                                CGPDFDocumentRef tempPDFDoc =  CGPDFDocumentCreateWithProvider(provider);
                                if (CGPDFDocumentUnlockWithPassword (tempPDFDoc, "")) {
                                    [weakSelf.skipArray addObject:tempData];
                                }
                                CGDataProviderRelease(provider);
                                CGPDFDocumentRelease(tempPDFDoc);
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                weakSelf.count++;
                                weakSelf.isSkip = YES;
                                if (weakSelf.count != weakSelf.pdfCount) {
                                    dispatch_semaphore_signal(semaphore);
                                }
                                if (weakSelf.count == weakSelf.pdfCount) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [weakSelf top_getRootVC];
                                    });
                                }
                            });
                        });
                    }];
                    [col addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        textField.placeholder = @"password";
                    }];
                    [col addAction:cancelAction];
                    [col addAction:confirmAction];
                    [self.fileVC presentViewController:col animated:YES completion:nil];
                });
            }
        }else{
            if (weakSelf.isSkip) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.pdfCount>1) {
                        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...(%@-%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(weakSelf.count+1),@(weakSelf.pdfCount)]];
                    }else{
                        if (weakSelf.pdfCount>0) {
                            [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
                        }
                    }
                });
            }
            [self top_presentSendControllerMothodWith:fromPDFDoc password:nil shareType:shareType dispatch:(dispatch_semaphore_t)semaphore];
            [self.shareArray removeObject:data];
        }
    }
    CGDataProviderRelease(provider);
}

- (void)top_presentSendControllerMothodWith:(CGPDFDocumentRef )fromPDFDoc password:(NSString *)passwordStr shareType:(NSString *)shareType dispatch:(dispatch_semaphore_t)semaphore
{
    WS(weakSelf);
    [TOPDocumentHelper top_getUIImageFromPDFPageWithpdfpathUrl:fromPDFDoc password:passwordStr docPath:shareType progress:^(CGFloat progressString) {
        if (weakSelf.pdfCount>1) {
            [[TOPProgressStripeView shareInstance] top_showProgress:progressString withStatus:[NSString stringWithFormat:@"%@...(%@-%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(weakSelf.count+1),@(weakSelf.pdfCount)]];
        }else{
            [[TOPProgressStripeView shareInstance] top_showProgress:progressString withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
        }
    } success:^(id  _Nonnull responseObj) {
        [TOPEditDBDataHandler top_addDocumentAtFolder:shareType WithParentId:[TOPFileDataManager shareInstance].fileModel.docId];
        weakSelf.count++;
        dispatch_semaphore_signal(semaphore);
        if (weakSelf.count == weakSelf.pdfCount) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [weakSelf top_getRootVC];
            });
        }
    }];
}

- (void)top_getRootVC{
    [self.fileVC dismissViewControllerAnimated:YES completion:nil];
    UIViewController * topVC = [self top_appRootViewController];
    [TOPScanerShare shared].isReceive = YES;
    TOPBaseNavViewController * baseVC = (TOPBaseNavViewController *)topVC;
    UIViewController * vc = baseVC.childViewControllers.lastObject;
    if ([vc isKindOfClass:[TOPHomeViewController class]]) {
        TOPHomeViewController * homVC = (TOPHomeViewController *)vc;
        [homVC top_saveSharePDFAndImgAndReload];
    }
    
    if ([vc isKindOfClass:[TOPNextFolderViewController class]]) {
        TOPNextFolderViewController * homVC = (TOPNextFolderViewController *)vc;
        [homVC top_CancleSelectAction];
        [homVC top_LoadSanBoxData:[TOPScanerShare top_sortType]];
    }
    
    if ([vc isKindOfClass:[TOPHomeChildViewController class]]) {
        TOPHomeChildViewController * homVC = (TOPHomeChildViewController *)vc;
        [homVC top_CancleSelectAction];
        [homVC top_LoadSanBoxData];
    }
}

- (UIViewController *)top_appRootViewController {
    UIViewController *RootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = RootVC;
    while (topVC.presentedViewController) {
        if ([topVC.presentedViewController isKindOfClass:[UIActivityViewController class]]) {
            break;
        }
        if ([topVC.presentedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController * temNav = (TOPBaseNavViewController *)topVC.presentedViewController;
            UIViewController * vc = temNav.childViewControllers.lastObject;
            if ([vc isKindOfClass:[TOPFileTargetListViewController class]]) {
                break;
            }
        }
        topVC = topVC.presentedViewController;
    }
    return topVC;
}
@end
