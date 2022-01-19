#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPLoadingCircleView : UIView
/// 开始加载
- (void)top_startLoading;
/// 进度结束
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
