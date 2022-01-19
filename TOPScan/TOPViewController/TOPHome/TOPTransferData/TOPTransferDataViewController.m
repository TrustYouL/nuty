#import "TOPTransferDataViewController.h"
#import "TOPTransferDataTableView.h"
#import "TOPSearchDevicesView.h"
#import "TOPTransferModel.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "TOPConnectorView.h"
#import "TOPConnectivityViewController.h"
#import "TOPTransferNativeAdView.h"

static NSString * const ServiceType = @"nearByContent";

@interface TOPTransferDataViewController ()<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate,GADAdLoaderDelegate,GADNativeAdLoaderDelegate>
@property (nonatomic ,strong) UILabel *titleLab;
@property (nonatomic ,strong) UILabel *tipLab;
@property (nonatomic ,strong) UILabel *tip2Lab;
@property (nonatomic ,strong) UILabel *tip3Lab;
@property (nonatomic ,strong) UIView *contentView;
@property (nonatomic ,strong) TOPConnectorView *connectorView;//发送方
@property (nonatomic ,strong) TOPConnectorView *receiveConnectorView;//接收方
@property (nonatomic ,strong) TOPSearchDevicesView *searchingView;
@property (nonatomic ,strong) TOPTransferDataTableView *tableView;
@property (nonatomic ,strong) NSMutableArray *devicesDataArray;
@property (nonatomic ,strong) NSMutableArray *offLineDevices;
@property (nonatomic ,strong) GADAdLoader *adLoader;//原生广告
@property (nonatomic ,strong) GADNativeAd * adModel;//广告model
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCPeerID *clientPeer;//接收方
@property (nonatomic, strong) MCPeerID *sendPeer;//发送方
@property (nonatomic, assign) BOOL isReceive;//接收方
@property (strong, nonatomic) NSProgress *progress;
@property (nonatomic, strong) TOPTransferNativeAdView * adView;
@end

@implementation TOPTransferDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"topscan_transferdata", @"");
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self top_configNavBar];
    [self top_configContentView];
    [self top_refreshShowPeerList];
    [self top_nativeAdConditions];
    
    self.peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:kCommonGrayWhiteBgColor];
    [self startScan];
    [self top_startPush];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self top_configMCSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self top_stopPush];
    [self top_stopScan];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}

- (void)top_configNavBar {
    [self top_configBackItemWithSelector:@selector(top_goBackAction)];
}

- (void)top_goBackAction {
    [self top_disConnectInvite];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)takeExplain {
}

#pragma mark -- 刷新显示节点列表
- (void)top_refreshShowPeerList {
    NSMutableArray *dataSource = @[].mutableCopy;
    for (MCPeerID *peer in self.devicesDataArray) {
        TOPTransferModel *model = [[TOPTransferModel alloc] init];
        model.title = peer.displayName;
        model.peerId= peer;
        [dataSource addObject:model];
    }
    self.tableView.hidden = dataSource.count ? NO : YES;
    CGFloat Hei = dataSource.count * 44.0;
    if (!dataSource.count) {
        Hei = 44.0;
    }
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(Hei);
    }];
    self.tableView.dataArray = dataSource;
    [self.tableView reloadData];
}

#pragma mark -- 创建会话
- (void)top_configMCSession {
    self.session = [[MCSession alloc] initWithPeer:self.peerID];
    self.session.delegate = self;
}

#pragma mark -- 开始扫描
- (void)startScan {
    NSLog(@"开始扫描");
    [self.browser startBrowsingForPeers];
}

#pragma mark -- 结束扫描
- (void)top_stopScan {
    NSLog(@"结束扫描");
    [self.browser stopBrowsingForPeers];
}

#pragma mark -- 开启广播
- (void)top_startPush {
    NSLog(@"开启广播");
    [self.advertiser startAdvertisingPeer];
}

#pragma mark -- 关闭广播
- (void)top_stopPush {
    NSLog(@"关闭广播");
    [self.advertiser stopAdvertisingPeer];
}

