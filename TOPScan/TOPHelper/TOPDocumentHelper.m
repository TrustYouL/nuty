#import "TOPDocumentHelper.h"
#import <UserNotifications/UserNotifications.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "TOPCurrentTimeFormatter.h"

#import "sys/utsname.h"
@implementation TOPDocumentHelper
+(void)top_initializationFolder{
    NSString *documetsPath =  [TOPDocumentHelper top_getBelongDocumentPathString:@"Documents"];
    NSString *foldersPath =  [TOPDocumentHelper top_getBelongDocumentPathString:@"Folders"];
    NSString *tagsPath =  [TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString];
    
    BOOL isHaveDocuments = [TOPWHCFileManager top_isExistsAtPath:documetsPath];
    BOOL isHaveFolders = [TOPWHCFileManager top_isExistsAtPath:foldersPath];
    BOOL isHaveTags = [TOPWHCFileManager top_isExistsAtPath:tagsPath];
    if (!isHaveDocuments) {
        [TOPWHCFileManager top_createDirectoryAtPath:documetsPath];
    }
    if (!isHaveFolders) {
        [TOPWHCFileManager top_createDirectoryAtPath:foldersPath];
    }
    if (!isHaveTags) {
        [TOPWHCFileManager top_createDirectoryAtPath:tagsPath];
    }
}

+(void)top_creatGalleryFolder:(NSString *)folderName{
    PHFetchResult *collectonResults = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    __block BOOL isExisted = NO;
    //对获取的集合进行遍历
    [collectonResults enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection * assetCollection = obj;
        if ([assetCollection.localizedTitle isEqualToString:folderName]) {
            isExisted = YES;
        }
    }];
    
    if (!isExisted) {//不存在文件夹就创建 存在了就不再创建
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //添加文件夹
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:folderName];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"创建相册文件夹成功");
            }else{
                NSLog(@"创建相册文件夹失败");
            }
        }];
    }
}

+ (UIViewController *)top_topViewController{
    UIViewController *topViewController = [[UIApplication sharedApplication].keyWindow rootViewController];
    while (true) {
        if (topViewController.presentedViewController){
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]){
            topViewController = [(TOPBaseNavViewController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]){
            TOPMainTabBarController *tab = (TOPMainTabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else if ([topViewController isKindOfClass:[UIAlertController class]]){
            topViewController = topViewController.presentingViewController;
            UIAlertController *preVC = (UIAlertController *)topViewController.presentedViewController;
            [preVC dismissViewControllerAnimated:NO completion:nil];
            break;
        } else {
            break;
        }
    }
    return topViewController;
}
+ (BOOL)top_getInterfaceOrientationState{
    if (IS_IPAD) {
        for (NSDictionary * classDic in [self top_getSCVCClassData]) {
            if (classDic.allKeys.count) {
                NSString * className = classDic.allKeys[0];
                BOOL vcState = [classDic[className] boolValue];
                if ([[self top_topViewController] isKindOfClass:[NSClassFromString(className) class]]) {
                    return vcState;
                }
            }
        }
    }
    return YES;
}
+ (UIViewController * )top_getPushVC{
    UIViewController *RootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    TOPMainTabBarController * mainTab = (TOPMainTabBarController *)RootVC;
    TOPBaseNavViewController * baseVC = mainTab.selectedViewController;
    UIViewController * vc = baseVC.childViewControllers.lastObject;
    return vc;
}
+ (void)top_getNetworkState{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager ] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case -1:
                NSLog(@"未知网络");
                break;
            case 0:
                NSLog(@"网络不可达");
                break;
            case 1:
                NSLog(@"GPRS网络");
                break;
            case 2:
                NSLog(@"wifi网络");
                break;
            default:
                break;
        }
        if(status ==AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi)
        {
            NSLog(@"有网");
        }else
        {
            NSLog(@"没有网");
            [self top_showAlertControllerStyleAlertTitle:NSLocalizedString(@"topscan_networkstate", @"") message:NSLocalizedString(@"topscan_networkstatecontent", @"")];
        }
        [TOPScanerShare top_writeSaveNetworkState:status];
    }];
}

+ (void)top_showAlertControllerStyleAlertTitle:(NSString *)title message:(NSString *)message{
    TOPSCAlertController *actionSheet = [TOPSCAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_setting", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        return;
    }];
    
    UIAlertAction *alertF = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        NSLog(@"点击了取消");
        
    }];
    [actionSheet addAction:okAction];
    [actionSheet addAction:alertF];
    [[self top_topViewController] presentViewController:actionSheet animated:YES completion:nil];
}

+(void)top_saveImagePathArray:(NSArray *)imagePathArray toFolder:(NSString *)folderName tipShow:(BOOL)isShow showAlter:(nonnull void (^)(BOOL))success{
    //标识 保存到相册中的标识
    //       __block NSString * localIdentifier;
    PHFetchResult * collectonResults = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    __block BOOL isExisted = NO;
    if (isShow) {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }
    //对获取到的集合进行遍历
    [collectonResults enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection * assetCollection = obj;
        if (!isExisted) {//防止相册文件夹名称相同时 多次写入图片 保证只写入图片到一个文件夹
            if ([assetCollection.localizedTitle isEqualToString:folderName]) {
                isExisted = YES;
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    //请求创建一个Asset
                    for (id imagePath in imagePathArray) {
                        if ([imagePath isKindOfClass:[NSString class]]) {
                            NSURL * url = [NSURL fileURLWithPath:imagePath];
                            PHAssetChangeRequest * assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
                            PHAssetCollectionChangeRequest * collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                            //为Asset创建一个占位符，放到相册编辑请求中
                            PHObjectPlaceholder * placeHoder = [assetRequest placeholderForCreatedAsset];
                            //相册中添加照片
                            [collectionRequest addAssets:@[placeHoder]];
                        }
                        
                        if ([imagePath isKindOfClass:[UIImage class]]) {
                            PHAssetChangeRequest * assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:imagePath];
                            PHAssetCollectionChangeRequest * collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                            //为Asset创建一个占位符，放到相册编辑请求中
                            PHObjectPlaceholder * placeHoder = [assetRequest placeholderForCreatedAsset];
                            //相册中添加照片
                            [collectionRequest addAssets:@[placeHoder]];
                        }
                        
                        if ([imagePathArray indexOfObject:imagePath] == imagePathArray.count-1) {
                        }
                    }
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        NSLog(@"写入图片成功");
                        if (isShow) {
                            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_savetogallery", @"")];
                            [SVProgressHUD dismissWithDelay:1];
                        }
                    }else{
                        [SVProgressHUD dismiss];
                        NSLog(@"写入图片失败");
                    }
                }];
            }
        }
    }];
    NSLog(@"isExisted==%d",isExisted);
    success(isExisted);
}
+ (UIImage *)top_image:(UIImage *)image rotation:(UIImageOrientation)orientation{
    UIImage * newImg = [UIImage new];
    UIImageOrientation imgOrientation = image.imageOrientation;
    UIImageOrientation changeOr = UIImageOrientationRight;
    if (orientation == UIImageOrientationRight) {
        switch (imgOrientation) {
            case UIImageOrientationUp:
                changeOr = UIImageOrientationRight;
                break;
            case UIImageOrientationDown:
                changeOr = UIImageOrientationLeft;
                break;
            case UIImageOrientationLeft:
                changeOr = UIImageOrientationUp;
                break;
            case UIImageOrientationRight:
                changeOr = UIImageOrientationDown;
                break;
            default:
                break;
        }
    }
    
    if (orientation == UIImageOrientationLeft) {
        switch (imgOrientation) {
            case UIImageOrientationUp:
                changeOr = UIImageOrientationLeft;
                break;
            case UIImageOrientationDown:
                changeOr = UIImageOrientationRight;
                break;
            case UIImageOrientationLeft:
                changeOr = UIImageOrientationDown;
                break;
            case UIImageOrientationRight:
                changeOr = UIImageOrientationUp;
                break;
            default:
                break;
        }
    }
    newImg = [UIImage imageWithCGImage:[image CGImage] scale:[image scale] orientation: changeOr];//这里只是改变了图片的imageOrientation属性 imageview加载图片时会根据图片的imageOrientation对图片进行旋转
    NSLog(@"imageOrientation==%ld",newImg.imageOrientation);
    return newImg;
}

