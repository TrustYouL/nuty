#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPActionCell : UITableViewCell
@property (nonatomic ,strong)UIView * backViewF;
@property (nonatomic ,strong)UIView * backViewS;
@property (nonatomic ,strong)UIView * backViewT;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,assign)NSInteger row;
@property (nonatomic ,assign)NSInteger drawIndex;
@property (nonatomic ,strong)NSMutableArray * titleArray;
@end

NS_ASSUME_NONNULL_END
