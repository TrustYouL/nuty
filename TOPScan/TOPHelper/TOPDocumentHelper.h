#import <Foundation/Foundation.h>
#import "TOPEnumHeader.h"

NS_ASSUME_NONNULL_BEGIN



@interface TOPDocumentHelper : NSObject
+ (UIViewController *)top_topViewController;
+ (UIViewController *)top_getPushVC;
+ (void)top_getNetworkState;
+ (void)top_showAlertControllerStyleAlertTitle:(NSString *)title message:(NSString *)message;
//创建文件夹
+(void)top_initializationFolder;
//在系统相册中创建指定文件夹
+(void)top_creatGalleryFolder:(NSString *)folderName;
//将图片写入指定系统相册的文件夹中
+(void)top_saveImagePathArray:(NSArray *)imagePathArray toFolder:(NSString *)folderName tipShow:(BOOL)isShow showAlter:(void (^)(BOOL isExisted))success;
//图片旋转,只改变图片旋转属性，并没有生产新图片
+ (UIImage *)top_image:(UIImage *)image rotation:(UIImageOrientation)orientation;
//生成pdf图片
+(NSString*)top_creatPDF:(NSArray *)imgArray documentName:(NSString *)name;
//生成pdf带进度条的
+ (NSString*)top_creatPDF:(NSArray *)imgArray documentName:(nonnull NSString *)name progress:(nonnull void (^)(CGFloat myProgress))progress;
//生成pdf
+ (void)top_creatPDF:(NSArray *)imgArray documentName:(nonnull NSString *)name pageSizeType:(NSInteger)sizeType success:(void (^)(id responseObj))success;
//不加密的PDF
+ (NSString*)top_creatNOPasswordPDF:(NSArray *)imgArray documentName:(nonnull NSString *)name progress:(nonnull void (^)(CGFloat myProgress))progress;
+ (CGRect)top_getPdfsizeWithType:(NSInteger)type;
#pragma mark --根据长宽生成相应pdf尺寸 width height是纸张大小 单位是cm
+ (CGRect)top_getPdfSizeWithWidth:(CGFloat)width WithHeight:(CGFloat)height;
//压缩图片质量
+ (NSData *)top_compressImageQuality:(UIImage *)image toByte:(NSInteger)maxLength;
+ (NSString *)top_saveCompressImage:(NSString *)imgPath maxCompression:(CGFloat)compression;
+ (NSString *)top_saveCompressImage:(NSString *)imgPath savePath:(NSString *)savePath maxCompression:(CGFloat)compression;
+ (NSString *)top_saveCompressPDFImage:(NSString *)imgPath maxCompression:(CGFloat)compression;
+ (NSString *)top_saveCompressPDFImage:(NSString *)imgPath savePath:(NSString *)savePath maxCompression:(CGFloat)compression;
+ (NSString *)top_saveResizeImage:(NSString *)imgPath maxCompression:(CGFloat)compression;
+ (BOOL)top_saveImage:(UIImage*)photoImage atPath:(NSString *)path;
+(NSData*)top_saveImageForData:(UIImage*)photoImage;
+ (void)top_saveCropShowImage:(UIImage *)photoImage;
/// 保存剪裁应用的源图片
+ (void)top_saveCropOriginalImage:(UIImage *)photoImage;
/// 剪裁展示用的图片
+ (UIImage *)top_cropShowImage;
/// 剪裁应用的源图片
+ (UIImage *)top_cropOriginalImage;
///压缩到指定大小
+(UIImage *)top_scaleToSize:(UIImage *)img size:(CGSize)size;
///只遍历document下的路径
+(NSMutableArray*)top_getCurrentDocumentFileAndPath;
///只遍历某个文件夹下的路径
+(NSMutableArray*)top_getCurrentFileAndPath:(NSString*)str;
///获取某个目录下所有带有.jpg格式的文件 深遍历
+ (NSArray*)top_getAllJPEGFileForDeep:(NSString*)filePath;
///获取某个文件下所有带有.jpg格式的文件
+ (NSArray*)top_getJPEGFile:(NSString*)filePath;
///获取某个文件下所有带有.png格式的文件
+ (NSArray*)top_getPNGFile:(NSString*)filePath;
/// 获取文件夹下所有文件 排序
+ (NSArray *)top_sortItemAthPath:(NSString *)path;
/// 获取文档下的所有图片 根据数字下标排序--升序
+ (NSArray *)top_sortPicsAtPath:(NSString *)path;
/// 获取文档下的所有图片 根据图片完整名称排序--升序
+ (NSArray *)top_sortPicArryBuyName:(NSString *)path;
/// -- 获取图片的数字序号排序用
+ (NSString *)top_picSortNO:(NSString *)path;
///获取文件创建时间(字符串)
+ (NSString*)top_getCreateTimeString:(NSString*)path;
+ (NSString*)top_getModifyTimeString:(NSString*)path;
///用户操作所创建的文件目录
+ (NSString*)top_appBoxDirectory;
///属于app supports路径追加
+ (NSString*)top_getBelongDocumentPathString:(NSString*)str;
/// temporary 路径追加
+ (NSString*)top_getBelongTemporaryPathString:(NSString*)str;
/// 创建一个新的临时目录
+ (void)top_createTemporaryFile;
///数据库目录 (沙盒Documnets下的)完整路径
+ (NSString *)top_getDBPathString;
///Folders (沙盒Documnets下的)完整路径
+ (NSString *)top_getFoldersPathString;
///Documents (沙盒Documnets下的)完整路径
+ (NSString *)top_getDocumentsPathString;
///CamearPath (沙盒Documnets下的)完整路径
+ (NSString *)top_getCamearPathPathString;
///PDF (沙盒Documnets下的)完整路径
+ (NSString *)top_getPDFPathString;
/// 存放签名图的文件目录
+ (NSString *)top_getSignaturePathString;
/// 存放剪裁图片的临时目录
+ (NSString *)top_getCropImageFileString;
///存放批量处理图片时展示图的目录
+ (NSString *)top_getBatchImageFileString;
+ (NSString *)top_getDefaultBatchImageFileString;
///存放批量处理图片时缩略图的目录
+ (NSString *)top_getBatchCoverImageFileString;
/// 存放缩率图的临时目录
+ (NSString *)top_getCoverImageFileString;
+ (NSString *)top_getTxtPathString;
///temporary下 网盘下载存放jpg的临时目录
+ (NSString *)top_getDriveDownloadJPGPathPathString;
///temporary下 网盘下载存放待拆分PDF的临时目录
+ (NSString *)top_getDriveDownloadPDFPathPathString;
///temporary下 网盘下载存放待拆分PDF拆分的临时目录
+ (NSString *)top_getDrivePDFBreakPathPathString ;
///存放批量处理图片时展示图的路径
+ (NSString *)top_batchImageFile:(NSString *)fileName;
///存放批量处理图片时模版图的路径
+ (NSString *)top_defaultBatchImageFile:(NSString *)fileName;
///存放批量处理图片时缩略图的路径
+ (NSString *)top_batchCoverImageFile:(NSString *)fileName;
/// 存放缩率图路径
+ (NSString *)top_coverImageFile:(NSString *)fileName;
///高斯模糊图片
+ (NSString *)top_gaussianBlurImgFileString:(NSString *)fileName;
/// long image
+ (NSString *)top_longImageFileString;
/// copy Image
+ (NSString *)top_copyImageFileString;
/// 文字水印
+ (NSString *)top_waterMarkTextImagePath;
/// 拼图临时文件
+ (NSString *)top_collageImageFileString;
+ (NSString *)top_collageImagePath:(NSString *)fileName;
/// 正在渲染处理的图片
+ (NSString *)top_drawingImageFileString;
+ (NSString *)top_drawingOCRImageFileString;
/// action 扩展临时文件
+ (NSString *)top_actionExtensionFileString;
/// 获取document文件夹下Tags文件夹的路径
///@param documentPath  document文件夹的路径
+ (NSString *)top_getTagsPathString:(NSString *)documentPath;
/// 获取document文件夹下密码文件夹的路径
///@param documentPath  document文件夹的路径
+ (NSString *)top_getDocPasswordPathString:(NSString *)documentPath;
/// -- 删除文档密码
+ (void)top_removeDocPassword:(NSString *)docPath;
/// -- 删除文件夹内所有的文档密码
+ (void)top_removePasswordOfFolder:(NSString *)folderPath;
//计算单个文件占用内存大小
+ (NSString*)top_getFileMemorySize:(NSString*)path;
//计算多个文件占用内存大小
+ (NSString*)top_getFileTotalMemorySize:(NSArray *)array;
/// 根据固定格式返回文件大小字符串：100K 、 5M
/// @param totalSize 文件大小浮点型
+ (NSString *)top_memorySizeStr:(CGFloat)totalSize;
/// 计算多个文件占用内存大小 返回计算值浮点型
/// @param array 文件路径
+ (CGFloat)top_totalMemorySize:(NSArray *)array;
//根据图片名获取到源文件
+ (NSString*)top_getSourceFilePath:(NSString*)path fileName:(NSString*)fileName;
/// 源txt路径
/// @param imgPath 图片路径
+ (NSString *)top_originalNote:(NSString *)imgPath;
/// 源ocr路径
/// @param imgPath 图片路径
+ (NSString *)top_originalOcr:(NSString *)imgPath;
///创建文件夹
+(NSString*)top_createFolders:(NSString*)path;
+ (NSString *)top_createTempFileAtPath:(NSString *)path;
///获取当前系统的时间
+(NSString*)top_getCurrentTime;
///获取系统时间 不同的格式
+(NSString*)top_getCurrentTimeAndSendFormatterString:(NSString *)formatterString;
///将当前系统的时间去空格 -
+(NSString*)top_getFormatCurrentTime;
///设置默认document名称 对时间格式解析
+ (NSString *)top_getCurrentFormatterTime:(NSString *)formatterString;
+ (NSDate *)top_getAroundDateFromDate:(NSDate *)date month:(int)month;
+(NSString*)top_getFileNameNumber:(NSInteger)index;
+ (NSString*)top_nameNewFileIndex:(NSArray*)indexArray;
///获取字符串中的数字
+ (NSString *)top_getNumberFromStr:(NSString *)str;

