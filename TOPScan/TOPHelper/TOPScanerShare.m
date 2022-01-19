#import "TOPScanerShare.h"

@implementation TOPScanerShare
static TOPScanerShare *instance = nil;


+(instancetype)shared{
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TOPScanerShare alloc] init];
    });
    return instance;
}

+ (BOOL)top_appLockState {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"appLockStateKey"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"appLockStateKey"];
    } else {
        return NO;
    }
}

+ (void)top_writeAppLockState:(BOOL)state {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:state forKey:@"appLockStateKey"];
    [def synchronize];
}

//
+ (NSInteger)top_listType{
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"ListCode"]) {
          return [[NSUserDefaults standardUserDefaults] integerForKey:@"ListCode"];
      }else{
          return 0;
      }
    
}

+ (void)top_writeListType:(NSInteger)type{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:type forKey:@"ListCode"];
    [def synchronize];
}

//
+ (NSInteger)top_sortType{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"SortCode"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"SortCode"];
    }else{
        return 0;
    }
}

+ (void)top_writSortType:(NSInteger)sort{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:sort forKey:@"SortCode"];
    [def synchronize];
}
//tags管理界面的tags文件夹排列顺序
+ (NSInteger)top_sortTagsType{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"sortTagsType"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"sortTagsType"];
    }else{
        return 0;
    }
}
+ (void)top_writSortTagsType:(NSInteger)sort{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:sort forKey:@"sortTagsType"];
    [def synchronize];
}

//pdf文档大小
+ (NSInteger)top_pageSizeType{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"pageSizeCode"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"pageSizeCode"];
    }else{
        return 0;
    }
}

+ (void)top_writePageSizeType:(NSInteger)sort{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:sort forKey:@"pageSizeCode"];
    [def synchronize];
}

//渲染模式
+ (NSInteger)top_defaultProcessType{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"defaultProcessCode"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"defaultProcessCode"];
    }else{
        return 0;
    }
}

+ (void)top_writeDefaultProcessType:(NSInteger)sort{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:sort forKey:@"defaultProcessCode"];
    [def synchronize];
}

//
+ (NSInteger)top_lastFilterType{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"lastFilterCode"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"lastFilterCode"];
    }else{
        return 0;
    }
}

+ (void)top_writeLastFilterType:(NSInteger)sort{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:sort forKey:@"lastFilterCode"];
    [def synchronize];
}

//homechildvc界面图片的排列顺序
+ (NSInteger)top_childViewByType{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"childViewByType"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"childViewByType"];
    }else{
        return 0;
    }
}

+ (void)top_writeChildViewByType:(NSInteger)sort{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:sort forKey:@"childViewByType"];
    [def synchronize];
}

//图片详情是否显示
+ (NSInteger)top_childHideDetailType{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"childHideDetailType"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"childHideDetailType"];
    }else{
        return 0;
    }
}

+ (void)top_writeChildHideDetailType:(NSInteger)sort{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:sort forKey:@"childHideDetailType"];
    [def synchronize];
}

//folder文件夹的位置 在底部或者在顶部
+ (NSInteger)top_homeFolderTopOrBottom{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"homeFolderTopOrBottom"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"homeFolderTopOrBottom"];
    }else{
        return 0;
    }
}

+ (void)top_writeHomeFolderTopOrBottom:(NSInteger)sort{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:sort forKey:@"homeFolderTopOrBottom"];
    [def synchronize];
}
//记录进入app的次数
+ (NSInteger)top_theCountEnterApp{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"theCountEnterApp"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"theCountEnterApp"];
    }else{
        return 0;
    }
}
+ (void)top_writeEnterAppCount:(NSInteger)count{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:count forKey:@"theCountEnterApp"];
    [def synchronize];
}

//记录进入suggestionView弹出次数
+ (NSInteger)top_theCountSuggestionView{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"theCountSuggestionView"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"theCountSuggestionView"];
    }else{
        return 0;
    }
}
+ (void)top_writeSuggestionViewCount:(NSInteger)count{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:count forKey:@"theCountSuggestionView"];
    [def synchronize];
}

