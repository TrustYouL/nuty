#import "TOPBaseChildViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPConnectivityViewController : TOPBaseChildViewController

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, assign) BOOL isReceive;

@end

NS_ASSUME_NONNULL_END
