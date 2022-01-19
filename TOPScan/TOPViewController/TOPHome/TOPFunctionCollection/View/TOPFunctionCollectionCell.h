#import <UIKit/UIKit.h>
#import "TOPFunctionColletionModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPFunctionCollectionCell : UICollectionViewCell
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)TOPFunctionColletionModel * model;
@end

NS_ASSUME_NONNULL_END
