#import <UIKit/UIKit.h>
#import "TOPSettingFormatModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingShowViewCell : UITableViewCell
@property (nonatomic ,strong)TOPSettingFormatModel * model;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,strong)UIImageView *vipLogoView;

@end

NS_ASSUME_NONNULL_END