//压缩图片
+(UIImage *)top_scaleToSize:(UIImage *)img size:(CGSize)size{
    // 设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}
+ (NSString*)top_creatPDF:(NSArray *)imgArray documentName:(nonnull NSString *)name progress:(nonnull void (^)(CGFloat))progress{
    if (!imgArray.count) {
        return @"";
    }
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * doocumentPath = TOPPDF_Path;
    
    if (![fileManager fileExistsAtPath:doocumentPath]) {
        [fileManager createDirectoryAtPath:doocumentPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [NSString new];
    filePath = [doocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",name]];
    if ([TOPWHCFileManager top_isExistsAtPath:filePath]) {//判断pdf是否有相同名称的
        filePath = [doocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@(1).pdf",name]];
    }
    // CGRectZero 表示默认尺寸，参数可修改，设置自己需要的尺寸
    CGRect current = [self top_getPdfsizeWithType:[TOPScanerShare top_pageSizeType]];
    
    NSString *pdfPassword = [TOPScanerShare top_pdfPassword];
    NSDictionary *tempDict = [pdfPassword length] ? @{
        (NSString *)kCGPDFContextOwnerPassword : pdfPassword,
        (NSString *)kCGPDFContextUserPassword : pdfPassword} : NULL;
    UIGraphicsBeginPDFContextToFile(filePath, current, tempDict);
    
    //pdf每一页的尺寸大小
    CGRect  pdfBounds = UIGraphicsGetPDFContextBounds();
    CGFloat pdfWidth  = pdfBounds.size.width;
    CGFloat pdfHeight = pdfBounds.size.height;
    TOPPDFPageNumLayoutType layoutType = [TOPScanerShare top_pdfNumberType];
    CGFloat scale = pdfWidth / TOPScreenWidth;
    CGFloat marginH = layoutType == TOPPDFPageNumLayoutTypeNull ? 0 : 25 * scale;
    CGFloat fatherH = pdfHeight - marginH * 2;
    for (int i = 0; i<imgArray.count; i++) {
        @autoreleasepool {
            UIImage * image = imgArray[i];
            // 绘制PDF
            //获取每张图片的实际长宽
            CGFloat imageW = image.size.width;
            CGFloat imageH = image.size.height;
            CGRect getRect;
            //每张图居中显示
            //如果图片宽高都小于PDF宽高
            if (imageW <= pdfWidth && imageH <= fatherH)
            {
                CGFloat originX = (pdfWidth - imageW) / 2;
                CGFloat originY = (fatherH - imageH) / 2;
                getRect = CGRectMake(originX, originY, imageW, imageH);
            }
            else
            {
                CGFloat width,height;//缩放图片
                //图片宽高比大于PDF
                if ((imageW / imageH) > (pdfWidth / fatherH))
                {
                    width  = pdfWidth;
                    height = width * imageH / imageW;
                }
                else
                {
                    height = fatherH;
                    width = height * imageW / imageH;
                }
                getRect = CGRectMake((pdfWidth - width) / 2, (pdfHeight - height) / 2, width, height);
            }
            
            UIGraphicsBeginPDFPage();
            
            [self top_drawPageNum:[NSString stringWithFormat:@"%d",(i+1)] layoutType:layoutType pdfSize:CGSizeMake(pdfWidth, pdfHeight)];
            [image drawInRect:getRect];
            NSString * stateStr = [NSString stringWithFormat:@"%.3f",((i+1)*10.00)/((imgArray.count)*10.00)];
            NSLog(@"stateStr==%@",stateStr);
            progress([stateStr doubleValue]);
        }
    }
    UIGraphicsEndPDFContext();
    
    return filePath;
}

#pragma mark -- 绘制页码
+ (void)top_drawPageNum:(NSString *)pageNum layoutType:(TOPPDFPageNumLayoutType)layoutType pdfSize:(CGSize)pdfSize {
    if (layoutType != TOPPDFPageNumLayoutTypeNull) {
        NSString *title = pageNum;
        //段落样式
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        //对齐方式
        NSTextAlignment aligment = NSTextAlignmentNatural;
        switch (layoutType) {
            case TOPPDFPageNumLayoutTypeNull:
                aligment = NSTextAlignmentNatural;
                break;
            case TOPPDFPageNumLayoutTypeTopLeft:
            case TOPPDFPageNumLayoutTypeBottomLeft:
                aligment = NSTextAlignmentNatural;
                break;
            case TOPPDFPageNumLayoutTypeTopCenter:
            case TOPPDFPageNumLayoutTypeBottomCenter:
                aligment = NSTextAlignmentCenter;
                break;
            case TOPPDFPageNumLayoutTypeTopRight:
            case TOPPDFPageNumLayoutTypeBottomRight:
                aligment = NSTextAlignmentRight;
                break;
                
            default:
                break;
        }
        CGFloat scale = pdfSize.width / (TOPScreenWidth - 10 *2);
        NSInteger fontSize = 10 * scale;
        style.alignment = aligment;
        NSDictionary *attribute = @{NSFontAttributeName:PingFang_R_FONT_(fontSize),NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:RGB(53, 53, 53)};
        CGRect pageNumRect = [self top_pageLabelFrame:layoutType scale:scale pdfSize:CGSizeMake(pdfSize.width, pdfSize.height)];
        [title drawInRect:pageNumRect withAttributes:attribute];
    }
}

+ (CGRect)top_pageLabelFrame:(TOPPDFPageNumLayoutType)layoutType scale:(CGFloat)scale pdfSize:(CGSize)pdfSize {
    CGRect frame = CGRectZero;
    switch (layoutType) {
        case TOPPDFPageNumLayoutTypeNull:
            frame = CGRectZero;
            break;
        case TOPPDFPageNumLayoutTypeTopLeft:
        case TOPPDFPageNumLayoutTypeTopCenter:
        case TOPPDFPageNumLayoutTypeTopRight:
            frame = CGRectMake(15 * scale, 15 * scale / 2, pdfSize.width - 15 * scale * 2, 25 * scale);
            break;
        case TOPPDFPageNumLayoutTypeBottomLeft:
        case TOPPDFPageNumLayoutTypeBottomCenter:
        case TOPPDFPageNumLayoutTypeBottomRight:
            frame = CGRectMake(15 * scale, pdfSize.height - 25 * scale + 15 * scale / 2, pdfSize.width - 15 * scale * 2, 25 * scale);
            break;
            
        default:
            break;
    }
    return frame;
}

+ (NSString*)top_creatPDF:(NSArray *)imgArray documentName:(nonnull NSString *)name{
    if (!imgArray.count) {
        return @"";
    }
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * doocumentPath = TOPPDF_Path;
    
    if (![fileManager fileExistsAtPath:doocumentPath]) {
        [fileManager createDirectoryAtPath:doocumentPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [NSString new];
    filePath = [doocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",name]];
    
    // CGRectZero 表示默认尺寸，参数可修改，设置自己需要的尺寸
    CGRect current = [self top_getPdfsizeWithType:[TOPScanerShare top_pageSizeType]];
    NSString *pdfPassword = [TOPScanerShare top_pdfPassword];
    NSDictionary *tempDict = [pdfPassword length] ? @{
        (NSString *)kCGPDFContextOwnerPassword : pdfPassword,
        (NSString *)kCGPDFContextUserPassword : pdfPassword} : NULL;
    UIGraphicsBeginPDFContextToFile(filePath, current, tempDict);
    
    //pdf每一页的尺寸大小
    CGRect  pdfBounds = UIGraphicsGetPDFContextBounds();
    CGFloat pdfWidth  = pdfBounds.size.width;
    CGFloat pdfHeight = pdfBounds.size.height;
    TOPPDFPageNumLayoutType layoutType = [TOPScanerShare top_pdfNumberType];
    CGFloat scale = pdfWidth / TOPScreenWidth;
    CGFloat marginH = layoutType == TOPPDFPageNumLayoutTypeNull ? 0 : 25 * scale;
    CGFloat fatherH = pdfHeight - marginH * 2;
    int i = 0;
    for(UIImage * image in imgArray){
        @autoreleasepool {
            //            UIImage * image = [UIImage imageWithContentsOfFile:imagePath];
            // 绘制PDF
            //获取每张图片的实际长宽
            CGFloat imageW = image.size.width;
            CGFloat imageH = image.size.height;
            CGRect getRect;
            //每张图居中显示
            //如果图片宽高都小于PDF宽高
            if (imageW <= pdfWidth && imageH <= fatherH)
            {
                CGFloat originX = (pdfWidth - imageW) / 2;
                CGFloat originY = (fatherH - imageH) / 2;
                getRect = CGRectMake(originX, originY, imageW, imageH);
            }
            else
            {
                CGFloat width,height;//缩放图片
                //图片宽高比大于PDF
                if ((imageW / imageH) > (pdfWidth / fatherH))
                {
                    width  = pdfWidth;
                    height = width * imageH / imageW;
                }
                else
                {
                    height = fatherH;
                    width = height * imageW / imageH;
                }
                getRect = CGRectMake((pdfWidth - width) / 2, (pdfHeight - height) / 2, width, height);
            }
            
            UIGraphicsBeginPDFPage();
            TOPPDFPageNumLayoutType layoutType = [TOPScanerShare top_pdfNumberType];
            [self top_drawPageNum:[NSString stringWithFormat:@"%d",(i+1)] layoutType:layoutType pdfSize:CGSizeMake(pdfWidth, pdfHeight)];
            [image drawInRect:getRect];
            i ++;
        }
    }
    UIGraphicsEndPDFContext();
    
    return filePath;
}

+ (void )top_creatPDF:(NSArray *)imgArray documentName:(nonnull NSString *)name pageSizeType:(NSInteger)sizeType success:(void (^)(id responseObj))success{
    __block NSString *tempStr;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * doocumentPath = TOPPDF_Path;
        
        if (![fileManager fileExistsAtPath:doocumentPath]) {
            [fileManager createDirectoryAtPath:doocumentPath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        NSString *filePath = [NSString new];
        filePath = [doocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",name]];
        tempStr =  [doocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",name]];
        // CGRectZero 表示默认尺寸，参数可修改，设置自己需要的尺寸
        CGRect current = [self top_getPdfsizeWithType:sizeType];
        UIGraphicsBeginPDFContextToFile(filePath, current, NULL);
        
        //pdf每一页的尺寸大小
        CGRect  pdfBounds = UIGraphicsGetPDFContextBounds();
        CGFloat pdfWidth  = pdfBounds.size.width;
        CGFloat pdfHeight = pdfBounds.size.height;
        
        for (int i = 0; i<imgArray.count; i++) {
            @autoreleasepool {
                UIImage * image = imgArray[i];
                // 绘制PDF
                //获取每张图片的实际长宽
                CGFloat imageW = image.size.width;
                CGFloat imageH = image.size.height;
                CGRect getRect;
                //每张图居中显示
                //如果图片宽高都小于PDF宽高
                if (imageW <= pdfWidth && imageH <= pdfHeight)
                {
                    CGFloat originX = (pdfWidth - imageW) / 2;
                    CGFloat originY = (pdfHeight - imageH) / 2;
                    getRect = CGRectMake(originX, originY, imageW, imageH);
                }
                else
                {
                    CGFloat width,height;//缩放图片
                    //图片宽高比大于PDF
                    if ((imageW / imageH) > (pdfWidth / pdfHeight))
                    {
                        width  = pdfWidth;
                        height = width * imageH / imageW;
                    }
                    else
                    {
                        height = pdfHeight;
                        width = height * imageW / imageH;
                    }
                    getRect = CGRectMake((pdfWidth - width) / 2, (pdfHeight - height) / 2, width, height);
                }
                
                UIGraphicsBeginPDFPage();
                [image drawInRect:getRect];
            }
        }
        UIGraphicsEndPDFContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            success(tempStr);
        });
    });
}

+ (NSString *)top_creatNOPasswordPDF:(NSArray *)imgArray documentName:(NSString *)name progress:(void (^)(CGFloat))progress {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * doocumentPath = TOPPDF_Path;
    
    if (![fileManager fileExistsAtPath:doocumentPath]) {
        [fileManager createDirectoryAtPath:doocumentPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [NSString new];
    filePath = [doocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",name]];
    
    // CGRectZero 表示默认尺寸，参数可修改，设置自己需要的尺寸
    CGRect current = [self top_getPdfsizeWithType:[TOPScanerShare top_pageSizeType]];
    
    UIGraphicsBeginPDFContextToFile(filePath, current, NULL);
    
    //pdf每一页的尺寸大小
    CGRect  pdfBounds = UIGraphicsGetPDFContextBounds();
    CGFloat pdfWidth  = pdfBounds.size.width;
    CGFloat pdfHeight = pdfBounds.size.height;
    for (int i = 0; i<imgArray.count; i++) {
        @autoreleasepool {
            UIImage * image = imgArray[i];
            // 绘制PDF
            //获取每张图片的实际长宽
            CGFloat imageW = image.size.width;
            CGFloat imageH = image.size.height;
            CGRect getRect;
            //每张图居中显示
            //如果图片宽高都小于PDF宽高
            if (imageW <= pdfWidth && imageH <= pdfHeight)
            {
                CGFloat originX = (pdfWidth - imageW) / 2;
                CGFloat originY = (pdfHeight - imageH) / 2;
                getRect = CGRectMake(originX, originY, imageW, imageH);
            }
            else
            {
                CGFloat width,height;//缩放图片
                //图片宽高比大于PDF
                if ((imageW / imageH) > (pdfWidth / pdfHeight))
                {
                    width  = pdfWidth;
                    height = width * imageH / imageW;
                }
                else
                {
                    height = pdfHeight;
                    width = height * imageW / imageH;
                }
                getRect = CGRectMake((pdfWidth - width) / 2, (pdfHeight - height) / 2, width, height);
            }
            
            UIGraphicsBeginPDFPage();
            [image drawInRect:getRect];
            NSString * stateStr = [NSString stringWithFormat:@"%.3f",((i+1)*10.00)/((imgArray.count)*10.00)];
            progress([stateStr doubleValue]);
        }
    }
    UIGraphicsEndPDFContext();
    
    return filePath;
}

+ (CGRect)top_getPdfsizeWithType:(NSInteger)type{
    CGRect current = CGRectZero;
    switch (type) {
        case TOPPDFPageSizeLetter://信纸Letter 1英寸=2.54cm 72像素/尺寸时 设置的像素大小（21.6*（72/2.54),27.9*(72/2.54))。
            current = [self top_getPdfSizeWithWidth:21.6 WithHeight:27.9];
            break;
        case TOPPDFPageSizeA4://A4
            current = [self top_getPdfSizeWithWidth:21.0 WithHeight:29.7];
            break;
        case TOPPDFPageSizeLegal://legal
            current = [self top_getPdfSizeWithWidth:21.6 WithHeight:35.6];
            break;
        case TOPPDFPageSizeA3://A3
            current = [self top_getPdfSizeWithWidth:29.7 WithHeight:42.0];
            break;
        case TOPPDFPageSizeA5://A5
            current = [self top_getPdfSizeWithWidth:14.8 WithHeight:21.0];
            break;
        case TOPPDFPageSizeBusiness://Business
            current = [self top_getPdfSizeWithWidth:8.5 WithHeight:5.5];
            break;
        case TOPPDFPageSizeB4://B4
            current = [self top_getPdfSizeWithWidth:25.0 WithHeight:35.3];
            break;
        case TOPPDFPageSizeB5://B5
            current = [self top_getPdfSizeWithWidth:17.6 WithHeight:25.0];
            break;
        case TOPPDFPageSizeTabloid://Tabloid
            current = [self top_getPdfSizeWithWidth:27.9 WithHeight:43.2];
            break;
        case TOPPDFPageSizeExecutive://Executive
            current = [self top_getPdfSizeWithWidth:18.4 WithHeight:26.7];
            break;
        case TOPPDFPageSizePostcard://Postcard
            current = [self top_getPdfSizeWithWidth:10.0 WithHeight:14.7];
            break;
        case TOPPDFPageSizeFlsa://Flsa
            current = [self top_getPdfSizeWithWidth:21.6 WithHeight:33.0];
            break;
        case TOPPDFPageSizeFlse://Flse
            current = [self top_getPdfSizeWithWidth:22.9 WithHeight:33.0];
            break;
        case TOPPDFPageSizeArch_A://Arch_A
            current = [self top_getPdfSizeWithWidth:23.0 WithHeight:30.5];
            break;
        case TOPPDFPageSizeArch_B://Arch_B
            current = [self top_getPdfSizeWithWidth:30.5 WithHeight:46.0];
            break;
        default:
            break;
    }
    return current;
}

#pragma mark --根据长宽生成相应pdf尺寸 width height是纸张大小 单位是cm
+ (CGRect)top_getPdfSizeWithWidth:(CGFloat)width WithHeight:(CGFloat)height{
    CGRect current = CGRectZero;
    current = CGRectMake(0, 0, width*TOPPDFSizeConversion, height*TOPPDFSizeConversion);
    return current;
}
#pragma mark -- 压缩图片质量 
+ (NSData *)top_compressImageQuality:(UIImage *)image toByte:(NSInteger)maxLength {
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, TOP_TRPicScale);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    return data;
}

#pragma mark -- 保存压缩图片 压缩图片尺寸
+ (NSString *)top_saveResizeImage:(NSString *)imgPath maxCompression:(CGFloat)compression {
    if (![TOPWHCFileManager top_isExistsAtPath:TOPCompress_Path]) {
        [TOPWHCFileManager top_createDirectoryAtPath:TOPCompress_Path];
    }
    NSString *imgName = [TOPWHCFileManager top_fileNameAtPath:imgPath suffix:YES];
    NSString * compressFile = [NSString stringWithFormat:@"%@/%@",TOPCompress_Path, imgName];
    UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
    NSData *compressData = [NSData dataWithContentsOfFile:imgPath];
    UIImage *temp = [TOPPictureProcessTool top_scaleImageWithData:compressData withSize:CGSizeMake(sqrtf(compression) *img.size.width, sqrtf(compression) *img.size.height)];
    compressData = UIImageJPEGRepresentation(temp, TOP_TRPicScale);
    [compressData writeToFile:compressFile atomically:YES];
    
    return compressFile;
}

#pragma mark -- 保存压缩图片 粗略压缩
+ (NSString *)top_saveCompressPDFImage:(NSString *)imgPath maxCompression:(CGFloat)compression{
    if (![TOPWHCFileManager top_isExistsAtPath:TOPCompress_Path]) {
        [TOPWHCFileManager top_createDirectoryAtPath:TOPCompress_Path];
    }
    NSString *imgName = [TOPWHCFileManager top_fileNameAtPath:imgPath suffix:YES];
    NSString * compressFile = [NSString stringWithFormat:@"%@/%@",TOPCompress_Path, imgName];
    UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
    NSData *data = UIImageJPEGRepresentation(img, TOP_TRPicScale*compression);
    [data writeToFile:compressFile atomically:YES];
    return compressFile;
}
#pragma mark -- 保存压缩图片 粗略压缩 （分享图片时用到）
+ (NSString *)top_saveCompressPDFImage:(NSString *)imgPath savePath:(NSString *)savePath maxCompression:(CGFloat)compression{
    if (![TOPWHCFileManager top_isExistsAtPath:TOPCompress_Path]) {
        [TOPWHCFileManager top_createDirectoryAtPath:TOPCompress_Path];
    }
    NSString * compressFile = [NSString stringWithFormat:@"%@/%@",TOPCompress_Path, savePath];
    UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
    NSData *data = UIImageJPEGRepresentation(img, TOP_TRPicScale*compression);
    [data writeToFile:compressFile atomically:YES];
    return compressFile;
}


#pragma mark -- 保存压缩图片，根据设置的比例进行压缩
+ (NSString *)top_saveCompressImage:(NSString *)imgPath maxCompression:(CGFloat)compression {
    if (![TOPWHCFileManager top_isExistsAtPath:TOPCompress_Path]) {
        [TOPWHCFileManager top_createDirectoryAtPath:TOPCompress_Path];
    }
    NSString *imgName = [TOPWHCFileManager top_fileNameAtPath:imgPath suffix:YES];
    NSString * compressFile = [NSString stringWithFormat:@"%@/%@",TOPCompress_Path, imgName];
    UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
    NSInteger fileMemory = [[TOPWHCFileManager top_sizeOfFileAtPath:imgPath] integerValue];
    NSData * compressData = UIImageJPEGRepresentation(img, TOP_TRPicScale * compression);//[self top_compressImageQuality:img toByte:fileMemory * compression];
    CGFloat rateMin = 0, rateMax = 1, rate = 0.8;
    for (int i = 0; i < 6; ++i) {
        rate = (rateMin + rateMax)/2;
        CGFloat faultTolerant = (compressData.length/(fileMemory*1.0)) - compression;
        if (faultTolerant> 0.1) {
            rateMax = rate;
        } else {
            break;
        }
        
        UIImage *temp = [TOPPictureProcessTool top_scaleImageWithData:compressData withSize:CGSizeMake(rate *img.size.width, rate *img.size.height)];
        compressData = UIImageJPEGRepresentation(temp, compression);
    }
    
    BOOL result = [compressData writeToFile:compressFile atomically:YES];
    if (!result) {
        compressFile = nil;
        NSLog(@"压缩图片保存失败");
    }
    return compressFile;
}

#pragma mark -- 保存压缩图片，根据设置的比例进行压缩（分享图片时用到）
+ (NSString *)top_saveCompressImage:(NSString *)imgPath savePath:(NSString *)savePath maxCompression:(CGFloat)compression {
    if (![TOPWHCFileManager top_isExistsAtPath:TOPCompress_Path]) {
        [TOPWHCFileManager top_createDirectoryAtPath:TOPCompress_Path];
    }
    NSString * compressFile = [NSString stringWithFormat:@"%@/%@",TOPCompress_Path, savePath];
    UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
    NSInteger fileMemory = [[TOPWHCFileManager top_sizeOfFileAtPath:imgPath] integerValue];
    NSData * compressData = UIImageJPEGRepresentation(img, TOP_TRPicScale * compression);//[self top_compressImageQuality:img toByte:fileMemory * compression];
    CGFloat rateMin = 0, rateMax = 1, rate = 0.8;
    for (int i = 0; i < 6; ++i) {
        rate = (rateMin + rateMax)/2;
        CGFloat faultTolerant = (compressData.length/(fileMemory*1.0)) - compression;
        if (faultTolerant > 0.1) {
            rateMax = rate;
        } else {
            break;
        }
        
        UIImage *temp = [TOPPictureProcessTool top_scaleImageWithData:compressData withSize:CGSizeMake(rate *img.size.width, rate *img.size.height)];
        compressData = UIImageJPEGRepresentation(temp, compression);
    }
    
    BOOL result = [compressData writeToFile:compressFile atomically:YES];
    if (!result) {
        compressFile = nil;
        NSLog(@"压缩图片保存失败");
    }
    return compressFile;
}
#pragma mark  -- 保存图片到指定目录下
+ (BOOL)top_saveImage:(UIImage *)photoImage atPath:(NSString *)path {
    NSData *imgData = [self top_saveImageForData:photoImage];
    BOOL result = [imgData writeToFile:path atomically:YES];
    return result;
}

+ (NSData *)top_saveImageForData:(UIImage*)photoImage {
    NSData *data = UIImageJPEGRepresentation(photoImage, TOP_TRPicScale);
    return data;
}

#pragma mark -- 保存剪裁展示用的图片
+ (void)top_saveCropShowImage:(UIImage *)photoImage {
    [self top_saveTmpImage:photoImage atTempFile:TOP_TRCropShowImageString];
}

#pragma mark -- 保存剪裁应用的源图片
+ (void)top_saveCropOriginalImage:(UIImage *)photoImage {
    [self top_saveTmpImage:photoImage atTempFile:TOP_TRCropOriginalImageString];
}

#pragma mark -- 保存临时的图片到临时文件
+ (void)top_saveTmpImage:(UIImage *)photoImage atTempFile:(NSString *)fileName {
    NSData *imgData = [self top_saveImageForData:photoImage];
    NSString *tempFilePath = [self top_createTempFileAtPath:[self top_getCropImageFileString]];
    NSString *imagePath = [tempFilePath stringByAppendingPathComponent:fileName];
    [imgData writeToFile:imagePath atomically:YES];
}

#pragma mark -- 创建临时文件
+ (NSString *)top_createTempFileAtPath:(NSString *)path {
    BOOL isHaveFolders = [TOPWHCFileManager top_isExistsAtPath:path];
    if (isHaveFolders) {
        return path;
    }
    [TOPWHCFileManager top_createDirectoryAtPath:path];
    return path;
}

#pragma mark -- 剪裁展示用的图片
+ (UIImage *)top_cropShowImage {
    NSString *path = [[self top_getCropImageFileString] stringByAppendingPathComponent:TOP_TRCropShowImageString];
    UIImage *cropImg = [UIImage imageWithContentsOfFile:path];
    return cropImg;
}

#pragma mark -- 剪裁应用的源图片
+ (UIImage *)top_cropOriginalImage {
    NSString *path = [[self top_getCropImageFileString] stringByAppendingPathComponent:TOP_TRCropOriginalImageString];
    UIImage *cropImg = [UIImage imageWithContentsOfFile:path];
    return cropImg;
}

+(NSMutableArray*)top_getCurrentFileAndPath:(NSString*)str{
    NSMutableArray *documentArray = [NSMutableArray arrayWithArray:[TOPWHCFileManager top_listFilesInDirectoryAtPath:str deep:NO]];
    for (NSString *pathString in documentArray.reverseObjectEnumerator) {
        if ([pathString containsString:@".DS_Store"]) {
            [documentArray removeObject:pathString];
        }else if ([pathString containsString:TOPRSimpleScanOriginalString]){
            [documentArray removeObject:pathString];
        }else if ([pathString containsString:@".tmp"]){
            [documentArray removeObject:pathString];
        }else if ([pathString containsString:TOPRSimpleScanNoteString]){
            [documentArray removeObject:pathString];
        }else if ([pathString containsString:TOP_TRTagsPathString]){
            [documentArray removeObject:pathString];
        }else if([pathString containsString:@".txt"]){
            [documentArray removeObject:pathString];
        }else if([pathString containsString:TOP_TRDocPasswordPathString]){
            [documentArray removeObject:pathString];
        }
    }
    return documentArray;
}

+ (NSArray*)top_getAllJPEGFileForDeep:(NSString*)filePath {
    NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:filePath deep:YES];
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSString *tempContentPath in tempContentsArray) {
        NSString *tempName = [TOPWHCFileManager top_fileNameAtPath:tempContentPath suffix:YES];
        if ([self top_isCoverJPG:tempName]) {
            [temp addObject:tempContentPath];
        }
    }
    return temp;
}

+ (NSArray*)top_getJPEGFile:(NSString*)filePath {
    NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:filePath deep:NO];
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSString *tempContentPath in tempContentsArray) {
        if ([self top_isCoverJPG:tempContentPath]) {
            [temp addObject:tempContentPath];
        }
    }
    return temp;
}

+ (NSArray*)top_getPNGFile:(NSString*)filePath {
    NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:filePath deep:NO];
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSString *tempContentPath in tempContentsArray) {
        if ([self top_isPNGFile:tempContentPath]) {
            [temp addObject:tempContentPath];
        }
    }
    return temp;
}

#pragma mark -- 获取文件夹下所有文件 排序
+ (NSArray *)top_sortItemAthPath:(NSString *)path {
    NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:path deep:NO];
    //排序,根据图片的后几位数字去排序
    NSArray *sortArray = [tempContentsArray sortedArrayUsingComparator:^NSComparisonResult(NSString *tempContentPath1, NSString *tempContentPath2) {
        NSString *sortNO1 = [self top_picSortNO:tempContentPath1];
        NSString *sortNO2 = [self top_picSortNO:tempContentPath2];
        return [sortNO1 compare:sortNO2 options:NSNumericSearch];
    }];
    return sortArray;
}

#pragma mark -- 获取文档下的所有图片 根据数字下标排序--升序
+ (NSArray *)top_sortPicsAtPath:(NSString *)path {
    NSArray *pics = [self top_coverPicArrayAtPath:path];
    return pics;
}


//获取文件创建时间(字符串)
+ (NSString*)top_getCreateTimeString:(NSString*)path{
    NSDate *date = [TOPWHCFileManager top_creationDateOfItemAtPath:path];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+ (NSString*)top_getModifyTimeString:(NSString*)path{
    NSDate *date = [TOPWHCFileManager top_modificationDateOfItemAtPath:path];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:[TOPScanerShare top_documentDateType]];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+ (NSString*)top_getCompareTimeString:(NSString*)path{
    NSDate *date = [TOPWHCFileManager top_modificationDateOfItemAtPath:path];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+ (NSString*)top_appBoxDirectory {
    NSString *topScanBox = [[TOPWHCFileManager top_appSupportDir] stringByAppendingPathComponent:TOP_TRAppBoxString];
    if (![TOPWHCFileManager top_isExistsAtPath:topScanBox]) {
        [TOPWHCFileManager top_createDirectoryAtPath:topScanBox];
    }
    return topScanBox;
}

+ (NSString*)top_getBelongDocumentPathString:(NSString*)str {
    NSString *topScanBox = [self top_appBoxDirectory];
    NSString * rarFilePath = [topScanBox stringByAppendingPathComponent:str];
    
    return rarFilePath;
}

#pragma mark -- 创建一个新的临时目录
+ (void)top_createTemporaryFile {
    NSString * tempPath = [self top_getBelongDocumentPathString:TOP_TRTemporaryString];
    if ([TOPWHCFileManager top_isExistsAtPath:tempPath]) {
        [TOPWHCFileManager top_removeItemAtPath:tempPath];
    }
    [TOPWHCFileManager top_createDirectoryAtPath:tempPath];
}

+ (NSString*)top_getBelongTemporaryPathString:(NSString*)str {
    NSString * tempPath = [self top_getBelongDocumentPathString:TOP_TRTemporaryString];
    NSString * rarFilePath = [tempPath stringByAppendingPathComponent:str];
    return rarFilePath;
}

#pragma mark -- 数据库目录
+ (NSString *)top_getDBPathString {
    NSString * rarFilePath = [self top_getBelongDocumentPathString:@"topscan_DB"];
    //    [TOPWHCFileManager top_removeItemAtPath:rarFilePath];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}

#pragma mark -- Folders路径
+ (NSString *)top_getFoldersPathString {
    NSString * rarFilePath = [self top_getBelongDocumentPathString:TOP_TRFoldersString];
    return rarFilePath;
}

#pragma mark -- Documents路径
+ (NSString *)top_getDocumentsPathString {
    NSString * rarFilePath = [self top_getBelongDocumentPathString:TOP_TRDocumentsString];
    return rarFilePath;
}

#pragma mark -- 存放签名图的文件目录
+ (NSString *)top_getSignaturePathString {
    NSString * rarFilePath = [self top_getBelongDocumentPathString:TOP_TRSignatureImageFileString];
    return rarFilePath;
}

#pragma mark -- 临时目录下：temporary
//保存从系统相册取的图片
+ (NSString *)top_getCamearPathPathString {
    NSString * rarFilePath = [self top_getBelongTemporaryPathString:TOP_TRCamearPathString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}

#pragma mark -- 临时目录下：temporary下 网盘下载存放jpg的临时目录
//网盘下载存放jpg的临时目录
+ (NSString *)top_getDriveDownloadJPGPathPathString
{
    NSString * rarFilePath = [self top_getBelongTemporaryPathString:TOP_TRDownloadFileJPGPathString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}

#pragma mark -- 临时目录下：temporary下 网盘下载存放待拆分PDF的临时目录
//网盘下载存放待拆分PDF的临时目录
+ (NSString *)top_getDriveDownloadPDFPathPathString {
    NSString * rarFilePath = [self top_getBelongTemporaryPathString:TOP_TRDownloadFilePDFPathString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}

#pragma mark -- 临时目录下：temporary下 网盘下载存放待拆分PDF拆分的临时目录
//网盘下载存放待拆分PDF的临时目录
+ (NSString *)top_getDrivePDFBreakPathPathString {
    NSString * rarFilePath = [self top_getBelongTemporaryPathString:TOP_TRDownloadFilePDFBreakPathString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}

#pragma mark -- 存放PDF的目录
+ (NSString *)top_getPDFPathString {
    NSString * rarFilePath = [self top_getBelongTemporaryPathString:TOP_TRPDFString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}

#pragma mark -- 存放txt的目录
+ (NSString *)top_getTxtPathString {
    NSString * rarFilePath = [self top_getBelongTemporaryPathString:TOP_TRTXTPathString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}

#pragma mark -- 存放剪裁图片的临时目录
+ (NSString *)top_getCropImageFileString {
    NSString * rarFilePath = [self top_getBelongTemporaryPathString:TOP_TRCropImageFileString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}

#pragma mark -- 存放批量处理图片时展示图的目录
+ (NSString *)top_getBatchImageFileString {
    NSString * rarFilePath = [self top_getBelongTemporaryPathString:TOP_TRBatchImageFileString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}

#pragma mark -- 存放批量处理图片时的模版图
+ (NSString *)top_getDefaultBatchImageFileString {
    NSString * rarFilePath = [self top_getBelongTemporaryPathString:TOP_TRDefaultBatchImageFileString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}
#pragma mark -- 存放批量处理图片时缩略图图的目录 TOP_TRBatchCoverImageFileString
+ (NSString *)top_getBatchCoverImageFileString {
    NSString * rarFilePath = [self top_getBelongTemporaryPathString:TOP_TRBatchCoverImageFileString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}

#pragma mark -- 存放缩率图的临时目录
+ (NSString *)top_getCoverImageFileString {
    NSString * rarFilePath = [self top_getBelongTemporaryPathString:TOP_TRCoverImageFileString];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}
#pragma mark -- 存放高斯模糊目录
+ (NSString *)top_getGaussianBlurImgFileString{
    NSString * rarFilePath = [self top_getBelongTemporaryPathString:TOP_TRGaussianBlurImgFile];
    if (![TOPWHCFileManager top_isExistsAtPath:rarFilePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:rarFilePath];
    }
    return rarFilePath;
}
#pragma mark -- 存放批量处理图片时展示图的路径
+ (NSString *)top_batchImageFile:(NSString *)fileName {
    NSString * rarFilePath = [[self top_getBatchImageFileString] stringByAppendingPathComponent:fileName];
    return rarFilePath;
}

#pragma mark -- 存放批量处理图片模版图的路径
+ (NSString *)top_defaultBatchImageFile:(NSString *)fileName {
    NSString * rarFilePath = [[self top_getDefaultBatchImageFileString] stringByAppendingPathComponent:fileName];
    return rarFilePath;
}

#pragma mark -- 存放批量处理图片时展示图的路径
+ (NSString *)top_batchCoverImageFile:(NSString *)fileName {
    NSString * rarFilePath = [[self top_getBatchCoverImageFileString] stringByAppendingPathComponent:fileName];
    return rarFilePath;
}

#pragma mark -- 存放缩率图路径
+ (NSString *)top_coverImageFile:(NSString *)fileName {
    NSString * rarFilePath = [[self top_getCoverImageFileString] stringByAppendingPathComponent:fileName];
    return rarFilePath;
}

#pragma mark -- 存放高斯模糊路径
+ (NSString *)top_gaussianBlurImgFileString:(NSString *)fileName {
    NSString * rarFilePath = [[self top_getGaussianBlurImgFileString] stringByAppendingPathComponent:fileName];
    return rarFilePath;
}
#pragma mark -- long image
+ (NSString *)top_longImageFileString {
    NSString *filePath = [self top_getBelongTemporaryPathString:TOP_TRLongImageFileString];
    if (![TOPWHCFileManager top_isExistsAtPath:filePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:filePath];
    }
    NSString * fileName = [NSString stringWithFormat:@"long image_%@%@",[TOPDocumentHelper top_getCurrentTimeAndSendFormatterString:@"MM-dd-yyyy HH.mm.ss"],TOP_TRJPGPathSuffixString];
    NSString * rarFilePath = [filePath stringByAppendingPathComponent:fileName];
    
    return rarFilePath;
}

#pragma mark -- copy image
+ (NSString *)top_copyImageFileString {
    NSString *filePath = [self top_getBelongTemporaryPathString:@"TRCopyFile"];
    if (![TOPWHCFileManager top_isExistsAtPath:filePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:filePath];
    }
    NSString * rarFilePath = [filePath stringByAppendingPathComponent:@"TRCopyImage.jpg"];
    return rarFilePath;
}

#pragma mark -- waterMark image
+ (NSString *)top_waterMarkTextImagePath {
    NSString *filePath = [self top_getBelongTemporaryPathString:TOP_TRWaterMarkImageFileString];
    if (![TOPWHCFileManager top_isExistsAtPath:filePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:filePath];
    }
    NSString * rarFilePath = [filePath stringByAppendingPathComponent:TOP_TRWaterMarkImageJPGString];
    return rarFilePath;
}

#pragma mark -- 拼图的临时文件
+ (NSString *)top_collageImageFileString {
    NSString *filePath = [self top_getBelongTemporaryPathString:TOP_TRCollageImageFileString];
    if (![TOPWHCFileManager top_isExistsAtPath:filePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:filePath];
    }
    return filePath;
}

#pragma mark -- 拼图路径
+ (NSString *)top_collageImagePath:(NSString *)fileName {
    NSString * rarFilePath = [[self top_collageImageFileString] stringByAppendingPathComponent:fileName];
    return rarFilePath;
}

#pragma mark -- 正在渲染处理的图片
+ (NSString *)top_drawingImageFileString {
    NSString *filePath = [self top_getBelongTemporaryPathString:TOP_TRDrawingImageFileString];
    if (![TOPWHCFileManager top_isExistsAtPath:filePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:filePath];
    }
    NSString * rarFilePath = [filePath stringByAppendingPathComponent:TOP_TRDrawingImageJPGString];
    return rarFilePath;
}

+ (NSString *)top_drawingOCRImageFileString {
    NSString *filePath = [self top_getBelongTemporaryPathString:TOP_TROCRDrawingImageFileString];
    if (![TOPWHCFileManager top_isExistsAtPath:filePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:filePath];
    }
    NSString * rarFilePath = [filePath stringByAppendingPathComponent:TOP_TRDrawingImageJPGString];
    return rarFilePath;
}

+ (NSString *)top_actionExtensionFileString {
    NSString *filePath = [self top_getBelongTemporaryPathString:TOP_TRActionExtensionFileString];
    if (![TOPWHCFileManager top_isExistsAtPath:filePath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:filePath];
    }
    return filePath;
}

#pragma mark -- 创建Tags文件夹
+ (NSString *)top_createTagsPath:(NSString *)documentPath{
    NSString * tagsPath = [documentPath stringByAppendingPathComponent:TOP_TRTagsPathString];
    if (![TOPWHCFileManager top_isExistsAtPath:tagsPath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:tagsPath];
    }
    return tagsPath;
}

#pragma mark -- 创建Tags下的文件夹
+ (BOOL)top_createTagsBottomPathTagsPath:(NSString *)tagsPath withCreatePath:(NSString *)pathName{
    NSString * getTagsPath = [tagsPath stringByAppendingPathComponent:pathName];
    if (![TOPWHCFileManager top_isExistsAtPath:getTagsPath]) {
        return [TOPWHCFileManager top_createDirectoryAtPath:getTagsPath];
    }else{
        return YES;
    }
}

#pragma mark -- 当该文件夹是新创建的需要添加标签 只要是新创建的文件夹都会走这个方法 例如doc的合并 拍照裁剪后生成文件夹流程
+ (void)top_createDocumentAddTags:(NSString *)docPath {
    //保存的标签名称 标签名称如果和TOP_TRTagsAllDocesName相同就不写入标签 否则要写入标签
    NSString * tagsName = [TOPScanerShare top_saveTagsName];
    //tags的路径
    NSString * docTagsPath = [docPath stringByAppendingPathComponent:TOP_TRTagsPathString];
    //写入标签的路径
    NSString * tagsPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",TOP_TRTagsPathString,tagsName]];
    //先删除再写入
    [TOPWHCFileManager top_removeItemAtPath:docTagsPath];
    //标签名称不是TOP_TRTagsAllDocesName同时不是TOP_TRTagsUngroupedName 并且tagsPath的文件夹不存在 就写入
    if (![tagsName isEqualToString:TOP_TRTagsAllDocesKey]&&![tagsName isEqualToString:TOP_TRTagsUngroupedKey]&&![TOPWHCFileManager top_isExistsAtPath:tagsPath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:tagsPath];
    }
}

#pragma mark -- 创建doc下的密码文件夹
+ (BOOL)top_creatDocPasswordWithPath:(NSString *)docPath withPassword:(NSString *)password{
    NSString * getlastString = [NSString stringWithFormat:@"%@%@",TOP_TRDocPasswordPathString,password];
    NSString * passwordPath = [docPath stringByAppendingPathComponent:getlastString];
    if (![TOPWHCFileManager top_isExistsAtPath:passwordPath]) {
        return [TOPWHCFileManager top_createDirectoryAtPath:passwordPath];
    }else{
        return YES;
    }
}

#pragma mark -- 如果本地没有默认密码 获取文件中的密码作为本地的默认密码
+ (void)top_defaultPassword{
    NSString * password = [TOPScanerShare top_docPassword];
    NSLog(@"password==%@",password);
    if (password.length == 0) {
        //所有的doc文档
        NSMutableArray  * docArray = [TOPDataModelHandler top_buildSearchDataAtPath:[TOPDocumentHelper top_appBoxDirectory]];
        for (DocumentModel * docModel in docArray) {
            if ([docModel.type isEqualToString:@"1"]) {
                NSString * docPasswordPath = docModel.docPasswordPath;
                if (docPasswordPath.length>0) {
                    //获取默认密码 取第一个密码 如果有多个不一样的密码也取第一个 在写入密码时会将与默认密码不一样的密码删除掉
                    NSArray * getArray = [docPasswordPath componentsSeparatedByString:TOP_TRDocPasswordPathString];
                    [TOPScanerShare top_writeDocPasswordSave:getArray.lastObject];
                    return;
                }
            }
        }
    }
    return;
}
#pragma mark -- 获取选中的数组中有密码的数据
+ (NSMutableArray *)top_getSelectLockState:(NSMutableArray *)homeDataArray{
    NSMutableArray * selectTempArray = [NSMutableArray new];
    for (DocumentModel * model in homeDataArray) {
        if (model.selectStatus) {
            [selectTempArray addObject:model];
        }
    }
    NSMutableArray * folderDocArray = [NSMutableArray new];//保存所有doc的路径
    for (DocumentModel * docModel in selectTempArray) {
        if ([docModel.type isEqualToString:@"1"]) {
            [folderDocArray addObject:docModel.path];
        }else{
            NSMutableArray * tempArray = [NSMutableArray new];
            //获取folder下的doc路径
            NSMutableArray * getArray = [TOPDocumentHelper top_showAllFileWithPath:docModel.path documentArray:tempArray];
            [folderDocArray addObjectsFromArray:[getArray copy]];
        }
    }
    NSMutableArray * passwordArray = [NSMutableArray new];
    for (NSString * docPath in folderDocArray) {
        //根据doc路径拼获取passord文件夹路径
        NSString * passwordPath = [TOPDocumentHelper top_getDocPasswordPathString:docPath];
        if (passwordPath.length>0) {
            [passwordArray addObject:passwordPath];
        }
    }
    return passwordArray;
}
#pragma mark -- 新创建文件夹时的标签处理
+ (void)top_creatNewDocTags:(NSString *)docPath{
    //保存本地的标签名称
    NSString * tagsName = [TOPScanerShare top_saveTagsName];
    //tags的路径
    NSString * docTagsPath = [docPath stringByAppendingPathComponent:TOP_TRTagsPathString];
    //写入标签的路径
    NSString * tagsPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",TOP_TRTagsPathString,tagsName]];
    //先删除tags文件夹 再写入向tags文件夹写入标签
    [TOPWHCFileManager top_removeItemAtPath:docTagsPath];
    //写入的标签名称不是TOP_TRTagsAllDocesName同时不是TOP_TRTagsUngroupedName 并且写入的标签不存在 就写入
    if (![tagsName isEqualToString:TOP_TRTagsAllDocesKey]&&![tagsName isEqualToString:TOP_TRTagsUngroupedKey]&&![TOPWHCFileManager top_isExistsAtPath:tagsPath]) {
        [TOPWHCFileManager top_createDirectoryAtPath:tagsPath];
    }
}
#pragma mark -- 判断Tags文件夹的路径是否存在 存在就返回 不存在返回nil
+ (NSString *)top_getTagsPathString:(NSString *)documentPath{
    NSString * sendPath = [NSString new];
    NSString * tagsPath = [documentPath stringByAppendingPathComponent:TOP_TRTagsPathString];
    if ([TOPWHCFileManager top_isExistsAtPath:tagsPath]) {
        sendPath = tagsPath;
    }
    return sendPath;
}

+ (NSString *)top_getDocPasswordPathString:(NSString *)documentPath{
    NSString * docPassword = [NSString new];
    //获取doc里的所有数据
    NSMutableArray *tempPathArray = [NSMutableArray arrayWithArray:[TOPWHCFileManager top_listFilesInDirectoryAtPath:documentPath deep:NO]];
    for (NSString * tempPath in tempPathArray) {
        NSString * tempPathString = [documentPath stringByAppendingPathComponent:tempPath];
        //判断路径存在并且还要是password文件夹
        if ([tempPath containsString:TOP_TRDocPasswordPathString]&&[TOPWHCFileManager top_isExistsAtPath:tempPathString]&&[TOPWHCFileManager top_isDirectoryAtPath:tempPathString]) {
            docPassword = tempPathString;
            break;
        }
    }
    return docPassword;
}

#pragma mark -- 删除文档密码
+ (void)top_removeDocPassword:(NSString *)docPath {
    //获取doc里的所有数据
    NSArray *tempPathArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:docPath deep:NO];
    for (NSString * tempPath in tempPathArray) {
        NSString * tempPathString = [docPath stringByAppendingPathComponent:tempPath];
        //判断路径存在并且还要是password文件夹
        if ([tempPath containsString:TOP_TRDocPasswordPathString]&&[TOPWHCFileManager top_isExistsAtPath:tempPathString]&&[TOPWHCFileManager top_isDirectoryAtPath:tempPathString]) {
            [TOPWHCFileManager top_removeItemAtPath:tempPathString];
            break;
        }
    }
}

#pragma mark -- 删除文件夹内所有的文档密码
+ (void)top_removePasswordOfFolder:(NSString *)folderPath {
    NSMutableArray * documentArray1 = [NSMutableArray new];
    NSMutableArray * getArry1 = [TOPDocumentHelper top_getAllDocumentsWithPath:folderPath documentArray:documentArray1];
    for (NSString * docPath in getArry1) {
        [self top_removeDocPassword:docPath];
    }

}

+ (NSString*)top_getFileMemorySize:(NSString*)path{
    long long size = [[TOPWHCFileManager top_sizeOfFileAtPath:path] longLongValue];
    return [self top_memorySizeStr:size];
}

+ (NSString*)top_getFileTotalMemorySize:(NSArray *)array{
    long long totalSize = 0;
    for (NSString * path in array) {
        long long size = [[TOPWHCFileManager top_sizeOfFileAtPath:path] longLongValue];
        totalSize +=size;
    }
    return [self top_memorySizeStr:totalSize];
}

+ (NSString *)top_memorySizeStr:(CGFloat)totalSize {
    float unitRate = 1024.0;
    float foldSize = totalSize / (unitRate * unitRate);
    float foldSize1= totalSize / unitRate;
    float flodSize2 = totalSize / (unitRate*unitRate*unitRate);
    if (foldSize < 1) {
        //就显示kb
        return [NSString stringWithFormat:@"%.fK",foldSize1];
    }else if (foldSize >=1  && foldSize < unitRate){
        //就显示M
        return [NSString stringWithFormat:@"%.2fM",foldSize];
    }else{
        //就显示G
        return [NSString stringWithFormat:@"%.2fG",flodSize2];
    }
}

+ (CGFloat)top_totalMemorySize:(NSArray *)array {
    long long totalSize = 0;
    for (NSString * path in array) {
        long long size = [[TOPWHCFileManager top_sizeOfFileAtPath:path] longLongValue];
        totalSize +=size;
    }
    float foldSize = totalSize * 1.0;
    return foldSize;
}

+ (NSString*)top_getSourceFilePath:(NSString*)path fileName:(NSString*)fileName {
    NSString *sourcePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",TOPRSimpleScanOriginalString,fileName]];
    return sourcePath;
}

+(NSString*)top_createFolders:(NSString*)path{
    BOOL isHaveFolders = [TOPWHCFileManager top_isExistsAtPath:path];
    if (!isHaveFolders) {
        //没有该文件夹 就创建
        BOOL isSuccess =   [TOPWHCFileManager top_createDirectoryAtPath:path];
        if (isSuccess) {
            return @"1";
        }else{
            return @"2";
        }
    }else{
        //有该文件夹 那就不创建 换个名字不一样的
        return @"0";
    }
    
}
+(NSString*)top_getCurrentTime{
    NSDate *date = [NSDate date];
    //    NSString *languageCode = [NSLocale  currentLocale].languageCode;// 当前设置的首选语言
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:[TOPScanerShare top_documentDateType]];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+(NSString*)top_getCurrentTimeAndSendFormatterString:(NSString *)formatterString{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setDateFormat:formatterString];
    NSString *strTime = [formatter stringFromDate:date];
    return strTime;
}

+(NSString*)top_getFormatCurrentTime{
    NSDate *date = [NSDate date];
    NSString *strTime = [[TOPCurrentTimeFormatter shareInstance] stringFromDate:date];//[formatter stringFromDate:date];
    return strTime;
}

+ (NSString *)top_getCurrentFormatterTime:(NSString *)formatterString{
    NSString * timeString = [NSString new];
    
    if ([formatterString containsString:@"Doc "]) {
        NSString * cutString = [formatterString substringFromIndex:3];
        NSString * cutFormatString = [self top_getCurrentTimeAndSendFormatterString:cutString];
        timeString = [NSString stringWithFormat:@"Doc%@",cutFormatString];
    }else{
        NSString * cutFormatString = [self top_getCurrentTimeAndSendFormatterString:formatterString];
        timeString = cutFormatString;
    }
    return timeString;
}
+ (NSDate *)top_getAroundDateFromDate:(NSDate *)date month:(int)month
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:month];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [calender dateByAddingComponents:comps toDate:date options:0];;
}

+ (NSString*)top_getFileNameNumber:(NSInteger)index{
    NSString *numStr;
    if (index >= 0 && index < 10) {
        numStr = [NSString stringWithFormat:@"100%ld",index];
    }else if (index >= 10 && index < 100){
        numStr = [NSString stringWithFormat:@"10%ld",index];
    }else{
        numStr = [NSString stringWithFormat:@"1%ld",index];
    }
    return numStr;
}

+ (NSString*)top_nameNewFileIndex:(NSArray*)indexArray{
    //通过自带的compare方法升序排列
    NSArray *newArray =  [indexArray sortedArrayUsingSelector:@selector(compare:)];
    NSInteger fileIndex = 0;
    for (NSString *str in newArray) {
        if ([newArray indexOfObject:str] + 1 != [str integerValue]) {
            fileIndex = [newArray indexOfObject:str] + 1;
            break;
        }
    }
    return [NSString  stringWithFormat:@"%ld",fileIndex];
}

#pragma mark -- //获取文件末尾数字标记--重名文件
+(NSString *)top_getNumberFromStr:(NSString *)str{
    if (!str.length) {
        return @"0";
    }
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [[str componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
}

#pragma mark - 数组排序

+(NSMutableArray*)top_sortByNameAZ:(NSArray*)dataArray{
    NSArray *sortArray = [dataArray sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        
        if ([obj1 isKindOfClass:[NSString class]]&&[obj2 isKindOfClass:[NSString class]]) {
            return [obj1 compare:obj2];
        }
        
        if ([obj1 isKindOfClass:[DocumentModel class]]&&[obj2 isKindOfClass:[DocumentModel class]]) {
            DocumentModel * model1 = (DocumentModel *)obj1;
            DocumentModel * model2 = (DocumentModel *)obj2;
            
            return [model1.name compare:model2.name];
        }
        
        if ([obj1 isKindOfClass:[TOPTagsManagerModel class]]&&[obj2 isKindOfClass:[TOPTagsManagerModel class]]) {
            TOPTagsManagerModel * model1 = (TOPTagsManagerModel *)obj1;
            TOPTagsManagerModel * model2 = (TOPTagsManagerModel *)obj2;
            return [model1.tagsListModel.tagName compare:model2.tagsListModel.tagName];
        }
        
        if ([obj1 isKindOfClass:[TOPTagsModel class]]&&[obj2 isKindOfClass:[TOPTagsModel class]]) {
            TOPTagsModel * model1 = (TOPTagsModel *)obj1;
            TOPTagsModel * model2 = (TOPTagsModel *)obj2;
            return [model1.name compare:model2.name];
        }
        if ([obj1 isKindOfClass:[TOPTagsListModel class]]&&[obj2 isKindOfClass:[TOPTagsListModel class]]) {
            TOPTagsListModel * model1 = (TOPTagsListModel *)obj1;
            TOPTagsListModel * model2 = (TOPTagsListModel *)obj2;
            return [model1.tagName compare:model2.tagName];
        }
        return [obj1 compare:obj2];
    }];
    return [NSMutableArray arrayWithArray:sortArray];
}


+ (NSMutableArray*)top_sortByNameZA:(NSArray*)dataArray{
    NSArray *sortArray =   [[[self top_sortByNameAZ:dataArray] reverseObjectEnumerator] allObjects];
    return [NSMutableArray arrayWithArray:sortArray];
}

//按照修改时间排序 
+(NSMutableArray*)top_sortByTimeNewToOld:(NSArray*)dataArray path:(NSString*)pathString{
    
    NSArray *sortArray = [dataArray sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        id firstDate;
        id secondDate;
        if ([obj1 isKindOfClass:[NSString class]]&&[obj2 isKindOfClass:[NSString class]]) {
            firstDate = [self top_getCompareTimeString:[pathString stringByAppendingPathComponent:obj1]];
            secondDate = [self top_getCompareTimeString:[pathString stringByAppendingPathComponent:obj2]];
        }
        
        if ([obj1 isKindOfClass:[DocumentModel class]]&&[obj2 isKindOfClass:[DocumentModel class]]) {
            DocumentModel * model1 = (DocumentModel *)obj1;
            DocumentModel * model2 = (DocumentModel *)obj2;
            
            firstDate = [self top_getCompareTimeString:[pathString stringByAppendingPathComponent:model1.name]];
            secondDate = [self top_getCompareTimeString:[pathString stringByAppendingPathComponent:model2.name]];
        }
        
        if ([obj1 isKindOfClass:[TOPTagsManagerModel class]]&&[obj2 isKindOfClass:[TOPTagsManagerModel class]]) {
            TOPTagsManagerModel * model1 = (TOPTagsManagerModel *)obj1;
            TOPTagsManagerModel * model2 = (TOPTagsManagerModel *)obj2;
            firstDate = [self top_getCompareTimeString:[pathString stringByAppendingPathComponent:model1.tagsListModel.tagName]];
            secondDate = [self top_getCompareTimeString:[pathString stringByAppendingPathComponent:model2.tagsListModel.tagName]];
        }
        
        if ([obj1 isKindOfClass:[TOPTagsModel class]]&&[obj2 isKindOfClass:[TOPTagsModel class]]) {
            TOPTagsModel * model1 = (TOPTagsModel *)obj1;
            TOPTagsModel * model2 = (TOPTagsModel *)obj2;
            
            firstDate = [self top_getCompareTimeString:[pathString stringByAppendingPathComponent:model1.name]];
            secondDate = [self top_getCompareTimeString:[pathString stringByAppendingPathComponent:model2.name]];
        }
        if ([obj1 isKindOfClass:[TOPTagsListModel class]]&&[obj2 isKindOfClass:[TOPTagsListModel class]]) {
            TOPTagsListModel * model1 = (TOPTagsListModel *)obj1;
            TOPTagsListModel * model2 = (TOPTagsListModel *)obj2;
            
            firstDate = [self top_getCompareTimeString:model1.tagPath];
            secondDate = [self top_getCompareTimeString:model2.tagPath];
        }
        return [secondDate compare:firstDate options:NSNumericSearch];
    }];
    return [NSMutableArray arrayWithArray:sortArray];
    
}

+(NSMutableArray*)top_sortByTimeOldToNew:(NSArray*)dataArray path:(NSString*)pathString{
    NSArray *sortArray =   [[[self top_sortByTimeNewToOld:dataArray path:pathString] reverseObjectEnumerator] allObjects];
    return [NSMutableArray arrayWithArray:sortArray];
}

//创建时间排序
+(NSMutableArray*)top_sortByCreateTimeNewToOld:(NSArray*)dataArray path:(NSString*)pathString{
    NSArray *sortArray = [dataArray sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        id firstDate;
        id secondDate;
        if ([obj1 isKindOfClass:[NSString class]]&&[obj2 isKindOfClass:[NSString class]]) {
            firstDate = [self top_getCreateTimeString:[pathString stringByAppendingPathComponent:obj1]];
            secondDate = [self top_getCreateTimeString:[pathString stringByAppendingPathComponent:obj2]];
        }
        if ([obj1 isKindOfClass:[DocumentModel class]]&&[obj2 isKindOfClass:[DocumentModel class]]) {
            DocumentModel * model1 = (DocumentModel *)obj1;
            DocumentModel * model2 = (DocumentModel *)obj2;
            
            firstDate = [self top_getCreateTimeString:[pathString stringByAppendingPathComponent:model1.name]];
            secondDate = [self top_getCreateTimeString:[pathString stringByAppendingPathComponent:model2.name]];
        }
        if ([obj1 isKindOfClass:[TOPTagsManagerModel class]]&&[obj2 isKindOfClass:[TOPTagsManagerModel class]]) {
            TOPTagsManagerModel * model1 = (TOPTagsManagerModel *)obj1;
            TOPTagsManagerModel * model2 = (TOPTagsManagerModel *)obj2;
            
            firstDate = [self top_getCreateTimeString:[pathString stringByAppendingPathComponent:model1.tagsListModel.tagName]];
            secondDate = [self top_getCreateTimeString:[pathString stringByAppendingPathComponent:model2.tagsListModel.tagName]];
        }
        if ([obj1 isKindOfClass:[TOPTagsModel class]]&&[obj2 isKindOfClass:[TOPTagsModel class]]) {
            TOPTagsModel * model1 = (TOPTagsModel *)obj1;
            TOPTagsModel * model2 = (TOPTagsModel *)obj2;
            
            firstDate = [self top_getCreateTimeString:[pathString stringByAppendingPathComponent:model1.name]];
            secondDate = [self top_getCreateTimeString:[pathString stringByAppendingPathComponent:model2.name]];
        }
        if ([obj1 isKindOfClass:[TOPTagsListModel class]]&&[obj2 isKindOfClass:[TOPTagsListModel class]]) {
            TOPTagsListModel * model1 = (TOPTagsListModel *)obj1;
            TOPTagsListModel * model2 = (TOPTagsListModel *)obj2;
            
            firstDate = [self top_getCreateTimeString:model1.tagPath];
            secondDate = [self top_getCreateTimeString:model2.tagPath];
        }
        return [secondDate compare:firstDate options:NSNumericSearch];
        
    }];
    return [NSMutableArray arrayWithArray:sortArray];
}

+(NSMutableArray*)top_sortByCreateTimeOldToNew:(NSArray*)dataArray path:(NSString*)pathString{
    NSArray *sortArray =   [[[self top_sortByCreateTimeNewToOld:dataArray path:pathString] reverseObjectEnumerator] allObjects];
    return [NSMutableArray arrayWithArray:sortArray];
}

+(NSString*)top_getFirstPathString:(NSArray*)documentArray{
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *str in documentArray) {
        DocumentModel *model = [[DocumentModel alloc] init];
        model.name = str;
        NSString *nameStr  = [str stringByDeletingPathExtension];
        if (nameStr.length > 4) {
            model.numberIndex =  [nameStr substringFromIndex:nameStr.length - 4];
        }
        [array addObject:model];
    }
    
    NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(DocumentModel *model1, DocumentModel *model2) {
        return  [model1.numberIndex compare:model2.numberIndex options:NSNumericSearch];
        
    }];
    
    // NSLog(@"+++++ %@",sortArray);
    DocumentModel *firstModel = [sortArray firstObject];
    
    return firstModel.name;
}

+ (NSMutableArray *)top_showAllFileWithPath:(NSString *)path documentArray:(NSMutableArray *)documentArray{
    NSFileManager * fileManger = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray *dirArray = [TOPDocumentHelper top_getCurrentFileAndPath:path];
            NSLog(@"dirArray==%@",dirArray);
            
            for (NSString * lastString in dirArray) {
                NSString * componentStr = [NSString stringWithFormat:@"%@/%@",path,lastString];
                NSLog(@"componentStr56556===%@",componentStr);
                //先判断给的路径是不是文件夹 不是文件夹说明是图片 是文件夹才能进行下面的操作
                if ([TOPWHCFileManager top_isDirectoryAtPath:componentStr]) {
                    NSArray * componentArray = [TOPDocumentHelper top_getCurrentFileAndPath:componentStr];
                    if (componentArray.count>0) {
                        NSLog(@"componentStr==%@ componentArray==%@",componentStr,componentArray);
                        NSString * contentStr = componentArray[0];
                        NSString *fullStr = [NSString stringWithFormat:@"%@/%@",componentStr,contentStr];
                        //判断第二层内是不是文件夹 若是文件夹 说明上层为folder 反之为documemnt
                        //document文档
                        if ([TOPWHCFileManager top_isFileAtPath:fullStr]) {
                            [documentArray addObject:componentStr];
                        }
                        
                        //获取子文件夹文件夹
                        if ([TOPWHCFileManager top_isDirectoryAtPath:fullStr]) {
                        }
                    }else{
                    }
                }
            }
            
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                subPath  = [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                [self top_showAllFileWithPath:subPath documentArray:documentArray];
            }
        }else{
            
        }
    }else{
        NSLog(@"this path is not exist!");
    }
    return documentArray;
}

#pragma mark -- 判断文件是否为图片
+ (BOOL)top_isValidateJPG:(NSString *)fileName {
    NSString *jpgRegex = @"[a-z_0-9]+\\.jpg";
    NSPredicate *jpgTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", jpgRegex];
    return [jpgTest evaluateWithObject:fileName];
}

#pragma mark -- 检测当前目录下是否有图片
+ (BOOL)top_directoryHasJPG:(NSString *)path {
    NSArray * dirArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *fileName in dirArray) {//遍历文件是否含有图片：有图片==该目录为文档
        if ([self top_isValidateJPG:fileName]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- 遍历文件集合是否为含有图片
+ (BOOL)contentsHasJPG:(NSArray *)dirArray {
    for (NSString *fileName in dirArray) {
        if ([self top_isValidateJPG:fileName]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- 获取沙盒Documents目录下的所有文件夹(Folder) 递归遍历
+ (NSMutableArray *)top_getAllFoldersWithPath:(NSString *)path documentArray:(NSMutableArray*)documentArray {
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {//目录(文件夹)
            NSString *foldersPath = [self top_getFoldersPathString];
            NSArray * dirArray = [self top_sortContentOfDirectoryAtPath:path];
            if (!dirArray.count) {//没有子目录 则是Folder
                if (![foldersPath isEqualToString:path]) {//过滤掉第一个Folders文件
                    [documentArray addObject:path];
                }
            } else {
                if (![self contentsHasJPG:dirArray]) {//有图片==该目录为文档,没有则为文件夹
                    BOOL hasDoc = NO;
                    if (![foldersPath isEqualToString:path]) {//过滤掉第一个Folders文件
                        if (!hasDoc) {//确保遍历子目录过程中只计算一次
                            [documentArray addObject:path];
                            hasDoc = YES;
                        }
                    }
                    //递归遍历该文件下所有的子目录
                    for (NSString *fileName in dirArray) {
                        if ([fileName containsString:@".DS_Store"] || [self top_isValidateJPG:fileName]|| [fileName containsString:TOP_TRTXTPathSuffixString]) {
                            continue;
                        }
                        NSString * documentPath = [path stringByAppendingPathComponent:fileName];
                        [self top_getAllFoldersWithPath:documentPath documentArray:documentArray];
                    }
                }
            }
        } else {//文件
            return documentArray;
        }
    }
    return documentArray;
}

#pragma mark -- 获取沙盒Documents目录下的所有文档(Document-存放图片的文件夹) 递归遍历
+ (NSMutableArray *)top_getAllDocumentsWithPath:(NSString *)path documentArray:(NSMutableArray*)documentArray {
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {//目录(文件夹)
            NSArray * dirArray = [self top_sortContentOfDirectoryAtPath:path];
            if (!dirArray.count) {//没有子目录 则是Folder
                return documentArray;
            } else {
                if ([self contentsHasJPG:dirArray]) {//有图片==该目录为文档,没有则为文件夹
                    [documentArray addObject:path];
                } else {
                    //递归遍历该文件下所有的子目录
                    for (NSString *fileName in dirArray) {
                        if ([fileName containsString:@".DS_Store"] || [self top_isValidateJPG:fileName] || [fileName containsString:TOP_TRTXTPathSuffixString]) {
                            continue;
                        }
                        NSString * documentPath = [path stringByAppendingPathComponent:fileName];
                        [self top_getAllDocumentsWithPath:documentPath documentArray:documentArray];
                    }
                }
            }
        } else {//文件
            return documentArray;
        }
    }
    return documentArray;
}

#pragma mark -- 根据首页的排序规则返回文件目录
+ (NSArray *)top_sortContentOfDirectoryAtPath:(NSString *)path {
    NSArray * dirArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *fileName in dirArray) {//如果子文件是图片不用做排序
        if ([self top_isValidateJPG:fileName]) {
            return dirArray;
        }
    }
    NSArray *sortArray = @[];
    if (dirArray.count) {
        NSInteger type = [TOPScanerShare top_sortType];
        if (type == FolderDocumentCreateDescending) {
            sortArray = [TOPDocumentHelper top_sortByCreateTimeNewToOld:dirArray path:path];
        }else if (type == FolderDocumentCreateAscending){
            sortArray = [TOPDocumentHelper top_sortByCreateTimeOldToNew:dirArray path:path];
        }else if (type == FolderDocumentUpdateDescending){
            sortArray = [TOPDocumentHelper top_sortByTimeNewToOld:dirArray path:path];
        }else if (type == FolderDocumentUpdateAscending){
            sortArray = [TOPDocumentHelper top_sortByTimeOldToNew:dirArray path:path];
        }else if (type == FolderDocumentFileNameAToZ){
            sortArray = [TOPDocumentHelper top_sortByNameAZ:dirArray];
        }else if (type == FolderDocumentFileNameZToA){
            sortArray = [TOPDocumentHelper top_sortByNameZA:dirArray];
        }
    }
    return sortArray;
}

#pragma mark -- 获取当前目录下的文件夹 -- 浅遍历 只看次级目录
+ (NSMutableArray *)top_getNextFoldersWithPath:(NSString *)path {
    NSMutableArray *documentArray = [@[] mutableCopy];
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {//目录(文件夹)
            NSArray * dirArray = [self top_sortContentOfDirectoryAtPath:path];
            if (!dirArray.count) {//没有子目录
                return documentArray;
            } else {
                for (NSString *fileName in dirArray) {
                    if ([fileName containsString:@".DS_Store"]) {
                        continue;
                    }
                    if ([self top_isFolderAtPath:fileName]) {//如果是文件夹，拼接完整的路径
                        [documentArray addObject:[path stringByAppendingPathComponent:fileName]];
                    }
                }
            }
        } else {//文件
            return documentArray;
        }
    }
    return documentArray;
}

#pragma mark -- 获取当前文件夹下的文档 -- 浅遍历 只看次级目录
+ (NSMutableArray *)top_getCurrnetDocumentsWithPath:(NSString *)path {
    NSMutableArray *documentArray = [@[] mutableCopy];
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {//目录(文件夹)
            NSArray * dirArray = [self top_sortContentOfDirectoryAtPath:path];
            if (!dirArray.count) {//
                return documentArray;
            } else {
                for (NSString *fileName in dirArray) {
                    if ([fileName containsString:@".DS_Store"]) {
                        continue;
                    }
                    if ([self top_isDocumentAtPath:fileName]) {//如果是文档，拼接完整的路径
                        [documentArray addObject:[path stringByAppendingPathComponent:fileName]];
                    }
                }
            }
        } else {//文件
            return documentArray;
        }
    }
    return documentArray;
}

#pragma mark -- 判断目录是否为Folder
+ (BOOL)top_isFolderAtPath:(NSString *)path {
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {//目录(文件夹)
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            if (!dirArray.count) {//没有子目录 则是Folder
                return YES;
            } else {
                for (NSString *fileName in dirArray) {
                    if ([fileName containsString:@".DS_Store"]) {
                        continue;
                    }
                    if ([self top_isValidateJPG:fileName]) {//判断是否为jpg 有图片 则是Doc
                        return NO;
                    }
                }//子目录中没有图片 则是Folder 除了首页的Documents目录
                NSString *foldersPath = [self top_getDocumentsPathString];
                if (![foldersPath isEqualToString:path]) {//过滤掉第一个Documents文件
                    return YES;
                }
            }
        } else {//文件
            return NO;
        }
    }
    return NO;
}

#pragma mark -- 判断目录是否为Document
+ (BOOL)top_isDocumentAtPath:(NSString *)path {
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {//目录(文件夹)
            NSArray *contents = [self top_getJPEGFile:path];
            return !contents.count ? NO : YES;
        } else {//文件
            return NO;
        }
    }
    return NO;
}

#pragma mark -- 移动文件下所有图片
+ (void)top_moveFileItemsAtPath:(NSString *)path toNewFileAtPath:(NSString *)newPath {
    NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:path deep:NO];
    for (NSString *tempContentPath in tempContentsArray) {
        NSString *oldContentPath = [path stringByAppendingPathComponent:tempContentPath];
        NSString *newContentPath = [newPath stringByAppendingPathComponent:tempContentPath];
        //图片移到指定文件
        [TOPWHCFileManager top_moveItemAtPath:oldContentPath toPath:newContentPath];
    }
    //删除原文件夹
    [TOPWHCFileManager top_removeItemAtPath:path];
}

+ (void)top_moveFileItemsAtPath:(NSString *)path toNewFileAtPath:(NSString *)newPath progress:(void (^)(CGFloat moveProgressValue))moveProgressBlock {
    NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:path deep:NO];
    NSInteger start = 0;
    NSInteger total = tempContentsArray.count;
    for (NSString *tempContentPath in tempContentsArray) {
        NSString *oldContentPath = [path stringByAppendingPathComponent:tempContentPath];
        NSString *newContentPath = [newPath stringByAppendingPathComponent:tempContentPath];
        //图片移到指定文件
        [TOPWHCFileManager top_moveItemAtPath:oldContentPath toPath:newContentPath];
        start ++;
        if (moveProgressBlock) {
            CGFloat progressValue = (start * 10.0) / (total * 10.0);
            moveProgressBlock(progressValue);
        }
    }
    //删除原文件夹
    [TOPWHCFileManager top_removeItemAtPath:path];
}

#pragma mark -- 复制文件目录
+ (void)top_copyDirectoryAtPath:(NSString *)path toNewDirectoryPath:(NSString *)newPath {
    [TOPWHCFileManager top_copyItemAtPath:path toPath:newPath];
    NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:path deep:NO];
    for (NSString *tempContentPath in tempContentsArray) {
        NSString *newContentPath = [newPath stringByAppendingPathComponent:tempContentPath];
        [TOPWHCFileManager top_removeItemAtPath:newContentPath];
    }
}

#pragma mark -- 复制文件下的所有图片
+ (void)top_copyFileItemsAtPath:(NSString *)path toNewFileAtPath:(NSString *)newPath {
    NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:path deep:NO];
    for (NSString *tempContentPath in tempContentsArray) {
        NSString *oldContentPath = [path stringByAppendingPathComponent:tempContentPath];
        NSString *newContentPath = [newPath stringByAppendingPathComponent:tempContentPath];
        //图片复制到指定文件
        [TOPWHCFileManager top_copyItemAtPath:oldContentPath toPath:newContentPath];
    }
}

+ (void)top_copyFileItemsAtPath:(NSString *)path toNewFileAtPath:(NSString *)newPath progress:(void (^)(CGFloat copyProgressValue))copyProgressBlock {
    NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:path deep:NO];
    NSInteger start = 0;
    NSInteger total = tempContentsArray.count;
    for (NSString *tempContentPath in tempContentsArray) {
        NSString *oldContentPath = [path stringByAppendingPathComponent:tempContentPath];
        NSString *newContentPath = [newPath stringByAppendingPathComponent:tempContentPath];
        //图片复制到指定文件
        [TOPWHCFileManager top_copyItemAtPath:oldContentPath toPath:newContentPath];
        start ++;
        if (copyProgressBlock) {
            CGFloat progressValue = (start * 10.0) / (total * 10.0);
            copyProgressBlock(progressValue);
        }
    }
}

