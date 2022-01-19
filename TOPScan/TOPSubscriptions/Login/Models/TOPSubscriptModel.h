//
//  TOPSubscriptModel.h
//  SimpleScan
//
//  Created by admin4 on 2021/7/2.
//  Copyright © 2021 admin3. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSubscriptModel : NSObject
/**
免费识别OCR点数 第一次默认为3
 **/
@property(nonatomic,assign) NSInteger freeOcrNum;
/**
是否订阅
 **/
@property(nonatomic,assign) BOOL apple_sub_status;


/**
是否处于免费试用期
 **/
@property(nonatomic,assign) BOOL is_trial_period;
/**
订阅的商品Key
 */
@property (copy, nonatomic) NSString * purchaseKey;

/**
订阅的原始ID
 */
@property (copy, nonatomic) NSString * original_transaction_id;

/**
订阅的当前订阅ID
 */
@property (copy, nonatomic) NSString * transaction_id;


/**
订阅的商品价格 例如 ￥12.00
 */
@property (copy, nonatomic) NSString * priceTitle;

/**
订阅后OCR识别点数 默认每个月1000点 识别一次扣除1点
 **/
@property(nonatomic,assign) NSInteger subOcrNum;

/**
 *  用户余额
 */
@property (assign, nonatomic) NSInteger  userBalance;

/**
 *      登录之后的用户余额
 */
@property (assign, nonatomic) NSInteger  userLoginBalance;



/**
订阅续费时间（每个月重置OCR点数点时间）
 **/
@property(nonatomic,assign) double subscriptUpdateTime;


/**
订阅结束时间
 **/
@property(nonatomic,assign) double subscriptEndTime;

/**
 0取消自动订阅了,1正常续订
 */
@property (assign, nonatomic) NSInteger  auto_renew_status;
/// -- 订阅数据解析
- (void)top_setupValueWithParam:(NSDictionary *)param;

@end

NS_ASSUME_NONNULL_END
