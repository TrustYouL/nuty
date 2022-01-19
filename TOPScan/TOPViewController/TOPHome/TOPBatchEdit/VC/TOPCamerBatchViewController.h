#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPCamerBatchViewController : TOPBaseChildViewController
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, copy) NSString * pathString;
@property (nonatomic, assign) NSInteger fileType;
@property (nonatomic, assign) TOPHomeChildViewControllerBackType backType;
@property (nonatomic, strong) DocumentModel *docModel;
@property (nonatomic, copy)void(^top_backAndReloadData)(void);
@end

NS_ASSUME_NONNULL_END
