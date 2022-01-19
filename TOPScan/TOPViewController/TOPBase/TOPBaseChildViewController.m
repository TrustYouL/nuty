#import "TOPBaseChildViewController.h"

@interface TOPBaseChildViewController ()
@property (nonatomic, strong) TOPRoundedButton *rightBtn;
@property (nonatomic, strong) UIBarButtonItem *rightBarItem;
@property (nonatomic, assign) BOOL isBarStyle;
@end

@implementation TOPBaseChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout =  UIRectEdgeBottom;
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

- (void)top_defaultNavigationBar {
    [self.navigationController.navigationBar setTitleTextAttributes:
         @{NSForegroundColorAttributeName:[UIColor top_textColor:[UIColor whiteColor] defaultColor:TOPAPPGreenColor]}];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.navigationController.navigationBarHidden = NO;
    [self top_adaptationSystemUpgrade];
}
#pragma mark -- 适配系统更新
- (void)top_adaptationSystemUpgrade {
    NSDictionary *textAtt = @{NSForegroundColorAttributeName:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)],
                              NSFontAttributeName:[UIFont systemFontOfSize:18]};
    if (@available(iOS 15.0, *)){
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
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

- (void)top_addLeftButtonItem:(NSString *)title color:(UIColor *)color Image:(UIImage *)image WithSelector:(SEL)selector
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, (52), 44)];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateNormal];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

- (void)top_addRightCameraButtonItemWithSelector:(SEL)selector{
    UIBarButtonItem *rightButtonItemSec = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:selector];
    self.navigationItem.rightBarButtonItem = rightButtonItemSec;
}
- (void)top_initBackButton:(nullable NSString *)imgName withSelector:(SEL)selector{
    TOPImageTitleButton * btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
    btn.frame = CGRectMake(0, 0, 44, 60);
    if (isRTL()) {
        btn.style = EImageLeftTitleRightCenter;
    }else{
        btn.style = EImageLeftTitleRightLeft;
    }
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

- (void)top_configBackItemWithSelector:(SEL)selector {
    NSString *btnImg = isRTL() ? @"top_RTLbackItem" : @"top_backItem";
    [self top_initBackButton:btnImg withSelector:selector];
}

- (BOOL)shouldAutorotate{
    return [TOPDocumentHelper top_getInterfaceOrientationState];
}

@end
