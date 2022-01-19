#import <UIKit/UIKit.h>
#import "TOPAlertAction.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, TOPAlertControllerStyle) {
    TOPAlertControllerStyleActionSheet = 0,
    TOPAlertControllerStyleAlert
} API_AVAILABLE(ios(9.0));


UIKIT_EXTERN API_AVAILABLE(ios(9.0)) @interface TOPAlertController : UIViewController
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(TOPAlertControllerStyle)preferredStyle;
- (void)addAction:(TOPAlertAction *)action;
@property (nonatomic, readonly) NSArray<TOPAlertAction *> *actions;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;
@property (nonatomic, readonly) TOPAlertControllerStyle preferredStyle;
- (void)showInViewController:(UIViewController *)vc;
- (void)dismiss;
@property(nonatomic, assign) BOOL allowTapMaskToDismiss;
/// 点击空白处进行回调
@property(nonatomic, copy) void (^didTapMaskView)(void);
@property(nonatomic, strong) UIColor *titleColor;
/// title文本字体, Default is  13 bold
@property(nonatomic, strong) UIFont *titleFont;
/// message文本颜色,Default is #979797
@property(nonatomic, strong) UIColor *messageColor;
/// message文本字体 Default is 13
@property(nonatomic, strong) UIFont *messageFont;
/// 分割线的颜色,Default is #3C3C3C4A
@property(nonatomic, strong) UIColor *separatorColor;
/// 按钮文本颜色 style = TOPAlertActionStyleDefault ,Default is  #333（黑）
@property(nonatomic, strong) UIColor *textColorOfDefault;
/// 按钮文本字体 style = TOPAlertActionStyleDefault,Default is  17
@property(nonatomic, strong) UIFont *textFontOfDefault;
/// 按钮文本颜色 style = TOPAlertActionStyleCancel, Default is #097FFF（蓝）
@property(nonatomic, strong) UIColor *textColorOfCancel;
/// 按钮文本字体 style = TOPAlertActionStyleCancel ,Default is 17 bold
@property(nonatomic, strong) UIFont *textFontOfCancel;
/// 按钮文本颜色 style = TOPAlertActionStyleDestructive, Default is #FF4238 (红)
@property(nonatomic, strong) UIColor *textColorOfDestructive;
/// 按钮文本字体 style = TOPAlertActionStyleDestructive, Default is 17
@property(nonatomic, strong) UIFont *textFontOfDestructive;
/// action高亮背景颜色, Default is [UIColor colorWithWhite:0 alpha:0.03]
@property(nonatomic, strong) UIColor *actionBgColorOfHighlighted;
/// 取消按钮所在视图是否使用模糊效果，default is NO
@property(nonatomic, assign) BOOL isBlurEffectOfCancelView;
/// 默认白色（深色模式0.11的黑色）
@property(nonatomic, strong) UIColor *backgroundColorOfCancelView;
@property(nonatomic, assign) UIBlurEffectStyle effectStyle;
/// action的siize，可用于自定义Action
@property(nonatomic, assign, readonly) CGSize actionSize;
@end

NS_ASSUME_NONNULL_END
