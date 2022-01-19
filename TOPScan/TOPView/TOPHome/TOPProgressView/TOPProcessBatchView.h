#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPProcessBatchView : UIView

/// 显示进度
- (void)show;
/// 更新进度
- (void)top_showProgress:(CGFloat)currentProgress;
/// 进度结束
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
