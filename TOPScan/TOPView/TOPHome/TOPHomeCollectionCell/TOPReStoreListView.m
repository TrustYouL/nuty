#import "TOPReStoreListView.h"
#import "TOPReStoreItemTableViewCell.h"
#import "DriveDownloadManger.h"
#import "TOPDownProgressAlertView.h"

@interface TOPReStoreListView ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)  UIView *alertView;
@property (strong, nonatomic)  UITableView *tableView;
@property (strong, nonatomic)  TOPDownProgressAlertView *downProgressView;
@end
@implementation TOPReStoreListView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight);
    self.backgroundColor = [UIColor clearColor];
    self.alertView.alpha = 0.0;
    
    self.alertView.layer.cornerRadius = 2;
    self.alertView.clipsToBounds = YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight);
        self.backgroundColor = [UIColor clearColor];
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor= [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.alertView.alpha = 0.0;
        self.alertView.clipsToBounds = YES;
        self.alertView.layer.cornerRadius = 2;
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = NSLocalizedString(@"topscan_restoretitle", @"");
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, TOPScreenWidth-30, 50) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[TOPReStoreItemTableViewCell class] forCellReuseIdentifier:@"ReStoreItemCe1ll"];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [cancelButton setTitle:[NSLocalizedString(@"topscan_cancel", @"") uppercaseString] forState:UIControlStateNormal];
        
        [cancelButton setTitleColor: UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
       
        [self addSubview:_alertView];
        [_alertView addSubview:titleLabel];
        [_alertView addSubview:_tableView];
        [_alertView addSubview:cancelButton];
        
        [_alertView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(15);
            make.trailing.equalTo(self).offset(-15);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(260);
        }];
        [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_alertView).offset(15);
            make.trailing.equalTo(_alertView).offset(-20);
            make.top.equalTo(_alertView).offset(15);
            make.height.mas_equalTo(25);
        }];
        [cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_alertView).offset(-5);
            make.trailing.equalTo(_alertView).offset(-20);
            make.size.mas_equalTo(CGSizeMake(70, 35));
        }];
        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_alertView).offset(10);
            make.trailing.equalTo(_alertView).offset(-10);
            make.top.equalTo(_alertView).offset(40);
            make.bottom.equalTo(cancelButton.mas_top);
        }];
    }
    return self;
}

- (void)top_refreshUI:(NSMutableArray *)dataArray{
    CGFloat alertViewH = 0.0;
    if (dataArray.count>5) {
        alertViewH = 5*60+90;
    }else{
        alertViewH = dataArray.count*60+90;
    }
    [_alertView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.trailing.equalTo(self).offset(-15);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(alertViewH);
    }];
    [self.tableView reloadData];
}
-(void)top_showXib
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.alertView.transform = CGAffineTransformScale(self.alertView.transform,1.1,1.1);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundColor = RGBA(0, 0, 0, 0.4);
        self.alertView.transform = CGAffineTransformIdentity;
        self.alertView.alpha = 1.0;
    } completion:nil];
}
-(void)top_showXib:(UIView *)supView
{
    [supView addSubview:self];
    self.frame = supView.frame;
    self.alertView.transform = CGAffineTransformScale(self.alertView.transform,1.1,1.1);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundColor =  [UIColorFromRGB(0x333333) colorWithAlphaComponent:0.5];
        self.alertView.transform = CGAffineTransformIdentity;
        self.alertView.alpha = 1.0;
    } completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
}

-(void)top_closeXib
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0.0;
        self.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.0];
        self.alertView.transform = CGAffineTransformScale(self.alertView.transform,0.9,0.9);
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

+(instancetype)top_creatXIB{
    return  [[TOPReStoreListView alloc] init];
}

