#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPMarkTextInputView : UIView
@property (strong, nonatomic) UITextField *textFld;
@property (strong, nonatomic) UIColor *currentColor;
@property (assign, nonatomic) CGFloat opacityValue;
@property (assign, nonatomic) CGFloat fontSize;
@property (nonatomic, copy) void(^top_callTextCompleteBlock)(NSString *text, UIColor *textColor, CGFloat fontValue, CGFloat opacity);
@property (nonatomic, copy) void(^top_clickCancelBlock)(void);
- (instancetype)initWithFontSie:(CGFloat)fontsize opacity:(CGFloat)opacity;//初始化
- (void)top_beginEditing;

@end

NS_ASSUME_NONNULL_END
