#import "TOPUploadFileDriveCollectionVC.h"
#import "TOPOneDriveFolderCollectionViewCell.h"
#import "TOPNewFolderInDriveViewController.h"
#import "DriveDownloadManger.h"

#define DefaultSize (1024*1024)*10.0

@interface TOPUploadFileDriveCollectionVC ()
@property UIRefreshControl *refreshControl;
@property NSMutableDictionary *thumbnails;
@property (nonatomic, readwrite, strong) BOXFolder *folder;
@property (nonatomic, assign) CGFloat  totalSizeNum;
@property (nonatomic,strong) NSProgress *progress;
@property (nonatomic,strong) UIButton *bottomConfirmBut;
@end
static void *ProgressObserverContext = &ProgressObserverContext;
@implementation TOPUploadFileDriveCollectionVC
static NSString * const reuseIdentifier = @"Cell";

-(instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(TOPScreenWidth, 65);
    layout.minimumInteritemSpacing = 0 ;
    layout.minimumLineSpacing = 1;
    layout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
    return [super initWithCollectionViewLayout:layout];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
        NSMutableArray *currentDriceArrays = [[DriveDownloadManger sharedSingleton] selectDownloadDriveArrays];
        if (currentDriceArrays.count >0) {
            [self.bottomConfirmBut setTitle:[NSString stringWithFormat:@"%@ (%ld)",NSLocalizedString(@"topscan_importfile", @""),currentDriceArrays.count] forState:UIControlStateNormal];
        }else{
            [self.bottomConfirmBut setTitle:NSLocalizedString(@"topscan_importfile", @"") forState:UIControlStateNormal];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.boxItems = [NSMutableArray array];
    self.googleitems = [NSMutableArray array];
    self.dropBoxItems = [NSMutableArray array];
    self.itemsLookup = [NSMutableArray array];
    self.oneDriveItems = [NSMutableDictionary dictionary];
    self.thumbnails = [NSMutableDictionary dictionary];
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.navigationController.navigationBar.barTintColor =  [UIColor whiteColor];
    
    self.collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xF1F1F1)];
    [self.collectionView registerNib:[UINib nibWithNibName:@"TOPOneDriveFolderCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView
     registerClass:[UICollectionReusableView class]
     forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
     withReuseIdentifier:@"noneSectionFooter"];
    [self.collectionView
     registerClass:[UICollectionReusableView class]
     forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
     withReuseIdentifier:@"noneSectionHeader"];
    [self.collectionView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.collectionView.alwaysBounceVertical = YES;
    [self top_loadRequestFourListData];
    if (self.openDrivetype == TOPDriveOpenStyleTypeUpload) {
        UIButton * saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        saveBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [saveBtn setImage:[UIImage imageNamed:@"blackAddFolder"] forState:UIControlStateNormal];
        [saveBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 22, 0, 0)];
        
        [saveBtn addTarget:self action:@selector(top_uploadFile_ClickNewFolder) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * barItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
        self.navigationItem.rightBarButtonItem = barItem;
    }
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
        [confirmButton setTitle:NSLocalizedString(@"topscan_importfile", @"") forState:UIControlStateNormal];
    }else{
        [confirmButton setTitle:NSLocalizedString(@"topscan_upload", @"") forState:UIControlStateNormal];
    }
    [confirmButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    confirmButton.titleLabel.font = PingFang_R_FONT_(16);
    [confirmButton setBackgroundColor:TOPAPPGreenColor];
    [self.view addSubview:confirmButton];
    [confirmButton addTarget:self action:@selector(top_uploadFileClick:) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.layer.cornerRadius= 7;
    confirmButton.clipsToBounds = YES;
    self.bottomConfirmBut = confirmButton;
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-10-TOPBottomSafeHeight);
        make.leading.equalTo(self.view).offset(25);
        make.trailing.equalTo(self.view).offset(-25);
        make.height.mas_offset(49);
    }];
    
    [self top_setupBack];
}

#pragma mark -拉取列表数据
- (void)top_loadRequestFourListData
{
    switch (self.uploadDriveStyle) {
        case TOPDownLoadDataStyleDefaultGoogle:
        {
            [self top_fetchDriveFiles];
        }
            break;
        case TOPDownLoadDataStyleStyleBox:
        {
            if (!self.contentClient){
                self.contentClient = [BOXContentClient defaultClient];
            }
            if (self.contentClient){
                [self top_loadChildren];
            }
        }
            break;
        case TOPDownLoadDataStyleStyleDropBox:
        {
            if (!self.dropBoxContentClient){
                NSString *dbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
                self.dropBoxContentClient = [[DBUserClient alloc] initWithAccessToken:dbAccessToken];
            }
            if (self.dropBoxContentClient){
                [self top_loadChildren];
            }
        }
            break;
        case TOPDownLoadDataStyleStyleOneDrice:
        {
            if (!self.oneDriveClient){
                self.oneDriveClient = [ODClient loadCurrentClient];
            }
            if (self.oneDriveClient){
                [self top_loadChildren];
            }
        }
            break;
        default:
            break;
    }
}