- (void)buttonClick:(UIButton *)sender {
    [self top_closeXib];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.showStyle) {
        case TOPDownLoadDataStyleDefaultGoogle:
            return self.driveGoogleDataArrays.count;
            break;
        case TOPDownLoadDataStyleStyleDropBox:
            return self.dropBoxDataArrays.count;
            break;
        case TOPDownLoadDataStyleStyleBox:
            return self.boxDataArrays.count;
            break;
        case TOPDownLoadDataStyleStyleOneDrice:
            return self.oneDriveDataArrays.count;
            break;
        default:
            break;
    }
    return self.driveGoogleDataArrays.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TOPReStoreItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReStoreItemCe1ll" forIndexPath:indexPath];
    switch (self.showStyle) {
        case TOPDownLoadDataStyleDefaultGoogle:
        {
            cell.driveFile = self.driveGoogleDataArrays[indexPath.row];
            cell.top_didItemClick = ^(RestoreClickStyle clickStyle, GTLRDrive_File * _Nonnull driveFile) {
                [UIApplication sharedApplication].idleTimerDisabled = YES;
                [self restoreMothodWithType:clickStyle withItem:driveFile];
            };
        }
            break;
        case TOPDownLoadDataStyleStyleDropBox:
        {
            cell.dropBoxFile = self.dropBoxDataArrays[indexPath.row];
            cell.top_didDropBoxItemClick = ^(RestoreClickStyle clickStyle, DBFILESMetadata * _Nonnull dropBoxFile) {
                [UIApplication sharedApplication].idleTimerDisabled = YES;
                [self restoreDropBoxMothodWithType:clickStyle withItem:dropBoxFile];
            };
        }
            break;
            
        case TOPDownLoadDataStyleStyleBox:
        {
            cell.boxDriveFile = self.boxDataArrays[indexPath.row];
            cell.top_didBoxDriveItemClick = ^(RestoreClickStyle clickStyle, BOXItem * _Nonnull boxItemFile) {
                [UIApplication sharedApplication].idleTimerDisabled = YES;
                [self restoreBoxMothodWithType:clickStyle withItem:boxItemFile];
            };
        }
            break;
        case TOPDownLoadDataStyleStyleOneDrice:
        {
            cell.oneDriveFile = self.oneDriveDataArrays[indexPath.row];
            cell.top_didOneBoxDriveItemClick = ^(RestoreClickStyle clickStyle, ODItem * _Nonnull odItemFile) {
                [UIApplication sharedApplication].idleTimerDisabled = YES;
                [self restoreOneDriveMothodWithType:clickStyle withItem:odItemFile];
            };
        }
            break;
        default:
            break;
    }
    return cell;
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
 文件合并
 */
