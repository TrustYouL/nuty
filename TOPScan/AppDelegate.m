#import "AppDelegate.h"
#import "TOPMainTabBarController.h"
#import "TOPHomeViewController.h"
#import "TOPNextFolderViewController.h"
#import "TOPBaseNavViewController.h"
#import "TOPSettingFormatModel.h"
#import "TOPKeychainManager.h"
#import "TOPHomeChildViewController.h"
#import "TOPFileTargetListViewController.h"
#import "TOPAppSafeNotCenterClass.h"
#import "TOPActionExtensionHandler.h"
#import "TOPEditPDFViewController.h"
#import "TOPAppSafeShowPasswordVC.h"
#import "TOPTouchUnlockViewController.h"
#import "TOPPhotoShowOCRVC.h"
#import "TOPPhotoLongPressView.h"
#import "TOPScreenShotView.h"
#import "TOPDBService.h"
#import "TOPGuideVC.h"
#import "TOPJDSKPaymentTools.h"
#import "TOPSubscriptTools.h"
#import "SCRecentPreviewViewController.h"
#import "SCHomeListViewController.h"
#import "TOPFunctionCollectionVC.h"
#import "TOPInAppStoreObserver.h"
#import "TOPNetWorkManager.h"
#import "TOPPurchaseValidationHandler.h"

#define ShareAppGroup @"group.tongsoft.simple.scanner"
#define sharePdfType @"com.adobe.pdf"
#define shareImgType @"public.image"
#define shareZipType @"archive"

#define openVersion @"2.3.1"
#define oldVersion @"2.3.0"

#define ShortcutItemLibrary @"SSLibrary"
#define ShortcutItemSingle @"SSSingle"
#define ShortcutItemBatch @"SSBatch"

@interface AppDelegate ()<UNUserNotificationCenterDelegate,GADFullScreenContentDelegate>
@property (nonatomic ,strong)TOPMainTabBarController * mainRoot;
@property (nonatomic ,strong)NSMutableArray * saveArray;
@property (nonatomic ,strong)NSMutableArray * saveOriginalPathArray;
@property (nonatomic ,assign)NSInteger count;
@property (nonatomic ,strong)NSMutableArray * shareArray;
@property (nonatomic ,assign)BOOL isSkip;
@property (nonatomic ,strong)NSMutableArray * skipArray;
@property (nonatomic ,assign)NSInteger pdfCount;
@property (nonatomic ,strong)TOPFileTargetListViewController * fileVC;
@property (nonatomic ,assign)BOOL isOpenUrl;
@property (nonatomic ,strong)GADAppOpenAd * appOpenAd;
@property (nonatomic ,strong)NSDate * loadTime;
@property (nonatomic ,strong) NSMutableArray *airDropFiles;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.shortcutItems = [self shortCutItems];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [application setApplicationIconBadgeNumber:0];
    
    TOPBaseNavViewController * nav = [TOPBaseNavViewController new];
    self.window.rootViewController = nav;
    [TOPScanerShare shared].isFirstShow = YES;
    self.isOpenUrl = NO;
    
    //进度框的设置
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:RGB(230, 231, 238)];
    [FIRApp configure];
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    [self top_thirDriveInitMothod];
    [self registerAPNApplication:application];
    
    [self.window makeKeyAndVisible];
    BOOL isAppSafeStates = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeStates] boolValue];
    if (isAppSafeStates) {
        [TOPScanerShare top_writeAppLockState:NO];
    }
    [self top_migrateDocumentToAppSupportDirectory];
    [self top_settingDarkModelDefault];
    [self top_settingDefaultState];
    [self top_removeOldTempFile];
    [self top_settingJPGMaxPiexl];
    [self top_settingDefaultConfig];
    [self top_fetchNetTime];
    [self top_configureNavigationBar];
    [self top_setFunctionPermission];
    [self top_initTempFile];
    [self top_initDataBase];
    [self top_calculateDocNum];
    [[TOPJDSKPaymentTools shareInstance] top_startManager];
    [self top_setRootVC];
    return YES;
}


- (void)top_configSubscription {
    [[TOPInAppStoreObserver shareInstance] topStartTransactionObserver];
    [[TOPInAppStoreObserver shareInstance] topFetchSubscriptionInfo];
}

- (void)top_fetchNetTime {
    [TOPNetWorkManager topFetchGoogleTimeSuccess:^(NSTimeInterval time) {
        [self top_getLifeTime:time];
    }];
    if (![TOPScanerShare top_purchaseSubscriptionsCount]) {
        [TOPPurchaseValidationHandler topCheckSubscribeSuccess:^(NSInteger state) {
            if (state == 1) {
                [TOPScanerShare top_writePurchasedSubscriptionsCount:1];
            }
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }
}

- (void)top_getLifeTime:(NSTimeInterval)now {
    // 计算活动剩余时间
    NSInteger future = [[NSUserDefaults standardUserDefaults] integerForKey:@"futureTimeKey"];
    if (future > 0) {
        NSInteger lifeTime = future - lround(now);
        [[NSUserDefaults standardUserDefaults] setInteger:lifeTime forKey:@"lifeTimeKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark -- 计算文档大小
- (void)top_calculateDocNum{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RLMResults<TOPAppDocument *> *documents = [TOPAppDocument allObjects];
        long sumSize = 0;
          for (TOPAppDocument * doc in documents) {
              long docSize = [[doc.images sumOfProperty:@"fileLength"] longValue];
              sumSize += docSize;
          }
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat docNum = sumSize/1024.0/1024.0/1024.0;
            NSString * sendString = [NSString new];
            if (docNum>=2.0) {
                if (docNum>=100.0) {
                    sendString = @"MoreThan100";
                }else{
                    NSInteger num = (floor(docNum/2)+1)*2;
                    sendString = [NSString stringWithFormat:@"%ld",num];
                }
            }else{
                NSInteger num = 2;
                sendString = [NSString stringWithFormat:@"%ld",num];
            }
            NSString * recordString = [NSString stringWithFormat:@"allDocSize_%@GB",sendString];
            [FIRAnalytics logEventWithName:recordString parameters:nil];
        });
    });
}

- (void)top_setRootVC{
    TOPMainTabBarController * tab = [TOPMainTabBarController new];
    tab.selectedIndex = 2;
    self.window.rootViewController = tab;
}

- (void)top_backToRootViewController {
    if ([self.window.rootViewController isKindOfClass:[TOPBaseNavViewController class]]) {
        TOPBaseNavViewController *navVC = (TOPBaseNavViewController *)self.window.rootViewController;
        UIViewController* vc = navVC.visibleViewController;
        if ([vc isKindOfClass:[TOPHomeViewController class]]) {
            return ;
        }
        if (vc.presentingViewController) {
            [vc dismissViewControllerAnimated:NO completion:^{
                [self top_backToRootViewController];
            }];
        }
        else{
            [vc.navigationController popToRootViewControllerAnimated:NO];
            [self top_backToRootViewController];
        }
    } else if ([self.window.rootViewController isKindOfClass:[TOPMainTabBarController class]]) {
        TOPMainTabBarController *tabVC = (TOPMainTabBarController *)self.window.rootViewController;
        UINavigationController *navVC = (UINavigationController *)tabVC.selectedViewController;
        UIViewController *vc = navVC.visibleViewController;

        if ([vc isKindOfClass:[TOPHomeViewController class]] || [vc isKindOfClass:[SCRecentPreviewViewController class]] || [vc isKindOfClass:[SCHomeListViewController class]] || [vc isKindOfClass:[TOPFunctionCollectionVC class]]) {
            return ;
        }
        if (vc.presentingViewController) {
            [vc dismissViewControllerAnimated:NO completion:^{
                [self top_backToRootViewController];
            }];
        }
        else{
            [vc.navigationController popToRootViewControllerAnimated:NO];
            [self top_backToRootViewController];
        }
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    self.isOpenUrl = YES;
    BOOL isAppSafeStates = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeStates] boolValue];
    if ([url.scheme isEqualToString:@"jumpsimplescanner"]) {
        BOOL isContainingApp = NO;
        if([url.absoluteString rangeOfString:@"TOPScanBox"].location != NSNotFound) {
            isContainingApp = YES;
        }
        if (isAppSafeStates && !isContainingApp) {
            [TOPScanerShare top_writeIsShareExtension:url];
            [self top_didBecomeActive];
        } else {
            if ([url.absoluteString hasSuffix:@"PreviewPDF"]) {
                [FIRAnalytics logEventWithName:@"Action_CreatePDF" parameters:nil];
                [self top_deleteCoverView];
                [self top_actionDataHandle:url];
            } else if ([url.absoluteString hasSuffix:@"OCR"]) {
                [FIRAnalytics logEventWithName:@"Action_OCR" parameters:nil];
                [self top_deleteCoverView];
                [self top_ocrActionDataHandle:url];
            } else if ([url.absoluteString rangeOfString:@"ImportPic_"].location != NSNotFound) {
                [FIRAnalytics logEventWithName:@"Action_Import" parameters:nil];
                NSString *tempUrlStr = [url.absoluteString stringByReplacingOccurrencesOfString:@"ImportPic_" withString:@""];
                url = [NSURL URLWithString:tempUrlStr];
                [self top_deleteCoverView];
                [self top_dealShareData:url];
            }  else {
                [FIRAnalytics logEventWithName:@"Share_Import" parameters:nil];
                [self top_deleteCoverView];
                [self top_dealShareData:url];
            }
        }
    } else if ([url.scheme  isEqualToString:@"db-ji99nfnsvsufma2"]){
        DBOAuthCompletion completion = ^(DBOAuthResult *authResult) {
            if (authResult != nil) {
                if ([authResult isSuccess]) {
                    NSLog(@"\n\nSuccess! User is logged into Dropbox.\n\n");
                    [[NSUserDefaults standardUserDefaults] setObject:authResult.accessToken.accessToken forKey:@"accessToken"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:
                     @"DropBoxOpenDrives" object:nil userInfo:nil];
                    
                } else if ([authResult isCancel]) {
                    NSLog(@"\n\nAuthorization flow was manually canceled by user!\n\n");
                } else if ([authResult isError]) {
                    NSLog(@"\n\nError: %@\n\n", authResult);
                }
            }
        };
        BOOL canHandle = [DBClientsManager handleRedirectURL:url completion:completion];
        return  canHandle;
    } else if ([url.scheme isEqualToString:@"file"]) {
        [FIRAnalytics logEventWithName:@"Airdrop_file" parameters:nil];
        [self.airDropFiles addObject:url];
        if (self.airDropFiles.count == 1) {
            [self top_fileDataHandle:url];
        }
        
    } else if ([@"boxsdk-rssaagixjly0wbrs2z1y3z7e9phj15wj" isEqualToString:url.scheme]) {
        return YES;
    }
    
    return [[GIDSignIn sharedInstance] handleURL:url];
}

