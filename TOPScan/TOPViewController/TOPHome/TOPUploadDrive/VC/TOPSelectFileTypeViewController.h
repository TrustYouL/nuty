#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPSelectFileTypeViewController : TOPBaseChildViewController
@property(nonatomic,assign) TOPDownLoadDataStyle uploadDriveStyle;
@property (nonatomic, strong) NSMutableArray *uploadDatas;
@property (nonatomic, assign) BOOL isSingleUpload;
@end

NS_ASSUME_NONNULL_END
