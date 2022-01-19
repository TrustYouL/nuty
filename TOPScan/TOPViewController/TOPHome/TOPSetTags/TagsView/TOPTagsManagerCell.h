#import <UIKit/UIKit.h>
#import "TOPTagsManagerModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPTagsManagerCell : UITableViewCell
@property (nonatomic,strong)UILabel * titleLab;
@property (nonatomic,strong)UILabel * numLab;
@property (nonatomic,strong)UIButton * editBtn;
@property (nonatomic,strong)UIView * lineView;
@property (nonatomic,strong)TOPTagsManagerModel * model;
@property (nonatomic,copy)void(^top_clickToEdit)(TOPTagsManagerModel * model);
@property (nonatomic,copy)void(^top_clickToBack)(TOPTagsManagerModel * model);

@end

NS_ASSUME_NONNULL_END
