#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPSettingCellModel;
@interface TOPSingleSwitchCell : UITableViewCell
@property (nonatomic ,strong) TOPSettingCellModel *model;
@property (nonatomic ,assign) BOOL separatorLine;//分割线 YES：显示 NO：隐藏（默认）
@property (nonatomic ,copy)void(^top_changeSwitchValueBlock)(BOOL open);

@end

NS_ASSUME_NONNULL_END
