#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@class TOPAppDocument, TOPAPPFolder, TOPDocNoticeModel;
@interface TOPEditDBDataHandler : NSObject
/// -- 增加文件夹
+ (TOPAPPFolder *)top_addFolderAtFile:(NSString *)path WithParentId:(NSString *)folderId;
/// -- 删除文件夹
+ (void)top_deleteFolderWithId:(NSString *)docId;
/// -- 修改文件夹名称
+ (void)top_editFolderName:(NSString *)name withId:(NSString *)docId;
/// -- 增加文档
/// @param path 文档路径
/// @param folderId  上级目录id   根目录下传"000000"
+ (TOPAppDocument *)top_addDocumentAtFolder:(NSString *)path WithParentId:(NSString *)folderId;
/// -- 重置新建文档的创建和修改时间--保持从回收站还原前后一致
+ (void)top_setDocTime:(NSString *)docId withBinDocId:(NSString *)binDocId;
/// 修改文档路径：移动
/// @param name  新文档名称
/// @param parentId  上级目录id 
/// @param docId  文档id
+ (void)top_editDocumentPath:(NSString *)name withParentId:(NSString *)parentId withId:(NSString *)docId;
/// -- 拷贝文档
+ (TOPAppDocument *)top_copyDocument:(NSString *)docId atFolder:(NSString *)path WithParentId:(NSString *)folderId;
/// -- 删除文档
+ (void)top_deleteDocumentWithId:(NSString *)docId;
/// -- 修改文档名称
+ (void)top_editDocumentName:(NSString *)name withId:(NSString *)docId;
/// -- 修改文档加载耗时
+ (void)top_editDocumentCostTime:(int)costTime withId:(NSString *)docId;
/// -- 修改文档浏览时间
+ (void)top_editDocumentReadingTimeWithId:(NSString *)docId;
/// -- 修改文档收藏状态
+ (void)top_editDocumentCollectionState:(NSInteger)state withId:(NSString *)docId;
///// -- 更新文档图片：排序
//+ (void)updateDocumentImagesWithId:(NSString *)docId;
/// -- 更新文档图片的排序
+ (void)top_updateDocumentImagesSortWithIds:(NSArray *)Ids byDoc:(NSString *)docPath;
/// -- 更新文档标签
+ (void)top_updateDocumentTags:(NSDictionary *)data byDocIds:(NSArray *)docIds;
/// -- 增加图片
+ (void)top_addImageFileAtDocument:(NSArray *)fileNames WithId:(NSString *)docId;
/// -- 增加来自回收站的图片，文档时间不做修改
+ (void)top_addBinImageFileAtDocument:(NSArray *)fileNames WithId:(NSString *)docId;
/// -- 删除图片
+ (void)top_deleteImagesWithIds:(NSArray *)imageIds;
/// -- 更新图片
+ (void)top_updateImageWithId:(NSString *)imageId;
/// -- 批量更新图片
+ (void)top_updateImagesWithIds:(NSArray *)imageIds;
/// -- 更新图片 裁剪、渲染、朝向
+ (void)top_updateImageWithHandler:(NSDictionary *)handler byId:(NSString *)imageId;
/// -- 生成新图片：根据原图片和新图名称
+ (void)top_createImageById:(NSString *)imageId WithName:(NSString *)imageName;
/// -- 更新图片 根据图片名称和上级目录
+ (void)top_updateImageWithName:(NSString *)imageName atDoc:(NSString *)docId;
/// -- 批量修改图片路径：移动 imageNames:移动后会图片名有变化的情况下传值，没有可传空数组
+ (void)top_batchEditImagePathWithId:(NSString *)docId toNewDoc:(NSString *)newDocId withImageNames:(NSArray *)imageNames;
/// -- 批量移动图片 修改parentId、pathId、fileName
+ (void)top_batchMoveImageWithIds:(NSArray *)imageIds withImageNames:(NSArray *)imageNames toNewDoc:(NSString *)newDocId;
/// -- 批量复制图片 修改parentId、pathId、fileName
+ (void)top_batchCopyImageWithIds:(NSArray *)imageIds withImageNames:(NSArray *)imageNames toNewDoc:(NSString *)newDocId;
/// -- 新增标签
+ (void)top_createTags:(NSArray *)tags;
/// -- 删除标签
+ (void)top_deleteTag:(NSString *)tag;
/// -- 更新标签
+ (void)top_updateTag:(NSString *)tag withNewName:(NSString *)name;
/// -- 写入文档提醒的数据
+ (void)top_editDocumentNoticeModel:(TOPDocNoticeModel *)noticeModel;
@end

NS_ASSUME_NONNULL_END
