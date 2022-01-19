#import <UIKit/UIKit.h>
#import "TOPFileTargetModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPFileTargetTableView : UITableView
@property (copy, nonatomic) NSArray *dataArray;
@property (assign, nonatomic) TOPFileTargetType fileTargetType;
@property (nonatomic, copy) void(^top_didSelectFileBlock)(TOPFileTargetModel *model);
@end

NS_ASSUME_NONNULL_END