//是否保存到Gallery文件夹
+ (NSInteger)top_saveToGallery{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveToGallery"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveToGallery"];
    }else{
        return 0;
    }
}
+ (void)top_writeSaveToGallery:(NSInteger)gallery{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:gallery forKey:@"saveToGallery"];
    [def synchronize];
}

//是否保存原图
+ (NSInteger)top_saveOriginalImage{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveOriginalImage"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveOriginalImage"];
    }else{
        return 0;
    }
}
+ (void)top_writeSaveOriginalImage:(NSInteger)original{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:original forKey:@"saveOriginalImage"];
    [def synchronize];
}

//
+ (NSArray *)top_saveDragViewLoction{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"saveDragViewLoction"]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"saveDragViewLoction"];
    }else{
        return nil;
    }
}

+ (void)top_writeDragViewLoction:(NSArray *)location{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:location forKey:@"saveDragViewLoction"];
    [def synchronize];
}

//
+ (NSDictionary *)top_saveOcrLanguage{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"saveOcrLanguage"]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"saveOcrLanguage"];
    }else{
        return nil;
    }
}
+ (void)top_writeSaveOcrLanguage:(NSDictionary *)language{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:language forKey:@"saveOcrLanguage"];
    [def synchronize];
}

//
+ (NSDictionary *)top_saveOcrEndpoint{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"saveOcrEndpoint"]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"saveOcrEndpoint"];
    }else{
        return nil;
    }
}
+ (void)top_writeSaveOcrEndpoint:(NSDictionary *)endpoint{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:endpoint forKey:@"saveOcrEndpoint"];
    [def synchronize];
}


+ (BOOL)top_googleConnection {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"SaveGoogleConnection"];
}
+ (void)top_writeSaveGoogleConnection:(BOOL)state {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:state forKey:@"SaveGoogleConnection"];
    [def synchronize];
}

/**
接口有没有加载完成
 */
+ (NSString *)top_saveWlanFinish{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"saveWlanFinish"]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"saveWlanFinish"];
    }else{
        return nil;
    }
}
+ (void)top_writeSaveWlanFinish:(NSString *)finsh{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:finsh forKey:@"saveWlanFinish"];
    [def synchronize];
}

//网络状态
+ (NSInteger)top_saveNetworkState{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveNetworkState"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveNetworkState"];
    }else{
        return 0;
    }
}

+ (void)top_writeSaveNetworkState:(NSInteger)satate{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:satate forKey:@"saveNetworkState"];
    [def synchronize];
}
//
+ (NSString*)top_saveThreeDataLater{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"saveThreeDataLater"]){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"saveThreeDataLater"];
    }else{
        return nil;
    }
}

+ (void)top_writeSaveThreeDataLater:(NSString *)time{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:time forKey:@"saveThreeDataLater"];
    [def synchronize];
}

+ (NSString*)top_saveOneDataLater{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"saveOneDataLater"]){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"saveOneDataLater"];
    }else{
        return nil;
    }
}

+ (void)top_writeSaveOneDataLater:(NSString *)time{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:time forKey:@"saveOneDataLater"];
    [def synchronize];
}

//
+ (BOOL)top_savesScoreBox{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"savesScoreBox"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"savesScoreBox"];
    }else{
        return NO;
    }
}
+ (void)top_writeSaveScoreBox:(BOOL)isShow{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:isShow forKey:@"savesScoreBox"];
    [def synchronize];
}

//
+ (NSInteger)top_saveScoreBoxNumber{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveScoreBoxNumber"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveScoreBoxNumber"];
    }else{
        return 0;
    }
}
+ (void)top_writeSaveScoreBoxNumber:(NSInteger)number{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:number forKey:@"saveScoreBoxNumber"];
    [def synchronize];
}

/**
 记录ipad的进入次数
 */
+ (NSInteger)top_saveIpadEnterNumber{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveIpadEnterNumber"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveIpadEnterNumber"];
    }else{
        return 0;
    }
}
+ (void)top_writeSaveIpadEnterNumber:(NSInteger)number{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:number forKey:@"saveIpadEnterNumber"];
    [def synchronize];
}
/**
 记录iphone进入的次数
 */
