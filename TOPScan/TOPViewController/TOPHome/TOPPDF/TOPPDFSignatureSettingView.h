#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPDFSignatureSettingView : UIView
@property (assign, nonatomic) CGFloat saturationValue;
@property (strong, nonatomic) UIColor *currentColor;
@property (nonatomic, copy) void(^top_clickCancelBlock)(void);
@property (nonatomic, copy) void(^top_changeSaturationValueBlock)(CGFloat saturation);
@property (nonatomic, copy) void(^top_changeColorBlock)(UIColor *color);

@end

NS_ASSUME_NONNULL_END
