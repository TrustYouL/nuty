
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "TOPStoreObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPInAppStoreObserver : NSObject<SKPaymentTransactionObserver, SKRequestDelegate>

@property (nonatomic, strong) NSMutableArray<SKPaymentTransaction *> *purchased;//所有购买
@property (nonatomic, strong) NSMutableArray<SKPaymentTransaction *> *restored;//所有恢复购买的物品
@property (nonatomic, strong) SKPaymentTransaction *validatingTrans; //正在校验的支付对象
@property (nonatomic, assign) BOOL hasRestorablePurchases;//是否有可恢复的购买
@property (nonatomic, weak) id<TOPStoreObserverProtocol> delegate;

/// -- 单例初始化
+ (instancetype)shareInstance;
/// -- 购买监听写在程序入口,这样如果有未完成的订单将会自动执行并回调 paymentQueue:updatedTransactions:方法
- (void)topStartTransactionObserver;
/// -- 程序挂起时移除监听
- (void)topRemoveTransactionObserver;

/// -- 是否允许用户支付 查询应用商店时先告知用户
- (BOOL)topIsAuthorizedForPayments;
/// -- 购买商品
- (void)topBuyProduct:(SKProduct *)product;
/// -- 恢复所有以前完成的购买
- (void)topRestorePurchases;
/// -- 更新收据
- (void)topRefreshAppReceipt;
/// -- 二次校验，上次的校验失败，用户主动选择再次校验
- (void)topValidateAgain;

/// -- 校验锁 -- 保证交验完一条付款后才进行下一个校验
- (void)topLockValidation;
/// -- 校验解锁
- (void)topUnlockValidattion;

/// -- 获取详情订阅
- (void)topFetchSubscriptionInfo;
@end

NS_ASSUME_NONNULL_END
