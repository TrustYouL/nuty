
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPAPPFolder, TOPAppDocument, TOPImageFile, TOPDocTag;
@interface TOPDBQueryService : NSObject

///  -- 总文件个数
+ (long)top_totalFilesCount;
/// -- 某个文件夹下的总文件个数
+ (long)top_totalFilesCountAtFolder:(NSString *)folderId;
/// TOPAPPFolder 查询
/// @param Id  TOPAPPFolder主键
+ (TOPAPPFolder *)top_appFolderById:(NSString *)Id;
/// 查询所有的文件夹 默认排序
+ (RLMResults<TOPAPPFolder *> *)top_allFoldersBySorted;
/// -- 查询所有的文件夹 根据目录排序
+ (NSMutableArray *)top_allFoldersByDirectorySorted;
/// -- 查询所有的文件夹 根据第一级目录排序：用于复制、移动的文件夹数据
+ (NSMutableArray *)top_allFoldersByFatherDirectorySorted;
/// -- 根据父id(文件夹上级目录id)查询folders 默认排序
+ (RLMResults<TOPAPPFolder *> *)top_foldersByParentId:(NSString *)parentId;
/// -- 查询首页的文件夹 默认排序
+ (RLMResults<TOPAPPFolder *> *)top_homeFoldersBySorted;
/// -- 查询某个文件夹下的所有folder 可用于计数
+ (RLMResults<TOPAPPFolder *> *)top_foldersAtFile:(NSString *)folderId;
+ (RLMResults<TOPAppDocument *> *)top_allDocumentsAtFoler;
/// TOPAppDocument 查询
/// @param Id  TOPAppDocument主键
+ (TOPAppDocument *)top_appDocumentById:(NSString *)Id;
/// -- 查询所有的文档 默认排序
+ (RLMResults<TOPAppDocument *> *)top_allDocumentsBySorted;
///-- 查询所有的文档 制定排序类型进行排序
+ (RLMResults<TOPAppDocument *> *)top_allDocumentsBySortedWithSortType:(NSInteger)sortType;
/// -- 查询所有的文档 最近浏览时间排序
+ (RLMResults<TOPAppDocument *> *)top_allDocumentsByRecent;
/// -- 根据父id(文档上级目录id)查询documents 默认排序
+ (RLMResults<TOPAppDocument *> *)top_documentsByParentId:(NSString *)parentId;
/// -- 根据图片名称和父id(图片上级目录id)查询images
+ (RLMResults<TOPImageFile *> *)top_imageFilesByParentId:(NSString *)parentId withName:(NSString *)name;
/// -- 计数某个目录下的所有图片个数
+ (RLMResults<TOPImageFile *> *)top_imagesAtPath:(NSString *)pathId;
/// -- 查询首页的文档 默认排序
+ (RLMResults<TOPAppDocument *> *)top_homeDocumentsBySorted;
/// -- 查询没有标签的文档 默认排序
+ (RLMResults<TOPAppDocument *> *)top_unGroupedDocumentsBySorted;
/// -- 查询被收藏的文档 默认排序
+ (RLMResults<TOPAppDocument *> *)top_documentsByCollecting;
/// 查询带标签的文档 默认排序
/// @param tagName  标签名称
+ (RLMResults<TOPAppDocument *> *)top_documentsBySortedWithTag:(NSString *)tagName;
/// -- 查询某个文件夹下的所有文档 可用于计数
+ (RLMResults<TOPAppDocument *> *)top_documentsAtFoler:(NSString *)folderId;
/// -- TOPAppDocument 根据路径查询 **仅限首页文档**
+ (TOPAppDocument *)top_appDocumentByPath:(NSString *)path;
/// TOPImageFile 查询
/// @param Id  TOPImageFile主键
+ (TOPImageFile *)top_imageFileById:(NSString *)Id;
/// -- 根据父id(图片上级目录id)查询images
+ (RLMResults<TOPImageFile *> *)top_imageFilesByParentId:(NSString *)parentId;
/// -- 根据父id(图片上级目录id)查询images 并排序
+ (NSArray *)top_sortImageFilesByParentId:(NSString *)parentId;
/// -- 根据ids查询images
+ (RLMResults<TOPImageFile *> *)top_imageFilesWithImageIds:(NSArray *)imgIds;
+ (NSMutableArray *)top_imageFilesOrderByImageIds:(NSArray *)imgIds;
/// -- DocTag 查询
+ (TOPDocTag *)top_docTagById:(NSString *)Id;
/// --  查询所有TOPDocTag
+ (RLMResults<TOPDocTag *> *)top_allTagsBySorted;
///  TOPDocTag 根据标签名称查询
+ (TOPDocTag *)top_docTagByName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
