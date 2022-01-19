#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPAppDocument, TOPAPPFolder, TOPDocTag;
@interface TOPDBDataHandler : NSObject

/// -- 注意：第一次升级到有数据库的版本才需要写入 检测数据库是否有数据，有的话不需要写入，否则需要写入
+(BOOL)top_hasDBData;
/// -- 写入数据
+ (void)top_loadingRealmDBData;
/// -- 某个文件夹的数据同步 自检
+ (void)top_synchronizeDBDataWithFolder:(NSString *)folderId progress:(void (^_Nullable)(CGFloat value))progressBlock;
/// -- 数据同步 自检
+ (void)top_synchronizeRealmDBDataProgress:(void (^_Nullable)(CGFloat value))progressBlock;
///清空数据库  需要重新写入数据的时候调用
+ (void)top_emptyDBData;
/// -- 恢复备份数据
+ (void)top_restoreFileData:(NSArray *)data;

///从数据库获取 标签统计数据
+ (NSMutableArray *)top_buildTagListWithDB;
/// -- 从数据库获取 最后一个浏览文档数据
+ (DocumentModel *)top_buildLastDocDataWithDB;
///从数据库获取 最近浏览文档数据
+ (NSMutableArray *)top_buildRecentDocDataWithDB;
///从数据库获取 首页数据
+ (NSMutableArray *)top_buildHomeDataWithDB;
///从数据库获取Folder次级界面数据
+ (NSMutableArray *)top_buildFolderSecondaryDataWithDB:(TOPAPPFolder *)fldModel;
///从数据库获取 文档详情数据
+ (NSMutableArray *)top_buildDocumentDataWithDB:(TOPAppDocument *)docModel;
/// -- 从数据库获取所有标签数据
+ (NSMutableArray *)top_buildAllTagsDataWithDB;
///带标签的文档数据模型
+ (NSMutableArray *)top_buildTagDocModleDataWithDB:(RLMResults<TOPAppDocument *> *)docModels;
/// -- 构造数据库Folder模型
+ (TOPAPPFolder *)top_buildRealmFolderWithParentId:(NSString *)parentId atPath:(NSString *)docPath;
/// -- 构造数据库Doc模型 包含了标签和图片数据
+ (TOPAppDocument *)top_buildFullDocumetnWithParentId:(NSString *)parentId atPath:(NSString *)docPath;
/// -- 构造数据库Doc模型
+ (TOPAppDocument *)top_buildRealmDocumentWithParentId:(NSString *)parentId atPath:(NSString *)docPath;
/// -- 构造数据库Image模型
+ (NSMutableArray *)top_buildRealmImagesWithData:(TOPAppDocument *)appDoc;
/// -- 根据图片名称构造数据库Image模型
+ (NSMutableArray *)top_buildRealmImagesByFileNames:(NSArray *)fileNames withData:(TOPAppDocument *)appDoc;
/// -- 构造数据库Tag模型
+ (TOPDocTag *)top_buildRealmTagWithName:(NSString *)tagName;
+ (NSMutableArray *)top_buildRealmTagsWithData:(TOPAppDocument *)appDoc;
/// -- 文件夹 根据pathId获取完整路径
+ (NSString *)top_folderPath:(NSString *)pathId;
/// -- 文档 根据pathId获取完整路径
+ (NSString *)top_documentPath:(NSString *)pathId;

/// -- 收集所有的文件数据
+ (NSMutableDictionary *)top_fileDataAll;

/// -- 新增Document模型
+ (DocumentModel *)top_addNewDocModel:(NSString *)endPath;
/// -- 构造文件夹Folder模型
+ (DocumentModel *)top_buildFolderModelWithData:(TOPAPPFolder *)appFld;
/// -- 构造文档Doc模型
+ (DocumentModel *)top_buildDocumentModelWithData:(TOPAppDocument *)appDoc;
/// -- 构造Image数据模型
+ (DocumentModel *)top_buildImageModelWithData:(TOPImageFile *)imgFile;

///-- 统计标签 数据库数据写入
+ (void)top_createDocTag;

/// -- 图片 计算文件大小
+ (long)top_sumImagesFileSize:(NSArray *)imgIds;
///文档 计算文件大小
+ (long)top_sumDocumentsFileSize:(NSArray *)docIds;
///文件夹 计算文件大小
+ (long)top_sumFoldersFileSize:(NSArray *)folderIds;
+ (NSDate *)top_createTimeOfFile:(NSString *)path;
+ (NSDate *)top_updateTimeOfFile:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
