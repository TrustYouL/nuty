#import <UIKit/UIKit.h>
#import "TOPBatchEditModel.h"
#import <FLAnimatedImageView.h>
#import <FLAnimatedImage.h>
NS_ASSUME_NONNULL_BEGIN

@interface TOPChildBatchCell : UICollectionViewCell
@property (nonatomic ,assign)NSInteger index;
@property (nonatomic ,strong)UIImageView * picImg; 
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)TOPBatchEditModel * model;
@property (nonatomic ,strong)UILabel * backLab;
@property (nonatomic ,strong)FLAnimatedImageView * flImg;
@property (nonatomic ,copy)void(^top_refreshCurrentCell)(TOPBatchEditModel * model);

@end

NS_ASSUME_NONNULL_END
