#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPFHTimer : NSObject
/// -- 单例初始化
+ (instancetype)shareInstance;
/// -- 开始计时 每秒计一次
- (void)top_createTimerSeconds:(void (^)(int interval))seconds;
/// -- 销毁定时器
- (void)top_destroyTimer;

@end

NS_ASSUME_NONNULL_END
