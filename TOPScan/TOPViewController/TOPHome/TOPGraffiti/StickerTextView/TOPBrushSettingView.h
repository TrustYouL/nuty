#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPBrushSettingView : UIView
@property (assign, nonatomic) CGFloat brushSize;
@property (assign, nonatomic) CGFloat opacityValue;
@property (strong, nonatomic) UIColor *currentColor;
@property (nonatomic, copy) void(^callSetCompleteBlock)(UIColor *textColor, CGFloat brush, CGFloat opacity);
@property (nonatomic, copy) void(^top_clickCancelBlock)(void);
@property (nonatomic, copy) void(^changeBrushValueBlock)(CGFloat brush);
@property (nonatomic, copy) void(^changeOpacityValueBlock)(CGFloat opacity);
@property (nonatomic, copy) void(^changeTextColorBlock)(UIColor *color);

@end

NS_ASSUME_NONNULL_END
