#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (WaterMark)
- (instancetype)initWithFrame:(CGRect)frame withText:(NSString *)text withBgImage:(UIImage *)bgImg;
@end

NS_ASSUME_NONNULL_END
