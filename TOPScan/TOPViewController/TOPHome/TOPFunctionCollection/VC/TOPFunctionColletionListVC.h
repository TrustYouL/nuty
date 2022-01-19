
#import "TOPBaseChildViewController.h"
#import "TOPFunctionColletionModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPFunctionColletionListVC : TOPBaseChildViewController
@property (nonatomic ,strong) DocumentModel *docModel;
@property (nonatomic ,copy)NSString * folderPath;
@property (nonatomic ,strong)TOPFunctionColletionModel * selectModel;
@property (nonatomic ,copy)void(^top_backActionBlock)(void);
@end

NS_ASSUME_NONNULL_END
