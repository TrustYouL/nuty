#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSwithBackTapTableViewCell : UITableViewCell
@property (weak,nonatomic) IBOutlet UILabel *swithTitleLabel;
@property (weak,nonatomic) IBOutlet UILabel *lineView;
@property (nonatomic,copy) NSString *cellType;
@property (nonatomic,copy) NSString *swithName;
@property (weak,nonatomic) IBOutlet UISwitch *switchView;
@property (nonatomic,copy) void(^top_swichOpenOrCloseAppSafeBlock)(BOOL isOpen,NSString *currentItem);
@end

NS_ASSUME_NONNULL_END
