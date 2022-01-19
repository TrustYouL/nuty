#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPNewScoreView : UIView
@property (nonatomic ,copy)void(^top_submitScore)(NSInteger score);
@end

NS_ASSUME_NONNULL_END
