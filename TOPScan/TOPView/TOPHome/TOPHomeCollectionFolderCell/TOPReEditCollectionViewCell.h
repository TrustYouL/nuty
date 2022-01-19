#import <UIKit/UIKit.h>
#import "TOPReEditModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPReEditCollectionViewCell : UICollectionViewCell
@property (nonatomic ,strong)UIImageView * showImg;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,assign)NSInteger row;
@property (nonatomic ,strong)TOPReEditModel * model;
@end

NS_ASSUME_NONNULL_END
