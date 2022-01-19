#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPImageWaterMarkController : UIViewController
@property (copy, nonatomic) NSString *imagePath;
@property (nonatomic,copy) void(^top_saveWatermarkBlock)(void);
@end

NS_ASSUME_NONNULL_END
