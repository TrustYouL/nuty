#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPBatchAddPicCell : UICollectionViewCell
@property (nonatomic ,strong)UIView * backView;
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,assign)BOOL isFinish;
@property (nonatomic ,copy)void(^top_clickAddBtn)(void);

@end

NS_ASSUME_NONNULL_END