- (void)top_uploadFileClick:(UIButton *)sender
{
    [self top_originalSizeShare];
}
#pragma mark - 新建文件夹
- (void)top_uploadFile_ClickNewFolder
{
    TOPNewFolderInDriveViewController *newFolderVC = [[TOPNewFolderInDriveViewController alloc] init];
    switch (self.uploadDriveStyle) {
        case TOPDownLoadDataStyleDefaultGoogle:
            if (self.googleCurrentItem) {
                newFolderVC.currentGoogleFileDrive = self.googleCurrentItem;
            }
            newFolderVC.googleDriveService = self.googleDriveService;
            break;
        case TOPDownLoadDataStyleStyleBox:
            if (self.boxCurrentItem) {
                newFolderVC.boxCurrentItem = self.boxCurrentItem;
            }
            newFolderVC.boxContentClient = self.contentClient;
            break;
        case TOPDownLoadDataStyleStyleDropBox:
            if (self.dropBoxCurrentItem) {
                newFolderVC.dropBoxCurrentItem = self.dropBoxCurrentItem;
            }
            newFolderVC.dropBoxContentClient = self.dropBoxContentClient;
            break;
        case TOPDownLoadDataStyleStyleOneDrice:
            if (self.oneDrivecurrentItem) {
                newFolderVC.oneDrivecurrentItem = self.oneDrivecurrentItem;
            }
            newFolderVC.oneDriveClient = self.oneDriveClient;
            break;
        default:
            break;
    }
    newFolderVC.top_reloadCreatNewFolderWithListBlock = ^{
        [self top_loadRequestFourListData];
    };
    newFolderVC.uploadDriveStyle = self.uploadDriveStyle;
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:newFolderVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark - 返回按钮
- (void)top_setupBack {
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(back)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(back)];
    }
}
- (void)top_initBackButton:(nullable NSString *)imgName withSelector:(SEL)selector{
    TOPImageTitleButton * btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
    CGRect frameInNaviView = [self.navigationController.view convertRect:btn.frame fromView:btn.superview];
    NSLog(@"frameInNaviView==%@",NSStringFromCGRect(frameInNaviView));
}
- (void)back{
    switch (self.uploadDriveStyle) {
        case TOPDownLoadDataStyleDefaultGoogle:
        {
            if (!self.googleCurrentItem){
                [[DriveDownloadManger sharedSingleton].selectDownloadDriveArrays removeAllObjects];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }else{
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        }
            break;
        case TOPDownLoadDataStyleStyleOneDrice:
        {
            if (!self.oneDrivecurrentItem){
                [[DriveDownloadManger sharedSingleton].selectDownloadDriveArrays removeAllObjects];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }else{
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        }
            break;
        case TOPDownLoadDataStyleStyleDropBox:
        {
            if (!self.dropBoxCurrentItem){
                [[DriveDownloadManger sharedSingleton].selectDownloadDriveArrays removeAllObjects];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }else{
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        }
            break;
        case TOPDownLoadDataStyleStyleBox:
        {
            if (!self.boxCurrentItem){
                [[DriveDownloadManger sharedSingleton].selectDownloadDriveArrays removeAllObjects];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }else{
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        }
            break;
        default:
            break;
    }
}
- (void)selectAction:(UIButton *)sender
{
}

- (BOOL)isImageType:(NSString *)itemName {
    NSRange range = [itemName rangeOfString:@"\\.jpeg|\\.jpg|\\.JPEG|\\.JPG|\\.png|\\.PNG|\\.pdf|\\.PDF" options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}

- (void)refresh
{
    switch (self.uploadDriveStyle) {
        case TOPDownLoadDataStyleStyleBox:
            [self top_loadChildren];
            break;
        case TOPDownLoadDataStyleDefaultGoogle:
            [self top_fetchDriveFiles];
            break;
        default:
            break;
    }
}
- (void)top_fetchItemsWithCompletion:(void (^)(NSArray *items, BOOL fromCache, NSError *error))externalCompletionBlock
{
    BOXFolderRequest *folderRequest = [self.contentClient folderInfoRequestWithID:self.boxCurrentItem?self.boxCurrentItem.modelID:BOXAPIFolderIDRoot];
    folderRequest.requestAllFolderFields = YES;
    void (^internalCompletionBlock)(NSArray *, BOOL, NSError *) = ^void(NSArray *items, BOOL fromCache, NSError *error) {
        [BOXDispatchHelper callCompletionBlock:^{
            if (!error) {
                if (items.count == 0) {
                    if (!fromCache) {
                        [self switchToEmptyStateWithError:nil];
                    }
                } else {
                }
            } else if (!fromCache && self.collectionView.visibleCells.count < 1) {
                [self switchToEmptyStateWithError:error];
            }
            if (externalCompletionBlock) {
                externalCompletionBlock(items, fromCache, error);
            }
        } onMainThread:YES];
    };
    
    void (^itemFetchBlock)(BOXFolder *, BOOL fromCache, NSError *) = ^void(BOXFolder *folder, BOOL fromCache, NSError *error) {
        if (error.code == BOXContentSDKAPIErrorBadRequest ||
            error.code == BOXContentSDKAPIErrorUnauthorized ||
            error.code == BOXContentSDKAPIErrorForbidden ||
            error.code == BOXContentSDKAPIErrorNotFound) {
            internalCompletionBlock(nil, fromCache, error);
        } else {
            if (folder && !error) {
                [self setCurrentFolder:folder];
            }
            if (fromCache) {
                [self fetchItemsInFolder:self.folder cacheBlock:^(NSArray *items, NSError *error){
                    internalCompletionBlock(items, YES, error);
                } refreshBlock:nil];
            } else {
                [self fetchItemsInFolder:self.folder cacheBlock:nil refreshBlock:^(NSArray *items, NSError *error) {
                    internalCompletionBlock(items, NO, error);
                }];
            }
        }
    };
    
    [folderRequest performRequestWithCached:^(BOXFolder *folder, NSError *error) {
        itemFetchBlock(folder, YES, error);
        
    } refreshed:^(BOXFolder *folder, NSError *error) {
        itemFetchBlock(folder, NO, error);
    }];
}
- (void)setCurrentFolder:(BOXFolder *)folder
{
    self.folder = folder;
    if ([self.folder isRoot]) {
        self.title = @"All Files";
    } else {
        self.title = self.folder.name;
    }
}

- (void)fetchItemsInFolder:(BOXFolder *)folder cacheBlock:(void (^)(NSArray *items, NSError *error))cacheBlock refreshBlock:(void (^)(NSArray *items, NSError *error))refreshBlock
{
    BOXFolderItemsRequest *request = [self.contentClient folderItemsRequestWithID:folder.modelID];
    [request setRequestAllItemFields:YES];
    [request performRequestWithCached:cacheBlock refreshed:refreshBlock];
}

- (void)switchToEmptyStateWithError:(NSError *)error
{
    NSString *errorMessage = nil;
    if (error == nil) {
        errorMessage = @"This folder is empty.";
    } else {
        errorMessage = @"Unable to load contents of folder.";
    }
    
}

- (void)top_loadChildren
{
    WeakSelf(ws);
    switch (self.uploadDriveStyle) {
        case TOPDownLoadDataStyleStyleBox:
        {
            [self.boxItems removeAllObjects];
            [self top_fetchItemsWithCompletion:^(NSArray *items, BOOL fromCache, NSError *error) {
                if (items && !error) {
                    items = [ws filterItems:items];
                    [items enumerateObjectsUsingBlock:^(BOXFile *fileItem, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ( fileItem.isFolder) {
                            [ws.boxItems addObject:fileItem];
                        }else{
                            if ([[fileItem.extension lowercaseString] isEqualToString:@"pdf"] || [[fileItem.extension lowercaseString] isEqualToString:@"jpg"] || [[fileItem.extension lowercaseString] isEqualToString:@"jpeg"] || [[fileItem.extension lowercaseString] isEqualToString:@"png"]) {
                                [ws.boxItems addObject:fileItem];
                            }
                        }
                    }];
                    
                    [SVProgressHUD dismiss];
                    [ws.collectionView reloadData];
                    [ws.refreshControl endRefreshing];
                }
            }];
        }
            break;
        case TOPDownLoadDataStyleStyleDropBox:
        {
            NSString *searchPath = @"";
            if (self.dropBoxCurrentItem) {
                searchPath = self.dropBoxCurrentItem.pathDisplay;
            }
            [[self.dropBoxContentClient.filesRoutes listFolder:searchPath]
             setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
                if (result) {
                    [self top_displayPhotos:result.entries];
                } else {
                    [SVProgressHUD dismiss];
                    NSString *title = @"";
                    NSString *message = @"";
                    if (routeError) {
                        title = @"Route-specific error";
                        if ([routeError isPath]) {
                            message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
                        }
                    } else {
                        // Generic request error
                        title = @"Generic request error";
                        if ([error isInternalServerError]) {
                            DBRequestInternalServerError *internalServerError = [error asInternalServerError];
                            message = [NSString stringWithFormat:@"%@", internalServerError];
                        } else if ([error isBadInputError]) {
                            DBRequestBadInputError *badInputError = [error asBadInputError];
                            message = [NSString stringWithFormat:@"%@", badInputError];
                        } else if ([error isAuthError]) {
                            DBRequestAuthError *authError = [error asAuthError];
                            message = [NSString stringWithFormat:@"%@", authError];
                        } else if ([error isRateLimitError]) {
                            DBRequestRateLimitError *rateLimitError = [error asRateLimitError];
                            message = [NSString stringWithFormat:@"%@", rateLimitError];
                        } else if ([error isHttpError]) {
                            DBRequestHttpError *genericHttpError = [error asHttpError];
                            message = [NSString stringWithFormat:@"%@", genericHttpError];
                        } else if ([error isClientError]) {
                            DBRequestClientError *genericLocalError = [error asClientError];
                            message = [NSString stringWithFormat:@"%@", genericLocalError];
                        }
                    }
                    
                    UIAlertController *alertController =
                    [UIAlertController alertControllerWithTitle:title
                                                        message:message
                                                 preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok" ,@"")
                                                                        style:(UIAlertActionStyle)UIAlertActionStyleCancel
                                                                      handler:nil]];
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                }
            }];
        }
            break;
        case TOPDownLoadDataStyleStyleOneDrice:
        {
            NSString *itemId = (self.oneDrivecurrentItem) ? self.oneDrivecurrentItem.id : @"root";
            ODChildrenCollectionRequest *childrenRequest = [[[[self.oneDriveClient drive] items:itemId] children] request];
            if (![self.oneDriveClient serviceFlags][@"NoThumbnails"]){
                [childrenRequest expand:@"thumbnails"];
            }
            [self top_loadChildrenWithRequest:childrenRequest];
        }
            break;
        default:
            break;
    }
}
- (void)top_displayPhotos:(NSArray<DBFILESMetadata *> *)folderEntries {
    [self.dropBoxItems removeAllObjects];
    for (DBFILESMetadata *entry in folderEntries) {
        if ([entry isKindOfClass:[DBFILESFolderMetadata class]]) {
            [self.dropBoxItems addObject:entry];
            
        }else if ([entry isKindOfClass:[DBFILESFileMetadata class]]) {
            NSString *itemName = entry.name;
            if ([self isImageType:itemName]) {
                [self.dropBoxItems addObject:entry];
            }
        }
    }
    [self top_loadThumbnails:self.dropBoxItems];
    [SVProgressHUD dismiss];
    [self.collectionView reloadData];
}
- (void)top_loadThumbnails:(NSArray *)items{
    switch (self.uploadDriveStyle) {
        case TOPDownLoadDataStyleStyleDropBox:
        {
            for (DBFILESMetadata *item in items){
                if ([item isKindOfClass:[DBFILESFileMetadata class]]){
                    DBFILESFileMetadata *fileItem  = (DBFILESFileMetadata *)item;
                    [[self.dropBoxContentClient.filesRoutes getThumbnailData:item.pathDisplay] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESThumbnailError * _Nullable routeError, DBRequestError * _Nullable networkError, NSData * _Nullable fileData) {
                        if (result) {
                            
                            self.thumbnails[fileItem.id_] = [UIImage imageWithData:fileData];
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                [self.collectionView reloadData];
                            });
                        }
                    }];
                }
            }
        }
            break;
        case TOPDownLoadDataStyleStyleOneDrice:
        {
            for (ODItem *item in items){
                if ([item thumbnails:0]){
                    [[[[[[self.oneDriveClient drive] items:item.id] thumbnails:@"0"] small] contentRequest] downloadWithCompletion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                        if (!error){
                            self.thumbnails[item.id] = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                [self.collectionView reloadData];
                            });
                        }
                    }];
                }
            }
        }
            break;
        default:
            break;
    }
    
}


