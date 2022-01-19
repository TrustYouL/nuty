#import <UIKit/UIKit.h>
#import "TOPPhotoEditScrollView.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPShowPicCollectionViewCell : UICollectionViewCell
@property (nonatomic ,strong)TOPPhotoEditScrollView * zoomView;
@property (nonatomic ,strong)DocumentModel * model;
@property (nonatomic ,strong)NSString * cameraImagePath;
@property (nonatomic ,strong)NSString * cameraBatchImagePath;
@property (nonatomic ,copy)void (^top_clickItem)(void);
@property (nonatomic ,copy)void (^top_clickZoom)(void);
@property (nonatomic ,copy)void(^top_sendZoomScale)(CGFloat zoomScale);
@property (nonatomic ,copy)void(^top_scrollBeginShow)(void);
@property (nonatomic ,copy)void(^top_scrollEndHide)(void);
@end

NS_ASSUME_NONNULL_END
