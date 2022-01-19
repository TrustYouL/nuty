//
//  TOPPurchasepayModel.m
//  SimpleScan
//
//  Created by admin4 on 2021/6/24.
//  Copyright © 2021 admin3. All rights reserved.
//

#import "TOPPurchasepayModel.h"
#import <StoreKit/StoreKit.h>
#import "SKProduct+Formatter.h"
#import "SKProductDiscount+Formatter.h"
#import "TOPInAppStoreManager.h"

@implementation TOPPurchasepayModel

- (instancetype)initWithProduct:(SKProduct *)product {
    self = [super init];
    if (self) {
        _purchaseKey = [product productIdentifier];
        _productTitle = product.top_regularPrice;
        _payMoney = [[product price] floatValue];
        if (product.introductoryPrice) {
            _isFreeTrial = YES;
            _freeTrialTypeUnit = product.introductoryPrice.subscriptionPeriod.unit;
            _numberOfUnits = product.introductoryPrice.subscriptionPeriod.numberOfUnits;
            _discountPrice = product.introductoryPrice.top_regularPrice;
        }
        _buyType = [NSString stringWithFormat:@"%ld %@", product.subscriptionPeriod.numberOfUnits, [self top_periodUnitString:product.subscriptionPeriod.unit]];
        _productSubTitle = [NSString stringWithFormat:@"%@/Mon", product.top_regularMonthPrice];
        if (@available(iOS 12.2, *)) {
            if (product.discounts.count) {
                SKProductDiscount *dis = product.discounts.firstObject;
                _discountPrice = dis.top_regularPrice;
            }
        }
        if (!_discountPrice) {
            _discountPrice = product.top_regularPrice;
        }
    }
    return self;
}

- (NSString *)top_periodUnitString:(SKProductPeriodUnit)unit {
    NSString *type = @"Month";
    switch (unit) {
        case SKProductPeriodUnitDay:
            type = @"Day";
            break;
        case SKProductPeriodUnitWeek:
            type = @"Week";
            break;
        case SKProductPeriodUnitMonth:
            type = @"Month";
            break;
        case SKProductPeriodUnitYear:
            type = @"Year";
            break;
            
        default:
            break;
    }
    return type;
}

@end
