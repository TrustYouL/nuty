

#import "SKProduct+Formatter.h"

@implementation SKProduct (Formatter)

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
    if (self.subscriptionPeriod.unit == SKProductPeriodUnitMonth || self.subscriptionPeriod.unit == SKProductPeriodUnitYear) {
        NSInteger numNuit = self.subscriptionPeriod.unit == SKProductPeriodUnitYear ? 12 : self.subscriptionPeriod.numberOfUnits;
        NSDecimalNumber *months =  [[NSDecimalNumber alloc] initWithInt:(int)numNuit];
        NSString *formattedPrice = [numberFormatter stringFromNumber:[self.price decimalNumberByDividingBy:months]];
        return formattedPrice;
    }
    NSString *formattedPrice = [numberFormatter stringFromNumber:self.price];
    return formattedPrice;
}

@end
