#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPRemindSwitchCell : UITableViewCell
@property (nonatomic ,strong)UISwitch * switchBtn;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,assign)BOOL noticeState;
@property (nonatomic ,copy)void(^top_sendNoticeState)(BOOL noticeState); 
@end

NS_ASSUME_NONNULL_END