#pragma mark -- 文件内的所有图片生成新图片并保存到（合并后的）新文件夹下
+ (void)top_writeNewPic:(NSString *)originalPath toNewFileAtPath:(NSString *)path delete:(BOOL)isDelete {
    //获取合成后的新文件下的所有文件 过滤了原图片
    //作为下一个文件的排序名称
    NSInteger indexStart = [self top_maxImageNumIndexAtPath:path];
    //获取源文件下的所有文件 过滤了原图片 -- 将图片排序重命名后写入到新文件
    NSArray *tempContentsArray = [self top_coverPicArrayAtPath:originalPath];
    for (NSString *tempContentPath in tempContentsArray) {
        //拼接路径获取展示图片和原始图片的数据，用于写入新文件  还有txt文件的路径及数据
        NSString *contentFilePath = [originalPath stringByAppendingPathComponent:tempContentPath];
        NSString *originalContentFilePath = [TOPDocumentHelper top_getSourceFilePath:originalPath fileName:tempContentPath];
        
        NSString *notePath = [TOPDocumentHelper top_getTxtPath:originalPath imgPriName:tempContentPath txtType:TOPRSimpleScanNoteString];//获取txt文档路径
        NSString *ocrPath = [self top_originalOcr:contentFilePath];
        
        
        //修改排序名称作为新文件的路径
        NSString * tempSubString = [tempContentPath substringToIndex:14];
        NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",tempSubString,[TOPDocumentHelper top_getFileNameNumber: indexStart],TOP_TRJPGPathSuffixString];
        NSString *noteName  = [NSString stringWithFormat:@"%@%@%@",tempSubString,[TOPDocumentHelper top_getFileNameNumber: indexStart],TOP_TRTXTPathSuffixString];
        NSString *newContentPath = [path stringByAppendingPathComponent:fileName];
        NSString *newOriginalContentPath = [self top_originalImage:newContentPath];
        NSString *noteContentPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",TOPRSimpleScanNoteString,noteName]];
        NSString *ocrContentPath = [path stringByAppendingPathComponent:noteName];
        
        if (isDelete) {//合并后删除
            [TOPWHCFileManager top_moveItemAtPath:contentFilePath toPath:newContentPath];
            if ([TOPWHCFileManager top_isExistsAtPath:originalContentFilePath]) {
                [TOPWHCFileManager top_moveItemAtPath:originalContentFilePath toPath:newOriginalContentPath];
            }
            if ([TOPWHCFileManager top_isExistsAtPath:notePath]) {
                [TOPWHCFileManager top_moveItemAtPath:notePath toPath:noteContentPath];//如果上面txt的原始路径里有内容 则将txt内容保存到新的路径
            }
            if ([TOPWHCFileManager top_isExistsAtPath:ocrPath]) {
                [TOPWHCFileManager top_moveItemAtPath:ocrPath toPath:ocrContentPath];//如果上面txt的原始路径里有内容 则将txt内容保存到新的路径
            }
        } else {//合并后保留
            [TOPWHCFileManager top_copyItemAtPath:contentFilePath toPath:newContentPath];
            if ([TOPWHCFileManager top_isExistsAtPath:originalContentFilePath]) {
                [TOPWHCFileManager top_copyItemAtPath:originalContentFilePath toPath:newOriginalContentPath];
            }
            if ([TOPWHCFileManager top_isExistsAtPath:notePath]) {
                [TOPWHCFileManager top_copyItemAtPath:notePath toPath:noteContentPath];
            }
            if ([TOPWHCFileManager top_isExistsAtPath:ocrPath]) {
                [TOPWHCFileManager top_copyItemAtPath:ocrPath toPath:ocrContentPath];
            }
        }
        indexStart ++;
    }
    if (isDelete) {
        [TOPWHCFileManager top_removeItemAtPath:originalPath];
    }
}