- (BOOL)top_isPDFFileWithUrl:(NSURL *)url {
    NSString * fileName = [TOPWHCFileManager top_fileNameAtPath:url.path suffix:YES];
    if ([fileName.lowercaseString hasSuffix:@".pdf"]) {
        return YES;
    }
    return NO;
}

- (BOOL)top_isZipFileWithUrl:(NSURL *)url {
    NSString * fileName = [TOPWHCFileManager top_fileNameAtPath:url.path suffix:YES];
    if ([fileName.lowercaseString hasSuffix:@".zip"]) {
        return YES;
    }
    return NO;
}
#pragma mark -- airDrop 数据处理 pdf文件
- (void)top_fileDataHandle:(NSURL *)url {
    if ([self top_isPDFFileWithUrl:url]) {
        NSData * fileData = [NSData dataWithContentsOfFile:url.path];
        if (fileData) {
            [self top_importPdfToNewDocument];
        }
    } else if ([self top_isZipFileWithUrl:url]) {
        NSData * fileData = [NSData dataWithContentsOfFile:url.path];
        if (fileData) {
            [self top_importZipToNewDocument:fileData];
        }
    }
}

#pragma mark -- 导入AirDrop传输的zip
- (void)top_importZipToNewDocument:(NSData *)data  {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * shareTypessssss = @"";
        NSMutableArray * dataArray = [NSMutableArray array];
        NSString *zipPath = [self top_zipFileInbox:data];
        NSData * fileData = [NSData dataWithContentsOfFile:zipPath];
        if (fileData) {
            dataArray = [self top_unLockZipFile:zipPath];
            if (dataArray.count) {
                NSObject *content = dataArray.firstObject;
                if ([content isKindOfClass:[NSDictionary class]]) {
                    shareTypessssss = sharePdfType;
                } else {
                    shareTypessssss = shareImgType;
                }
            }
        }
        self.shareArray = dataArray;
        self.pdfCount = dataArray.count;
        [self.airDropFiles removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self top_creatRootVC:[dataArray copy] shareType:shareTypessssss];
        });
    });
}

#pragma mark -- 导入AirDrop传输的PDF
- (void)top_importPdfToNewDocument {
    WS(weakSelf);
    TOPFileTargetListViewController *targetListVC = [[TOPFileTargetListViewController alloc] init];
    targetListVC.currentFilePath = [TOPDocumentHelper top_getDocumentsPathString];
    targetListVC.fileHandleType = TOPFileHandleTypeCopy;
    targetListVC.fileTargetType = TOPFileTargetTypeFolder;
    self.fileVC = targetListVC;
    targetListVC.top_callBackFilePathBlock = ^(NSString * _Nonnull path) {
        [FIRAnalytics logEventWithName:@"recivePDFToMyApp" parameters:nil];
        
        [TOPScanerShare shared].isReceive = NO;
        [TOPDocumentHelper top_initializationFolder];
        weakSelf.shareArray = @[].mutableCopy;
        for (NSURL *url in weakSelf.airDropFiles) {
            if ([weakSelf top_isPDFFileWithUrl:url]) {
                NSData * fileData = [NSData dataWithContentsOfFile:url.path];
                if (fileData) {
                    [weakSelf.shareArray addObject:fileData];
                }
            }
        }
        weakSelf.pdfCount = weakSelf.shareArray.count;
        if (weakSelf.pdfCount > 1) {
            [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...(%@-%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(weakSelf.count+1),@(weakSelf.pdfCount)]];
        }else{
            if (weakSelf.pdfCount == 1) {
                [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
            }
        }
        NSMutableArray *tempArr = [weakSelf.shareArray mutableCopy];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            AutoRelease_for (NSData * tempData in tempArr)  {
                if (tempData) {
                    NSInteger row = [tempArr indexOfObject:tempData];
                    NSURL * url = weakSelf.airDropFiles[row];
                    NSString * fileName = [TOPWHCFileManager top_fileNameAtPath:url.path suffix:NO];
                    NSString *docFile = [TOPDocumentHelper top_createNewDocument:fileName atFolderPath:path];
                    [weakSelf top_breakupPDF:tempData shareType:docFile dispatch:semaphore alertTitle:NSLocalizedString(@"topscan_decryption", @"") alertMessage:@"pdf"];
                }
            }
            weakSelf.airDropFiles = @[].mutableCopy;
        });
    };
    targetListVC.top_clickCancelBlock = ^{
        [TOPScanerShare top_writeIsShareExtension:[NSURL new]];
        weakSelf.airDropFiles = @[].mutableCopy;
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:targetListVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [[TOPDocumentHelper top_appRootViewController] presentViewController:nav animated:YES completion:nil];
    });
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
    ocrVC.hidesBottomBarWhenPushed = YES;
    UIViewController *rootVC = [TOPDocumentHelper top_appRootViewController];
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        TOPBaseNavViewController *nav = (TOPBaseNavViewController *)rootVC;
        [nav pushViewController:ocrVC animated:YES];
    } else {
        TOPBaseNavViewController *nav = [[TOPBaseNavViewController alloc] initWithRootViewController:rootVC];
        [nav pushViewController:ocrVC animated:YES];
    }
}

