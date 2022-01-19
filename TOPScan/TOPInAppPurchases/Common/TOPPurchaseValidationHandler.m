
#import "TOPPurchaseValidationHandler.h"
#import "TOPNetWorkManager.h"
#import "TOPFreeBaseSqliteTools.h"

NSString * const SSAddSubscriptionApiUrl            = @"simpleScannerSubscription/addSubscription";//新增订阅
NSString * const SSAddOCRApiUrl            = @"scanIAP/addOCR";//购买OCR点数
NSString * const SSSubscriptionInfoApiUrl            = @"simpleScannerSubscription/getSubscription";//订阅详情
NSString * const SSOfferSignatureApiUrl            = @"simpleScannerSubscription/getPromotionOfferSignature";//订阅优惠签名
NSString * const SSCheckSubscribeApiUrl            = @"simpleScannerSubscription/isSubscribed";//查询是否有订阅记录

@implementation TOPPurchaseValidationHandler

#pragma mark -- 购买订阅服务校验
+ (void)topValidateSubscriptionsWithParam:(NSDictionary *)param success:(void (^)(NSDictionary * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    [TOPNetWorkManager topPostRequestWithUrl:SSAddSubscriptionApiUrl Param:param success:^(NSDictionary * _Nonnull res) {
        if (res) {
            TOPSubscriptModel *subModel = [TOPSubscriptTools getSubScriptData];
            [subModel top_setupValueWithParam:res];
            [TOPSubscriptTools changeSaveSubScripWith:subModel];
            if (success) {
                success(res);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark -- 购买OCR点数校验
+ (void)topValidateOCRCreditsWithParam:(NSDictionary *)param success:(void (^)(NSDictionary * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    [TOPNetWorkManager topPostRequestWithUrl:SSAddOCRApiUrl Param:param success:^(NSDictionary * _Nonnull res) {
        if (res) {
            NSInteger resultType = [res[@"resultType"] integerValue];
            if (resultType == 0) {
                NSString *buyHistory = [self topUpdateOCRBalance:res];
                [[TOPFreeBaseSqliteTools sharedSingleton] setOcr_buyhistoryToServiceWith:buyHistory];
                if (success) {
                    success(res);
                }
            } else {
                if (failure) {
                    NSError * newError = [[NSError alloc]initWithDomain:@"vip.service.error" code:resultType userInfo:@{NSLocalizedDescriptionKey : @"Validate Failure"}];
                    failure(newError);
                }
            }
        }
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark -- 订阅详情
+ (void)topFetchSubscriptionsWithParam:(NSDictionary *)param success:(void (^)(NSDictionary * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    if (!param.allKeys.count) {
        param = [self topRequestSubscriptionsParam];
    }
    [TOPNetWorkManager topPostRequestWithUrl:SSSubscriptionInfoApiUrl Param:param success:^(NSDictionary * _Nonnull res) {
        if (res) {
            TOPSubscriptModel *subModel = [TOPSubscriptTools getSubScriptData];
            [subModel top_setupValueWithParam:res];
            [TOPSubscriptTools changeSaveSubScripWith:subModel];
            if (success) {
                success(res);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark -- 获取促销优惠签名
+ (void)topFetchOfferSignatureWithParam:(NSDictionary *)param success:(nonnull void (^)(SKPaymentDiscount * _Nonnull))success failure:(nonnull void (^)(NSError * _Nonnull))failure  API_AVAILABLE(ios(12.2)){
    [TOPNetWorkManager topPostRequestWithUrl:SSOfferSignatureApiUrl Param:param success:^(NSDictionary * _Nonnull res) {
        if (res) {
            if (success) {
                if (@available(iOS 12.2, *)) {
                    SKPaymentDiscount *dis = [self topBuildPaymentDiscountWithParam:res];
                    success(dis);
                }
            }
        }
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark -- 查询用户是否购买了订阅
+ (void)topCheckSubscribeSuccess:(void (^)(NSInteger))success failure:(void (^)(NSError * _Nonnull))failure {
    [TOPNetWorkManager topPostRequestWithUrl:SSCheckSubscribeApiUrl Param:@{} success:^(NSDictionary * _Nonnull res) {
        if (res) {
            NSInteger state = [res[@"isSubscribed"] integerValue];
            if (success) {
                success(state);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (SKPaymentDiscount *)topBuildPaymentDiscountWithParam:(NSDictionary *)param  API_AVAILABLE(ios(12.2)){
    if (@available(iOS 12.2, *)) {
        NSString *offerId = param[@"identifier"];
        NSString *keyId = param[@"keyIdentifier"];
        NSUUID *nonce = [[NSUUID alloc] initWithUUIDString:param[@"nonce"]];
        NSString *signature = param[@"signature"];
        long timestamp = [param[@"timestamp"] longValue];
        NSNumber *stamp = [[NSNumber alloc] initWithLong:timestamp];
        SKPaymentDiscount *dis = [[SKPaymentDiscount alloc] initWithIdentifier:offerId keyIdentifier:keyId nonce:nonce signature:signature timestamp:stamp];
        return dis;
    }
    return nil;
}

+ (NSMutableDictionary *)topRequestSubscriptionsParam {
    TOPSubscriptModel *model = [TOPSubscriptTools getSubScriptData];
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"transaction_id"] = model.transaction_id;
    params[@"original_transaction_id"] = model.original_transaction_id;
    params[@"deviceId"] =  [TOPUUID top_getUUID];
    if ([TOPSubscriptTools googleLoginStates]) {
        params[@"userId"] = [FIRAuth auth].currentUser.uid;
    }
    return params;
}

+ (NSString *)topUpdateOCRBalance:(NSDictionary *)param {
    NSInteger userCurrentBalance = [TOPSubscriptTools getCurrentUserBalance];
    NSString * countCurrentIndex = @"200";
    if ([param.allKeys containsObject:@"product_id"]) {
        NSString *product_id = param[@"product_id"];
        if ([product_id isEqualToString:InAppProductIdConsumables200]) {
            userCurrentBalance = userCurrentBalance + 200;
            countCurrentIndex = @"200";
        } else if ([product_id isEqualToString:InAppProductIdConsumables1000]) {
            userCurrentBalance = userCurrentBalance + 1000;
            countCurrentIndex = @"1000";
        }
    }
    [TOPSubscriptTools saveWriteCurrentUserBalance:userCurrentBalance];
    NSString *buyHistory = [NSString stringWithFormat:@"%@ADDDDDD ====%@==transactionIdentID:%@ iOS",[TOPAppTools top_getCurrentTimeSeconds],countCurrentIndex,param[@"transaction_id"]];
    return buyHistory;
}

@end
