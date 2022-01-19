#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPBinFolder, TOPBinDocument, TOPBinImage;
@interface TOPBinQueryHandler : NSObject
+ (TOPBinFolder *)top_appFolderById:(NSString *)Id;
+ (RLMResults<TOPBinFolder *> *)top_allFoldersBySorted;
+ (RLMResults<TOPBinFolder *> *)top_foldersByParentId:(NSString *)parentId;
+ (RLMResults<TOPBinFolder *> *)top_foldersAtFile:(NSString *)folderId;
+ (TOPBinDocument *)top_appDocumentById:(NSString *)Id;
+ (RLMResults<TOPBinDocument *> *)top_allDocumentsBySorted;
+ (RLMResults<TOPBinDocument *> *)top_documentsByParentId:(NSString *)parentId;
+ (RLMResults<TOPBinDocument *> *)top_documentsAtFoler:(NSString *)folderId;
+ (TOPBinImage *)top_imageFileById:(NSString *)Id;
+ (RLMResults<TOPBinImage *> *)top_imageFilesByParentId:(NSString *)parentId;
+ (NSArray *)top_sortImageFilesByParentId:(NSString *)parentId;
+ (RLMResults<TOPBinImage *> *)top_imageFilesWithImageIds:(NSArray *)imgIds;
@end

NS_ASSUME_NONNULL_END
