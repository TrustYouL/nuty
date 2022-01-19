

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPurchaseValidationHandler : NSObject

/// 购买订阅服务校验
/// @param param  商品参数
/// @param success 成功回调
/// @param failure 失败回调
+ (void)topValidateSubscriptionsWithParam:(NSDictionary *)param
                              success:(void (^)(NSDictionary * data))success
                              failure:(void (^)(NSError *error))failure;

/// 购买OCR点数校验
/// @param param  商品参数
/// @param success 成功回调
/// @param failure 失败回调
+ (void)topValidateOCRCreditsWithParam:(NSDictionary *)param
                              success:(void (^)(NSDictionary * data))success
                              failure:(void (^)(NSError *error))failure;

/// 获取订阅详情
/// @param param  请求参数
/// @param success 成功回调
/// @param failure 失败回调
+ (void)topFetchSubscriptionsWithParam:(NSDictionary *)param
                              success:(void (^)(NSDictionary * data))success
                              failure:(void (^)(NSError *error))failure;

/// 获取促销优惠签名
/// @param param  请求参数
/// @param success 成功回调
/// @param failure 失败回调
+ (void)topFetchOfferSignatureWithParam:(NSDictionary *)param
                              success:(void (^)(SKPaymentDiscount * payDiscount))success
                             failure:(void (^)(NSError *error))failure API_AVAILABLE(ios(12.2));

/// 查询用户是否购买了订阅
/// @param success 成功回调
/// @param failure 失败回调
+ (void)topCheckSubscribeSuccess:(void (^)(NSInteger state))success
                             failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