#pragma mark -- 发出连接邀请
- (void)top_invitePeer {
    BOOL offLine = NO;
    for (MCPeerID *peer in self.offLineDevices) {
        if ([peer.displayName isEqualToString:self.clientPeer.displayName]) {
            offLine = YES;
            break;
        }
    }
    if (!offLine) {
        self.isReceive = NO;
        [self.browser invitePeer:self.clientPeer toSession:self.session withContext:nil timeout:120];
    } else {
        [[TOPCornerToast shareInstance] makeToast:@"off-line"];
    }
}

#pragma mark -- 取消连接邀请
- (void)top_cancelConnectInvite {
    [self.browser invitePeer:self.clientPeer toSession:self.session withContext:[@"cancelConnect" dataUsingEncoding:NSUTF8StringEncoding] timeout:120];
}

//接收方
#pragma mark -- 拒绝连接邀请
- (void)top_refusedConnectInvite {
    [self.browser invitePeer:self.sendPeer toSession:self.session withContext:[@"Refused" dataUsingEncoding:NSUTF8StringEncoding] timeout:120];
}

#pragma mark -- 收到邀请反馈
- (void)top_feedbackConnectInvite {
    [self.browser invitePeer:self.sendPeer toSession:self.session withContext:[@"feedback" dataUsingEncoding:NSUTF8StringEncoding] timeout:120];
}

#pragma mark -- 离线
- (void)top_disConnectInvite {
    for (MCPeerID *peer in self.devicesDataArray) {
        [self.browser invitePeer:peer toSession:self.session withContext:[@"disConnect" dataUsingEncoding:NSUTF8StringEncoding] timeout:120];
    }
}

#pragma mark -- 发送方连接器
- (void)top_showSendConnectView {
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    __weak typeof(self) weakSelf = self;
    TOPConnectorView *Connector = [[TOPConnectorView alloc] initWithTitle:NSLocalizedString(@"topscan_cancel", @"") role:YES cancelBlock:^{
        [weakSelf top_cancelConnectInvite];
        weakSelf.connectorView = nil;
    } completeBlock:^{
    }];
    [window addSubview:Connector];
    [Connector mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(window);
    }];
    Connector.peerId = self.clientPeer.displayName;
    self.connectorView = Connector;
}

- (void)top_hiddenSendConnectView {
    if (_connectorView) {
        [self.connectorView top_dismissView];
        self.connectorView = nil;
    }
}

#pragma mark -- 接收方连接器
- (void)top_showReceiveConnectViewWithInvitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler  {
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    __weak typeof(self) weakSelf = self;
    TOPConnectorView *Connector = [[TOPConnectorView alloc] initWithTitle:@"接收数据" role:NO cancelBlock:^{
        invitationHandler(NO, weakSelf.session);
    } completeBlock:^{
        invitationHandler(YES, weakSelf.session);
    }];
    [window addSubview:Connector];
    [Connector mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(window);
    }];
    Connector.peerId = self.sendPeer.displayName;
    self.receiveConnectorView = Connector;
}

- (void)top_hiddenReceiveConnectViewWithInvitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler {
    [self top_receiveConnectViewDismiss];
    invitationHandler(NO, self.session);
}

- (void)top_receiveConnectViewDismiss {
    if (_receiveConnectorView) {
        [self.receiveConnectorView top_dismissView];
        self.receiveConnectorView = nil;
    }
}

#pragma mark -- 拒绝邀请弹窗
- (void)top_refusedAlert {
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"topscan_trylater", @""), self.clientPeer.displayName];
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_busy", @"")
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 去掉下线设备
- (void)top_onLinePeer:(MCPeerID *)peerID {
    for (MCPeerID *offPeer in self.offLineDevices.reverseObjectEnumerator) {
        if ([offPeer.displayName isEqualToString:peerID.displayName]) {
            [self.offLineDevices removeObject:offPeer];
        }
    }
}

#pragma mark - MCNearbyServiceBrowserDelegate

