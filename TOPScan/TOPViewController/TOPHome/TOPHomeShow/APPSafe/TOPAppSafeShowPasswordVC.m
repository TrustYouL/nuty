#define ShareAppGroup @"group.tongsoft.simple.scanner"
#define sharePdfType @"com.adobe.pdf"
#define shareImgType @"public.image"
#import "TOPFileTargetListViewController.h"
#import "TOPBaseNavViewController.h"
#import "TOPHomeViewController.h"

#import "TOPAppSafeShowPasswordVC.h"
#import "TOPNumberCollectionViewCell.h"
#import "TOPClearPsdCollectionViewCell.h"
#import "TOPAppSafeEnterViewController.h"
#import "TOPTouchUnlockViewController.h"
#import "TOPCornerToast.h"
#import "TOPEditPDFViewController.h"
#import "TOPActionExtensionHandler.h"
#import "TOPPhotoShowOCRVC.h"

#import "TOPNextFolderViewController.h"
#import "TOPHomeChildViewController.h"

@interface TOPAppSafeShowPasswordVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *numberArrays;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) NSMutableArray *savePsdArrays;
@property (assign, nonatomic) BOOL isShowPsd;
@property (weak, nonatomic) IBOutlet UIView *oneSupView;
@property (weak, nonatomic) IBOutlet UILabel *oneDotView;
@property (weak, nonatomic) IBOutlet UILabel *onePwdContentLabel;
@property (weak, nonatomic) IBOutlet UIView *twoSupView;
@property (weak, nonatomic) IBOutlet UILabel *twoDotView;
@property (weak, nonatomic) IBOutlet UILabel *twoPwdContentLabel;
@property (weak, nonatomic) IBOutlet UIView *threeSupView;
@property (weak, nonatomic) IBOutlet UILabel *threeDotView;
@property (weak, nonatomic) IBOutlet UILabel *threePwdContentLabel;
@property (weak, nonatomic) IBOutlet UIView *fourSupView;
@property (weak, nonatomic) IBOutlet UILabel *fourDotView;
@property (weak, nonatomic) IBOutlet UILabel *fourPwdContentLabel;
@property (weak, nonatomic) IBOutlet UIView *supCollectionBackView;
@property (weak, nonatomic) IBOutlet UILabel *helpLab;
@property (weak, nonatomic) IBOutlet UILabel *helpLine;
@property (weak, nonatomic) IBOutlet UIButton *helpBtn;
@property (nonatomic,assign) NSInteger clearNumber;
@property (nonatomic ,assign)NSInteger count;
@property (nonatomic ,strong)NSMutableArray * shareArray;
@property (nonatomic ,assign)BOOL isSkip;
@property (nonatomic ,strong)NSMutableArray * skipArray;
@property (nonatomic ,assign)NSInteger pdfCount;
@property (nonatomic ,strong)TOPFileTargetListViewController * fileVC;

@end

@implementation TOPAppSafeShowPasswordVC
- (void)viewDidLoad {
    [super viewDidLoad];
    _clearNumber = 0;
    self.titleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    self.subTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    [self top_initUpdateUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *btnImg = isRTL() ? @"top_RTLbackItem" : @"top_backItem";
    [self.cancelButton setImage:[UIImage imageNamed:btnImg] forState:UIControlStateNormal];
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
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

- (void)top_initUpdateUI
{
    self.oneSupView.layer.cornerRadius = 2;
    self.oneSupView.layer.borderColor = TOPAPPGreenColor.CGColor;
    self.oneDotView.layer.cornerRadius = 5;
    self.oneSupView.layer.borderWidth = 1;
    
    self.twoSupView.layer.cornerRadius = 2;
    self.twoSupView.layer.borderColor = TOPAPPGreenColor.CGColor;
    self.twoDotView.layer.cornerRadius = 5;
    self.twoSupView.layer.borderWidth = 1;
    
    self.threeSupView.layer.cornerRadius = 2;
    self.threeSupView.layer.borderColor = TOPAPPGreenColor.CGColor;
    self.threeDotView.layer.cornerRadius = 5;
    self.threeSupView.layer.borderWidth = 1;
    
    self.fourSupView.layer.cornerRadius = 2;
    self.fourSupView.layer.borderColor = TOPAPPGreenColor.CGColor;
    self.fourDotView.layer.cornerRadius = 5;
    self.fourSupView.layer.borderWidth = 1;
    
    self.numberArrays = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"0",@"11"]];
    [self.supCollectionBackView addSubview:self.collectionView ];
    self.cancelButton.hidden = NO;
    switch (self.setSafePsdState ) {
            
        case TOPAppSetSafePasswordStateClosePwd:
        case TOPAppSetSafePasswordStateChangePwd:
        case TOPAppSetSafePasswordStateRestartPwd:
        case TOPAppSetSafePasswordStateChangeTouchIdType:
        case TOPAppSetSafePasswordStateChangeFaceIdType:
            
        {
            self.titleLabel.text = NSLocalizedString(@"topscan_verifypasscode", @"");
            self.subTitleLabel.text = NSLocalizedString(@"topscan_enterpwd",@"");
            self.helpBtn.hidden = NO;
            self.helpLab.hidden = NO;
            self.helpLine.hidden = NO;
            
        }
            break;
        case TOPAppSetSafePasswordStateSafeInLocalInput:
        {
            self.titleLabel.text = NSLocalizedString(@"topscan_verifypasscode", @"");
            self.subTitleLabel.text = NSLocalizedString(@"topscan_enterpwd"  ,@"");
            self.cancelButton.hidden = YES;
            self.helpBtn.hidden = NO;
            self.helpLab.hidden = NO;
            self.helpLine.hidden = NO;
        }
            break;
        case TOPAppSetSafePasswordStateFirstSetSafe:
        {
            self.titleLabel.text = NSLocalizedString(@"topscan_setpasscode", @"");
            self.subTitleLabel.text = NSLocalizedString(@"topscan_enternewpassword", @"");
            self.helpBtn.hidden = YES;
            self.helpLab.hidden = YES;
            self.helpLine.hidden = YES;
        }
            break;
        default:
            break;
    }
    
}

