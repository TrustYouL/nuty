#import "TOPLoadSelectDriveViewController.h"
#import "TOPSelectFileTypeViewController.h"
#import "TOPDriveSelectCollectionViewCell.h"
#import "TOPUploadFileDriveCollectionVC.h"

@interface TOPLoadSelectDriveViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic ,strong)NSMutableArray * dataArray;
@property (strong, nonatomic) UICollectionView *collectionView;
@end
@implementation TOPLoadSelectDriveViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.collectionView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_box", @""),NSLocalizedString(@"topscan_googledrive", @""),NSLocalizedString(@"topscan_onedrive" , @""),NSLocalizedString(@"topscan_dropbox", @"")]];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
        
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(top_dropBoxOpenSusess:) name:@"DropBoxOpenDrives" object:nil];
}

- (void)top_dropBoxOpenSusess:(NSNotificationCenter *)notification
{
    [self top_pushJumpSelectFileType:TOPDownLoadDataStyleStyleDropBox];
}
- (void)top_backHomeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

#pragma mark -- collectionView
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TOPDriveSelectCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPDriveSelectCollectionViewCell class])];
    }
    return _collectionView;
}

#pragma mark - CollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPDriveSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPDriveSelectCollectionViewCell class]) forIndexPath:indexPath];
    cell.titleSourseName = self.dataArray[indexPath.row];
    if (self.openDrivetype == TOPDriveOpenStyleTypeUpload) {
        cell.vipLogoView.hidden = [TOPPermissionManager top_enableByUploadFile];
    }
    WS(weakSelf);
    cell.top_didSelectDriveClickBlock = ^(NSString * _Nonnull titleName) {
        [weakSelf top_uploadDidSelectedDriveMothodWith:titleName];
    };
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSInteger itemW = (NSInteger)(CGRectGetWidth(self.view.frame)/2);
    CGFloat insetL = (CGRectGetWidth(self.view.frame)-itemW*2)/2;
    return  UIEdgeInsetsMake(10, insetL, 5, insetL);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger itemW = (NSInteger)(CGRectGetWidth(self.view.frame)/2);
    return CGSizeMake(itemW, 240);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (void)top_userUpGradeVip {
    if ([TOPAppTools needShowDiscountThemeView]) {
        [[TOPDiscountThemeView shareInstance] top_showDiscountTheme:@"20211123_year_sub"];
        return;
    }
    TOPSubscriptionPayListViewController *subscriptVC = [[TOPSubscriptionPayListViewController alloc] init];
    subscriptVC.closeType = TOPSubscriptOverCloseTypeDissmiss;
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:subscriptVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)top_uploadDidSelectedDriveMothodWith:(NSString *)titleSourseName
{
    if (![TOPPermissionManager top_enableByUploadFile] && self.openDrivetype == TOPDriveOpenStyleTypeUpload) {
        [self top_userUpGradeVip];
        return;
    }
    if ([titleSourseName isEqualToString:NSLocalizedString(@"topscan_box", @"")]) {
        BOXContentClient *client = [BOXContentClient defaultClient];
        if (client.user) {
            [self top_pushJumpSelectFileType:TOPDownLoadDataStyleStyleBox];
            
        }else{
            [self top_singnInDriveiCloud:titleSourseName];
        }
        
    }else if ([titleSourseName isEqualToString:NSLocalizedString(@"topscan_googledrive", @"")]) {
        [[FHGoogleLoginManager sharedInstance] checkGoogleAccountStateWithCompletion:^(FHGoogleAccountState state) {
            switch (state) {
                case FHGoogleAccountStateOnline:
                {
                    [self top_pushJumpSelectFileType:TOPDownLoadDataStyleDefaultGoogle];
                    
                }
                    break;
                case FHGoogleAccountStateHasKeyChain:
                {
                    [[FHGoogleLoginManager sharedInstance] autoLoginWithCompletion:^(GIDGoogleUser *user, NSError *error) {
                        if (error == nil && user)
                        {
                            [self top_pushJumpSelectFileType:TOPDownLoadDataStyleDefaultGoogle];
                        }
                    }];
                }
                    break;
                    
                default:
                    [self top_singnInDriveiCloud:titleSourseName];
                    break;
            }
        }];
        
    }else if ([titleSourseName isEqualToString:NSLocalizedString(@"topscan_onedrive" , @"")]) {
        ODClient *oneClient = [ODClient loadCurrentClient];
        
        if (oneClient) {
            
            [self top_pushJumpSelectFileType:TOPDownLoadDataStyleStyleOneDrice];
            
        }else{
            [self top_singnInDriveiCloud:titleSourseName];
            
        }
        
    }else if ([titleSourseName  isEqualToString:NSLocalizedString(@"topscan_dropbox", @"")]) {
        DBUserClient *dbClient = [DBClientsManager authorizedClient];
        
        if (dbClient.usersRoutes && dbClient.accessToken)
        {
            [self top_pushJumpSelectFileType:TOPDownLoadDataStyleStyleDropBox];
            
        }else{
            [self top_singnInDriveiCloud:titleSourseName];
            
        }
        
    }
}
- (void)top_singnInDriveiCloud:(NSString *)sourseName
{
    if ([sourseName isEqualToString:NSLocalizedString(@"topscan_box", @"")]) {
        BOXContentClient *client = [BOXContentClient defaultClient];
        [client authenticateWithCompletionBlock:^(BOXUser *user, NSError *error) {
            if (error == nil) {
                [self top_pushJumpSelectFileType:TOPDownLoadDataStyleStyleBox];
            }else {
                NSLog(@"授权失败");
            }
        }];
    }else if ([sourseName isEqualToString:NSLocalizedString(@"topscan_googledrive", @"")]) {
        [[FHGoogleLoginManager sharedInstance] startGoogleLoginWithCompletion:^(GIDGoogleUser *user, NSError *error) {
            if (user && error==nil) {
                [self top_pushJumpSelectFileType:TOPDownLoadDataStyleDefaultGoogle];
            }
        }];
    }else if ([sourseName isEqualToString:NSLocalizedString(@"topscan_onedrive" , @"")]) {
        [ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error){
            if (!error){
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self top_pushJumpSelectFileType:TOPDownLoadDataStyleStyleOneDrice];
                });
            }
            else{
            }
        }];
    }else if ([sourseName isEqualToString:NSLocalizedString(@"topscan_dropbox", @"")]) {
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:self
                                          openURL:^(NSURL *url) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }];
    }
}

- (void)top_pushJumpSelectFileType:(TOPDownLoadDataStyle)currentStyle
{
    if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
        TOPUploadFileDriveCollectionVC *fileDrive = [[TOPUploadFileDriveCollectionVC alloc] init];
        fileDrive.downloadFileSavePath = self.downloadFileSavePath;
        fileDrive.openDrivetype = self.openDrivetype;
        fileDrive.downloadFileType = self.downloadFileType;
        fileDrive.uploadDriveStyle =  currentStyle;
        fileDrive.docId =  self.docId;
        fileDrive.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:fileDrive animated:YES];
    }else{
        TOPSelectFileTypeViewController *selectFileVC = [[TOPSelectFileTypeViewController alloc] init];
        selectFileVC.uploadDriveStyle = currentStyle;
        selectFileVC.isSingleUpload = self.isSingleUpload;
        
        selectFileVC.uploadDatas = [NSMutableArray arrayWithArray:self.uploadDatas];
        selectFileVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:selectFileVC animated:YES];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
