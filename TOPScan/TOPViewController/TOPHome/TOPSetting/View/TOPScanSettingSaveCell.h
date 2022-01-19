#import <UIKit/UIKit.h>
#import "TOPSettingModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPScanSettingSaveCell : UITableViewCell
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UILabel * contentLab;
@property (nonatomic ,strong)UIImageView * saveImg;
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,strong)TOPSettingModel * model;
@property (nonatomic ,strong)UISwitch * switchBtn;

@end

NS_ASSUME_NONNULL_END
