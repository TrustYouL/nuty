#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPScanerShare : NSObject
@property (nonatomic,assign) BOOL isPush;//是否是在TOPPhotoReEditFinishVC界面进入相机的
@property (nonatomic,assign) BOOL isEditing;
@property (nonatomic,assign) BOOL isManualSorting;
@property (nonatomic,assign) BOOL isReceive;//1.接收pdf img时 接收并写入文件夹完毕才能在首页刷新数据 不能一边写图片一边刷新
@property (nonatomic,assign) BOOL isRefresh;//1.跨控制器之间 需要刷新数据的判定
@property (nonatomic,assign) BOOL isFirstShow;//1.从后台进入前台密码弹出视图获取指纹识别弹出视图 是否是第一次出现  出现过就不再弹出
+ (instancetype)shared;
+ (BOOL)top_appLockState;  //应用解锁状态
+ (void)top_writeAppLockState:(BOOL)state; //记录解锁状态

+ (NSInteger)top_listType;  //首页数据展示类型,如果更改就要记住
+ (void)top_writeListType:(NSInteger)type; //记录下展示类型

+ (NSInteger)top_sortType;//首页文件夹排列顺序
+ (void)top_writSortType:(NSInteger)sort;

+ (NSInteger)top_sortTagsType;//tags管理界面的tags文件夹排列顺序
+ (void)top_writSortTagsType:(NSInteger)sort;

+ (NSInteger)top_pageSizeType;
+ (void)top_writePageSizeType:(NSInteger)sort;//pdf文档大小设置

+ (NSInteger)top_defaultProcessType;
+ (void)top_writeDefaultProcessType:(NSInteger)sort;//渲染模式默认设置

+ (NSInteger)top_lastFilterType;
+ (void)top_writeLastFilterType:(NSInteger)sort;//渲染模式默认设置

+ (NSInteger)top_childViewByType;
+ (void)top_writeChildViewByType:(NSInteger)sort;//homechildvc界面图片的排列顺序

+ (NSInteger)top_childHideDetailType;
+ (void)top_writeChildHideDetailType:(NSInteger)sort;//图片详情是否显示

+ (NSInteger)top_homeFolderTopOrBottom;
+ (void)top_writeHomeFolderTopOrBottom:(NSInteger)sort;//folder文件夹的位置 在底部或者在顶部

+ (NSInteger)top_theCountEnterApp;
+ (void)top_writeEnterAppCount:(NSInteger)count;//记录进入app的次数

+ (NSInteger)top_saveToGallery;
+ (void)top_writeSaveToGallery:(NSInteger)gallery;//是否保存到Gallery文件夹

+ (NSInteger)top_saveOriginalImage;
+ (void)top_writeSaveOriginalImage:(NSInteger)original;//是否保存原图

+ (NSInteger)top_userDefinedFileSize;
+ (void)top_writeUserDefinedFileSizePercent:(NSInteger)val;//自定义文件大小百分比值

+ (BOOL)top_singleFileUserDefinedFileSizeState;
+ (void)top_writeUserDefinedFileSizeState:(BOOL)state;//单张图片自定义文件大小百分比开关

+ (NSInteger)top_collagePageSizeValue;
+ (void)top_writeCollagePageSizeValue:(NSInteger)val;//拼图纸张大小

+ (NSInteger)top_pdfNumberType;
+ (void)top_writeSavePDFNumberType:(NSInteger)type;//PDF页码

+ (NSInteger)top_pdfDirection;
+ (void)top_writeSavePDFDirection:(NSInteger)type;//纸张朝向

+ (NSString *)top_pdfPassword;
+ (void)top_writePDFPassword:(NSString *)word;//PDF密码

/**
 首页相机的默认位置
 */
+ (NSArray *)top_saveDragViewLoction;
+ (void)top_writeDragViewLoction:(NSArray *)location;//是否保存原图
/**
 ocr语言的默认值
 */
+ (NSDictionary *)top_saveOcrLanguage;
+ (void)top_writeSaveOcrLanguage:(NSDictionary *)language;//是否保存语言
/**
 ocr节点默认值
 */
+ (NSDictionary *)top_saveOcrEndpoint;
+ (void)top_writeSaveOcrEndpoint:(NSDictionary *)endpoint;//是否保存节点

/**
 google连接状态 可以连接的话加入谷歌识别的节点和语言
 */
+ (BOOL)top_googleConnection;
+ (void)top_writeSaveGoogleConnection:(BOOL)state;//是否保存节点

/**
接口有没有加载完成
 */
+ (NSString *)top_saveWlanFinish;
+ (void)top_writeSaveWlanFinish:(NSString *)finsh;//是否保存节点

/**
 网络状态
 */
+ (NSInteger)top_saveNetworkState;
+ (void)top_writeSaveNetworkState:(NSInteger)satate;