- (void)installFloderAllFileWithPath:(NSString *)path  foldersPath:(NSString *)foldersPath {
    
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir=NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * oldFolderDirArray = [TOPDocumentHelper top_getCurrentFileAndPath:path];
            if (!oldFolderDirArray.count) {//没有子目录 则是Folder
            } else {
                BOOL hasDoc = NO;
                for (NSString *fileName in oldFolderDirArray) {
                    if ([fileName containsString:@".DS_Store"]) {
                        continue;
                    }
                    if ([TOPDocumentHelper top_isValidateJPG:fileName] || [fileName containsString:@".txt"] || [fileName containsString:@".TXT"]) {//判断是否为jpg 有图片 则是Doc
                        [self changeAndroidFileName:path];
                        
                        BOOL oldisExist = [fileManger fileExistsAtPath:foldersPath isDirectory:nil];
                        NSString *creatStr = @"";
                        if (oldisExist) {
                            creatStr = [NSString stringWithFormat:@"%@/%@",foldersPath.stringByDeletingLastPathComponent,[TOPDocumentHelper  top_newDocumentFileName:foldersPath]];
                        }else{
                            creatStr = [foldersPath stringByAppendingPathComponent:fileName];
                        }
                        [fileManger createDirectoryAtPath:creatStr withIntermediateDirectories:YES attributes:nil error:nil];
                        [TOPDocumentHelper top_moveFileItemsAtPath:path  toNewFileAtPath:creatStr];
                        [[TOPFileDataManager shareInstance].docPaths addObject:creatStr];
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
                            NSString *creatStr = [NSString stringWithFormat:@"%@",[foldersPath stringByAppendingPathComponent:fileName]];
                            [self changeAndroidFileName:path];
                            
                            [fileManger createDirectoryAtPath:creatStr withIntermediateDirectories:YES attributes:nil error:nil];
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
 文件合并
 */
- (void)changeFileNameWithPath:(NSString *)path  foldersPath:(NSString *)foldersPath {
    
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir=NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * oldFolderDirArray = [TOPDocumentHelper top_getCurrentFileAndPath:path];
            if (!oldFolderDirArray.count) {//没有子目录 则是Folder
            } else {
                BOOL hasDoc = NO;
                for (NSString *fileName in oldFolderDirArray) {
                    if ([fileName containsString:@".DS_Store"]) {
                        continue;
                    }
                    if ([TOPDocumentHelper top_isValidateJPG:fileName] || [fileName containsString:@".txt"] || [fileName containsString:@".TXT"]) {//判断是否为jpg 有图片 则是Doc
                        [self changeAndroidFileName:path];
                        
                        BOOL oldisExist = [fileManger fileExistsAtPath:foldersPath isDirectory:nil];
                        if (oldisExist) {
                            NSString *creatStr = [NSString stringWithFormat:@"%@/%@",foldersPath.stringByDeletingLastPathComponent,[TOPDocumentHelper  top_newDocumentFileName:foldersPath]];
                            [fileManger createDirectoryAtPath:creatStr withIntermediateDirectories:YES attributes:nil error:nil];
                            [self changeAndroidNameBBFileName:path];
                            
                            [TOPDocumentHelper top_moveFileItemsAtPath:path  toNewFileAtPath:creatStr];
                            
                        }else{
                            NSString *creatStr = [foldersPath stringByAppendingPathComponent:fileName];
                            [fileManger createDirectoryAtPath:creatStr withIntermediateDirectories:YES attributes:nil error:nil];
                            [self changeAndroidNameBBFileName:path];
                            
                            [TOPDocumentHelper top_moveFileItemsAtPath:path   toNewFileAtPath:creatStr];
                            
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
                            NSString *creatStr = [NSString stringWithFormat:@"%@",[foldersPath stringByAppendingPathComponent:fileName]];
                            [self changeAndroidNameBBFileName:path];
                            
                            [fileManger createDirectoryAtPath:creatStr withIntermediateDirectories:YES attributes:nil error:nil];
                            [TOPDocumentHelper top_moveFileItemsAtPath:[path stringByAppendingPathComponent:fileName]  toNewFileAtPath:creatStr];
                            
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
- (void)changeAndroidNameBBFileName:(NSString *)filePath
{
    NSFileManager * fileManger = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *dirEnumerator = [fileManger enumeratorAtPath:filePath];
    NSArray *tempAllObjects = dirEnumerator.allObjects;
    for (NSString* tempTags in tempAllObjects) {
        
        BOOL isDir=NO;
        BOOL isExist = [fileManger fileExistsAtPath:tempTags isDirectory:&isDir];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (void)setDriveGoogleDataArrays:(NSMutableArray<GTLRDrive_File *> *)driveGoogleDataArrays
{
    _driveGoogleDataArrays = driveGoogleDataArrays;
    [self top_refreshUI:driveGoogleDataArrays];
}

- (void)setOneDriveDataArrays:(NSMutableArray<ODItem *> *)oneDriveDataArrays
{
    _oneDriveDataArrays = oneDriveDataArrays;
    [self top_refreshUI:oneDriveDataArrays];
}
- (void)setDropBoxDataArrays:(NSMutableArray<DBFILESMetadata *> *)dropBoxDataArrays
{
    _dropBoxDataArrays = dropBoxDataArrays;
    [self top_refreshUI:dropBoxDataArrays];
}
- (void)setBoxDataArrays:(NSMutableArray<BOXItem *> *)boxDataArrays
{
    _boxDataArrays = boxDataArrays;
    [self top_refreshUI:boxDataArrays];
}

- (NSString *)top_tempUnzipPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:TOPTemporaryPathZip]){//如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        [fileManager createDirectoryAtPath:TOPTemporaryPathZip withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@",
                      TOPTemporaryPathZip,
                      [NSUUID UUID].UUIDString];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:url
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
    if (error) {
        return nil;
    }
    return url.path;
}

- (void)setShowStyle:(TOPDownLoadDataStyle)showStyle
{
    _showStyle = showStyle;
}

#pragma mark- OneDriveItem

- (void)restoreOneDriveMothodWithType:(RestoreClickStyle)clickStyle withItem:(ODItem *) driveFile
{
    switch (clickStyle) {
        case RestoreClickStyleDelete:
        {
            TOPSCAlertController *col = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"") message:NSLocalizedString(@"topscan_deletedrive", @"") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSLocalizedString(@"topscan_cancel", @"") uppercaseString] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.oneDriveDataArrays removeObject:driveFile];
                [SVProgressHUD  showSuccessWithStatus:NSLocalizedString(@"topscan_filedeleteprompt", @"")];
                [SVProgressHUD dismissWithDelay:1];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                
                if (self.oneDriveDataArrays.count<=0) {
                    [self top_closeXib];
                }else{
                    [self top_refreshUI:self.oneDriveDataArrays];
                }
                [self.tableView reloadData];
                
                [[DriveDownloadManger sharedSingleton] deleteOneDriveWithID:driveFile.id CompletionBlock:^(BOOL deleteStates) {
                }];
                
            }];
            [col addAction:confirmAction];
            [col addAction:cancelAction];
            [[TOPDocumentHelper top_topViewController] presentViewController:col animated:YES completion:nil];
            
        }
            break;
        case RestoreClickStyleRestore:
        {
            [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_filedownbackup", @"")];
            
            [[DriveDownloadManger sharedSingleton] downReZipWithOneDriveItem:driveFile CompletionBlock:^(NSString * _Nonnull zipFilePath) {
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
                
                [self.downProgressView top_closeXib];
                self.downProgressView = nil;
                [SVProgressHUD dismiss];
                [self installDownLoadDataDocoumentFile:zipFilePath];
                
            } progress:^(float progressValue) {
                
            }];
            [self top_closeXib];
        }
            break;
        default:
            break;
    }
}

#pragma  -mark DropBox
- (void)restoreDropBoxMothodWithType:(RestoreClickStyle)clickStyle withItem:(DBFILESMetadata *) driveFile
{
    switch (clickStyle) {
        case RestoreClickStyleDelete:
        {
            TOPSCAlertController *col = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"") message:NSLocalizedString(@"topscan_deletedrive", @"") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSLocalizedString(@"topscan_cancel", @"") uppercaseString] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            WeakSelf(ws);
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ws.dropBoxDataArrays removeObject:driveFile];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                
                [SVProgressHUD  showSuccessWithStatus:NSLocalizedString(@"topscan_filedeleteprompt", @"")];
                [SVProgressHUD dismissWithDelay:1];
                if (ws.dropBoxDataArrays.count<=0) {
                    [ws top_closeXib];
                }else{
                    [self top_refreshUI:ws.dropBoxDataArrays];
                }
                [ws.tableView reloadData];
                
                [[DriveDownloadManger sharedSingleton] deleteDropBoxItemWithPath:driveFile.pathDisplay CompletionBlock:^(BOOL deleteStates) {
                }];
                
            }];
            [col addAction:confirmAction];
            [col addAction:cancelAction];
            
            [[TOPDocumentHelper top_topViewController] presentViewController:col animated:YES completion:nil];
            
        }
            break;
        case RestoreClickStyleRestore:
        {
            float currentSpaceBytes = [TOPDocumentHelper top_freeDiskSpaceInBytes];
            DBFILESFileMetadata *fileMeta = (DBFILESFileMetadata *)driveFile;
            
            if ([fileMeta.size doubleValue]/(1024.0*1024.0)*2+100 >currentSpaceBytes ) {
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_thereisnotstoragespaceon", @"")];
                [SVProgressHUD dismissWithDelay:1];
                return;
            }
            [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_filedownbackup", @"")];
            [[DriveDownloadManger sharedSingleton] downRestoreDataZipWithDropBoxItem:driveFile CompletionBlock:^(NSString * _Nonnull zipFilePath) {
                [SVProgressHUD dismiss];
                [self installDownLoadDataDocoumentFile:zipFilePath];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
                
                [self.downProgressView top_closeXib];
                
            } progress:^(float progressValue) {
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
                    
                    self.downProgressView.titleName = [NSString stringWithFormat:@"%@ (%.f%%)",NSLocalizedString(@"topscan_filestartbackup", @""),progressValue*100];
                }else{
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDownOrUpdateInback"];
                }
            }];
            [self top_closeXib];
        }
            break;
        default:
            break;
    }
}
#pragma mark- BOXItem