// 发现了附近的广播节点
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID
withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info {
    NSLog(@"发现了节点：%@ -- info =%@", peerID.displayName, info);
    NSMutableSet *set = [[NSMutableSet alloc] init];
    for (MCPeerID *peer in self.devicesDataArray) {
        [set addObject:peer.displayName];
    }
    [set addObject:peerID.displayName];
    if (set.count > self.devicesDataArray.count) {
        [self.devicesDataArray addObject:peerID];
        [self top_onLinePeer:peerID];
        [self top_refreshShowPeerList];
    }
}

// 广播节点丢失
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"丢失了节点：%@", peerID.displayName);//移除节点
    [self.devicesDataArray removeObject:peerID];
    [self top_refreshShowPeerList];
}

// 搜索失败回调
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    [browser stopBrowsingForPeers];
    NSLog(@"搜索出错：%@", error.localizedDescription);
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

// 收到节点邀请回调
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(nullable NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler {
    if (!context) {
        //只有发送者发出邀请，接收者接收邀请
        NSLog(@"收到%@节点的连接请求", peerID.displayName);
        self.sendPeer = peerID;
        if (!self.session.connectedPeers.count) {//没有连接对象
            self.isReceive = YES;
            [self top_feedbackConnectInvite];
            [self top_showReceiveConnectViewWithInvitationHandler:invitationHandler];
        } else {//已经有了连接对象,拒绝连接
            [self top_refusedConnectInvite];
        }
    } else {
        NSLog(@"收到%@节点的取消连接", peerID.displayName);
        NSString *contextStr = [[NSString alloc] initWithData:context encoding:NSUTF8StringEncoding];
        if ([contextStr isEqualToString:@"cancelConnect"]) {
            [self top_hiddenReceiveConnectViewWithInvitationHandler:invitationHandler];
        } else if ([contextStr isEqualToString:@"Refused"]) {
            [self top_refusedAlert];
        } else if ([contextStr isEqualToString:@"feedback"]) {
            [self top_showSendConnectView];
        } else if ([contextStr isEqualToString:@"disConnect"]) {
            [self.offLineDevices addObject:peerID];
        }
    }
}

// 广播失败回调
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    [advertiser stopAdvertisingPeer];
    NSLog(@"%@节点广播失败", advertiser.myPeerID.displayName);
}

#pragma mark - MCSessionDelegate

// 会话状态改变回调
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateNotConnected://未连接
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self->_connectorView) {
                        [self top_cancelConnectInvite];
                    }
                    [self top_hiddenSendConnectView];
                });
            }
            NSLog(@"未连接");
            break;
        case MCSessionStateConnecting://连接中
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self top_hiddenSendConnectView];
                [self top_goToSendReceiveDataVC];
            });
        }
            NSLog(@"连接中");
            break;
        case MCSessionStateConnected://连接完成
        {
            NSLog(@"连接完成 -- %@",peerID.displayName);
        }
            break;
    }
}

- (void)session:(nonnull MCSession *)session didReceiveData:(nonnull NSData *)data fromPeer:(nonnull MCPeerID *)peerID {
    
}


- (void)session:(nonnull MCSession *)session didReceiveStream:(nonnull NSInputStream *)stream withName:(nonnull NSString *)streamName fromPeer:(nonnull MCPeerID *)peerID {
    
}

- (void)session:(nonnull MCSession *)session didFinishReceivingResourceWithName:(nonnull NSString *)resourceName fromPeer:(nonnull MCPeerID *)peerID atURL:(nullable NSURL *)localURL withError:(nullable NSError *)error {
    
}

- (void)session:(nonnull MCSession *)session didStartReceivingResourceWithName:(nonnull NSString *)resourceName fromPeer:(nonnull MCPeerID *)peerID withProgress:(nonnull NSProgress *)progress {
    
}


