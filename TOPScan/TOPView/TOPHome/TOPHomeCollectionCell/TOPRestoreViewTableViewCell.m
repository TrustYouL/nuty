#import "TOPRestoreViewTableViewCell.h"
#import "FHGoogleLoginManager.h"

@implementation TOPRestoreViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.singnButton.layer.cornerRadius= 4;
    self.singnButton.clipsToBounds = YES;
    self.driveImageView.layer.shadowOffset = CGSizeMake(0, 1);
    self.driveImageView.layer.shadowColor = RGBA(9, 103, 103, 0.13).CGColor ;
    self.driveImageView.layer.shadowOpacity = 1;
    self.driveImageView.layer.shadowRadius = 3;
    self.driveImageView.clipsToBounds =NO;
    self.singIn = NSLocalizedString(@"topscan_uploadsingin", @"");
    self.singOut = [NSLocalizedString(@"topscan_singoutlowercase", @"") uppercaseString];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setItemName:(NSString *)itemName{
    _itemName =itemName;
    [self.singnButton setBackgroundColor:TOPAPPGreenColor];
    [self.singnButton setTitle:self.singIn forState:UIControlStateNormal];
    self.itemTitleLabel.text = itemName;

    if ([itemName isEqualToString:NSLocalizedString(@"topscan_box", @"")]) {
        self.driveImageView.image = [UIImage imageNamed:@"top_box_drive_cloud"];
        BOXContentClient *client = [BOXContentClient defaultClient];
        if (client.user) {
            self.itemTitleLabel.text = client.user.login;
            [self.singnButton setTitle:self.singOut forState:UIControlStateNormal];
            [self.singnButton setBackgroundColor:UIColorFromRGB(0xE44E46)];
        }else{
            [self.singnButton setTitle:self.singIn forState:UIControlStateNormal];
            [self.singnButton setBackgroundColor:TOPAPPGreenColor];
        }
    }
    if ([itemName isEqualToString:NSLocalizedString(@"topscan_googledrive", @"")]) {
        self.driveImageView.image = [UIImage imageNamed:@"top_google_drive_cloud"];
        [[FHGoogleLoginManager sharedInstance] checkGoogleAccountStateWithCompletion:^(FHGoogleAccountState state) {
            switch (state) {
                case FHGoogleAccountStateOnline:
                {
                    if ([GIDSignIn sharedInstance].currentUser) {
                        self.itemTitleLabel.text = [GIDSignIn sharedInstance].currentUser.profile.email;
                    }
                    [self.singnButton setTitle:self.singOut forState:UIControlStateNormal];
                    [self.singnButton setBackgroundColor:UIColorFromRGB(0xE44E46)];
                }
                    break;
                case FHGoogleAccountStateHasKeyChain:
                    {
                        [self.singnButton setTitle:self.singOut forState:UIControlStateNormal];
                        [self.singnButton setBackgroundColor:UIColorFromRGB(0xE44E46)];
                    }
                    break;
                case FHGoogleAccountStateOffline:
                {
                    [self.singnButton setTitle:self.singIn forState:UIControlStateNormal];
                    [self.singnButton setBackgroundColor:TOPAPPGreenColor];
                }
                    break;
                default:
                    break;
            }
        }];
    }

    if ([itemName isEqualToString:NSLocalizedString(@"topscan_onedrive" , @"")]) {
        ODClient *client = [ODClient loadCurrentClient];
        if (client) {
            [self.singnButton setTitle:self.singOut forState:UIControlStateNormal];
            [self.singnButton setBackgroundColor:UIColorFromRGB(0xE44E46)];
        }else{
            [self.singnButton setTitle:self.singIn forState:UIControlStateNormal];
            [self.singnButton setBackgroundColor:TOPAPPGreenColor];
        }
        self.driveImageView.image = [UIImage imageNamed:@"top_onedrive_drive_cloud"];
    }
    if ([itemName isEqualToString:NSLocalizedString(@"topscan_dropbox", @"")]) {
        DBUserClient *dbClient = [DBClientsManager authorizedClient];
          if (dbClient.usersRoutes) {
              [self.singnButton setTitle:self.singOut forState:UIControlStateNormal];
              [self.singnButton setBackgroundColor:UIColorFromRGB(0xE44E46)];
              [[dbClient.usersRoutes getCurrentAccount] setResponseBlock:^(DBUSERSFullAccount * _Nullable result, DBNilObject * _Nullable routeError, DBRequestError * _Nullable networkError) {
                  if (result != nil) {
                      self.itemTitleLabel.text = result.email;
                  }
              }];;
          }else{
              [self.singnButton setTitle:self.singIn forState:UIControlStateNormal];
              [self.singnButton setBackgroundColor:TOPAPPGreenColor];
          }
        self.driveImageView.image = [UIImage imageNamed:@"top_dropbox_drive_cloud"];
    }
}

