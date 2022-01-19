#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPBinHelper : NSObject
+ (NSString *)top_binBoxDirectory;
+ (NSString *)top_getBinFilePathString:(NSString*)str;
+ (NSString *)top_getBinFoldersPathString;
+ (NSString *)top_getBinDocumentsPathString;
+ (NSString *)top_binFileWithDeleteFolderPath:(NSString *)path isDoc:(BOOL)isDoc;
+ (NSString *)top_binImageWithDeleteFilePath:(NSString *)path isNewDoc:(BOOL)isNewDoc;
+ (NSString *)top_moveImageToBin:(NSString *)imgPath atNewDoc:(BOOL)newDoc;
+ (NSString *)top_moveDocumentToBin:(NSString *)docPath;
+ (NSString *)top_moveFolderToBin:(NSString *)docPath;
+ (NSString *)top_moveDocumentToBin:(NSString *)docPath progress:(void (^)(CGFloat moveProgressValue))moveProgressBlock;
+ (NSString *)top_restoreFolder:(NSString *)docPath atPath:(NSString *)path;
+ (NSString *)top_restoreDocument:(NSString *)docPath atPath:(NSString *)path;
+ (NSString *)top_restoreImage:(NSString *)imgPath atPath:(NSString *)docPath;
@end

NS_ASSUME_NONNULL_END
