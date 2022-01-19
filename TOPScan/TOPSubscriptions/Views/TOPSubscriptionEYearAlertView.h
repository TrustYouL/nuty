

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSubscriptionEYearAlertView : UIView
@property (strong, nonatomic) UICollectionView *collectionView;
/**
 ActionSheet 自定义

 @param selectBlock 选择回调
 */
- (instancetype)initWithAlertViewSelectBlock:(void(^)(TOPSubscriptionEYearAlertView *showAlertView))selectBlock cancelBlock:(void(^)(void))cancelBlock;


// 展示弹窗

- (void)top_showAlertUnBoundView;
// 展示弹窗

- (void)top_showAlertUnBoundViewSuperView:(UIView *)supView;

// 隐藏弹窗

- (void)top_dismissUnBoundView;

@end

NS_ASSUME_NONNULL_END
