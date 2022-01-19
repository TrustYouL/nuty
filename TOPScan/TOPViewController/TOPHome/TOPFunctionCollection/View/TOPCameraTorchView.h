#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPCameraTorchView : UIView
@property (nonatomic ,copy)void(^top_clickFlashBtnChangeType)(TOPCameraFlashType type);
@end

NS_ASSUME_NONNULL_END
