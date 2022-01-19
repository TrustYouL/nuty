#import <UIKit/UIKit.h>
#import "GKCycleScrollViewCell.h"
#import "TOPSubscribeModel.h"
NS_ASSUME_NONNULL_BEGIN
 
@interface TOPSubscribeCell : GKCycleScrollViewCell
@property (nonatomic ,strong)UIImageView * imgV;
@property (nonatomic ,strong)UIImageView * iconImgV;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)TOPSubscribeModel * model;
@end

NS_ASSUME_NONNULL_END
