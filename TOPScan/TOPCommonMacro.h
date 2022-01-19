//
//  TOPCommonMacro.h
//  uivery
//
//  Created by Edward. on 2016/11/4.
//  Copyright © 2016年 eddward. All rights reserved.
//
//在此应用下图片旋转只是更改了图片的转向属性 没有生成新的旋转图片 当imageview加载这张图片时 imageview会根据图片的旋转属性自动对图片进行旋转展示 所以断点调试时看见的旋转图和原图是一样的 区别就在于旋转属性的不一样 所以在对展示图(展示图是旋转后的图片)进行裁剪操作时 需要对展示图重新处理使之成为与imageview展示效果一样的图片 然后再生成裁剪图(例如OCR识别时 ocr识别处理的就是展示图而不是原图 识别的坐标有了之后需要先对展示图处理 再根据展示图和裁剪坐标来生成识别的裁剪图) 处理方法是img.fixOrientation 需要引入"UIImage+category.h"
#ifndef TOPCommonMacro_h
#define TOPCommonMacro_h

#undef WS
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#define WeakSelf(ws)  __weak __typeof(&*self)ws = self;

#undef SS
#define SS(strongSelf)  __strong __typeof(&*self)strongSelf = weakSelf;

#define weakify(var)   __weak typeof(var) weakSelf = var
#define blockify(var)  __block typeof(var) blockSelf = var
#define strongify(var) __strong typeof(var) strongSelf = var
#define AutoRelease_for(...) for(__VA_ARGS__) @autoreleasepool 
#define TRSSAppDelegate          ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define NULLString(string) ((![string isKindOfClass:[NSString class]])||[string isEqualToString:@""] || (string == nil) || [string isEqualToString:@""] || [string isEqualToString:@"<null>"] || [string isKindOfClass:[NSNull class]]||[[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
//iphoneX 底部 49 +  34 = 83   顶部 44 + 44 = 88   其它顶部 44 +  20 = 64

//设置界面email内容的路径
#define TOPSettingEmail_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TOPScanBox/SettingEmailContent.plist"]
//设置界面document默认名称的路径
#define TOPSettingFormatter_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TOPScanBox/SettingFormatterModel.plist"]
#define TOPSignationImagePath  [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/SignPng"]

//pdf文件的位置 --临时
#define TOPPDF_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/PDF"]
//压缩后的图片位置 --临时
#define TOPCompress_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/Compress"]
//保存拍照后的图片 --临时
#define TOPCamerPic_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/CamearPath"]
//保存拍照后的图片 这里是防止意外退出时拍完之后的图片丢失(例如拍照时意外退出app，app退入后台时间过长)，正常的拍照流程走完之后再清空，打开相机时该路径下有数据就给出弹框提示选择no时也清空掉
#define TOPAccidentCamerPic_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/accident/AccidentCamearPath"]
//重拍时保存图片的路径 -- 临时
#define TOPRetakeCamerPic_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/RetakeCamearPath"]


//同步时存储下载到zip的 临时文件夹
#define TOPTemporaryPathZip [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/TempZip"]
//压缩前的文件夹 临时文件夹
#define TOPTemporarySimpleScannerZip [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/SimpleScanner"]

#define TOPTemporaryPathUnZip [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/TempUnZip"]

//多张图片时保存需要调节的模版图片 --临时
#define TOPCameraBatchAdjustDraw_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/CameraBatchAdjustDrawPath"]
//多张图片时进入批量处理界面(即拍照界面的下一个界面)就开始做裁剪处理 保存裁剪后的图片 --临时
#define TOPCameraBatchCropDraw_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/CameraBatchCropDrawPath"]
//多张图片时进入批量处理界面(即拍照界面的下一个界面)原图的处理图（处理原图的像素大小到设置里的像素大小）
#define TOPCameraBatchCropDefaultDraw_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/CameraBatchCropDefaultDrawPath"]
//多张图片时进入批量处理在此处理的界面 如果将图片质量控制在500kb
#define TOPBatchCropAgainShow_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/BatchCropAgainShow_Path"]

#define TOPDefaultDraw_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/DefaultDrawPath"]
//多张张图片时保存渲染后的默认图片 --临时
#define TOPCameraBatchDefaultDraw_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/CameraBatchDefaultDrawPath"]
//图片对应的渲染图的小图 --临时
#define TOPCameraBatchProcessIcon_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/temporary/CameraBatchProcessIconPath"]

//批量处理时filter的展示图片位置
#define TOPBatchDefaultDraw_Path [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TOPScanBox/localSave/BatchDefaultDrawPath"]//不做app启动清除的操作 除非更换显示的本地图片

