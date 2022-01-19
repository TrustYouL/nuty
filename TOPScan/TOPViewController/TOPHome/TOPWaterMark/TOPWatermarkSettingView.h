#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPWatermarkSettingView : UIView
@property (strong, nonatomic) UIColor *currentColor;
@property (assign, nonatomic) CGFloat opacityValue;
@property (assign, nonatomic) CGFloat fontSize;
@property (nonatomic, copy) void(^top_changeSettingBlock)(UIColor *textColor, CGFloat fontValue, CGFloat opacity);
- (instancetype)initWithFontSie:(CGFloat)fontsize opacity:(CGFloat)opacity;//初始化
@end

NS_ASSUME_NONNULL_END
