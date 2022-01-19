#import "DriveDownloadManger.h"
#import "FHGoogleLoginManager.h"
#import "TOPDownProgressAlertView.h"
@interface DriveDownloadManger ()
@property (nonatomic,assign) NSInteger fileTotal;
//google
@property (nonatomic, strong) GTLRDrive_File *currentFileDrive;
@property (strong, nonatomic) GTLRDriveService *googleDriveService;

@property (nonatomic, copy) NSString *updateFilePath;
//DropBox
@property (nonatomic, strong) DBUserClient *contentClient;
@property  (nonatomic, strong) DBFILESMetadata *currentDropBoxItem;

//Box
@property (nonatomic, strong) BOXContentClient *boxClient;
@property  (nonatomic, strong) BOXItem *currentBoxItem;

//OneDrive
@property (nonatomic, strong) ODClient *oneDriveClient;
@property  (nonatomic, strong) ODItem *currentOneDriveItem;
@property (strong, nonatomic)  TOPDownProgressAlertView *downProgressView;


@property (assign, nonatomic) BOOL oneDriveDownOrUpdate;

/**
 当前的下载进度
 */
@property (nonatomic,strong) NSProgress *progress;

/**
 当前的下载进度
 */
@property (nonatomic,strong) NSProgress *downCloudProgress;

/**
 当前批量下载路径
 */
@property (nonatomic,copy) NSString *downloadFilePath;

/**
 当前批量下载数据的入口
 */
@property (nonatomic, assign) TOPDownloadFileToDriveAddPathType currentDownloadFileType;

/**
 当前下载上层目录到文件夹ID
 */
@property (nonatomic,copy) NSString *currentDocId;
@end
static DriveDownloadManger *_sharedSingleton = nil;
static void *ProgressObserverContext = &ProgressObserverContext;

static void *ProgressObserverDownContext = &ProgressObserverDownContext;


@implementation DriveDownloadManger



+ (instancetype)sharedSingleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return _sharedSingleton;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        //        [self getNewContoryList];
    }
    return self;
}



+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [super allocWithZone:zone];
    });
    return _sharedSingleton;
}

-(id)copyWithZone:(NSZone *)zone
{
    return _sharedSingleton;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _sharedSingleton;
}
- (NSMutableArray *)drivePaths
{
    if (_drivePaths == nil) {
        _drivePaths = [NSMutableArray array];
    }
    return _drivePaths;
}

/*
 上传同步ZIP到网盘
 @param filePath ZIP路径
 @param type 网盘类型
 */
- (void)updateZipWithGoogleDrive:(NSString *)filePath  Type:(TOPDownLoadDataStyle)type completionBlock:(void (^)(GTLRDrive_File *fileDrive, NSError *error))completionBlock progress:(void (^)( float progressValue))progress
{
    self.updateFilePath = filePath;
    switch (type) {
        case TOPDownLoadDataStyleDefaultGoogle:
        {
            [[FHGoogleLoginManager sharedInstance] checkGoogleAccountStateWithCompletion:^(FHGoogleAccountState state) {
                switch (state) {
                    case FHGoogleAccountStateOnline:
                    {
                        
                        
                        [self top_fetchDriveFilesCompletionBlock:^(GTLRDrive_File *file, NSError *error) {
                            
                            completionBlock(file,error);
                        } progress:^(float progressValue) {
                            progress(progressValue);
                        }];
                    }
                        
                        
                        
                        break;
                    case FHGoogleAccountStateHasKeyChain:
                    {
                        [[FHGoogleLoginManager sharedInstance] autoLoginWithCompletion:^(GIDGoogleUser *user, NSError *error) {
                            if (error == nil && user)
                            {
                                //                                [self top_fetchDriveFiles];
                                
                                [self top_fetchDriveFilesCompletionBlock:^(GTLRDrive_File *file, NSError *error) {
                                    
                                    completionBlock(file,error);
                                } progress:^(float progressValue) {
                                    progress(progressValue);
                                }];
                                
                            }
                            
                        }];
                    }
                        break;
                    case FHGoogleAccountStateOffline:
                    {
                        [[FHGoogleLoginManager sharedInstance] startGoogleLoginWithCompletion:^(GIDGoogleUser *user, NSError *error) {
                            //                            [weakSelf displayAccountVC];
                            if (error == nil && user)
                            {
                                //                        [self top_fetchDriveFiles];
                                [self top_fetchDriveFilesCompletionBlock:^(GTLRDrive_File *file, NSError *error) {
                                    
                                    completionBlock(file,error);
                                } progress:^(float progressValue) {
                                    progress(progressValue);
                                }];
                            }
                            else
                            {
                                //                            [self dismissViewControllerAnimated:YES completion:nil];
                                //Handle error
                            }
                        }];
                        
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
            break;
        case TOPDownLoadDataStyleStyleDropBox:
        {
            //            NSString *dbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
            //            if (!self.contentClient) {
            //                self.contentClient = [[DBUserClient alloc] initWithAccessToken:dbAccessToken];
            //
            //            }
            //
            //              if (self.contentClient.usersRoutes && dbAccessToken) {
            //
            //                  [self getDBFileChildren];
            //              }
        }
            break;
        default:
            break;
    }
    
    
}

#pragma - mark OneDrive

/*
 上传同步ZIP到网盘
 @param filePath ZIP路径
 */
- (void)updateZipWithOneDrive:(NSString *)filePath completionBlock:(void (^)(ODItem *fileDrive))completionBlock progress:(void (^)( float progressValue))progress
{
    if (!self.oneDriveClient){
        self.oneDriveClient = [ODClient loadCurrentClient];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
    
    self.oneDriveDownOrUpdate = YES;
    NSString *itemId = @"root";
    WeakSelf(ws);
    ODChildrenCollectionRequest *childrenRequest = [[[[self.oneDriveClient drive] items:itemId] children] request];
    [childrenRequest getWithCompletion:^(ODCollection *response, ODChildrenCollectionRequest *nextRequest, NSError *error){
        if (!error){
            if (response.value){
                __block BOOL isCortentFile = NO;
                [response.value enumerateObjectsUsingBlock:^(ODItem *item, NSUInteger index, BOOL *stop){
                    if ([item.name isEqualToString:@"SimpleScanner"]) {
                        
                        ws.currentOneDriveItem = item;
                        isCortentFile = YES;
                        *stop = YES;
                        return;
                    }
                }];
                if (isCortentFile == YES) {
                    //                    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
                    NSData *fileData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
                    ODURLSessionUploadTask *task1111 =   [[[[[self.oneDriveClient drive] items: ws.currentOneDriveItem.id] itemByPath:[NSString stringWithFormat:@"topscan_backup %@",[TOPDocumentHelper top_getCurrentYYYYDateForMatter]]] contentRequest] uploadFromData:fileData completion:^(ODItem *response, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            [ws.downProgressView top_showXib];
                            ws.downProgressView = nil;        //                    [self.collectionView reloadData];
                        });
                        
                        if (error) {
                            NSLog(@"上传失败");
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                completionBlock(nil);
                            });
                        }else {
                            NSLog(@"");
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                completionBlock(response);
                            });
                        }
                    }] ;
                    task1111.progress.totalUnitCount = self.currentOneDriveItem.size;
                    ws.progress = task1111.progress;
                    
                    
                }else{
                    ODItem *newFolder = [[ODItem alloc] initWithDictionary:@{[ODNameConflict rename].key : [ODNameConflict rename].value}];
                    newFolder.name = @"SimpleScanner";
                    newFolder.folder = [[ODFolder alloc] init];
                    [[[[[ws.oneDriveClient drive] items:@"root"] children] request] addItem:newFolder withCompletion:^(ODItem *response, NSError *error) {
                        if (response){
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                [ws.downProgressView top_showXib];
                                ws.downProgressView = nil;
                                //                                NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
                                NSData *fileData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
                                ODURLSessionUploadTask *task1111 =   [[[[[ws.oneDriveClient drive] items: response.id] itemByPath:[NSString stringWithFormat:@"topscan_backup %@",[TOPDocumentHelper top_getCurrentYYYYDateForMatter]]] contentRequest] uploadFromData:fileData completion:^(ODItem *response, NSError *error) {
                                    if (error) {
                                        NSLog(@"上传失败");
                                        
                                    }else {
                                        NSLog(@"");
                                        dispatch_async(dispatch_get_main_queue(), ^(){
                                            
                                            completionBlock(response);
                                            //                    [self.collectionView reloadData];
                                        });
                                    }
                                }] ;
                                task1111.progress.totalUnitCount = self.currentOneDriveItem.size;
                                ws.progress = task1111.progress;
                                
                            });
                            
                        }
                    }];
                }
                
                //                dispatch_async(dispatch_get_main_queue(), ^(){
                //                    completionBlock(self.currentOneDriveItem);
                ////                    [self.collectionView reloadData];
                //                });
            }
            
        }
        else if ([error isAuthenticationError]){
            
        }
    }];
    
    
    
}

/*
 查询
 */
- (void)queryFileOneDriveWithObjectCompletionBlock:(void (^)(NSArray<ODItem *> *fileItems))completionBlock
{
    
    if (!self.oneDriveClient){
        self.oneDriveClient = [ODClient loadCurrentClient];
    }
    
    NSString *itemId = @"root";
    ODChildrenCollectionRequest *childrenRequest = [[[[self.oneDriveClient drive] items:itemId] children] request];
    [childrenRequest getWithCompletion:^(ODCollection *response, ODChildrenCollectionRequest *nextRequest, NSError *error){
        if (!error){
            if (response.value){
                __block BOOL isCortentFile = NO;
                [response.value enumerateObjectsUsingBlock:^(ODItem *item, NSUInteger index, BOOL *stop){
                    if ([item.name isEqualToString:@"SimpleScanner"]) {
                        
                        self.currentOneDriveItem = item;
                        isCortentFile = YES;
                        *stop = YES;
                        return;
                    }
                }];
                if (isCortentFile == YES) {
                    
                    NSString *itemId1 = self.currentOneDriveItem.id;
                    ODChildrenCollectionRequest *childrenRequest11 = [[[[self.oneDriveClient drive] items:itemId1] children] request];
                    [childrenRequest11 getWithCompletion:^(ODCollection *response, ODChildrenCollectionRequest *nextRequest, NSError *error){
                        if (!error){
                            if (response.value){
                                NSMutableArray *tempArrays = [NSMutableArray array];
                                [response.value enumerateObjectsUsingBlock:^(ODItem *item, NSUInteger index, BOOL *stop){
                                    if ( [item.name containsString:@"topscan_backup"]  ) {
                                        [tempArrays addObject: item];
                                    }
                                }];
                                
                                dispatch_async(dispatch_get_main_queue(), ^(){
                                    completionBlock(tempArrays);
                                });
                            }
                            
                        }
                        else if ([error isAuthenticationError]){
                            completionBlock([NSArray array]);
                            
                        }
                    }];
                }else{
                    completionBlock([NSArray array]);
                    
                }
                
            }
            
        }
        else if ([error isAuthenticationError]){
            completionBlock([NSArray array]);
            
        }
    }];
    
    
    
}
/*
 删除DropBox网盘上的同步文件
 @param filepath ZIP文件的路径
 */

- (void)deleteOneDriveWithID:(NSString *)fileID CompletionBlock:(void (^)(BOOL deleteStates))completionBlock
{
    if (!self.oneDriveClient){
        self.oneDriveClient = [ODClient loadCurrentClient];
    }
    [[[[self.oneDriveClient drive] items:fileID] request] deleteWithCompletion:^(NSError *error){
        //Returns an error if there was one.
    }];
    BOXContentClient *contentClient = [BOXContentClient defaultClient];
    BOXFileDeleteRequest *fileDeleteRequest = [contentClient fileDeleteRequestWithID:fileID];
    [fileDeleteRequest performRequestWithCompletion:^(NSError *error) {
        // If successful, error will be nil.
        if (!error) {
            completionBlock(YES);
        }else{
            completionBlock(NO);
            
        }
    }];
}

/*
 下载同步Box网盘上的同步文件
 @param fileDrive 选中的文件
 */
