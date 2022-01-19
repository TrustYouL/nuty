#import "TOPRestoreViewController.h"
#import "TOPRestoreViewTableViewCell.h"
#import "TOPScanSettingSaveCell.h"
#import "TOPReStoreListView.h"
#import "DriveDownloadManger.h"
#import "TOPDownProgressAlertView.h"
#import "TOPDriveSelectListView.h"
#import "TOPSwithBackTableViewCell.h"
#import "TOPCornerToast.h"
#import "TOPICloudStatesTableViewCell.h"

static NSString *itemCellInderfiler = @"itemCellInderfiler";
@interface TOPRestoreViewController ()<UITableViewDelegate,UITableViewDataSource,UIDocumentPickerDelegate>
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *itemArrays ;
@property (strong,nonatomic) NSMutableArray *setConetntArrays ;
@property (assign,nonatomic) NSInteger showProgressIdnex ;
@property (strong,nonatomic) TOPDownProgressAlertView *downProgressView;
@property (copy, nonatomic) NSString  *zipPath;
@end

@implementation TOPRestoreViewController
- (NSMutableArray *)itemArrays
{
    if (_itemArrays == nil) {
        _itemArrays = [NSMutableArray array];
    }
    return _itemArrays;
}
- (NSMutableArray *)setConetntArrays
{
    if (_setConetntArrays == nil) {
        _setConetntArrays = [NSMutableArray array];
    }
    return _setConetntArrays;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[UINavigationBar appearance] setTranslucent:NO];
    [self top_configLightBgDarkTitle];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.titleTextAttributes=
    @{NSForegroundColorAttributeName:[UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)],
      NSFontAttributeName:[UIFont systemFontOfSize:18]};
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    [self.tableView reloadData];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [self.tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[_tableView]|"
                               options:1.0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(_tableView)]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[_tableView]|"
                               options:1.0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(_tableView)]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TOPRestoreViewTableViewCell" bundle:nil] forCellReuseIdentifier:itemCellInderfiler];
    [self.tableView registerNib:[UINib nibWithNibName:@"TOPSwithBackTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingSaveCell"];
    
    [self.tableView registerClass:[TOPICloudStatesTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPICloudStatesTableViewCell class])];
    
    self.itemArrays = [NSMutableArray arrayWithArray:@[@"iCloud",NSLocalizedString(@"topscan_box", @""),NSLocalizedString(@"topscan_googledrive", @""),NSLocalizedString(@"topscan_onedrive" , @""),NSLocalizedString(@"topscan_dropbox", @"")]];
    self.setConetntArrays = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"topscan_restorebackwifi", @""),NSLocalizedString(@"topscan_addorginalfile", @"")]];
    
    self.view.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [TOPDocumentHelper top_getNetworkState];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(top_dropBoxOpenSusess:) name:@"DropBoxOpenDrives" object:nil];
    
    self.title = NSLocalizedString(@"topscan_backup", @"");
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    
}
- (void)top_dropBoxOpenSusess:(NSNotificationCenter *)notification
{
    [self.tableView reloadData];
}