- (NSArray *)filterItems:(NSArray *)items
{
    return items;
}

- (BOXItem *)itemForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.boxItems.count <= indexPath.row) {
        return nil;
    }
    return (BOXItem *)[self.boxItems objectAtIndex:indexPath.row];
}

- (GTLRDrive_File *)googleItemForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.googleitems.count <= indexPath.row) {
        return nil;
    }
    return (GTLRDrive_File *)[self.googleitems objectAtIndex:indexPath.row];
}
- (DBFILESMetadata *)dropBoxItemForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dropBoxItems.count <= indexPath.row) {
        return nil;
    }
    return (DBFILESMetadata *)[self.dropBoxItems objectAtIndex:indexPath.row];
}

- (ODItem *)oneDriveItemForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *itemId = self.itemsLookup[indexPath.row];
    return self.oneDriveItems[itemId];
}
#pragma mark OneDrive CollectionView Methods
- (TOPUploadFileDriveCollectionVC *)collectionViewWithOneDriveItem:(ODItem *)item;
{
    TOPUploadFileDriveCollectionVC *newController = [[TOPUploadFileDriveCollectionVC alloc] init];
    newController.title = item.name;
    newController.oneDrivecurrentItem = item;
    newController.oneDriveClient = self.oneDriveClient;
    newController.uploadDriveStyle = self.uploadDriveStyle;
    if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
        newController.downloadFileSavePath = self.downloadFileSavePath;
        newController.downloadFileType = self.downloadFileType;
        newController.docId = self.docId;
    }else{
        newController.fileType = self.fileType;
        newController.uploadDatas = [NSMutableArray arrayWithArray:self.uploadDatas];
        newController.isSingleUpload = self.isSingleUpload;
    }
    newController.openDrivetype = self.openDrivetype;
    return newController;
}
#pragma mark CollectionView Methods
- (TOPUploadFileDriveCollectionVC *)collectionViewWithDropBoxItem:(DBFILESMetadata *)item;
{
    TOPUploadFileDriveCollectionVC *newController = [[TOPUploadFileDriveCollectionVC alloc] init];
    newController.title = item.name;
    newController.dropBoxCurrentItem = item;
    newController.dropBoxContentClient = self.dropBoxContentClient;
    newController.uploadDriveStyle = self.uploadDriveStyle;
    if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
        newController.downloadFileSavePath = self.downloadFileSavePath;
        newController.downloadFileType = self.downloadFileType;
        newController.docId = self.docId;
    }else{
        newController.fileType = self.fileType;
        newController.uploadDatas = [NSMutableArray arrayWithArray:self.uploadDatas];
        newController.isSingleUpload = self.isSingleUpload;
    }
    newController.openDrivetype = self.openDrivetype;
    return newController;
}
#pragma mark CollectionView Methods
- (TOPUploadFileDriveCollectionVC *)collectionViewWithItem:(BOXItem *)item;
{
    TOPUploadFileDriveCollectionVC *newController = [[TOPUploadFileDriveCollectionVC alloc] init];
    newController.title = item.name;
    newController.boxCurrentItem = item;
    newController.contentClient = self.contentClient;
    newController.uploadDriveStyle = self.uploadDriveStyle;
    
    if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
        newController.downloadFileSavePath = self.downloadFileSavePath;
        newController.downloadFileType = self.downloadFileType;
        newController.docId = self.docId;
    }else{
        newController.fileType = self.fileType;
        newController.uploadDatas = [NSMutableArray arrayWithArray:self.uploadDatas];
        newController.isSingleUpload = self.isSingleUpload;
    }
    newController.openDrivetype = self.openDrivetype;
    return newController;
}
#pragma mark CollectionView Methods
- (TOPUploadFileDriveCollectionVC *)collectionViewWithGoogleItem:(GTLRDrive_File *)item;
{
    TOPUploadFileDriveCollectionVC *newController = [[TOPUploadFileDriveCollectionVC alloc] init];
    newController.title = item.name;
    if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
        newController.downloadFileSavePath = self.downloadFileSavePath;
        newController.downloadFileType = self.downloadFileType;
        newController.docId = self.docId;
    }else{
        newController.fileType = self.fileType;
        newController.uploadDatas = [NSMutableArray arrayWithArray:self.uploadDatas];
        newController.isSingleUpload = self.isSingleUpload;
    }
    newController.openDrivetype = self.openDrivetype;
    newController.googleCurrentItem = item;
    newController.googleDriveService = self.googleDriveService;
    newController.uploadDriveStyle = self.uploadDriveStyle;
    return newController;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.uploadDriveStyle == TOPDownLoadDataStyleDefaultGoogle) {
        return  [self.googleitems count];
    }
    if (self.uploadDriveStyle == TOPDownLoadDataStyleStyleDropBox) {
        return  [self.dropBoxItems count];
    }
    if (self.uploadDriveStyle == TOPDownLoadDataStyleStyleOneDrice) {
        return  [self.oneDriveItems count];
    }
    return [self.boxItems count];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.uploadDriveStyle) {
        case TOPDownLoadDataStyleDefaultGoogle:
        {
            __block GTLRDrive_File *item = [self googleItemForRowAtIndexPath:indexPath];
            if ([item.mimeType isEqualToString:@"application/vnd.google-apps.folder"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self collectionViewWithGoogleItem:item].hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:[self collectionViewWithGoogleItem:item] animated:YES];
                });
            }else     if ([item.mimeType isEqualToString:@"image/png"] ||[item.mimeType isEqualToString:@"application/pdf"]||[item.mimeType isEqualToString:@"image/jpg"] ||[item.mimeType isEqualToString:@"image/jpeg"]) {
                if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
                    NSMutableArray *currentDriceArrays = [[DriveDownloadManger sharedSingleton] selectDownloadDriveArrays];
                    BOOL isContents = NO;
                    for (int i = 0; i < currentDriceArrays.count; i++) {
                        GTLRDrive_File *itemDrive = currentDriceArrays[i];
                        if ([item.identifier isEqualToString:itemDrive.identifier]) {
                            //设置选中时的颜色
                            [[DriveDownloadManger sharedSingleton].selectDownloadDriveArrays removeObject:itemDrive];
                            TOPOneDriveFolderCollectionViewCell *cell = (TOPOneDriveFolderCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                            [self top_drive_removeDiveItemCellWith:cell];
                            isContents = YES;
                            break;
                        }
                    }
                    if (isContents == NO) {
                        TOPOneDriveFolderCollectionViewCell *cell = (TOPOneDriveFolderCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                        [[DriveDownloadManger sharedSingleton].selectDownloadDriveArrays addObject:item];
                        [self top_drive_selectDriveCellwith:cell];
                    }
                }
            }
        }
            break;
        case  TOPDownLoadDataStyleStyleBox:
        {
            __block BOXItem *item = [self itemForRowAtIndexPath:indexPath];
            if (item.isFolder){
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self collectionViewWithItem:item].hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:[self collectionViewWithItem:item] animated:YES];
                });
            }    else if (item.isFile){
                
                if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
                    NSMutableArray *currentDriceArrays = [[DriveDownloadManger sharedSingleton] selectDownloadDriveArrays];
                    BOOL isContents = NO;
                    for (int i = 0; i < currentDriceArrays.count; i++) {
                        BOXItem *itemDrive = currentDriceArrays[i];
                        if ([item.modelID isEqualToString:itemDrive.modelID]) {
                            //设置选中时的颜色
                            TOPOneDriveFolderCollectionViewCell *cell = (TOPOneDriveFolderCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                            [[DriveDownloadManger sharedSingleton].selectDownloadDriveArrays removeObject:itemDrive];
                            [self top_drive_removeDiveItemCellWith:cell];
                            isContents = YES;
                            break;
                        }
                    }
                    if (isContents == NO) {
                        TOPOneDriveFolderCollectionViewCell *cell = (TOPOneDriveFolderCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                        [[DriveDownloadManger sharedSingleton].selectDownloadDriveArrays addObject:item];
                        [self top_drive_selectDriveCellwith:cell];
                    }
                    
                }
            }
        }
            break;
        case TOPDownLoadDataStyleStyleDropBox:
        {
            __block DBFILESMetadata *item = [self dropBoxItemForRowAtIndexPath:indexPath];
            if ([item isKindOfClass:[DBFILESFolderMetadata class]]) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.navigationController pushViewController:[self collectionViewWithDropBoxItem:item] animated:YES];
                });
            }else if ([item isKindOfClass:[DBFILESFileMetadata class]]) {
                
                DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata *)item;
                if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
                    
                    NSMutableArray *currentDriceArrays = [[DriveDownloadManger sharedSingleton] selectDownloadDriveArrays];
                    BOOL isContents = NO;
                    for (int i = 0; i < currentDriceArrays.count; i++) {
                        DBFILESFileMetadata *itemDrive = currentDriceArrays[i];
                        if ([fileMetadata.id_ isEqualToString:itemDrive.id_]) {
                            TOPOneDriveFolderCollectionViewCell *cell = (TOPOneDriveFolderCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                            [[DriveDownloadManger sharedSingleton].selectDownloadDriveArrays removeObject:itemDrive];
                            [self top_drive_removeDiveItemCellWith:cell];
                            isContents = YES;
                            break;
                        }
                    }
                    if (isContents == NO) {
                        TOPOneDriveFolderCollectionViewCell *cell = (TOPOneDriveFolderCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                        [[DriveDownloadManger sharedSingleton].selectDownloadDriveArrays addObject:item];
                        [self top_drive_selectDriveCellwith:cell];
                    }
                }
            }
        }
            break;
        case TOPDownLoadDataStyleStyleOneDrice:
        {
            __block ODItem *item = [self oneDriveItemForRowAtIndexPath:indexPath];
            if (item.folder){
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self collectionViewWithOneDriveItem:item].hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:[self collectionViewWithOneDriveItem:item] animated:YES];
                });
            }   else if (item.file){
                
                if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
                    
                    NSMutableArray *currentDriceArrays = [[DriveDownloadManger sharedSingleton] selectDownloadDriveArrays];
                    BOOL isContents = NO;
                    for (int i = 0; i < currentDriceArrays.count; i++) {
                        ODItem *itemDrive = currentDriceArrays[i];
                        if ([item.id isEqualToString:itemDrive.id]) {
                            TOPOneDriveFolderCollectionViewCell *cell = (TOPOneDriveFolderCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                            [[DriveDownloadManger sharedSingleton].selectDownloadDriveArrays removeObject:itemDrive];
                            [self top_drive_removeDiveItemCellWith:cell];
                            isContents = YES;
                            break;
                        }
                    }
                    if (isContents == NO) {
                        TOPOneDriveFolderCollectionViewCell *cell = (TOPOneDriveFolderCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                        [[DriveDownloadManger sharedSingleton].selectDownloadDriveArrays addObject:item];
                        [self top_drive_selectDriveCellwith:cell];
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"noneSectionHeader" forIndexPath:indexPath];
        reusableview = headerView;
    }else if (kind == UICollectionElementKindSectionFooter){
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"noneSectionFooter" forIndexPath:indexPath];
        reusableview = headerView;
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    
    return CGSizeMake(0, 0);
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.frame.size.width, 66);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.uploadDriveStyle == TOPDownLoadDataStyleDefaultGoogle) {
        GTLRDrive_File *item = [self googleItemForRowAtIndexPath:indexPath];
        TOPOneDriveFolderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        [cell.contentTitleLabel setText:item.name];
        cell.creatTimeLabel.text = [self top_changeDriveCreateDate:item.modifiedTime.date];
        if ([item.mimeType isEqualToString:@"image/png"] ||[item.mimeType isEqualToString:@"application/pdf"] ||[item.mimeType isEqualToString:@"image/jpg"]||[item.mimeType isEqualToString:@"image/jpeg"]) {
            [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:item.thumbnailLink] placeholderImage:[UIImage imageNamed:@"top_Placeholder_drive"]];
            cell.creatTimeLabel.hidden = NO;
            cell.topTitleConstraint.constant = 15;
            [self changeFileCellTextWith:cell withIndexPath:indexPath];
        }
        if ([item.mimeType isEqualToString:@"application/vnd.google-apps.folder"]) {
            [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]]];
            cell.coverImageView.image = [UIImage imageNamed:@"top_drive_newfolder_b"];
            cell.contentTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
            cell.creatTimeLabel.hidden = YES;
            cell.selectCoverImageView.hidden = YES;
            cell.topTitleConstraint.constant = 27;
        }
        return cell;
    }
    if (self.uploadDriveStyle == TOPDownLoadDataStyleStyleDropBox) {
        DBFILESMetadata *item = [self dropBoxItemForRowAtIndexPath:indexPath];
        TOPOneDriveFolderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        [cell.contentTitleLabel setText:item.name];
        if ([item isKindOfClass:[DBFILESFileMetadata class]]) {
            DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata *)item;
            cell.coverImageView.image = self.thumbnails[fileMetadata.id_]?self.thumbnails[fileMetadata.id_]:[UIImage imageNamed:@"top_Placeholder_drive"];
            cell.creatTimeLabel.text = [self top_changeDriveCreateDate:fileMetadata.serverModified];
            cell.contentTitleLabel.textColor = UIColorFromRGB(0xB7B7B7);
            cell.creatTimeLabel.hidden = NO;
            cell.topTitleConstraint.constant = 15;
            [self changeFileCellTextWith:cell withIndexPath:indexPath];
        }
        if ([item isKindOfClass:[DBFILESFolderMetadata class]]) {
            cell.creatTimeLabel.text = @"";
            [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]]];
            cell.coverImageView.image = [UIImage imageNamed:@"top_drive_newfolder_b"];
            cell.contentTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
            cell.creatTimeLabel.hidden = YES;
            cell.selectCoverImageView.hidden = YES;
            cell.topTitleConstraint.constant = 27;
        }
        return cell;
    }
    if (self.uploadDriveStyle ==TOPDownLoadDataStyleStyleOneDrice) {
        ODItem *item = [self oneDriveItemForRowAtIndexPath:indexPath];
        TOPOneDriveFolderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        [cell.contentTitleLabel setText:item.name];
        cell.creatTimeLabel.text = [self top_changeDriveCreateDate:item.createdDateTime];
        if (item.file) {
            if (self.thumbnails[item.id]){
                UIImage *image = self.thumbnails[item.id];
                cell.coverImageView.image = image?image:[UIImage imageNamed:@"top_Placeholder_drive"];
            }
            cell.contentTitleLabel.textColor = UIColorFromRGB(0xB7B7B7);
            cell.creatTimeLabel.hidden = NO;
            cell.topTitleConstraint.constant = 15;
            [self changeFileCellTextWith:cell withIndexPath:indexPath];
        }
        if (item.folder) {
            cell.coverImageView.image = [UIImage imageNamed:@"top_drive_newfolder_b"];
            cell.contentTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
            cell.creatTimeLabel.hidden = YES;
            cell.selectCoverImageView.hidden = YES;
            cell.topTitleConstraint.constant = 27;
        }
        
        if (item.folder){
            [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]]];
        }
        return cell;
    }
    BOXItem *item = [self itemForRowAtIndexPath:indexPath];
    TOPOneDriveFolderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.boxItem = item;
    cell.creatTimeLabel.text = [self top_changeDriveCreateDate:item.createdDate];
    [self changeFileCellTextWith:cell withIndexPath:indexPath];
    if (item.isFolder){
        [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]]];
        cell.selectCoverImageView.hidden = YES;
    }
    return cell;
}