#pragma mark -- OCR Action Extension 数据处理
- (void)top_ocrActionDataHandle:(NSURL *)url {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [TOPActionExtensionHandler top_parsingDataBuildModelsSuccess:^(NSMutableArray * _Nonnull dataArr, NSString * _Nonnull filePath) {
        [SVProgressHUD dismiss];
        [self top_jumpToOcrVC:dataArr];
    }];
}

#pragma mark -- 跳转PDF编辑预览
- (void)top_jumpToEditPDFVC:(NSArray *)imageArr atPath:(NSString *)filePath {
    TOPEditPDFViewController * pdfVC = [[TOPEditPDFViewController alloc] init];
    pdfVC.docModel = [TOPDBDataHandler top_addNewDocModel:filePath];
    pdfVC.filePath = filePath;
    pdfVC.imagePathArr = imageArr;
    pdfVC.hidesBottomBarWhenPushed = YES;
    UIViewController *rootVC = [TOPDocumentHelper top_appRootViewController];
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        TOPBaseNavViewController *nav = (TOPBaseNavViewController *)rootVC;
        [nav pushViewController:pdfVC animated:YES];
    } else {
        TOPBaseNavViewController *nav = [[TOPBaseNavViewController alloc] initWithRootViewController:rootVC];
        [nav pushViewController:pdfVC animated:YES];
    }
}
- (void)top_deleteCoverView{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    for (UIView __strong * childView in window.subviews) {
        if ([childView isKindOfClass:[TOPPhotoLongPressView class]]) {
            [TOPScanerShare shared].isEditing = NO;
            [childView removeFromSuperview];
            childView = nil;
        }
    }
}
#pragma mark -- PDF Action Extension 数据处理
- (void)top_actionDataHandle:(NSURL *)url {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [TOPActionExtensionHandler top_parsingDataSuccess:^(NSMutableArray * _Nonnull dataArr, NSString * _Nonnull filePath) {
        [SVProgressHUD dismiss];
        [self top_jumpToEditPDFVC:dataArr atPath:filePath];
    }];
}

#pragma mark -- 临时文件 存放分享文件
- (NSString *)top_setupTempGroupFile {
    NSString *tempGroupFile = [TOPDocumentHelper top_getBelongTemporaryPathString:@"SSTempGroup"];
    if ([TOPWHCFileManager top_isExistsAtPath:tempGroupFile]) {
        [TOPWHCFileManager top_removeItemAtPath:tempGroupFile];
    }
    [TOPWHCFileManager top_createDirectoryAtPath:tempGroupFile];
    return tempGroupFile;
}

