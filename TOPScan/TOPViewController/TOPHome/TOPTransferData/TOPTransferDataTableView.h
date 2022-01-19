#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPTransferDataTableView : UITableView

@property (copy, nonatomic) NSArray *dataArray;
@property (nonatomic, copy) void(^top_didSelectItemBlock)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