+ (NSInteger)top_saveIphoneEnterNumber{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveIphoneEnterNumber"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveIphoneEnterNumber"];
    }else{
        return 0;
    }
}
+ (void)top_writeSaveIphoneEnterNumber:(NSInteger)number{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:number forKey:@"saveIphoneEnterNumber"];
    [def synchronize];
}
/**
 记录是否点击了5星的按钮
 */
+ (BOOL)top_saveClickFiveStar{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"saveClickFiveStar"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"saveClickFiveStar"];
    }else{
        return NO;
    }
}
+ (void)top_writeSaveClickFiveStar:(BOOL)click{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:click forKey:@"saveClickFiveStar"];
    [def synchronize];
}
/**
 记录点击notnow按钮的次数
 */
+ (NSInteger)top_saveClickNotnowBtn{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveClickNotnowBtn"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveClickNotnowBtn"];
    }else{
        return 0;
    }
}
+ (void)top_writeSaveClickNotnowBtn:(NSInteger)number{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:number forKey:@"saveClickNotnowBtn"];
    [def synchronize];
}

+ (NSInteger)top_saveClickRateApp{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveClickRateApp"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveClickRateApp"];
    }else{
        return 0;
    }
}

+ (void)top_writeSaveClickRateApp:(NSInteger)number{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:number forKey:@"saveClickRateApp"];
    [def synchronize];
}

+ (NSString *)top_saveTagsName{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"saveTagsName"]){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"saveTagsName"];
    }else{
        return nil;
    }
}

+ (void)top_writeSaveTagsName:(NSString *)tagName{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:tagName forKey:@"saveTagsName"];
    [def synchronize];
}
+ (NSInteger)top_userDefinedFileSize {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"userDefinedFileSize"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"userDefinedFileSize"];
    }else{
        return 0;
    }
}

+ (void)top_writeUserDefinedFileSizePercent:(NSInteger)val {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:val forKey:@"userDefinedFileSize"];
    [def synchronize];
}

+ (BOOL)top_firstOpenStates {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstOpenStatesSave"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"firstOpenStatesSave"];
    }else{
        return 0;
    }
}
+ (void)top_writeFirstOpenStatesSave:(BOOL)firstOpen {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:firstOpen forKey:@"firstOpenStatesSave"];
    [def setBool:YES forKey:@"Backup-Wi-Fionly"];
    [def setBool:NO forKey:@"isSaveOriginalImage"];

    [def synchronize];
}
+ (BOOL)top_singleFileUserDefinedFileSizeState {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"userDefinedFileSizeState"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"userDefinedFileSizeState"];
    }else{
        return NO;
    }
}

+ (void)top_writeUserDefinedFileSizeState:(BOOL)state {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:state forKey:@"userDefinedFileSizeState"];
    [def synchronize];
}

+ (NSInteger)top_collagePageSizeValue {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"collagePageSizeKey"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"collagePageSizeKey"];
    }else{
        return 0;
    }
}

+ (void)top_writeCollagePageSizeValue:(NSInteger)val {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:val forKey:@"collagePageSizeKey"];
    [def synchronize];
}

+ (NSInteger)top_pdfNumberType {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"pdfNumberKey"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"pdfNumberKey"];
    }else{
        return 0;
    }
}

+ (void)top_writeSavePDFNumberType:(NSInteger)type {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:type forKey:@"pdfNumberKey"];
    [def synchronize];
}

+ (NSInteger)top_pdfDirection {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"pdfDirectionKey"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"pdfDirectionKey"];
    }else{
        return 0;
    }
}

+ (void)top_writeSavePDFDirection:(NSInteger)type {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:type forKey:@"pdfDirectionKey"];
    [def synchronize];
}

+ (NSString *)top_docPassword{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"docPassword"]){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"docPassword"];
    }else{
        return nil;
    }
}

+ (void)top_writeDocPasswordSave:(NSString *)firstOpen{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:firstOpen forKey:@"docPassword"];
    [def synchronize];
}

+ (NSString *)top_pdfPassword {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"pdfPasswordKey"]){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"pdfPasswordKey"];
    }else{
        return nil;
    }
}

+ (void)top_writePDFPassword:(NSString *)word {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:word forKey:@"pdfPasswordKey"];
    [def synchronize];
}

