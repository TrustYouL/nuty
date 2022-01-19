#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPDriveSelectCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic)  UIImageView *coverImageView;
@property (strong, nonatomic)  UIButton *signStatesButton;
@property (strong, nonatomic)  UILabel *driveNameLabel;
@property (strong, nonatomic)  UILabel *emailTextLabel;
@property (nonatomic,copy) NSString *titleSourseName;
@property (strong, nonatomic)  UIImageView *vipLogoView;
@property (nonatomic,copy) void(^top_didSelectDriveClickBlock)(NSString * titleName);
@end

NS_ASSUME_NONNULL_END
