#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPInputTextView : UIView
@property (strong, nonatomic) UITextView *textFld;
@property (strong, nonatomic) UIColor *currentColor;
@property (nonatomic, copy) void(^top_callTextCompleteBlock)(NSString *text, UIColor *textColor);
@property (nonatomic, copy) void(^top_clickCancelBlock)(void);

- (void)top_beginEditing;
- (void)getTextViewHeightWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