- (NSString *)top_shareFilesWithUrl:(NSURL *)url {
    [FIRAnalytics logEventWithName:@"shareFilesWithUrl" parameters:nil];
    NSString * shareTypessssss = [[url.absoluteString componentsSeparatedByString:@"-"] lastObject];
    NSURL * groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:ShareAppGroup];
    NSArray * folderList = [TOPWHCFileManager top_listFilesInDirectoryAtPath:[groupURL path] deep:NO];
    NSString *tempGroupFile = [self top_setupTempGroupFile];
    self.count = 0;
    NSMutableArray * dataArray = [NSMutableArray array];
    for (NSString  * tempstr in folderList) {
        @autoreleasepool {
            if ([tempstr.lowercaseString hasSuffix:@".jpg"]|| [tempstr.lowercaseString hasSuffix:@".png"] || [tempstr.lowercaseString hasSuffix:@".jpeg"]||[tempstr.lowercaseString hasSuffix:@".pdf"]||[tempstr.lowercaseString hasSuffix:@".zip"]) {
                NSString * tempFile = [[groupURL path] stringByAppendingPathComponent:tempstr];
                NSData * getData = [NSData dataWithContentsOfFile:tempFile];
                if (getData) {
                    NSString * newFilePath = [tempGroupFile stringByAppendingPathComponent:tempstr];
                    [TOPWHCFileManager top_moveItemAtPath:tempFile toPath:newFilePath];
                    if ([shareTypessssss isEqualToString:shareImgType]) {
                        [dataArray addObject:newFilePath];
                    } else if ([shareTypessssss isEqualToString:sharePdfType]) {
                        NSString* encodedString = [TOPDocumentHelper top_decodeFromPercentEscapeString:tempstr];
                        NSString* fileName = [NSString new];
                        if ([tempstr hasSuffix:@".pdf"]) {
                            fileName = [[encodedString componentsSeparatedByString:@".pdf"] firstObject];
                        } else {
                            continue;
                        }
                        NSDictionary * dic = @{fileName:newFilePath};
                        [dataArray addObject:dic];
                    } else if ([shareTypessssss isEqualToString:shareZipType] && [tempstr.lowercaseString hasSuffix:@".zip"]) {
                        NSString *zipPath = [self top_zipFileInbox:getData];
                        NSData * fileData = [NSData dataWithContentsOfFile:zipPath];
                        if (fileData) {
                            dataArray = [self top_unLockZipFile:zipPath];
                            if (dataArray.count) {
                                NSObject *content = dataArray.firstObject;
                                if ([content isKindOfClass:[NSDictionary class]]) {
                                    shareTypessssss = sharePdfType;
                                } else {
                                    shareTypessssss = shareImgType;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    self.shareArray = dataArray;
    self.pdfCount = dataArray.count;
    
    return shareTypessssss;
}

- (void)top_dealShareData:(NSURL *)url{
    self.isSkip = NO;
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * shareTypessssss = [self top_shareFilesWithUrl:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (self.shareArray.count) {
                [self top_creatRootVC:[self.shareArray mutableCopy] shareType:shareTypessssss];
            }
        });
    });
}

- (NSString *)top_zipFileInbox:(NSData *)data {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:TOPTemporaryPathZip]){
        [fileManager createDirectoryAtPath:TOPTemporaryPathZip withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *zipPath = [TOPTemporaryPathZip stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",
                                                                           [NSUUID UUID].UUIDString]];
    [data writeToFile:zipPath atomically:YES];
    return zipPath;
}

- (NSMutableArray *)top_unLockZipFile:(NSString *)zipFilePath {
    [TOPWHCFileManager top_removeItemAtPath:TOPTemporaryPathUnZip];
    NSMutableArray  *dataArray = @[].mutableCopy;
    NSString *unzipPath = [TOPDocumentHelper top_tempUnzipPath];
    BOOL succeeded = [SSZipArchive unzipFileAtPath:zipFilePath toDestination:unzipPath];
    if(succeeded){
        NSMutableArray  *tempFileArrays = [TOPDocumentHelper top_getCurrentFileAndPath:unzipPath];
        for (NSString *fileName in tempFileArrays) {
            NSString *filePath = [unzipPath stringByAppendingPathComponent:fileName];
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            if (fileData.length > 0) {
                if ([fileName.lowercaseString hasSuffix:@".pdf"]) {
                    NSString *pdfName = [[fileName componentsSeparatedByString:@".pdf"] firstObject];
                    NSDictionary * dic = @{pdfName:filePath};
                    [dataArray addObject:dic];
                } else {
                    [dataArray addObject:filePath];
                }
            }
        }
    }
    return dataArray;
}
- (void)top_thirDriveInitMothod{
    NSString *appKey = @"ji99nfnsvsufma2";
    NSString *registeredUrlToHandle = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"][0][@"CFBundleURLSchemes"][0];
    if (!appKey || [registeredUrlToHandle containsString:@"<"]) {
        NSString *message = @"You need to set `appKey` variable in `AppDelegate.m`, as well as add to `Info.plist`, before you can use DBRoulette.";
        NSLog(@"%@", message);
        NSLog(@"Terminating...");
        exit(1);
    }
    [DBClientsManager setupWithAppKey:appKey];
    [ODClient setMicrosoftAccountAppId:@"67935cbe-398a-48c1-a667-aea62dde5d76" scopes:@[@"onedrive.readwrite",@"offline_access"]];
    [ODClient setActiveDirectoryAppId:@"67935cbe-398a-48c1-a667-aea62dde5d76" redirectURL:@"msal67935cbe-398a-48c1-a667-aea62dde5d76://auth"];
    [BOXContentClient setClientID:@"rssaagixjly0wbrs2z1y3z7e9phj15wj" clientSecret:@"f8ANMikTHn9OiDNB195pRGOojbHQuv4O" redirectURIString:@"https://app.box.com/rssaagixjly0wbrs2z1y3z7e9phj15wj"];
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error == nil) {
    } else {
    }
}
- (void)top_creatRootVC:(NSArray *)array shareType:(NSString *)shareType{
    [FIRAnalytics logEventWithName:@"selectDirectory" parameters:nil];
    WS(weakSelf);
    TOPFileTargetListViewController *targetListVC = [[TOPFileTargetListViewController alloc] init];
    targetListVC.currentFilePath = [TOPDocumentHelper top_getDocumentsPathString];
    targetListVC.fileHandleType = TOPFileHandleTypeCopy;
    targetListVC.fileTargetType = TOPFileTargetTypeFolder;
    self.fileVC = targetListVC;
    targetListVC.top_callBackFilePathBlock = ^(NSString * _Nonnull path) {
        [TOPScanerShare shared].isReceive = NO;
        [TOPDocumentHelper top_initializationFolder];
        if ([shareType isEqualToString:shareImgType]) {
            [FIRAnalytics logEventWithName:@"reciveImgToMyApp" parameters:nil];
            [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingjpg", @"")]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:path];
                for (int i = 0; i<array.count; i++) {
                    @autoreleasepool {
                        NSString *filePath = array[i];
                        NSData *imgData = [NSData dataWithContentsOfFile:filePath];
                        if (imgData) {
                            UIImage * img = [TOPPictureProcessTool top_fetchOriginalImageWithData:imgData];
                            NSString *imgName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
                            NSString *oriName = [NSString stringWithFormat:@"%@%@%@%@",TOPRSimpleScanOriginalString,[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
                            NSString *fileEndPath =  [endPath stringByAppendingPathComponent:imgName];
                            NSString *oriEndPath = [endPath stringByAppendingPathComponent:oriName];
                            [TOPDocumentHelper top_saveImage:img atPath:fileEndPath];
                            [TOPWHCFileManager top_copyItemAtPath:fileEndPath toPath:oriEndPath];
                            [TOPWHCFileManager top_removeItemAtPath:filePath];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                CGFloat myProgress = ((i+1)*10.0)/(array.count * 10.0);
                                [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingjpg", @"")]];
                            });
                        }
                    }
                }
                [TOPEditDBDataHandler top_addDocumentAtFolder:endPath WithParentId:[TOPFileDataManager shareInstance].fileModel.docId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TOPScanerShare shared].isReceive = YES;
                    [SVProgressHUD dismiss];
                    [[TOPProgressStripeView shareInstance]dismiss];
                    [[NSNotificationCenter defaultCenter] postNotificationName:TOP_TRRemoveScreenhostView object:nil];
                    [weakSelf top_getRootVC];
                });
            });
        }
        
        if ([shareType isEqualToString:sharePdfType]) {
            [FIRAnalytics logEventWithName:@"recivePDFToMyApp" parameters:nil];
            if (weakSelf.pdfCount>1) {
                [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...(%@-%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(weakSelf.count+1),@(weakSelf.pdfCount)]];
            }else{
                if (weakSelf.pdfCount>0) {
                    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
                }
            }
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                AutoRelease_for (NSDictionary * tempDic in array)  {
                    if ([tempDic isKindOfClass:[NSDictionary class]]) {
                        NSData * data = [NSData new];
                        NSString * docName = [NSString new];
                        if (tempDic.allValues.count>0) {
                            NSString *filePath = tempDic.allValues[0];
                            data = [NSData dataWithContentsOfFile:filePath];
                            [TOPWHCFileManager top_removeItemAtPath:filePath];
                        }
                        if (tempDic.allKeys.count>0) {
                            docName = tempDic.allKeys[0];
                        }
                        if (data) {
                            NSString * docPath = [TOPDocumentHelper top_createNewDocument:docName atFolderPath:path];
                            [weakSelf top_breakupPDF:data shareType:docPath dispatch:semaphore alertTitle:NSLocalizedString(@"topscan_decryption", @"") alertMessage:@"pdf"];
                        }
                    }
                }
            });
        }
    };
    
    targetListVC.top_clickCancelBlock = ^{
        [TOPScanerShare top_writeIsShareExtension:[NSURL new]];
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:targetListVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [[TOPDocumentHelper top_appRootViewController] presentViewController:nav animated:YES completion:nil];
    });
}

- (void)top_breakupPDF:(NSData *)data shareType:(NSString *)shareType dispatch:(dispatch_semaphore_t)semaphore alertTitle:(NSString *)title alertMessage:(NSString *)message{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data );
    WS(weakSelf);
    CGPDFDocumentRef fromPDFDoc =  CGPDFDocumentCreateWithProvider(provider);
    if (fromPDFDoc == NULL) {
        CFRelease((__bridge CFDataRef)data);
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
                            [weakSelf.fileVC presentViewController:col animated:YES completion:nil];
                            return;
                        }
                    }];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_skip", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
                    }];
                    [col addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        textField.placeholder = NSLocalizedString(@"topscan_placeholderpassword", @"");
                    }];
                    [col addAction:cancelAction];
                    [col addAction:confirmAction];
                    [weakSelf.fileVC presentViewController:col animated:YES completion:nil];
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
            [weakSelf top_presentSendControllerMothodWith:fromPDFDoc password:nil shareType:shareType dispatch:(dispatch_semaphore_t)semaphore];
            [weakSelf.shareArray removeObject:data];
        }
    }
}

- (void)top_presentSendControllerMothodWith:(CGPDFDocumentRef )fromPDFDoc password:(NSString *)passwordStr shareType:(NSString *)shareType dispatch:(dispatch_semaphore_t)semaphore {
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
                [[NSNotificationCenter defaultCenter] postNotificationName:TOP_TRRemoveScreenhostView object:nil];
                [weakSelf top_getRootVC];
            });
        }
    }];
}

