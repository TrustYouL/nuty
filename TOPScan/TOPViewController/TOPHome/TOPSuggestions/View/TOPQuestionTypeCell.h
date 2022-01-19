#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPQuestionTypeCell : UITableViewCell
@property (nonatomic ,strong)UIView * backView;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIImageView * showImg;
@property (nonatomic ,assign)BOOL selectState;
@end

NS_ASSUME_NONNULL_END
