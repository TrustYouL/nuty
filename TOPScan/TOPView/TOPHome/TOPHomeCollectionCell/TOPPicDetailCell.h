#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPicDetailCell : UITableViewCell
@property (nonatomic ,copy)NSDictionary * picDic;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UILabel * contentLab;
@property (nonatomic ,strong)UIView * lineView;
@end

NS_ASSUME_NONNULL_END
