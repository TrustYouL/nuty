#import "TOPBaseViewController.h"
#import "TOPCamerBatchViewController.h"
@interface TOPBaseViewController ()
@property (nonatomic, strong) TOPRoundedButton *rightBtn;
@property (nonatomic, strong) UIBarButtonItem *rightBarItem;
@end

@implementation TOPBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self top_defaultNavigationBar];
    if ([TOPDocumentHelper top_isdark]) {
        [UIApplication sharedApplication].windows[0].backgroundColor = TOPAppDarkBackgroundColor;
    }else{
        [UIApplication sharedApplication].windows[0].backgroundColor = [UIColor whiteColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
- (void)top_defaultNavigationBar {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAPPGreenColor];
    self.navigationController.navigationBarHidden = NO;
    [self top_adaptationSystemUpgrade];
}
#pragma mark -- 适配系统更新
- (void)top_adaptationSystemUpgrade {
    NSDictionary *textAtt = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    if (@available(iOS 15.0, *)){
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAPPGreenColor];
        appearance.titleTextAttributes = textAtt;
        appearance.shadowColor = [UIColor clearColor];
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.standardAppearance = appearance;
    } else {
        [self.navigationController.navigationBar setTitleTextAttributes:textAtt];
    }
}

- (UIButton*)rightBtn{
    if (!_rightBtn) {
       _rightBtn = [[TOPRoundedButton alloc] initWithFrame:CGRectMake(0, 0, (52), 44)];
        [_rightBtn setTitleColor:kMainBlueTextColor forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        _rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    }
    return _rightBtn;
}
- (UIBarButtonItem*)rightBarItem{
    if (!_rightBarItem) {
        _rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
    }
    return _rightBarItem;
}

- (void)top_addRightButtonItem:(nullable NSString *)title Image:(nullable UIImage *)image WithSelector:(SEL)selector {
    [self.rightBtn setImage:image forState:UIControlStateNormal];
    [self.rightBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.rightBtn setTitle:title forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = self.rightBarItem;
}
- (void)top_addRightCameraButtonItemWithSelector:(SEL)selector{
    UIBarButtonItem *rightButtonItemSec = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:selector];
    self.navigationItem.rightBarButtonItem = rightButtonItemSec;
}

- (void)top_initBackButton:(SEL)selector{
    TOPImageTitleButton * btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
    btn.frame = CGRectMake(0, 0, 44, 60);
    if (isRTL()) {
        [btn setImage:[UIImage imageNamed:@"top_RTLbackItem"] forState:UIControlStateNormal];
        btn.style = EImageLeftTitleRightCenter;
    }else{
        [btn setImage:[UIImage imageNamed:@"top_backItem"] forState:UIControlStateNormal];
        btn.style = EImageLeftTitleRightLeft;
    }
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

- (void)top_initCancleBackBtn:(SEL)selector {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, (52), 44)];
     [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 25)];
    [btn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    [btn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [btn.titleLabel setFont:PingFang_M_FONT_(16)];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

- (BOOL)shouldAutorotate{
    return [TOPDocumentHelper top_getInterfaceOrientationState];
}

@end
