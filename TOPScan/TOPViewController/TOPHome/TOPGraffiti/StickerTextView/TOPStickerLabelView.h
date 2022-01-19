#import <UIKit/UIKit.h>
#import "TOPUIHitSubView.h"
#import "TOPInputTextView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPStickerLabelView : TOPUIHitSubView
@property (nonatomic) CGPoint originalPoint;
@property (strong, nonatomic, nullable) UIView *contentView;
@property (copy, nonatomic) NSString *labText;
@property (strong, nonatomic) UIColor *textColor;
@property (assign, nonatomic) CGFloat fontsize;
@property (assign, nonatomic) CGFloat totalRotation;
@property (nonatomic, strong, nullable) TOPInputTextView *inputTextView;
- (instancetype)initWithContentView:(UIView *)contentView;
- (void)setEditTextCtrlImage:(UIImage *)image;
- (void)setRemoveCtrlImage:(UIImage *)image;
- (void)setTransformCtrlImage:(UIImage *)image;
- (void)hiddenCtrl;
- (void)showCtrl;
@property (nonatomic, copy) void(^deleteTextLabBlock)(void);
@end

NS_ASSUME_NONNULL_END
