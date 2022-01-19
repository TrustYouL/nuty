#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPHomeChildBatchViewController : TOPBaseChildViewController
@property (nonatomic,strong)NSMutableArray * dataArray;
@property (nonatomic,assign)BOOL isAllData;
@property (nonatomic,copy) NSString *addType;
@property (nonatomic,copy) NSString *childVCPath;
@property (nonatomic,copy)void(^top_dataChangeAndLoadData)(void);
@property (nonatomic,assign)BOOL isCollectionBox;
@end

NS_ASSUME_NONNULL_END
