#import "TOPConnectivityViewController.h"
#import "TOPProgressSlider.h"

@interface TOPConnectivityViewController ()<MCSessionDelegate,GADFullScreenContentDelegate>
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCPeerID *clientPeer;
@property (strong, nonatomic) NSProgress *progress;
@property (nonatomic ,strong) UIView *contentView;
@property (nonatomic ,strong) UIImageView *stateImageView;
@property (nonatomic ,strong) UIButton *doneBtn;
@property (nonatomic ,strong) UILabel *tipLab;
@property (nonatomic ,strong) UIImageView *tipLogo;
@property (nonatomic ,strong) UIView *tipContent;
@property (nonatomic ,strong) TOPProgressSlider *proSlider;
@property (nonatomic, strong) GADInterstitialAd *interstitial;

@property (nonatomic, assign) BOOL isDone;
@property (nonatomic, assign) BOOL isWriting;
@end

@implementation TOPConnectivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isDone = NO;
    self.isWriting = NO;
    self.title = self.isReceive ? NSLocalizedString(@"topscan_receivedata", @"") : NSLocalizedString(@"topscan_senddata", @"");
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self top_configNavBar];
    [self top_configContentView];
    self.session.delegate = self;
    [self top_startSendReceive];
    [self top_loadAdData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:kCommonGrayWhiteBgColor];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}
- (void)top_loadAdData{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![TOPPermissionManager top_enableByAdvertising]) {//展示广告
                    [self top_getInterstitialAd];//插页广告
                }
            });
        }];
    } else {
        if (![TOPPermissionManager top_enableByAdvertising]) {//展示广告
            [self top_getInterstitialAd];//插页广告
        }
    }
}
- (void)top_configNavBar {
    [self top_configBackItemWithSelector:@selector(top_goBackAction)];
}

- (void)top_goBackAction {
    if (self.isDone) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self top_noCompletedAlert];
    }
}

#pragma mark -- 未完成提示
- (void)top_noCompletedAlert {
    __weak typeof(self) weakSelf = self;
    NSString *msg = [NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"topscan_transferunfinished", @""), NSLocalizedString(@"topscan_stopexit", @"")];
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_exit", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [weakSelf.session disconnect];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)top_startSendReceive {
    if (!self.isReceive) {
        //这里利用数据源的方式来发送数据
        [self.proSlider top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
    } else {
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
    }
}

#pragma mark - MCSessionDelegate
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateNotConnected://未连接
        {
            if (!self.isWriting && !self.isDone) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }
            break;
        case MCSessionStateConnecting://连接中
            NSLog(@"连接中");
            break;
        case MCSessionStateConnected://连接完成
        {
            NSLog(@"sendreceive开始 -- %@",peerID.displayName);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.isReceive) {
                    [self top_sendResource];
                }
            });
        }
            break;
    }
}

#pragma mark -- 这里利用数据源的方式来发送数据
- (void)top_sendResource {
    //这里必须要用fileURLWithPath 用String会报错Unsupported resource type
    //压缩文件路径
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *zipFile = [TOPDocumentHelper top_getBelongTemporaryPathString:@"transferData.zip"];
        //传输的文件路径集合
        NSArray *dataPaths = @[[TOPDocumentHelper top_getDocumentsPathString], [TOPDocumentHelper top_getFoldersPathString], [TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString]];
        BOOL successed = [SSZipArchive customCreateZipFileAtPath:zipFile withFilesAtDirectorys:dataPaths withPassword:nil andProgressHandler:^(NSUInteger entryNumber, NSUInteger total) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat complete = entryNumber * 1.00;
                CGFloat all = total * 1.00;
                CGFloat rate = complete / all;
                [self.proSlider top_showProgress:rate withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
            });
        }];
        if (successed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.proSlider top_showProgress:0.0 withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
            });
            NSProgress *progress = [self.session sendResourceAtURL:[NSURL fileURLWithPath:zipFile] withName:[zipFile lastPathComponent] toPeer:[self.session.connectedPeers firstObject] withCompletionHandler:^(NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.proSlider top_showWithStatus:@"100%"];
                    [self top_transferCompleted];
                });
                if (error) {
                    NSLog(@"发送源数据发生错误：%@", [error localizedDescription]);
                } else {
                    NSLog(@"发送源数据完成");
                }
            }];
            self.progress = progress;
            [progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
        } else {
            NSLog(@"压缩源数据发生错误");
        }
    });
}

// 普通数据传输
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"普通数据%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

// 数据流传输
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    NSLog(@"数据流%@", peerID.displayName);
}

// 数据源传输开始
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    NSLog(@"数据传输开始");
    if (self.isReceive) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.proSlider top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_receiving", @"")]];
        });
        self.progress = progress;
        [progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
    }
}

