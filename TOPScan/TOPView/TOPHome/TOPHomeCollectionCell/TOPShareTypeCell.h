#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPShareTypeCell : UITableViewCell
@property (nonatomic ,strong)UIView * backViewF;
@property (nonatomic ,strong)UIView * backViewS;
@property (nonatomic ,strong)UIView * backViewT;
@property (nonatomic ,strong)UIImageView * img;
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UILabel * numberLab;
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,assign)NSInteger row;
@property (nonatomic ,strong)NSMutableArray * titleArray;
@property (nonatomic ,strong)NSMutableArray * picArray;
@property (nonatomic ,strong)NSMutableArray * selectArray;
@property (nonatomic ,assign)TOPPopUpBounceViewType popType;
@property (nonatomic ,assign)BOOL showSectionHeader;
@end

NS_ASSUME_NONNULL_END
