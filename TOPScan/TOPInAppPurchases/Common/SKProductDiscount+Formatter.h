

#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKProductDiscount (Formatter)
///  -- 金额格式化
- (NSString *)top_regularPrice;
/// -- 平均每月的金额
- (NSString *)top_regularMonthPrice;

@end

NS_ASSUME_NONNULL_END
