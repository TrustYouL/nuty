#import "UIColor+DarkMode.h"

@implementation UIColor (DarkMode)
+ (UIColor *)top_textColor:(UIColor *)darkColor defaultColor:(UIColor *)defaultColor{
    if (@available(iOS 13.0, *)) {
        if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleUnspecified) {
            return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trait) {
               if (trait.userInterfaceStyle == UIUserInterfaceStyleDark) {
                   return darkColor;
               } else {
                   return defaultColor;
               }
            }];
        }else{
            if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleLight) {
                return defaultColor;
            }else{
                return darkColor;
            }
        }
      }else{
         return defaultColor;
      }
}

+ (UIColor *)top_viewControllerBackGroundColor:(UIColor *)darkColor defaultColor:(UIColor *)defaultColor{
    if (@available(iOS 13.0, *)) {
        if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleUnspecified) {
            return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trait) {
               if (trait.userInterfaceStyle == UIUserInterfaceStyleDark) {
                   return darkColor;
               } else {
                   return defaultColor;
               }
            }];
        }else{
            if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleLight) {
                return defaultColor;
            }else{
                return darkColor;
            }
        }
      }else{
         return defaultColor;
      }
}
@end
