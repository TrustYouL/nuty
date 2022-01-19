//
//  TOPSubscriptModel.m
//  SimpleScan
//
//  Created by admin4 on 2021/7/2.
//  Copyright © 2021 admin3. All rights reserved.
//

#import "TOPSubscriptModel.h"
#import "TOPInAppStoreManager.h"

@implementation TOPSubscriptModel
/**/
+ (instancetype)accountWithDict:(NSDictionary *)dict {
    TOPSubscriptModel * subscript = [[self alloc] init];
    subscript.apple_sub_status           =  [dict[@"apple_sub_status"] boolValue];
    subscript.is_trial_period           =  [dict[@"is_trial_period"] boolValue];
    subscript.transaction_id           =   dict[@"transaction_id"];
    subscript.purchaseKey           =   dict[@"purchaseKey"];
    subscript.original_transaction_id           = dict[@"original_transaction_id"];
    subscript.priceTitle           = dict[@"priceTitle"];
    subscript.subOcrNum           =  [dict[@"subOcrNum"] integerValue];
    subscript.freeOcrNum           =  [dict[@"freeOcrNum"] integerValue];

    
    subscript.userBalance           =  [dict[@"userBalance"] integerValue];
    subscript.userLoginBalance           =  [dict[@"userLoginBalance"] integerValue];
    subscript.subscriptUpdateTime           =  [dict[@"subscriptUpdateTime"] doubleValue];
    subscript.subscriptEndTime           =  [dict[@"subscriptEndTime"] doubleValue];
    subscript.auto_renew_status           =  [dict[@"auto_renew_status"] integerValue];

    
    return subscript;
}



- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
/**
 *  当从文件中读取一个对象的时候调用
 *  在这个方法中写清楚怎么解析文件中的数据，利用key来解析数据
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.purchaseKey        = [aDecoder decodeObjectForKey:@"purchaseKey"];
        self.original_transaction_id         = [aDecoder decodeObjectForKey:@"original_transaction_id"];
        self.transaction_id         = [aDecoder decodeObjectForKey:@"transaction_id"];


        self.priceTitle      = [aDecoder decodeObjectForKey:@"priceTitle"];
        self.apple_sub_status       = [[aDecoder decodeObjectForKey:@"apple_sub_status"] boolValue];
        self.is_trial_period       = [[aDecoder decodeObjectForKey:@"is_trial_period"] boolValue];

        self.freeOcrNum       = [[aDecoder decodeObjectForKey:@"freeOcrNum"] integerValue];

        self.subOcrNum       = [[aDecoder decodeObjectForKey:@"subOcrNum"] integerValue];
        self.userBalance       = [[aDecoder decodeObjectForKey:@"userBalance"] integerValue];
        self.userLoginBalance       = [[aDecoder decodeObjectForKey:@"userLoginBalance"] integerValue];
        self.subscriptUpdateTime       = [[aDecoder decodeObjectForKey:@"subscriptUpdateTime"] doubleValue];
        self.subscriptEndTime       = [[aDecoder decodeObjectForKey:@"subscriptEndTime"] doubleValue];
        self.auto_renew_status       = [[aDecoder decodeObjectForKey:@"auto_renew_status"] integerValue];
               
    }
    return self;
}



/**
 *  当将一个对象存储到文件中的时候需要调用
 *  这这个方法中写清楚要存储哪些属性，以及定义怎么存储属性，以及存储哪些属性
 */
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.purchaseKey forKey:@"purchaseKey"];
    [aCoder encodeObject:self.original_transaction_id forKey:@"original_transaction_id"];
    [aCoder encodeObject:self.transaction_id forKey:@"transaction_id"];

    [aCoder encodeObject:self.priceTitle forKey:@"priceTitle"];
    
    [aCoder encodeObject:[NSString stringWithFormat:@"%ld",self.userLoginBalance] forKey:@"userLoginBalance"];
    [aCoder encodeObject:[NSString stringWithFormat:@"%ld",self.userBalance] forKey:@"userBalance"];
    [aCoder encodeObject:[NSString stringWithFormat:@"%ld",self.subOcrNum] forKey:@"subOcrNum"];
    [aCoder encodeObject:[NSString stringWithFormat:@"%d",self.apple_sub_status] forKey:@"apple_sub_status"];
    [aCoder encodeObject:[NSString stringWithFormat:@"%d",self.is_trial_period] forKey:@"is_trial_period"];
    [aCoder encodeObject:[NSString stringWithFormat:@"%ld",self.freeOcrNum] forKey:@"freeOcrNum"];

    [aCoder encodeObject:[NSString stringWithFormat:@"%ld",self.auto_renew_status] forKey:@"auto_renew_status"];
    [aCoder encodeObject:[NSString stringWithFormat:@"%f",self.subscriptUpdateTime] forKey:@"subscriptUpdateTime"];
    [aCoder encodeObject:[NSString stringWithFormat:@"%f",self.subscriptEndTime] forKey:@"subscriptEndTime"];


}

- (void)top_setupValueWithParam:(NSDictionary *)param {
    NSString *productKey = param[@"product_id"];
    _purchaseKey = productKey;
    _subscriptEndTime = [param[@"expires_date_ms"] doubleValue];
    _is_trial_period = [param[@"is_trial_period"] boolValue];
    _original_transaction_id = param[@"original_transaction_id"];
    _transaction_id = param[@"transaction_id"];
    _auto_renew_status = [param[@"auto_renew_status"] integerValue];
    _freeOcrNum = 0;
    NSInteger resultType = [param[@"apple_sub_status"] integerValue];
    switch (resultType) {//0过期,1正常
        case 0:
        {
            _auto_renew_status = 0;
            _apple_sub_status = NO;
            _subOcrNum = 0;
        }
            break;
        case 1:
        {
            _auto_renew_status = 1;
            _apple_sub_status = YES;
            [TOPScanerShare top_writeshowSubscriptViewNum:9];
            double nowTime = [param[@"currentTimeMillis"] doubleValue] > 0 ? [param[@"currentTimeMillis"] doubleValue] : [TOPAppTools timeStamp];
            NSString *periodUnit = [[TOPInAppStoreManager shareInstance] topProductPeriodUnit:productKey];
            if ([periodUnit isEqualToString:InAppSubscriptionPeriodUnitMonth]) {
                _priceTitle = @"1 Month Premium";
                //OCR识别点数重置时间（订阅结束时间）
                if (nowTime >= _subscriptUpdateTime) {//到了更新日期
                    _subOcrNum = 1000;
                    _subscriptUpdateTime = [param[@"expires_date_ms"] doubleValue];;//记录下次更新时间
                }
            } else if ([periodUnit isEqualToString:InAppSubscriptionPeriodUnitYear]) {
                _priceTitle = @"1 Year Premium";
                //订阅为1年时下次订阅套餐OCR识别点数重置时间
                if (nowTime >= _subscriptUpdateTime) {//到了更新日期
                    _subOcrNum = 1000;
                    _subscriptUpdateTime = [TOPValidateTools top_beginningOfNextMonth:nowTime];//记录下次更新时间
                }
            }
        }
            break;
            
        default:
            break;
    }
    _subOcrNum = 0;
}

@end