+ (BOOL)top_firstManualSorting{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstManualSorting"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"firstManualSorting"];
    }else{
        return NO;
    }
}

+ (void)top_writefirstManualSorting:(BOOL)firstOpen{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:firstOpen forKey:@"firstManualSorting"];
    [def synchronize];
}

+ (NSDictionary *)top_codeLanguageMap {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"codeLanguageMapKey"]){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"codeLanguageMapKey"];
    }else{
        return nil;
    }
}

+ (void)top_writeCodeLanguageMapSave:(NSDictionary *)map {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:map forKey:@"codeLanguageMapKey"];
    [def synchronize];
}


+ (NSArray *)top_recentLanguageModels {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"recentLanguageKey"]){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"recentLanguageKey"];
    }else{
        return nil;
    }
}

+ (void)top_writeLanguageModelsSave:(NSArray *)Models {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:Models forKey:@"recentLanguageKey"];
    [def synchronize];
}

+ (NSString *)top_sourceLanguage {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"sourceLanguageKey"]){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"sourceLanguageKey"];
    }else{
        return nil;
    }
}

+ (void)top_writeSourceLanguageSave:(NSString *)languageCode {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:languageCode forKey:@"sourceLanguageKey"];
    [def synchronize];
}

+ (NSString *)top_targetLanguage {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"targetLanguageKey"]){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"targetLanguageKey"];
    }else{
        return nil;
    }
}

+ (void)top_writeTargetLanguageSave:(NSString *)languageCode {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:languageCode forKey:@"targetLanguageKey"];
    [def synchronize];
}

//是否保存原图
+ (NSInteger)top_saveBatchImage{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveBatchImage"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveBatchImage"];
    }else{
        return 0;
    }
}
+ (void)top_writeSaveBatchImage:(NSInteger)original{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:original forKey:@"saveBatchImage"];
    [def synchronize];
}

+ (NSURL *)top_isShareExtension{
    if ([[NSUserDefaults standardUserDefaults] URLForKey:@"isShareExtension"]) {
        return [[NSUserDefaults standardUserDefaults] URLForKey:@"isShareExtension"];
    }else{
        return nil;
    }
}

+ (void)top_writeIsShareExtension:(NSURL *)isURL{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    [def setObject:isURL forKey:@"isShareExtension"];
    [def setURL:isURL forKey:@"isShareExtension"];
    [def synchronize];
}

+ (BOOL)top_cameraRemindHadShow{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cameraRemindHadShow"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"cameraRemindHadShow"];
    }else{
        return NO;
    }
}
+ (void)top_writeCameraRemindHadShow:(BOOL)firstOpen{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:firstOpen forKey:@"cameraRemindHadShow"];
    [def synchronize];
}

+ (BOOL)top_cameraOCRTip {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cameraOCRTipShowKey"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"cameraOCRTipShowKey"];
    }else{
        return NO;
    }
}
    
+ (void)top_writeCameraOCRTip:(BOOL)isShow {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:isShow forKey:@"cameraOCRTipShowKey"];
    [def synchronize];
}

+ (NSInteger)top_cameraOCRTipCount {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"cameraOCRTipCountKey"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"cameraOCRTipCountKey"];
    }else{
        return 0;
    }
}

+ (void)top_writeCameraOCRTipCount:(NSInteger)count {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:count forKey:@"cameraOCRTipCountKey"];
    [def synchronize];
}

+ (BOOL)top_cameraIDCardTip {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cameraIDCardTipShowKey"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"cameraIDCardTipShowKey"];
    }else{
        return NO;
    }
}

+ (void)top_writeCameraIDCardTip:(BOOL)isShow {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:isShow forKey:@"cameraIDCardTipShowKey"];
    [def synchronize];
}


+ (NSInteger)top_cameraIDCardTipCount {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"cameraIDCardTipCountKey"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"cameraIDCardTipCountKey"];
    }else{
        return 0;
    }
}

+ (void)top_writeCameraIDCardTipCount:(NSInteger)count {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:count forKey:@"cameraIDCardTipCountKey"];
    [def synchronize];
}

+ (NSInteger)top_cameraTakeMode {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"takeModeKey"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"takeModeKey"];
    }else{
        return 0;
    }
}

