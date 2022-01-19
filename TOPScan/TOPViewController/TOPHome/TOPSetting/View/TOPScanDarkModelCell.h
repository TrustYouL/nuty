#import <UIKit/UIKit.h>
#import "TOPSettingModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPScanDarkModelCell : UITableViewCell
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,strong)UILabel * contentLab;
@property (nonatomic ,strong)TOPSettingModel * model;

@end

NS_ASSUME_NONNULL_END