#pragma mark - 返回按钮
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.itemArrays.count;
    }
    return self.setConetntArrays.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            TOPICloudStatesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPICloudStatesTableViewCell class]) forIndexPath:indexPath];
            return cell;
        }
        TOPRestoreViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemCellInderfiler forIndexPath:indexPath];
        cell.itemName = self.itemArrays[indexPath.row];
        cell.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        cell.lineview.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGB(240, 240, 240)];
        return cell;
    }
    TOPSwithBackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingSaveCell" forIndexPath:indexPath];
    NSString *currentValue = self.setConetntArrays[indexPath.row];
    cell.swithName = currentValue;
    cell.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    cell.lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGB(240, 240, 240)];
    cell.swithTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(180, 180, 180, 1.0)];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *footCustomView = [[UIView alloc] init];
        UIView *topCtenterview  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth,10)];
        [footCustomView addSubview:topCtenterview];
        topCtenterview.backgroundColor  = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:UIColorFromRGB(0xEFEFF4)];
        [topCtenterview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(footCustomView);
            make.trailing.equalTo(footCustomView);
            make.top.equalTo(footCustomView);
            make.height.mas_offset(10);
        }];
        
        UIButton *backupnowOne = [UIButton buttonWithType:UIButtonTypeCustom];
        [backupnowOne setTitle:NSLocalizedString(@"topscan_restorebackup", @"") forState:UIControlStateNormal];
        backupnowOne.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
        [backupnowOne setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [backupnowOne setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateHighlighted];
        [footCustomView addSubview:backupnowOne];
        [backupnowOne mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footCustomView);
            make.top.equalTo(topCtenterview.mas_bottom).offset(15);
            make.height.mas_offset(44);
            make.width.mas_offset(240);
        }];
        
        [backupnowOne addTarget:self action:@selector(top_backupNowClick:) forControlEvents:UIControlEventTouchUpInside];
        [backupnowOne setBackgroundImage:[UIImage imageNamed:@"top_rastore_n_back_s"] forState:UIControlStateHighlighted];
        backupnowOne.layer.cornerRadius = 5;
        backupnowOne.layer.borderColor = TOPAPPGreenColor.CGColor;
        backupnowOne.layer.borderWidth = 0.5;
        
        UILabel*  restoreTipsLab = [UILabel new];
        restoreTipsLab.lineBreakMode = NSLineBreakByTruncatingTail;
        restoreTipsLab.font = [UIFont systemFontOfSize:11];
        restoreTipsLab.textColor = RGBA(180, 180, 180, 1.0);
        restoreTipsLab.textAlignment = NSTextAlignmentCenter;
        restoreTipsLab.numberOfLines = 0;
        [footCustomView addSubview:restoreTipsLab];
        
        [restoreTipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footCustomView);
            make.top.equalTo(backupnowOne.mas_bottom).offset(1);
            NSString * backuplastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"backuplastDate"];
            if (backuplastDate.length>0) {
                make.height.mas_offset(30);
            }else{
                make.height.mas_offset(0);
            }
            make.width.mas_offset(CGRectGetWidth(self.view.frame)-30);
        }];
        
        NSString * backuplastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"backuplastDate"];
        if (backuplastDate.length>0) {
            [restoreTipsLab setText:[NSString stringWithFormat:@"(%@ %@)",NSLocalizedString(@"topscan_restorelastbackup", @""),backuplastDate]];
        }else{
            [restoreTipsLab setText:@""];
        }
        UIView *bottomCtenterView  = [[UIView alloc] init];
        [footCustomView addSubview:bottomCtenterView];
        bottomCtenterView.backgroundColor  = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:UIColorFromRGB(0xEFEFF4)];
        
        [bottomCtenterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footCustomView);
            make.top.equalTo(restoreTipsLab.mas_bottom).offset(10);
            make.height.mas_offset(10);
            make.leading.equalTo(footCustomView);
            make.trailing.equalTo(footCustomView);
        }];
        
        UIView *bottomSeletedOneView  = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(backupnowOne.frame), CGRectGetMaxY(bottomCtenterView.frame)+10, TOPScreenWidth-CGRectGetMinX(backupnowOne.frame)-20,30)];
        [footCustomView addSubview:bottomSeletedOneView];
        bottomSeletedOneView.backgroundColor  = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xFFFFFF)];
        
        [bottomSeletedOneView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bottomCtenterView.mas_bottom).offset(10);
            make.height.mas_offset(30);
            make.leading.equalTo(backupnowOne);
            make.trailing.equalTo(footCustomView).offset(-10);
        }];
        
        UIImageView *leftSelectView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_select_n_1"]];
        [bottomSeletedOneView addSubview:leftSelectView];
        leftSelectView.layer.cornerRadius = 7;
        leftSelectView.tag = section+122;
        
        [leftSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bottomSeletedOneView).offset(11);
            make.height.mas_offset(14);
            make.width.mas_offset(14);
            make.leading.equalTo(bottomSeletedOneView).offset(5);
        }];
        
        UILabel*  selectOneLab = [UILabel new];
        selectOneLab.font = [UIFont systemFontOfSize:12];
        selectOneLab.textColor = RGBA(180, 180, 180, 1.0);
        selectOneLab.tag = section+130;
        selectOneLab.textAlignment = NSTextAlignmentNatural;
        [selectOneLab setText:NSLocalizedString(@"topscan_restoremerge", @"")];
        [bottomSeletedOneView addSubview:selectOneLab];
        [selectOneLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bottomSeletedOneView).offset(5);
            make.height.mas_offset(25);
            make.leading.equalTo(bottomSeletedOneView).offset(25);
            make.trailing.equalTo(bottomSeletedOneView).offset(-10);
        }];
        
        UIButton *oneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        oneButton.tag = section+210;
        [oneButton addTarget:self action:@selector(top_selectClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomSeletedOneView addSubview:oneButton];
        
        [oneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bottomSeletedOneView);
            make.bottom.equalTo(bottomSeletedOneView);
            make.leading.equalTo(bottomSeletedOneView);
            make.trailing.equalTo(bottomSeletedOneView);
        }];
        
        UIView *bottomSeletedTwoView  = [[UIView alloc] init];
        [footCustomView addSubview:bottomSeletedTwoView];
        [bottomSeletedTwoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bottomSeletedOneView.mas_bottom).offset(10);
            make.height.mas_offset(30);
            make.leading.equalTo(backupnowOne);
            make.trailing.equalTo(footCustomView).offset(-10);
        }];
        
        bottomSeletedTwoView.backgroundColor  = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xFFFFFF)];
        UIImageView *leftSelectTwoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_select_n_1"]];
        [bottomSeletedTwoView addSubview:leftSelectTwoView];
        leftSelectTwoView.tag = section+150;
        
        [leftSelectTwoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bottomSeletedTwoView).offset(11);
            make.height.mas_offset(14);
            make.width.mas_offset(14);
            make.leading.equalTo(bottomSeletedTwoView).offset(5);
        }];
        
        UILabel*  selectOneTwoLab = [UILabel new];
        selectOneTwoLab.font = [UIFont systemFontOfSize:12];
        selectOneTwoLab.textColor = UIColorFromRGB(0x666666);
        selectOneTwoLab.textAlignment = NSTextAlignmentNatural;
        selectOneTwoLab.tag = section+160;
        
        [selectOneTwoLab setText:NSLocalizedString(@"topscan_restoredelete", @"")];
        [bottomSeletedTwoView addSubview:selectOneTwoLab];
        
        [selectOneTwoLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bottomSeletedTwoView).offset(5);
            make.height.mas_offset(25);
            make.leading.equalTo(bottomSeletedTwoView).offset(25);
            make.trailing.equalTo(bottomSeletedTwoView).offset(-10);
            
        }];
        
        UIButton *twoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        twoButton.tag = section+200;
        
        [twoButton addTarget:self action:@selector(top_selectClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomSeletedTwoView addSubview:twoButton];
        [twoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bottomSeletedTwoView);
            make.bottom.equalTo(bottomSeletedTwoView);
            make.leading.equalTo(bottomSeletedTwoView);
            make.trailing.equalTo(bottomSeletedTwoView);
        }];
        
        BOOL isRestoreOnly = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RestoreMerge"] boolValue];
        if (isRestoreOnly== NO) {
            leftSelectView.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
            leftSelectTwoView.image = [UIImage imageNamed:@"top_select_n_1"];
            selectOneLab.textColor = UIColorFromRGB(0xB4B4B4);
        }else{
            leftSelectView.image = [UIImage imageNamed:@"top_select_n_1"];
            leftSelectTwoView.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
            selectOneTwoLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x666666)];
        }
        
        UIButton *restoreOne = [UIButton buttonWithType:UIButtonTypeCustom];
        [restoreOne setTitle:NSLocalizedString(@"topscan_restoretitle", @"") forState:UIControlStateNormal];
        restoreOne.layer.cornerRadius = 3;
        restoreOne.clipsToBounds = YES;
        
        [restoreOne setBackgroundImage:[UIImage imageNamed:@"top_rastore_n_back_s"] forState:UIControlStateHighlighted];
        restoreOne.layer.cornerRadius = 5;
        restoreOne.layer.borderColor = TOPAPPGreenColor.CGColor;
        restoreOne.layer.borderWidth = 0.5;
        
        restoreOne.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
        [restoreOne setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [restoreOne setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [footCustomView addSubview:restoreOne];
        [restoreOne mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footCustomView);
            make.top.equalTo(bottomSeletedTwoView.mas_bottom).offset(10);
            make.height.mas_offset(44);
            make.width.mas_offset(240);
        }];
        
        [restoreOne addTarget:self action:@selector(top_restoreClick:) forControlEvents:UIControlEventTouchUpInside];
        UILabel*  bottomLab = [UILabel new];
        bottomLab.font = [UIFont systemFontOfSize:12];
        bottomLab.textColor = RGBA(180, 180, 180, 1.0);
        bottomLab.numberOfLines =0;
        bottomLab.textAlignment = NSTextAlignmentNatural;
        bottomLab.text = NSLocalizedString(@"topscan_backupbottomtitle", @"");
        [footCustomView addSubview:bottomLab];
        [bottomLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footCustomView);
            make.top.equalTo(restoreOne.mas_bottom).offset(5);
            make.height.mas_offset(50);
            make.width.mas_offset(240);
        }];
        return footCustomView;
    }else{
        UIView *bottomSeletedTwoView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth,10)];
        bottomSeletedTwoView.backgroundColor  = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:UIColorFromRGB(0xEFEFF4)];
        return bottomSeletedTwoView;
    }
    return nil;
}

