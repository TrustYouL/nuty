#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPhotoEditScrollView : UIScrollView

@property (nonatomic, copy) void(^photoClickSingleHandler)(void);

@property (nonatomic, copy) void(^photoClickZoomHandler)(void);
@property (nonatomic, copy) void(^photoWillBeginDragging)(void);
@property (nonatomic, copy) void(^photoDidEndDecelerating)(void);

@property (nonatomic, copy) void(^photoZoomScale)(CGFloat zoomScale);
@property (nonatomic, strong) UIImage *mainImage;
@property (nonatomic, strong) UIImageView *mainImageView;
@end

NS_ASSUME_NONNULL_END
