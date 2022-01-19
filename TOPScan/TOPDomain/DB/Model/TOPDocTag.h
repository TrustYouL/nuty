

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPDocTag : RLMObject

/**
 *  ID
 */
@property NSString *Id;
/**
 *  文件名称
 */
@property NSString *name;
/**
 *  文件夹路径 **不存数据库 设置忽略属性
 */
@property (readonly) NSString *filePath;
/**
 *  类型
 */
@property int tagType;//默认1类型  文本
/**
 * 颜色id
 */
@property int tagColor;//默认1 黑色
/**
 * 排序
 */
@property int sort;//排序
/**
 *  创建时间
 */
@property NSDate *ctime;
/**
 *  更新时间
 */
@property NSDate *utime;


@end

NS_ASSUME_NONNULL_END