+ (NSMutableArray *)top_writeNewPic:(NSString *)originalPath toNewFileAtPath:(NSString *)path delete:(BOOL)isDelete  progress:(void (^)(CGFloat copyProgressValue))copyProgressBlock  {
    //获取合成后的新文件下的所有文件 过滤了原图片
    //作为下一个文件的排序名称
    NSMutableArray *newImages = @[].mutableCopy;
    NSInteger indexStart = [self top_maxImageNumIndexAtPath:path];
    //获取源文件下的所有文件 过滤了原图片 -- 将图片排序重命名后写入到新文件
    NSArray *tempContentsArray = [self top_coverPicArrayAtPath:originalPath];
    NSInteger start = 0;
    NSInteger total = tempContentsArray.count;
    for (NSString *tempContentPath in tempContentsArray) {
        //拼接路径获取展示图片和原始图片的数据，用于写入新文件  还有txt文件的路径及数据
        NSString *contentFilePath = [originalPath stringByAppendingPathComponent:tempContentPath];
        NSString *originalContentFilePath = [TOPDocumentHelper top_getSourceFilePath:originalPath fileName:tempContentPath];
        
        NSString *notePath = [TOPDocumentHelper top_getTxtPath:originalPath imgPriName:tempContentPath txtType:TOPRSimpleScanNoteString];//获取txt文档路径
        NSString *ocrPath = [self top_originalOcr:contentFilePath];
        
        
        //修改排序名称作为新文件的路径
        NSString * tempSubString = [tempContentPath substringToIndex:14];
        NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",tempSubString,[TOPDocumentHelper top_getFileNameNumber: indexStart],TOP_TRJPGPathSuffixString];
        NSString *noteName  = [NSString stringWithFormat:@"%@%@%@",tempSubString,[TOPDocumentHelper top_getFileNameNumber: indexStart],TOP_TRTXTPathSuffixString];
        NSString *newContentPath = [path stringByAppendingPathComponent:fileName];
        NSString *newOriginalContentPath = [self top_originalImage:newContentPath];
        NSString *noteContentPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",TOPRSimpleScanNoteString,noteName]];
        NSString *ocrContentPath = [path stringByAppendingPathComponent:noteName];
        [newImages addObject:fileName];
        if (isDelete) {//合并后删除
            [TOPWHCFileManager top_moveItemAtPath:contentFilePath toPath:newContentPath];
            if ([TOPWHCFileManager top_isExistsAtPath:originalContentFilePath]) {
                [TOPWHCFileManager top_moveItemAtPath:originalContentFilePath toPath:newOriginalContentPath];
            }
            if ([TOPWHCFileManager top_isExistsAtPath:notePath]) {
                [TOPWHCFileManager top_moveItemAtPath:notePath toPath:noteContentPath];//如果上面txt的原始路径里有内容 则将txt内容保存到新的路径
            }
            if ([TOPWHCFileManager top_isExistsAtPath:ocrPath]) {
                [TOPWHCFileManager top_moveItemAtPath:ocrPath toPath:ocrContentPath];//如果上面txt的原始路径里有内容 则将txt内容保存到新的路径
            }
        } else {//合并后保留
            [TOPWHCFileManager top_copyItemAtPath:contentFilePath toPath:newContentPath];
            if ([TOPWHCFileManager top_isExistsAtPath:originalContentFilePath]) {
                [TOPWHCFileManager top_copyItemAtPath:originalContentFilePath toPath:newOriginalContentPath];
            }
            if ([TOPWHCFileManager top_isExistsAtPath:notePath]) {
                [TOPWHCFileManager top_copyItemAtPath:notePath toPath:noteContentPath];
            }
            if ([TOPWHCFileManager top_isExistsAtPath:ocrPath]) {
                [TOPWHCFileManager top_copyItemAtPath:ocrPath toPath:ocrContentPath];
            }
        }
        indexStart ++;
        start ++;
        if (copyProgressBlock) {
            CGFloat progressValue = (start * 10.0) / (total * 10.0);
            copyProgressBlock(progressValue);
        }
    }
    if (isDelete) {
        [TOPWHCFileManager top_removeItemAtPath:originalPath];
    }
    return newImages;
}

