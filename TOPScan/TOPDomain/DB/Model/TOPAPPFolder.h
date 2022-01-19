
#import <Realm/Realm.h>
#import "TOPAppDocument.h"



NS_ASSUME_NONNULL_BEGIN

@interface TOPAPPFolder : RLMObject

/**
 *  ID
 */
@property NSString *Id;
/**
 *  文件名称
 */
@property NSString *name;
/**
 *  父id  上级目录的id
 */
@property NSString *parentId;
/**
 *  文件夹路径id  上级目录的pathId + Id
 */
@property NSString *pathId;
/**
 *  文件夹路径 **不存数据库 设置忽略属性
 */
@property NSString *filePath;
/**
 *  创建时间
 */
@property NSDate *ctime;
/**
 *  更新时间
 */
@property NSDate *utime;
/**
 *  是否被删除
 */
@property BOOL isDelete;


@end

NS_ASSUME_NONNULL_END
