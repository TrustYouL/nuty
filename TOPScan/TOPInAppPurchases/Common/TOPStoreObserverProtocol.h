

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TOPStoreObserverProtocol <NSObject>

@required
/// -- 恢复购买成功回调
- (void)top_topStoreObserverRestoreDidSucceed;
/// -- 购买成功
- (void)topStoreObserverPurchaseSucceed;
/// -- 票据验证成功
- (void)topStoreObserverValidateSucceed;
/// -- 二次票据验证 失败后提示用户再次校验
- (void)topStoreObserverValidateAgain;
/// -- 票据为空 ，提示用户去主动获取收据
- (void)topStoreObserverAppReceiptIsEmpty;
/// -- 回调信息
- (void)top_topStoreObserverDidReceiveMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