#pragma mark -  数组排序
///按照文件名称排序 A-Z
+(NSMutableArray*)top_sortByNameAZ:(NSArray*)dataArray;
+(NSMutableArray*)top_sortByNameZA:(NSArray*)dataArray;
///修改时间排序
+(NSMutableArray*)top_sortByTimeNewToOld:(NSArray*)dataArray path:(NSString*)pathString;
+(NSMutableArray*)top_sortByTimeOldToNew:(NSArray*)dataArray path:(NSString*)pathString;
///创建时间排序
+(NSMutableArray*)top_sortByCreateTimeNewToOld:(NSArray*)dataArray path:(NSString*)pathString;
+(NSMutableArray*)top_sortByCreateTimeOldToNew:(NSArray*)dataArray path:(NSString*)pathString;
///根据数组获取排名第一个的元素路径
+(NSString*)top_getFirstPathString:(NSArray*)documentArray;
///递归读取解压路径下的所有归属Documents的文件夹
+ (NSMutableArray *)top_showAllFileWithPath:(NSString *) path documentArray:(NSMutableArray*)documentArray;
///获取沙盒Documents下所有的文件夹 -- folder
+ (NSMutableArray *)top_getAllFoldersWithPath:(NSString *) path documentArray:(NSMutableArray*)documentArray;
///获取沙盒Documents目录下的所有文档(Document-存放图片的文件夹)
+ (NSMutableArray *)top_getAllDocumentsWithPath:(NSString *) path documentArray:(NSMutableArray*)documentArray;
///根据首页的排序规则返回文件目录
+ (NSArray *)top_sortContentOfDirectoryAtPath:(NSString *)path;
///获取当前目录下的文件夹 -- 浅遍历 只看次级目录
+ (NSMutableArray *)top_getNextFoldersWithPath:(NSString *)path;
///获取当前文件夹下的文档 -- 浅遍历 只看次级目录
+ (NSMutableArray *)top_getCurrnetDocumentsWithPath:(NSString *)path;
///-- 移动文件下所有图片
+ (void)top_moveFileItemsAtPath:(NSString *)path toNewFileAtPath:(NSString *)newPath;
+ (void)top_moveFileItemsAtPath:(NSString *)path toNewFileAtPath:(NSString *)newPath progress:(void (^)(CGFloat moveProgressValue))moveProgressBlock;
///-- 复制文件目录
+ (void)top_copyDirectoryAtPath:(NSString *)path toNewDirectoryPath:(NSString *)newPath;
///-- 复制文件下的所有图片
+ (void)top_copyFileItemsAtPath:(NSString *)path toNewFileAtPath:(NSString *)newPath;
+ (void)top_copyFileItemsAtPath:(NSString *)path toNewFileAtPath:(NSString *)newPath progress:(void (^)(CGFloat copyProgressValue))copyProgressBlock;
///-- 文件内的所有图片生成新图片并保存到（合并后的）新文件夹下    (旧文档的所有图片移到新文档下)
+ (void)top_writeNewPic:(NSString *)originalPath toNewFileAtPath:(NSString *)path delete:(BOOL)isDelete;
+ (NSMutableArray *)top_writeNewPic:(NSString *)originalPath toNewFileAtPath:(NSString *)path delete:(BOOL)isDelete  progress:(void (^)(CGFloat copyProgressValue))copyProgressBlock;
///-- 将单个图片写入目标文件下
+ (void)top_writeImage:(NSString *)imgPath toTargetFile:(NSString *)path delete:(BOOL)isDelete;
///-- 将单个图片根据指定名称下标写入目标文件下
+ (NSString *)top_writeImage:(NSString *)imgPath atIndex:(NSInteger)indexStart toTargetFile:(NSString *)path delete:(BOOL)isDelete;
///当前文档中所有图片的最大下标
+ (NSInteger)top_maxImageNumIndexAtPath:(NSString *)path;
/// 图片源文件路径
+ (NSString *)top_originalImage:(NSString *)imgPath;
/// -- 备份图片文件路径
+ (NSString *)top_backupImage:(NSString *)imgPath;
/// -- 判断文件是否为封面图片
+ (BOOL)top_isCoverJPG:(NSString *)fileName;
/// -- 获取文件中的所有图片路径(过滤了原始图片等)--不做排序
+ (NSMutableArray *)top_showPicArrayAtPath:(NSString *)path;
/// -- 排序,根据图片的后几位数字去排序
+ (NSArray *)top_sortedPicArray:(NSArray *)imageNames;
/// -- 过滤掉原始图片
+ (NSMutableArray *)top_coverPicArrayAtPath:(NSString *)path;
/// 在当前目录下获取新文件夹默认名称
/// @param path 当前目录
+ (NSString *)top_newDefaultFolderNameAtPath:(NSString *)path;
/// 在当前目录下获取新文档默认名称
/// @param path 当前目录
+ (NSString *)top_newDefaultDocumentNameAtPath:(NSString *)path;
/// -- 使用默认文件名在指定目录下创建Doc
+ (NSString *)top_createDefaultDocumentAtFolderPath:(NSString *)folderPath;
/// -- 在指定目录下创建Documents
+ (NSString *)top_createNewDocument:(NSString *)docName atFolderPath:(NSString *)folderPath;
/// -- 创建文件
+ (NSString *)top_createDirectoryAtPath:(NSString *)path;
/// -- 新文件名 有重名的加数字标签:(1)、(2)
+ (NSString *)top_newDocumentFileName:(NSString *)path;
/// -- 新文件的时间属性沿用老文件的
+ (BOOL)top_setFileTimeAttribute:(NSString *)oldPath atNewPath:(NSString *)fldPath;
/// -- 设置文件路径
+ (NSString *)top_buildDirectoryAtPath:(NSString *)path;
#pragma mark -- 字符串的宽高
///固定宽度和字体大小，获取label的frame
+ (CGSize)top_getSizeWithStr:(NSString *) str Width:(float)width Font:(float)fontSize;
///固定高度和字体大小，获取label的frame
+ (CGSize)top_getSizeWithStr:(NSString *) str Height:(float)height Font:(float)fontSize;
#pragma mark - 判断输入内容是不是邮箱
+ (BOOL) top_validateEmail: (NSString *) candidate;
///改变文件夹名字
+ (NSString *)top_changeDocumentName:(NSString *)path folderText:(NSString *)folderText;
+ (NSString *)top_changeFileName:(NSString *)path folderText:(nonnull NSString *)folderText;
///更改以前版本的数据结构用到
+ (void)top_changeBeforeFolder:(NSString *)beforeFolder toChangeFolder:(NSString *)changeFolder;
///传真
+ (void)top_jumpToSimpleFax:(NSString *)pdfPathing;
/// -- 计算所有文件大小(无选中状态判断)
+ (long)top_calculateAllFilesSize:(NSArray *)fileArr;
/// -- 计算所选文件大小(有选中状态判断)
+ (long)top_calculateSelectFilesSize:(NSArray *)fileArr;
/// -- 计算所选图片大小(有选中状态判断)
+ (long)top_calculateSelectImagesSize:(NSArray *)imgArr;
///选中文件夹里的所有图片集合
+ (NSMutableArray *)top_getSelectFolderPicture:(NSArray *)sendArray;
///docunment里所选图片的集合
+ (NSArray *)top_getSelectPicture:(NSArray *)sendArray;
///txt文档路径imgName不带.jpg后缀
+ (NSString *)top_getTxtPath:(NSString *)filePath imgName:(NSString *)imgName txtType:(NSString *)type;
///txt文档路径imgName带.jpg后缀
+ (NSString *)top_getTxtPath:(NSString *)filePath imgPriName:(NSString *)imgName txtType:(NSString *)type;
///根据txt路径获取里面的内容
+ (NSString *)top_getTxtContent:(NSString *)txtPath;
///所有语言数据
+ (NSArray *)top_getAllLanguageData;
///第三方语言数据
+ (NSArray *)top_getThirdLanguageData;
///google语言数据
+ (NSArray *)top_getGoogleLanguageData;
///支持的google本地语言
+ (NSArray *)top_getGoogleLocationLanguageData;
///ipad不做旋转的VC集合
+ (NSArray *)top_getSCVCClassData;
//根据语言获取对应的节点
+ (NSString *)top_getEndPoint:(NSDictionary *)language;
//节点数据
+ (NSArray *)top_getEndpointData;
//获取引擎
+ (NSInteger)top_getOCREngine:(NSString *)language;
+ (NSString *)top_getTimeAfterNowWithDay:(int)day;
+ (NSString *)top_getCurrentSecondTimeInterval;
+ (NSString *)top_getCurrentTimeInterval;
+ (void)top_getUIImageFromPDFPageWithpdfpathUrl:(CGPDFDocumentRef)fromPDFDoc password:(NSString *)passwordStr docPath:(NSString *)path progress:(void (^)(CGFloat progressString))progress success:(void (^)(id responseObj))success;
+ (void)top_getCloudUIImageFromPDFPageWithpdfpathUrl:(CGPDFDocumentRef)fromPDFDoc password:(NSString *)passwordStr docPath:(nonnull NSString *)path homeChildPath:(NSString *)childPath progress:(nonnull void (^)(CGFloat progressString))progress success:(nonnull void (^)(id _Nonnull))success;
+ (UIImage *)top_imageAtRect:(UIImage *)originImg imageRect:(CGRect)imgRect;
+ (NSString *)top_createTagsPath:(NSString *)documentPath;
+ (NSString *)top_getFolderShowName:(NSString *)path;
+ (BOOL)top_createTagsBottomPathTagsPath:(NSString *)tagsPath withCreatePath:(NSString *)pathName;
/// -- 新建文档并添加标签：在当前选中标签分组下创建文档
+ (void)top_createDocumentAddTags:(NSString *)docPath;
+ (BOOL)top_creatDocPasswordWithPath:(NSString *)docPath withPassword:(NSString *)password;
///判断设置默认密码
+ (void)top_defaultPassword;
#pragma mark -- 获取选中的数组中有密码的数据
+ (NSMutableArray *)top_getSelectLockState:(NSMutableArray *)homeDataArray;
#pragma mark -- 高斯模糊
+ (UIImage *)top_blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;
#pragma mark -- 当该文件夹是新创建的需要添加标签 只要是新创建的文件夹都会走这个方法 例如doc的合并 拍照裁剪后生成文件夹流程
+ (void)top_creatNewDocTags:(NSString *)docPath;
#pragma mark -- 复制文件下过滤临时文件的所有图片(同步云盘方法使用)
+ (void)top_copyFileItemsFilterAtPath:(NSString *)path toNewFileAtPath:(NSString *)newPath;
#pragma mark -- 判断文件是否为图片
+ (BOOL)top_isValidateJPG:(NSString *)fileName;
/// -- 检测当前目录下是否有图片
+ (BOOL)top_directoryHasJPG:(NSString *)path;
+ (NSString *)top_getEnish2ForMatterWith:(NSDate *)date;
+ (float)top_freeDiskSpaceInBytes;
+ (void)top_addLocalNotificationWithTitle:(NSString *)title subTitle:(NSString *)subTitle body:(NSString *)body timeInterval:(long)timeInterval identifier:(NSString *)identifier userInfo:(NSDictionary *)userInfo repeats:(int)repeats;
+ (void)top_removeNotificationWithIdentifierID:(NSString *)noticeId;
+ (void)top_removeAllNotification;
#pragma mark -- 获取设备是否支持Touchid 和Faceid
+ (TOPLAContextSupportType)top_getBiometryType;
#pragma mark -- 创建一个临时解压文件路径
+ (NSString *)top_tempUnzipPath;
#pragma mark- 获取一个网盘上传的字符串时间名称格式(MM-dd-yyyy HH-mm)
+ (NSString *)top_getCurrentYYYYDateForMatter;
+ (CGFloat)top_distanceBetweenPoints:(CGPoint)point1 :(CGPoint)point2;
/**特殊字符数组*/
+ (NSArray *)top_specialStringArray;
+ (BOOL)top_achiveStringWithWeb:(NSString *)infor;
+ (BOOL)top_getInterfaceOrientationState;
+  (void)top_subscriptEndTimeRenewedDay:(double)intervalData SuccessBlock:(void (^)(BOOL resultStates,NSString *_Nonnull amazonDateStr))resultBlock;
+ (void)top_getInternetDateBlock:(void (^)(NSString * nowInternetDate))selectBlock;
+ (NSString *)top_decodeFromPercentEscapeString:(NSString *)input;
/// -- 广告植入的索引
+ (NSInteger)top_adMobIndexWithListType:(NSInteger)listType byItemCount:(NSInteger)count;
+ (BOOL)top_getSelectFolderDocPicState:(NSArray *)sendArray;
+ (NSArray *)top_interstitialAdID;
+ (NSArray *)top_bannerAdID;
+ (NSArray *)top_AppOpenAdID;
+ (NSArray *)top_nativeAdID;
+ (BOOL)top_extended2WithPath:(NSString *)path key:(NSString *)key value:(NSString *)attribute;
+ (id)top_extended2WithPath:(NSString *)path key:(NSString *)key;
#pragma mark -- 插页广告的出现概率为1/12
+ (int)top_interstitialAdRandomNumber;
+ (BOOL)top_isdark;
+ (UIStatusBarStyle)top_barStyle;
/// -- 文件创建时间
+ (NSDate *)top_createTimeOfFile:(NSString *)path;
/// -- 文件修改时间
+ (NSDate *)top_updateTimeOfFile:(NSString *)path;
+ (UIViewController *)top_appRootViewController;
+ (void)top_appReopenedNetworkState:(void(^)(BOOL isReopened))completion;
@end

NS_ASSUME_NONNULL_END
