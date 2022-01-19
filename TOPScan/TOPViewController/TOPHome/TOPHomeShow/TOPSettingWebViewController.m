#import "TOPSettingWebViewController.h"

@interface TOPSettingWebViewController ()<WKUIDelegate,WKNavigationDelegate>
@property (nonatomic ,strong)WKWebView * wkWebView;
@property (nonatomic ,strong)WKWebViewConfiguration * wkConfig;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIProgressView * progressView;
@end

@implementation TOPSettingWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }

    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLab.font = [UIFont boldSystemFontOfSize:18];
    titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1)];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.text = self.titleString;
    self.navigationItem.titleView = titleLab;
    self.titleLab = titleLab;

    [self.view addSubview:self.wkWebView];
    [self.view addSubview:self.progressView];

    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.mas_equalTo(2.0);
    }];
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self top_startLoad];
}

- (void)top_startLoad{
    NSURL * pathURL = [NSURL URLWithString:self.urlString] ;
    NSURLRequest * pathRequest = [NSURLRequest requestWithURL:pathURL];
    [self.wkWebView loadRequest:pathRequest];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [self top_startLoad];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.wkWebView.UIDelegate = nil;
    self.wkWebView.navigationDelegate = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (WKWebViewConfiguration *)wkConfig{
    if (!_wkConfig) {
        _wkConfig = [[WKWebViewConfiguration alloc]init];
        _wkConfig.allowsInlineMediaPlayback = YES;
        _wkConfig.allowsPictureInPictureMediaPlayback = YES;
    }
    return _wkConfig;
}

- (WKWebView *)wkWebView{
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight) configuration:self.wkConfig];
        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
        _wkWebView.scrollView.showsVerticalScrollIndicator = NO;
        _wkWebView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    }
    return _wkWebView;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 2)];
        _progressView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        _progressView.trackTintColor = [UIColor blackColor];
        _progressView.progressTintColor = TOPAPPGreenColor;
        _progressView.transform = CGAffineTransformMakeScale(1.0f, 1.2f);
    }
    return _progressView;
}

- (void)top_backHomeAction{
    [FIRAnalytics logEventWithName:@"top_backHomeAction" parameters:nil];
    [SVProgressHUD dismiss];
    [self.wkWebView stopLoading];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [FIRAnalytics logEventWithName:@"observeValueForKeyPath" parameters:nil];
    WS(weakSelf);
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.wkWebView.estimatedProgress;
        if (self.progressView.progress == 1) {
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0, 1.1);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if ([TOPDocumentHelper top_isdark]) {
        [self.wkWebView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= '#FFFFFF'" completionHandler:nil];
        [self.wkWebView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.background= '#000000'" completionHandler:nil];
    }
}

#pragma mark---delegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [FIRAnalytics logEventWithName:@"didStartProvisionalNavigation" parameters:nil];
    self.progressView.hidden = NO;
    self.progressView.transform = CGAffineTransformMakeScale(1.0, 1.2);
    [self.view bringSubviewToFront:self.progressView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [FIRAnalytics logEventWithName:@"didFinishNavigation" parameters:nil];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error{
    [FIRAnalytics logEventWithName:@"didFailProvisionalNavigation" parameters:nil];
    self.progressView.hidden = YES;
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    [self.wkWebView reload];
}

- (void)dealloc {
    [self top_cleanCacheAndCookie];
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}

-(void)top_cleanCacheAndCookie{
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
    }];
}


@end
