#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPTagsManagerViewController : TOPBaseChildViewController
@property (nonatomic,strong)NSMutableArray * dataArray;
@property (nonatomic,strong)void(^top_clickTagManageBlock)(TOPTagsListModel * model);
@end

NS_ASSUME_NONNULL_END
