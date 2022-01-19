#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPHomeTopMergeVC : TOPBaseChildViewController
@property (nonatomic ,strong) NSMutableArray * addDocArray;
@property (nonatomic ,copy) NSString * pathString;
@property (nonatomic ,strong) DocumentModel *docModel;//文档数据模型
@end

NS_ASSUME_NONNULL_END
