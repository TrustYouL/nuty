#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPScoreView : UIView
@property (nonatomic,copy)void(^top_clickCancelBtn)(void);
@property (nonatomic,copy)void(^top_clickFiveStarBtn)(void);

@end

NS_ASSUME_NONNULL_END