- (void)restoreBoxMothodWithType:(RestoreClickStyle)clickStyle withItem:(BOXItem *) driveFile
{
    switch (clickStyle) {
        case RestoreClickStyleDelete:
        {
            TOPSCAlertController *col = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"") message:NSLocalizedString(@"topscan_deletedrive", @"") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSLocalizedString(@"topscan_cancel", @"") uppercaseString] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            WeakSelf(ws);
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ws.boxDataArrays removeObject:driveFile];
                [SVProgressHUD  showSuccessWithStatus:NSLocalizedString(@"topscan_filedeleteprompt", @"")];
                [SVProgressHUD dismissWithDelay:1];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                
                if (ws.boxDataArrays.count<=0) {
                    [ws top_closeXib];
                }else{
                    [self top_refreshUI:ws.boxDataArrays];
                }
                [ws.tableView reloadData];
                [[DriveDownloadManger sharedSingleton] deleteBoxItemWithID:driveFile.modelID CompletionBlock:^(BOOL deleteStates) {
                }];
                
            }];
            [col addAction:confirmAction];
            [col addAction:cancelAction];
            [[TOPDocumentHelper top_topViewController] presentViewController:col animated:YES completion:nil];
        }
            break;
        case RestoreClickStyleRestore:
        {
            float currentSpaceBytes = [TOPDocumentHelper top_freeDiskSpaceInBytes];
            if ([driveFile.size doubleValue]/(1024.0*1024.0)*2+100 >currentSpaceBytes ) {
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_thereisnotstoragespaceon", @"")];
                [SVProgressHUD dismissWithDelay:1];
                return;
            }
            [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_filedownbackup", @"")];
            
            [[DriveDownloadManger sharedSingleton] downRestoreZipWithBoxItem:driveFile CompletionBlock:^(NSString * _Nonnull zipFilePath) {
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
                
                [self.downProgressView top_closeXib];
                self.downProgressView = nil;
                [SVProgressHUD dismiss];
                [self installDownLoadDataDocoumentFile:zipFilePath];
            } progress:^(float progressValue) {
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
                    self.downProgressView.titleName = [NSString stringWithFormat:@"%@ (%.f%%)",NSLocalizedString(@"topscan_filestartbackup", @""),progressValue*100];
                }else{
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDownOrUpdateInback"];
                }
            }];
            [self top_closeXib];
        }
            break;
        default:
            break;
    }
}


