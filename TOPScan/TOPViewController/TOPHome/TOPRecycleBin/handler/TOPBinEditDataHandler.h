#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPBinFolder, TOPBinDocument, TOPBinImage;
@interface TOPBinEditDataHandler : NSObject
+ (void)top_addFolderAtFile:(NSString *)path WithParentId:(NSString *)folderId;
+ (void)top_saddBinDocWithParentId:(NSString *)parentId atPath:(NSString *)path;
+ (void)top_setBinDocTime:(NSString *)binDocId withDocId:(NSString *)docId;
+ (void)top_addBinImageAtDocument:(NSArray *)fileNames WithId:(NSString *)docId;
+ (void)top_deleteFolderWithId:(NSString *)docId;
+ (void)top_deleteDocumentWithId:(NSString *)docId;
+ (void)top_deleteImagesWithIds:(NSArray *)docIds;

@end

NS_ASSUME_NONNULL_END