//Save To Gallery 的路径
#define TOPSaveToGallery_Path @"TopScan"
/** UUID */
#define  KEY_USERUU_UUID @"com.company.appSimpleScan.FreeUUID"
#define SimplescannerEmail @"simple.scanner@tongsoftinfo.com"
#define TOPFreeSize         (5.0)//手机剩余存储空间的判断临界值 剩余空间小于5m不在写入图片
#define TOPPageSize         @"pageSize"
#define TOPCollagePageSize  @"collagePageSize"
#define TOPPDFSizeConversion (72/2.54)//pdf纸张大小转化为像素的中间量
//固定命名规范
#define TOPRSimpleScanOriginalString @"original_"
#define TOPRSimpleScanNoteString @"note_"
#define TOPRNewDocumentString @"New Document"
#define TOPRNewFolderString NSLocalizedString(@"topscan_newfolderprompt",@"")

//回收站文件夹命名
#define TOPRAppBinString @"TopScanBin"

//首页文件夹命名(沙盒Documents目录下)
#define TOP_TRAppBoxString @"TOPScanBox"
#define TOP_TRDocumentsString @"Documents"
#define TOP_TRPDFString @"PDF"
#define TOP_TRFoldersString @"Folders"
#define TOP_TRTemporaryString @"temporary"
#define TOP_TRCamearPathString @"CamearPath"
#define TOP_TRJPGPathSuffixString @".jpg"
#define TOP_TRTXTPathSuffixString @".txt"
#define TOP_TRPNGPathSuffixString @".png"
#define TOP_TRCropImageFileString @"cropImageFile"
#define TOP_TRCoverImageFileString @"coverImageFile"
#define TOP_TRBatchImageFileString @"batchImageFile"
#define TOP_TRDefaultBatchImageFileString @"DefaultbatchImageFile"
#define TOP_TRBatchCoverImageFileString @"batchCoverImageFile"
#define TOP_TRGaussianBlurImgFile @"GaussianBlurImgFile"
#define TOP_TRSignatureImageFileString @"SignPng"
#define TOP_TRSignationImageName  @"topscan_sign.png"
#define TOP_TRLongImageFileString @"longImageFile"
//#define TRLongImageJPGString @"longImage.jpg"
#define TOP_TRDrawingImageFileString @"drawingImageFile"
#define TOP_TRDrawingImageJPGString @"drawingImage.jpg"
#define TOP_TROCRDrawingImageFileString @"ocrDrawingImageFile"
#define TOP_TRActionExtensionFileString @"actionExtensionFile"
#define TOP_TRTXTPathString @"Txt"
#define TOP_TRCollageImageFileString @"CollageImageFile"
#define TOP_TRWaterMarkImageFileString @"waterMarkImageFile"
#define TOP_TRWaterMarkImageJPGString @"waterMarkImage.jpg"
#define TOP_TRTagsPathString @"Tags"
#define TOP_TRPlistsString @"Plists"
#define TOP_TRDownloadFileJPGPathString @"DownloadJPG"
#define TOP_TRDownloadFilePDFPathString @"DownloadPDF"
#define TOP_TRDownloadFilePDFBreakPathString @"DownloadPDFBreak"

#define TOP_TRDocPasswordPathString @"DocPassword_"
#define TOP_TRTagsAllDocesName NSLocalizedString(@"topscan_tagsalldocs", @"")
#define TOP_TRTagsUngroupedName  NSLocalizedString(@"topscan_tagsungrouped", @"")

#define TOP_TRTagsAllDocesKey @"All Docs"
#define TOP_TRTagsUngroupedKey @"Ungrouped"

#define TOP_TRCropShowImageString @"cropShowImage.jpg"
#define TOP_TRCropOriginalImageString @"cropOriginalImage.jpg"
//#define ExtensionShareNSNotification @"extensionShareNSNotification"

#define TOP_TRNewSignatureKey @"newSignatureKey"
#define TOP_TRWatermarkTextOpacityKey @"watermarkTextOpacity"
#define TOP_TRWatermarkTextFontValueKey @"watermarkTextFontValue"
#define TOP_TRWatermarkTextColorKey @"watermarkTextColor"
#define TOP_TRWatermarkTextkey @"watermartText"
#define TOP_TRSSMaxPiexlKey @"maxPiexlKey"
#define TOP_TROrientationKey @"orientation"
#define TOP_TRGraffitiLabelTextKey @"graffitiLabelText"
#define TOP_TRGraffitiLabelTextColorKey @"graffitiLabelTextColor"
#define TOP_TRAddNewSignatureImageKey @"addNewSignatureImage"
#define TOP_TRSaveSignatureImageKey @"saveSignatureImage"
//#define FirstEnterApp    @"firstEnterApp"
#define TOP_TRPhotoReEditVCNotification @"postNotificationToTOPPhotoReEditVC"
#define TOP_TRCodeReaderReStatr @"CodeReaderReStatr"

