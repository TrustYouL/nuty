#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPUIThroughSuperView : UIView
@property (nonatomic,copy) void(^tapViewBlock)(void);//点击事件

@end

NS_ASSUME_NONNULL_END