#pragma mark -- 将单个图片写入目标文件下
+ (void)top_writeImage:(NSString *)imgPath toTargetFile:(NSString *)path delete:(BOOL)isDelete {
    if (![TOPWHCFileManager top_isExistsAtPath:imgPath]) {
        return;
    }
    //作为下一个文件的排序名称
    NSInteger indexStart = [self top_maxImageNumIndexAtPath:path];
    NSString *originalContentFilePath = [self top_originalImage:imgPath];
    NSString *notePath = [self top_originalNote:imgPath];
    NSString *ocrPath = [self top_originalOcr:imgPath];
    
    //修改排序名称作为新文件的路径
    NSString * tempSubString = [[imgPath lastPathComponent] substringToIndex:14];
    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",tempSubString,[TOPDocumentHelper top_getFileNameNumber: indexStart],TOP_TRJPGPathSuffixString];
    NSString *noteName  = [NSString stringWithFormat:@"%@%@%@%@",TOPRSimpleScanNoteString,tempSubString,[TOPDocumentHelper top_getFileNameNumber: indexStart],TOP_TRTXTPathSuffixString];
    NSString *ocrName = [NSString stringWithFormat:@"%@%@%@",tempSubString,[TOPDocumentHelper top_getFileNameNumber: indexStart],TOP_TRTXTPathSuffixString];
    
    //新文件名
    NSString *newContentPath = [path stringByAppendingPathComponent:fileName];
    NSString *newOriginalContentPath = [self top_originalImage:newContentPath];
    NSString *noteContentPath = [path stringByAppendingPathComponent:noteName];
    NSString *ocrContentPath = [path stringByAppendingPathComponent:ocrName];
    
    if (isDelete) {//移动
        [TOPWHCFileManager top_moveItemAtPath:imgPath toPath:newContentPath];
        if ([TOPWHCFileManager top_isExistsAtPath:originalContentFilePath]) {
            [TOPWHCFileManager top_moveItemAtPath:originalContentFilePath toPath:newOriginalContentPath];
        }
        if ([TOPWHCFileManager top_isExistsAtPath:notePath]) {
            [TOPWHCFileManager top_moveItemAtPath:notePath toPath:noteContentPath];
        }
        if ([TOPWHCFileManager top_isExistsAtPath:ocrPath]) {
            [TOPWHCFileManager top_moveItemAtPath:ocrPath toPath:ocrContentPath];
        }
    } else {//复制
        [TOPWHCFileManager top_copyItemAtPath:imgPath toPath:newContentPath];
        if ([TOPWHCFileManager top_isExistsAtPath:originalContentFilePath]) {
            [TOPWHCFileManager top_copyItemAtPath:originalContentFilePath toPath:newOriginalContentPath];
        }
        if ([TOPWHCFileManager top_isExistsAtPath:notePath]) {
            [TOPWHCFileManager top_copyItemAtPath:notePath toPath:noteContentPath];
        }
        if ([TOPWHCFileManager top_isExistsAtPath:ocrPath]) {
            [TOPWHCFileManager top_copyItemAtPath:ocrPath toPath:ocrContentPath];
        }
    }
}

#pragma mark -- 将单个图片根据指定名称下标写入目标文件下
+ (NSString *)top_writeImage:(NSString *)imgPath atIndex:(NSInteger)indexStart toTargetFile:(NSString *)path delete:(BOOL)isDelete {
    if (![TOPWHCFileManager top_isExistsAtPath:imgPath]) {
        return @"";
    }
    NSString *originalContentFilePath = [self top_originalImage:imgPath];
    NSString *notePath = [self top_originalNote:imgPath];
    NSString *ocrPath = [self top_originalOcr:imgPath];
    
    //修改排序名称作为新文件的路径
    NSString * tempSubString = [[imgPath lastPathComponent] substringToIndex:14];
    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",tempSubString,[TOPDocumentHelper top_getFileNameNumber: indexStart],TOP_TRJPGPathSuffixString];
    NSString *noteName  = [NSString stringWithFormat:@"%@%@%@%@",TOPRSimpleScanNoteString,tempSubString,[TOPDocumentHelper top_getFileNameNumber: indexStart],TOP_TRTXTPathSuffixString];
    NSString *ocrName = [NSString stringWithFormat:@"%@%@%@",tempSubString,[TOPDocumentHelper top_getFileNameNumber: indexStart],TOP_TRTXTPathSuffixString];
    
    //新文件名
    NSString *newContentPath = [path stringByAppendingPathComponent:fileName];
    NSString *newOriginalContentPath = [self top_originalImage:newContentPath];
    NSString *noteContentPath = [path stringByAppendingPathComponent:noteName];
    NSString *ocrContentPath = [path stringByAppendingPathComponent:ocrName];
    
    if (isDelete) {//移动
        [TOPWHCFileManager top_moveItemAtPath:imgPath toPath:newContentPath];
        if ([TOPWHCFileManager top_isExistsAtPath:originalContentFilePath]) {
            [TOPWHCFileManager top_moveItemAtPath:originalContentFilePath toPath:newOriginalContentPath];
        }
        if ([TOPWHCFileManager top_isExistsAtPath:notePath]) {
            [TOPWHCFileManager top_moveItemAtPath:notePath toPath:noteContentPath];
        }
        if ([TOPWHCFileManager top_isExistsAtPath:ocrPath]) {
            [TOPWHCFileManager top_moveItemAtPath:ocrPath toPath:ocrContentPath];
        }
    } else {//复制
        [TOPWHCFileManager top_copyItemAtPath:imgPath toPath:newContentPath];
        if ([TOPWHCFileManager top_isExistsAtPath:originalContentFilePath]) {
            [TOPWHCFileManager top_copyItemAtPath:originalContentFilePath toPath:newOriginalContentPath];
        }
        if ([TOPWHCFileManager top_isExistsAtPath:notePath]) {
            [TOPWHCFileManager top_copyItemAtPath:notePath toPath:noteContentPath];
        }
        if ([TOPWHCFileManager top_isExistsAtPath:ocrPath]) {
            [TOPWHCFileManager top_copyItemAtPath:ocrPath toPath:ocrContentPath];
        }
    }
    return fileName;
}

