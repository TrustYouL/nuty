#import <Realm/Realm.h>
#import "TOPBinImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPBinDocument : RLMObject

@property NSString *Id;
@property NSString *name;
@property NSString *parentId;
@property NSString *pathId;
@property NSString *filePath;
@property NSDate *ctime;
@property NSDate *utime;
@property NSDate *rtime;
@property BOOL isDelete;
@property NSString *tags;
@property int costTime;
@property RLMArray <TOPBinImage *> <TOPBinImage> *images;

#pragma mark -- pdf
@property int paginationLayout;
@property NSString *paperOrientation;
@property NSString *paperSize;
@property NSDate *remindTime;
@property NSString *remindNote;
@property NSString *remindTitle;
@property BOOL docNoticeLock;
@property BOOL isLock;
@property NSDate *delTime;
@property NSString *delParentId;

@end

NS_ASSUME_NONNULL_END
