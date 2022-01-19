#import <UIKit/UIKit.h>
#import "TOPSettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPScanSettingCell : UITableViewCell
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UIView * centerLine;
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UILabel * contentLab;
@property (nonatomic ,strong)NSIndexPath * indexPath;
@property (nonatomic ,strong)TOPSettingModel * model;
@end

NS_ASSUME_NONNULL_END
