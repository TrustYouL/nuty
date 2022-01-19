#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPHomeShowView : UIView
@property (nonatomic ,strong)NSArray * dataArray;
@property (nonatomic ,strong)NSArray * iconArray;
@property (nonatomic ,assign)TOPHomeShowViewLocationType showType;
@property (nonatomic ,copy)void(^top_clickCellAction)(NSInteger row); 
@property (nonatomic ,copy)void(^top_clickDismiss)(void);
@property (nonatomic ,copy)void(^top_clickTagsCell)(TOPTagsListModel *model);
@property (nonatomic ,copy)void(^top_clickTagsFooterBtn)(void);
@end

NS_ASSUME_NONNULL_END