#pragma mark -- 当前文档中所有图片的最大下标
+ (NSInteger)top_maxImageNumIndexAtPath:(NSString *)path {
    NSArray *imageArray = [self top_getJPEGFile:path];
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

#pragma mark -- 图片源文件路径
+ (NSString *)top_originalImage:(NSString *)imgPath {
    NSString *directory = [TOPWHCFileManager top_directoryAtPath:imgPath];
    NSString *imgName= [imgPath lastPathComponent];
    NSString *originalContentFilePath = [TOPDocumentHelper top_getSourceFilePath:directory fileName:imgName];
    return originalContentFilePath;
}

#pragma mark -- 备份图片文件路径
+ (NSString *)top_backupImage:(NSString *)imgPath {
    NSString *directory = [TOPWHCFileManager top_directoryAtPath:imgPath];
    NSString *imgName= [imgPath lastPathComponent];
    NSString *originalContentFilePath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"backup_%@",imgName]];
    return originalContentFilePath;
}

#pragma mark -- 源txt路径
+ (NSString *)top_originalNote:(NSString *)imgPath {
    NSString *directory = [TOPWHCFileManager top_directoryAtPath:imgPath];
    NSString *imgName= [imgPath lastPathComponent];
    NSString *notePath = [self top_getTxtPath:directory imgPriName:imgName txtType:TOPRSimpleScanNoteString];
    return notePath;
}

#pragma mark -- 源ocr路径
+ (NSString *)top_originalOcr:(NSString *)imgPath {
    NSString *directory = [TOPWHCFileManager top_directoryAtPath:imgPath];
    NSString *noSuffName = [TOPWHCFileManager top_fileNameAtPath:imgPath suffix:NO];
    NSString *notePath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",noSuffName,TOP_TRTXTPathSuffixString]];
    return notePath;
}

#pragma mark -- 判断文件是否png格式图片
+ (BOOL)top_isPNGFile:(NSString *)fileName {
    NSString *jpgRegex = @"[0-9]+\\.png";
    NSPredicate *jpgTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", jpgRegex];
    return [jpgTest evaluateWithObject:fileName];
}

#pragma mark -- 判断文件是否为封面图片
+ (BOOL)top_isCoverJPG:(NSString *)fileName {
    if (!fileName.length) {
        return NO;
    }
    NSString *jpgRegex = @"[0-9]+\\.jpg";
    NSPredicate *jpgTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", jpgRegex];
    return [jpgTest evaluateWithObject:fileName];
}

#pragma mark -- 获取文件中的所有图片路径(过滤了原始图片等)--不做排序
+ (NSMutableArray *)top_showPicArrayAtPath:(NSString *)path  {
    //获取合成后的新文件下的所有文件 有显示图片和原始图片(original_)
    NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:path deep:NO];
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSString *tempContentPath in tempContentsArray) {
        if ([TOPDocumentHelper top_isCoverJPG:tempContentPath]) {
            [temp addObject:tempContentPath];
        }
    }
    return temp;
}

#pragma mark -- 过滤掉原始图片 排序,根据图片的后几位数字去排序
+ (NSMutableArray *)top_coverPicArrayAtPath:(NSString *)path  {
    //获取合成后的新文件下的所有文件 有显示图片和原始图片(original_)
    NSMutableArray *temp = [self top_showPicArrayAtPath:path];
    //排序,根据图片的后几位数字去排序
    NSArray *sortArray = [temp sortedArrayUsingComparator:^NSComparisonResult(NSString *tempContentPath1, NSString *tempContentPath2) {
        NSString *sortNO1 = [self top_picSortNO:tempContentPath1];
        NSString *sortNO2 = [self top_picSortNO:tempContentPath2];
        return [sortNO1 compare:sortNO2 options:NSNumericSearch];
    }];
    return [sortArray mutableCopy];
}

#pragma mark -- 排序,根据图片的后几位数字去排序
+ (NSArray *)top_sortedPicArray:(NSArray *)imageNames {
    //排序,根据图片的后几位数字去排序
    NSArray *sortArray = [imageNames sortedArrayUsingComparator:^NSComparisonResult(NSString *tempContentPath1, NSString *tempContentPath2) {
        NSString *sortNO1 = [self top_picSortNO:tempContentPath1];
        NSString *sortNO2 = [self top_picSortNO:tempContentPath2];
        return [sortNO1 compare:sortNO2 options:NSNumericSearch];
    }];
    return sortArray;
}

#pragma mark -- 根据图片名称排序
+ (NSMutableArray *)top_sortPicArryBuyName:(NSString *)path{
    //获取合成后的新文件下的所有文件 有显示图片和原始图片(original_)
    NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:path deep:NO];
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSString *tempContentPath in tempContentsArray) {
        if ([self top_isCoverJPG:tempContentPath]) {
            [temp addObject:tempContentPath];
        }
    }
    NSArray *sortArray = [temp sortedArrayUsingComparator:^NSComparisonResult(NSString *tempContentPath1, NSString *tempContentPath2) {
        NSString *sortNO1 = [tempContentPath1 stringByDeletingPathExtension];
        NSString *sortNO2 = [tempContentPath2 stringByDeletingPathExtension];
        return [sortNO1 compare:sortNO2 options:NSNumericSearch];
    }];
    return [sortArray mutableCopy];
}

#pragma mark -- 获取图片的数字序号排序用
+ (NSString *)top_picSortNO:(NSString *)path {
    NSString *fileName = [path stringByDeletingPathExtension];
    NSString *sortNO = fileName.length > 14 ? [fileName substringFromIndex:14] : fileName;
    return sortNO;
}

#pragma mark -- 在当前目录下获取新文件夹默认名称
+ (NSString *)top_newDefaultFolderNameAtPath:(NSString *)path {
    NSString * namePath = TOPRNewFolderString;
    path = [path stringByAppendingPathComponent:namePath];
    BOOL isHaveFolders = [TOPWHCFileManager top_isExistsAtPath:path];
    if (isHaveFolders) {////有该文件夹 换个名字不一样的
        namePath = [self top_newDocumentFileName:path];
    }
    return namePath;
}

#pragma mark -- 在当前目录下获取新文档默认名称
+ (NSString *)top_newDefaultDocumentNameAtPath:(NSString *)path {
    TOPSettingFormatModel * formatModel = [NSKeyedUnarchiver unarchiveObjectWithFile:TOPSettingFormatter_Path];
    NSString * namePath = [self top_getCurrentFormatterTime:formatModel.formatString];
    path = [path stringByAppendingPathComponent:namePath];
    BOOL isHaveFolders = [TOPWHCFileManager top_isExistsAtPath:path];
    if (isHaveFolders) {////有该文件夹 换个名字不一样的
        namePath = [self top_newDocumentFileName:path];
    }
    return namePath;
}

#pragma mark -- 使用默认文件名在指定目录下创建Doc
+ (NSString *)top_createDefaultDocumentAtFolderPath:(NSString *)folderPath {
    TOPSettingFormatModel * formatModel = [NSKeyedUnarchiver unarchiveObjectWithFile:TOPSettingFormatter_Path];
    NSString * namePath = [self top_getCurrentFormatterTime:formatModel.formatString];
    NSString *newDocPath = [self top_createNewDocument:namePath atFolderPath:folderPath];
    return newDocPath;
}

#pragma mark -- 在指定目录下创建Documents
+ (NSString *)top_createNewDocument:(NSString *)docName atFolderPath:(NSString *)folderPath {
    NSString *mergerFilePath = [folderPath stringByAppendingPathComponent:docName];
    NSString *newDocPath =  [self top_createDirectoryAtPath:mergerFilePath];
    return newDocPath;
}

#pragma mark -- 创建文件
+ (NSString *)top_createDirectoryAtPath:(NSString *)path {
    BOOL isHaveFolders = [TOPWHCFileManager top_isExistsAtPath:path];
    if (isHaveFolders) {////有该文件夹 换个名字不一样的  没有该文件夹直接创建
        NSString *newFolder = [TOPWHCFileManager top_directoryAtPath:path];
        NSString *newDocName = [self top_newDocumentFileName:path];
        NSString *newDocPath = [newFolder stringByAppendingPathComponent:newDocName];
        path = newDocPath;
    }
    [TOPWHCFileManager top_createDirectoryAtPath:path];
    return path;
}

#pragma mark -- 设置文件路径
+ (NSString *)top_buildDirectoryAtPath:(NSString *)path {
    BOOL isHaveFolders = [TOPWHCFileManager top_isExistsAtPath:path];
    if (isHaveFolders) {////有该文件夹 换个名字不一样的  没有该文件夹直接创建
        NSString *newFolder = [TOPWHCFileManager top_directoryAtPath:path];
        NSString *newDocName = [self top_newDocumentFileName:path];
        NSString *newDocPath = [newFolder stringByAppendingPathComponent:newDocName];
        path = newDocPath;
    }
    return path;
}

#pragma mark -- 新文件名 有重名的加数字标签:(1)、(2)
+ (NSString *)top_newDocumentFileName:(NSString *)path {
    NSString *pathFileName = [path lastPathComponent];
    NSString *directory = [TOPWHCFileManager top_directoryAtPath:path];//上层目录
    int i = 1;
    NSString *newName = pathFileName;
    while ([TOPWHCFileManager top_isExistsAtPath:path]) {
        newName = [NSString stringWithFormat:@"%@(%@)",pathFileName,@(i)];
        path = [directory stringByAppendingPathComponent:newName];
        i ++;
    }
    return newName;
}

#pragma mark -- 新文件的时间属性沿用老文件的
+ (BOOL)top_setFileTimeAttribute:(NSString *)oldPath atNewPath:(NSString *)fldPath {
    NSDate *cTime = [TOPDocumentHelper top_createTimeOfFile:oldPath];
    NSDate *uTime = [TOPDocumentHelper top_updateTimeOfFile:oldPath];
    BOOL isSuccess = [[NSFileManager defaultManager] setAttributes:@{NSFileModificationDate:uTime,NSFileCreationDate:cTime,}  ofItemAtPath:fldPath error:nil];
    NSDate *cTime11 = [TOPDocumentHelper top_createTimeOfFile:fldPath];
    NSDate *uTime11 = [TOPDocumentHelper top_updateTimeOfFile:fldPath];
    return isSuccess;
}

#pragma mark - 固定宽度和字体大小，获取label的frame
+ (CGSize) top_getSizeWithStr:(NSString *) str Width:(float)width Font:(float)fontSize
{
    NSDictionary * attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGSize tempSize = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:attribute
                                        context:nil].size;
    return tempSize;
}

#pragma mark - 固定高度和字体大小，获取label的frame
+ (CGSize) top_getSizeWithStr:(NSString *) str Height:(float)height Font:(float)fontSize
{
    NSDictionary * attribute = @{NSFontAttributeName :[UIFont systemFontOfSize:fontSize] };
    CGSize tempSize=[str boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                   attributes:attribute
                                      context:nil].size;
    return tempSize;
}

#pragma mark - 判断输入内容是不是邮箱
+ (BOOL) top_validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

