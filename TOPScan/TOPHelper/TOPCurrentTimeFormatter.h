#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPCurrentTimeFormatter : NSDateFormatter
/// 单例初始化
+ (instancetype)shareInstance;
/// 销毁
+ (void)top_destroyInstance;
@end

NS_ASSUME_NONNULL_END
