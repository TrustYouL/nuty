#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPRestoreViewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *driveImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *singnButton;
@property (weak, nonatomic) IBOutlet UILabel *lineview;

@property (nonatomic,copy) NSString *itemName;
@property (nonatomic,copy) NSString *singIn;
@property (nonatomic,copy) NSString *singOut;
@end

NS_ASSUME_NONNULL_END
