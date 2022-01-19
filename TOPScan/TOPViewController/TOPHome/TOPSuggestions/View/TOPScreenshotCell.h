#import <UIKit/UIKit.h>
#import "TOPPhotoEditScrollView.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPScreenshotCell : UICollectionViewCell
@property (nonatomic ,strong)UIImageView * deleteImg;
@property (nonatomic ,strong)UIButton * deleteBtn;
@property (nonatomic ,strong)TOPPhotoEditScrollView * zoomView;
@property (nonatomic ,strong)UIView * backView;
@property (nonatomic ,strong)UIImageView * addImg;
@property (nonatomic ,copy)NSString * picName;
@property (nonatomic ,copy)void(^top_deleteCurrentPic)(NSString * picName);
@property (nonatomic ,copy)void(^top_sendZoomScale)(CGFloat zoomScale);

@end

NS_ASSUME_NONNULL_END