- (void)changeFileCellTextWith:(TOPOneDriveFolderCollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
        cell.creatTimeLabel.textColor  = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
        cell.selectCoverImageView.hidden = NO;
        cell.contentTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
        NSMutableArray *currentDriceArrays = [[DriveDownloadManger sharedSingleton] selectDownloadDriveArrays];
        BOOL isContents = NO;
        switch (self.uploadDriveStyle) {
            case TOPDownLoadDataStyleStyleBox:
            {
                BOXItem *item = [self itemForRowAtIndexPath:indexPath];
                for (int i = 0; i < currentDriceArrays.count; i++) {
                    BOXItem *itemDrive = currentDriceArrays[i];
                    if ([item.modelID isEqualToString:itemDrive.modelID]) {
                        //设置选中时的颜色
                        [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:UIColorFromRGB(0xEBEBEB)]];
                        cell.selectCoverImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
                        isContents = YES;
                    }
                }
            }
                break;
            case TOPDownLoadDataStyleStyleDropBox:
            {
                DBFILESMetadata *item = [self dropBoxItemForRowAtIndexPath:indexPath];
                DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata *)item;
                for (int i = 0; i < currentDriceArrays.count; i++) {
                    DBFILESFileMetadata *itemDrive = currentDriceArrays[i];
                    if ([fileMetadata.id_ isEqualToString:itemDrive.id_]) {
                        //设置选中时的颜色
                        [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:UIColorFromRGB(0xEBEBEB)]];
                        cell.selectCoverImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
                        isContents = YES;
                    }
                }
            }
                break;
            case TOPDownLoadDataStyleDefaultGoogle:
            {
                __block GTLRDrive_File *item = [self googleItemForRowAtIndexPath:indexPath];
                for (int i = 0; i < currentDriceArrays.count; i++) {
                    GTLRDrive_File *itemDrive = currentDriceArrays[i];
                    if ([item.identifier isEqualToString:itemDrive.identifier]) {
                        //设置选中时的颜色
                        [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:UIColorFromRGB(0xEBEBEB)]];
                        cell.selectCoverImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
                        isContents = YES;
                    }
                }
            }
                break;
            case TOPDownLoadDataStyleStyleOneDrice:
            {
                ODItem *item  = [self oneDriveItemForRowAtIndexPath:indexPath];
                for (int i = 0; i < currentDriceArrays.count; i++) {
                    ODItem *itemDrive = currentDriceArrays[i];
                    if ([item.id isEqualToString:itemDrive.id]) {
                        //设置选中时的颜色
                        [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:UIColorFromRGB(0xEBEBEB)]];
                        cell.selectCoverImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
                        isContents = YES;
                    }
                }
            }
                break;
            default:
                break;
        }
        if (isContents == NO) {
            [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]]];
            cell.selectCoverImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllNormal"];
        }
    }else{
        cell.creatTimeLabel.textColor  = UIColorFromRGB(0xB7B7B7);
        cell.selectCoverImageView.hidden = YES;
        cell.contentTitleLabel.textColor = UIColorFromRGB(0xB7B7B7);
    }
}
#pragma mark-Google
- (void)top_fetchDriveFiles {
    self.googleDriveService = [[GTLRDriveService alloc] init];
    self.googleDriveService.authorizer = [[[[FHGoogleLoginManager sharedInstance] currentUser] authentication] fetcherAuthorizer];
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.spaces = @"drive";
    if (self.googleCurrentItem) {
        query.q = [NSString stringWithFormat: @"'%@' in parents  and (mimeType contains 'image/png' or mimeType contains 'image/jpg' or mimeType contains 'image/jpeg'  or mimeType contains 'application/pdf' or mimeType contains 'application/vnd.google-apps.folder')",self.googleCurrentItem.identifier];
        
    }else{
        query.q = @"'root' in parents and (mimeType contains 'image/png' or mimeType contains 'image/jpg' or mimeType contains 'image/jpeg'  or mimeType contains 'application/pdf' or mimeType contains 'application/vnd.google-apps.folder')";
    }
    query.fields = @"kind,nextPageToken,files(mimeType,id,kind,name,webViewLink,thumbnailLink,trashed,modifiedTime,size,originalFilename)";
    [self.googleDriveService executeQuery:query
                        completionHandler:^(GTLRServiceTicket *callbackTicket,
                                            GTLRDrive_FileList *fileList,
                                            NSError *callbackError) {
        [self.refreshControl endRefreshing];
        if (callbackError == nil)
        {
            self.googleitems = fileList.files;
            [self.collectionView reloadData];
            [SVProgressHUD dismiss];
        }
        else
        {
            [SVProgressHUD dismiss];
        }
    }];
}

