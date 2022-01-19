#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPBaseChildViewController : UIViewController
- (void)top_addRightButtonItem:(nullable NSString *)title Image:(nullable UIImage *)image WithSelector:(SEL)selector;
- (void)top_addLeftButtonItem:(nullable NSString *)title color:(UIColor *)color Image:(nullable UIImage *)image WithSelector:(SEL)selector;
- (void)top_addRightCameraButtonItemWithSelector:(SEL)selector;
- (void)top_initBackButton:(nullable NSString *)imgName withSelector:(SEL)selector;
- (void)top_configBackItemWithSelector:(SEL)selector;
@end

NS_ASSUME_NONNULL_END