#pragma mark -- 跳转到接收/发送数据界面
- (void)top_goToSendReceiveDataVC {
    TOPConnectivityViewController *vc = [[TOPConnectivityViewController alloc] init];
    vc.session = self.session;
    vc.isReceive = self.isReceive;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)top_configContentView {
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.searchingView];
    [self.contentView addSubview:self.tableView];
    [self.contentView addSubview:self.tipLab];
    [self.contentView addSubview:self.tip2Lab];
    [self.contentView addSubview:self.tip3Lab];
    
    __weak typeof(self) weakSelf = self;
    self.tableView.top_didSelectItemBlock = ^(NSInteger index) {
        weakSelf.clientPeer = weakSelf.devicesDataArray[index];
        [weakSelf top_invitePeer];
    };
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.equalTo(self.view);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(15);
        make.trailing.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.contentView);
        make.height.mas_equalTo(36);
    }];
    self.titleLab.text = NSLocalizedString(@"topscan_availabledevice", @"");
    
    [self.searchingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(15);
        make.trailing.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.titleLab.mas_bottom).offset(0);
        make.height.mas_equalTo(44);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(15);
        make.trailing.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.titleLab.mas_bottom).offset(0);
        make.height.mas_equalTo(0);
    }];
    
    [self top_configTipLab];
}

- (void)top_configTipLab {
    UILabel *pot1 = [[UILabel alloc] init];
    pot1.textColor = kTabbarNormal;
    pot1.textAlignment = NSTextAlignmentNatural;
    pot1.font = PingFang_R_FONT_(11);
    pot1.text = @"*";
    [self.contentView addSubview:pot1];
    
    [pot1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).offset(46);
        make.leading.equalTo(self.contentView).offset(27);
        make.width.mas_equalTo(10);
    }];
    
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).offset(46);
        make.leading.equalTo(self.contentView).offset(37);
        make.centerX.equalTo(self.contentView);
    }];
    
    UILabel *pot2 = [[UILabel alloc] init];
    pot2.textColor = kTabbarNormal;
    pot2.textAlignment = NSTextAlignmentNatural;
    pot2.font = PingFang_R_FONT_(11);
    pot2.text = @"*";
    [self.contentView addSubview:pot2];
    
    [pot2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipLab.mas_bottom).offset(5);
        make.leading.equalTo(self.contentView).offset(27);
        make.width.mas_equalTo(10);
    }];
    
    [self.tip2Lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipLab.mas_bottom).offset(5);
        make.leading.equalTo(self.contentView).offset(37);
        make.centerX.equalTo(self.contentView);
    }];
    
    UILabel *pot3 = [[UILabel alloc] init];
    pot3.textColor = kTabbarNormal;
    pot3.textAlignment = NSTextAlignmentNatural;
    pot3.font = PingFang_R_FONT_(11);
    pot3.text = @"*";
    [self.contentView addSubview:pot3];
    
    [pot3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tip2Lab.mas_bottom).offset(5);
        make.leading.equalTo(self.contentView).offset(27);
        make.width.mas_equalTo(10);
    }];
    
    [self.tip3Lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tip2Lab.mas_bottom).offset(5);
        make.leading.equalTo(self.contentView).offset(37);
        make.centerX.equalTo(self.contentView);
    }];
}
#pragma mark -- 展示广告
- (void)top_showNativeAdView{
    [self.view addSubview:self.adView];
    self.adView.nativeAd = self.adModel;
    [self.adView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(280);
    }];
}
- (void)top_nativeAdConditions{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    [FIRAnalytics logEventWithName:@"ATTrackingManagerAuthorized" parameters:nil];
                }else{
                    [FIRAnalytics logEventWithName:@"ATTrackingManagerDenied" parameters:nil];
                }
                if (![TOPPermissionManager top_enableByAdvertising]) {//展示广告
                    [self top_getNativeAd];//原生广告
                }
            });
        }];
    } else {
        if (![TOPPermissionManager top_enableByAdvertising]) {//展示广告
            [self top_getNativeAd];//原生广告
        }
    }
}
#pragma mark -- 原生广告
- (void)top_getNativeAd{
    NSString * adID = @"ca-app-pub-3940256099942544/3986624511";
    adID = [TOPDocumentHelper top_nativeAdID][3];
    GADMultipleAdsAdLoaderOptions *multipleAdsOptions = [[GADMultipleAdsAdLoaderOptions alloc] init];
    multipleAdsOptions.numberOfAds = 1;
    
    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
    videoOptions.startMuted = YES ;
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:adID
                                       rootViewController:self
                                                  adTypes:@[kGADAdLoaderAdTypeNative]
                                                  options:@[multipleAdsOptions,videoOptions]];
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:[GADRequest request]];
}
- (void)adLoaderDidFinishLoading:(GADAdLoader *) adLoader {
    // The adLoader has finished loading ads, and a new request can be sent.
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error{
}
#pragma mark -- 获取原生广告成功
- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    [FIRAnalytics logEventWithName:@"homeView_nativeDidReceiveAd" parameters:nil];
    NSLog(@"nativeAd==%@ images==%@",nativeAd,nativeAd.images);
    self.adModel = nativeAd;
    [self top_showNativeAdView];
}
#pragma mark -- lazy
- (TOPTransferNativeAdView *)adView{
    if (!_adView) {
        _adView = [[TOPTransferNativeAdView alloc]initWithFrame:CGRectZero];
    }
    return _adView;
}
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = kTabbarNormal;
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.font = PingFang_R_FONT_(13);
    }
    return _titleLab;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.textColor = kTabbarNormal;
        _tipLab.textAlignment = NSTextAlignmentNatural;
        _tipLab.numberOfLines = 0;
        _tipLab.font = PingFang_R_FONT_(11);
        _tipLab.text = NSLocalizedString(@"topscan_directlyexport", @"");
    }
    return _tipLab;
}

