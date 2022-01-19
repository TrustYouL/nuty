#import <UIKit/UIKit.h>
#import "TOPSettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPScanDarkSystemCell : UITableViewCell
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UILabel * contentLab;
@property (nonatomic ,strong)TOPSettingModel * model;
@property (nonatomic ,strong)UISwitch * switchBtn;
@property (nonatomic ,copy)void(^top_switchBtnAction)(BOOL switchOn); 
@end

NS_ASSUME_NONNULL_END