/**
 保存当前时间为起始时间 3天后的时间的时间戳
 */
+ (NSString*)top_saveThreeDataLater;
+ (void)top_writeSaveThreeDataLater:(NSString *)time;

/**
 保存当前时间为起始时间 1天后的时间的时间戳
 */
+ (NSString*)top_saveOneDataLater;
+ (void)top_writeSaveOneDataLater:(NSString *)time;
/**
 评分弹框有没有弹出过
 */
+ (BOOL)top_savesScoreBox;
+ (void)top_writeSaveScoreBox:(BOOL)isShow;
/**
 记录进入应用的次数 这个次数是评分的时候用到
 */
+ (NSInteger)top_saveScoreBoxNumber;
+ (void)top_writeSaveScoreBoxNumber:(NSInteger)number;
/**
 记录ipad的进入次数
 */
+ (NSInteger)top_saveIpadEnterNumber;
+ (void)top_writeSaveIpadEnterNumber:(NSInteger)number;
/**
 记录iphone进入的次数
 */
+ (NSInteger)top_saveIphoneEnterNumber;
+ (void)top_writeSaveIphoneEnterNumber:(NSInteger)number;
/**
 记录是否点击了5星的按钮
 */
+ (BOOL)top_saveClickFiveStar;
+ (void)top_writeSaveClickFiveStar:(BOOL)click;
/**
 记录点击notnow按钮的次数
 */
+ (NSInteger)top_saveClickNotnowBtn;
+ (void)top_writeSaveClickNotnowBtn:(NSInteger)number;
/**
 记录点击设置界面给app评分的按钮的次数  点击2次之后评分按钮消失
 */
+ (NSInteger)top_saveClickRateApp;
+ (void)top_writeSaveClickRateApp:(NSInteger)number;
/**
 记录标签列表中点击的标签名称
 */
+ (NSString *)top_saveTagsName;
+ (void)top_writeSaveTagsName:(NSString *)tagName;

/**
app是否第一次进入
 */
+ (BOOL)top_firstOpenStates;
+ (void)top_writeFirstOpenStatesSave:(BOOL)firstOpen;
/**
doc文档的密码
 */
+ (NSString *)top_docPassword;
+ (void)top_writeDocPasswordSave:(NSString *)firstOpen;

/**
 childVC更多功能中的Mannual sorting功能是不是首次点击
 */
+ (BOOL)top_firstManualSorting;
+ (void)top_writefirstManualSorting:(BOOL)firstOpen;

/**
 supported languages BCP-47 Code --> language
 */
+ (NSDictionary *)top_codeLanguageMap;
+ (void)top_writeCodeLanguageMapSave:(NSDictionary *)map;

/**
 最近使用的语言模型
 */
+ (NSArray *)top_recentLanguageModels;
+ (void)top_writeLanguageModelsSave:(NSArray *)Models;

/**
上次使用的源语言
 */
+ (NSString *)top_sourceLanguage;
+ (void)top_writeSourceLanguageSave:(NSString *)languageCode;

/**
上次使用的目标语言
 */
+ (NSString *)top_targetLanguage;
+ (void)top_writeTargetLanguageSave:(NSString *)languageCode;

/**
 拍照批量处理时 是否做裁剪
 */
+ (NSInteger)top_saveBatchImage;
+ (void)top_writeSaveBatchImage:(NSInteger)original;

/**
 childVC更多功能中的Mannual sorting功能是不是首次点击
 */
+ (NSURL *)top_isShareExtension;
+ (void)top_writeIsShareExtension:(NSURL *)isURL;

/**
 拍照的新手指导界面 只出现一次
 */
+ (BOOL)top_cameraRemindHadShow;
+ (void)top_writeCameraRemindHadShow:(BOOL)firstOpen;

/**
 OCR拍照下次是否提示
 */
+ (BOOL)top_cameraOCRTip;
+ (void)top_writeCameraOCRTip:(BOOL)isShow;
/**
 OCR拍照提示次数
 */
+ (NSInteger)top_cameraOCRTipCount;
+ (void)top_writeCameraOCRTipCount:(NSInteger)count;

/**
 IDCard拍照下次是否提示
 */
+ (BOOL)top_cameraIDCardTip;
+ (void)top_writeCameraIDCardTip:(BOOL)isShow;

/**
 IDCard拍照提示次数
 */
+ (NSInteger)top_cameraIDCardTipCount;
+ (void)top_writeCameraIDCardTipCount:(NSInteger)count;

/**
 记录上次的拍照模式 只记录单拍和多拍
 */
+ (NSInteger)top_cameraTakeMode;
+ (void)top_writeCameraTakeMode:(NSInteger)mode;
/**
 记录上次闪光灯选中的模式
 */
