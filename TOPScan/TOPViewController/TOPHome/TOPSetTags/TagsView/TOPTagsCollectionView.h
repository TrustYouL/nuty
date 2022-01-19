#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPTagsCollectionView : UICollectionView<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong)NSMutableArray * dataArray;
@property (nonatomic,copy)NSString * headerTitle;
@property (nonatomic,copy)void(^top_clickCellchangeState)(TOPTagsModel * model);
@end 

NS_ASSUME_NONNULL_END
