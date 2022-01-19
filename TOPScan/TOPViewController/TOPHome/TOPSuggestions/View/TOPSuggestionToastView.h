#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSuggestionToastView : UIView
@property(nonatomic ,copy)void(^top_clickContinue)(void);
@property(nonatomic ,copy)void(^top_clickHideView)(void);
@end

NS_ASSUME_NONNULL_END
