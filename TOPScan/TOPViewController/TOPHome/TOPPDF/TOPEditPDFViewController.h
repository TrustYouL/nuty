#import <UIKit/UIKit.h>
#import "TOPFunctionColletionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPEditPDFViewController : UIViewController
@property (copy, nonatomic) NSString *filePath;
@property (copy, nonatomic) NSArray *imagePathArr;
@property (nonatomic, strong) DocumentModel *docModel;
@property (copy, nonatomic) void(^top_backBtnAction)(void);
@property (copy, nonatomic) void(^top_editDocNameBlock)(NSString *path);
@property (nonatomic ,strong)TOPFunctionColletionModel * selectModel;
@property (nonatomic ,assign)BOOL backRefresh;
@end

NS_ASSUME_NONNULL_END
