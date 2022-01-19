#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPBaseViewController : UIViewController

@property (nonatomic ,strong)UIButton * sharaBtn;
- (void)top_addRightButtonItem:(nullable NSString *)title Image:(nullable UIImage *)image WithSelector:(SEL)selector;
- (void)top_addRightCameraButtonItemWithSelector:(SEL)selector;
- (void)top_initBackButton:(SEL)selector;
- (void)top_initCancleBackBtn:(SEL)selector;
@end

NS_ASSUME_NONNULL_END