- (void)top_getRootVC{
    [self.fileVC dismissViewControllerAnimated:YES completion:nil];
    UIViewController * topVC = [TOPDocumentHelper top_appRootViewController];
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
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [FIRAnalytics logEventWithName:@"appDidEnterBackground" parameters:nil];
    [TOPScanerShare top_writeAppLockState:NO];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:TOP_TRCodeReaderReStatr object:nil];
    NSInteger openAdCount = [TOPScanerShare top_saveAppOpenAdCount];
    openAdCount++;
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self top_restorPresentAd:openAdCount];
                [TOPScanerShare top_writeSaveAppOpenAdCount:openAdCount];
            });
        }];
    } else {
        [self top_restorPresentAd:openAdCount];
        [TOPScanerShare top_writeSaveAppOpenAdCount:openAdCount];
    }
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}
#pragma mark -- 开屏广告
- (void)top_restorPresentAd:(NSInteger)openAdCount{
    if (![TOPPermissionManager top_enableByAdvertising]) {
        if (openAdCount % 3 == 0) {
            if (![[TOPDocumentHelper top_topViewController] isKindOfClass:[TOPGuideVC class]]&&![[TOPDocumentHelper top_topViewController] isKindOfClass:[TOPSubscribeVC class]]) {
                [self tryToPresentAd];
            }
        }
    }
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    _count = 0;
    if (!self.isOpenUrl) {
        [TOPScanerShare top_writeIsShareExtension:[NSURL new]];
        if (![TOPScanerShare top_appLockState]) {
            if ([TOPScanerShare shared].isFirstShow) {
                [TOPScanerShare shared].isFirstShow = NO;
                [self top_didBecomeActive];
            }
        }
    } else {
        self.isOpenUrl = NO;
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[TOPInAppStoreObserver shareInstance] topRemoveTransactionObserver];
}


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions{
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (IS_IPAD) {
        return UIInterfaceOrientationMaskAll;
    }else{
        if (self.allowRotation) {
            return UIInterfaceOrientationMaskLandscapeRight;
        } else {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
}

- (void)top_didBecomeActive
{
    BOOL isAppSafeStates = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeStates] boolValue];
    if (isAppSafeStates) {
        
        NSInteger currentType = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeUnLockType] integerValue];
        switch (currentType) {
            case TOPAppSetSafeUnlockTypePwd:
            {
                TOPAppSafeShowPasswordVC *setpwdVC = [[TOPAppSafeShowPasswordVC alloc] init];
                TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:setpwdVC];
                setpwdVC.setSafePsdState = TOPAppSetSafePasswordStateSafeInLocalInput;
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                
                [[TOPDocumentHelper top_topViewController] presentViewController:nav animated:YES completion:nil];
            }
                break;
            case TOPAppSetSafeUnlockTypeTouchID:
            {
                TOPTouchUnlockViewController *setpwdVC = [[TOPTouchUnlockViewController alloc] init];
                TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:setpwdVC];
                
                setpwdVC.unlockType = TOPAppSetSafeUnlockTypeTouchID;
                setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateLocalInput;
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [[TOPDocumentHelper top_topViewController] presentViewController:nav animated:YES completion:nil];
                
            }
                break;
            case TOPAppSetSafeUnlockTypeFaceID:
            {
                TOPTouchUnlockViewController *setpwdVC = [[TOPTouchUnlockViewController alloc] init];
                TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:setpwdVC];
                
                setpwdVC.unlockType = TOPAppSetSafeUnlockTypeFaceID;
                setpwdVC.systomUnlockType = TOPAppSetTouchAFaceStateLocalInput;
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [[TOPDocumentHelper top_topViewController] presentViewController:nav animated:YES completion:nil];
                
            }
                break;
            default:
                break;
        }
    }
}
- (void)top_settingDarkModelDefault{
    if (@available(iOS 13.0, *)) {
        self.window.overrideUserInterfaceStyle = [TOPScanerShare top_darkModel];
    } else {
    }
    if ([TOPDocumentHelper top_isdark]) {
        self.window.backgroundColor = TOPAppDarkBackgroundColor;
    }else{
        self.window.backgroundColor = [UIColor whiteColor];
    }
}
- (void)top_settingDefaultState{
    [TOPScanerShare shared].isReceive = YES;
    ///设置pdf文档默认大小 和 渲染的默认方式
    if ([TOPScanerShare top_pageSizeType] == 0) {
        [TOPScanerShare top_writePageSizeType:2];
    }
    
    if ([TOPScanerShare top_defaultProcessType] == 0) {
        [TOPScanerShare top_writeDefaultProcessType:TOPProcessTypeMagicColor];
    }
    
    ///首页默认排列方式
    if ([TOPScanerShare top_listType] == 0) {
        [TOPScanerShare top_writeListType:ShowThreeGoods];
    }
    
    ///homeChildVC图片默认排列顺序
    if ([TOPScanerShare top_childViewByType] == 0) {
        [TOPScanerShare top_writeChildViewByType:1];
    }
    
    ///homeChildVC默认图片详情模式
    if ([TOPScanerShare top_childHideDetailType] == 0) {
        [TOPScanerShare top_writeChildHideDetailType:1];
    }
    
    ///folder的默认位置
    if ([TOPScanerShare top_homeFolderTopOrBottom] == 0) {
        [TOPScanerShare top_writeHomeFolderTopOrBottom:1];
    }
    ///默认是否保存到Gallery
    if ([TOPScanerShare top_saveToGallery] == 0) {
        [TOPScanerShare top_writeSaveToGallery:TOPSettingSaveNO];
    }
    
    ///默认是否保存原图
    if ([TOPScanerShare top_saveOriginalImage] == 0) {
        [TOPScanerShare top_writeSaveOriginalImage:TOPSettingSaveYES];
    }
    
    ///默认是否做相机的批量裁剪
    if ([TOPScanerShare top_saveBatchImage] == 0) {
        [TOPScanerShare top_writeSaveBatchImage:TOPSettingSaveYES];
    }
    
    ///给设置email设置一个默认的空值
    TOPSettingEmailModel * emailModel = [NSKeyedUnarchiver unarchiveObjectWithFile:TOPSettingEmail_Path];
    if (!emailModel) {
        TOPSettingEmailModel * model = [TOPSettingEmailModel new];
        [NSKeyedArchiver archiveRootObject:model toFile:TOPSettingEmail_Path];
    }
    ///首页相机默认位置
    if ([TOPScanerShare top_saveDragViewLoction] == nil) {
        NSArray * array = @[@(TOPScreenWidth - 95),@(TOPScreenHeight - TOPNavBarAndStatusBarHeight - 100),@(80),@(80)];
        [TOPScanerShare top_writeDragViewLoction:array];
    }
    
    ///给设置document默认名称时 设置一个
    TOPSettingFormatModel * formatModel = [NSKeyedUnarchiver unarchiveObjectWithFile:TOPSettingFormatter_Path];
    if (!formatModel) {
        TOPSettingFormatModel * model = [TOPSettingFormatModel new];
        model.formatString = @"Doc MMM dd, yyyy, HH.mm";
        [NSKeyedArchiver archiveRootObject:model toFile:TOPSettingFormatter_Path];
    }else{///将以前版本本地保存的数据替换掉
        if ([formatModel.formatString isEqualToString:@"Doc MMM dd yyyy HH.mm"]||[formatModel.formatString isEqualToString:@"Doc MMM dd yy HH.mm"]) {
            formatModel.formatString = @"Doc MMM dd, yyyy, HH.mm";
        }
        if ([formatModel.formatString isEqualToString:@"Doc MMM dd yyyy"]||[formatModel.formatString isEqualToString:@"Doc MMM dd yy"]) {
            formatModel.formatString = @"Doc MMM dd, yyyy";
        }
        if ([formatModel.formatString isEqualToString:@"MMM dd yyyy HH.mm"]||[formatModel.formatString isEqualToString:@"MMM dd yy HH.mm"]) {
            formatModel.formatString = @"MMM dd, yyyy, HH.mm";
        }
        if ([formatModel.formatString isEqualToString:@"MMM dd yyyy"]||[formatModel.formatString isEqualToString:@"MMM dd yy"]) {
            formatModel.formatString = @"MMM dd, yyyy";
        }
        [NSKeyedArchiver archiveRootObject:formatModel toFile:TOPSettingFormatter_Path];
    }
    
    ///ocr默认语言
    if ([TOPScanerShare top_saveOcrLanguage] == nil) {
        NSDictionary * dic = @{@"English - eng":@"eng"};
        [TOPScanerShare top_writeSaveOcrLanguage:dic];
    }
    NSInteger iCloudOpen = [[[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudOpen"] integerValue];
    if (iCloudOpen==0) {
        [[NSUserDefaults standardUserDefaults ] setInteger:2 forKey:@"iCloudOpen"];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
    
    ///判断数据结构的类型 若是以前版本的进行更改数据结构的操作 是当前版本的数据结构不做修改
    [self top_judgePathType];
    ///删除原来的数据
    for (NSString * pathString in self.saveArray) {
        [TOPWHCFileManager top_removeItemAtPath:pathString];
    }
    ///记录进入app次数
    NSInteger count = [TOPScanerShare top_theCountEnterApp];
    count++;
    [TOPScanerShare top_writeEnterAppCount:count];
    ///从有广告开始记录进入app的次数
    NSInteger adCount = [TOPScanerShare top_saveInterstitialAdCount];
    adCount++;
    [TOPScanerShare top_writeSaveInterstitialAdCount:adCount];
    NSInteger showSubscriptNum = [TOPScanerShare top_showSubscriptViewNum];
    ///记录订阅弹框显示进入app次数
    if (showSubscriptNum <8) {
        NSInteger subBecomeCount = [TOPScanerShare top_subscriptBecomeNum];
        subBecomeCount ++;
        [TOPScanerShare top_writeSubscriptBecomeNum:subBecomeCount];
    }
    ///弹框是否弹出过 默认没有弹出
    if (![TOPScanerShare top_savesScoreBox]) {
        [TOPScanerShare top_writeSaveScoreBox:NO];
    }
    ///记录进入app次数 这个是评分的时候用到
    NSInteger scoreNum = [TOPScanerShare top_saveScoreBoxNumber];
    scoreNum++;
    [TOPScanerShare top_writeSaveScoreBoxNumber:scoreNum];
    [self top_recordDeviceEnterNumber];
    ///设置当前时间3天后的日期
    if ([TOPScanerShare top_saveThreeDataLater] == nil) {
        NSString * timeString = [TOPDocumentHelper top_getTimeAfterNowWithDay:3];
        [TOPScanerShare top_writeSaveThreeDataLater:timeString];
    }
    
    ///设置当前时间天后的日期
    if ([TOPScanerShare top_saveOneDataLater] == nil) {
        NSString * timeString = [TOPDocumentHelper top_getTimeAfterNowWithDay:1];
        [TOPScanerShare top_writeSaveOneDataLater:timeString];
    }
    
    ///设置默认保存的标签名称
    if ([TOPScanerShare top_saveTagsName] == nil) {
        [TOPScanerShare top_writeSaveTagsName:TOP_TRTagsAllDocesKey];
    }
    
    if (![TOPScanerShare top_pdfPageAdjustmentBottomViewShow]) {
        [TOPScanerShare top_writepdfPageAdjustmentBottomViewShow:NO];
    }
    
    ///相机闪光灯的默认状态
    if (![TOPScanerShare top_cameraFlashType]) {
        [TOPScanerShare top_writeCameraFlashType:TOPCameraFlashTypeOff];
    }
    
    if ([TOPScanerShare top_documentDateType] == nil) {
        NSString *languageCode = [NSLocale  currentLocale].languageCode;///当前设置的首选语言
        NSString * dateType = [NSString new];
        if ([languageCode isEqual:@"zh"]) {
            dateType = @"yyyy/MM/dd HH:mm";
        }else{
            dateType = @"MM/dd/yyyy HH:mm";
        }
        [TOPScanerShare top_writeDocumentDateType:dateType];
    }
    
    NSInteger type = [TOPScanerShare top_sortType];
    if ([TOPScanerShare top_theCountEnterApp]>1) {///保证老用户只走一次下面的方法
        if (![TOPScanerShare top_updateOldUserDocTime]) {
            if (type == FolderDocumentCreateDescending) {
                type = FolderDocumentUpdateDescending;
            }
            if (type == FolderDocumentCreateAscending) {
                type = FolderDocumentUpdateAscending;
            }
            [TOPScanerShare top_writSortType:type];
            [TOPScanerShare top_writeUpdateOldUserDocTime:YES];
        }
    }
    ///childVC列表展示类型
    if ([TOPScanerShare top_saveChildVCListType] == 0) {
        [TOPScanerShare top_writeSaveChildVCListType:TOPChildVCListTypeSecond];
    }
}

#pragma mark -- 权限设置
- (void)top_setFunctionPermission {
    NSString *appVersion = [TOPAppTools getAppVersion];
    NSString *user_version = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_version"];
    if (!user_version.length) {
        if ([TOPScanerShare top_theCountEnterApp] > 1) {
            user_version = oldVersion;
        } else {
            user_version = appVersion;
        }
        [[NSUserDefaults standardUserDefaults] setValue:user_version forKey:@"user_version"];
    }
    [TOPUserInfoManager shareInstance].isOld = [TOPAppTools compareVersion:user_version WithVersionApp:openVersion];
    if (TOP_TRSSMaxPiexl == 8000000) {
        if (![TOPPermissionManager top_enableByImageHigh]) {
            [[NSUserDefaults standardUserDefaults] setFloat:6000000 forKey:TOP_TRSSMaxPiexlKey];
        }
    }
    if (TOP_TRSSMaxPiexl == 10000000) {
        if (![TOPPermissionManager top_enableByImageSuperHigh]) {
            [[NSUserDefaults standardUserDefaults] setFloat:6000000 forKey:TOP_TRSSMaxPiexlKey];
        }
    }
    if ([TOPScanerShare top_pdfNumberType] > 0) {
        if (![TOPPermissionManager top_enableByPDFPageNO]) {
            [TOPScanerShare top_writeSavePDFNumberType:TOPPDFPageNumLayoutTypeNull];
        }
    }
    if ([[TOPScanerShare top_pdfPassword] length] > 0) {
        if (![TOPPermissionManager top_enableByPDFPassword]) {
            [TOPScanerShare top_writePDFPassword:@""];
        }
    }
}

#pragma mark -- 记录不同设备进入app的次数
- (void)top_recordDeviceEnterNumber{
    if (IS_IPAD) {
        NSInteger count = [TOPScanerShare top_saveIpadEnterNumber];
        count++;
        [TOPScanerShare top_writeSaveIpadEnterNumber:count];
        [FIRAnalytics logEventWithName:@"simpleScanIpad" parameters:nil];
    }else{
        NSInteger count = [TOPScanerShare top_saveIphoneEnterNumber];
        count++;
        [TOPScanerShare top_writeSaveIphoneEnterNumber:count];
        [FIRAnalytics logEventWithName:@"simpleScanIphone" parameters:nil];
    }
}
+ (AppDelegate *) top_getAppDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDWebImageManager sharedManager] cancelAll];
    [self top_cleanCacheAndCookie];
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(nonnull NSCoder *)coder{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(nonnull NSCoder *)coder{
    return YES;
}

-(void)top_cleanCacheAndCookie{
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
    }];
    
}

- (void)top_judgePathType{
    NSString * pathString = [TOPDocumentHelper top_appBoxDirectory];
    NSString * componentFondersStr = [NSString stringWithFormat:@"%@/%@",pathString,@"Folders"];
    
    NSArray *blFdArray = [TOPDocumentHelper top_getCurrentFileAndPath:componentFondersStr];
    
    if (blFdArray.count>0) {
        NSString * getTempString = [NSString new];
        for (NSString * tempStr in blFdArray) {
            NSString *fullStr = [NSString stringWithFormat:@"%@/%@",componentFondersStr,tempStr];
            NSArray *dirArray = [TOPDocumentHelper top_getCurrentFileAndPath:fullStr];
            if (dirArray.count>0) {
                getTempString = fullStr;
            }
        }
        
        NSArray * dirArray = [NSArray new];
        if (getTempString.length>0) {
            dirArray = [TOPDocumentHelper top_getCurrentFileAndPath:getTempString];
        }
        if (dirArray.count <3) {
            if (dirArray.count == 1) {
                if ([dirArray containsObject:@"Documents"]||[dirArray containsObject:@"Folders"]) {
                    NSString * componentFirst = [NSString stringWithFormat:@"%@/%@",getTempString,dirArray[0]];
                    if ([TOPWHCFileManager top_isDirectoryAtPath:componentFirst]) {
                        if ([TOPDocumentHelper top_getCurrentFileAndPath:componentFirst].count>0) {
                            [self top_changeAllDocumentPath];
                        }
                    }
                }
            }
            
            if (dirArray.count == 2) {
                if ([dirArray containsObject:@"Documents"]&&[dirArray containsObject:@"Folders"]) {
                    NSString * componentFirst = [NSString stringWithFormat:@"%@/%@",getTempString,dirArray[0]];
                    NSString * componentSecd = [NSString stringWithFormat:@"%@/%@",getTempString,dirArray[1]];
                    if ([TOPWHCFileManager top_isDirectoryAtPath:componentFirst]&&[TOPWHCFileManager top_isDirectoryAtPath:componentSecd]) {
                        if ([TOPDocumentHelper top_getCurrentFileAndPath:componentFirst].count>0||[TOPDocumentHelper top_getCurrentFileAndPath:componentSecd].count>0) {
                            [self top_changeAllDocumentPath];
                        }
                    }
                }
            }
        }
    }
}

- (void)top_changeAllDocumentPath{
    [FIRAnalytics logEventWithName:@"changeAllFolders_DocumentPath" parameters:nil];
    NSString * pathString = [TOPDocumentHelper top_appBoxDirectory];
    NSString * componentFondersStr = [NSString stringWithFormat:@"%@/%@",pathString,@"Folders"];
    NSArray *blFdArray = [TOPDocumentHelper top_getCurrentFileAndPath:componentFondersStr];
    
    if (blFdArray.count>0) {
        for (NSString * fdStr in blFdArray) {
            NSString *fullStr = [NSString stringWithFormat:@"%@/%@",componentFondersStr,fdStr];
            NSMutableArray * documentArray = [NSMutableArray new];
            NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:fullStr documentArray:documentArray];
            NSMutableArray *array = [NSMutableArray arrayWithArray:getArry];
            
            NSMutableArray *oriMutablearray = [@[] mutableCopy];
            NSMutableArray *dateMutablearray = [@[] mutableCopy];
            for (int i = 0; i < array.count; i ++) {
                NSString *string = [[array[i] componentsSeparatedByString:@"/"] lastObject];
                NSMutableArray *tempArray = [@[] mutableCopy];
                [tempArray addObject:array[i]];
                for (int j = i+1; j < array.count; j ++) {
                    NSString *jstring = [[array[j] componentsSeparatedByString:@"/"] lastObject];
                    if([string isEqualToString:jstring]){
                        [tempArray addObject:array[j]];
                        [array removeObjectAtIndex:j];
                        j -= 1;
                    }
                }
                for (int m = 0; m<tempArray.count; m++) {
                    NSString * tempStr = [NSString stringWithFormat:@"%@(%d)",tempArray[m],m+1];
                    [dateMutablearray addObject:tempStr];
                    [oriMutablearray addObject:tempArray[m]];
                }
            }
            
            NSString * getTempString = [NSString stringWithFormat:@"%@/",componentFondersStr];
            for (NSString * tempString in dateMutablearray) {
                NSString * orPath = oriMutablearray[[dateMutablearray indexOfObject:tempString]];
                
                NSString * remainString = [[orPath componentsSeparatedByString:getTempString] lastObject];
                NSString * getHomeFtString = [[remainString componentsSeparatedByString:@"/"] firstObject];
                NSString * saveString = [NSString stringWithFormat:@"%@%@",getTempString,getHomeFtString];
                
                NSString * changeStr = [tempString componentsSeparatedByString:@"/"].lastObject;
                NSString * changePath = [NSString stringWithFormat:@"%@/%@",saveString,changeStr];
                
                [TOPDocumentHelper top_changeBeforeFolder:orPath toChangeFolder:changePath];
            }
            [self.saveArray addObjectsFromArray:oriMutablearray];
        }
    }
}