#define TOP_TRFileADDCustomExtentedKey @"FileUploadDriveTime"

// 获取本地首页相机默认位置的key值
//#define TRSaveDragViewLoctionString @"saveDragViewLoction"
#define TOP_TRDefaultSignatureColor  @"DefaultSignatureColor"
#define TOP_TRDefaultSignatureLineWitdth  @"DefaultSignatureLineWitdth"
#define TOP_RTDefaultSignatureEraserWitdth  @"DefaultSignatureEraserWitdth"
//#define kDefaultGraffitiPenColor  @"DefaultGraffitiPenColor"
//图片展示页面 屏幕旋转的通知名称
//#define TRVIEWROTAINGFINISH @"viewrotaingfinish"
#define TOPScreenWidth  ([UIScreen mainScreen].bounds.size.width)
#define TOPScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define IS_IPAD   ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].length != 0)
#define kIs_iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define TOP_TRSSWatermarkOpacity (0.3)

//保存JPG图片的比例
#define TOP_TRPicScale (0.6)
#define IPAD_CELLW (IS_IPAD ? 560:TOPScreenWidth)
#define IPAD_FilterW 700.0
//高清图片最大像素
#define TOP_TRSSMaxPiexl  [[NSUserDefaults standardUserDefaults] floatForKey:TOP_TRSSMaxPiexlKey]

////高清图片最大像素
//#define SSMaxLength 1800000.00

/*状态栏高度*/
#define TOPStatusBarHeight \
^(){\
if (@available(iOS 13.0, *)) {\
    UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;\
    return statusBarManager.statusBarFrame.size.height;\
} else {\
    return [UIApplication sharedApplication].statusBarFrame.size.height;\
}\
}()

/*底部安全区域远离高度*/
#define TOPBottomSafeHeight \
^(){\
if (@available(iOS 11.0, *)) {\
   UIEdgeInsets safeAreaInsets = [[UIApplication sharedApplication] delegate].window.safeAreaInsets;\
   return safeAreaInsets.bottom;\
} else {\
   return UIEdgeInsetsMake(0, 0, 0, 0).bottom;\
}\
}()//34 , 0

/*导航栏高度*/
#define TOPNavBarHeight (44.0)
/*状态栏和导航栏总高度*/
#define TOPNavBarAndStatusBarHeight (TOPStatusBarHeight+TOPNavBarHeight)
/*TabBar高度*/
#define TOPTabBarHeight (CGFloat)(kIs_iPhoneX?(49.0 + TOPBottomSafeHeight):(49.0))
/*导航条和Tabbar总高度*/
#define TOPNavAndTabHeight (TOPNavBarAndStatusBarHeight + TOPTabBarHeight)
//#define Mobile_SettingBool(a) [NSString stringWithFormat:@"%@",a]

#define IS_IPAD   ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].length != 0)
//判断设备的软件版本
//#define iPhoneSystemVersion ([UIDevice currentDevice].systemVersion.floatValue)

//#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height-(double)568 ) < DBL_EPSILON)
//#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)
//#define IS_IOS8 ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] >= 8)
//#define IS_IOS7 ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] >= 7)
//#define IS_IOS6 ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] == 6)

// 灰色
#define TOPBackgroundGrayColor [UIColor colorWithRed:241.0 / 255 green:241.0 / 255 blue:241.0 / 255 alpha:1.0]

// 所有按钮的颜色
// 蓝色
//#define kAllBtnBgBlueColor [Common colorWithHexString:@"52cffe"]
//#define kAllBtnBgGrayColor [UIColor colorWithRed:243.0 / 255 green:243.0 / 255 blue:243.0 / 255 alpha:1.0]

// 所有字体颜色
// 灰色
//#define kAllTextGrayColor [UIColor colorWithRed:133.0 / 255 green:138.0 / 255 blue:142.0 / 255 alpha:1.0]
//#define kAllCellSepGrayColor [UIColor colorWithRed:193.0 / 255 green:192.0 / 255 blue:197.0 / 255 alpha:1.0]

#pragma mark 字体(size)规范
//basci
#define PingFang_L_FONT_(s)   [UIFont systemFontOfSize:s weight:UIFontWeightLight] //PingFangSC-Light//细
#define PingFang_R_FONT_(s)   [UIFont systemFontOfSize:s weight:UIFontWeightRegular]  //PingFangSC-Regular//常规
#define PingFang_M_FONT_(s)   [UIFont systemFontOfSize:s weight:UIFontWeightMedium] // //PingFangSC-Medium//中
#define PingFang_S_FONT_(s)   [UIFont systemFontOfSize:s weight:UIFontWeightSemibold]//PingFangSC-Semibold//粗

