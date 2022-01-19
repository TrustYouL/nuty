#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPBinImageBrowseViewController : TOPBaseChildViewController
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, copy) void(^top_deleteAllDataBlock)(void);
@end

NS_ASSUME_NONNULL_END