- (void)top_selectClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 211:
        {
            UIImageView *selectOneView = [self.tableView viewWithTag:123];
            UIImageView *selectTwoView = [self.tableView viewWithTag:151];
            UILabel *selectOneLabel = [self.tableView viewWithTag:131];
            UILabel *selectTwoLabel = [self.tableView viewWithTag:161];
            selectOneView.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
            selectTwoView.image = [UIImage imageNamed:@"top_select_n_1"];
            selectOneLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x666666)];
            selectTwoLabel.textColor = UIColorFromRGB(0xB4b4b4);
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"RestoreMerge"];
            
        }
            break;
        case 201:
        {
            UIImageView *selectOneView = [self.tableView viewWithTag:123];
            UIImageView *selectTwoView = [self.tableView viewWithTag:151];
            UILabel *selectOneLabel = [self.tableView viewWithTag:131];
            UILabel *selectTwoLabel = [self.tableView viewWithTag:161];
            selectOneView.image = [UIImage imageNamed:@"top_select_n_1"];
            selectTwoView.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
            selectOneLabel.textColor = UIColorFromRGB(0xB4b4b4);
            selectTwoLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x666666)];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RestoreMerge"];
        }
            break;
            
        default:
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    return (TOPScreenHeight-7*52-20-TOPNavBarHeight-TOPStatusBarHeight-100)>294?TOPScreenHeight-7*52-20-TOPNavBarHeight-TOPStatusBarHeight-100:294;
}
#pragma mark- 压缩上传的点击事件
- (void)top_backupNowClick:(UIButton *)sender
{
    NSMutableArray *statesArrays = [self getAllSelectDriveArrays];
    if (statesArrays.count<=0) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_restorenotlogin", @"")];
        [SVProgressHUD dismissWithDelay:1];
        return;
    }
    BOOL isInback11 =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"isDownOrUpdateInback"] boolValue];
    if (isInback11 == YES) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_restorenotrepeat", @"")];
        return;
    }
    BOOL isWiFiOnly = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Backup-Wi-Fionly"] boolValue];
    
    if (isWiFiOnly == YES) {
        if ([TOPScanerShare top_saveNetworkState] ==  2) {
            [self top_quertLocalFileToDriveMothod:statesArrays];
        }else{
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_restorebackwifi", @"")];
            [SVProgressHUD dismissWithDelay:2];
        }
    }else{
        [self top_quertLocalFileToDriveMothod:statesArrays];
    }
    
}
#pragma mark - 查询本地文件并压缩文件的处理方法
- (void)top_quertLocalFileToDriveMothod:(NSMutableArray *)statesArrays
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:TOPTemporarySimpleScannerZip]){
            [fileManager createDirectoryAtPath:TOPTemporarySimpleScannerZip withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSError *error;
        NSArray *tempFileArrays = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[TOPDocumentHelper top_getDocumentsPathString] error:&error];
        NSArray *folderFileArrays = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[TOPDocumentHelper top_getFoldersPathString] error:&error];
        if (tempFileArrays.count <=0 && folderFileArrays.count <=0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_restorenodocument", @"")];
                [SVProgressHUD dismissWithDelay:1];
                return;
            });
        }
        [TOPDocumentHelper top_copyFileItemsFilterAtPath:[TOPDocumentHelper top_appBoxDirectory] toNewFileAtPath:TOPTemporarySimpleScannerZip];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (statesArrays.count >1) {
                [SVProgressHUD dismiss];
                TOPDriveSelectListView*listView = [TOPDriveSelectListView top_creatXIB];
                listView.driveDataArrays = statesArrays;
                [listView top_showXib];
                WeakSelf(ws);
                listView.selectDriveBlock = ^(NSString * _Nonnull selectItemName) {
                    [ws top_zipPressed:selectItemName];
                };
            }else{
                NSString *currentDriveName = [statesArrays firstObject];
                [self top_zipPressed:currentDriveName];
            }
        });
        
    });
}
#pragma mark - 获取当前登录可用的网盘
- (NSMutableArray *)getAllSelectDriveArrays
{
    NSMutableArray *drives = [NSMutableArray array];
    NSInteger iCloudOpen =   [[[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudOpen"] integerValue];
    if (iCloudOpen == 2) {
        [drives addObject:@"iCloud"];
    }
    BOXContentClient *client = [BOXContentClient defaultClient];
    if (client.user) {
        [drives addObject:NSLocalizedString(@"topscan_box", @"")];
    }
    [[FHGoogleLoginManager sharedInstance] checkGoogleAccountStateWithCompletion:^(FHGoogleAccountState state) {
        switch (state) {
            case FHGoogleAccountStateOnline:
            case FHGoogleAccountStateHasKeyChain:
            {
                [drives addObject:NSLocalizedString(@"topscan_googledrive", @"")];
            }
                break;
            default:
                break;
        }
    }];
    ODClient *oneClient = [ODClient loadCurrentClient];
    if (oneClient) {
        [drives addObject:NSLocalizedString(@"topscan_onedrive" , @"")];
    }
    DBUserClient *dbClient = [DBClientsManager authorizedClient];
    if (dbClient.usersRoutes)
    {
        [drives addObject:NSLocalizedString(@"topscan_dropbox", @"")];
    }
    return drives;
}
#pragma mark - 查询下载网盘内容的方法
- (void)top_restoreClick:(UIButton *)sender
{
    NSMutableArray *statesArrays = [self getAllSelectDriveArrays];
    if (statesArrays.count<=0) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_restorenotlogin", @"")];
        [SVProgressHUD dismissWithDelay:1];
        return;
    }
    BOOL isInback11 =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"isDownOrUpdateInback"] boolValue];
    if (isInback11 == YES) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_restorenotrepeat", @"")];
        return;
    }
    if (statesArrays.count >1) {
        TOPDriveSelectListView*listView = [TOPDriveSelectListView top_creatXIB];
        listView.driveDataArrays = statesArrays;
        [listView top_showXib];
        listView.selectDriveBlock = ^(NSString * _Nonnull selectItemName) {
            [self top_selectDriveQueryList:selectItemName];
        };
    }else{
        NSString *currentDriveName = [statesArrays firstObject];
        [self top_selectDriveQueryList:currentDriveName];
    }
}
#pragma mark- 查询各个网盘的内容列表
- (void)top_selectDriveQueryList:(NSString *)currentDriveName
{
    if ([currentDriveName isEqualToString:NSLocalizedString(@"topscan_onedrive" , @"")]) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_restorequery", @"")];
        [[DriveDownloadManger sharedSingleton] queryFileOneDriveWithObjectCompletionBlock:^(NSArray<ODItem *> * _Nonnull fileItems) {
            [SVProgressHUD dismiss];
            if (fileItems.count>0) {
                TOPReStoreListView *listView = [TOPReStoreListView top_creatXIB];
                listView.showStyle = TOPDownLoadDataStyleStyleOneDrice;
                listView.oneDriveDataArrays = [NSMutableArray arrayWithArray:fileItems];
                [listView top_showXib];
            }else{
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_restorequeryfailed", @"")];
                [SVProgressHUD dismissWithDelay:1];
            }
            
        }];
    }else if ([currentDriveName isEqualToString:NSLocalizedString(@"topscan_googledrive", @"")])
    {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_restorequery", @"")];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [[DriveDownloadManger sharedSingleton] queryDriveWithGoogleCompletionBlock:^(NSArray<GTLRDrive_File *> * _Nonnull fileItems, NSError * _Nonnull error) {
            [SVProgressHUD dismiss];
            if (fileItems.count>0) {
                TOPReStoreListView *listView = [TOPReStoreListView top_creatXIB];
                listView.showStyle = TOPDownLoadDataStyleDefaultGoogle;
                listView.driveGoogleDataArrays = [NSMutableArray arrayWithArray:fileItems];
                [listView top_showXib];
            }else{
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_restorequeryfailed", @"")];
                [SVProgressHUD dismissWithDelay:1];
                
            }
            
        }];
    }else if ([currentDriveName isEqualToString:NSLocalizedString(@"topscan_box", @"")])
    {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_restorequery", @"")];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [[DriveDownloadManger sharedSingleton] queryFileBoxWithObjectCompletionBlock:^(NSArray<BOXItem *> * _Nonnull fileItems) {
            [SVProgressHUD dismiss];
            if (fileItems.count>0) {
                TOPReStoreListView *listView = [TOPReStoreListView top_creatXIB];
                listView.showStyle = TOPDownLoadDataStyleStyleBox;
                listView.boxDataArrays = [NSMutableArray arrayWithArray:fileItems];
                [listView top_showXib];
            }else{
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_restorequeryfailed", @"")];
                [SVProgressHUD dismissWithDelay:1];
            }
        }];
    }else if ([currentDriveName isEqualToString:NSLocalizedString(@"topscan_dropbox", @"")])
    {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_restorequery", @"")];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [[DriveDownloadManger sharedSingleton] queryFileINDropBoxWithObjectCompletionBlock:^(NSArray<DBFILESMetadata *> * _Nonnull fileItems) {
            [SVProgressHUD dismiss];
            if (fileItems.count>0) {
                TOPReStoreListView *listView = [TOPReStoreListView top_creatXIB];
                listView.showStyle = TOPDownLoadDataStyleStyleDropBox;
                listView.dropBoxDataArrays = [NSMutableArray arrayWithArray:fileItems];
                [listView top_showXib];
            }else{
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_restorequeryfailed", @"")];
                [SVProgressHUD dismissWithDelay:1];
            }
        }];
    }else if ([currentDriveName isEqualToString:@"iCloud"])
    {
        NSArray *documentTypes = @[ (NSString*)kUTTypeZipArchive];
        [[UINavigationBar appearance] setTranslucent:YES];
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc]initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
        documentPicker.delegate = self;
        documentPicker.modalPresentationStyle =  UIModalPresentationFullScreen;
        [self presentViewController:documentPicker animated:YES completion:nil];
    }
    
}

