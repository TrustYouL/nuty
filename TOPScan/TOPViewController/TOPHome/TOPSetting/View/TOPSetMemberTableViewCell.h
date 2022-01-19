#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSetMemberTableViewCell : UITableViewCell
@property (nonatomic ,strong)UIView * bgView;
@property (nonatomic ,strong)UIButton * buyNumberButton;
@property (nonatomic ,strong)UIImageView * rowImg;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,copy)NSDictionary * dic;
@end

NS_ASSUME_NONNULL_END
