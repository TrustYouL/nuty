#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (LongTap)

- (void)addLongTapWithTarget:(id)target action:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
