#import "TOPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPNextFolderViewController : TOPBaseViewController
@property (nonatomic ,strong) DocumentModel *docModel;
@property (nonatomic ,copy)NSString * pathString;
@property (nonatomic ,strong)NSMutableArray * homeArray;
- (void)top_CancleSelectAction;
- (void)top_LoadSanBoxData:(NSInteger)type;
@end

NS_ASSUME_NONNULL_END
