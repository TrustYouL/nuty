#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (DarkMode)

+ (UIColor *)top_textColor:(UIColor *)darkColor defaultColor:(UIColor *)defaultColor;

+ (UIColor *)top_viewControllerBackGroundColor:(UIColor *)darkColor defaultColor:(UIColor *)defaultColor;
@end

NS_ASSUME_NONNULL_END
