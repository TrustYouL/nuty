#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPSettingCellModel;
@interface TOPSingleTextCell : UITableViewCell
@property (nonatomic ,strong) TOPSettingCellModel *model;
@property (nonatomic ,assign) BOOL separatorLine;

@end

NS_ASSUME_NONNULL_END