#pragma mark- oneDrive
- (void)top_onLoadedChildren:(NSArray *)children
{
    [self.oneDriveItems removeAllObjects];
    [self.itemsLookup removeAllObjects];
    [children enumerateObjectsUsingBlock:^(ODItem *item, NSUInteger index, BOOL *stop){
        if (item.folder || [item.file.mimeType isEqualToString:@"image/png"]|| [item.file.mimeType isEqualToString:@"image/jpeg"] || [item.file.mimeType isEqualToString:@"application/pdf"]) {
            if (![self.itemsLookup containsObject:item.id]){
                [self.itemsLookup addObject:item.id];
            }
            self.oneDriveItems[item.id] = item;
        }
    }];
    [self top_loadThumbnails:children];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.collectionView reloadData];
        [SVProgressHUD dismiss];
    });
}

- (void)top_loadChildrenWithRequest:(ODChildrenCollectionRequest*)childrenRequests
{
    [childrenRequests getWithCompletion:^(ODCollection *response, ODChildrenCollectionRequest *nextRequest, NSError *error){
        if (!error){
            if (response.value){
                [self top_onLoadedChildren:response.value];
            }
            if (nextRequest){
                [self top_loadChildrenWithRequest:nextRequest];
            }
        }
        else if ([error isAuthenticationError]){
            [self top_onLoadedChildren:@[]];
        }
    }];
}


- (NSString *)top_changeDriveCreateDate:(NSDate *)creatDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:[TOPScanerShare top_documentDateType]];
    NSString *strDate = [dateFormatter stringFromDate:creatDate];
    return strDate;
}

#pragma 计算选中文件的大小
- (void)top_CalculateSelectNumber:(NSMutableArray *)shareFaxList{
    [FIRAnalytics logEventWithName:@"upload_CalculateSelectNumber" parameters:nil];
    NSMutableArray * tempPathArray = [TOPDocumentHelper top_getSelectFolderPicture:shareFaxList];
    CGFloat memorySize = [TOPDocumentHelper top_totalMemorySize:tempPathArray];
    self.totalSizeNum = memorySize;
}