- (void)downReZipWithOneDriveItem:(ODItem *)fileDrive CompletionBlock:(void (^)(NSString  *zipFilePath))completionBlock progress:(void (^)( float progressValue))progress
{
    
    if (!self.oneDriveClient){
        self.oneDriveClient = [ODClient loadCurrentClient];
    }
    self.oneDriveDownOrUpdate = NO;
    
    ODURLSessionDownloadTask *task = [[[[self.oneDriveClient drive] items:fileDrive.id] contentRequest] downloadWithCompletion:^(NSURL *filePath, NSURLResponse *response, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.downProgressView top_showXib];
            self.downProgressView = nil;
            
        });
        
        if (!error) {
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if(![fileManager fileExistsAtPath:TOPTemporaryPathZip]){//如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
                [fileManager createDirectoryAtPath:TOPTemporaryPathZip withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSString *newFilePath = [TOPTemporaryPathZip stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.zip",fileDrive.name]];
            if ([fileDrive.name hasSuffix:@".zip"]|| [fileDrive.name hasSuffix:@".ZIP"] || [fileDrive.name hasSuffix:@".Zip"]) {
                newFilePath = [TOPTemporaryPathZip stringByAppendingPathComponent:fileDrive.name];
            }
            
            [[NSFileManager defaultManager] moveItemAtURL:filePath toURL:[NSURL fileURLWithPath:newFilePath] error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(newFilePath);
            });
            
        }
        
    }];
    task.progress.totalUnitCount = fileDrive.size;
    self.progress = task.progress;
    
}


#pragma - mark Box

/*
 上传同步ZIP到网盘
 @param filePath ZIP路径
 */
- (void)updateZipWithBoxDrive:(NSString *)filePath completionBlock:(void (^)(BOXItem *fileDrive))completionBlock progress:(void (^)( float progressValue))progress
{
    if (!self.boxClient){
        self.boxClient = [BOXContentClient defaultClient];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
    
    BOXSearchRequest * searchRequest =    [self.boxClient searchRequestWithQuery:@"SimpleScanner" inRange:NSMakeRange(0, 1000)];
    searchRequest.requestAllItemFields =   NO;
    searchRequest.ancestorFolderIDs = @[BOXAPIFolderIDRoot];
    WeakSelf(ws);
    [searchRequest performRequestWithCompletion:^(NSArray *items, NSUInteger totalCount, NSRange range, NSError *error) {
        if (!error) {
            BOOL isFileThere = NO;
            for (BOXItem *currentItem in items) {
                if ([currentItem.name isEqualToString:@"SimpleScanner"] && currentItem.isFolder) {
                    isFileThere = YES;
                    ws.currentBoxItem = currentItem;
                    break;
                }
            }
            if (isFileThere == YES) {
                
                //                NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
                NSData *fileData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
                if (fileData) {
                    BOXFileUploadRequest *uploadRequest = [ws.boxClient fileUploadRequestToFolderWithID:ws.currentBoxItem.modelID fromData:fileData fileName:[NSString stringWithFormat:@"topscan_backup %@",[TOPDocumentHelper top_getCurrentYYYYDateForMatter]]];
                    
                    [uploadRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
                        // Update a progress bar, etc.
                        progress( 1.0*totalBytesTransferred/totalBytesExpectedToTransfer);
                    } completion:^(BOXFile *file, NSError *error) {
                        completionBlock(file);
                        // Upload has completed. If successful, file will be non-nil; otherwise, error will be non-nil.
                    }];
                }else{
                    completionBlock(nil);
                }
                
            }else{
                BOXFolderCreateRequest *creatRequest = [self.boxClient folderCreateRequestWithName:@"SimpleScanner" parentFolderID:BOXAPIFolderIDRoot];
                [creatRequest performRequestWithCompletion:^(BOXFolder *folder, NSError *error) {
                    //                    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
                    NSData *fileData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
                    if (fileData) {
                        BOXFileUploadRequest *uploadRequest = [self.boxClient fileUploadRequestToFolderWithID:folder.modelID fromData:fileData fileName:[NSString stringWithFormat:@"topscan_backup %@",[TOPDocumentHelper top_getCurrentYYYYDateForMatter]]];
                        [uploadRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
                            // Update a progress bar, etc.
                            progress( 1.0*totalBytesTransferred/totalBytesExpectedToTransfer);
                        } completion:^(BOXFile *file, NSError *error) {
                            completionBlock(file);
                            // Upload has completed. If successful, file will be non-nil; otherwise, error will be non-nil.
                        }];
                    }else{
                        completionBlock(nil);
                    }
                    
                    
                }];
                
                
            }
        }
        
    }];
    
    
}

/*
 查询
 */
- (void)queryFileBoxWithObjectCompletionBlock:(void (^)(NSArray<BOXItem *> *fileItems))completionBlock
{
    
    if (!self.boxClient){
        self.boxClient = [BOXContentClient defaultClient];
    }
    
    BOXSearchRequest * searchRequest =    [self.boxClient searchRequestWithQuery:@"SimpleScanner" inRange:NSMakeRange(0, 1000)];
    searchRequest.requestAllItemFields =   NO;
    searchRequest.ancestorFolderIDs = @[BOXAPIFolderIDRoot];
    [searchRequest performRequestWithCompletion:^(NSArray *items, NSUInteger totalCount, NSRange range, NSError *error) {
        if (!error) {
            BOOL isFileThere = NO;
            for (BOXItem *currentItem in items) {
                if ([currentItem.name isEqualToString:@"SimpleScanner"] && currentItem.isFolder) {
                    isFileThere = YES;
                    self.currentBoxItem = currentItem;
                    break;
                }
            }
            if (isFileThere == YES) {
                
                BOXSearchRequest * searchZipRequest =    [self.boxClient searchRequestWithQuery:@"SimpleS" inRange:NSMakeRange(0, 1000)];
                searchZipRequest.requestAllItemFields =   NO;
                searchZipRequest.ancestorFolderIDs = @[self.currentBoxItem.modelID];
                [searchZipRequest performRequestWithCompletion:^(NSArray *items1, NSUInteger totalCount1, NSRange range1, NSError *error1) {
                    if (!error) {
                        NSMutableArray *tempBoxArrys = [NSMutableArray array];
                        for (BOXItem *currentItem in items1) {
                            if (currentItem.isFile) {
                                [tempBoxArrys addObject:currentItem];
                            }
                        }
                        completionBlock(tempBoxArrys);
                    }
                }];
            }else{
                completionBlock([NSArray array]);
                
            }
            
        }else{
            completionBlock([NSArray array]);
        }
        
    }];
    
}
/*
 删除DropBox网盘上的同步文件
 @param filepath ZIP文件的路径
 */

- (void)deleteBoxItemWithID:(NSString *)fileID CompletionBlock:(void (^)(BOOL deleteStates))completionBlock
{
    BOXContentClient *contentClient = [BOXContentClient defaultClient];
    BOXFileDeleteRequest *fileDeleteRequest = [contentClient fileDeleteRequestWithID:fileID];
    [fileDeleteRequest performRequestWithCompletion:^(NSError *error) {
        // If successful, error will be nil.
        if (!error) {
            completionBlock(YES);
        }else{
            completionBlock(NO);
            
        }
    }];
}

/*
 下载同步Box网盘上的同步文件
 @param fileDrive 选中的文件
 */
- (void)downRestoreZipWithBoxItem:(BOXItem *)fileDrive CompletionBlock:(void (^)(NSString  *zipFilePath))completionBlock progress:(void (^)( float progressValue))progress
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    BOXContentClient *contentClient = [BOXContentClient defaultClient];
    //    NSString *localFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.jpg"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:TOPTemporaryPathZip]){//如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        [fileManager createDirectoryAtPath:TOPTemporaryPathZip withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *newFilePath = [TOPTemporaryPathZip stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.zip",fileDrive.name]];
    if ([fileDrive.name hasSuffix:@".zip"]|| [fileDrive.name hasSuffix:@".ZIP"] || [fileDrive.name hasSuffix:@".Zip"]) {
        newFilePath = [TOPTemporaryPathZip stringByAppendingPathComponent:fileDrive.name];
    }
    
    BOXFileDownloadRequest *boxRequest = [contentClient fileDownloadRequestWithID:fileDrive.modelID toLocalFilePath:newFilePath];
    [boxRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
        // Update a progress bar, etc.
        progress((float)totalBytesTransferred/totalBytesExpectedToTransfer);
        
    } completion:^(NSError *error) {
        completionBlock(newFilePath);
        // Download has completed. If it failed, error will contain reason (e.g. network connection)
    }];
}

#pragma - mark DropBox

/*
 上传同步ZIP到网盘
 @param filePath ZIP路径
 @param type 网盘类型
 */
- (void)updateZipWithDropBox:(NSString *)filePath  completionBlock:(void (^)(DBFILESMetadata *fileDrive))completionBlock progress:(void (^)( float progressValue))progress
{
    self.updateFilePath = filePath;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
    
    //        NSString *dbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    if (!self.contentClient) {
        self.contentClient = [DBClientsManager authorizedClient];
    }
    if (self.contentClient.usersRoutes) {
        
        [self getDBFileChildren:filePath CompletionBlock:^(DBFILESMetadata *fileDrive) {
            completionBlock(fileDrive);
            
        } progress:^(float progressValue) {
            progress(progressValue);
            
        }];
    }
    
}

- (void)queryFileINDropBoxWithObjectCompletionBlock:(void (^)(NSArray<DBFILESMetadata *> *fileItems))completionBlock
{
    if (!self.contentClient) {
        self.contentClient = [DBClientsManager authorizedClient];
    }
    [[self.contentClient.filesRoutes listFolder:@"/SimpleScanner"]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
        if (result) {
            NSMutableArray *tempArrays = [NSMutableArray array];
            for (DBFILESMetadata *itemDile in  result.entries) {
                if ([itemDile.name  containsString:@"SimpleScan"]) {
                    [tempArrays addObject:itemDile];
                }
            }
            
            completionBlock(tempArrays);
        } else {
            completionBlock([NSArray array]);
            
            if ([error.statusCode isEqualToNumber:[NSNumber numberWithInt:409]]) {
                completionBlock([NSArray array]);
                
                NSLog(@"...%@",error.errorContent);
            }
            
        }
    }];
    
    
}
- (void)getDBFileChildren:(NSString *)filePath CompletionBlock:(void (^)(DBFILESMetadata *fileDrive))completionBlock progress:(void (^)( float progressValue))progress
{
    
    NSString *searchPath = @"";
    
    // list folder metadata contents (folder will be root "/" Dropbox folder if app has permission
    // "Full Dropbox" or "/Apps/<APP_NAME>/" if app has permission "App Folder").
    [[self.contentClient.filesRoutes listFolder:searchPath]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
        if (result) {
            BOOL isContainsSimFile = NO;
            for (DBFILESMetadata *metaFile in  result.entries) {
                if ([metaFile.name isEqualToString:@"SimpleScanner"]) {
                    isContainsSimFile = YES;
                    break;
                }
            }
            if (isContainsSimFile == NO) {
                [self creatDropBoxFileCompletionBlock:^(DBFILESMetadata *fileDrive) {
                    completionBlock(fileDrive);
                    
                } progress:^(float progressValue) {
                    progress(progressValue);
                    
                }];
            }else{
                [self dropboxUploadFile:self.updateFilePath completionBlock:^(DBFILESMetadata *fileDrive) {
                    completionBlock(fileDrive);
                    
                } progress:^(float progressValue) {
                    progress(progressValue);
                }];
            }
            //            [self top_displayPhotos:result.entries];
        } else {
            NSString *title = @"";
            NSString *message = @"";
            if (routeError) {
                // Route-specific request error
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
            
        }
    }];
    
}

- (void)creatDropBoxFileCompletionBlock:(void (^)(DBFILESMetadata *fileDrive))completionBlock progress:(void (^)( float progressValue))progress
{
    [[self.contentClient.filesRoutes createFolderV2:@"/SimpleScanner"] setResponseBlock:^(DBFILESCreateFolderResult * _Nullable result, DBFILESCreateFolderError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        if (result) {
            NSLog(@"%@\n", result);
            [self dropboxUploadFile:self.updateFilePath completionBlock:^(DBFILESMetadata *fileDrive) {
                completionBlock(fileDrive);
                
            } progress:^(float progressValue) {
                progress(progressValue);
            }];
        } else {
            NSLog(@"%@\n%@\n", routeError, networkError);
        }
        
    }];
}

