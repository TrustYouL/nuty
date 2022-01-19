#import "TOPPresentNavViewController.h"
#import "TOPScreenShotView.h"

@interface TOPPresentNavViewController ()
@property (nonatomic ,strong)TOPScreenShotView * shotView;
@property (nonatomic ,assign)BOOL isShot;

@end

@implementation TOPPresentNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isShot = YES;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (BOOL)shouldAutorotate{
    return [TOPDocumentHelper top_getInterfaceOrientationState];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
