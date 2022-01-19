

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPDocPDF : RLMObject//待定 暂时没有使用该表

/**
 *  ID
 */
@property NSString *Id;
/**
 *  PDF密码
 */
@property NSString *password;
/**
 *  页码排版0、1~6 默认0
 */
@property NSInteger paginationLayout;
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
 *  是否加锁 有锁需要密码解
 */
@property BOOL isLock;
@end

NS_ASSUME_NONNULL_END