- (IBAction)lockpasswordClick:(UIButton *)sender {
    if (self.isShowPsd == YES) {
        self.isShowPsd = NO;
        [sender setImage:[UIImage imageNamed:@"top_appsafe_hide_lock"] forState:UIControlStateNormal];
    }else{
        [sender setImage:[UIImage imageNamed:@"top_appsafe_hide_hd"] forState:UIControlStateNormal];
        self.isShowPsd = YES;
    }
    if (self.savePsdArrays.count) {
        [self top_updateTopPasswordUIWith:self.savePsdArrays];
    }
}

- (IBAction)cancelClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)top_validationTapMothod
{
    switch (self.setSafePsdState ) {
        case TOPAppSetSafePasswordStateChangePwd:
        {
            NSString *currentPWD = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeCurrentPWDKey];
            __block NSString *firstPsd = @"";
            [self.savePsdArrays enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                firstPsd = [firstPsd stringByAppendingString:obj];
            }];
            if ([currentPWD isEqualToString:firstPsd]) {
                TOPAppSafeShowPasswordVC *safeEnterVC = [[TOPAppSafeShowPasswordVC alloc] init];
                safeEnterVC.setSafePsdState = TOPAppSetSafePasswordStateFirstSetSafe;
                safeEnterVC.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:safeEnterVC animated:YES];
            }else{
                
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_psderror", @"")];
                [self top_clearAllPassWordMothod];
            }
        }
            break;
        case TOPAppSetSafePasswordStateSafeInLocalInput:
        {
            [self top_validationPwd:TOPAppSetSafePasswordStateSafeInLocalInput];
            
        }
            break;
        case TOPAppSetSafePasswordStateFirstSetSafe:
        {
            TOPAppSafeEnterViewController *safeEnterVC = [[TOPAppSafeEnterViewController alloc] init];
            __block NSString *firstPsd = @"";
            
            [self.savePsdArrays enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                firstPsd = [firstPsd stringByAppendingString:obj];
            }];
            safeEnterVC.firstPwdStr = firstPsd;
            safeEnterVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:safeEnterVC animated:YES];
            
        }
            break;
        case TOPAppSetSafePasswordStateClosePwd:
        {
            [self top_validationPwd:TOPAppSetSafePasswordStateClosePwd];
            
        }
            break;
        case TOPAppSetSafePasswordStateRestartPwd:
        {
            [self top_validationPwd:TOPAppSetSafePasswordStateRestartPwd];
            
        }
            break;
        case TOPAppSetSafePasswordStateChangeFaceIdType:
        {
            TOPTouchUnlockViewController *setpwdVC = [[TOPTouchUnlockViewController alloc] init];
            setpwdVC.unlockType = TOPAppSetSafeUnlockTypeFaceID;
            setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateOpen;
            [self.navigationController  pushViewController:setpwdVC animated:YES];
        }
            break;
        case TOPAppSetSafePasswordStateChangeTouchIdType:
        {
            TOPTouchUnlockViewController *setpwdVC = [[TOPTouchUnlockViewController alloc] init];
            setpwdVC.unlockType = TOPAppSetSafeUnlockTypeTouchID;
            setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateOpen;
            [self.navigationController  pushViewController:setpwdVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)top_validationPwd:(TOPAppSetSafePasswordState)currentSafePsdState
{
    if (self.savePsdArrays.count < 4) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_safeentertips", @"")];
        [SVProgressHUD dismissWithDelay:1];
        return;
    }
    __block NSString *enterPsd = @"";
    [self.savePsdArrays enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        enterPsd = [enterPsd stringByAppendingString:obj];
    }];
    NSString *currentPWD = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeCurrentPWDKey];
    if ([enterPsd isEqualToString:currentPWD]) {
        switch (currentSafePsdState) {
            case TOPAppSetSafePasswordStateSafeInLocalInput:
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
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [TOPScanerShare shared].isFirstShow = YES;
                }
            }
                break;
            case TOPAppSetSafePasswordStateRestartPwd:
            {
                [[NSUserDefaults standardUserDefaults] setInteger:TOPAppSetSafeUnlockTypePwd forKey:TOP_TRAppSafeUnLockType];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TOP_TRAppSafeStates];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
                break;
            case TOPAppSetSafePasswordStateClosePwd:
            {
                [[NSUserDefaults standardUserDefaults] setInteger:TOPAppSetSafeUnlockTypePwd forKey:TOP_TRAppSafeUnLockType];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TOP_TRAppSafeStates];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:TOP_TRAppSafeCurrentPWDKey];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                [TOPScanerShare shared].isFirstShow = YES;
            }
                break;
                
            default:
                break;
        }
    }else{
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_psderror", @"")];
        [self top_clearAllPassWordMothod];
    }
}

