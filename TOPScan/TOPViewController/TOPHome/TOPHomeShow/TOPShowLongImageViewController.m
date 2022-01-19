#import "TOPShowLongImageViewController.h"
#import "TOPImageBrowsingView.h"
#import "TOPPictureProcessTool.h"

@interface TOPShowLongImageViewController ()<UIDocumentInteractionControllerDelegate, UIScrollViewDelegate, TOPImageBrowsingViewDelegate>
@property (nonatomic,strong)UIDocumentInteractionController * document;
@property (nonatomic,strong)UIImageView *showImgView;
@property (nonatomic,strong)TOPImageBrowsingView *imgBrowsingView;
@property (nonatomic,assign)CGFloat imageH;

@end

@implementation TOPShowLongImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    _imageH = TOPScreenHeight-TOPNavBarAndStatusBarHeight;
    [self top_configContentView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self top_congfigNav];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
#pragma mark -- 导航栏
- (void)top_congfigNav {
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    [self top_addRightButtonItem:@"" Image:[UIImage imageNamed:@"top_savetext"] WithSelector:@selector(top_ShowLongImage_ShareImg:)];
    NSString *imageName = [TOPWHCFileManager top_fileNameAtPath:self.showPath suffix:YES];
    NSString *fileSize = [TOPDocumentHelper top_getFileMemorySize:self.showPath];
    UILabel *noClassLab = [[UILabel alloc] init];
    noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor];
    noClassLab.textAlignment = NSTextAlignmentCenter;
    noClassLab.font = PingFang_M_FONT_(18);
    noClassLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    noClassLab.text = [imageName stringByAppendingString:[NSString stringWithFormat:@"(%@)",fileSize]];
    self.navigationItem.titleView = noClassLab;
}
#pragma mark -- 视图内容
- (void)top_configContentView {
    NSData *imgData = [NSData dataWithContentsOfFile:self.showPath];
    if (imgData.length) {
        CGFloat maxData = 1024*1024*2.0;
        if (imgData.length > maxData) {
            [self top_handleLargerImage];
        } else {
            self.imgBrowsingView.mainImage = [UIImage imageWithContentsOfFile:self.showPath];
        }
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_creationfailed", @"")];
        [SVProgressHUD dismissWithDelay:1];
    }
}

#pragma mark -- 大图压缩显示
- (void)top_handleLargerImage {
    self.imgBrowsingView.highDefinition = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *showImg = [self top_clippingShowImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imgBrowsingView.mainImage = showImg;
        });
    });
}

- (UIImage *)top_clippingShowImage {
    NSData *imgData = [NSData dataWithContentsOfFile:self.showPath];
    UIImage *smallImg = [TOPPictureProcessTool top_scaleImageWithData:imgData withSize:CGSizeMake(TOPScreenWidth, _imageH)];
    return smallImg;
}

#pragma mark -- 返回
- (void)top_backHomeAction{
    if (self.top_bankAndReloadData) {
        self.top_bankAndReloadData();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)top_ShowLongImage_ShareImg:(UIButton *)sender{
    [FIRAnalytics logEventWithName:@"ShowLongImage_ShareImg" parameters:nil];
    NSMutableArray * pdfArray = [NSMutableArray new];
    NSURL * file = [NSURL fileURLWithPath:self.showPath];
    [pdfArray addObject:file];
    UIActivityViewController * activityVC = [[UIActivityViewController alloc]initWithActivityItems:pdfArray applicationActivities:nil];
    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    activityVC.excludedActivityTypes = excludedActivityTypes;
    if (IS_IPAD) {
        activityVC.popoverPresentationController.sourceView = self.view;
        activityVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark TOPImageBrowsingViewDelegate
- (void)top_imageBrowsingShowDidScrollZoom {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.imgBrowsingView top_resetHighImage:[UIImage imageWithContentsOfFile:self.showPath]];
    });
    
}

- (TOPImageBrowsingView *)imgBrowsingView {
    if (!_imgBrowsingView) {
        TOPImageBrowsingView *scrollView = [[TOPImageBrowsingView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight)];
        scrollView.browsingDelegate = self;
        [self.view addSubview:scrollView];
        _imgBrowsingView = scrollView;
    }
    return _imgBrowsingView;
}

- (void)dealloc {
    NSLog(@"showLongImage -- dealloc");
}

@end