+ (NSInteger)top_cameraFlashType;
+ (void)top_writeCameraFlashType:(NSInteger)type;
/**
 工具箱中PDF Page Adjustment功能 调入ChildVC界面时 对应的底部视图是否弹出的判定
 */
+ (BOOL)top_pdfPageAdjustmentBottomViewShow;
+ (void)top_writepdfPageAdjustmentBottomViewShow:(BOOL)show;

/**
文档时间格式类型
 */
+ (NSString *)top_documentDateType;
+ (void)top_writeDocumentDateType:(NSString *)dateType;

/**
  判断手机中的iCloud功能是否开启
 @return 判断手机中的iCloud功能是否开启
*/
+ (BOOL)top_getCurrentiCloudStates;


/**
 是否显示免费试用购买提示弹框
 */
+ (BOOL)top_showSubscriptAlertViewStates;
+ (void)top_writeShowSubscriptStates:(BOOL)open;

/**
 显示免费试用购买提示弹框的次数 最大8次
 */
+ (NSInteger)top_showSubscriptViewNum;
+ (void)top_writeshowSubscriptViewNum:(NSInteger)num;

/**
 显示免费试用购买提示弹框的进入次数
 */
+ (NSInteger)top_subscriptBecomeNum;
+ (void)top_writeSubscriptBecomeNum:(NSInteger)num;
/**
 SuggestionView弹出的次数
 */
+ (NSInteger)top_theCountSuggestionView;
+ (void)top_writeSuggestionViewCount:(NSInteger)count;

/**
 控制2.3.0以前的用户 意见反馈界面只弹出一次
 */
+ (BOOL)top_onlyOldUserShow;
+ (void)top_writeOldUserShow:(BOOL)state;
/**
 记录用户反馈的内容 如果提交成功了 记录的内容就清空
 */
+ (NSString *)top_saveUserSuggestion;
+ (void)top_writeUserSuggestion:(NSString *)suggestion;

/**
 app从有广告的版本开始记录从后题进入前台的次数 这个次数是用来判定开屏广告的显示 当进入次数是3的倍数时才显示开屏广告
 */
+ (NSInteger)top_saveAppOpenAdCount;
+ (void)top_writeSaveAppOpenAdCount:(NSInteger)count;
/**
 app从有广告的版本开始记录进入app的次数 这个次数是用来判定首页插页广告的显示 当进入app次数是3的倍数时首页插页广告才显示
 */
+ (NSInteger)top_saveInterstitialAdCount;
+ (void)top_writeSaveInterstitialAdCount:(NSInteger)count;
/**
 2.4.7以前(包括2.4.7)的老用户文档时间排序是有问题的 显示的按创建时间排序实际是修改时间排序 这个属性是更正老用户文档时间排序用到的
 */
+ (BOOL)top_updateOldUserDocTime;
+ (void)top_writeUpdateOldUserDocTime:(BOOL)state;
/**
 记录暗黑模式类型
 */
+ (UIUserInterfaceStyle)top_darkModel API_AVAILABLE(ios(12.0));
+ (void)top_writeDarkModelStyle:(UIUserInterfaceStyle)state API_AVAILABLE(ios(12.0));
/**
 截图时响应事件的开关 默认是打开的
 */
+ (BOOL)top_screenshotEventState;
+ (void)top_writeScreenshotEventState:(BOOL)state;

/// -- 删除提醒开关 默认打开
+ (BOOL)top_deleteFileAlert;
+ (void)top_writeDeleteFileAlert:(BOOL)state;

/// -- 回收站保存时间 -- 单位：天
+ (NSInteger)top_saveBinFileTime;
+ (void)top_writeSaveBinFileTime:(NSInteger)time;

/// -- folder文件夹列表收起显示的状态
+ (BOOL)top_saveFolderMergeState;
+ (void)top_writeSaveFolderMergeState:(BOOL)state;

/// -- 从pdf预览界面返回之后弹出评论弹框的判定 只弹出一次
+ (BOOL)top_saveNewScoreState;
+ (void)top_writeSaveNewScoreState:(BOOL)state;
/// -- childVC列表样式
+ (NSInteger)top_saveChildVCListType;
+ (void)top_writeSaveChildVCListType:(NSInteger)type;

/**
 进入购买订阅界面次数
 */
+ (NSInteger)top_theCountSubscribtionVC;
+ (void)top_writeSubscribtionVCCount:(NSInteger)count;

/**
 点击购买订阅次数
 */
+ (NSInteger)top_theCountClickPurchased;
+ (void)top_writeClickPurchasedCount:(NSInteger)count;

/**
 购买订阅次数
 */
+ (NSInteger)top_purchaseSubscriptionsCount;
+ (void)top_writePurchasedSubscriptionsCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
