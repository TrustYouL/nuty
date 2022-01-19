#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPBinImage : RLMObject
@property NSString *Id;
@property NSString *parentId;
@property NSString *pathId;
@property NSString *filePath;
@property NSString *name;
@property long fileLength;
@property NSString *fileName;
@property (readonly) NSString *picIndex;
@property NSString *fileShowName;
@property NSString *driveId;
@property NSString *boxId;
@property NSString *dropBoxId;
@property NSString *oneDriveId;
@property NSString *oneNoteId;
@property NSString *envrNoteId;
@property NSString *uploadTime;
@property NSDate *ctime;
@property NSDate *utime;
@property BOOL isDelete;
@property BOOL isUploadSuccess;
@property BOOL isUpload;
@property NSData *portraitPoints;
@property NSData *landscapePoints;
@property NSData *atuoPortraitPoints;
@property NSData *autoLandscapePoints;
@property int orientation;
@property int filterMode;
@property NSDate *delTime;
@property NSString *delParentId;

@end

NS_ASSUME_NONNULL_END
RLM_COLLECTION_TYPE(TOPBinImage)
