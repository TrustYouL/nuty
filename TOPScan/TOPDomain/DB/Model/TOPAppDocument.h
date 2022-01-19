
#import <Realm/Realm.h>
#import "TOPDocTag.h"
#import "TOPImageFile.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPAppDocument : RLMObject

/**
 *  ID
 */
@property NSString *Id;
/**
 *  文档名称
 */
@property NSString *name;
/**
 *  父id 上级目录的id
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
 *  查看时间 --reading
 */
@property NSDate *rtime;
/**
 *  是否被删除
 */
@property BOOL isDelete;
/**
 *  tags 01/02/  把标签文件名拼接加‘/’
 */
@property NSString *tags;
/**
 *  加载数据的耗时：xx/ms
 */
@property int costTime;
/**
 *  images
 */
@property RLMArray <TOPImageFile *> <TOPImageFile> *images; 

#pragma mark -- pdf
/**
 *  页码排版0、1~6 默认0
 */
@property int paginationLayout;
/**
 *  纸张朝向 自动适配、横、竖 默认自动适配
 */
@property NSString *paperOrientation;
/**
 *  纸张大小 A3,  A4，A5  默认A4
 */
@property NSString *paperSize;
/**
 *  文档提醒时间
 */
@property NSDate *remindTime;
/**
 *  文档提醒备注信息
 */
@property NSString *remindNote;
/**
 *  文档提醒备注标题
 */
@property NSString *remindTitle;
/**
 *   文档提醒关闭状态
 */
@property BOOL docNoticeLock;
/**
 *  是否加锁 有锁需要密码解
 */
@property BOOL isLock;
/**
 *  从回收站还原前的delParentId
 */
@property NSString *storeParentId;
/**
 *  是否收藏该文档
 */
@property NSInteger collectionState; 

@end

NS_ASSUME_NONNULL_END
