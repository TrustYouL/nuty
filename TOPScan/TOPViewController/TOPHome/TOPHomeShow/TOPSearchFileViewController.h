#import "TOPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPSearchFileViewController : TOPBaseViewController
@property (nonatomic ,copy) NSString * pathString;
@property (nonatomic, strong) DocumentModel *fatherDocModel;
@end

NS_ASSUME_NONNULL_END