- (UILabel *)tip2Lab {
    if (!_tip2Lab) {
        _tip2Lab = [[UILabel alloc] init];
        _tip2Lab.textColor = kTabbarNormal;
        _tip2Lab.textAlignment = NSTextAlignmentNatural;
        _tip2Lab.numberOfLines = 0;
        _tip2Lab.font = PingFang_R_FONT_(11);
        _tip2Lab.text = NSLocalizedString(@"topscan_turnonwifi", @"");
    }
    return _tip2Lab;
}

- (UILabel *)tip3Lab {
    if (!_tip3Lab) {
        _tip3Lab = [[UILabel alloc] init];
        _tip3Lab.textColor = kTabbarNormal;
        _tip3Lab.textAlignment = NSTextAlignmentNatural;
        _tip3Lab.numberOfLines = 0;
        _tip3Lab.font = PingFang_R_FONT_(11);
        _tip3Lab.text = NSLocalizedString(@"topscan_keepnear", @"");
    }
    return _tip3Lab;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:kCommonGrayWhiteBgColor];
    }
    return _contentView;
}

- (TOPSearchDevicesView *)searchingView {
    if (!_searchingView) {
        _searchingView = [[TOPSearchDevicesView alloc] init];
    }
    return _searchingView;
}

- (TOPTransferDataTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TOPTransferDataTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    }
    return _tableView;
}

- (NSMutableArray *)devicesDataArray {
    if (!_devicesDataArray) {
        _devicesDataArray = @[].mutableCopy;
    }
    return _devicesDataArray;
}
    
- (NSMutableArray *)offLineDevices {
    if (!_offLineDevices) {
        _offLineDevices = @[].mutableCopy;
    }
    return _offLineDevices;
}

- (MCNearbyServiceAdvertiser *)advertiser {
    if (!_advertiser) {
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:nil serviceType:ServiceType];
        _advertiser.delegate = self;
    }
    return _advertiser;
}

- (MCNearbyServiceBrowser *)browser {
    if (!_browser) {
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:ServiceType];
        _browser.delegate = self;
    }
    return _browser;
}

- (void)dealloc {
    // 关闭屏幕常亮，
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

@end
