#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TOPPhotoShowChildImageViewDelegate <NSObject>
@optional
- (void)top_photoShowChildImageViewCurrentLocation:(NSInteger)index;
- (void)top_photoShowChildImageViewStartScrollow:(NSInteger)index;
- (void)top_photoShowChildImageViewScrollBeginHide;
- (void)top_photoShowChildImageViewScrollEndShow;
- (void)top_photoShowChildImageViewTextAgainScrollBeginShow;
- (void)top_photoShowChildImageViewTextAgainScrollEndHide;
- (void)top_photoShowChildImageViewBackHomeVC;
- (void)top_photoShowChildImageViewTailoringAgain:(NSArray *)dataArray;
- (void)top_photoShowChildImageViewScrollViewToSelect:(NSInteger)index;
- (void)top_photoShowChildImageViewShowEditNote:(NSInteger)index;
- (void)top_photoShowChildImageViewShowSignatureImage:(NSInteger)index;
- (void)top_photoShowChildImageViewShowShareView:(NSInteger)shareType currentIndex:(NSInteger)index;
- (void)top_photoShowChildImageViewSaveToGallery:(NSInteger)index;
- (void)top_photoShowChildImageViewPrint:(NSInteger)index;
- (void)top_photoShowChildImageViewDelete:(NSInteger)index;
- (void)top_photoShowChildImageViewMore:(NSInteger)index;
- (void)top_photoShowChildImageViewSwitchShowType:(BOOL)isshow;
- (void)top_photoShowChildImageViewOcrAgain:(NSInteger)index;
- (void)top_photoShowChildImageViewEditAgain:(NSInteger)index;
- (void)top_photoShowChildImageViewCopy:(NSInteger)index;
- (void)top_photoShowChildImageViewExport:(NSInteger)index;
- (void)top_photoShowChildImageViewTranlation:(NSInteger)index;
- (void)top_photoShowChildImageViewSaveText:(NSInteger)index;
- (void)top_photoShowChildImageViewShareText:(NSInteger)index;
- (void)top_photoShowChildImageViewOCRText;
- (void)top_photoShowChildImageViewOCRLanguage;
- (void)top_photoShowChildImageViewOCRBalanceClick;
- (void)top_photoShowChildImageViewOCRStarImage:(NSMutableArray *)dataArray currentIndex:(NSInteger)index;
@end
@interface TOPPhotoShowChildImageView : UIView
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) id<TOPPhotoShowChildImageViewDelegate>delegate;
@property (nonatomic, assign) TOPPhotoShowViewShowType showType;
@property (nonatomic, assign) TOPPhotoShowOCRVCAgainType ocrAgain;
@property (nonatomic, assign) CGFloat textAgainCellH;
@property (nonatomic, assign) TOPCollectionConstantType ConstantType;
@property (nonatomic, assign) CGFloat adSizeH;
- (void)top_loadCurrentData;
- (void)top_resetcollectionViewContent;
@end

NS_ASSUME_NONNULL_END