/*
 删除DropBox网盘上的同步文件
 @param filepath ZIP文件的路径
 */

- (void)deleteDropBoxItemWithPath:(NSString *)filepath CompletionBlock:(void (^)(BOOL deleteStates))completionBlock
{
    if (!self.contentClient) {
        self.contentClient = [DBClientsManager authorizedClient];
    }
    
    [[self.contentClient.filesRoutes delete_V2:filepath] setResponseBlock:^(DBFILESDeleteResult * _Nullable result, DBFILESDeleteError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        if (result) {
            NSLog(@"%@\n", result);
            completionBlock(YES);
            
        } else {
            completionBlock(NO);
            
            // Error is with the route specifically (status code 409)
            if (routeError) {
                if ([routeError isPathLookup]) {
                    // Can safely access this field
                    DBFILESLookupError *pathLookup = routeError.pathLookup;
                    NSLog(@"%@\n", pathLookup);
                } else if ([routeError isPathWrite]) {
                    DBFILESWriteError *pathWrite = routeError.pathWrite;
                    NSLog(@"%@\n", pathWrite);
                    
                    // This would cause a runtime error
                    // DBFILESLookupError *pathLookup = routeError.pathLookup;
                }
            }
            NSLog(@"%@\n%@\n", routeError, networkError);
        }
        
    }];
    
}

/*
 下载同步DropBox网盘上的同步文件
 @param fileDrive 选中的文件
 */
- (void)downRestoreDataZipWithDropBoxItem:(DBFILESMetadata *)fileDrive CompletionBlock:(void (^)(NSString  *zipFilePath))completionBlock progress:(void (^)( float progressValue))progress
{
    
    if (!self.contentClient) {
        self.contentClient = [DBClientsManager authorizedClient];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
    
    [[[self.contentClient.filesRoutes downloadData:fileDrive.pathDisplay] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESDownloadError * _Nullable routeError, DBRequestError * _Nullable networkError, NSData * _Nullable fileData) {
        
        if (result) {
            
            //            NSString *newFilePath = [NSString stringWithFormat:@"/%@.zip",fileDrive.name];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if(![fileManager fileExistsAtPath:TOPTemporaryPathZip]){//如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
                [fileManager createDirectoryAtPath:TOPTemporaryPathZip withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSString *newFilePath = [TOPTemporaryPathZip stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.zip",fileDrive.name]];
            if ([fileDrive.name hasSuffix:@".zip"]|| [fileDrive.name hasSuffix:@".ZIP"] || [fileDrive.name hasSuffix:@".Zip"]) {
                newFilePath = [TOPTemporaryPathZip stringByAppendingPathComponent:fileDrive.name];
            }
            [fileData writeToFile:newFilePath atomically:YES];
            completionBlock(newFilePath);
            
        }
    }] setProgressBlock:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
        NSLog(@"%lld\n%lld\n%lld\n%f", bytesDownloaded, totalBytesDownloaded, totalBytesExpectedToDownload,(float)totalBytesDownloaded/totalBytesExpectedToDownload);
        //                    progressView.progressFloat = (float)totalBytesDownloaded/totalBytesExpectedToDownload;
        //                    if (drives.count<=1) {
        progress((float)totalBytesDownloaded/totalBytesExpectedToDownload);
    }];
    
}


- (void)dropboxUploadFile:(NSString *)filePath  completionBlock:(void (^)(DBFILESMetadata *fileDrive))completionBlock progress:(void (^)( float progressValue))progress
{
    
    // For overriding on upload
    DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
    //    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:self.updateFilePath];
    NSData *fileData = [NSData dataWithContentsOfFile:self.updateFilePath options:NSDataReadingMappedIfSafe error:nil];
    [[[self.contentClient.filesRoutes uploadData:[NSString stringWithFormat:@"/SimpleScanner/topscan_backup %@",[TOPDocumentHelper top_getCurrentYYYYDateForMatter]] mode:mode autorename:@(YES) clientModified:nil mute:@(NO) propertyGroups:nil strictConflict:@(YES) inputData:fileData] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        completionBlock(result);
        if (result) {
            NSLog(@"%@\n", result);
        } else {
            NSLog(@"%@\n%@\n", routeError, networkError);
        }
    }] setProgressBlock:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
        NSLog(@"%lld\n%lld\n%lld\n%f", bytesDownloaded, totalBytesDownloaded, totalBytesExpectedToDownload,(float)totalBytesDownloaded/totalBytesExpectedToDownload);
        progress((float)totalBytesDownloaded/totalBytesExpectedToDownload);
        
    }];
    
}
#pragma - mark Google Drive
- (void)top_fetchDriveFilesCompletionBlock:(void (^)(GTLRDrive_File *fileDrive, NSError *error))completionBlock progress:(void (^)( float))progress {
    self.googleDriveService = [[GTLRDriveService alloc] init];
    self.googleDriveService.authorizer = [[[[FHGoogleLoginManager sharedInstance] currentUser] authentication] fetcherAuthorizer];
    
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    
    query.q = @"name = 'SimpleScanner' and (mimeType = 'application/vnd.google-apps.folder')";
    
    query.fields = @"kind,nextPageToken,files(mimeType,id,kind,name,webViewLink,thumbnailLink,trashed,modifiedTime,size,originalFilename)";
    [   self.googleDriveService executeQuery:query
                           completionHandler:^(GTLRServiceTicket *callbackTicket,
                                               GTLRDrive_FileList *fileList,
                                               NSError *callbackError) {
        if (callbackError == nil)
        {
            if (fileList.files.count <=0) {
                GTLRDrive_File *folderObj = [GTLRDrive_File object];
                //  folderObj.name = [NSString stringWithFormat:@"New Folder %@", [NSDate date]];
                folderObj.name = @"SimpleScanner";
                folderObj.mimeType = @"application/vnd.google-apps.folder";
                
                
                GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:folderObj
                                                                               uploadParameters:nil];
                [self.googleDriveService executeQuery:query
                                    completionHandler:^(GTLRServiceTicket *callbackTicket,
                                                        GTLRDrive_File *folderItem,
                                                        NSError *callbackError) {
                    // Callback
                    if (callbackError == nil) {
                        
                        self.currentFileDrive = folderItem;
                        [self updataToGoogleCompletionBlock:^(GTLRDrive_File *driveFire, NSError *error) {
                            completionBlock(driveFire,error);
                        } progress:^(float progressValue) {
                            progress(progressValue);
                        }];
                        
                    } else {
                        
                    }
                }];
                //                         [self createAFolder];
            }else{
                
                self.currentFileDrive = [fileList.files firstObject];
                
                [self updataToGoogleCompletionBlock:^(GTLRDrive_File *driveFire, NSError *error) {
                    completionBlock(driveFire,error);
                } progress:^(float progressValue) {
                    progress(progressValue);
                }];
                
                
            }
        }
        else
        {
            //Handle error
        }
    }];
}



- (void)updataToGoogleCompletionBlock:(void (^)(GTLRDrive_File *, NSError *))completionBlock progress:(void (^)( float))progress
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
    
    NSString *filename = [self.updateFilePath lastPathComponent];
    NSString *mimeType = [self top_MIMETypeFileName:filename
                                defaultMIMEType:@"binary/octet-stream"];
    
    //    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:self.updateFilePath];
    NSData *fileData = [NSData dataWithContentsOfFile:self.updateFilePath options:NSDataReadingMappedIfSafe error:nil];
    
    GTLRUploadParameters *uploadParameters =
    [GTLRUploadParameters uploadParametersWithData:fileData MIMEType:mimeType];
    GTLRDrive_File *newFile = [GTLRDrive_File object];
    
    newFile.parents = @[self.currentFileDrive.identifier];
    newFile.name =   [NSString stringWithFormat:@"topscan_backup %@",[TOPDocumentHelper top_getCurrentYYYYDateForMatter]];
    GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:newFile
                                                                   uploadParameters:uploadParameters];
    
    query.executionParameters.uploadProgressBlock = ^(GTLRServiceTicket *callbackTicket,
                                                      unsigned long long numberOfBytesRead,
                                                      unsigned long long dataLength) {
        NSLog(@"uploadProgressIndicator.maxValue=%f uploadProgressIndicator.doubleValue%f",(double)dataLength, (double)numberOfBytesRead);
        progress((double)numberOfBytesRead/dataLength);
    };
    
    [self.googleDriveService executeQuery:query
                        completionHandler:^(GTLRServiceTicket *callbackTicket,
                                            GTLRDrive_File *uploadedFile,
                                            NSError *callbackError) {
        // Callback
        completionBlock(uploadedFile,callbackError);
        if (callbackError == nil) {
            
        } else {
            
        }
        
    }];
    
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

//- (void)createAFolder {
////  GTLRDriveService *service = self.driveService;
//
//  GTLRDrive_File *folderObj = [GTLRDrive_File object];
////  folderObj.name = [NSString stringWithFormat:@"New Folder %@", [NSDate date]];
//    folderObj.name = @"SimpleScan";
//    folderObj.mimeType = @"application/vnd.google-apps.folder";
//
//
//  GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:folderObj
//                                                                 uploadParameters:nil];
//[self.googleDriveService executeQuery:query
//                            completionHandler:^(GTLRServiceTicket *callbackTicket,
//                                                GTLRDrive_File *folderItem,
//                                                NSError *callbackError) {
//                              // Callback
//        if (callbackError == nil) {
//       
//            self.currentFileDrive = folderItem;
//            [self updataToGoogle];
//
//        } else {
//        
//        }
//  }];
//}
/*
 获取google的登录状态
 */
- (FHGoogleAccountState)getCurrentGoogleStates
{
    __block  FHGoogleAccountState currentStates = FHGoogleAccountStateOffline;
    [[FHGoogleLoginManager sharedInstance] checkGoogleAccountStateWithCompletion:^(FHGoogleAccountState state) {
        
        currentStates = state;
        
    }];
    
    return currentStates;
}

- (void)queryDriveWithGoogleCompletionBlock:(void (^)(NSArray<GTLRDrive_File *> *fileItems, NSError *error))completionBlock
{
    
    switch ([self getCurrentGoogleStates]) {
        case FHGoogleAccountStateOnline:
        {
            [self queryFileNameWithObjectCompletionBlock:^(NSArray<GTLRDrive_File *> *fileItems, NSError *error) {
                completionBlock(fileItems,error);
            }];
        }
            break;
        case FHGoogleAccountStateHasKeyChain:
        {
            [[FHGoogleLoginManager sharedInstance] autoLoginWithCompletion:^(GIDGoogleUser *user, NSError *error) {
                if (error == nil && user)
                {
                    [self queryFileNameWithObjectCompletionBlock:^(NSArray<GTLRDrive_File *> *fileItems, NSError *error) {
                        completionBlock(fileItems,error);
                    }];
                }else{
                    [SVProgressHUD dismiss];
                    
                }
                
            }];
        }
            break;
        case FHGoogleAccountStateOffline:
        {
            [[FHGoogleLoginManager sharedInstance] startGoogleLoginWithCompletion:^(GIDGoogleUser *user, NSError *error) {
                if (error == nil && user)
                {
                    [self queryFileNameWithObjectCompletionBlock:^(NSArray<GTLRDrive_File *> *fileItems, NSError *error) {
                        completionBlock(fileItems,error);
                    }];
                }
                else
                {
                    [SVProgressHUD dismiss];
                    
                    //                            [self dismissViewControllerAnimated:YES completion:nil];
                    //Handle error
                }
            }];
            
        }
            break;
        default:
            break;
    }
    //    [[FHGoogleLoginManager sharedInstance] checkGoogleAccountStateWithCompletion:^(FHGoogleAccountState state) {
    //        switch (state) {
    //            case FHGoogleAccountStateOnline:
    //            {
    //
    //                [self queryFileNameWithObjectCompletionBlock:^(NSArray<GTLRDrive_File *> *fileItems, NSError *error) {
    //                    completionBlock(fileItems,error);
    //                }];
    //
    //            }
    //
    //                break;
    //            case FHGoogleAccountStateHasKeyChain:
    //                {
    //                    [[FHGoogleLoginManager sharedInstance] autoLoginWithCompletion:^(GIDGoogleUser *user, NSError *error) {
    //                        if (error == nil && user)
    //                        {
    //                            [self queryFileNameWithObjectCompletionBlock:^(NSArray<GTLRDrive_File *> *fileItems, NSError *error) {
    //                                completionBlock(fileItems,error);
    //                            }];
    //                        }
    //
    //                    }];
    //                }
    //                break;
    //            case FHGoogleAccountStateOffline:
    //            {
    //                [[FHGoogleLoginManager sharedInstance] startGoogleLoginWithCompletion:^(GIDGoogleUser *user, NSError *error) {
    ////                            [weakSelf displayAccountVC];
    //                    if (error == nil && user)
    //                    {
    ////                        [self top_fetchDriveFiles];
    //                        [self queryFileNameWithObjectCompletionBlock:^(NSArray<GTLRDrive_File *> *fileItems, NSError *error) {
    //                            completionBlock(fileItems,error);
    //                        }];
    //                    }
    //                    else
    //                    {
    ////                            [self dismissViewControllerAnimated:YES completion:nil];
    //                        //Handle error
    //                    }
    //                }];
    //
    //            }
    //                break;
    //            default:
    //                break;
    //        }
    //    }];
}