#pragma  -mark Google
- (void)restoreMothodWithType:(RestoreClickStyle)clickStyle withItem:(GTLRDrive_File *) driveFile
{
    switch (clickStyle) {
        case RestoreClickStyleDelete:
        {
            TOPSCAlertController *col = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"") message:NSLocalizedString(@"topscan_deletedrive", @"") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSLocalizedString(@"topscan_cancel", @"") uppercaseString] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            WeakSelf(ws);
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ws.driveGoogleDataArrays removeObject:driveFile];
                [SVProgressHUD  showSuccessWithStatus:NSLocalizedString(@"topscan_filedeleteprompt", @"")];
                [SVProgressHUD dismissWithDelay:1];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                
                if (ws.driveGoogleDataArrays.count<=0) {
                    [ws top_closeXib];
                }else{
                    [self top_refreshUI:ws.driveGoogleDataArrays];
                }
                [ws.tableView reloadData];
                
                [[DriveDownloadManger sharedSingleton] deleteGoogleItemWithIdentifier:driveFile.identifier CompletionBlock:^(BOOL deleteStates, NSError * _Nonnull error) {
                    
                }];
            }];
            [col addAction:confirmAction];
            [col addAction:cancelAction];
            [[TOPDocumentHelper top_topViewController] presentViewController:col animated:YES completion:nil];
        }
            break;
        case RestoreClickStyleRestore:
        {
            float currentSpaceBytes = [TOPDocumentHelper top_freeDiskSpaceInBytes];
            
            if ([driveFile.size doubleValue]/(1024.0*1024.0)*2+100 >currentSpaceBytes ) {
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_thereisnotstoragespaceon", @"")];
                [SVProgressHUD dismissWithDelay:1];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                return;
            }
            [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_filedownbackup", @"")];
            [[DriveDownloadManger sharedSingleton] downRestoreDataZipWithItem:driveFile CompletionBlock:^(NSString * _Nonnull zipFilePath, NSError * _Nonnull error) {
                [SVProgressHUD dismiss];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDownOrUpdateInback"];
                
                [self installDownLoadDataDocoumentFile:zipFilePath];
                [self top_closeXib];
                [self.downProgressView top_closeXib];
                self.downProgressView = nil;
            } progress:^(float progressValue) {
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
                    
                    self.downProgressView.titleName = [NSString stringWithFormat:@"%@ (%.f%%)",NSLocalizedString(@"topscan_filestartbackup", @""),progressValue*100];
                }
            }];
            [self top_closeXib];
        }
            break;
        default:
            break;
    }
}

