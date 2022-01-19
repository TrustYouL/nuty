#import <UIKit/UIKit.h>
#import "TOPGuideView.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPGuideIphoneCell : UICollectionViewCell
@property (nonatomic,strong)TOPGuideView * guideView;
@property (nonatomic,strong)TOPGuideModel * model;
@property (nonatomic,copy)void(^top_lastPageEnterAction)(void);
@end

NS_ASSUME_NONNULL_END