- (IBAction)signinClick:(UIButton *)sender {
    if ([self.itemName isEqualToString:NSLocalizedString(@"topscan_box", @"")]) {
        BOXContentClient *client = [BOXContentClient defaultClient];
        if (client.user) {
            TOPSCAlertController *col = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"")  message:NSLocalizedString(@"topscan_loginouttipsmessage", @"") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_singoutlowercase", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self top_boxlogOutClick];
            }];
            [col addAction:confirmAction];
            [col addAction:cancelAction];
            [[self top_appRootViewController] presentViewController:col animated:YES completion:nil];
        }else{
            [self top_boxSignInClick];
        }
    }
    if ([self.itemName isEqualToString:NSLocalizedString(@"topscan_googledrive", @"")]) {
        [[FHGoogleLoginManager sharedInstance] checkGoogleAccountStateWithCompletion:^(FHGoogleAccountState state) {
            switch (state) {
                case FHGoogleAccountStateOnline:
                case FHGoogleAccountStateHasKeyChain:
                    {
                        TOPSCAlertController *col = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"") message:NSLocalizedString(@"topscan_loginouttipsmessage", @"") preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_singoutlowercase", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [[GIDSignIn sharedInstance] signOut];
                            [[GIDSignIn sharedInstance] disconnect];
                            self.itemTitleLabel.text = NSLocalizedString(@"topscan_googledrive", @"");
                            [self.singnButton setTitle:self.singIn forState:UIControlStateNormal];
                            [self.singnButton setBackgroundColor:TOPAPPGreenColor];
                        }];
                        [col addAction:confirmAction];
                        [col addAction:cancelAction];
                        [[self top_appRootViewController] presentViewController:col animated:YES completion:nil];
                    }
                    break;
                case FHGoogleAccountStateOffline:
                {
                    [[FHGoogleLoginManager sharedInstance] startGoogleLoginWithCompletion:^(GIDGoogleUser *user, NSError *error) {
                        if (user && error==nil) {
                            [self.singnButton setTitle:self.singOut forState:UIControlStateNormal];
                            self.itemTitleLabel.text = user.profile.email;
                            [self.singnButton setBackgroundColor:UIColorFromRGB(0xE44E46)];
                        }
                    }];

                }
                    break;
                default:
                    break;
            }
        }];
    }

    if ([self.itemName isEqualToString:NSLocalizedString(@"topscan_onedrive" , @"")]) {
        ODClient *client = [ODClient loadCurrentClient];
        if (client) {
            TOPSCAlertController *col = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"") message:NSLocalizedString(@"topscan_loginouttipsmessage", @"") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_singoutlowercase", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self top_signOutOneDriveAction];
            }];
            [col addAction:confirmAction];
            [col addAction:cancelAction];
            [[self top_appRootViewController] presentViewController:col animated:YES completion:nil];
        }else{
            [self top_signInOneDriveAction];
        }
    }

    if ([self.itemName isEqualToString:NSLocalizedString(@"topscan_dropbox", @"")]) {
        DBUserClient *dbClient = [DBClientsManager authorizedClient];
          if (dbClient.usersRoutes) {
              TOPSCAlertController *col = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"") message:NSLocalizedString(@"topscan_loginouttipsmessage", @"") preferredStyle:UIAlertControllerStyleAlert];
              UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
              }];
              UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_singoutlowercase", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                  [self top_dropboxSingout];
              }];
              [col addAction:confirmAction];
              [col addAction:cancelAction];
              [[self top_appRootViewController] presentViewController:col animated:YES completion:nil];
          }else{
              [self top_dropBoxSignIn];
          }
    }
}

- (void)top_signInOneDriveAction
{
    [ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error){
        if (!error){
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.singnButton setTitle:self.singOut forState:UIControlStateNormal];
                [self.singnButton setBackgroundColor:UIColorFromRGB(0xE44E46)];
            });
        }
        else{
        }
    }];
}

- (void)top_signOutOneDriveAction
{
    ODClient *client = [ODClient loadCurrentClient];
    [client signOutWithCompletion:^(NSError *signOutError){
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.singnButton setTitle:self.singIn forState:UIControlStateNormal];
            [self.singnButton setBackgroundColor:TOPAPPGreenColor];
        });

    }];
}

- (void)top_boxSignInClick {
    BOXContentClient *client = [BOXContentClient defaultClient];
       [client authenticateWithCompletionBlock:^(BOXUser *user, NSError *error) {
           if (error == nil) {
               [self.singnButton setTitle:self.singOut forState:UIControlStateNormal];
               [self.singnButton setBackgroundColor:UIColorFromRGB(0xE44E46)];
               self.itemTitleLabel.text = user.login;
           }else {
               NSLog(@"授权失败");
           }
       }];
}
- (void)top_boxlogOutClick {
    self.itemTitleLabel.text = NSLocalizedString(@"topscan_box", @"");
    BOXContentClient *client = [BOXContentClient defaultClient];
    [client logOut];
    [self.singnButton setTitle:self.singIn forState:UIControlStateNormal];
    [self.singnButton setBackgroundColor:TOPAPPGreenColor];
}

- (void)top_dropBoxSignIn{
    [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                        controller:[self top_appRootViewController]
                                           openURL:^(NSURL *url) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }];
}

- (void)top_dropboxSingout
{
    [DBClientsManager unlinkAndResetClients];
    self.itemTitleLabel.text = NSLocalizedString(@"topscan_dropbox", @"");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accessToken"];
    [self.singnButton setTitle:self.singIn forState:UIControlStateNormal];
    [self.singnButton setBackgroundColor:TOPAPPGreenColor];
}


- (UIViewController *)top_appRootViewController
{
    UIViewController *RootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = RootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}





@end