+ (NSString *)top_changeDocumentName:(NSString *)path folderText:(nonnull NSString *)folderText{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString * sendString = [NSString new];
    NSString * beforFolder = path;
    NSString * lastStr = [[beforFolder componentsSeparatedByString:@"/"] lastObject];
    NSString * publicStr = [beforFolder substringToIndex:beforFolder.length-lastStr.length];
    NSLog(@"lastStr==%@ \npublicStr==%@",lastStr,publicStr);
    
    NSString * afterFolder = [NSString stringWithFormat:@"%@%@",publicStr,folderText];
    
    NSArray * tempArrayForContentsOfDirectory = [fm contentsOfDirectoryAtPath:beforFolder error:nil];
    
    [fm createDirectoryAtPath:afterFolder withIntermediateDirectories:YES attributes:nil error:nil];
    for (int i = 0; i<tempArrayForContentsOfDirectory.count; i++) {
        NSString *newFilePath = [afterFolder stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
        NSString *oldFilePath = [beforFolder stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
        NSError * error = nil;
        [fm moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
        
        if (error) {
        }
    }
    [fm removeItemAtPath:beforFolder error:nil];
    
    sendString = [NSString stringWithFormat:@"%@%@",publicStr,folderText];
    return sendString;
}
+ (NSString *)top_changeFileName:(NSString *)path folderText:(nonnull NSString *)folderText{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString * sendString = [NSString new];
    NSString * beforFolder = path;
    NSString * lastStr = beforFolder.lastPathComponent;
    NSString * publicStr = beforFolder.stringByDeletingLastPathComponent;
    NSLog(@"lastStr==%@ \npublicStr==%@",lastStr,publicStr);
    
    //    NSString * afterFolder = [NSString stringWithFormat:@"%@%@",publicStr,folderText];
    
    NSError * error = nil;
    
    [fm moveItemAtPath:path toPath:[publicStr stringByAppendingPathComponent:folderText] error:&error];
    if (error) {
    }
    sendString = [publicStr stringByAppendingPathComponent:folderText];
    return sendString;
}


+ (void)top_changeBeforeFolder:(NSString *)beforeFolder toChangeFolder:(NSString *)changeFolder{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray * tempArrayForContentsOfDirectory = [fm contentsOfDirectoryAtPath:beforeFolder error:nil];
    [fm createDirectoryAtPath:changeFolder withIntermediateDirectories:YES attributes:nil error:nil];
    
    for (int i = 0; i<tempArrayForContentsOfDirectory.count; i++) {
        NSString *newFilePath = [changeFolder stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
        NSString *oldFilePath = [beforeFolder stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
        NSError * error = nil;
        [fm moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
        
        if (error) {
        }
    }
}

+ (void)top_jumpToSimpleFax:(NSString *)pdfPathing{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIPasteboard * myPasteboard = [UIPasteboard generalPasteboard];
        NSData * imgData = [NSData dataWithContentsOfFile:pdfPathing];
        NSLog(@"imgData==%@",imgData);
        if (imgData) {
            [myPasteboard setValue:imgData forPasteboardType:@"sharepdffile"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            NSURL * container = [NSURL URLWithString:[NSString stringWithFormat:@"sharepdffile://"]];
            
            [[UIApplication sharedApplication] openURL:container options:@{} completionHandler:nil];
            NSLog(@"container===%d",[[UIApplication sharedApplication] canOpenURL:container]);
            
            if ([[UIApplication sharedApplication] canOpenURL:container]) {
                [[UIApplication sharedApplication] openURL:container options:@{} completionHandler:nil];
            }else{
                NSString *url = @"https://itunes.apple.com/app/apple-store/id1523972672";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
            }
        });
    });
}
#pragma mark -- 计算所选文件大小
+ (long)top_calculateAllFilesSize:(NSArray *)fileArr {
    NSMutableArray *docIds = @[].mutableCopy;
    NSMutableArray *folderIds = @[].mutableCopy;
    for (int i = 0; i<fileArr.count; i++) {
        DocumentModel * model = fileArr[i];
        if ([model.type isEqualToString:@"1"]) {//documents
            if (model.docId) {
                [docIds addObject:model.docId];
            }
        }
        if([model.type isEqualToString:@"0"]){
            if (model.docId) {
                [folderIds addObject:model.docId];
            }
        }
    }
    long docSize = [TOPDBDataHandler top_sumDocumentsFileSize:docIds];
    long fldSize = [TOPDBDataHandler top_sumFoldersFileSize:folderIds];
    return (docSize + fldSize);
}

#pragma mark -- 计算所选文件大小
+ (long)top_calculateSelectFilesSize:(NSArray *)fileArr {
    NSMutableArray *docIds = @[].mutableCopy;
    NSMutableArray *folderIds = @[].mutableCopy;
    for (DocumentModel * model in fileArr) {
        if (model.selectStatus) {
            if ([model.type isEqualToString:@"1"]) {//documents
                [docIds addObject:model.docId];
            } else {
                [folderIds addObject:model.docId];
            }
        }
    }
    long docSize = [TOPDBDataHandler top_sumDocumentsFileSize:docIds];
    long fldSize = [TOPDBDataHandler top_sumFoldersFileSize:folderIds];
    return (docSize + fldSize);
}

#pragma mark -- 计算所选图片大小
+ (long)top_calculateSelectImagesSize:(NSArray *)imgArr {
    NSMutableArray *imgIds = @[].mutableCopy;
    for (DocumentModel * model in imgArr) {
        if (model.selectStatus) {
            [imgIds addObject:model.docId];
        }
    }
    long imgSize = [TOPDBDataHandler top_sumImagesFileSize:imgIds];
    return imgSize;
}

+ (NSMutableArray *)top_getSelectFolderPicture:(NSArray *)sendArray{
    NSArray * pathArray = [NSArray new];
    NSMutableArray * emailArray = [NSMutableArray new];
    for (DocumentModel * model in sendArray) {
        if (model.selectStatus) {
            //在folder文件夹下 获取图片
            if ([model.type isEqualToString:@"0"]) {
                NSMutableArray * documentArray = [NSMutableArray new];
                //folder下的Documents文件夹中的所有文件夹的路径，图片都是存放在documents文件夹中的文件夹里的
                NSMutableArray * getArry = [self top_showAllFileWithPath:model.path documentArray:documentArray];
                //遍历出文件夹路径
                for (NSString * documentPath in getArry) {
                    //Documents文件夹下的文件夹里的图片名称集合 及路径下的图片名称集合
                    NSArray * documentArray = [self top_getCurrentFileAndPath:documentPath];
                    for (NSString * picName in documentArray) {
                        //拼接成图片路径 文件夹路径+图片名称=图片路径
                        NSString * picPath = [documentPath stringByAppendingPathComponent:picName];
                        [emailArray addObject:picPath];
                    }
                }
            }
            
            if ([model.type isEqualToString:@"1"]) {
                pathArray = [self top_getCurrentFileAndPath:model.path];
                for (NSString * pcStr in pathArray) {
                    NSString * fullPath = [NSString stringWithFormat:@"%@/%@",model.path,pcStr];
                    [emailArray addObject:fullPath];
                }
            }
        }
    }
    return emailArray;
}

+ (NSArray *)top_getSelectPicture:(NSArray *)sendArray{
    NSMutableArray * emailArray = [NSMutableArray new];
    for (DocumentModel * model in sendArray) {
        if (model.selectStatus) {
            //在folder文件夹下 获取图片
            if ([model.type isEqualToString:@"0"]) {
                NSMutableArray * documentArray = [NSMutableArray new];
                //folder下的Documents文件夹中的所有文件夹的路径，图片都是存放在documents文件夹中的文件夹里的
                NSMutableArray * getArry = [self top_showAllFileWithPath:model.path documentArray:documentArray];
                //遍历出文件夹路径
                for (NSString * documentPath in getArry) {
                    //Documents文件夹下的文件夹里的图片名称集合 及路径下的图片名称集合
                    NSArray * documentArray = [self top_getCurrentFileAndPath:documentPath];
                    for (NSString * picName in documentArray) {
                        //拼接成图片路径 文件夹路径+图片名称=图片路径
                        NSString * picPath = [documentPath stringByAppendingPathComponent:picName];
                        [emailArray addObject:picPath];
                    }
                }
            }
            
            if ([model.type isEqualToString:@"1"]) {
                [emailArray addObject:model.imagePath];
            }
        }
    }
    return emailArray;
}

+ (NSString *)top_getTxtPath:(NSString *)filePath imgName:(NSString *)imgName txtType:(nonnull NSString *)type{
    //imgName 不带后缀的图片名 filePath是文件夹的路径
    //拼接成txt文档的名称
    NSString *noteFileName =  [NSString stringWithFormat:@"%@%@.txt",type,imgName];
    //拼接成txt文档的路径
    NSString *noteFilePath = [NSString stringWithFormat:@"%@/%@",filePath,noteFileName];
    return noteFilePath;
}

+ (NSString *)top_getTxtPath:(NSString *)filePath imgPriName:(nonnull NSString *)imgName txtType:(nonnull NSString *)type{
    NSArray * tempArray = [imgName componentsSeparatedByString:@".jpg"];
    NSString * nameString = [NSString new];
    NSString * noteFilePath = [NSString new];
    if (tempArray.count>0) {
        nameString = tempArray[0];
    }
    //拼接成txt文档的名称
    NSString *noteFileName =  [NSString stringWithFormat:@"%@%@.txt",type,nameString];
    //拼接成txt文档的路径
    noteFilePath = [NSString stringWithFormat:@"%@/%@",filePath,noteFileName];
    return noteFilePath;
}

+ (NSString *)top_getTxtContent:(NSString *)txtPath{
    NSString * txtContentString = [[NSString alloc]initWithContentsOfFile:txtPath encoding:NSUTF8StringEncoding error:nil];
    return txtContentString;
}

+ (NSArray *)top_getAllLanguageData{
    NSString * languagePath = [[NSBundle mainBundle] pathForResource:@"LanguageList" ofType:@"plist"];
    NSArray * languageArray = [[NSArray alloc]initWithContentsOfFile:languagePath];
    return languageArray;
}

+ (NSArray *)top_getThirdLanguageData{
    NSString * languagePath = [[NSBundle mainBundle] pathForResource:@"ThirdLanguageList" ofType:@"plist"];
    NSArray * languageArray = [[NSArray alloc]initWithContentsOfFile:languagePath];
    return languageArray;
}

+ (NSArray *)top_getGoogleLanguageData{
    NSString * languagePath = [[NSBundle mainBundle] pathForResource:@"GoogleLanguageList" ofType:@"plist"];
    NSArray * languageArray = [[NSArray alloc]initWithContentsOfFile:languagePath];
    return languageArray;
}

+ (NSArray *)top_getGoogleLocationLanguageData{
    NSString * languagePath = [[NSBundle mainBundle] pathForResource:@"GoogleLocationLanguage" ofType:@"plist"];
    NSArray * languageArray = [[NSArray alloc]initWithContentsOfFile:languagePath];
    return languageArray;
}

+ (NSArray *)top_getSCVCClassData{
    NSString * vcClassPath = [[NSBundle mainBundle] pathForResource:@"TOPVClassList" ofType:@"plist"];
    NSArray * vcClassArry = [[NSArray alloc]initWithContentsOfFile:vcClassPath];
    return vcClassArry;
}
+ (NSString *)top_getEndPoint:(NSDictionary *)languageDic{
    NSArray * thirdLanguage = [self top_getThirdLanguageData];//第三方语言
    NSArray * googleLanguage = [self top_getGoogleLanguageData];//google语言
    NSString * url_usa = @"https://apipro1.ocr.space/parse/image"; //USA OCR API Endpoints
    NSString * url_europe = @"https://apipro2.ocr.space/parse/image"; //Europe OCR API
    NSString * url_asia = @"https://apipro3.ocr.space/parse/image"; // Asia OCR API Endpoints
    
    NSArray * usaArray = @[@"eng"];
    NSArray * europeArray = @[@"bul",@"hrv",@"cze",@"dan",@"dut",@"fin",@"fre",@"ger",@"gre",@"hun",@"ita",@"pol",@"por",@"rus",@"slv",@"spa",@"swe",@"tur"];
    NSArray * asiaArray = @[@"ara",@"chs",@"cht",@"kor",@"jpn"];
    //首先要根据语言判断是google识别还是第三方识别 google识别是没有节点的 保存的默认节点只是第三方的
    if ([thirdLanguage containsObject:languageDic]) {
        if (languageDic.allKeys.count>0) {
            if ([TOPScanerShare top_saveOcrEndpoint] == nil) {
                if ([usaArray containsObject:languageDic.allValues[0]] ) {
                    return url_usa;
                }
                if ([europeArray containsObject:languageDic.allValues[0]]) {
                    return url_europe;
                }
                if ([asiaArray containsObject:languageDic.allValues[0]]) {
                    return url_asia;
                }
            }else{
                NSDictionary * tempDic = [TOPScanerShare top_saveOcrEndpoint];
                if (tempDic.allKeys.count>0) {
                    if ([tempDic.allKeys[0] isEqualToString:@"USA"]) {
                        return url_usa;
                    }else if([tempDic.allKeys[0] isEqualToString:@"Europe"]){
                        return url_europe;
                    }else{
                        return url_asia;
                    }
                }
            }
        }
    }
    
    if ([googleLanguage containsObject:languageDic]) {
        return nil;
    }
    return nil;
}

+ (NSArray *)top_getEndpointData{
    NSArray * endpointArray = @[@{@"USA":@"https://apipro1.ocr.space/parse/image"},@{@"Europe":@"https://apipro2.ocr.space/parse/image"},@{@"Asia":@"https://apipro3.ocr.space/parse/image"}];
    return endpointArray;
}

+ (NSInteger)top_getOCREngine:(NSString *)language{
    NSInteger OCREngine = 0;
    if ([language isEqualToString:@"dan"]||[language isEqualToString:@"dut"]||[language isEqualToString:@"eng"]||[language isEqualToString:@"fre"]||[language isEqualToString:@"ger"]||[language isEqualToString:@"ita"]||[language isEqualToString:@"pol"]||[language isEqualToString:@"por"]||[language isEqualToString:@"spa"]) {
        OCREngine = 2;
    }else{
        OCREngine = 1;
    }
    return OCREngine;
}

+ (NSString *)top_getTimeAfterNowWithDay:(int)day{
    NSDate * currentDate = [NSDate date];
    NSDate *theDate;
    NSLog(@"currentDate==%@",currentDate);
    NSTimeInterval  oneDay = 24*60*60*1;  //3天的长度
    //    NSTimeInterval  oneDay = 30;  //3天的长度
    theDate = [currentDate initWithTimeIntervalSinceNow: oneDay*day];
    NSTimeInterval timeInterval = [theDate timeIntervalSince1970];
    NSString * timeString = [NSString stringWithFormat:@"%.0f",timeInterval];
    return timeString;
}

+ (NSString *)top_getCurrentSecondTimeInterval{
    NSDate * currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSince1970]*1000;
    NSString * timeString = [NSString stringWithFormat:@"%.0f",timeInterval];
    return timeString;
}
+ (NSString *)top_getCurrentTimeInterval{
    NSDate * currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSince1970];
    NSString * timeString = [NSString stringWithFormat:@"%.0f",timeInterval];
    return timeString;
}
+ (void)top_getUIImageFromPDFPageWithpdfpathUrl:(CGPDFDocumentRef)fromPDFDoc password:(NSString *)passwordStr docPath:(nonnull NSString *)path progress:(nonnull void (^)(CGFloat progressString))progress success:(nonnull void (^)(id _Nonnull))success
{
    NSMutableArray *tempImagePathArrays = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger pages = (NSInteger)CGPDFDocumentGetNumberOfPages(fromPDFDoc);
        //判断PDF是否为空
        if (fromPDFDoc == NULL) {
        }
        //判断PDF是否有密码有密码需要输入密码
        if (passwordStr.length!=0 || passwordStr != nil) {//判断pdf是否加密
            if (!CGPDFDocumentUnlockWithPassword (fromPDFDoc, "")) {//判断密码是否为""
                if (passwordStr != NULL) {
                    if (!CGPDFDocumentUnlockWithPassword (fromPDFDoc, [passwordStr UTF8String]))
                        //使用password对pdf进行解密，密码有效返回yes
                        NSLog(@"invalid password.");
                }
            }
        }
        int i = 1;
        for (i = 1; i <= pages; i++) {
            @autoreleasepool {
                UIImage * tempImage = [self top_getPDFImage:fromPDFDoc index:i];
                if (tempImage) {
                    [self savePDFImage:tempImage imagePath:path index:i];
                    CGFloat stateF = (i * 10.0)/(pages * 10.0);
                    progress(stateF);
                }
                if (i == pages) {
                    success(tempImagePathArrays);
                }
            }
        }
        CGPDFDocumentRelease(fromPDFDoc);
    });
}
+ (void)top_getCloudUIImageFromPDFPageWithpdfpathUrl:(CGPDFDocumentRef)fromPDFDoc password:(NSString *)passwordStr docPath:(nonnull NSString *)path homeChildPath:(NSString *)childPath progress:(nonnull void (^)(CGFloat progressString))progress success:(nonnull void (^)(id _Nonnull))success
{
    NSMutableArray *tempImagePathArrays = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //判断PDF是否为空
        if (fromPDFDoc == NULL) {
        }else{
            NSInteger pages = (NSInteger)CGPDFDocumentGetNumberOfPages(fromPDFDoc);
            //判断PDF是否有密码有密码需要输入密码
            if (passwordStr.length!=0 || passwordStr != nil) {//判断pdf是否加密
                if (!CGPDFDocumentUnlockWithPassword (fromPDFDoc, "")) {//判断密码是否为""
                    if (passwordStr != NULL) {
                        if (!CGPDFDocumentUnlockWithPassword (fromPDFDoc, [passwordStr UTF8String]))
                            //使用password对pdf进行解密，密码有效返回yes
                            NSLog(@"invalid password.");
                    }
                }
            }
            int i = 1;
            NSArray *  pdfimageArrays = [TOPDocumentHelper top_sortPicsAtPath: [TOPDocumentHelper top_getDriveDownloadJPGPathPathString]];
            NSArray *  homeChildArrays = [NSArray array];
            if (childPath.length>0) {
                homeChildArrays = [TOPDocumentHelper top_sortPicsAtPath:childPath];
            }
            for (i = 1; i <= pages; i++) {
                @autoreleasepool {
                    UIImage * tempImage = [self top_getPDFImage:fromPDFDoc index:i];
                    if (tempImage) {
                        [self savePDFImage:tempImage imagePath:path index:i+pdfimageArrays.count+homeChildArrays.count];
                        CGFloat stateF = (i * 10.0)/(pages * 10.0);
                        progress(stateF);
                    }
                    if (i == pages) {
                        success(tempImagePathArrays);
                    }
                }
            }
            CGPDFDocumentRelease(fromPDFDoc);
        }
    });
}
#pragma mark -- 拆分pdf
+ (UIImage *)top_getPDFImage:(CGPDFDocumentRef)fromPDFDoc index:(NSInteger)i{
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(fromPDFDoc, i);
    CGPDFPageRetain(pageRef);
    CGFloat scaleCustom = 3;
    CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFMediaBox);
    CGFloat imagePiexl = pageRect.size.width * pageRect.size.height * 9;
    if (imagePiexl > TOP_TRSSMaxPiexl) {//图片过大需要压缩 SSMaxPiexl
        float rate = imagePiexl / TOP_TRSSMaxPiexl;
        float scale = sqrtf(rate);
        CGFloat sizeH =  pageRect.size.height*3/ scale;
        CGFloat sizeW = pageRect.size.width *3/ scale;
        pageRect.size.height= sizeH;
        pageRect.size.width= sizeW;
    }else{
        pageRect.size.height= pageRect.size.height*scaleCustom;
        pageRect.size.width= pageRect.size.width*scaleCustom;
    }
    
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef imgContext = UIGraphicsGetCurrentContext();
    //设置白色背景
    CGContextSetRGBFillColor(imgContext, 1.0,1.0,1.0,1.0);
    CGContextFillRect(imgContext,pageRect);
    CGContextSaveGState(imgContext);
    CGContextTranslateCTM(imgContext, -pageRect.size.width*((scaleCustom-1)/2), pageRect.size.height*(scaleCustom/2+0.5));
    CGContextScaleCTM(imgContext,scaleCustom, -scaleCustom);
    CGContextSetRenderingIntent(imgContext, kCGRenderingIntentDefault);
    CGContextSetInterpolationQuality(imgContext, kCGInterpolationDefault);
    CGContextConcatCTM(imgContext, CGPDFPageGetDrawingTransform(pageRef, kCGPDFMediaBox, pageRect,0,true));
    CGContextDrawPDFPage(imgContext, pageRef);
    CGContextRestoreGState(imgContext);
    //PDF Page to image
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //Release current source page
    CGPDFPageRelease(pageRef);
    pageRef = NULL;
    return tempImage;
}
#pragma mark --高斯模糊
+ (UIImage *)top_blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if (image == nil) {
        return nil;
    }
    
    if (image.CGImage) {
        @autoreleasepool {
            CIContext *context = [CIContext contextWithOptions:nil];
            CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
            CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
            [filter setValue:ciImage forKey:kCIInputImageKey];
            //设置模糊程度
            [filter setValue:@(blur) forKey: @"inputRadius"];
            CIImage *result = [filter valueForKey:kCIOutputImageKey];
            CGImageRef outImage = [context createCGImage: result fromRect:ciImage.extent];
            UIImage * blurImage = [UIImage imageWithCGImage:outImage];
            CGImageRelease(outImage);
            outImage = nil;
            context = nil;
            filter = nil;
            return blurImage;
        }
    }else{
        return image;
    }
}

#pragma mark -- 写入pdf图片到本地
+ (void)savePDFImage:(UIImage *)image imagePath:(NSString *)path index:(NSInteger)i{
    NSString *imgName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
    NSString *oriName = [NSString stringWithFormat:@"%@%@%@%@",TOPRSimpleScanOriginalString,[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [path stringByAppendingPathComponent:imgName];
    NSString *oriEndPath = [path stringByAppendingPathComponent:oriName];
    [UIImageJPEGRepresentation(image, TOP_TRPicScale) writeToFile:fileEndPath atomically:YES];
    [UIImageJPEGRepresentation(image, TOP_TRPicScale) writeToFile:oriEndPath atomically:YES];
}

+ (UIImage *)top_imageAtRect:(UIImage *)originImg imageRect:(CGRect)imgRect{
    if (imgRect.size.width) {
        CGImageRef imageRef = CGImageCreateWithImageInRect([originImg CGImage], imgRect);
        UIImage* subImage = [UIImage imageWithCGImage: imageRef];
        CGImageRelease(imageRef);
        
        return subImage;
    }
    return originImg;
}

#pragma mark -- 复制文件下过滤临时文件的所有图片(同步云盘方法使用)
+ (void)top_copyFileItemsFilterAtPath:(NSString *)path toNewFileAtPath:(NSString *)newPath {
    NSArray *tempContentsArray = [TOPWHCFileManager top_listFilesInDirectoryAtPath:path deep:NO];
    
    for (NSString *tempContentPath in tempContentsArray) {
        if ([tempContentPath isEqualToString:@".DS_Store"] || [tempContentPath isEqualToString:@"temporary"] || [tempContentPath containsString:@".plist"] ) {
            continue;
        }
        NSString *oldContentPath = [path stringByAppendingPathComponent:tempContentPath];
        NSString *newContentPath = [newPath stringByAppendingPathComponent:tempContentPath];
        //图片复制到指定文件
        [TOPWHCFileManager top_copyItemAtPath:oldContentPath toPath:newContentPath];
    }
}
+ (NSString *)top_getEnish2ForMatterWith:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设置时间格式
    formatter.dateFormat = @"MMM dd,yyyy,HH:mm:ss";
    NSString *dateStr = [formatter  stringFromDate:date];
    return dateStr;
}
+ (float)top_freeDiskSpaceInBytes{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace/1024.0/1024.0;
}
+ (void)top_addLocalNotificationWithTitle:(NSString *)title subTitle:(NSString *)subTitle body:(NSString *)body timeInterval:(long)timeInterval identifier:(NSString *)identifier userInfo:(NSDictionary *)userInfo repeats:(int)repeats
{
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        // 标题
        if (title.length) {
            content.title = title;
        }
        if (subTitle.length) {
            content.subtitle = subTitle;
        }
        // 内容
        if (body.length) {
            content.body = body;
        }
        if (userInfo != nil) {
            content.userInfo = userInfo;
        }
        // 声音
        // 默认声音
        content.sound = [UNNotificationSound defaultSound];
        // 添加自定义声音
        // 角标 （我这里测试的角标无效，暂时没找到原因）
        content.badge = @1;
        // 多少秒后发送,可以将固定的日期转化为时间
        NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:timeInterval] timeIntervalSinceNow];
        UNNotificationTrigger *trigger = nil;
        // repeats，是否重复，如果重复的话时间必须大于60s，要不会报错
        if (repeats > 0 && repeats < 7) {
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
            // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
            unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitWeekday | NSCalendarUnitMinute | NSCalendarUnitSecond;
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            // 获取不同时间字段的信息
            NSDateComponents* comp = [gregorian components:unitFlags fromDate:date];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.second = comp.second;
            if (repeats == 6) {
                //每分钟循环
            } else if (repeats == 5) {
                //每小时循环
                components.minute = comp.minute;
            } else if (repeats == 4) {
                //每天循环
                components.minute = comp.minute;
                components.hour = comp.hour;
            } else if (repeats == 3) {
                //每周循环
                components.minute = comp.minute;
                components.hour = comp.hour;
                components.weekday = comp.weekday;
            } else if (repeats == 2) {
                //每月循环
                components.minute = comp.minute;
                components.hour = comp.hour;
                components.day = comp.day;
                components.month = comp.month;
            } else if (repeats == 1) {
                //每年循环
                components.minute = comp.minute;
                components.hour = comp.hour;
                components.day = comp.day;
                components.month = comp.month;
                components.year = comp.year;
            }
            trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
        } else {
            //不循环
            trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
        }
        // 添加通知的标识符，可以用于移除，更新等操作 identifier
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            NSLog(@"ECKPushSDK log:添加本地推送成功");
        }];
    } else {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        // 发出推送的日期
        notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
        if (title.length > 0) {
            notif.alertTitle = title;
        }
        // 推送的内容
        if (body.length > 0) {
            notif.alertBody = body;
        }
        if (userInfo != nil) {
            NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            [mdict setObject:identifier forKey:@"identifier"];
            notif.userInfo = mdict;
        } else {
            // 可以添加特定信息
            notif.userInfo = @{@"identifier":identifier};
        }
        // 角标
        notif.applicationIconBadgeNumber = 1;
        // 提示音
        notif.soundName = UILocalNotificationDefaultSoundName;
        // 循环提醒
        if (repeats == 6) {
            //每分钟循环
            notif.repeatInterval = NSCalendarUnitMinute;
        } else if (repeats == 5) {
            //每小时循环
            notif.repeatInterval = NSCalendarUnitHour;
        } else if (repeats == 4) {
            //每天循环
            notif.repeatInterval = NSCalendarUnitDay;
        } else if (repeats == 3) {
            //每周循环
            notif.repeatInterval = NSCalendarUnitWeekday;
        } else if (repeats == 2) {
            //每月循环
            notif.repeatInterval = NSCalendarUnitMonth;
        } else if (repeats == 1) {
            //每年循环
            notif.repeatInterval = NSCalendarUnitYear;
        } else {
            //不循环
        }
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    }
}