- (void)queryFileNameWithObjectCompletionBlock:(void (^)(NSArray<GTLRDrive_File *> *fileItems, NSError *error))completionBlock
{
    if (self.googleDriveService == nil) {
        self.googleDriveService = [[GTLRDriveService alloc] init];
        
        self.googleDriveService.authorizer = [[[[FHGoogleLoginManager sharedInstance] currentUser] authentication] fetcherAuthorizer];
        
    }
    
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    
    query.q = @"name = 'SimpleScanner' and (mimeType = 'application/vnd.google-apps.folder')";
    
    query.fields = @"kind,nextPageToken,files(mimeType,id,kind,name,webViewLink,thumbnailLink,trashed,modifiedTime,size,originalFilename)";
    [   self.googleDriveService executeQuery:query
                           completionHandler:^(GTLRServiceTicket *callbackTicket,
                                               GTLRDrive_FileList *fileList,
                                               NSError *callbackError) {
        if (callbackError == nil)
        {
            if (fileList.files.count <=0) {
                completionBlock(fileList.files,callbackError);
            }else{
                self.currentFileDrive = [fileList.files firstObject];
                GTLRDriveQuery_FilesList *secoundQuery = [GTLRDriveQuery_FilesList query];
                
                secoundQuery.q =   [NSString stringWithFormat: @"'%@' in parents  and (mimeType = 'application/zip') and name contains 'SimpleScan'",self.currentFileDrive.identifier];
                
                secoundQuery.fields = @"kind,nextPageToken,files(mimeType,id,kind,name,webViewLink,thumbnailLink,trashed,modifiedTime,size,originalFilename)";
                [   self.googleDriveService executeQuery:secoundQuery
                                       completionHandler:^(GTLRServiceTicket *callbackTicket,
                                                           GTLRDrive_FileList *fileList,
                                                           NSError *callbackError) {
                    if (callbackError == nil)
                    {
                        completionBlock(fileList.files,callbackError);
                        
                    }
                    else
                    {
                        [SVProgressHUD dismiss];
                        
                        //Handle error
                    }
                }];
            }
        }
        else
        {
            [SVProgressHUD dismiss];
            
            //Handle error
        }
    }];
}

/*
 删除google网盘上的同步文件
 @param fileID ZIP文件的Identifier
 */

- (void)deleteGoogleItemWithIdentifier:(NSString *)fileID CompletionBlock:(void (^)(BOOL deleteStates, NSError *error))completionBlock
{
    if (self.googleDriveService == nil) {
        self.googleDriveService = [[GTLRDriveService alloc] init];
        self.googleDriveService.authorizer = [[[[FHGoogleLoginManager sharedInstance] currentUser] authentication] fetcherAuthorizer];
        
    }
    if (fileID) {
        GTLRDriveQuery_FilesDelete *query = [GTLRDriveQuery_FilesDelete queryWithFileId:fileID];
        [self.googleDriveService executeQuery:query
                            completionHandler:^(GTLRServiceTicket *callbackTicket,
                                                id nilObject,
                                                NSError *callbackError) {
            if (callbackError == nil) {
                
                completionBlock(YES,callbackError);
            } else {
                completionBlock(NO,callbackError);
                
            }
        }];
    }
}
/*
 下载同步google网盘上的同步文件
 @param fileDrive 选中的文件
 */
- (void)downRestoreDataZipWithItem:(GTLRDrive_File *)fileDrive CompletionBlock:(void (^)(NSString  *zipFilePath, NSError *error))completionBlock progress:(void (^)( float progressValue))progress
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
    
    if (self.googleDriveService == nil) {
        self.googleDriveService = [[GTLRDriveService alloc] init];
        self.googleDriveService.authorizer = [[[[FHGoogleLoginManager sharedInstance] currentUser] authentication] fetcherAuthorizer];
        
    }
    GTLRQuery *query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:fileDrive.identifier];
    NSURLRequest *downloadRequest = [self.googleDriveService requestForQuery:query];
    GTMSessionFetcher *fetcher =
    [self.googleDriveService.fetcherService fetcherWithRequest:downloadRequest];
    
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *fetchError) {
        
        
        if (fetchError == nil) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if(![fileManager fileExistsAtPath:TOPTemporaryPathZip]){//如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
                [fileManager createDirectoryAtPath:TOPTemporaryPathZip withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSString *newFilePath = [TOPTemporaryPathZip stringByAppendingPathComponent:fileDrive.name];
            
            [data writeToFile:newFilePath atomically:YES];
            completionBlock(newFilePath,fetchError);
            
        }else{
            [SVProgressHUD dismiss];
            
        }
    }];
    float totalBytesExpectedToWrite = [fileDrive.size floatValue]; //file - it's GTLDriveFile to download
    [fetcher setReceivedProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten)
     {
        NSLog(@"Download progress - %.2f",(totalBytesWritten )/totalBytesExpectedToWrite);
        //                    if (drives.count<=1) {
        progress(totalBytesWritten/totalBytesExpectedToWrite);
        
        //                    }
        
    }];
}


- (void)setProgress:(NSProgress *)progress
{
    _progress = progress;
    
    [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:0 context:ProgressObserverContext];
}

- (void)setDownCloudProgress:(NSProgress *)downCloudProgress
{
    _downCloudProgress = downCloudProgress;
    [downCloudProgress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:0 context:ProgressObserverDownContext];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == ProgressObserverContext){
        WeakSelf(ws);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSProgress *progress = object;
            [SVProgressHUD dismiss];
            
            BOOL isInback =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"isDownOrUpdateInback"] boolValue];
            if (isInback== NO) {
                if (ws.downProgressView == nil) {
                    TOPDownProgressAlertView *downProgressView  = [TOPDownProgressAlertView top_creatXIB];
                    [downProgressView top_showXib];
                    downProgressView.closeViewBlock = ^{
                        //                    [self.downProgressView top_showXib];
                        ws.downProgressView = nil;
                    };
                    ws.downProgressView = downProgressView;
                }
                ws.downProgressView.progressFloat = progress.fractionCompleted;
                if (ws.oneDriveDownOrUpdate) {
                    ws.downProgressView.titleName = [NSString stringWithFormat:@"%@ (%.f%%)",NSLocalizedString(@"topscan_restoreuploadingfile", @""),progress.fractionCompleted*100];
                    
                }else{
                    ws.downProgressView.titleName = [NSString stringWithFormat:@"%@ (%.f%%)",NSLocalizedString(@"topscan_filestartbackup", @""),progress.fractionCompleted*100];
                    
                }
            }
            
            
            if (progress.fractionCompleted  >= 1.0f) {
                [SVProgressHUD dismiss];
                
            }
        });
    }else if (context == ProgressObserverDownContext)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSProgress *progress = object;
            
            [[TOPProgressStripeView shareInstance] top_showProgress:progress.fractionCompleted withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(1),@(self.fileTotal)]];
            
            if (progress.fractionCompleted  >= 1.0f) {
                [[TOPProgressStripeView shareInstance] dismiss];
            }
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

/*
 合并文件
 */
- (void)installDownLoadDataDocoumentFile:(NSString *)zipFilePath
{
    BOOL isClearFile = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RestoreMerge"] boolValue];
    if (isClearFile == YES) {
        TOPSCAlertController *col = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"") message:NSLocalizedString(@"topscan_deletedrive", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSLocalizedString(@"topscan_cancel", @"") uppercaseString]  style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [TOPWHCFileManager top_removeItemAtPath:TOPTemporaryPathUnZip];
            [TOPWHCFileManager top_removeItemAtPath:TOPTemporaryPathZip];
            return;
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            
            NSMutableArray *tempDocumentsDir= [TOPDocumentHelper top_getCurrentFileAndPath:[TOPDocumentHelper top_getDocumentsPathString]];
            for (NSString *documentPath in tempDocumentsDir) {
                [TOPWHCFileManager top_removeItemAtPath:documentPath];
            }
            NSMutableArray *folderDocumentsDirs = [TOPDocumentHelper top_getCurrentFileAndPath:[TOPDocumentHelper top_getFoldersPathString]];
            for (NSString * folderPath in folderDocumentsDirs) {
                [TOPWHCFileManager top_removeItemAtPath:folderPath];
            }
            NSMutableArray *signPngDocumentsDirs = [TOPDocumentHelper top_getCurrentFileAndPath:[TOPDocumentHelper top_getBelongDocumentPathString:@"SignPng"]];
            for (NSString * folderPath in signPngDocumentsDirs) {
                [TOPWHCFileManager top_removeItemAtPath:folderPath];
            }
            NSMutableArray *tagsDocumentsDirs = [TOPDocumentHelper top_getCurrentFileAndPath:[TOPDocumentHelper top_getBelongDocumentPathString:@"Tags"]];
            for (NSString * folderPath in tagsDocumentsDirs) {
                [TOPWHCFileManager top_removeItemAtPath:folderPath];
            }
            [TOPDBDataHandler top_emptyDBData];
            [self top_unLockZipFileDelete:zipFilePath];
            
        }];
        [col addAction:cancelAction];
        [col addAction:confirmAction];
        UIWindow *window = [UIApplication sharedApplication].windows[0];
        [window.rootViewController presentViewController:col animated:YES completion:nil];
    }else{
        [self top_unLockZipFileDelete:zipFilePath];
    }
    
}

