#import <UIKit/UIKit.h>
#import "TOPBaseChildViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPSingleBatchViewController : TOPBaseChildViewController
@property (nonatomic ,strong)NSMutableArray * dataArray;
@property (nonatomic ,copy) NSArray * batchArray;
@property (nonatomic ,copy) NSString *pathString;
@property (nonatomic ,assign) NSInteger fileType;
@property (nonatomic ,assign) TOPHomeChildViewControllerBackType backType;
@property (nonatomic ,strong)DocumentModel * model;

@end

NS_ASSUME_NONNULL_END
