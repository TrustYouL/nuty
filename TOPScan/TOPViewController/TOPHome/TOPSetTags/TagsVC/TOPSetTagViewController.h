#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPSetTagViewController : TOPBaseChildViewController
@property (nonatomic ,strong)NSMutableArray * dataArray;
@property (nonatomic ,copy)void(^top_saveFinishAction)(void);
@end

NS_ASSUME_NONNULL_END