- (void)top_unLockZipFileDelete:(NSString *)zipFilePath
{
    BOOL isClearFile = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RestoreMerge"] boolValue];
    
    NSString *unzipPath = [TOPDocumentHelper top_tempUnzipPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:TOPTemporaryPathZip]){//如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        [fileManager createDirectoryAtPath:TOPTemporaryPathZip withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TOPTemporaryPathUnZip]){//如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        [fileManager createDirectoryAtPath:TOPTemporaryPathUnZip withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SSZipArchive unzipFileAtPath:zipFilePath toDestination: unzipPath overwrite:YES password:@"" progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD showProgress:(float)entryNumber/total status:[NSString stringWithFormat:@"Processing files %.f%%",(float)entryNumber/total*100]];
                
            });
        } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                NSString *objectTempStr = [unzipPath stringByAppendingPathComponent:@"SimpleScanner"];
                NSMutableArray  *tempFileArrays=  [TOPDocumentHelper top_getCurrentFileAndPath:objectTempStr];
                [SVProgressHUD dismiss];
                [[TOPFileDataManager shareInstance].docPaths removeAllObjects];
                [[TOPFileDataManager shareInstance].folderPaths removeAllObjects];
                NSMutableArray *docData = @[].mutableCopy;
                NSMutableArray *fldData = @[].mutableCopy;
                NSMutableArray *tagData = @[].mutableCopy;
                NSFileManager * fileManger = [NSFileManager defaultManager];
                for (NSString *filePath in tempFileArrays) {
                    if ([filePath isEqualToString:@"Documents"]) {
                        NSString *tempCreatPath = [TOPDocumentHelper top_getDocumentsPathString];
                        BOOL isExist = [fileManger fileExistsAtPath:tempCreatPath isDirectory:nil];
                        
                        if (!isExist) {
                            [TOPDocumentHelper top_createDirectoryAtPath:tempCreatPath];
                        }
                        if (isClearFile == YES) {
                            
                            [self changeAndroidNameBBFileName:[objectTempStr stringByAppendingPathComponent:TOP_TRDocumentsString] ];
                            [TOPDocumentHelper top_moveFileItemsAtPath:[objectTempStr stringByAppendingPathComponent:TOP_TRDocumentsString] toNewFileAtPath:[TOPDocumentHelper top_getDocumentsPathString]];
                        }else{
                            NSMutableArray  *oldDocumentArrays=  [TOPDocumentHelper top_getCurrentFileAndPath:[TOPDocumentHelper top_getDocumentsPathString]];
                            NSMutableArray  *newDocumentArrays=  [TOPDocumentHelper top_getCurrentFileAndPath:[objectTempStr stringByAppendingPathComponent:TOP_TRDocumentsString]];
                            
                            for (int i= 0; i < newDocumentArrays.count; i ++) {
                                NSString *newPath = newDocumentArrays[i];
                                if ([oldDocumentArrays containsObject:newPath]) {
                                    [self changeAndroidFileName:[objectTempStr stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",newPath]]];
                                    
                                    NSString *creatNewPath = [NSString stringWithFormat:@"%@/%@",[TOPDocumentHelper top_getDocumentsPathString],[TOPDocumentHelper  top_newDocumentFileName:[[TOPDocumentHelper top_getDocumentsPathString] stringByAppendingPathComponent:newPath]]];
                                    
                                    NSString *tempCreatPath = [TOPDocumentHelper top_createDirectoryAtPath:creatNewPath];
                                    [TOPDocumentHelper top_moveFileItemsAtPath:[objectTempStr stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",newPath]] toNewFileAtPath:tempCreatPath];
                                    [docData addObject:tempCreatPath];
                                }else{
                                    [self changeAndroidFileName:[objectTempStr stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",newPath]]];
                                    
                                    NSString *creatNewPath = [NSString stringWithFormat:@"%@/%@",[TOPDocumentHelper top_getDocumentsPathString],newPath];
                                    NSString *tempCreatPath = [TOPDocumentHelper top_createDirectoryAtPath:creatNewPath];
                                    [TOPDocumentHelper top_moveFileItemsAtPath:[objectTempStr stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",newPath]] toNewFileAtPath:tempCreatPath];
                                    [docData addObject:tempCreatPath];
                                }
                            }
                        }
                    }else if([filePath isEqualToString:@"Folders"]){
                        NSString *tempCreatPath = [TOPDocumentHelper top_getFoldersPathString];
                        BOOL isExist = [fileManger fileExistsAtPath:[TOPDocumentHelper top_getFoldersPathString] isDirectory:nil];
                        
                        if (!isExist) {
                            [TOPDocumentHelper top_createDirectoryAtPath:[TOPDocumentHelper top_getFoldersPathString]];
                        }
                        
                        NSString *oldFoldersPath = [objectTempStr stringByAppendingPathComponent:TOP_TRFoldersString];
                        if (isClearFile == YES) {
                            
                            [self changeAndroidNameBBFileName:oldFoldersPath];
                            
                            [TOPDocumentHelper top_moveFileItemsAtPath:oldFoldersPath toNewFileAtPath:tempCreatPath];
                        }else{
                            [self installFloderAllFileWithPath:oldFoldersPath foldersPath:[TOPDocumentHelper top_getFoldersPathString]];
                            
                        }
                    }else if([filePath isEqualToString:@"SignPng"]){
                        
                        NSString *tempCreatPath = [TOPDocumentHelper top_getBelongDocumentPathString:@"SignPng"];
                        BOOL isExist = [fileManger fileExistsAtPath:tempCreatPath isDirectory:nil];
                        
                        NSString *oldSignPngPath = [objectTempStr stringByAppendingPathComponent:@"SignPng"];
                        if (isExist) {
                            [TOPDocumentHelper top_moveFileItemsAtPath:oldSignPngPath toNewFileAtPath:tempCreatPath];
                            
                        }else{
                            [TOPDocumentHelper top_createDirectoryAtPath:tempCreatPath];
                            [TOPDocumentHelper top_moveFileItemsAtPath:oldSignPngPath toNewFileAtPath:tempCreatPath];
                            
                        }
                        
                        
                    }else if([filePath containsString:@"Tags"]){
                        NSString *tempCreatPath = [TOPDocumentHelper top_getBelongDocumentPathString:@"Tags"];
                        BOOL isExist = [fileManger fileExistsAtPath:tempCreatPath isDirectory:nil];
                        if (!isExist) {
                            [TOPDocumentHelper top_createDirectoryAtPath:tempCreatPath];
                            
                            NSString *tempTags =    [self changeAndroidFileName:[objectTempStr stringByAppendingPathComponent:filePath]];
                            [TOPDocumentHelper top_moveFileItemsAtPath:tempTags toNewFileAtPath:tempCreatPath];
                            
                        }else{
                            if (isClearFile == YES) {
                                NSString *tempTags =    [self changeAndroidFileName:[objectTempStr stringByAppendingPathComponent:filePath]];
                                
                                [TOPDocumentHelper top_moveFileItemsAtPath:tempTags toNewFileAtPath:tempCreatPath];
                                
                            }else{
                                NSString *tempTags =    [self changeAndroidFileName:[objectTempStr stringByAppendingPathComponent:filePath]];
                                NSMutableArray *folderList = [TOPDocumentHelper top_getCurrentFileAndPath:tempTags];
                                NSMutableArray  *oldDocumentArrays=  [TOPDocumentHelper top_getCurrentFileAndPath:tempCreatPath];
                                for (NSString *oldFileName in folderList) {
                                    if (![oldDocumentArrays containsObject:oldFileName]) {
                                        NSString *path = [tempCreatPath stringByAppendingPathComponent:oldFileName];
                                        [TOPDocumentHelper top_createDirectoryAtPath:path];
                                        [tagData addObject:path];
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                if (isClearFile) {//删除原文件，重新写入备份文件
                    [TOPDBDataHandler top_loadingRealmDBData];
                } else {//合并，增加文件
                    [fldData addObjectsFromArray:[TOPFileDataManager shareInstance].folderPaths];
                    [docData addObjectsFromArray:[TOPFileDataManager shareInstance].docPaths];
                    NSMutableArray *fileData = @[].mutableCopy;
                    [fileData addObject:fldData];
                    [fileData addObject:docData];
                    [fileData addObject:tagData];
                    [TOPDBDataHandler top_restoreFileData:fileData];
                }
                [SVProgressHUD showSuccessWithStatus:@"Backup file restore succeeded."];
                [SVProgressHUD dismissWithDelay:1];
                
                [TOPWHCFileManager top_removeItemAtPath:TOPTemporaryPathUnZip];
                [TOPWHCFileManager top_removeItemAtPath:TOPTemporaryPathZip];
            });
            
        }];
        
    });
}
- (void)installFloderAllFileWithPath:(NSString *)path  foldersPath:(NSString *)foldersPath{
    
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir=NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            // 浅遍历
            NSError *error;
            NSArray *oldFolderDirArray = [fileManger contentsOfDirectoryAtPath:path error:&error];
            if (!oldFolderDirArray.count) {//没有子目录 则是Folder
                
            } else {
                BOOL hasDoc = NO;
                for (NSString *fileName in oldFolderDirArray) {
                    if ([fileName containsString:@".DS_Store"]) {
                        continue;
                    }
                    if ([TOPDocumentHelper top_isValidateJPG:fileName] || [fileName containsString:@".txt"] || [fileName containsString:@".TXT"]) {//判断是否为jpg 有图片 则是Doc
                        BOOL oldisExist = [fileManger fileExistsAtPath:foldersPath isDirectory:nil];
                        if (oldisExist) {
                            NSString *creatStr = [NSString stringWithFormat:@"%@/%@",foldersPath.stringByDeletingLastPathComponent,[TOPDocumentHelper  top_newDocumentFileName:foldersPath]];
                            [fileManger createDirectoryAtPath:creatStr withIntermediateDirectories:YES attributes:nil error:nil];
                            [self changeAndroidNameBBFileName:path];
                            
                            [TOPDocumentHelper top_moveFileItemsAtPath:path  toNewFileAtPath:creatStr];
                            [[TOPFileDataManager shareInstance].docPaths addObject:creatStr];
                            
                        }else{
                            NSString *creatStr = [foldersPath stringByAppendingPathComponent:fileName];
                            [fileManger createDirectoryAtPath:creatStr withIntermediateDirectories:YES attributes:nil error:nil];
                            [self changeAndroidNameBBFileName:path];
                            
                            [TOPDocumentHelper top_moveFileItemsAtPath:path   toNewFileAtPath:creatStr];
                            [[TOPFileDataManager shareInstance].docPaths addObject:creatStr];
                        }
                        break;
                    } else {// 不是图片 则是Folder
                        //递归遍历该文件下所有的子目录
                        BOOL oldisExist = [fileManger fileExistsAtPath:[foldersPath stringByAppendingPathComponent:fileName] isDirectory:nil];
                        
                        if (oldisExist) {
                            if (!hasDoc) {//确保遍历子目录过程中只计算一次
                                hasDoc = YES;
                            }
                            NSString * documentPath = [path stringByAppendingPathComponent:fileName];
                            NSString * documentPathFolder = [foldersPath stringByAppendingPathComponent:fileName];
                            [self installFloderAllFileWithPath:documentPath foldersPath:documentPathFolder];
                        }else{
                            NSString *creatStr = [NSString stringWithFormat:@"%@/%@",foldersPath,[TOPDocumentHelper  top_newDocumentFileName:[foldersPath stringByAppendingPathComponent:fileName]]];
                            
                            [fileManger createDirectoryAtPath:creatStr withIntermediateDirectories:YES attributes:nil error:nil];
                            [self changeAndroidNameBBFileName:path];
                            
                            [TOPDocumentHelper top_moveFileItemsAtPath:[path stringByAppendingPathComponent:fileName]  toNewFileAtPath:creatStr];
                            
                            [[TOPFileDataManager shareInstance].folderPaths addObject:creatStr];
                            
                        }
                        
                    }
                }
                
            }
            
        }
        
    }
    
}


/*
 修改.开头的文件的名称 并返回修改后的路径(.Tags文件内的.文件也修改掉)
 */
- (NSString *)changeAndroidFileName:(NSString *)filePath
{
    NSString *tempTags = filePath;
    
    //    NSLog(@"%@",tempTags);
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir=NO;
    BOOL isExist = [fileManger fileExistsAtPath:tempTags isDirectory:&isDir];
    if (isExist) {
        if (![tempTags.lastPathComponent isEqualToString:@".DS_Store"]) {
            if ([tempTags.lastPathComponent hasPrefix:@"."]) {
                tempTags =  [TOPDocumentHelper top_changeDocumentName:tempTags folderText:
                             [tempTags.lastPathComponent substringFromIndex:1]];
            }
        }
        //         NSMutableArray *folderList = [TOPDocumentHelper top_getCurrentFileAndPath:tempTags];
        NSError *error;
        // 浅遍历
        NSArray *folderList = [fileManger contentsOfDirectoryAtPath:tempTags error:&error];
        for (NSString *fileName in folderList) {
            if ([fileName isEqualToString:@".Tags"]) {
                [self changeAndroidFileName:[filePath stringByAppendingPathComponent:fileName]];
            }else{
                if ([fileName hasSuffix:@".pdf"] || [fileName hasSuffix:@".PDF"]|| [fileName hasSuffix:@".PNG"] || [fileName hasSuffix:@".png"] || [fileName hasSuffix:@".DS_Store"]  ) {
                    [fileManger removeItemAtPath: [tempTags stringByAppendingPathComponent:fileName] error:&error];
                }
                if ([fileName hasPrefix:@"."]) {
                    NSString *subFileName = [fileName substringFromIndex:1];
                    [TOPDocumentHelper top_changeFileName:[tempTags stringByAppendingPathComponent:fileName] folderText:subFileName];
                }
            }
            
        }
    }
    
    return tempTags;
}

/*
 修改.开头的文件的名称 并返回修改后的路径(.Tags文件内的.文件也修改掉)
 */
- (void)changeAndroidNameBBFileName:(NSString *)filePath
{
    NSFileManager * fileManger = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *dirEnumerator = [fileManger enumeratorAtPath:filePath];
    NSArray *tempAllObjects = dirEnumerator.allObjects;
    for (NSString* fileNames in tempAllObjects) {
        
        NSString* tempTags = [filePath stringByAppendingPathComponent:fileNames] ;
        BOOL isDir=NO;
        BOOL isExist = [fileManger fileExistsAtPath:tempTags  isDirectory:&isDir];
        if (isExist) {
            if (![tempTags.lastPathComponent isEqualToString:@".DS_Store"]) {
                if ([tempTags.lastPathComponent hasSuffix:@".pdf"] || [tempTags.lastPathComponent hasSuffix:@".PDF"]|| [tempTags.lastPathComponent hasSuffix:@".PNG"] || [tempTags.lastPathComponent hasSuffix:@".png"] || [tempTags.lastPathComponent hasSuffix:@".DS_Store"]  ) {
                    NSError *error;
                    [fileManger removeItemAtPath: [tempTags stringByAppendingPathComponent:tempTags.lastPathComponent] error:&error];
                }
                if ([tempTags.lastPathComponent hasPrefix:@"."]) {
                    
                    NSString *subFileName = [tempTags.lastPathComponent  substringFromIndex:1];
                    [TOPDocumentHelper top_changeFileName:tempTags folderText:subFileName];
                    
                }
            }
            
        }
    }
}

#pragma mark- 批量下载PDF 和JPG 生成 Doc

- (void)breakupPdfwithtempPDFs:(NSMutableArray *)temparrays
{
    
    WeakSelf(ws);
    if (temparrays.count<2) {
        NSString * newFilePath =  [[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:[temparrays firstObject]];
        
        NSString  *pathString =  [temparrays firstObject];
        NSLog(@"%@",pathString.stringByDeletingPathExtension);

        NSData *sendData = [NSData dataWithContentsOfFile:newFilePath];
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)sendData );
        CGPDFDocumentRef fromPDFDoc =  CGPDFDocumentCreateWithProvider(provider);
        if (fromPDFDoc == NULL) {
//            CFRelease((__bridge CFDataRef)sendData);
        }else{
            if (CGPDFDocumentIsEncrypted (fromPDFDoc)) {//判断pdf是否加密
                if (!CGPDFDocumentUnlockWithPassword (fromPDFDoc, "")) {//判断密码是否为""
                        UIAlertController *col = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_decryption", @"")message:[temparrays firstObject] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok" ,@"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        UITextField *  textField=   col.textFields.firstObject;
                        //判断字符串是否全是空格
                        if ( [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
                            col.title = NSLocalizedString(@"topscan_error", @"");
                            col.message = NSLocalizedString(@"topscan_pdferror", @"");
                            col.textFields.firstObject.text = @"";
                            [[TOPDocumentHelper top_topViewController] presentViewController:col animated:YES completion:nil];
                            return;
                        }
                        //去除textfieled的前后空格
                        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                        if (textField.text != NULL) {
                            if (CGPDFDocumentUnlockWithPassword (fromPDFDoc, [textField.text UTF8String]))
                            {
                                NSString * saveFilePath = [TOPDocumentHelper top_createNewDocument:pathString.stringByDeletingPathExtension atFolderPath:self.downloadFilePath];
                                if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild) {
                                    saveFilePath = [TOPDocumentHelper top_getDriveDownloadJPGPathPathString];
                                }
                                NSString *homeChildPath = @"";
                                if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild ) {
                                    homeChildPath = self.downloadFilePath;
                                }
                                //使用password对pdf进行解密，密码有效返回yes
                                
                                [TOPDocumentHelper top_getCloudUIImageFromPDFPageWithpdfpathUrl:fromPDFDoc password:textField.text docPath:saveFilePath homeChildPath:homeChildPath  progress:^(CGFloat progressString) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        //拆分成pdf的进度条
                                        NSString * stateStr = [[NSString alloc]initWithFormat:@"1/1\n%@…(%.f%%)",NSLocalizedString(@"topscan_processing", @""),progressString*100];
                                        [SVProgressHUD showWithStatus:stateStr];
                                        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];

                                    });

                                } success:^(id _Nonnull responseObj) {
                                    
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                                    [ws breakPDFAndCreatDocToDownloadFilePathWithpdfPath:saveFilePath];

                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [SVProgressHUD dismiss];

                                        [TOPWHCFileManager top_removeItemAtPath:newFilePath];
                                        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_downloadsuccessfilly", @"")];

                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"downDrives" object:nil userInfo:nil];
                                    });
                                    });
                                }];

                            }else{
                                col.title = NSLocalizedString(@"topscan_error", @"");
                                col.message = NSLocalizedString(@"topscan_pdferror", @"");
                                col.textFields.firstObject.text = @"";
                                [[TOPDocumentHelper top_topViewController] presentViewController:col animated:YES completion:nil];
                                return;
                            }
                        }
                    }];

                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_skip", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [TOPWHCFileManager top_removeItemAtPath:newFilePath];
                                if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild) {
                                    NSString * saveFilePath =[TOPDocumentHelper top_getDriveDownloadJPGPathPathString];
                                    [ws breakPDFAndCreatDocToDownloadFilePathWithpdfPath:saveFilePath];
                                }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"downDrives" object:nil userInfo:nil];
                            });
                            });

                        }];
                    [col addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        textField.placeholder =  NSLocalizedString(@"topscan_placeholderpassword", @"");
                    }];
                    [col addAction:cancelAction];

                    [col addAction:confirmAction];
                    [[TOPDocumentHelper top_topViewController] presentViewController:col animated:YES completion:nil];
                }
            }else{
                NSString * saveFilePath = [TOPDocumentHelper top_createNewDocument:pathString.stringByDeletingPathExtension atFolderPath:self.downloadFilePath];
                if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild) {
                    saveFilePath = [TOPDocumentHelper top_getDriveDownloadJPGPathPathString];
                }
                NSString *homeChildPath = @"";
                if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild ) {
                    homeChildPath = self.downloadFilePath;
                }
                [TOPDocumentHelper top_getCloudUIImageFromPDFPageWithpdfpathUrl:fromPDFDoc password:@"" docPath:saveFilePath homeChildPath:homeChildPath  progress:^(CGFloat progressString) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //拆分成pdf的进度条
                        NSString * stateStr = [[NSString alloc]initWithFormat:@"1/1\n%@…(%.f%%)",NSLocalizedString(@"topscan_processing", @""),progressString*100];
                        [SVProgressHUD showWithStatus:stateStr];
                        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];

                    });

                } success:^(id _Nonnull responseObj) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [ws breakPDFAndCreatDocToDownloadFilePathWithpdfPath:saveFilePath];
                        [TOPWHCFileManager top_removeItemAtPath:newFilePath];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [[NSNotificationCenter defaultCenter] postNotificationName:
                         @"downDrives" object:nil userInfo:nil];
                    });
                    });

                }];
            }
        }
        CGDataProviderRelease(provider);
    }else{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int idx = 0; idx<temparrays.count; idx++) {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                

                NSString * newFilePath =  [[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:temparrays[idx]];

                NSString  *pathString =  temparrays[idx];


                NSData *sendData = [NSData dataWithContentsOfFile:newFilePath];
                CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)sendData );
                CGPDFDocumentRef fromPDFDoc =  CGPDFDocumentCreateWithProvider(provider);
                if (fromPDFDoc == NULL) {
                    CFRelease((__bridge CGDataProviderRef)sendData);
                }else{
                    if (CGPDFDocumentIsEncrypted (fromPDFDoc)) {//判断pdf是否加密
                        if (!CGPDFDocumentUnlockWithPassword (fromPDFDoc, "")) {//判断密码是否为""
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIAlertController *col = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_decryption", @"") message:temparrays[idx] preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok" ,@"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                UITextField *  textField=   col.textFields.firstObject;
                                //判断字符串是否全是空格
                                if ( [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
                                    col.title = NSLocalizedString(@"topscan_error", @"");
                                    col.message = NSLocalizedString(@"topscan_pdferror", @"");
                                    col.textFields.firstObject.text = @"";
                                    [[TOPDocumentHelper top_topViewController] presentViewController:col animated:YES completion:nil];
                                    return;
                                }
                                //去除textfieled的前后空格
                                textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                                if (textField.text != NULL) {
                                    if (CGPDFDocumentUnlockWithPassword (fromPDFDoc, [textField.text UTF8String]))
                                    {
                                        NSLog(@"%@",textField.text);
                                        NSString * saveFilePath = [TOPDocumentHelper top_createNewDocument:pathString.stringByDeletingPathExtension atFolderPath:self.downloadFilePath];

                                        if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild) {
                                            saveFilePath = [TOPDocumentHelper top_getDriveDownloadJPGPathPathString];
                                        }
                                        NSString *homeChildPath = @"";
                                        if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild ) {
                                            homeChildPath = self.downloadFilePath;
                                        }
                                        [TOPDocumentHelper top_getCloudUIImageFromPDFPageWithpdfpathUrl:fromPDFDoc password:textField.text docPath:saveFilePath  homeChildPath:homeChildPath progress:^(CGFloat progressString) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                //拆分成pdf的进度条
                                                NSString * stateStr = [[NSString alloc]initWithFormat:@"%d/%ld\n%@…(%.f%%)",idx+1,temparrays.count,NSLocalizedString(@"topscan_processing", @""),progressString*100];
                                                [SVProgressHUD showWithStatus:stateStr];
                                                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];

                                            });
                                        } success:^(id _Nonnull responseObj) {

                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                if (self.currentDownloadFileType != TOPDownloadFileToDriveAddPathTypeHomeChild) {
                                                    [ws breakPDFAndCreatDocToDownloadFilePathWithpdfPath:saveFilePath];
                                                }
                                                [TOPWHCFileManager top_removeItemAtPath:newFilePath];
                                                if (idx == temparrays.count-1) {
                                                    if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild) {
                                                        [ws breakPDFAndCreatDocToDownloadFilePathWithpdfPath:saveFilePath];
                                                    }
                                                    dispatch_semaphore_signal(semaphore);

                                                    dispatch_async(dispatch_get_main_queue(), ^{

                                                    [[NSNotificationCenter defaultCenter] postNotificationName:
                                                     @"downDrives" object:nil userInfo:nil];
                                                    [SVProgressHUD dismiss];
                                                    });
                                                }
                                            });
                                        }];
                                    }else{
                                        col.title = NSLocalizedString(@"topscan_error", @"");
                                        col.message = NSLocalizedString(@"topscan_pdferror", @"");
                                        col.textFields.firstObject.text = @"";
                                        [[TOPDocumentHelper top_topViewController] presentViewController:col animated:YES completion:nil];
                                        return;
                                    }
                                }
                            }];

                                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_skip", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                                        [TOPWHCFileManager top_removeItemAtPath:newFilePath];
                                        if (idx == temparrays.count-1) {
                                            if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild) {
                                                NSString * saveFilePath =[TOPDocumentHelper top_getDriveDownloadJPGPathPathString];
                                                [ws breakPDFAndCreatDocToDownloadFilePathWithpdfPath:saveFilePath];
                                            }
                                            dispatch_semaphore_signal(semaphore);

                                            dispatch_async(dispatch_get_main_queue(), ^{

                                            [[NSNotificationCenter defaultCenter] postNotificationName:
                                             @"downDrives" object:nil userInfo:nil];
                                            [SVProgressHUD dismiss];
                                            });

                                        }
                                        
                                    });
                                }];
                            [col addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                                textField.placeholder =   NSLocalizedString(@"topscan_placeholderpassword", @"");
                            }];
                            [col addAction:cancelAction];

                            [col addAction:confirmAction];
                            [[TOPDocumentHelper top_topViewController] presentViewController:col animated:YES completion:nil];
                            });
                        }
                    }else{
                        NSString * saveFilePath = [TOPDocumentHelper top_createNewDocument:pathString.stringByDeletingPathExtension atFolderPath:self.downloadFilePath];
                        if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild) {
                            saveFilePath = [TOPDocumentHelper top_getDriveDownloadJPGPathPathString];
                        }
                        NSString *homeChildPath = @"";
                        if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild ) {
                            homeChildPath = self.downloadFilePath;
                        }
                        [TOPDocumentHelper top_getCloudUIImageFromPDFPageWithpdfpathUrl:fromPDFDoc password:@"" docPath:saveFilePath homeChildPath:homeChildPath progress:^(CGFloat progressString) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //拆分成pdf的进度条
                                NSString * stateStr = [[NSString alloc]initWithFormat:@"%d/%ld\n%@…(%.f%%)",idx+1,temparrays.count,NSLocalizedString(@"topscan_processing", @""),progressString*100];
                                [SVProgressHUD showWithStatus:stateStr];
                                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];

                            });
                        } success:^(id _Nonnull responseObj) {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                if (self.currentDownloadFileType != TOPDownloadFileToDriveAddPathTypeHomeChild) {
                                    [ws breakPDFAndCreatDocToDownloadFilePathWithpdfPath:saveFilePath];
                                }
                                dispatch_semaphore_signal(semaphore);

                                [TOPWHCFileManager top_removeItemAtPath:newFilePath];
                                if (idx == temparrays.count-1) {
                                    if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild) {
                                        [ws breakPDFAndCreatDocToDownloadFilePathWithpdfPath:saveFilePath];
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{

                                    [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_downloadsuccessfilly", @"")];

                                    [[NSNotificationCenter defaultCenter] postNotificationName:
                                     @"downDrives" object:nil userInfo:nil];
                                    [SVProgressHUD dismiss];
                                    });
                                }
                            });
                        }];
                    }
                }
                CGDataProviderRelease(provider);
            }
        });
    }
}
- (NSMutableArray *)selectDownloadDriveArrays
{
    if (_selectDownloadDriveArrays == nil) {
        _selectDownloadDriveArrays = [NSMutableArray array];
    }
    return _selectDownloadDriveArrays;
}