#pragma mark - IBAction
- (void)top_zipPressed:(NSString *)currentDriveName {
    _zipPath = [self tempZipPath];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    __block BOOL success ;
    WeakSelf(weakself);
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        success = [SSZipArchive createZipFileAtPath:self->_zipPath withContentsOfDirectory:TOPTemporarySimpleScannerZip keepParentDirectory:YES withPassword:nil andProgressHandler:^(NSUInteger entryNumber, NSUInteger total) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%@ (%@)",NSLocalizedString(@"topscan_restoreprocessfiles", @""),[weakself top_getProgressWithPercent:(float)entryNumber/total]]];
            });
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [TOPWHCFileManager top_removeItemAtPath:TOPTemporarySimpleScannerZip];
                WeakSelf(ws);
                if ([currentDriveName isEqualToString:NSLocalizedString(@"topscan_onedrive" , @"")]) {
                    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_drivestartupdate", @"")]];
                    [[DriveDownloadManger sharedSingleton] updateZipWithOneDrive:self->_zipPath completionBlock:^(ODItem * _Nonnull fileDrive) {
                        [ws.downProgressView top_closeXib];
                        ws.downProgressView = nil;
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
                        [UIApplication sharedApplication].idleTimerDisabled = NO;
                        if (fileDrive) {
                            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_onedrivesussess", @"")];
                            [SVProgressHUD dismissWithDelay:1];
                            [TOPDocumentHelper top_addLocalNotificationWithTitle:NSLocalizedString(@"topscan_onedrivesussess", @"") subTitle:@"" body:NSLocalizedString(@"topscan_onedrivesussess", @"")  timeInterval:5 identifier:@"22222222" userInfo:@{@"Identifier":@"22222222"} repeats:8];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:[TOPDocumentHelper top_getEnish2ForMatterWith:[NSDate date]] forKey:@"backuplastDate"];
                            [ws.tableView reloadData];
                        }else{
                            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_restorebackupfailed", @"")];
                            [SVProgressHUD dismissWithDelay:1];
                            
                        }
                        [TOPWHCFileManager top_removeItemAtPath:ws.zipPath];
                    } progress:^(float progressValue) {
                    }];
                    
                }else if ([currentDriveName isEqualToString:NSLocalizedString(@"topscan_googledrive", @"")]){
                    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_drivestartupdate", @"")]];
                    [[DriveDownloadManger sharedSingleton] updateZipWithGoogleDrive:self->_zipPath Type:TOPDownLoadDataStyleDefaultGoogle completionBlock:^(GTLRDrive_File * _Nonnull file, NSError * _Nonnull error) {
                        [ws.downProgressView top_closeXib];
                        ws.downProgressView = nil;
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
                        [UIApplication sharedApplication].idleTimerDisabled = NO;
                        if (error) {
                            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_restorebackupfailed", @"")];
                            [SVProgressHUD dismissWithDelay:1];
                        }else{
                            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_googledrivesussess", @"")];
                            [SVProgressHUD dismissWithDelay:1];
                            [TOPDocumentHelper top_addLocalNotificationWithTitle:NSLocalizedString(@"topscan_googledrivesussess", @"") subTitle:@"" body:NSLocalizedString(@"topscan_googledrivesussess", @"")  timeInterval:5 identifier:@"22222222" userInfo:@{@"Identifier":@"22222222"} repeats:8];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:[TOPDocumentHelper top_getEnish2ForMatterWith:[NSDate date]] forKey:@"backuplastDate"];
                            
                            [ws.tableView reloadData];
                        }
                        [TOPWHCFileManager top_removeItemAtPath:ws.zipPath];
                    } progress:^(float progressValue) {
                        [ws top_showProgressinUPDateDrive:progressValue];
                    }];
                }else if ([currentDriveName isEqualToString:NSLocalizedString(@"topscan_box", @"")])
                {
                    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_drivestartupdate", @"")]];
                    [[DriveDownloadManger sharedSingleton] updateZipWithBoxDrive:self->_zipPath completionBlock:^(BOXItem * _Nonnull fileDrive) {
                        [self.downProgressView top_closeXib];
                        self.downProgressView = nil;
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
                        [UIApplication sharedApplication].idleTimerDisabled = NO;
                        if (fileDrive) {
                            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_boxsussess", @"")];
                            [SVProgressHUD dismissWithDelay:1];
                            [TOPDocumentHelper top_addLocalNotificationWithTitle:NSLocalizedString(@"topscan_boxsussess", @"") subTitle:@"" body:NSLocalizedString(@"topscan_boxsussess", @"")  timeInterval:5 identifier:@"22222222" userInfo:@{@"Identifier":@"22222222"} repeats:8];
                            [[NSUserDefaults standardUserDefaults] setObject:[TOPDocumentHelper top_getEnish2ForMatterWith:[NSDate date]] forKey:@"backuplastDate"];
                            [ws.tableView reloadData];
                        }else{
                            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_restorebackupfailed", @"")];
                            [SVProgressHUD dismissWithDelay:1];
                        }
                        [TOPWHCFileManager top_removeItemAtPath:ws.zipPath];
                    } progress:^(float progressValue) {
                        [ws top_showProgressinUPDateDrive:progressValue];
                    }];
                    
                }else if ([currentDriveName isEqualToString:NSLocalizedString(@"topscan_dropbox", @"")])
                {
                    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_drivestartupdate", @"")]];
                    [[DriveDownloadManger sharedSingleton] updateZipWithDropBox:self->_zipPath completionBlock:^(DBFILESMetadata * _Nonnull fileDrive) {
                        [ws.downProgressView top_closeXib];
                        ws.downProgressView = nil;
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
                        [UIApplication sharedApplication].idleTimerDisabled = NO;
                        if (fileDrive) {
                            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_dropboxsussess", @"")];
                            [SVProgressHUD dismissWithDelay:1];
                            [TOPDocumentHelper top_addLocalNotificationWithTitle:NSLocalizedString(@"topscan_dropboxsussess", @"") subTitle:@"" body:NSLocalizedString(@"topscan_dropboxsussess", @"")  timeInterval:5 identifier:@"22222222" userInfo:@{@"Identifier":@"22222222"} repeats:8];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:[TOPDocumentHelper top_getEnish2ForMatterWith:[NSDate date]] forKey:@"backuplastDate"];
                        }else{
                            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_restorebackupfailed", @"")];
                            [SVProgressHUD dismissWithDelay:1];
                        }
                        [TOPWHCFileManager top_removeItemAtPath:ws.zipPath];
                        [ws.tableView reloadData];
                    } progress:^(float progressValue) {
                        [ws top_showProgressinUPDateDrive:progressValue];
                    }];
                }else if ([currentDriveName isEqualToString:@"iCloud"])
                {
                    [SVProgressHUD dismiss];
                    NSURL *url = [NSURL fileURLWithPath:self.zipPath];
                    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithURL:url
                                                                                                                  inMode:UIDocumentPickerModeExportToService];
                    documentPicker.delegate = self;
                    documentPicker.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:documentPicker animated:YES completion:nil];
                }
            } else {
                NSLog(@"No success zip");
            }
        });
    });
}
#pragma mark - 网盘上传的进度显示

