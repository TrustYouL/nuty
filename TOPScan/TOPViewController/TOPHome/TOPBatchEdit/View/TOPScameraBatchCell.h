#import <UIKit/UIKit.h>
#import "TOPPhotoEditScrollView.h"
#import "TOPCameraBatchModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPScameraBatchCell : UICollectionViewCell
@property (nonatomic ,strong)TOPPhotoEditScrollView * zoomView;
@property (nonatomic ,copy)NSString * cameraBatchImagePath;
@property (nonatomic ,strong)TOPCameraBatchModel * model;
@property (nonatomic ,assign) CGFloat picH;
@property (nonatomic ,copy)void(^top_sendZoomScale)(CGFloat zoomScale);
@property (nonatomic ,copy)void(^top_changAdjustModelImg)(void);

@end

NS_ASSUME_NONNULL_END