- (void)startDownloadSelectFileDataWith:(NSMutableArray *)drives withDownloadSave:(NSString *)savePath Type:(TOPDownLoadDataStyle)driveType downloadEnterType:(TOPDownloadFileToDriveAddPathType) downloadFileType
                              withDocID:(NSString *)currentDocId
{
    self.fileTotal = drives.count;
    [self.drivePaths removeAllObjects];
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...(1/%@)",NSLocalizedString(@"topscan_processing", @""),@( drives.count)]];
    [[TOPProgressStripeView shareInstance] top_resetProgress];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    NSMutableArray *pathWitchs = [NSMutableArray array];
    self.downloadFilePath = savePath;
    self.currentDownloadFileType = downloadFileType;
    self.currentDocId = currentDocId;
    
    NSArray *  homeChildArrays = [NSArray array];
    if (self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeHomeChild) {
        homeChildArrays = [TOPDocumentHelper top_sortPicsAtPath:self.downloadFilePath];
    }
    switch (driveType) {
        case TOPDownLoadDataStyleDefaultGoogle:
        {
            if (self.googleDriveService== nil) {
                self.googleDriveService = [[GTLRDriveService alloc] init];
                self.googleDriveService.authorizer = [[[[FHGoogleLoginManager sharedInstance] currentUser] authentication] fetcherAuthorizer];
                
            }
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [drives enumerateObjectsUsingBlock:^(GTLRDrive_File*  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    GTLRQuery *query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:item.identifier];
                    NSURLRequest *downloadRequest = [self.googleDriveService requestForQuery:query];
                    GTMSessionFetcher *fetcher =
                    [self.googleDriveService.fetcherService fetcherWithRequest:downloadRequest];
                    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *fetchError) {
                        dispatch_semaphore_signal(semaphore);
                        
                        NSLog(@"main thread:%d",[NSThread isMainThread]);
                        if (fetchError == nil) {
                            if ([item.mimeType isEqualToString:@"image/png"] || [item.mimeType isEqualToString:@"image/jpeg"]  ) {
                                UIImage *img = [TOPPictureProcessTool top_fetchOriginalImageWithData:data];
                                
                                NSString *imagePath  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:idx+homeChildArrays.count],TOP_TRJPGPathSuffixString];
                                NSString *newFilePath =  [[TOPDocumentHelper top_getDriveDownloadJPGPathPathString] stringByAppendingPathComponent:imagePath];
                                [UIImageJPEGRepresentation(img, TOP_TRPicScale) writeToFile:newFilePath atomically:YES];
                                NSString *oriName = [NSString stringWithFormat:@"%@%@",TOPRSimpleScanOriginalString,imagePath];
                                NSString *oriEndPath = [[TOPDocumentHelper top_getDriveDownloadJPGPathPathString] stringByAppendingPathComponent:oriName];
                                [UIImageJPEGRepresentation(img, TOP_TRPicScale) writeToFile:oriEndPath atomically:YES];
                                
                                [pathWitchs addObject:imagePath];
                                if (self.fileTotal >1) {
                                    CGFloat progressValue = (CGFloat)pathWitchs.count/self.fileTotal;
                                    [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(pathWitchs.count),@(self.fileTotal)]];
                                }
                                if (pathWitchs.count>= self.fileTotal) {
                                    [[TOPProgressStripeView shareInstance] dismiss];
                                    [self.selectDownloadDriveArrays  removeAllObjects];
                                    [self queryDownLoadFileContentPdfFileWith:pathWitchs];
                                }
                                
                            }else if ([item.mimeType isEqualToString:@"application/pdf"]){
                                NSString *newFilePath = [[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:item.name];
                                if ([TOPWHCFileManager top_isExistsAtPath:newFilePath]) {
                                    NSString *filePath = [[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:item.name.stringByDeletingPathExtension];
                                    newFilePath =[[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:[[TOPDocumentHelper top_newDocumentFileName:filePath] stringByAppendingString:@".pdf"]];
                                }
                                [data writeToFile:newFilePath atomically:YES];
                                [pathWitchs addObject:newFilePath.lastPathComponent];
                                if (self.fileTotal >1) {
                                    CGFloat progressValue = (CGFloat)pathWitchs.count/self.fileTotal;
                                    [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(pathWitchs.count),@(self.fileTotal)]];
                                }
                                if (pathWitchs.count>= self.fileTotal) {
                                    [[TOPProgressStripeView shareInstance] dismiss];
                                    [self.selectDownloadDriveArrays  removeAllObjects];
                                    [self queryDownLoadFileContentPdfFileWith:pathWitchs];
                                }
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                if (self.drivePaths.count) {
                                    dispatch_semaphore_signal(semaphore);
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"downDrives" object:nil userInfo:nil];
                                }
                                [[TOPProgressStripeView shareInstance] dismiss];
                                [self.selectDownloadDriveArrays  removeAllObjects];
                                
                            });
                            
                        }
                    }];
                    WeakSelf(ws);
                    __block  long long bytesWritten1 =0;
                    float totalBytesExpectedToWrite = [item.size floatValue]; //file - it's GTLDriveFile to download
                    [fetcher setReceivedProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten)
                     {
                        bytesWritten1 +=bytesWritten;
                        if (ws.fileTotal< 2) {
                            [[TOPProgressStripeView shareInstance] top_showProgress:bytesWritten1/totalBytesExpectedToWrite withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(1),@(self.fileTotal)]];
                        }
                        
                    }];
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    
                }];
                
            });
            
            
        }
            break;
        case TOPDownLoadDataStyleStyleBox:
        {
            BOXContentClient *  client =  [BOXContentClient defaultClient];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [drives enumerateObjectsUsingBlock:^(BOXItem*  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSOutputStream *outputStream = [[NSOutputStream alloc] initToMemory];
                    BOXFileDownloadRequest *downloadRequest = [client fileDownloadRequestWithID:item.modelID toOutputStream:outputStream];
                    WeakSelf(ws);
                    [downloadRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
                        //                        DLog(@"upload -- %.2f",1.0*totalBytesTransferred/totalBytesExpectedToTransfer);
                        //                        DLog(@"upload main thread:%d",[NSThread isMainThread]);
                        
                        if (ws.fileTotal< 2) {
                            [[TOPProgressStripeView shareInstance] top_showProgress:1.0*totalBytesTransferred/totalBytesExpectedToTransfer withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(1),@(self.fileTotal)]];
                            
                        }
                    }
                                                     completion:^(NSError *error) {
                        dispatch_semaphore_signal(semaphore);
                        
                        if (error == nil) {
                            
                            BOXFile * fileItem = (BOXFile *)item;
                            if ( [[fileItem.extension lowercaseString] isEqualToString:@"jpg"] || [[fileItem.extension lowercaseString] isEqualToString:@"jpeg"] || [[fileItem.extension lowercaseString] isEqualToString:@"png"]) {
                                
                                NSData *data = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
                                UIImage *img = [TOPPictureProcessTool top_fetchOriginalImageWithData:data];
                                
                                NSString *imagePath  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:idx+homeChildArrays.count],TOP_TRJPGPathSuffixString];
                                NSString *newFilePath =  [[TOPDocumentHelper top_getDriveDownloadJPGPathPathString] stringByAppendingPathComponent:imagePath];
                                [UIImageJPEGRepresentation(img, TOP_TRPicScale) writeToFile:newFilePath atomically:YES];
                                NSString *oriName = [NSString stringWithFormat:@"%@%@",TOPRSimpleScanOriginalString,imagePath];
                                NSString *oriEndPath = [[TOPDocumentHelper top_getDriveDownloadJPGPathPathString] stringByAppendingPathComponent:oriName];
                                [UIImageJPEGRepresentation(img, TOP_TRPicScale) writeToFile:oriEndPath atomically:YES];
                                
                                [pathWitchs addObject:imagePath];
                                if (self.fileTotal >1) {
                                    CGFloat progressValue = (CGFloat)pathWitchs.count/self.fileTotal;
                                    [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(pathWitchs.count),@(self.fileTotal)]];
                                }
                                
                                if (pathWitchs.count>= self.fileTotal) {
                                    dispatch_async(dispatch_get_main_queue(), ^(){
                                        [self.selectDownloadDriveArrays  removeAllObjects];
                                        [[TOPProgressStripeView shareInstance] dismiss];
                                        [self queryDownLoadFileContentPdfFileWith:pathWitchs];
                                    });
                                }
                                
                            }else if ([[fileItem.extension lowercaseString] isEqualToString:@"pdf"] )
                            {
                                
                                NSData *data = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
                                NSString *newFilePath = [[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:item.name];
                                if ([TOPWHCFileManager top_isExistsAtPath:newFilePath]) {
                                    NSString *filePath = [[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:item.name.stringByDeletingPathExtension];
                                    newFilePath =[[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:[[TOPDocumentHelper top_newDocumentFileName:filePath] stringByAppendingString:@".pdf"]];
                                }
                                [data writeToFile:newFilePath atomically:YES];
                                [pathWitchs addObject:item.name];
                                if (self.fileTotal >1) {
                                    CGFloat progressValue = (CGFloat)pathWitchs.count/self.fileTotal;
                                    [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(pathWitchs.count),@(self.fileTotal)]];
                                    
                                }
                                if (pathWitchs.count>= self.fileTotal) {
                                    dispatch_async(dispatch_get_main_queue(), ^(){
                                        [self.selectDownloadDriveArrays  removeAllObjects];
                                        [[TOPProgressStripeView shareInstance] dismiss];
                                        [self queryDownLoadFileContentPdfFileWith:pathWitchs];
                                        
                                    });
                                }
                            }
                            
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                [self.selectDownloadDriveArrays  removeAllObjects];
                                [[TOPProgressStripeView shareInstance] dismiss];
                                if (self.drivePaths.count) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:
                                     @"downDrives" object:nil userInfo:nil];
                                }
                            });
                        }
                        
                    }];
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                }];
            });
            
        }
            break;
        case TOPDownLoadDataStyleStyleOneDrice:
        {
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                ODClient *  client =  [ODClient currentClientWithAppConfig:[ODAppConfiguration defaultConfiguration]];
                WeakSelf(ws);
                [drives enumerateObjectsUsingBlock:^(ODItem*  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    ODURLSessionDownloadTask *task = [[[[client drive] items:item.id] contentRequest] downloadWithCompletion:^(NSURL *filePath, NSURLResponse *response, NSError *error){
                        dispatch_semaphore_signal(semaphore);
                        
                        if (!error) {
                            if ([item.file.mimeType isEqualToString:@"image/png"]|| [item.file.mimeType isEqualToString:@"image/jpeg"]) {
                                
                                NSData *itemData = [NSData dataWithContentsOfURL:(NSURL *)filePath options:NSDataReadingMappedIfSafe error:&error];
                                UIImage *img = [TOPPictureProcessTool top_fetchOriginalImageWithData:itemData];
                                
                                
                                NSString *imagePath  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:idx+homeChildArrays.count],TOP_TRJPGPathSuffixString];
                                NSString *newFilePath =  [[TOPDocumentHelper top_getDriveDownloadJPGPathPathString] stringByAppendingPathComponent:imagePath];
                                [UIImageJPEGRepresentation(img, TOP_TRPicScale) writeToFile:newFilePath atomically:YES];
                                
                                NSString *oriName = [NSString stringWithFormat:@"%@%@",TOPRSimpleScanOriginalString,imagePath];
                                NSString *oriEndPath = [[TOPDocumentHelper top_getDriveDownloadJPGPathPathString] stringByAppendingPathComponent:oriName];
                                [UIImageJPEGRepresentation(img, TOP_TRPicScale) writeToFile:oriEndPath atomically:YES];
                                
                                [pathWitchs addObject:imagePath];
                                if (ws.fileTotal >1) {
                                    CGFloat progressValue = (CGFloat)pathWitchs.count/self.fileTotal;
                                    [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(pathWitchs.count),@(self.fileTotal)]];
                                }
                                //                                [[NSFileManager defaultManager] moveItemAtURL:filePath toURL:[NSURL fileURLWithPath:newFilePath] error:nil];
                                
                                if (pathWitchs.count>= self.fileTotal) {
                                    dispatch_async(dispatch_get_main_queue(), ^(){
                                        [self.selectDownloadDriveArrays  removeAllObjects];
                                        [[TOPProgressStripeView shareInstance] dismiss];
                                        [self queryDownLoadFileContentPdfFileWith:pathWitchs];
                                        
                                    });
                                }
                            }else if([item.file.mimeType isEqualToString:@"application/pdf"])
                            {
                                //                                NSFileManager *fileManager = [NSFileManager defaultManager];
                                
                                NSString *newFilePath = [[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:item.name];
                                if ([TOPWHCFileManager top_isExistsAtPath:newFilePath]) {
                                    NSString *filePath = [[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:item.name.stringByDeletingPathExtension];
                                    newFilePath =[[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:[[TOPDocumentHelper top_newDocumentFileName:filePath] stringByAppendingString:@".pdf"]];
                                }
                                NSData *itemData = [NSData dataWithContentsOfURL:(NSURL *)filePath options:NSDataReadingMappedIfSafe error:&error];
                                [itemData writeToFile:newFilePath atomically:YES];
                                
                                //                                [fileManager moveItemAtURL:filePath toURL:[NSURL fileURLWithPath:newFilePath] error:nil];
                                [pathWitchs addObject:item.name];
                                if (self.fileTotal >1) {
                                    CGFloat progressValue = (CGFloat)pathWitchs.count/self.fileTotal;
                                    [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(pathWitchs.count),@(self.fileTotal)]];
                                    
                                }
                                if (pathWitchs.count>= self.fileTotal) {
                                    dispatch_async(dispatch_get_main_queue(), ^(){
                                        [self.selectDownloadDriveArrays  removeAllObjects];
                                        [[TOPProgressStripeView shareInstance] dismiss];
                                        [self queryDownLoadFileContentPdfFileWith:pathWitchs];
                                        
                                    });
                                }
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                if (ws.drivePaths.count) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:
                                     @"downDrives" object:nil userInfo:nil];
                                }
                                [self.selectDownloadDriveArrays  removeAllObjects];
                                [[TOPProgressStripeView shareInstance] dismiss];
                                
                            });
                        }
                        
                    }];
                    task.progress.totalUnitCount = item.size;
                    if (self.fileTotal<2) {
                        self.downCloudProgress = task.progress;
                        
                    }
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                
            });
            
            
        }
            break;
        case TOPDownLoadDataStyleStyleDropBox:
        {
            
            WeakSelf(ws);
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [drives enumerateObjectsUsingBlock:^(DBFILESMetadata*  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *dbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
                    DBUserClient *client = [[DBUserClient alloc] initWithAccessToken:dbAccessToken];
                    [[[client.filesRoutes downloadData:item.pathDisplay] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESDownloadError * _Nullable routeError, DBRequestError * _Nullable networkError, NSData * _Nullable fileData) {
                        dispatch_semaphore_signal(semaphore);
                        
                        if (result) {
                            if ([self isImageType:item.name]) {
                                UIImage *img = [TOPPictureProcessTool top_fetchOriginalImageWithData:fileData];
                                NSString *imagePath  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:idx+homeChildArrays.count],TOP_TRJPGPathSuffixString];
                                NSString *newFilePath =  [[TOPDocumentHelper top_getDriveDownloadJPGPathPathString] stringByAppendingPathComponent:imagePath];
                                [UIImageJPEGRepresentation(img, TOP_TRPicScale) writeToFile:newFilePath atomically:YES];
                                NSString *oriName = [NSString stringWithFormat:@"%@%@",TOPRSimpleScanOriginalString,imagePath];
                                NSString *oriEndPath = [[TOPDocumentHelper top_getDriveDownloadJPGPathPathString] stringByAppendingPathComponent:oriName];
                                [UIImageJPEGRepresentation(img, TOP_TRPicScale) writeToFile:oriEndPath atomically:YES];
                                
                                [pathWitchs addObject:imagePath];
                                if (self.fileTotal >1) {
                                    CGFloat progressValue = (CGFloat)pathWitchs.count/self.fileTotal;
                                    [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(pathWitchs.count),@(self.fileTotal)]];
                                    
                                }
                                
                                if (pathWitchs.count>= self.fileTotal) {
                                    dispatch_async(dispatch_get_main_queue(), ^(){
                                        [self.selectDownloadDriveArrays  removeAllObjects];
                                        [[TOPProgressStripeView shareInstance] dismiss];
                                        [self queryDownLoadFileContentPdfFileWith:pathWitchs];
                                    });
                                }
                                
                            }else if([self isPDFType:item.name])
                            {
                                NSString *newFilePath = [[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:item.name];
                                if ([TOPWHCFileManager top_isExistsAtPath:newFilePath]) {
                                    NSString *filePath = [[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:item.name.stringByDeletingPathExtension];
                                    newFilePath =[[TOPDocumentHelper top_getDriveDownloadPDFPathPathString] stringByAppendingPathComponent:[[TOPDocumentHelper top_newDocumentFileName:filePath] stringByAppendingString:@".pdf"]];
                                }
                                [fileData writeToFile:newFilePath atomically:YES];
                                [pathWitchs addObject:item.name];
                                if (self.fileTotal >1) {
                                    CGFloat progressValue = (CGFloat)pathWitchs.count/self.fileTotal;
                                    [[TOPProgressStripeView shareInstance] top_showProgress:progressValue withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(pathWitchs.count),@(self.fileTotal)]];
                                }
                                if (pathWitchs.count>= self.fileTotal) {
                                    dispatch_async(dispatch_get_main_queue(), ^(){
                                        [self.selectDownloadDriveArrays  removeAllObjects];
                                        [[TOPProgressStripeView shareInstance] dismiss];
                                        [self queryDownLoadFileContentPdfFileWith:pathWitchs];
                                    });
                                }
                                
                                
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                [self.selectDownloadDriveArrays  removeAllObjects];
                                [[TOPProgressStripeView shareInstance] dismiss];
                                if (self.drivePaths.count) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"downDrives" object:nil userInfo:nil];
                                }
                            });
                        }
                        
                        
                    }] setProgressBlock:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
                        
                        NSLog(@"%lld\n%lld\n%lld\n%f", bytesDownloaded, totalBytesDownloaded, totalBytesExpectedToDownload,(float)totalBytesDownloaded/totalBytesExpectedToDownload);
                        if (ws.fileTotal< 2) {
                            [[TOPProgressStripeView shareInstance] top_showProgress:(float)totalBytesDownloaded/totalBytesExpectedToDownload withStatus:[NSString stringWithFormat:@"%@...(%@/%@)",NSLocalizedString(@"topscan_processing", @""),@(1),@(self.fileTotal)]];
                        }
                    }];
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    
                }];
            });
            
        }
            break;
        default:
            break;
    }
    
    
}