// 数据传输完成回调
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(nullable NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.proSlider top_showWithStatus:@"100%"];
    });
    if (error) {
        NSLog(@"数据传输结束%@----%@", localURL.absoluteString, error);
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
        });
        self.isWriting = YES;
        [self top_resourceHandlerAtURL:localURL];
        self.isWriting = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self top_transferCompleted];
        });
    }
}

- (void)top_transferCompleted {
    self.isDone = YES;
    self.doneBtn.hidden = NO;
    self.tipContent.hidden = YES;
    if (self.interstitial) {//传输完成弹出插页广告
        [self.interstitial presentFromRootViewController:self];
    }
}

- (void)top_resourceHandlerAtURL:(NSURL *)localURL {
    NSString *destinationPath = [TOPDocumentHelper top_getBelongTemporaryPathString:@"transferData.zip"];
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    //判断文件是否存在，存在则删除
    if ([TOPWHCFileManager top_isExistsAtPath:destinationPath]) {
        [TOPWHCFileManager top_removeItemAtPath:destinationPath];
    }
    //转移文件
    NSError *error1 = nil;
    if (![[NSFileManager defaultManager] moveItemAtURL:localURL toURL:destinationURL  error:&error1]) {
        NSLog(@"移动文件出错：error = %@", error1.localizedDescription);
    } else {
        NSString *unzipPath = [TOPDocumentHelper top_getBelongTemporaryPathString:@"fileData"];
        //判断文件是否存在，存在则删除
        if ([TOPWHCFileManager top_isExistsAtPath:unzipPath]) {
            [TOPWHCFileManager top_removeItemAtPath:unzipPath];
        }
        [TOPWHCFileManager top_createDirectoryAtPath:unzipPath];
        [SSZipArchive unzipFileAtPath:destinationPath toDestination:unzipPath overwrite:YES password:nil progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat complete = entryNumber * 1.00;
                CGFloat all = total * 1.00;
                CGFloat rate = complete / all;
                [[TOPProgressStripeView shareInstance] top_showProgress:rate withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
            });
        } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
            });
            if (succeeded) {
                [self top_writeFileDataToAppBox:unzipPath];
            }
        }];
    }
}

#pragma mark -- 把接收的文件数据写入到应用沙盒并显示
- (void)top_writeFileDataToAppBox:(NSString *)filePath {
    NSMutableArray *docData = @[].mutableCopy;
    NSMutableArray *fldData = @[].mutableCopy;
    NSMutableArray *tagData = @[].mutableCopy;
    
    NSArray *tempFileArrays = [TOPWHCFileManager top_listFilesInDirectoryAtPath:filePath deep:NO];
    for (NSString *fileName in tempFileArrays) {
        if ([fileName isEqualToString:@"Documents"]) {
            NSString *path = [filePath stringByAppendingPathComponent:fileName];
            NSString *newPath = [TOPDocumentHelper top_getDocumentsPathString];
            NSArray *tempContentsArray = [TOPDocumentHelper top_getCurrentFileAndPath:path];
            for (NSString *tempContentPath in tempContentsArray) {
                NSString *oldContentPath = [path stringByAppendingPathComponent:tempContentPath];
                NSString *newContentPath = [newPath stringByAppendingPathComponent:tempContentPath];
                newContentPath = [TOPDocumentHelper top_createDirectoryAtPath:newContentPath];
                [TOPDocumentHelper top_removeDocPassword:oldContentPath];
                [TOPDocumentHelper top_moveFileItemsAtPath:oldContentPath toNewFileAtPath:newContentPath];
                [docData addObject:newContentPath];
            }
        } else if ([fileName isEqualToString:@"Folders"]) {
            NSString *path = [filePath stringByAppendingPathComponent:fileName];
            NSString *newPath = [TOPDocumentHelper top_getFoldersPathString];
            NSArray *tempContentsArray = [TOPDocumentHelper top_getCurrentFileAndPath:path];
            for (NSString *tempContentPath in tempContentsArray) {
                NSString *oldContentPath = [path stringByAppendingPathComponent:tempContentPath];
                NSString *newContentPath = [newPath stringByAppendingPathComponent:tempContentPath];
                [TOPDocumentHelper top_removePasswordOfFolder:oldContentPath];
                newContentPath = [TOPDocumentHelper top_createDirectoryAtPath:newContentPath];
                [TOPDocumentHelper top_moveFileItemsAtPath:oldContentPath toNewFileAtPath:newContentPath];
                [fldData addObject:newContentPath];
            }
        } else if ([fileName isEqualToString:@"Tags"]) {
            NSString *tempCreatPath = [TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString];
            NSString *tempTags = [filePath stringByAppendingPathComponent:fileName];
            NSMutableArray *folderList = [TOPDocumentHelper top_getCurrentFileAndPath:tempTags];
            NSMutableArray  *oldDocumentArrays=  [TOPDocumentHelper top_getCurrentFileAndPath:tempCreatPath];
            for (NSString *oldFileName in folderList) {
                if (![oldDocumentArrays containsObject:oldFileName]) {
                    NSString *newTagPath = [tempCreatPath stringByAppendingPathComponent:oldFileName];
                    newTagPath = [TOPDocumentHelper top_createDirectoryAtPath:newTagPath];
                    [tagData addObject:[TOPWHCFileManager top_fileNameAtPath:newTagPath suffix:YES]];
                }
            }
        }
    }
    
    NSMutableArray *fileData = @[].mutableCopy;
    [fileData addObject:fldData];
    [fileData addObject:docData];
    [fileData addObject:tagData];
    [TOPDBDataHandler top_restoreFileData:fileData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSProgress *progress = (NSProgress *)object;
        if (progress.fractionCompleted > 0) {
            NSString *status = self.isReceive ? [NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_receiving", @"")] : [NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_sending", @"")];
            [self.proSlider top_showProgress:progress.fractionCompleted withStatus:status];
        }
        if (progress.fractionCompleted == 1.0) {
            if (self.progress) {
                [progress removeObserver:self forKeyPath:@"completedUnitCount" context:nil];
                self.progress = nil;
            }
        }
    });
}

