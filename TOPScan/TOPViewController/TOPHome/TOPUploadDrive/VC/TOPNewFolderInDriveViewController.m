#import "TOPNewFolderInDriveViewController.h"

@interface TOPNewFolderInDriveViewController ()
@property (nonatomic,strong) UILabel *folderNameLabel;
@property (nonatomic,strong) UITextField *folderTextField;
@end

@implementation TOPNewFolderInDriveViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"topscan_tagsdone", @"") style:UIBarButtonItemStylePlain target:self action:@selector(top_newFolderClickAction)];
    [self.navigationItem.rightBarButtonItem setTintColor:TOPAPPGreenColor];
    
    UIView *topbgVIew = [[UIView alloc] init];
    topbgVIew.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    [self.view addSubview:topbgVIew];
    [topbgVIew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.mas_offset(10);
    }];
    
    UIImageView *folderIconImageView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_drive_newfolder_b"]];
    [self.view addSubview:folderIconImageView];
    
    [folderIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topbgVIew.mas_bottom).offset(50);
        make.height.mas_offset(62);
        make.width.mas_offset(68);
        make.centerX.equalTo(self.view);
    }];
    
    self.folderNameLabel = [[UILabel alloc] init];
    self.folderNameLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
    self.folderNameLabel.font = PingFang_R_FONT_(15);
    self.folderNameLabel.text = NSLocalizedString(@"topscan_newfolderprompt", @"");
    self.folderNameLabel.numberOfLines = 0;
    self.folderNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_folderNameLabel];
    
    [_folderNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(folderIconImageView.mas_bottom).offset(10);
        make.leading.equalTo(self.view).offset(25);
        make.trailing.equalTo(self.view).offset(-25);
    }];
    
    self.folderTextField = [[UITextField alloc] init];
    self.folderTextField.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
    self.folderTextField.font = PingFang_R_FONT_(12);
    self.folderTextField.placeholder = NSLocalizedString(@"topscan_newfolderprompt", @"");
    self.folderTextField.textAlignment = NSTextAlignmentNatural;
    self.folderTextField.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    self.folderTextField.layer.cornerRadius = 15;
    UIView *lefttextView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.folderTextField.leftView = lefttextView;
    self.folderTextField.leftViewMode = UITextFieldViewModeAlways;
    self.folderTextField.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview:_folderTextField];
    
    [self.folderTextField addTarget:self action:@selector(top_folderTextChangeEdit:) forControlEvents:UIControlEventEditingChanged];
    [_folderTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_folderNameLabel.mas_bottom).offset(50);
        make.leading.equalTo(self.view).offset(60);
        make.trailing.equalTo(self.view).offset(-60);
        make.height.mas_offset(30);
        
    }];
    
    [self.folderTextField becomeFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
- (void)top_folderTextChangeEdit:(UITextField *)folderTextF
{
    if (folderTextF.text.length<=0 ) {
        self.folderNameLabel.text = NSLocalizedString(@"topscan_newfolderprompt", @"");
    }else{
        self.folderNameLabel.text = folderTextF.text;
    }
}
- (void)top_newFolderClickAction
{
    [self.view endEditing:YES];
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    switch (self.uploadDriveStyle) {
        case TOPDownLoadDataStyleDefaultGoogle:
        {
            [self top_googleDriveCreateNewFolder];
        }
            break;
            
        case TOPDownLoadDataStyleStyleBox:
        {
            [self top_boxDriveCreateNewFolder];
        }
            break;
        case TOPDownLoadDataStyleStyleDropBox:
        {
            [self top_dropBoxDriveCreateNewFolder];
        }
            break;
            
        case TOPDownLoadDataStyleStyleOneDrice:
        {
            [self top_oneDriveCreatNewFolder];
        }
            break;
            
        default:
            break;
    }
}

- (void)top_backHomeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- google网盘创建文件夹
- (void)top_googleDriveCreateNewFolder
{
    GTLRDrive_File *folderObj = [GTLRDrive_File object];
    folderObj.name = self.folderTextField.text;
    folderObj.mimeType = @"application/vnd.google-apps.folder";
    if (self.currentGoogleFileDrive) {
        folderObj.parents = @[self.currentGoogleFileDrive.identifier];
    }
    
    GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:folderObj
                                                                   uploadParameters:nil];
    WeakSelf(ws);
    [self.googleDriveService executeQuery:query
                        completionHandler:^(GTLRServiceTicket *callbackTicket,
                                            GTLRDrive_File *folderItem,
                                            NSError *callbackError) {
        [SVProgressHUD dismiss];
        if (callbackError == nil) {
            
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_createdsuccessfully", @"")];
            
            if (ws.top_reloadCreatNewFolderWithListBlock) {
                ws.top_reloadCreatNewFolderWithListBlock();
            }
            [ws dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_creationfailed", @"")];
            
        }
    }];
}

#pragma mark- Box网盘创建文件夹
- (void)top_boxDriveCreateNewFolder
{
    BOXSearchRequest * searchRequest =    [self.boxContentClient searchRequestWithQuery:self.folderTextField.text inRange:NSMakeRange(0, 1000)];
    searchRequest.requestAllItemFields =   NO;
    NSString *folderID = BOXAPIFolderIDRoot;
    if (self.boxCurrentItem) {
        folderID = self.boxCurrentItem.modelID;
        
    }else{
        folderID = BOXAPIFolderIDRoot;
        
    }
    searchRequest.ancestorFolderIDs = @[folderID];
    
    WeakSelf(ws);
    [searchRequest performRequestWithCompletion:^(NSArray *items, NSUInteger totalCount, NSRange range, NSError *error) {
        
        if (!error) {
            BOOL isFileThere = NO;
            for (BOXItem *currentItem in items) {
                if ([currentItem.name isEqualToString:ws.folderTextField.text] && currentItem.isFolder) {
                    isFileThere = YES;
                    break;
                }
            }
            if (isFileThere == YES) {
                [SVProgressHUD dismiss];
                
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_folderexists", @"")];
            }else{
                BOXFolderCreateRequest *creatRequest = [self.boxContentClient folderCreateRequestWithName:ws.folderTextField.text parentFolderID:folderID];
                [creatRequest performRequestWithCompletion:^(BOXFolder *folder, NSError *error11) {
                    [SVProgressHUD dismiss];
                    
                    if (error11) {
                        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_creationfailed", @"")];
                        
                    }else{
                        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_createdsuccessfully", @"")];
                        
                        if (ws.top_reloadCreatNewFolderWithListBlock) {
                            ws.top_reloadCreatNewFolderWithListBlock();
                        }
                        [ws dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
            }
        }
        
    }];
}

#pragma mark- DropBox网盘创建文件夹
- (void)top_dropBoxDriveCreateNewFolder
{
    NSString *searchPath = @"";
    if (self.dropBoxCurrentItem) {
        searchPath = self.dropBoxCurrentItem.pathLower;
    }
    WeakSelf(ws);
    [[self.dropBoxContentClient.filesRoutes listFolder:searchPath]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
        if (result) {
            BOOL isContainsSimFile = NO;
            for (DBFILESMetadata *metaFile in  result.entries) {
                if ([metaFile.name isEqualToString:ws.folderTextField.text]) {
                    isContainsSimFile = YES;
                    break;
                }
            }
            if (isContainsSimFile == NO) {
                
                [ws top_creatDropBoxFolderMothod];
            }else{
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_folderexists", @"")];
                [SVProgressHUD dismiss];
                
            }
        }
        
    }];
    
}

- (void)top_creatDropBoxFolderMothod
{
    NSString *creatFolderPath = [NSString stringWithFormat:@"/%@",self.folderTextField.text];
    if (self.dropBoxCurrentItem) {
        creatFolderPath = [NSString stringWithFormat:@"%@/%@",self.dropBoxCurrentItem.pathLower,self.folderTextField.text];
    }
    WeakSelf(ws);
    [[self.dropBoxContentClient.filesRoutes createFolderV2:creatFolderPath] setResponseBlock:^(DBFILESCreateFolderResult * _Nullable result, DBFILESCreateFolderError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        [SVProgressHUD dismiss];
        
        if (result) {
            NSLog(@"%@\n", result);
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_createdsuccessfully", @"")];
            if (ws.top_reloadCreatNewFolderWithListBlock) {
                ws.top_reloadCreatNewFolderWithListBlock();
            }
            [ws dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"%@\n%@\n", routeError, networkError);
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_creationfailed", @"")];
            
        }
        
    }];
}

#pragma mark- OneDrive
- (void)top_oneDriveCreatNewFolder
{
    NSString *itemId = @"root";
    if (self.oneDrivecurrentItem) {
        itemId = self.oneDrivecurrentItem.id;
    }
    ODChildrenCollectionRequest *childrenRequest = [[[[self.oneDriveClient drive] items:itemId] children] request];
    WeakSelf(ws);
    [childrenRequest getWithCompletion:^(ODCollection *response, ODChildrenCollectionRequest *nextRequest, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error){
                if (response.value){
                    __block BOOL isCortentFile = NO;
                    [response.value enumerateObjectsUsingBlock:^(ODItem *item, NSUInteger index, BOOL *stop){
                        if ([item.name isEqualToString:ws.folderTextField.text]) {
                            
                            isCortentFile = YES;
                            *stop = YES;
                            return;
                        }
                    }];
                    if (isCortentFile == YES) {
                        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_folderexists", @"")];
                        [SVProgressHUD dismiss];
                        
                    }else{
                        [ws top_creatOneDriveFolderMothod];
                    }
                }
            }else{
                NSLog(@"error===%@",error);
                [SVProgressHUD dismiss];
            }
        });
    }];
}
- (void)top_creatOneDriveFolderMothod
{
    ODItem *newFolder = [[ODItem alloc] initWithDictionary:@{[ODNameConflict rename].key : [ODNameConflict rename].value}];
    newFolder.name = self.folderTextField.text;
    newFolder.folder = [[ODFolder alloc] init];
    
    NSString *creatFolderPath = @"root";
    if (self.oneDrivecurrentItem) {
        creatFolderPath = self.oneDrivecurrentItem.id;
    }
    WeakSelf(ws);
    [[[[[self.oneDriveClient drive] items:creatFolderPath] children] request] addItem:newFolder withCompletion:^(ODItem *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (response){
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_createdsuccessfully", @"")];
                if (ws.top_reloadCreatNewFolderWithListBlock) {
                    ws.top_reloadCreatNewFolderWithListBlock();
                }
                [ws dismissViewControllerAnimated:YES completion:nil];
            }else{
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_creationfailed", @"")];
                
            }
        });
        
    }];
}

@end