- (void) top_showProgressinUPDateDrive:(float)progressValue
{
    [SVProgressHUD dismiss];
    BOOL isInback =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"isDownOrUpdateInback"] boolValue];
    if (isInback== NO) {
        if (self.downProgressView == nil) {
            TOPDownProgressAlertView *downProgressView  = [TOPDownProgressAlertView top_creatXIB];
            [downProgressView top_showXib];
            downProgressView.closeViewBlock = ^{
                self.downProgressView = nil;
            };
            self.downProgressView = downProgressView;
        }
        self.downProgressView.progressFloat = progressValue;
        self.downProgressView.titleName = [NSString stringWithFormat:@"%@(%.f%%)",NSLocalizedString(@"topscan_restoreuploadingfile", @""),floorf(progressValue*100)];
    }
}
- (void)changeDownloadbackStates:(NSString *)currentStr states:(NSMutableArray *)statesArrays downStates:(NSMutableArray *)downloadStatesArrays
{
    NSInteger currentIndex = [statesArrays indexOfObject:currentStr];
    NSNumber *oldState = [downloadStatesArrays objectAtIndex:currentIndex];
    NSNumber *newState = [NSNumber numberWithDouble:![oldState boolValue]];
    [downloadStatesArrays removeObjectAtIndex:currentIndex];
    [downloadStatesArrays insertObject:newState atIndex:currentIndex];
    BOOL isdownSuerrse = YES;
    for (int i = 0; i<downloadStatesArrays.count; i++) {
        if([downloadStatesArrays[i] boolValue]==NO)
        {
            isdownSuerrse = NO;
            break;
        }
    }
    if (isdownSuerrse ==YES) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private
- (NSString *)tempZipPath {
    NSString *path = [NSString stringWithFormat:@"%@/%@.zip",
                      NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0],
                      [NSString stringWithFormat:@"topscan_backup %@",[TOPDocumentHelper top_getCurrentYYYYDateForMatter]]];
    return path;
}

