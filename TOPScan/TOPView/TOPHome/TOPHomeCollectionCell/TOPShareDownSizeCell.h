#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPShareDownSizeCell : UITableViewCell
@property (nonatomic ,strong)UIView * backViewF;
@property (nonatomic ,strong)UIView * backViewS;
@property (nonatomic ,strong)UIView * backViewT;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UILabel * numberLab;
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,assign)NSInteger row;
@property (nonatomic ,strong)NSMutableArray * dataSourceArray;
@end

NS_ASSUME_NONNULL_END
