#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPShowLongImageViewController : TOPBaseChildViewController
@property (nonatomic ,copy)NSString * showPath;
@property (nonatomic ,copy)NSString * pathString;
@property (nonatomic ,copy)void(^top_bankAndReloadData)(void);
@end

NS_ASSUME_NONNULL_END
