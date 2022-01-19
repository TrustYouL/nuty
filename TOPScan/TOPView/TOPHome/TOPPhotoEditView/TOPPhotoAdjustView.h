#import <UIKit/UIKit.h>
#import "TOPCameraBatchModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPPhotoAdjustView : UIView
@property (nonatomic ,strong)void (^changePictureState)(NSNumber * sliderValue,NSInteger sliderType);

- (void)top_reloadAdjustViewUIWithModel:(TOPCameraBatchModel *)model;
- (void)top_reloadAdjustViewUI;
@end

NS_ASSUME_NONNULL_END