//主题颜色
//#define TOPAPPGreenColor       RGBA(38, 43, 48, 1.0)
//淡绿色
#define TOPAPPGreenColor         RGBA(36, 196, 164, 1.0)
//主题背景色
#define TOPAppBackgroundColor     RGBA(250, 250, 250, 1.0)
#define TOPAppDarkBackgroundColor RGBA(0, 0, 0, 1.0)//暗黑试图的背景色
#define TOPAPPViewMainDarkColor      RGBA(26, 26, 28, 1.0)//暗黑大部分试图的背景的
#define TOPAPPLineDarkColor          RGBA(40, 40, 40, 1.0)//暗黑TOPAPPViewMainDarkColor对应的分界线颜色
#define TOPAPPViewMostDarkColor      RGBA(40, 40, 40, 1.0)//暗黑小部分弹框的背景的 例如childVC的底部更多弹框的背景色
#define TOPAPPViewSecondDarkColor    RGBA(80, 80, 80, 1.0)//暗黑弹框的子视图的背景色 大部分输入框颜色
#define TOPAPPLineMostDarkColor      RGBA(60, 60, 60, 1.0)//暗黑TOPAPPViewMostDarkColor对应的分界线颜色

#define TITLE_Number(a) [NSString stringWithFormat:@"我们已经将验证码发送至+%@",a]

/**Dubug相关*/

#ifdef DEBUG
#define TYLog(format,...)  NSLog((@"[函数名:%s]\n" "[行号:%d]\n" format),__FUNCTION__,__LINE__,##__VA_ARGS__)
#else
#define TYLog(...)
#endif

#ifdef DEBUG
//#define SLog(format, ...) printf("%p【类名: %s : (%d行)】——【函数名: %s 】\n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )

#define SLog(FORMAT, ...) do {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"HH:mm:ss:SSSS"];\
NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"[%s:%d %s] %s\n", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [dateString UTF8String], [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
}  while (0)
#else
#define SLog(FORMAT, ...) nil
#endif


#define DECLARE_WEAK_SELF __typeof(&*self) __weak weakSelf = self
#define DECLARE_STRONG_SELF __typeof(&*self) __strong strongSelf = weakSelf

//#define AnimationWidth 300.0

//定义设备的类型
//#define iPad      (([UIScreen mainScreen].currentMode.size.height) == 1024?YES:NO)
//#define iPadAir   (([UIScreen mainScreen].currentMode.size.height) == 2048?YES:NO)
//#define iPhone4   (([UIScreen mainScreen].currentMode.size.height) == 960?YES:NO)
//#define iPhone5   (([UIScreen mainScreen].currentMode.size.height) == 1136?YES:NO)
//#define iPhone6   (([UIScreen mainScreen].currentMode.size.height) == 1334?YES:NO)
//#define iPhone6p  (([UIScreen mainScreen].currentMode.size.height) == 2208?YES:NO)
//#define iPhoneX   (([[UIApplication sharedApplication] statusBarFrame].size.height) == 44?YES:NO)

//通知
//中间按钮的通知
#define TOP_TRCenterBtnGetCamera @"TRCenterBtnGetCamera"
#define TOP_TRRemoveScreenhostView @"TRRemoveScreenhostView"
#define SHAREBOARD @"com.tongsoft.Pasteboard" //剪贴板名 名字规范为Bundle id 的前缀com.company 例如:com.company.pasteboardname
/** 是否开启app锁 默认是关闭的*/
#define TOP_TRAppSafeStates @"kISAppSafeStates"
/** 是否开启app锁 默认是关闭的*/
#define TOP_TRAppSafeCurrentPWDKey @"TRAppSafeCurrentPWDKey"
/** app解锁的模式 */
#define TOP_TRAppSafeUnLockType @"TRAppSafeUnLockType"
/** 订阅信息 */
#define  KEY_USERINFO_SUBSCRIPTION @"com.company.appSimpleScan.userInfo"
/** UUID */
#define  KEY_USERUU_UUID @"com.company.appSimpleScan.FreeUUID"

#define  AppType_SimpleScan  @"5"

#define isRTL() ([[[NSLocale preferredLanguages] firstObject] hasPrefix:@"ar"]||[[[NSLocale preferredLanguages] firstObject] hasPrefix:@"he"]||[[[NSLocale preferredLanguages] firstObject] hasPrefix:@"fa"])

#endif