#pragma mark -- 跳转到OCR识别界面
- (void)top_jumpToOcrVC:(NSMutableArray *)dataArr {
    TOPPhotoShowOCRVC * ocrVC = [TOPPhotoShowOCRVC new];
    ocrVC.currentIndex = 0;
    ocrVC.dataArray = dataArr;//DocumentModel
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
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [TOPActionExtensionHandler top_parsingDataBuildModelsSuccess:^(NSMutableArray * _Nonnull dataArr, NSString * _Nonnull filePath) {
        [SVProgressHUD dismiss];
        [self top_jumpToOcrVC:dataArr];
    }];
}

#pragma mark -- actionExtension分享数据的处理
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
                                CGPDFDocumentRelease(fromPDFDoc);
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

- (NSMutableArray *)savePsdArrays
{
    if (_savePsdArrays == nil) {
        _savePsdArrays = [NSMutableArray array];
    }
    return _savePsdArrays;
}

- (NSMutableArray *)numberArrays
{
    if (_numberArrays ==nil) {
        _numberArrays = [NSMutableArray array];
    }
    return _numberArrays;
}

#pragma mark -- helpBtnAction
- (IBAction)AppPasswordHelpClick:(UIButton *)sender {
    [FIRAnalytics logEventWithName:@"settingView_SendFeedback" parameters:nil];
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
    
    MFMailComposeViewController * mailCompose = [[MFMailComposeViewController alloc]init];
    mailCompose.mailComposeDelegate = self;
    [mailCompose setSubject:NSLocalizedString(@"topscan_passwordapphelpsubject", @"")];
    
    NSArray * toRecipients = [NSArray arrayWithObjects:SimplescannerEmail,nil];
    [mailCompose setToRecipients:toRecipients];
    
    NSString *emailBody = [NSString stringWithFormat:@"Model:%@\n %@\n App:%@",[TOPAppTools deviceVersion],[TOPAppTools SystemVersion],[TOPAppTools getAppVersion]];
    
    
    [mailCompose setMessageBody:emailBody isHTML:NO];
    [self presentViewController:mailCompose animated:YES completion:^{
        
    }];
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

#pragma mark -- collectionView and delegate
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.delaysContentTouches = false;
        
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerNib:[UINib nibWithNibName:@"TOPNumberCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([TOPNumberCollectionViewCell class])];
        [_collectionView registerClass:[TOPClearPsdCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPClearPsdCollectionViewCell class])];
        
        
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.numberArrays.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.item == 9 || indexPath.item == 11) {
        TOPClearPsdCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPClearPsdCollectionViewCell class]) forIndexPath:indexPath];
        if (indexPath.item == 9) {
            cell.imageIconName = @"";
        }else{
            cell.imageIconName = @"top_appsafe_clear";
        }
        return cell;
    }
    TOPNumberCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPNumberCollectionViewCell class]) forIndexPath:indexPath];
    cell.numberTitleLabel.text = self.numberArrays[indexPath.item];
    return cell;
}
#pragma mark - 连续点击5次
- (void)clearAppPasswordTap:(UITapGestureRecognizer *)gesture {
    BOOL isAppSafeStates = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeStates] boolValue];
    if (isAppSafeStates ) {
        [self top_clearAppLockStatesAlert];
        
    }
    
}
#pragma mark -- 是否清除安全密码
- (void)top_clearAppLockStatesAlert{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"")
                                                                   message:NSLocalizedString(@"topscan_clearapppsd" ,@"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        
        NSString *currentPwd = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeCurrentPWDKey];
        if (currentPwd) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:TOP_TRAppSafeCurrentPWDKey];
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TOP_TRAppSafeStates];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(73, 73);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return (TOPScreenWidth-100-73*3)/2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 9) {
        return;
    }
    if (indexPath.item == 11) {
        self.clearNumber ++;
        if (self.clearNumber>=10) {
            [self top_clearAppLockStatesAlert];
            self.clearNumber  = 0;
        }
        if (self.savePsdArrays.count) {
            [self.savePsdArrays removeLastObject];
            [self top_updateTopPasswordUIWith:self.savePsdArrays];
            return;
        }
        return;
    }
    if (self.savePsdArrays.count  >=4) {
        return;
    }
    self.clearNumber  = 0;
    [self.savePsdArrays addObject:self.numberArrays[indexPath.item]];
    [self top_updateTopPasswordUIWith:self.savePsdArrays];
    if (self.savePsdArrays.count  >=4) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self top_validationTapMothod];
            
        });
    }
}

