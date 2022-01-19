#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TOPShowScreenshotVC : TOPBaseChildViewController
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, copy) void (^top_showBackBlock)(void);
@end

NS_ASSUME_NONNULL_END