#pragma mark -- 分享时原图生成pdf分享和原图分享
- (void)top_originalSizeShare{
    WS(weakSelf);
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * shareArray = [NSMutableArray new];
        switch (self.fileType) {
            case TOPUpLoadToDriveFileTypePDF:
            {
                [self top_CalculateSelectNumber:self.uploadDatas];
                [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
                if (weakSelf.uploadDatas.count>0) {
                    NSMutableArray * allTempArray = [NSMutableArray new];
                    if (self.isSingleUpload) {
                        NSMutableArray * imgArray = [NSMutableArray new];
                        imgArray = [weakSelf top_singletop_documentOriginalpdfShare:weakSelf.uploadDatas];
                        [allTempArray addObjectsFromArray:imgArray];
                        
                    }else{
                        for (int i = 0; i<weakSelf.uploadDatas.count; i++) {
                            DocumentModel * model = weakSelf.uploadDatas[i];
                            NSMutableArray * imgArray = [NSMutableArray new];
                            if ([model.type isEqualToString:@"0"]) {
                                imgArray = [weakSelf top_folderOriginalpdfShare:model index:i];
                                [allTempArray addObjectsFromArray:imgArray];
                            }
                            
                            if ([model.type isEqualToString:@"1"]) {
                                imgArray = [weakSelf top_documentOriginalpdfShare:model index:i];
                                [allTempArray addObjectsFromArray:imgArray];
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.totalSizeNum>DefaultSize) {
                            [SVProgressHUD dismiss];
                            
                            if (allTempArray.count>1) {
                                [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@... (1/%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(weakSelf.uploadDatas.count)]];
                            }else{
                                [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
                            }
                        }
                    });
                    
                    for (int j = 0; j<allTempArray.count; j++) {
                        if (j<allTempArray.count) {
                            DocumentModel * model = allTempArray[j];
                            NSMutableArray * imgArray = [model.docArray mutableCopy];
                            NSString * path = [TOPDocumentHelper top_creatPDF:imgArray documentName:model.name progress:^(CGFloat myProgress) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (weakSelf.totalSizeNum>DefaultSize) {
                                        [SVProgressHUD dismiss];
                                        
                                        if (allTempArray.count>1) {
                                            [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@... (%@/%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(j +1),@(weakSelf.uploadDatas.count)]];
                                        }else{
                                            [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
                                        }
                                    }
                                    
                                });
                            }];
                            if (path) {
                                [shareArray addObject:path];
                            }
                        }
                    }
                }
            }
                break;
            case TOPUpLoadToDriveFileTypeJPG:
            {
                [TOPWHCFileManager top_removeItemAtPath:TOPCompress_Path];
                if (weakSelf.uploadDatas.count>0) {
                    if (self.isSingleUpload) {
                        shareArray =  [weakSelf top_homeChindSignleDocument:self.uploadDatas mediumSize:1.0];
                    }else{
                        shareArray =  [weakSelf top_HomeVCShare:1.0];
                    }
                }
                
            }
                break;
            case TOPUpLoadToDriveFileTypeJPG_PDF:
            {
                [self top_CalculateSelectNumber:self.uploadDatas];
                [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
                if (weakSelf.uploadDatas.count>0) {
                    NSMutableArray * allTempArray = [NSMutableArray new];
                    if (self.isSingleUpload) {
                        NSMutableArray * imgArray = [NSMutableArray new];
                        imgArray = [weakSelf top_singletop_documentOriginalpdfShare:weakSelf.uploadDatas];
                        [allTempArray addObjectsFromArray:imgArray];
                        
                    }else{
                        for (int i = 0; i<weakSelf.uploadDatas.count; i++) {
                            DocumentModel * model = weakSelf.uploadDatas[i];
                            NSMutableArray * imgArray = [NSMutableArray new];
                            if ([model.type isEqualToString:@"0"]) {
                                imgArray = [weakSelf top_folderOriginalpdfShare:model index:i];
                                [allTempArray addObjectsFromArray:imgArray];
                            }
                            if ([model.type isEqualToString:@"1"]) {
                                imgArray = [weakSelf top_documentOriginalpdfShare:model index:i];
                                [allTempArray addObjectsFromArray:imgArray];
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.totalSizeNum>DefaultSize) {
                            [SVProgressHUD dismiss];
                            
                            if (allTempArray.count>1) {
                                [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@... (1-%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(weakSelf.uploadDatas.count)]];
                            }else{
                                [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
                            }
                        }
                    });
                    for (int j = 0; j<allTempArray.count; j++) {
                        if (j<allTempArray.count) {
                            DocumentModel * model = allTempArray[j];
                            NSMutableArray * imgArray = [model.docArray mutableCopy];
                            NSString * path = [TOPDocumentHelper top_creatPDF:imgArray documentName:model.name progress:^(CGFloat myProgress) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (weakSelf.totalSizeNum>DefaultSize) {
                                        [SVProgressHUD dismiss];
                                        
                                        if (allTempArray.count>1) {
                                            [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@... (%@/%@)",NSLocalizedString(@"topscan_buildingpdf", @""),@(j +1),@(weakSelf.uploadDatas.count)]];
                                        }else{
                                            [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
                                        }
                                    }
                                    
                                });
                            }];
                            if (path) {
                                [shareArray addObject:path];
                            }
                        }
                    }
                    [TOPWHCFileManager top_removeItemAtPath:TOPCompress_Path];
                    if (weakSelf.uploadDatas.count>0) {
                        if (self.isSingleUpload) {
                            [shareArray  addObjectsFromArray:[weakSelf top_homeChindSignleDocument:self.uploadDatas mediumSize:1.0]];
                        }else{
                            [shareArray addObjectsFromArray:[weakSelf top_HomeVCShare:1.0]];
                        }
                    }
                    
                }
            }
                break;
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            [self top_uploadFileWithDatasPath:shareArray];
        });
    });
}
- (NSMutableArray *)top_HomeVCShare:(CGFloat)max {
    NSMutableArray *shareArray = @[].mutableCopy;
    for (DocumentModel * model in self.uploadDatas) {
        if ([model.type isEqualToString:@"0"]) {
            [shareArray addObjectsFromArray:[self top_folderMediumImgShare:model mediumSize:max]];
        }
        
        if ([model.type isEqualToString:@"1"]) {
            [shareArray addObjectsFromArray:[self top_documentMediumImgShare:model mediumSize:max]];
        }
        
    }
    return shareArray;
}
- (NSMutableArray *)top_homeChindSignleDocument:(NSMutableArray *)compareArray mediumSize:(CGFloat)max
{
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * signleModel in compareArray) {
        NSString * savePath = [NSString stringWithFormat:@"%@_%@.jpg",signleModel.fileName,signleModel.name];
        NSString * fullPath = signleModel.path;
        NSString * compressFile = [NSString new];
        if (compareArray.count > 5) {
            compressFile = [TOPDocumentHelper top_saveCompressPDFImage:fullPath savePath:savePath maxCompression:max];
        }else{
            compressFile = [TOPDocumentHelper top_saveCompressImage:fullPath savePath:savePath maxCompression:max];
        }
        if (compressFile.length) {
            [tempArray addObject:compressFile];
        }
    }
    return tempArray;
}

#pragma mark -- folder下压缩图片URL集合
- (NSMutableArray *)top_folderMediumImgShare:(DocumentModel*)model mediumSize:(CGFloat)max{
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * tempArray = [NSMutableArray new];
    NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:model.path documentArray:documentArray];
    for (NSString * documentPath in getArry) {
        NSArray * compareArray = [self top_documentAllPicPath:documentPath];
        for (NSString * picName in compareArray) {
            NSString * nameIndex = [NSString stringWithFormat:@"%ld",[compareArray indexOfObject:picName]+1];
            NSString * docName = [documentPath componentsSeparatedByString:@"/"].lastObject;
            NSString * savePath = [NSString stringWithFormat:@"%@_%@.jpg",docName,nameIndex];
            NSString * picPath = [documentPath stringByAppendingPathComponent:picName];
            NSString * compressFile = [NSString new];
            if (compareArray.count > 5) {
                compressFile = [TOPDocumentHelper top_saveCompressPDFImage:picPath savePath:savePath maxCompression:max];
            }else{
                compressFile = [TOPDocumentHelper top_saveCompressImage:picPath savePath:savePath maxCompression:max];
            }
            if (compressFile.length) {
                [tempArray addObject:compressFile];
            }
        }
    }
    return tempArray;
}

#pragma mark -- document下压缩图片URL集合
- (NSMutableArray *)top_documentMediumImgShare:(DocumentModel*)model mediumSize:(CGFloat)max{
    NSArray * compareArray = [self top_documentAllPicPath:model.path];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (NSString * pcStr in compareArray) {
        NSString * nameIndex = [NSString stringWithFormat:@"%ld",[compareArray indexOfObject:pcStr]+1];
        NSString * docName = [model.path componentsSeparatedByString:@"/"].lastObject;
        NSString * savePath = [NSString stringWithFormat:@"%@_%@.jpg",docName,nameIndex];
        NSString * fullPath = [NSString stringWithFormat:@"%@/%@",model.path,pcStr];
        NSString * compressFile = [NSString new];
        if (compareArray.count > 5) {
            compressFile = [TOPDocumentHelper top_saveCompressPDFImage:fullPath savePath:savePath maxCompression:max];
        }else{
            compressFile = [TOPDocumentHelper top_saveCompressImage:fullPath savePath:savePath maxCompression:max];
        }
        if (compressFile.length) {
            [tempArray addObject:compressFile];
        }
    }
    return tempArray;
}

