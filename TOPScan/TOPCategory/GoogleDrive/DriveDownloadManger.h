#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface DriveDownloadManger : NSObject
@property (nonatomic,strong) NSMutableArray *selectDownloadDriveArrays;
//批量下载pdf和jpg
- (void)startDownloadSelectFileDataWith:(NSMutableArray *)drives withDownloadSave:(NSString *)savePath Type:(TOPDownLoadDataStyle)driveType downloadEnterType:(TOPDownloadFileToDriveAddPathType) downloadFileType
                              withDocID:(NSString *)currentDocId;
//单利
+ (instancetype)sharedSingleton;
@property (nonatomic,assign) TOPDownLoadDataStyle  downType;
@property (nonatomic,copy) NSString *dropBoxToken;
@property (nonatomic,strong) NSMutableArray *drivePaths;
- (void)updateZipWithGoogleDrive:(NSString *)filePath  Type:(TOPDownLoadDataStyle)type completionBlock:(void (^)(GTLRDrive_File *fileDrive, NSError *error))completionBlock progress:(void (^)( float progressValue))progress;
- (void)queryDriveWithGoogleCompletionBlock:(void (^)(NSArray<GTLRDrive_File *> *fileItems, NSError *error))completionBlock;
- (void)deleteGoogleItemWithIdentifier:(NSString *)fileID CompletionBlock:(void (^)(BOOL deleteStates, NSError *error))completionBlock;
- (void)downRestoreDataZipWithItem:(GTLRDrive_File *)fileDrive CompletionBlock:(void (^)(NSString  *zipFilePath, NSError *error))completionBlock progress:(void (^)( float progressValue))progress;
- (FHGoogleAccountState)getCurrentGoogleStates;
- (void)updateZipWithDropBox:(NSString *)filePath  completionBlock:(void (^)(DBFILESMetadata *fileDrive))completionBlock progress:(void (^)( float progressValue))progress;
- (void)queryFileINDropBoxWithObjectCompletionBlock:(void (^)(NSArray<DBFILESMetadata *> *fileItems))completionBlock;
- (void)deleteDropBoxItemWithPath:(NSString *)filepath CompletionBlock:(void (^)(BOOL deleteStates))completionBlock;
- (void)downRestoreDataZipWithDropBoxItem:(DBFILESMetadata *)fileDrive CompletionBlock:(void (^)(NSString  *zipFilePath))completionBlock progress:(void (^)( float progressValue))progress;
#pragma mark BOX

- (void)updateZipWithBoxDrive:(NSString *)filePath completionBlock:(void (^)(BOXItem *fileDrive))completionBlock progress:(void (^)( float progressValue))progress;
- (void)queryFileBoxWithObjectCompletionBlock:(void (^)(NSArray<BOXItem *> *fileItems))completionBlock;
- (void)deleteBoxItemWithID:(NSString *)fileID CompletionBlock:(void (^)(BOOL deleteStates))completionBlock;
- (void)downRestoreZipWithBoxItem:(BOXItem *)fileDrive CompletionBlock:(void (^)(NSString  *zipFilePath))completionBlock progress:(void (^)( float progressValue))progress;
#pragma mark OneDrive

- (void)queryFileOneDriveWithObjectCompletionBlock:(void (^)(NSArray<ODItem *> *fileItems))completionBlock ;
- (void)deleteOneDriveWithID:(NSString *)fileID CompletionBlock:(void (^)(BOOL deleteStates))completionBlock;
- (void)updateZipWithOneDrive:(NSString *)filePath completionBlock:(void (^)(ODItem *fileDrive))completionBlock progress:(void (^)( float progressValue))progress;
- (void)downReZipWithOneDriveItem:(ODItem *)fileDrive CompletionBlock:(void (^)(NSString  *zipFilePath))completionBlock progress:(void (^)( float progressValue))progress;
- (void)installDownLoadDataDocoumentFile:(NSString *)zipFilePath;
@end

NS_ASSUME_NONNULL_END
