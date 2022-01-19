

#import "SKProductDiscount+Formatter.h"

@implementation SKProductDiscount (Formatter)

- (NSString *)top_regularPrice {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:self.price];//例如 ￥12.00
    return formattedPrice;
}

#pragma mark -- 平均每月的金额
- (NSString *)top_regularMonthPrice {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];//1234->1,234
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSDecimalNumber *months = [[NSDecimalNumber alloc] initWithInt:12];//12个月
    NSString *formattedPrice = [numberFormatter stringFromNumber:[self.price decimalNumberByDividingBy:months]];
    return formattedPrice;
}

@end