- (void)top_clickDoneBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)top_configContentView {
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.equalTo(self.view);
    }];
    
    [self.contentView addSubview:self.stateImageView];
    [self.stateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(46);
    }];
    
    self.proSlider = [[TOPProgressSlider alloc] init];
    [self.contentView addSubview:self.proSlider];
    [self.proSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.stateImageView.mas_bottom).offset(60);
        make.height.mas_equalTo(35);
        make.leading.equalTo(self.contentView).offset(87);
        make.trailing.equalTo(self.contentView).offset(-87);
    }];
    
    [self.contentView addSubview:self.doneBtn];
    [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stateImageView.mas_bottom).offset(118);
        make.centerX.equalTo(self.contentView);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(117);
    }];
    self.doneBtn.hidden = YES;
    
    [self.contentView addSubview:self.tipContent];
    [self.tipContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stateImageView.mas_bottom).offset(200);
        make.leading.equalTo(self.contentView).offset(50);
        make.trailing.equalTo(self.contentView).offset(-50);
        make.height.mas_equalTo(50);
    }];
    
    [self.tipContent addSubview:self.tipLogo];
    [self.tipLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.tipContent);
        make.size.mas_equalTo(CGSizeMake(22, 22));
        make.centerY.equalTo(self.tipContent);
    }];
    
    [self.tipContent addSubview:self.tipLab];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.tipLogo.mas_trailing).offset(9);
        make.trailing.equalTo(self.tipContent);
        make.centerY.equalTo(self.tipContent);
    }];
}
#pragma mark -- 插页广告
- (void)top_getInterstitialAd{
    WS(weakSelf);
    GADRequest *request = [GADRequest request];
    NSString * adID = @"ca-app-pub-3940256099942544/4411468910";
    adID = [TOPDocumentHelper top_interstitialAdID][5];
    [GADInterstitialAd loadWithAdUnitID:adID
                                request:request
                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
            [weakSelf top_getInterstitialAd];
        }else{
            weakSelf.interstitial = ad;
            weakSelf.interstitial.fullScreenContentDelegate = weakSelf;
        }
    }];
}
#pragma mark -- lazy
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:kCommonGrayWhiteBgColor];
    }
    return _contentView;
}

- (UIImageView *)stateImageView {
    if (!_stateImageView) {
        NSString *imgName = self.isReceive ? @"top_receiving_logo" : @"top_sending_logo";
        _stateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    }
    return _stateImageView;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(TOPScreenWidth - 75, 0, 60, 30)];
        [btn setTitle:@"OK" forState:UIControlStateNormal];
        [btn setTitleColor:kWhiteColor forState:UIControlStateNormal];
        [btn setBackgroundColor:kTopicBlueColor];
        btn.layer.cornerRadius = 17.5;
        [btn.titleLabel setFont:PingFang_R_FONT_(14)];
        [btn addTarget:self action:@selector(top_clickDoneBtn) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn = btn;
    }
    return _doneBtn;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kTabbarNormal];
        _tipLab.textAlignment = NSTextAlignmentNatural;
        _tipLab.font = PingFang_R_FONT_(13);
        _tipLab.numberOfLines = 0;
        _tipLab.text = NSLocalizedString(@"topscan_keepscreen", @"");
    }
    return _tipLab;
}

- (UIView *)tipContent {
    if (!_tipContent) {
        _tipContent = [[UIView alloc] init];
        _tipContent.backgroundColor = [UIColor clearColor];
    }
    return _tipContent;
}

- (UIImageView *)tipLogo {
    if (!_tipLogo) {
        NSString *imgName = @"top_alert_gray";
        _tipLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    }
    return _tipLogo;
}

- (void)dealloc {
    // 关闭屏幕常亮，
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}
@end
