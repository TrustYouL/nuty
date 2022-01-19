//
//  TOPPurchasepayModel.h
//  SimpleScan
//
//  Created by admin4 on 2021/6/24.
//  Copyright © 2021 admin3. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class SKProduct;
@interface TOPPurchasepayModel : NSObject

- (instancetype)initWithProduct:(SKProduct *)product;

/**
 是否有免费试用
 */
@property (assign, nonatomic) BOOL isFreeTrial;

/**
 免费试用类型
 SKProductPeriodUnitDay = 0
 SKProductPeriodUnitWeek,
 SKProductPeriodUnitMonth,
 SKProductPeriodUnitYear
 */
@property (assign, nonatomic) NSInteger freeTrialTypeUnit;
/**
试用时间数量
 */
@property (assign, nonatomic) NSInteger numberOfUnits;

/**
 * key
 */
@property (copy, nonatomic) NSString * purchaseKey;
///**

/** 购买的金额 */
@property (nonatomic,copy) NSString * buyMoney;

/** 需要支付的金额 */
@property (nonatomic,assign) float  payMoney;
/**
 * 订阅主标题
 */
@property (copy, nonatomic) NSString * productTitle;

/**
 * 订阅副标题
 */
@property (copy, nonatomic) NSString * productSubTitle;

/** 购买的类型 */
@property (nonatomic,copy) NSString * buyType;
/** 折扣价*/
@property (nonatomic,copy) NSString * discountPrice;

@end

NS_ASSUME_NONNULL_END
