#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingCell : UITableViewCell
@property (nonatomic ,strong)UIView * backViewF;
@property (nonatomic ,strong)UIView * backViewS;
@property (nonatomic ,strong)UIView * backViewT;
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,strong)UIImageView * titleImg;
@property (nonatomic ,strong)UIImageView * rowImg;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)NSIndexPath * indexPath;
@property (nonatomic ,copy)NSDictionary * dic;
@end

NS_ASSUME_NONNULL_END