#pragma mark -- folder文件夹下所有图片的集合
- (NSMutableArray *)top_folderOriginalpdfShare:(DocumentModel*)model index:(NSInteger)index{
    NSMutableArray * tempArray = [NSMutableArray new];
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:model.path documentArray:documentArray];
    for (int j = 0; j<getArry.count; j++) {
        NSString * documentPath = getArry[j];
        DocumentModel * folderUnderModel = [DocumentModel new];
        folderUnderModel.name = [documentPath componentsSeparatedByString:@"/"].lastObject;
        NSArray * compareArray = [self top_documentAllPicPath:documentPath];
        NSMutableArray * imgArray = [NSMutableArray new];
        for (int i = 0; i<compareArray.count; i++) {
            NSString * picName = compareArray[i];
            NSString * picPath = [documentPath stringByAppendingPathComponent:picName];
            UIImage * img = [UIImage imageWithContentsOfFile:picPath];
            if (img) {
                [imgArray addObject:img];
            }
        }
        folderUnderModel.docArray = [imgArray copy];
        [tempArray addObject:folderUnderModel];
    }
    return tempArray;
}
#pragma mark -- document文件夹下图片集合
- (NSMutableArray *)top_documentOriginalpdfShare:(DocumentModel*)model index:(NSInteger)index{
    DocumentModel * folderUnderModel = [DocumentModel new];
    folderUnderModel.name = model.name;
    NSMutableArray * tempArray = [NSMutableArray new];
    NSMutableArray * imgArray = [NSMutableArray new];
    NSArray * compareArray = [self top_documentAllPicPath:model.path];
    for (int i = 0; i<compareArray.count; i++) {
        NSString * pcStr = compareArray[i];
        NSString * fullPath = [NSString stringWithFormat:@"%@/%@",model.path,pcStr];
        UIImage * img = [UIImage imageWithContentsOfFile:fullPath];
        if (img) {
            [imgArray addObject:img];
            if (self.totalSizeNum>DefaultSize) {
                if (self.uploadDatas.count>1) {
                    [[TOPProgressStripeView shareInstance]top_showProgress:((i+1)*10.0)/(compareArray.count*10.0) withStatus:[NSString stringWithFormat:@"%@...(%@-%@)",NSLocalizedString(@"topscan_processingdoc", @""),@(index+1),@(self.uploadDatas.count)]];
                }else{
                    [[TOPProgressStripeView shareInstance]top_showProgress:((i+1)*10.0)/(compareArray.count*10.0) withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingdoc", @"")]];
                }
            }
        }
    }
    folderUnderModel.docArray = [imgArray copy];
    [tempArray addObject:folderUnderModel];
    return tempArray;
}

#pragma mark -- 单个document文件夹下图片集合
- (NSMutableArray *)top_singletop_documentOriginalpdfShare:(NSMutableArray*)compareArray{
    DocumentModel * folderUnderModel = [DocumentModel new];
    NSMutableArray * tempArray = [NSMutableArray new];
    NSMutableArray * imgArray = [NSMutableArray new];
    for (int i = 0; i<compareArray.count; i++) {
        DocumentModel *model = compareArray[i];
        if (compareArray.count == 1) {
            folderUnderModel.name = [NSString stringWithFormat:@"%@_%@",model.fileName,model.name];
        }else{
            folderUnderModel.name = model.fileName;
        }
        NSString * fullPath = model.path;
        UIImage * img = [UIImage imageWithContentsOfFile:fullPath];
        if (img) {
            [imgArray addObject:img];
            if (self.totalSizeNum>DefaultSize) {
                [[TOPProgressStripeView shareInstance]top_showProgress:((i+1)*10.0)/(compareArray.count*10.0) withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processingdoc", @"")]];
            }
        }
    }
    folderUnderModel.docArray = [imgArray copy];
    [tempArray addObject:folderUnderModel];
    return tempArray;
}

#pragma mark -- document下所有图片集合 并排序
- (NSArray *)top_documentAllPicPath:(NSString *)path{
    NSArray * documentArray = [TOPDocumentHelper top_getJPEGFile:path];
    NSArray * compareArray = [documentArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString * str1 = obj1;
        NSString * str2 = obj2;
        NSString * compareStr1 = [[str1 componentsSeparatedByString:@".jpg"][0] substringFromIndex:14];
        NSString * compareStr2 = [[str2 componentsSeparatedByString:@".jpg"][0] substringFromIndex:14];
        if ([compareStr1 integerValue]>[compareStr2 integerValue]) {
            if ([TOPScanerShare top_childViewByType] == 1) {
                return NSOrderedDescending;
            }else{
                return NSOrderedAscending;
            }
        }else if([compareStr1 integerValue]<[compareStr2 integerValue]){
            if ([TOPScanerShare top_childViewByType] == 1) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }else{
            return NSOrderedSame;
        }
    }];
    return compareArray;
}

#pragma mark- 上传文件

- (void)top_uploadFileWithDatasPath:(NSMutableArray *)paths
{
    if (self.openDrivetype == TOPDriveOpenStyleTypeDownFile) {
        [self top_startDownloadSelectFileWithDriveType:self.uploadDriveStyle];
    }else{
        switch (self.uploadDriveStyle) {
            case TOPDownLoadDataStyleDefaultGoogle:
            {
                [self top_googleDriveUPLoadFile:paths];
            }
                break;
            case TOPDownLoadDataStyleStyleBox:
            {
                [self top_boxDriveUPLoadFile:paths];
            }
                break;
            case TOPDownLoadDataStyleStyleDropBox:
            {
                [self top_dropBoxDriveUPLoadFile:paths];
            }
                break;
            case TOPDownLoadDataStyleStyleOneDrice:
            {
                [self top_oneDriveUPloadFile:paths];
            }
                break;
            default:
                break;
        }
    }
    
}
#pragma mark- 下载文件
- (void)top_startDownloadSelectFileWithDriveType:(TOPDownLoadDataStyle)downloadDriveType
{
    NSMutableArray *currentDriceArrays = [[DriveDownloadManger sharedSingleton] selectDownloadDriveArrays];
    if (currentDriceArrays.count<=0) {
        return;
    }
    [[DriveDownloadManger sharedSingleton] startDownloadSelectFileDataWith:currentDriceArrays withDownloadSave:self.downloadFileSavePath Type:downloadDriveType  downloadEnterType:self.downloadFileType withDocID:self.docId];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark- googleDrive上传文件
- (void)top_googleDriveUPLoadFile:(NSMutableArray *)paths
{
    [[TOPProgressStripeView shareInstance] top_resetProgress];
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@(1/%@)",NSLocalizedString(@"topscan_driveuploading", @""),@( paths.count)]];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<paths.count; i++) {
            NSString * filePath = paths[i];
            NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
            NSString *filename = [filePath lastPathComponent];
            NSString *mimeType = [self top_MIMETypeFileName:filename
                                        defaultMIMEType:@"binary/octet-stream"];
            GTLRUploadParameters *uploadParameters =
            [GTLRUploadParameters uploadParametersWithData:fileData MIMEType:mimeType];
            GTLRDrive_File *newFile = [GTLRDrive_File object];
            if (self.googleCurrentItem) {
                newFile.parents = @[self.googleCurrentItem.identifier];
            }
            newFile.name =   filename;
            GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:newFile
                                                                           uploadParameters:uploadParameters];
            query.executionParameters.uploadProgressBlock = ^(GTLRServiceTicket *callbackTicket,
                                                              unsigned long long numberOfBytesRead,
                                                              unsigned long long dataLength) {
                if (paths.count<2) {
                    [[TOPProgressStripeView shareInstance] top_showProgress:(double)numberOfBytesRead/dataLength withStatus:[NSString stringWithFormat:@"%@(%@/%@)",NSLocalizedString(@"topscan_driveuploading", @""),@(1),@(1)]];
                }
            };
            [self.googleDriveService executeQuery:query
                                completionHandler:^(GTLRServiceTicket *callbackTicket,
                                                    GTLRDrive_File *uploadedFile,
                                                    NSError *callbackError) {
                dispatch_semaphore_signal(semaphore);
                if (paths.count >1) {
                    CGFloat progressValue = (CGFloat)(i+1)/paths.count;
                    [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@(%@/%@)",NSLocalizedString(@"topscan_driveuploading", @""),@((i+1)),@(paths.count)]];
                }
                if (callbackError == nil) {
                    if ((i+1)>= paths.count) {
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [[TOPProgressStripeView shareInstance] dismiss];
                            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_uploadsucceeded", @"")];
                            [weakSelf.uploadDatas removeAllObjects];
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        });
                    }
                } else {
                    if ((i+1)>= paths.count) {
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [[TOPProgressStripeView shareInstance] dismiss];
                            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_uploadsucceeded", @"")];
                            [weakSelf.uploadDatas removeAllObjects];
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        });
                    }
                }
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    });
}
- (NSString *)top_MIMETypeFileName:(NSString *)path
               defaultMIMEType:(NSString *)defaultType {
    NSString *result = defaultType;
    NSString *extension = [path pathExtension];
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)extension, NULL);
    if (uti) {
        CFStringRef cfMIMEType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        if (cfMIMEType) {
            result = CFBridgingRelease(cfMIMEType);
        }
        CFRelease(uti);
    }
    return result;
}
#pragma mark- DropBox上传文件
- (void)top_dropBoxDriveUPLoadFile:(NSMutableArray *)paths
{
    [[TOPProgressStripeView shareInstance] top_resetProgress];
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@(1/%@)",NSLocalizedString(@"topscan_driveuploading", @""),@( paths.count)]];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<paths.count; i++) {
            NSString * filePath = paths[i];
            NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
            NSString *creatFolderPath = [NSString stringWithFormat:@"/%@",filePath.lastPathComponent];
            if (self.dropBoxCurrentItem) {
                creatFolderPath = [NSString stringWithFormat:@"%@/%@",self.dropBoxCurrentItem.pathLower,filePath.lastPathComponent];
            }
            DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
            
            [[[self.dropBoxContentClient.filesRoutes uploadData:creatFolderPath mode:mode autorename:@(YES) clientModified:nil mute:@(NO) propertyGroups:nil strictConflict:@(YES) inputData:fileData] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
                dispatch_semaphore_signal(semaphore);
                if (paths.count >1) {
                    CGFloat progressValue = (CGFloat)(i+1)/paths.count;
                    [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@(%@/%@)",NSLocalizedString(@"topscan_driveuploading", @""),@((i+1)),@(paths.count)]];
                }
                if (result) {
                    if ((i+1)>= paths.count) {
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [[TOPProgressStripeView shareInstance] dismiss];
                            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_uploadsucceeded", @"")];
                            
                            [weakSelf.uploadDatas removeAllObjects];
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        });
                    }
                } else {
                    if ((i+1)>= paths.count) {
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [[TOPProgressStripeView shareInstance] dismiss];
                            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_uploadsucceeded", @"")];
                            
                            [weakSelf.uploadDatas removeAllObjects];
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                            
                        });
                    }
                }
            }] setProgressBlock:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
                if (paths.count<2) {
                    [[TOPProgressStripeView shareInstance] top_showProgress:(float)totalBytesDownloaded/totalBytesExpectedToDownload withStatus:[NSString stringWithFormat:@"%@(%@/%@)",NSLocalizedString(@"topscan_driveuploading", @""),@(1),@(1)]];
                }
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    });
}