+ (NSString *)top_getFolderShowName:(NSString *)path{
    NSString * nameString = [NSString new];
    NSString * foldersPath =  [TOPDocumentHelper top_getBelongDocumentPathString:@"Folders"];
    NSArray * tempArray = [path componentsSeparatedByString:foldersPath];
    NSString * tagsName = [TOPScanerShare top_saveTagsName];
    if ([tagsName isEqualToString:TOP_TRTagsAllDocesKey]) {
        tagsName = TOP_TRTagsAllDocesName;
    }else if([tagsName isEqualToString:TOP_TRTagsUngroupedKey]){
        tagsName = TOP_TRTagsUngroupedName;
    }
    nameString = [tagsName stringByAppendingPathComponent:tempArray[1]];
    return nameString;
}

/**
 移除某一个指定的通知
 @param noticeId 通知标识符
 */
+ (void)top_removeNotificationWithIdentifierID:(NSString *)noticeId
{
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            for (UNNotificationRequest *req in requests){
                NSLog(@"ECKPushSDK log: 当前存在的本地通知identifier: %@\n", req.identifier);
            }
        }];
        [center removePendingNotificationRequestsWithIdentifiers:@[noticeId]];
    } else {
        NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *localNotification in array){
            NSDictionary *userInfo = localNotification.userInfo;
            NSString *obj = [userInfo objectForKey:@"identifier"];
            if ([obj isEqualToString:noticeId]) {
                [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            }
        }
    }
}

/*
 移除所有通知
 */
+ (void)top_removeAllNotification
{
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
    }else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}
#pragma mark -- 获取设备是否支持Touchid 和Faceid

+ (TOPLAContextSupportType)top_getBiometryType {
    LAContext *context = [LAContext new];
    NSError *error = nil;
    BOOL supportEvaluatePolicy = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    TOPLAContextSupportType type = TOPLAContextSupportTypeNone;
    if (@available(iOS 11.0, *)) {
        if (context.biometryType == LABiometryTypeTouchID) {
            // 指纹
            if (error) {
                type = TOPLAContextSupportTypeTouchIDNotEnrolled;
            } else {
                type = TOPLAContextSupportTypeTouchID;
            }
        }else if (context.biometryType == LABiometryTypeFaceID) {
            // 面容
            if (error) {
                type = TOPLAContextSupportTypeFaceIDNotEnrolled;
            } else {
                type = TOPLAContextSupportTypeFaceID;
            }
        }else {
            // 不支持
        }
    } else {
        if (error) {
            if (error.code == LAErrorTouchIDNotEnrolled) {
                // 支持指纹但没有设置
                type = TOPLAContextSupportTypeTouchIDNotEnrolled;
            }
        } else {
            type = TOPLAContextSupportTypeTouchID;
        }
    }
#ifdef DEBUG
    NSArray *testArr = @[@"不支持指纹face",@"指纹录入",@"faceid录入",@"指纹未录入",@"faceID未录入"];
    NSInteger index = (NSInteger)type;
    NSLog(@"%@===xxx===%d=====%@",testArr[index],supportEvaluatePolicy,error);
#endif
    return type;
}
#pragma mark- 获取临时 的解压文件夹
+ (NSString *)top_tempUnzipPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:TOPTemporaryPathUnZip]){//如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        [fileManager createDirectoryAtPath:TOPTemporaryPathUnZip withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@",
                      TOPTemporaryPathUnZip,
                      [NSUUID UUID].UUIDString];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:url
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
    if (error) {
        return nil;
    }
    return url.path;
}
#pragma mark- 获取一个网盘上传的字符串时间名称格式(MM-dd-yyyy HH-mm)
+ (NSString *)top_getCurrentYYYYDateForMatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设置时间格式
    formatter.dateFormat = @"MM-dd-yyyy HH-mm";
    NSString *dateStr = [formatter  stringFromDate:[NSDate date]];
    
    return dateStr;
    
}
#pragma mark -- 两坐标点之间的距离
+ (CGFloat)top_distanceBetweenPoints:(CGPoint)point1 :(CGPoint)point2{
    CGFloat xPow = pow((point1.x - point2.x), 2);
    CGFloat yPow = pow((point1.y - point2.y), 2);
    return sqrtf((xPow + yPow));
}

+ (NSArray *)top_specialStringArray{
    NSArray * tempArray = @[@"*",@"/",@"\\",@">",@"<",@"?",@"|",@"%"];
    return tempArray;
}

+ (BOOL)top_achiveStringWithWeb:(NSString *)infor{
    NSString *emailRegex = @"[a-zA-z]+://.*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:infor];
}
+  (void)top_subscriptEndTimeRenewedDay:(double)intervalData SuccessBlock:(void (^)(BOOL resultStates,NSString *_Nonnull amazonDateStr))resultBlock
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSString *urlString = @"https://www.amazon.com";
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:5];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_semaphore_signal(semaphore);
    
        if (response) {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {//请求成功
                NSString *date = [[httpResponse allHeaderFields] objectForKey:@"Date"];
                NSLog(@">>>>> date :%@",date);
                date = [date substringFromIndex:5];
                date = [date substringToIndex:[date length]-4];
                //NSLog(@">>>>> date :%@",date);
                NSDateFormatter *dMatter = [[NSDateFormatter alloc] init];
                dMatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                //    dMatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-CHS"];
                [dMatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];
                NSDate *netDate = [[dMatter dateFromString:date] dateByAddingTimeInterval:60*60*8];
                NSTimeZone *zone = [NSTimeZone systemTimeZone];
                NSInteger interval = [zone secondsFromGMTForDate: netDate];
                NSDate *localeDate = [netDate dateByAddingTimeInterval: interval];
                
                NSLog(@">>>>> localeDate :%@",localeDate);
                NSString *tmpDate = [NSString stringWithFormat:@"%@",localeDate];
                tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
                NSDateFormatter *format1=[[NSDateFormatter alloc]init];
                [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *nowDate = [format1 dateFromString:tmpDate];
                NSLog(@">>>>> nowDate :%@",nowDate);
                NSDate *pDate1 =[NSDate dateWithTimeIntervalSince1970:intervalData/1000];
                
                NSCalendar *calendar = [NSCalendar currentCalendar];
                
                unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
                // 1.获得当前亚马逊时间的年月日
                NSDateComponents *nowCmps = [calendar components:unitFlags fromDate:nowDate];
                // 1.获得当前亚马逊时间的年月日
                NSDateComponents *subscriptUpdateOcrCmps = [calendar components:unitFlags fromDate:pDate1];
                
                //                NSComparisonResult result = [nowDate compare:pDate1];
                BOOL isConetntStates = NO;
                if (nowCmps.year >subscriptUpdateOcrCmps.year) {
                    isConetntStates = YES;
                }else{
                    if (nowCmps.month >subscriptUpdateOcrCmps.month)
                    {
                        isConetntStates = YES;
                    }else{
                        isConetntStates = NO;
                    }
                }
                
                NSString * nowInternetDate = [format1 stringFromDate:nowDate];
                
                resultBlock(isConetntStates,nowInternetDate);
            }
        }else{
            NSDateFormatter *format1=[[NSDateFormatter alloc]init];
            [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate * pDate2 = [NSDate date];
            NSDate *pDate1 =[NSDate dateWithTimeIntervalSince1970:intervalData/1000];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            
            unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            // 1.获得当前亚马逊时间的年月日
            NSDateComponents *nowCmps = [calendar components:unitFlags fromDate:pDate2];
            // 1.获得当前亚马逊时间的年月日
            NSDateComponents *subscriptUpdateOcrCmps = [calendar components:unitFlags fromDate:pDate1];
            
            //                NSComparisonResult result = [nowDate compare:pDate1];
            BOOL isConetntStates = NO;
            if (nowCmps.year >subscriptUpdateOcrCmps.year) {
                isConetntStates = YES;
            }else{
                if (nowCmps.month >subscriptUpdateOcrCmps.month)
                {
                    isConetntStates = YES;
                }else{
                    isConetntStates = NO;
                }
            }
            NSString * nowInternetDate = [format1 stringFromDate:pDate2];
            
            resultBlock(isConetntStates,nowInternetDate);
        }
    }];
    
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

/**
 获取网络时间 (默认获取的事百度服务器时间)
 */
+ (void)top_getInternetDateBlock:(void (^)(NSString * nowInternetDate))selectBlock
{
    //NSString *urlString = @"https://www.baidu.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSString *urlString = @"https://www.amazon.com";
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:5];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_semaphore_signal(semaphore);
        
        if (response) {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {//请求成功
                NSString *date = [[httpResponse allHeaderFields] objectForKey:@"Date"];
                NSLog(@">>>>> date :%@",date);
                date = [date substringFromIndex:5];
                date = [date substringToIndex:[date length]-4];
                //NSLog(@">>>>> date :%@",date);
                NSDateFormatter *dMatter = [[NSDateFormatter alloc] init];
                dMatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                //    dMatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-CHS"];
                [dMatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];
                NSDate *netDate = [[dMatter dateFromString:date] dateByAddingTimeInterval:60*60*8];
                NSTimeZone *zone = [NSTimeZone systemTimeZone];
                NSInteger interval = [zone secondsFromGMTForDate: netDate];
                NSDate *localeDate = [netDate dateByAddingTimeInterval: interval];
                
                NSLog(@">>>>> localeDate :%@",localeDate);
                NSString *tmpDate = [NSString stringWithFormat:@"%@",localeDate];
                tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
                NSDateFormatter *format1=[[NSDateFormatter alloc]init];
                [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *nowDate = [format1 dateFromString:tmpDate];
                NSString * nowInternetDate = [format1 stringFromDate:nowDate];
                selectBlock(nowInternetDate);
            }
        }else{
            NSDateFormatter *format1=[[NSDateFormatter alloc]init];
            [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString * nowInternetDate = [format1 stringFromDate:[NSDate date]];
            selectBlock(nowInternetDate);
        }
    }];
    
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

+ (NSString *)top_decodeFromPercentEscapeString:(NSString *)input {
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [outputStr length])];
    return [input stringByRemovingPercentEncoding];
}
+ (BOOL)top_getSelectFolderDocPicState:(NSArray *)sendArray{
    for (DocumentModel * model in sendArray) {
        if (model.selectStatus) {
            if ([model.type isEqualToString:@"1"]) {
                return YES;
            }else{
                //document 文档
                RLMResults<TOPAppDocument *> *documents = [TOPDBQueryService top_documentsAtFoler:model.docId];
                if (documents.count) {//有文档
                    return YES;
                }
            }
        }
    }
    return NO;
}
#pragma mark -- 广告植入的索引
+ (NSInteger)top_adMobIndexWithListType:(NSInteger)listType byItemCount:(NSInteger)count {
    NSInteger adIndex = 0;
    if (listType == ShowTwoGoods) {
        adIndex = count < 4 ? count : ((rand() % (4-2+1) + 2 )-1);//2,3,4  后面的减-1是获取插入数组的下标
    } else if (listType == ShowThreeGoods) {
        adIndex = count < 9 ? count : (rand() % (8-5+1) + 5);//5,6,7,8随机数
    } else if (listType == ShowListGoods) {
        adIndex = count < 7 ? count : (rand() % (6-3+1) + 3);//3,4,5,6随机数
    } else if(listType == ShowListNextGoods){
        adIndex = count < 7 ? count : (rand() % (6-3+1) + 3);//3,4,5,6随机数
    }
    return adIndex;
}
#pragma mark -- 插页广告ID
+ (NSArray *)top_interstitialAdID{
    NSArray * idArray = @[@"ca-app-pub-1310679029621015/8473192013",
                          @"ca-app-pub-1310679029621015/2209082281",
                          @"ca-app-pub-1310679029621015/1907783660",
                          @"ca-app-pub-1310679029621015/6968538656",
                          @"ca-app-pub-1310679029621015/7788712028",
                          @"ca-app-pub-1310679029621015/2646150261",
                          @"ca-app-pub-1310679029621015/6052070475",
                          @"ca-app-pub-1310679029621015/6232087779"];
    return idArray;
}
#pragma mark -- 横幅广告ID
+ (NSArray *)top_bannerAdID{
    NSArray * idArray = @[@"ca-app-pub-1310679029621015/2400653970",
                          @"ca-app-pub-1310679029621015/4041038704",
                          @"ca-app-pub-1310679029621015/2674070423",
                          @"ca-app-pub-1310679029621015/6421743740",
                          @"ca-app-pub-1310679029621015/3795580403",
                          @"ca-app-pub-1310679029621015/8856335398",
                          @"ca-app-pub-1310679029621015/2290927041",
                          @"ca-app-pub-1310679029621015/4821969038"];
    return idArray;
}
#pragma mark -- 开屏广告ID
+ (NSArray *)top_AppOpenAdID{
    NSArray * idArray = @[@"ca-app-pub-1310679029621015/6164802494"];
    return idArray;
}
#pragma mark -- 原生广告ID
+ (NSArray *)top_nativeAdID{
    NSArray * idArray = @[@"ca-app-pub-1310679029621015/5860498781",
                          @"ca-app-pub-1310679029621015/9608172109",
                          @"ca-app-pub-1310679029621015/4355845426",
                          @"ca-app-pub-1310679029621015/8103518745",
                          @"ca-app-pub-1310679029621015/7477884162",];
    return idArray;
}

/**
 为文件增加一个扩展属性
 @param path 文件路径
 @param key 文件属性Key
 @param attribute 文件属性内容
 
 */
+ (BOOL)top_extended2WithPath:(NSString *)path key:(NSString *)key value:(NSString *)attribute
{
    NSData *value = [NSPropertyListSerialization dataWithPropertyList:attribute format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    NSDictionary *extendedAttributes = [NSDictionary dictionaryWithObject:
                                        [NSDictionary dictionaryWithObject:value forKey:key]
                                                                   forKey:@"NSFileExtendedAttributes"];
    
    NSError *error = NULL;
    BOOL sucess = [[NSFileManager defaultManager] setAttributes:extendedAttributes
                                                   ofItemAtPath:path error:&error];
    return sucess;
}
/**
 读取文件扩展属性
 @param path 文件路径
 @param key 文件属性Key
 */
+ (id)top_extended2WithPath:(NSString *)path key:(NSString *)key
{
    NSError *error = NULL;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (!attributes) {
        return nil;
    }
    NSDictionary *extendedAttributes = [attributes objectForKey:@"NSFileExtendedAttributes"];
    if (!extendedAttributes) {
        return nil;
    }
    NSData *data = [extendedAttributes objectForKey:key];
    
    id plist = [NSPropertyListSerialization propertyListWithData:data options:0 format:NSPropertyListImmutable error:nil];
    
    return [plist description];
}
#pragma mark -- 插页广告出现的数值为1-12之间的数
+ (int)top_interstitialAdRandomNumber{
    int index = rand() % (12 - 1 +1 ) + 1;
    return index;
}
+ (BOOL)top_isdark{
    if (@available(iOS 13.0,*)) {
        if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleUnspecified) {
            if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return YES;
            }else{
                return NO;
            }
        }else{
            if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleLight) {
                return NO;
            }else{
                return YES;
            }
        }
    }else{
        return NO;
    }
}
+ (UIStatusBarStyle)top_barStyle{
    if (@available(iOS 13.0,*)) {
        if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleUnspecified) {
            return UIStatusBarStyleDefault;
        }else{
            if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleLight) {
                return UIStatusBarStyleDarkContent;
            }else{
                return UIStatusBarStyleLightContent;
            }
        }
    }else{
        return UIStatusBarStyleDefault;
    }
}
#pragma mark -- 获取顶层的push出控制器
+ (UIViewController *)top_appRootViewController {
    UIViewController *RootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = RootVC;
    if ([RootVC isKindOfClass:[TOPMainTabBarController class]]) {
        TOPMainTabBarController *tabVC = (TOPMainTabBarController *)RootVC;
        topVC = tabVC.selectedViewController;
    }
    while (topVC.presentedViewController) {
        if ([topVC.presentedViewController isKindOfClass:[UIActivityViewController class]]) {//去除present出来的控制器 找到最后push的控制器
            break;
        }
        if ([topVC.presentedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController * temNav = (UINavigationController *)topVC.presentedViewController;
            UIViewController * vc = temNav.childViewControllers.lastObject;
            if ([vc isKindOfClass:[TOPFileTargetListViewController class]]) {
                break;
            }
        }
        topVC = topVC.presentedViewController;
    }
    return topVC;
}
#pragma mark -- 文件创建时间
+ (NSDate *)top_createTimeOfFile:(NSString *)path {
    NSDate *date = [TOPWHCFileManager top_creationDateOfItemAtPath:path];
    return date;
}

#pragma mark -- 文件修改时间
+ (NSDate *)top_updateTimeOfFile:(NSString *)path {
    NSDate *date = [TOPWHCFileManager top_modificationDateOfItemAtPath:path];
    return date;
}

+ (void)top_appReopenedNetworkState:(void (^)(BOOL isReopened))completion{
    __block BOOL isEdit = YES;
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    // 状态发生变化时调用
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState restrictedState) {//这个block回调不主动调用也会走 只要app的蜂窝数据状态发生改变就会调用 这样就不符合需求 所以在回调的外部加了个isEdit布尔值来加以控制
        if (isEdit) {//这里时为了保证只有按钮点击时才走下面的内容
            isEdit = NO;//这里是为了防止点击操作了之后，然后其他操作使蜂窝数据状态发生改变而导致主动调用
            BOOL isRestricted = YES;
            switch (restrictedState) {
                case kCTCellularDataRestrictedStateUnknown:
                    NSLog(@"蜂窝移动网络状态：未知");
                    break;
                case kCTCellularDataRestricted:
                    NSLog(@"蜂窝移动网络状态：关闭");
                    break;
                case kCTCellularDataNotRestricted:
                    NSLog(@"蜂窝移动网络状态：开启");
                    isRestricted = NO;
                    break;
                default:
                    break;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(isRestricted);
            });
        }
    };
}
@end
