#import <UIKit/UIKit.h>
#import "TOPBaseChildViewController.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^top_DismissBlock)(void);

@interface TOPCameraShowViewController : TOPBaseChildViewController
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, copy) void (^top_showBackBlock)(NSMutableArray * imageArray);
@end

NS_ASSUME_NONNULL_END
