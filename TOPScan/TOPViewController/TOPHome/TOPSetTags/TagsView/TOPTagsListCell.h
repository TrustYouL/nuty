
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPTagsListCell : UITableViewCell
@property (nonatomic,strong)TOPTagsListModel * model;
@property (nonatomic,strong)UILabel * titleLab;
@property (nonatomic,strong)UILabel * numLab;
@property (nonatomic,strong)UIView * lineView;
@end

NS_ASSUME_NONNULL_END
