#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TLModalStyle) {
    TLModalStyleActionSheet = 0,
    TLModalStyleAlert
} API_AVAILABLE(ios(9.0));
#define Is_iPhoneX (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) || \
                    CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)) || \
                    CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 896)) || \
                    CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(896, 414)))

@interface TOPAlertPresentationController : UIPresentationController<UIViewControllerTransitioningDelegate>
@property(nonatomic, assign) NSTimeInterval transitionDuration;
@property(nonatomic, assign) BOOL disableTapMaskToDismiss;
@property(nonatomic, copy) void (^didTapMaskView)(void);
@property(nonatomic, assign) TLModalStyle modalStyle;
@end

NS_ASSUME_NONNULL_END
