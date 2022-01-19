

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPDiscountThemeView : UIView

@property (nonatomic, copy) void(^purchaseSucceed)(void);
@property (nonatomic, copy) void(^overTimeBlock)(void);

+ (instancetype)shareInstance;
- (void)top_showDiscountTheme:(NSString *)productId;
- (void)top_hiddenTheme;


@end

NS_ASSUME_NONNULL_END