+ (void)top_writeCameraTakeMode:(NSInteger)mode {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:mode forKey:@"takeModeKey"];
    [def synchronize];
}

+ (NSInteger)top_cameraFlashType{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"cameraFlashType"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"cameraFlashType"];
    }else{
        return 0;
    }
}

+ (void)top_writeCameraFlashType:(NSInteger)type{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:type forKey:@"cameraFlashType"];
    [def synchronize];
}

+ (BOOL)top_pdfPageAdjustmentBottomViewShow{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"pdfPageAdjustmentBottomViewShow"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"pdfPageAdjustmentBottomViewShow"];
    }else{
        return NO;
    }
}

+ (void)top_writepdfPageAdjustmentBottomViewShow:(BOOL)show{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:show forKey:@"pdfPageAdjustmentBottomViewShow"];
    [def synchronize];
}
/**
文档时间格式类型
 */
+ (NSString *)top_documentDateType{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"documentDateType"]){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"documentDateType"];
    }else{
        return nil;
    }
}
+ (void)top_writeDocumentDateType:(NSString *)dateType{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:dateType forKey:@"documentDateType"];
    [def synchronize];
}

/**
  判断手机中的iCloud功能是否开启
 @return 判断手机中的iCloud功能是否开启
*/
+ (BOOL)top_getCurrentiCloudStates
{
    BOOL states = NO;
    //判断手机中的iCloud功能是否开启
    id cloudUrl = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    if (cloudUrl == nil) {
    NSLog(@"iCloud没有开启");
        states = NO;
    } else {
    NSLog(@"iCloud开启");
        states = YES;
    }
    return states;
}

/**
 是否显示免费试用购买提示弹框
 */
+ (BOOL)top_showSubscriptAlertViewStates
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SubscriptAlertViewShowStates"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"SubscriptAlertViewShowStates"];
    }else{
        return NO;
    }
}
+ (void)top_writeShowSubscriptStates:(BOOL)open
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:open forKey:@"SubscriptAlertViewShowStates"];
    [def synchronize];
}

/**
 显示免费试用购买提示弹框的进入次数
 */
+ (NSInteger)top_subscriptBecomeNum
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"subscriptBecomeNum"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"subscriptBecomeNum"];
    }else{
        return 0;
    }
}
+ (void)top_writeSubscriptBecomeNum:(NSInteger)num
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:num forKey:@"subscriptBecomeNum"];
    [def synchronize];
}


/**
 显示免费试用购买提示弹框的次数 最大8次
 */
+ (NSInteger)top_showSubscriptViewNum
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"showSubscriptViewNum"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"showSubscriptViewNum"];
    }else{
        return 0;
    }
}

+ (void)top_writeshowSubscriptViewNum:(NSInteger)num
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:num forKey:@"showSubscriptViewNum"];
    [def synchronize];
}

+ (BOOL)top_onlyOldUserShow{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"onlyOldUserShow"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"onlyOldUserShow"];
    }else{
        return NO;
    }
}

+ (void)top_writeOldUserShow:(BOOL)state{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:state forKey:@"onlyOldUserShow"];
    [def synchronize];
}

+ (NSString *)top_saveUserSuggestion {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"saveUserSuggestion"]){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"saveUserSuggestion"];
    }else{
        return nil;
    }
}

+ (void)top_writeUserSuggestion:(NSString *)suggestion {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:suggestion forKey:@"saveUserSuggestion"];
    [def synchronize];
}
/**
 app从有广告的版本开始记录从后题进入前台的次数 这个次数是用来判定开屏广告的显示 当进入次数是3的倍数时才显示开屏广告
 */
+ (NSInteger)top_saveAppOpenAdCount
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveAppOpenAdCount"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveAppOpenAdCount"];
    }else{
        return 0;
    }
}

+ (void)top_writeSaveAppOpenAdCount:(NSInteger)num
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:num forKey:@"saveAppOpenAdCount"];
    [def synchronize];
}
/**
 app从有广告的版本开始记录进入app的次数 这个次数是用来判定首页插页广告的显示 当进入app次数是3的倍数时首页插页广告才显示
 */