#pragma mark -- 删除临时文件，统一使用一个临时目录
- (void)top_removeOldTempFile {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isOld = [[NSUserDefaults standardUserDefaults] boolForKey:@"oldTempKey"];
        if (!isOld) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"oldTempKey"];
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRCoverImageFileString]];
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRCropImageFileString]];
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRLongImageFileString]];
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRPDFString]];
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBelongDocumentPathString:@"Compress"]];
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRCamearPathString]];
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBelongDocumentPathString:@"DefaultDrawPath"]];
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRDrawingImageFileString]];
            [TOPWHCFileManager top_removeItemAtPath:[TOPDocumentHelper top_getBelongDocumentPathString:@"SignationImagePath"]];
        }
    });
}

#pragma mark -- 设置默认的最大图片像素
- (void)top_settingJPGMaxPiexl {
    if (TOP_TRSSMaxPiexl <= 0 || TOP_TRSSMaxPiexl >= 8000000.00) {
        [[NSUserDefaults standardUserDefaults] setFloat:6000000.00 forKey:TOP_TRSSMaxPiexlKey];
    }
}

- (void)top_settingDefaultConfig {
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:RGB(0, 0, 0)];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:TOP_TRWatermarkTextColorKey];
    BOOL settingDeleteAlert = [[NSUserDefaults standardUserDefaults] boolForKey:@"settingDeleteAlertKey"];
    if (!settingDeleteAlert) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"settingDeleteAlertKey"];
        [TOPScanerShare top_writeDeleteFileAlert:YES];
    }
}