- (void)top_initBackButton:(nullable NSString *)imgName withSelector:(SEL)selector{
    TOPImageTitleButton * btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

- (void)top_backHomeAction{
    [SVProgressHUD dismiss];
    self.navigationController.navigationBar.barTintColor = TOPAPPGreenColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:UIColorFromRGB(0xFFFFFF),
                                                                    NSFontAttributeName:[UIFont systemFontOfSize:18]};
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSString *)top_getProgressWithPercent:(float)percent
{
    CFLocaleRef currentLocale = CFLocaleCopyCurrent();
    CFNumberFormatterRef numberFormatter = CFNumberFormatterCreate(NULL, currentLocale, kCFNumberFormatterPercentStyle);
    CFNumberRef number = CFNumberCreate(NULL, kCFNumberFloatType, &percent);
    CFStringRef numberString = CFNumberFormatterCreateStringWithNumber(NULL, numberFormatter, number);
    NSString *tempStr = (__bridge NSString *)(numberString);
    CFRelease(currentLocale);
    CFRelease(numberFormatter);
    CFRelease(number);
    CFRelease(numberString);
    return tempStr;
}

#pragma mark - iCloud代理
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls
{
    if (controller.documentPickerMode == UIDocumentPickerModeOpen)
    {
        BOOL fileAuthorized = [urls.firstObject startAccessingSecurityScopedResource];
        if (fileAuthorized) {
            NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc]init];
            NSError *error;
            [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) {
                NSString *fileName = [newURL lastPathComponent];
                NSData *fileData = [NSData dataWithContentsOfURL:newURL];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                if(![fileManager fileExistsAtPath:TOPTemporaryPathZip]){
                    [fileManager createDirectoryAtPath:TOPTemporaryPathZip withIntermediateDirectories:YES attributes:nil error:nil];
                }
                NSString *newFilePath = [TOPTemporaryPathZip stringByAppendingPathComponent:fileName];
                [fileData writeToFile:newFilePath atomically:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[DriveDownloadManger sharedSingleton] installDownLoadDataDocoumentFile:newFilePath];
                });
            }];
        }
    }else  if (controller.documentPickerMode == UIDocumentPickerModeExportToService)
    {
        BOOL fileAuthorized = [urls.firstObject startAccessingSecurityScopedResource];
        if (fileAuthorized) {
            NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc]init];
            NSError *error;
            [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TOPWHCFileManager top_removeItemAtPath:self.zipPath];
                });
            }];
        }
    }
}
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    if (self.zipPath) {
        [TOPWHCFileManager top_removeItemAtPath:self.zipPath];
    }
}
@end
