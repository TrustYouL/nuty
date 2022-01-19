#import <UIKit/UIKit.h>

@class TOPSubscriptModel;
NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingSubsciptInfoTableViewCell : UITableViewCell
@property (nonatomic ,strong)UIView * bgView;
@property (nonatomic ,strong)UIImageView * rowImg;
@property (nonatomic ,strong)UILabel * subscriptionPlanContentLab;
@property (nonatomic ,strong)UILabel * renewedDayContentLab;
@property (nonatomic ,strong)UILabel * automaticRenewalConetentLab;
@property (nonatomic ,strong)TOPSubscriptModel * subscriptInfoModel;
@property (nonatomic ,copy)void(^top_clickMoreDetailBlock)(void);
@end

NS_ASSUME_NONNULL_END
