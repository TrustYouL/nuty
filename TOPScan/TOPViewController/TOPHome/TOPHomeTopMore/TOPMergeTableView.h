#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPMergeTableView : UITableView
@property (nonatomic, copy) void(^top_pushNextControllerHandler)(DocumentModel * model);
@property (nonatomic, copy) void(^top_longPressCheckItemHandler)(NSInteger index, BOOL selected);
@property (nonatomic, copy) void(^top_longPressCalculateSelectedHander)(void);
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, assign) BOOL isMerge;
@end

NS_ASSUME_NONNULL_END