#pragma mark -- 全局配置导航栏
- (void)top_configureNavigationBar {
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
}
#pragma mark -- 沙盒Document目录下的文件迁移至Application Support目录下
- (void)top_migrateDocumentToAppSupportDirectory {
    NSString *documentPath = [TOPWHCFileManager top_documentsDir];
    NSArray *docs = [TOPWHCFileManager top_listFilesInDirectoryAtPath:documentPath deep:NO];
    if (docs.count) {
        for (NSString *tempPath in docs) {
            NSString *filePath = [documentPath stringByAppendingPathComponent:tempPath];
            NSString *targetPath = [TOPDocumentHelper top_getBelongDocumentPathString:tempPath];
            [TOPWHCFileManager top_moveItemAtPath:filePath toPath:targetPath overwrite:YES];
        }
    } else {
        [TOPDocumentHelper top_appBoxDirectory];
    }
}

#pragma mark -- 新的临时目录
- (void)top_initTempFile {
    NSString *temPath = NSTemporaryDirectory();
    NSArray *tempItems = [TOPWHCFileManager top_listFilesInDirectoryAtPath:temPath deep:NO];
    for (NSString *item in tempItems) {
        NSString *itemPath = [temPath stringByAppendingPathComponent:item];
        [TOPWHCFileManager top_removeItemAtPath:itemPath];
    }
    [TOPDocumentHelper top_createTemporaryFile];
}

