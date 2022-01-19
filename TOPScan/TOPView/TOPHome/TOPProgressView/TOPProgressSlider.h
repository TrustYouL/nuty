#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPProgressSlider : UIView

- (void)top_showWithStatus:(NSString *)status;
- (void)top_showProgress:(CGFloat)currentProgress withStatus:(NSString *)status;
- (void)top_resetProgress;
- (void)dismiss;
- (void)hide;
- (void)show;

@end

NS_ASSUME_NONNULL_END