- (BOOL)isImageType:(NSString *)itemName {
    NSRange range = [itemName rangeOfString:@"\\.jpeg|\\.jpg|\\.JPEG|\\.JPG|\\.png|\\.PNG" options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}
- (BOOL)isPDFType:(NSString *)itemName {
    NSRange range = [itemName rangeOfString:@"\\.pdf|\\.PDF" options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}
#pragma mark- 查询下载的数据是否包含PDF文件
- (void)queryDownLoadFileContentPdfFileWith:(NSMutableArray *)downloadArrays
{
    NSMutableArray *tempPDFs = [NSMutableArray array];
    [downloadArrays enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([[obj lowercaseString] hasSuffix:@".pdf"]) {
            
            [tempPDFs addObject:obj];
        }else{
            [self.drivePaths addObject:obj];
        }
        
    }];
    if (tempPDFs.count) {
        [self breakupPdfwithtempPDFs:tempPDFs];
        if (self.currentDownloadFileType== TOPDownloadFileToDriveAddPathTypeHome ||self.currentDownloadFileType == TOPDownloadFileToDriveAddPathTypeNextFolder) {
            [self createNewDocmentSaveJPG];
        }
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self createNewDocmentSaveJPG];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_downloadsuccessfilly", @"")];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"downDrives" object:nil userInfo:nil];
            });
        });
        
    }
}

