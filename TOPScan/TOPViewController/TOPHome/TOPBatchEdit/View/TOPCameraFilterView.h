#import <UIKit/UIKit.h>
#import "TOPReEditModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPCameraFilterView : UIView
@property (nonatomic, copy)void(^top_sendProcessStateTip)(TOPReEditModel * model,NSInteger index);
@property (nonatomic, strong) UICollectionView *filterCollectionView;//渲染列表
@end

NS_ASSUME_NONNULL_END
