#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface TOPCornerToast : NSObject
+ (instancetype)shareInstance;
- (void)makeToast:(NSString *)message;
- (void)makeToast:(NSString *)message duration:(CGFloat)duration;
- (void)top_hiddenToast;
- (void)makeLoading;
- (void)hiddenLoadingView;
- (void)setToastCenter:(CGPoint)center;

@end

NS_ASSUME_NONNULL_END
