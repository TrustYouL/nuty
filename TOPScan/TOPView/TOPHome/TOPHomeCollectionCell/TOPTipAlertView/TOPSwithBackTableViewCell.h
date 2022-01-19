#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSwithBackTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *swithTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineView;
@property (nonatomic, copy) NSString *swithName;
@property (weak, nonatomic) IBOutlet UISwitch *switchView;
@end

NS_ASSUME_NONNULL_END