#pragma mark- Box上传文件
- (void)top_boxDriveUPLoadFile:(NSMutableArray *)paths
{
    [[TOPProgressStripeView shareInstance] top_resetProgress];
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@(1/%@)",NSLocalizedString(@"topscan_driveuploading", @""),@( paths.count)]];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<paths.count; i++) {
            NSString * filePath = paths[i];
            NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
            NSString *itemId = BOXAPIFolderIDRoot;
            if (self.boxCurrentItem) {
                itemId = self.boxCurrentItem.modelID;
            }
            if (fileData) {
                BOXFileUploadRequest *uploadRequest = [weakSelf.contentClient fileUploadRequestToFolderWithID:itemId fromData:fileData fileName:filePath.lastPathComponent];
                [uploadRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
                    if (paths.count<2) {
                        [[TOPProgressStripeView shareInstance] top_showProgress:1.0*totalBytesTransferred/totalBytesExpectedToTransfer withStatus:[NSString stringWithFormat:@"%@(%@/%@)",NSLocalizedString(@"topscan_driveuploading", @""),@(1),@(1)]];
                    }
                } completion:^(BOXFile *file, NSError *error) {
                    dispatch_semaphore_signal(semaphore);
                    if (paths.count >1) {
                        CGFloat progressValue = (CGFloat)(i+1)/paths.count;
                        [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@(%@/%@)",NSLocalizedString(@"topscan_driveuploading", @""),@((i+1)),@(paths.count)]];
                    }
                    if (error) {
                        if ((i+1)>= paths.count) {
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                [[TOPProgressStripeView shareInstance] dismiss];
                                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_uploadsucceeded", @"")];
                                [self.uploadDatas removeAllObjects];
                                [self dismissViewControllerAnimated:YES completion:nil];
                            });
                        }
                    }else {
                        if ((i+1)>= paths.count) {
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                [[TOPProgressStripeView shareInstance] dismiss];
                                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_uploadsucceeded", @"")];
                                [self.uploadDatas removeAllObjects];
                                [self dismissViewControllerAnimated:YES completion:nil];
                            });
                        }
                    }
                }];
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    });
}
#pragma mark- onedrive上传文件
- (void)top_oneDriveUPloadFile:(NSMutableArray *)paths
{
    [[TOPProgressStripeView shareInstance] top_resetProgress];
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@(1/%@)",NSLocalizedString(@"topscan_driveuploading", @""),@( paths.count)]];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<paths.count; i++) {
            NSString * filePath = paths[i];
            NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
            NSString *itemId = @"root";
            if (self.oneDrivecurrentItem) {
                itemId = self.oneDrivecurrentItem.id;
            }
            ODURLSessionUploadTask *task1111 =   [[[[[self.oneDriveClient drive] items:itemId] itemByPath:filePath.lastPathComponent] contentRequest] uploadFromData:fileData completion:^(ODItem *response, NSError *error) {
                dispatch_semaphore_signal(semaphore);
                
                if (paths.count >1) {
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        
                        CGFloat progressValue = (CGFloat)(i+1)/paths.count;
                        [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@(%@/%@)",NSLocalizedString(@"topscan_driveuploading", @""),@((i+1)),@(paths.count)]];
                    });
                }
                if (error) {
                    if ((i+1)>= paths.count) {
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [[TOPProgressStripeView shareInstance] dismiss];
                            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_uploadsucceeded", @"")];
                            
                            [self.uploadDatas removeAllObjects];
                            [self dismissViewControllerAnimated:YES completion:nil];
                        });
                    }
                }else {
                    if ((i+1)>= paths.count) {
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [[TOPProgressStripeView shareInstance] dismiss];
                            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_uploadsucceeded", @"")];
                            [self.uploadDatas removeAllObjects];
                            [self dismissViewControllerAnimated:YES completion:nil];
                        });
                    }
                }
            }];
            if (paths.count<2) {
                self.progress = task1111.progress;
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    });
}

- (void)setProgress:(NSProgress *)progress
{
    _progress = progress;
    [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:0 context:ProgressObserverContext];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == ProgressObserverContext){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSProgress *progress = object;
            [SVProgressHUD dismiss];
            [[TOPProgressStripeView shareInstance] top_showProgress:progress.fractionCompleted withStatus:[NSString stringWithFormat:@"%@(%@/%@)",NSLocalizedString(@"topscan_driveuploading", @""),@(1),@(1)]];
        });
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)dealloc
{
    [self.progress removeObserver:self
                       forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                          context:ProgressObserverContext];
    self.progress = nil;
}
- (void)top_drive_selectDriveCellwith:(TOPOneDriveFolderCollectionViewCell *)cell
{
    [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:UIColorFromRGB(0xEBEBEB)]];
    cell.selectCoverImageView.hidden = NO;
    cell.selectCoverImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
    NSMutableArray *currentDriceArrays = [[DriveDownloadManger sharedSingleton] selectDownloadDriveArrays];
    if (currentDriceArrays.count >0) {
        [self.bottomConfirmBut setTitle:[NSString stringWithFormat:@"%@ (%ld)",NSLocalizedString(@"topscan_importfile", @""),currentDriceArrays.count] forState:UIControlStateNormal];
    }else{
        [self.bottomConfirmBut setTitle:NSLocalizedString(@"topscan_importfile", @"") forState:UIControlStateNormal];
    }
}

- (void)top_drive_removeDiveItemCellWith:(TOPOneDriveFolderCollectionViewCell *)cell
{
    [cell setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]]];
    cell.selectCoverImageView.image = [UIImage imageNamed:@"top_scamerbatch_AllNormal"];
    NSMutableArray *newcurrentDriceArrays = [[DriveDownloadManger sharedSingleton] selectDownloadDriveArrays];
    [self.bottomConfirmBut setTitle:[NSString stringWithFormat:@"%@ (%ld)",NSLocalizedString(@"topscan_importfile", @""),newcurrentDriceArrays.count] forState:UIControlStateNormal];
}


@end
