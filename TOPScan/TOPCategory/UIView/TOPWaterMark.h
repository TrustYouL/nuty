#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPWaterMark : NSObject
+ (UIImage*)view:(UIImageView *)view WaterImageWithImage:(UIImage *)image text:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