-(void) collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 9 ) {
        return;
    }
    if (indexPath.item == 11) {
        TOPClearPsdCollectionViewCell *cell = (TOPClearPsdCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.iconView.image = [UIImage imageNamed:@"top_appsafe_clear_Select"];
        return;
    }
    TOPNumberCollectionViewCell *cell = (TOPNumberCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:UIColorFromRGB(0xE3e3e3)]];
}

- (void)collectionView:(UICollectionView *)colView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 9 ) {
        
        return;
    }
    if (indexPath.item == 11) {
        TOPClearPsdCollectionViewCell *cell = (TOPClearPsdCollectionViewCell*)[colView cellForItemAtIndexPath:indexPath];
        cell.iconView.image = [UIImage imageNamed:@"top_appsafe_clear"];
        return;
    }
    TOPNumberCollectionViewCell *cell = (TOPNumberCollectionViewCell*)[colView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 25;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return  UIEdgeInsetsMake(25, 50, 15, 50);
}

- (void)top_clearAllPassWordMothod
{
    
    [self.savePsdArrays removeAllObjects];
    self.oneDotView.hidden = YES;
    self.onePwdContentLabel.text = @"";
    self.twoDotView.hidden = YES;
    self.twoPwdContentLabel.text = @"";
    self.threeDotView.hidden = YES;
    self.threePwdContentLabel.text = @"";
    self.fourDotView.hidden = YES;
    self.fourPwdContentLabel.text = @"";
}

- (void)top_updateTopPasswordUIWith:(NSMutableArray *)currentSaveArrays
{
    self.oneDotView.hidden = YES;
    self.onePwdContentLabel.hidden = YES;
    self.twoDotView.hidden = YES;
    self.twoPwdContentLabel.hidden = YES;
    self.threeDotView.hidden = YES;
    self.threePwdContentLabel.hidden = YES;
    self.fourDotView.hidden = YES;
    self.fourPwdContentLabel.hidden = YES;
    
    if (currentSaveArrays.count >0) {
        self.oneDotView.hidden = NO;
        self.onePwdContentLabel.hidden = YES;
        self.onePwdContentLabel.text = [currentSaveArrays firstObject];
        if (self.isShowPsd == YES) {
            self.oneDotView.hidden = YES;
            self.onePwdContentLabel.hidden = NO;
        }
    }
    if (currentSaveArrays.count  > 1)
    {
        self.twoDotView.hidden = NO;
        self.twoPwdContentLabel.text = currentSaveArrays[1];
        self.twoPwdContentLabel.hidden = YES;
        if (self.isShowPsd == YES) {
            self.twoDotView.hidden = YES;
            self.twoPwdContentLabel.hidden = NO;
        }
    }
    if (currentSaveArrays.count  >2)
    {
        self.threeDotView.hidden = NO;
        self.threePwdContentLabel.text =  currentSaveArrays[2];
        self.threePwdContentLabel.hidden = YES;
        if (self.isShowPsd == YES) {
            self.threeDotView.hidden = YES;
            self.threePwdContentLabel.hidden = NO;
        }
    }
    if (currentSaveArrays.count  > 3)
    {
        self.fourDotView.hidden = NO;
        self.fourPwdContentLabel.text = currentSaveArrays[3];
        self.fourPwdContentLabel.hidden = YES;
        if (self.isShowPsd == YES) {
            self.fourDotView.hidden = YES;
            self.fourPwdContentLabel.hidden = NO;
        }
    }
}

- (BOOL)shouldAutorotate{
    return NO;
}
@end
