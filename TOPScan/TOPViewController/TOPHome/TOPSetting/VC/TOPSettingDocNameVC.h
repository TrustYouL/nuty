#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingDocNameVC : TOPBaseChildViewController
@property (nonatomic ,copy)void (^top_backAction)(NSString * formatString);
@end

NS_ASSUME_NONNULL_END
