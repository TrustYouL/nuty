#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPBinFolder : RLMObject
@property NSString *Id;
@property NSString *name;
@property NSString *parentId;
@property NSString *pathId;
@property NSString *filePath;
@property NSDate *ctime;
@property NSDate *utime;
@property NSDate *delTime;
@property NSString *delParentId;

@end

NS_ASSUME_NONNULL_END