- (void)installDownLoadDataDocoumentFile:(NSString *)zipFilePath
{
    BOOL isClearFile = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RestoreMerge"] boolValue];
    if (isClearFile == YES) {
        TOPSCAlertController *col = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"") message:NSLocalizedString(@"topscan_deletedrive", @"") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSLocalizedString(@"topscan_cancel", @"") uppercaseString] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
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
            [self unlockServerZipFile:zipFilePath];
        }];
        [col addAction:cancelAction];
        [col addAction:confirmAction];
        [[TOPDocumentHelper top_topViewController] presentViewController:col animated:YES completion:nil];
    }else{
        [self unlockServerZipFile:zipFilePath];
    }
}

- (void)unlockServerZipFile:(NSString *)zipFilePath
{
    BOOL isClearFile = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RestoreMerge"] boolValue];
    
    NSString *unzipPath = [self top_tempUnzipPath];
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
                [SVProgressHUD showProgress:(float)entryNumber/total status:[NSString stringWithFormat:@"%@ %.f%%",NSLocalizedString(@"topscan_restoreprocessfiles", @""),(float)entryNumber/total*100]];
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
                        NSString *oldDocPath = [objectTempStr stringByAppendingPathComponent:@"Documents"];
                        
                        BOOL isExist = [fileManger fileExistsAtPath:tempCreatPath isDirectory:nil];
                        
                        if (!isExist) {
                            [TOPDocumentHelper top_createDirectoryAtPath:tempCreatPath];
                        }
                        if (isClearFile == YES) {
                            [self changeAndroidNameBBFileName:oldDocPath];
                            
                            [TOPDocumentHelper top_moveFileItemsAtPath:oldDocPath toNewFileAtPath:[TOPDocumentHelper top_getDocumentsPathString]];
                        }else{
                            NSMutableArray  *oldDocumentArrays=  [TOPDocumentHelper top_getCurrentFileAndPath:[TOPDocumentHelper top_getDocumentsPathString]];
                            NSMutableArray  *newDocumentArrays=  [TOPDocumentHelper top_getCurrentFileAndPath:oldDocPath];
                            
                            for (int i= 0; i < newDocumentArrays.count; i ++) {
                                NSString *newPath = newDocumentArrays[i];
                                if ([oldDocumentArrays containsObject:newPath]) {
                                    [self changeAndroidFileName:[oldDocPath stringByAppendingPathComponent:newPath]];
                                    
                                    NSString *creatNewPath = [NSString stringWithFormat:@"%@/%@",[TOPDocumentHelper top_getDocumentsPathString],[TOPDocumentHelper  top_newDocumentFileName:[[TOPDocumentHelper top_getDocumentsPathString] stringByAppendingPathComponent:newPath]]];
                                    
                                    NSString *tempCreatPath = [TOPDocumentHelper top_createDirectoryAtPath:creatNewPath];
                                    
                                    [TOPDocumentHelper top_moveFileItemsAtPath:[oldDocPath stringByAppendingPathComponent:newPath] toNewFileAtPath:tempCreatPath];
                                    [docData addObject:tempCreatPath];
                                    
                                }else{
                                    [self changeAndroidFileName:[oldDocPath stringByAppendingPathComponent:newPath]];
                                    
                                    NSString *creatNewPath = [NSString stringWithFormat:@"%@/%@",[TOPDocumentHelper top_getDocumentsPathString],newPath];
                                    NSString *tempCreatPath = [TOPDocumentHelper top_createDirectoryAtPath:creatNewPath];
                                    [TOPDocumentHelper top_moveFileItemsAtPath:[oldDocPath stringByAppendingPathComponent:newPath] toNewFileAtPath:tempCreatPath];
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
                        NSString *oldFoldersPath = [objectTempStr stringByAppendingPathComponent:@"Folders"];
                        if (isClearFile == YES) {
                            [self changeAndroidNameBBFileName:oldFoldersPath];
                            [TOPDocumentHelper top_moveFileItemsAtPath:oldFoldersPath toNewFileAtPath:tempCreatPath];
                        }else{
                            [self installFloderAllFileWithPath:oldFoldersPath foldersPath:[TOPDocumentHelper top_getFoldersPathString]];
                        }
                    }else if([filePath isEqualToString:@"SignPng"]){
                        
                        NSString *tempCreatPath = [TOPDocumentHelper top_getBelongDocumentPathString:@"SignPng"];
                        BOOL isExist = [fileManger fileExistsAtPath:tempCreatPath isDirectory:nil];
                        
                        if (isExist) {
                            [TOPDocumentHelper top_moveFileItemsAtPath:[objectTempStr stringByAppendingString:@"/SignPng"] toNewFileAtPath:tempCreatPath];
                        }else{
                            [TOPDocumentHelper top_createDirectoryAtPath:tempCreatPath];
                            [TOPDocumentHelper top_moveFileItemsAtPath:[objectTempStr stringByAppendingString:@"/SignPng"] toNewFileAtPath:tempCreatPath];
                        }
                    }else if([filePath containsString:@"Tags"]){
                        NSString *tempCreatPath =  [TOPDocumentHelper top_getBelongDocumentPathString:@"Tags"];
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
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_filerestoresuccessed", @"")];
                [SVProgressHUD dismissWithDelay:1];
                
                [TOPWHCFileManager top_removeItemAtPath:TOPTemporaryPathUnZip];
                [TOPWHCFileManager top_removeItemAtPath:TOPTemporaryPathZip];
            });
        }];
    });
}

@end
