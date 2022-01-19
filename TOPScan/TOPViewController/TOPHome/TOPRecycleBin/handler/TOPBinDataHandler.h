#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPBinDataHandler : NSObject
+ (void)top_checkExpiredFile;
+ (NSMutableArray *)top_buildBinHomeDataWithDB;
+ (NSMutableArray *)top_buildBinFolderDataWithDB:(TOPBinFolder *)fldModel;
+ (NSMutableArray *)top_buildBinDocumentDataWithDB:(TOPBinDocument *)docModel;
+ (TOPBinFolder *)top_buildBinFolderWithParentId:(NSString *)parentId atPath:(NSString *)docPath;
+ (TOPBinDocument *)top_buildFullBinDocWithParentId:(NSString *)parentId atPath:(NSString *)path;
+ (BOOL)top_needCreateBinDocument:(NSString *)docId;
+ (BOOL)top_needNewDocument:(NSString *)docId;
+ (NSMutableArray *)top_buildRealmImagesByFileNames:(NSArray *)fileNames withData:(TOPBinDocument *)appDoc;
+ (NSMutableArray *)top_buildRealmImagesWithData:(TOPBinDocument *)appDoc;
+ (NSString *)top_binFolderPath:(NSString *)pathId;
+ (NSString *)top_binDocumentPath:(NSString *)pathId;
+ (NSString *)top_restoreFolderPath:(NSString *)docId;
+ (NSString *)top_restoreDocumentPath:(NSString *)docId;
+ (NSString *)top_restoreImageParentPath:(NSString *)docId;
+ (NSString *)top_restoreImageParentId:(NSString *)docId;
+ (NSString *)top_documentParentId:(NSString *)docId;
+ (NSString *)top_imageParentId:(NSString *)docId;
+ (DocumentModel *)top_restoreNewDocModel:(NSString *)endPath withDelParentId:(NSString *)delParentId;
+ (long)top_sumAllBinFileSize;
+ (long)top_sumBinImagesFileSize:(NSArray *)imgIds;
+ (long)top_sumBinDocumentsFileSize:(NSArray *)docIds;
+ (long)top_sumBinFoldersFileSize:(NSArray *)folderIds;

@end

NS_ASSUME_NONNULL_END
