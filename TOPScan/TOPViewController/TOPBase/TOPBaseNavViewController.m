#import "TOPBaseNavViewController.h"
#import "TOPHomeViewController.h"
#import "TOPScreenShotView.h"
#import "TOPHomeChildViewController.h"
#import "TOPSuggestionsVC.h"
#import "TOPSettingGeneralVC.h"
#import "TOPShareTypeView.h"
#import "TOPScreenshotHelper.h"
@interface TOPBaseNavViewController () 
@property (nonatomic ,strong)TOPHomeViewController * homeVC;
@property (nonatomic ,strong)TOPScreenShotView * shotView;
@property (nonatomic ,strong)TOPShareTypeView * shareAction;
@property (nonatomic ,copy)NSString * shotUrl;//分享时的url
@property (nonatomic ,strong)UIImage * shotImg;
@property (nonatomic ,strong)DocumentModel *saveModel;//保留进入TOPHomeChildViewController之前单利模型数据
@end

@implementation TOPBaseNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (BOOL)shouldAutorotate{
    return [TOPDocumentHelper top_getInterfaceOrientationState];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

@end