+ (NSInteger)top_saveInterstitialAdCount
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveInterstitialAdCount"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveInterstitialAdCount"];
    }else{
        return 0;
    }
}

+ (void)top_writeSaveInterstitialAdCount:(NSInteger)num
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:num forKey:@"saveInterstitialAdCount"];
    [def synchronize];
}

+ (BOOL)top_updateOldUserDocTime{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"updateOldUserDocTime"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"updateOldUserDocTime"];
    }else{
        return NO;
    }
}
+ (void)top_writeUpdateOldUserDocTime:(BOOL)state{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:state forKey:@"updateOldUserDocTime"];
    [def synchronize];
}

+ (UIUserInterfaceStyle)top_darkModel API_AVAILABLE(ios(12.0)){
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"darkModel"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"darkModel"];
    }else{
        return UIUserInterfaceStyleUnspecified;
    }
}
+ (void)top_writeDarkModelStyle:(UIUserInterfaceStyle)state API_AVAILABLE(ios(12.0)){
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:state forKey:@"darkModel"];
    [def synchronize];
}
+ (BOOL)top_screenshotEventState{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"screenshotEventState"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"screenshotEventState"];
    }else{
        return NO;
    }
}
+ (void)top_writeScreenshotEventState:(BOOL)state{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:state forKey:@"screenshotEventState"];
    [def synchronize];
}

#pragma mark -- 删除提醒
+ (BOOL)top_deleteFileAlert {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"deleteFileAlertSwitch"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"deleteFileAlertSwitch"];
    } else {
        return NO;
    }
}

+ (void)top_writeDeleteFileAlert:(BOOL)state {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:state forKey:@"deleteFileAlertSwitch"];
    [def synchronize];
}

#pragma mark -- 回收站保存时间 -- 单位：天
+ (NSInteger)top_saveBinFileTime {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveBinFileTimeKey"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveBinFileTimeKey"];
    } else {
        return 30;
    }
}

+ (void)top_writeSaveBinFileTime:(NSInteger)time {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:time forKey:@"saveBinFileTimeKey"];
    [def synchronize];
}
#pragma mark -- 删除提醒
+ (BOOL)top_saveFolderMergeState {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"saveFolderMergeState"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"saveFolderMergeState"];
    } else {
        return NO;
    }
}

+ (void)top_writeSaveFolderMergeState:(BOOL)state {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:state forKey:@"saveFolderMergeState"];
    [def synchronize];
}

#pragma mark -- 评论弹框的弹出判定
+ (BOOL)top_saveNewScoreState {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"saveNewScoreState"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"saveNewScoreState"];
    } else {
        return NO;
    }
}

+ (void)top_writeSaveNewScoreState:(BOOL)state {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:state forKey:@"saveNewScoreState"];
}
#pragma mark  -- childVC列表样式
+ (NSInteger)top_saveChildVCListType{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"saveChildVCListType"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveChildVCListType"];
    } else {
        return 0;
    }
}
+ (void)top_writeSaveChildVCListType:(NSInteger)type{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:type forKey:@"saveChildVCListType"];
    [def synchronize];
}

/**
 进入购买订阅界面次数
 */
+ (NSInteger)top_theCountSubscribtionVC {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"CountSubscribtionkey"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"CountSubscribtionkey"];
    } else {
        return 0;
    }
}

+ (void)top_writeSubscribtionVCCount:(NSInteger)count {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:count forKey:@"CountSubscribtionkey"];
    [def synchronize];
}

/**
 点击购买订阅次数
 */
+ (NSInteger)top_theCountClickPurchased {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"CountPurchasedkey"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"CountPurchasedkey"];
    } else {
        return 0;
    }
}

+ (void)top_writeClickPurchasedCount:(NSInteger)count {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:count forKey:@"CountPurchasedkey"];
    [def synchronize];
}

/**
 购买订阅次数
 */
+ (NSInteger)top_purchaseSubscriptionsCount {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"buySubscriptionsKey"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"buySubscriptionsKey"];
    } else {
        return 0;
    }
}

+ (void)top_writePurchasedSubscriptionsCount:(NSInteger)count {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:count forKey:@"buySubscriptionsKey"];
    [def synchronize];
}

@end 