#pragma mark -- 配置数据库
- (void)top_initDataBase {
    [TOPDBService top_configDBWithIdentifier:@"tr"];
    [TOPDBService top_realmDBMigration];
    
    [self top_clearExpiredFile];
    
    self.loadSuccess = NO;
    __block BOOL outTime = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.homeDataArr = [TOPDataModelHandler top_getTagsListManagerData];
        self.loadSuccess = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (outTime) {
                [SVProgressHUD dismiss];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHomeData" object:nil];
            }
        });
    });
    [NSThread sleepForTimeInterval:1.0];
    if (!self.loadSuccess) {
        outTime = YES;
    }
}

#pragma mark -- 清除过期文件 -- 30天
- (void)top_clearExpiredFile {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TOPBinDataHandler top_checkExpiredFile];
    });
}
#pragma mark -- lazy
- (NSMutableArray *)saveArray{
    if (!_saveArray) {
        _saveArray = [NSMutableArray new];
    }
    return _saveArray;
}

- (NSMutableArray *)skipArray{
    if (!_skipArray) {
        _skipArray = [NSMutableArray new];
    }
    return _skipArray;
}

- (NSMutableArray *)shareArray{
    if (!_shareArray) {
        _shareArray = [NSMutableArray new];
    }
    return _shareArray;
}

- (NSMutableArray *)saveOriginalPathArray{
    if (!_saveOriginalPathArray) {
        _saveOriginalPathArray = [NSMutableArray new];
    }
    return _saveOriginalPathArray;
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
API_AVAILABLE(ios(10.0)){
    if (@available(iOS 10.0, *)) {
        completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
    } else {
    }
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    
    NSString *identifier =  response.notification.request.identifier;
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if ([userInfo.allKeys containsObject:@"docModel"]&&[userInfo.allKeys containsObject:@"upperPathString"]) {
        DocumentModel * docModel = [DocumentModel mj_objectWithKeyValues:userInfo[@"docModel"]];
        NSString * upperPathString = userInfo[@"upperPathString"];
        NSLog(@"-----------%@ docModel==%@",identifier,docModel);
        TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
        childVC.docModel = docModel;
        childVC.pathString = docModel.path;
        childVC.upperPathString = upperPathString;
        childVC.hidesBottomBarWhenPushed = YES;
        [[TOPDocumentHelper top_topViewController].navigationController pushViewController:childVC animated:YES];
    }
    
    completionHandler();
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"userInfo=%@",userInfo);
    CKNotification *note = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
    if (note.notificationType == CKNotificationTypeQuery)
    {
        CKQueryNotification *queryNote = (CKQueryNotification *)note;
        CKRecordID *recordID = [queryNote recordID];
    }
    completionHandler(UIBackgroundFetchResultNewData);
    if(application.applicationState==UIApplicationStateInactive){
    }
}

- (void)registerAPNApplication:(UIApplication *)application {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        center.delegate = self;
        [center removeAllPendingNotificationRequests];
    }
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(nonnull UIApplicationShortcutItem *)shortcutItem completionHandler:(nonnull void (^)(BOOL))completionHandler {
    [self top_backToRootViewController];
    if ([shortcutItem.type isEqualToString:ShortcutItemLibrary]) {
        [FIRAnalytics logEventWithName:@"shortcut_library" parameters:nil];
        [self systemLibrary];
    } else if ([shortcutItem.type isEqualToString:ShortcutItemSingle]) {
        [FIRAnalytics logEventWithName:@"shortcut_single" parameters:nil];
        [self scanAction:TOPScameraTakeModeSingle];
    } else if ([shortcutItem.type isEqualToString:ShortcutItemBatch]) {
        [FIRAnalytics logEventWithName:@"shortcut_batch" parameters:nil];
        [self scanAction:TOPScameraTakeModeBatch];
    }
}

- (NSArray *)shortCutItems {
    UIApplicationShortcutIcon *libraryIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"top_short_library"];
    UIApplicationShortcutItem *search = [[UIApplicationShortcutItem alloc] initWithType:ShortcutItemLibrary localizedTitle:NSLocalizedString(@"topscan_shortlibrary", @"") localizedSubtitle:nil icon:libraryIcon userInfo:nil];
    
    UIApplicationShortcutIcon *singleIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"top_short_single"];
    UIApplicationShortcutItem *public = [[UIApplicationShortcutItem alloc] initWithType:ShortcutItemSingle localizedTitle:NSLocalizedString(@"topscan_singlescan", @"") localizedSubtitle:nil icon:singleIcon userInfo:nil];
    
    UIApplicationShortcutIcon *batchIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"top_short_batch"];
    UIApplicationShortcutItem *list = [[UIApplicationShortcutItem alloc] initWithType:ShortcutItemBatch localizedTitle:NSLocalizedString(@"topscan_batchscan", @"") localizedSubtitle:nil icon:batchIcon userInfo:nil];
    
    return @[list, public, search];
}

#pragma mark -- 拍照模式
- (void)scanAction:(TOPScameraTakeMode)takeModel {
    [TOPScanerShare top_writeCameraTakeMode:takeModel];
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = [TOPDocumentHelper top_appBoxDirectory];
    camera.fileType = TOPShowFolderCameraType;
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
}

#pragma mark ---到系统相册
- (void)systemLibrary {
    TOPBaseNavViewController *navVC = (TOPBaseNavViewController *)self.window.rootViewController;
    UIViewController* vc = navVC.viewControllers.firstObject;
    if ([vc isKindOfClass:[TOPHomeViewController class]]) {
        TOPHomeViewController * homVC = (TOPHomeViewController *)vc;
        [homVC top_HomeHeaderCameraPicture];
    }
}

- (NSMutableArray *)airDropFiles {
    if (!_airDropFiles) {
        _airDropFiles = @[].mutableCopy;
    }
    return _airDropFiles;
}

- (NSMutableArray *)homeDataArr {
    if (!_homeDataArr) {
        _homeDataArr = @[].mutableCopy;
    }
    return _homeDataArr;
}

- (void)tryToPresentAd{
    if (self.appOpenAd && [self wasLoadTimeLessThanNHoursAgo:4]) {
        UIViewController *rootController = [TOPDocumentHelper top_topViewController];
        [self.appOpenAd presentFromRootViewController:rootController];
        self.appOpenAd = nil;
        [FIRAnalytics logEventWithName:@"homeView_openAd" parameters:nil];
    } else {
        [self requestAppOpenAd];
    }
}

- (BOOL)wasLoadTimeLessThanNHoursAgo:(int)n {
    NSDate *now = [NSDate date];
    NSTimeInterval timeIntervalBetweenNowAndLoadTime = [now timeIntervalSinceDate:self.loadTime];
    double secondsPerHour = 3600.0;
    double intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour;
    return intervalInHours < n;
}

- (void)requestAppOpenAd {
    self.appOpenAd = nil;
    NSString * adID = @"ca-app-pub-3940256099942544/5662855259";
    adID = [TOPDocumentHelper top_AppOpenAdID][0];
    [GADAppOpenAd loadWithAdUnitID:adID
                           request:[GADRequest request]
                       orientation:UIInterfaceOrientationPortrait
                 completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
        if (error) {
            NSLog(@"Failed to load app open ad: %@", error);
            return;
        }
        self.appOpenAd = appOpenAd;
        self.appOpenAd.fullScreenContentDelegate = self;
        self.loadTime = [NSDate date];
        [self tryToPresentAd];
    }];
}


@end
