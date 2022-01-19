

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPCreditsTipView : UIView
/**
 ActionSheet 自定义
 @param selectBlock 选择回调
 */
- (instancetype)initWithTitleViewSelectBlock:(void(^)(void))selectBlock;

// 展示弹窗

- (void)top_showAlertUnBoundView;

// 隐藏弹窗

- (void)top_dismissUnBoundView;
@end

NS_ASSUME_NONNULL_END
