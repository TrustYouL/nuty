#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface TOPBatchViewController : TOPBaseChildViewController
@property (nonatomic,strong)NSMutableArray * allBatchArray;
@property (nonatomic,strong)NSMutableArray * cameraArray;
@property (nonatomic,assign)NSInteger currentIndex;
@property (nonatomic,assign)TOPBatchCropType batchCropType;
@property (nonatomic,copy)void(^top_returnAndReloadData)(NSMutableArray * dataArray);
@end

NS_ASSUME_NONNULL_END
