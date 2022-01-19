#import <UIKit/UIKit.h>
#import "TOPPdfSizeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPPdfSizeSettingView : UIView
@property (nonatomic,strong)UICollectionView * collectionView;
@property (nonatomic ,copy)void(^top_dismissAction)(void);
@property (nonatomic ,copy)void(^top_choosePdfSize)(TOPPdfSizeModel *model);
@end

NS_ASSUME_NONNULL_END
