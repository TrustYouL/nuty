#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPhotoCombineSignatureVC : UIViewController

@property (nonatomic,copy) NSString *imagePath;
@property(nonatomic,copy) void(^top_saveSignatureImgBlick)(void);

@end

NS_ASSUME_NONNULL_END
