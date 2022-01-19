#import <UIKit/UIKit.h>

@interface UIColor (HJWColor)
+ (UIColor *)colorWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
+ (UIImage*)top_imageWithColor: (UIColor*) color;
@end
