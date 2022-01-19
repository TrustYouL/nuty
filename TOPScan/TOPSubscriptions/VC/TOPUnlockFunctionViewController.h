
#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPUnlockFunctionViewController : TOPBaseChildViewController
/**
 订阅购买完成后关闭页面 同时关闭首页的订阅弹框
 */
@property (copy, nonatomic) void(^purchaseSuecssCloseHomeAlertBlock)(BOOL isPurchaseSuecss);
/**
 订阅购买完成后到关闭模式 不设置默认为pop到上一页面
 */
@property (nonatomic,assign) TOPSubscriptOverCloseType closeType;

/**
 是否显示底部的订阅
 */
@property (nonatomic,assign) BOOL isHiddenBottomSubScript;

@end

NS_ASSUME_NONNULL_END
