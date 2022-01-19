#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPEraserSettingView : UIView
@property (assign, nonatomic) CGFloat eraserWidth;
@property (nonatomic, copy) void(^callSetCompleteBlock)(CGFloat width);

- (instancetype)initWithEarserValue:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