- (void)createNewDocmentSaveJPG
{
    
    switch (self.currentDownloadFileType) {
        case TOPDownloadFileToDriveAddPathTypeHome:
        {
            
            
            NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:self.downloadFilePath];
            [TOPDocumentHelper top_moveFileItemsAtPath:[TOPDocumentHelper top_getDriveDownloadJPGPathPathString] toNewFileAtPath:endPath];
            [TOPDBDataHandler top_addNewDocModel:endPath];
            
        }
            break;
        case TOPDownloadFileToDriveAddPathTypeNextFolder:
        {
            NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:self.downloadFilePath];
            [TOPDocumentHelper top_moveFileItemsAtPath:[TOPDocumentHelper top_getDriveDownloadJPGPathPathString] toNewFileAtPath:endPath];
            [TOPEditDBDataHandler  top_addDocumentAtFolder:endPath WithParentId:self.currentDocId];
        }
            break;
        case TOPDownloadFileToDriveAddPathTypeHomeChild:
        {
            [TOPDocumentHelper top_moveFileItemsAtPath:[TOPDocumentHelper top_getDriveDownloadJPGPathPathString] toNewFileAtPath:self.downloadFilePath];
            
            [TOPEditDBDataHandler top_addImageFileAtDocument:self.drivePaths WithId:self.currentDocId];
            
        }
            break;
        default:
            break;
    }
}

- (void)breakPDFAndCreatDocToDownloadFilePathWithpdfPath:(NSString *)pdfSavepath
{
    switch (self.currentDownloadFileType) {
        case TOPDownloadFileToDriveAddPathTypeHome:
        {
            [TOPDBDataHandler top_addNewDocModel:pdfSavepath];
            
        }
            break;
        case TOPDownloadFileToDriveAddPathTypeNextFolder:
        {
            [TOPEditDBDataHandler  top_addDocumentAtFolder:pdfSavepath WithParentId:self.currentDocId];
        }
            break;
        case TOPDownloadFileToDriveAddPathTypeHomeChild:
        {
            NSArray *imageNames = [TOPDocumentHelper top_sortPicsAtPath:pdfSavepath];
            [TOPDocumentHelper top_moveFileItemsAtPath:[TOPDocumentHelper top_getDriveDownloadJPGPathPathString] toNewFileAtPath:self.downloadFilePath];
            
            [TOPEditDBDataHandler top_addImageFileAtDocument:imageNames WithId:self.currentDocId];
        }
            break;
        default:
            break;
    }
    
}

@end
