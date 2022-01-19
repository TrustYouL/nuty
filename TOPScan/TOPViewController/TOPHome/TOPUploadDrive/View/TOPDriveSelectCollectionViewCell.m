#import "TOPDriveSelectCollectionViewCell.h"

@implementation TOPDriveSelectCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_box_drive_cloud"]];
        [self.contentView addSubview:_coverImageView];
        
        [self.vipLogoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.trailing.equalTo(self.coverImageView);
        }];
        [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.centerX.equalTo(self.contentView);
            make.height.mas_offset(85);
            make.width.mas_offset(85);
        }];
        self.coverImageView.layer.shadowOffset = CGSizeMake(0, 1);
        self.coverImageView.layer.shadowColor = RGBA(9, 103, 103, 0.13).CGColor ;
        self.coverImageView.layer.shadowOpacity = 1;
        self.coverImageView.layer.shadowRadius = 3;
        self.coverImageView.clipsToBounds =NO;
        
        self.driveNameLabel = [[UILabel alloc ]init];
        self.driveNameLabel.font = PingFang_M_FONT_(16);
        self.driveNameLabel.numberOfLines = 0;
        self.driveNameLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
        self.driveNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.driveNameLabel];
        [_driveNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(5);
            make.trailing.equalTo(self.contentView).offset(-5);
            make.top.equalTo(_coverImageView.mas_bottom).offset(15);
        }];
        
        self.emailTextLabel = [[UILabel alloc ]init];
        self.emailTextLabel.font = PingFang_M_FONT_(12);
        self.emailTextLabel.numberOfLines = 0;
        self.emailTextLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
        self.emailTextLabel.textAlignment = NSTextAlignmentCenter;
        self.emailTextLabel.backgroundColor  = [UIColor clearColor];
        [self.contentView addSubview:self.emailTextLabel];
        [_emailTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(15);
            make.trailing.equalTo(self.contentView).offset(-15);
            make.top.equalTo(_driveNameLabel.mas_bottom).offset(5);
            make.height.mas_offset(40);
        }];
        
        _signStatesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signStatesButton setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        _signStatesButton.titleLabel.font = PingFang_M_FONT_(16);
        
        [self.contentView addSubview:_signStatesButton];
        [_signStatesButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(_emailTextLabel.mas_bottom).offset(5);
            make.height.mas_offset(40);
            make.width.mas_offset(109);
        }];
        [_signStatesButton addTarget:self action:@selector(driveiCloudSignClick:) forControlEvents:UIControlEventTouchUpInside];
        _signStatesButton.layer.cornerRadius = 20;
        _signStatesButton.layer.borderColor = TOPAPPGreenColor.CGColor;
        _signStatesButton.layer.borderWidth = 0.7;
        [self.signStatesButton setTitle:NSLocalizedString(@"topscan_singoutlowercase", @"") forState:UIControlStateNormal];
        [self.signStatesButton setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:TOPAPPGreenColor] forState:UIControlStateNormal];
        self.signStatesButton.layer.borderColor = TOPAPPGreenColor.CGColor;
        
        
        UIButton * clickSignButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clickSignButton setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:TOPAPPGreenColor] forState:UIControlStateNormal];
        
        [self.contentView addSubview:clickSignButton];
        [clickSignButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_coverImageView);
            make.trailing.equalTo(_coverImageView);
            make.top.equalTo(_coverImageView);
            make.bottom.equalTo(_emailTextLabel).offset(-20);
        }];
        
        [clickSignButton addTarget:self action:@selector(top_loginSignClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)top_loginSignClick:(UIButton *)sender
{
    if (self.top_didSelectDriveClickBlock) {
        self.top_didSelectDriveClickBlock(self.titleSourseName);
    }
}

- (void)setTitleSourseName:(NSString *)titleSourseName
{
    _titleSourseName = titleSourseName;
    self.driveNameLabel.text = titleSourseName;
    self.emailTextLabel.text = @"";
    if ([titleSourseName isEqualToString:NSLocalizedString(@"topscan_box", @"")]) {
        self.coverImageView.image= [UIImage imageNamed:@"top_box_drive_cloud"];
        BOXContentClient *client = [BOXContentClient defaultClient];
        if (client.user) {
            self.emailTextLabel.text = client.user.login;
            self.signStatesButton.hidden = NO;
        }else{
            self.signStatesButton.hidden = YES;
        }
    }else if ([titleSourseName isEqualToString:NSLocalizedString(@"topscan_googledrive", @"")]) {
        self.coverImageView.image= [UIImage imageNamed:@"top_google_drive_cloud"];
        [[FHGoogleLoginManager sharedInstance] checkGoogleAccountStateWithCompletion:^(FHGoogleAccountState state) {
            switch (state) {
                case FHGoogleAccountStateOnline:
                {
                    if ([GIDSignIn sharedInstance].currentUser) {
                        self.emailTextLabel.text = [GIDSignIn sharedInstance].currentUser.profile.email;
                    }
                    self.signStatesButton.hidden = NO;
                }
                    break;
                case FHGoogleAccountStateHasKeyChain:
                {
                    self.signStatesButton.hidden = YES;
                }
                    break;
                case FHGoogleAccountStateOffline:
                {
                    self.signStatesButton.hidden = YES;
                }
                    break;
                default:
                    break;
            }
        }];
    }else if ([titleSourseName isEqualToString:NSLocalizedString(@"topscan_onedrive" , @"")]) {
        self.coverImageView.image= [UIImage imageNamed:@"top_onedrive_drive_cloud"];
        ODClient *client = [ODClient loadCurrentClient];
        if (client) {
            self.signStatesButton.hidden = NO;
        }else{
            self.signStatesButton.hidden = YES;
        }
    }else if ([titleSourseName isEqualToString:NSLocalizedString(@"topscan_dropbox", @"")]) {
        DBUserClient *dbClient = [DBClientsManager authorizedClient];
        if (dbClient.usersRoutes) {
            self.signStatesButton.hidden = NO;
            [[dbClient.usersRoutes getCurrentAccount] setResponseBlock:^(DBUSERSFullAccount * _Nullable result, DBNilObject * _Nullable routeError, DBRequestError * _Nullable networkError) {
                if (result != nil) {
                    self.emailTextLabel.text = result.email;
                }
            }];;
        }else{
            self.signStatesButton.hidden = YES;
        }
        self.coverImageView.image= [UIImage imageNamed:@"top_dropbox_drive_cloud"];
    }
}

- (void)driveiCloudSignClick:(UIButton *)sender
{
    if ([self.titleSourseName isEqualToString:NSLocalizedString(@"topscan_box", @"")]) {
        BOXContentClient *client = [BOXContentClient defaultClient];
        if (client.user) {
            [self singnOutDriveiCloud:self.titleSourseName];
        }
    }else if ([self.titleSourseName isEqualToString:NSLocalizedString(@"topscan_googledrive", @"")]) {
        [[FHGoogleLoginManager sharedInstance] checkGoogleAccountStateWithCompletion:^(FHGoogleAccountState state) {
            switch (state) {
                case FHGoogleAccountStateOnline:
                case FHGoogleAccountStateHasKeyChain:
                {
                    [self singnOutDriveiCloud:self.titleSourseName];
                }
                    break;
                default:
                    break;
            }
        }];
        
    }else if ([self.titleSourseName isEqualToString:NSLocalizedString(@"topscan_onedrive" , @"")]) {
        ODClient *oneClient = [ODClient loadCurrentClient];
        if (oneClient) {
            [self singnOutDriveiCloud:self.titleSourseName];
        }
    }else if ([self.titleSourseName isEqualToString:NSLocalizedString(@"topscan_dropbox", @"")]) {
        DBUserClient *dbClient = [DBClientsManager authorizedClient];
        if (dbClient.usersRoutes && dbClient.accessToken)
        {
            [self singnOutDriveiCloud:self.titleSourseName];
        }
    }
}

- (void)singnOutDriveiCloud:(NSString *)sourseName
{
    UIAlertController *col = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"") message:NSLocalizedString(@"topscan_loginouttipsmessage", @"") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    WeakSelf(ws);
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_singoutlowercase", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([sourseName isEqualToString:NSLocalizedString(@"topscan_box", @"")]) {
            BOXContentClient *client = [BOXContentClient defaultClient];
            [client logOut];
        }else if ([sourseName isEqualToString:NSLocalizedString(@"topscan_googledrive", @"")]) {
            [[GIDSignIn sharedInstance] signOut];
            [[GIDSignIn sharedInstance] disconnect];
        }else if ([sourseName isEqualToString:NSLocalizedString(@"topscan_onedrive" , @"")]) {
            ODClient *client = [ODClient loadCurrentClient];
            [client signOutWithCompletion:^(NSError *signOutError){
            }];
        }else if ([sourseName isEqualToString:NSLocalizedString(@"topscan_dropbox", @"")]) {
            [DBClientsManager unlinkAndResetClients];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accessToken"];
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            ws.signStatesButton.hidden = YES;
            ws.emailTextLabel.text = @"";
        });
    }];
    [col addAction:confirmAction];
    [col addAction:cancelAction];
    [[TOPDocumentHelper top_topViewController] presentViewController:col animated:YES completion:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark -- lazy
- (UIImageView *)vipLogoView {
    if (!_vipLogoView) {
        UIImage *noClassImg = [UIImage imageNamed:@"top_vip_logo_corner"];
        UIImageView *noClass = [[UIImageView alloc] initWithImage:noClassImg];
        [self.contentView addSubview:noClass];
        noClass.hidden = YES;
        _vipLogoView = noClass;
    }
    return _vipLogoView;
}

@end
