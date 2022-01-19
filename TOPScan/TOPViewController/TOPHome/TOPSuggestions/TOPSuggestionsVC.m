#import "TOPSuggestionsVC.h"
#import "TOPQuestionTypeCell.h"
#import "TOPQuestionDescribeCell.h"
#import "TOPQuestionImgCell.h"
#import "TOPSuggestionModel.h"
#import "TOPSuggestionTypeView.h"
#import "TOPShowScreenshotVC.h"

@interface TOPSuggestionsVC ()<UITableViewDelegate,UITableViewDataSource,TZImagePickerControllerDelegate>
@property (nonatomic ,strong)UITableView * suggestionTabView;
@property (nonatomic ,strong)TOPSuggestionModel * suggestionModel;
@property (nonatomic ,strong)UITextView * titleTV;
@property (nonatomic ,strong)UIButton * returnBtn;
@property (nonatomic ,strong)UIView * coverView;
@property (nonatomic ,strong)TOPSuggestionTypeView * typeView;
@property (nonatomic ,assign)BOOL reloadType;
@property (nonatomic ,strong)UIButton * submitBtn;
@end

@implementation TOPSuggestionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reloadType = NO;
    [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
    [TOPWHCFileManager top_createDirectoryAtPath:TOPCamerPic_Path];
    [self top_setupUI];
    [self top_loadData];
    [self top_setSubmitBtnState];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)top_loadData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self top_dealPicArray];
        TOPSuggestionModel * model = [TOPSuggestionModel new];
        model.suggestionType = NSLocalizedString(@"topscan_questiontypecrash", @"");
        model.suggestionDetail = [TOPScanerShare top_saveUserSuggestion];
        model.userEmail = @"";
        model.selectState = NO;
        model.picArray = [[TOPDocumentHelper top_sortItemAthPath:TOPCamerPic_Path] mutableCopy];
        self.suggestionModel = model;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.suggestionTabView reloadData];
        });
    });
}
#pragma mark -- 将传递的图片做保存到本地处理
- (void)top_dealPicArray{
    for (int i = 0; i<self.picArray.count; i++) {
        UIImage * picImg = self.picArray[i];
        if (picImg) {
            NSData * data = UIImageJPEGRepresentation(picImg, TOP_TRPicScale);
            [self top_savePicData:data index:i];
        }
    }
}
#pragma mark -- 键盘弹出，文本框移动到键盘上方
- (void)keyboardwill:(NSNotification *)notification{
    //获取通知中的信息，其它信息贴在下面
    NSDictionary * info = [notification userInfo];
    NSLog(@"%@", info);
    //获取键盘尺寸
    CGFloat keyOriginY = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    if (!_returnBtn) {
        UIButton * returnBtn = [[UIButton alloc]init];
        returnBtn.backgroundColor = RGBA(212, 216, 222, 1.0);
        [returnBtn setImage:[UIImage imageNamed:@"top_downKeyboard"] forState:UIControlStateNormal];
        [returnBtn addTarget:self action:@selector(top_clickReturnToHide) forControlEvents:UIControlEventTouchUpInside];
        returnBtn.layer.masksToBounds = YES;
        returnBtn.layer.cornerRadius = 3;
        self.returnBtn = returnBtn;
        [self.view addSubview:self.returnBtn];
    }
    self.returnBtn.frame = CGRectMake(TOPScreenWidth-55, keyOriginY-48-TOPNavBarAndStatusBarHeight, 53, 47);
    self.returnBtn.hidden = NO;
}
#pragma mark --键盘隐藏,文本框回到原来位置
- (void)keybaordhide:(NSNotification *)info{
    [UIView animateWithDuration:0.3 animations:^{
        self.returnBtn.hidden = YES;
    }];
}
- (void)top_clickReturnToHide{
    [self.titleTV resignFirstResponder];
}
#pragma mark -- 返回
- (void)top_backAction{
    [self.titleTV resignFirstResponder];
    [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
    [TOPScanerShare top_writeUserSuggestion:self.suggestionModel.suggestionDetail];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)top_setSubmitBtnState{
    if (self.suggestionModel.suggestionDetail.length == 0) {
        self.submitBtn.enabled = NO;
        [self.submitBtn setBackgroundColor:RGBA(36, 196, 164, 0.4)];
    }else{
        self.submitBtn.enabled = YES;;
        [self.submitBtn setBackgroundColor:TOPAPPGreenColor];
    }
}
#pragma mark -- 提交
- (void)top_submitAction{
    if (self.suggestionModel.userEmail.length>0&&![TOPDocumentHelper top_validateEmail:self.suggestionModel.userEmail]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_questioninvalidemail", @"")];
        [SVProgressHUD dismissWithDelay:1.5];
        return;
    }
    [FIRAnalytics logEventWithName:@"submitSuggestion" parameters:nil];
    NSMutableArray * imgArray = [NSMutableArray new];
    for (NSString * picName in self.suggestionModel.picArray) {
        UIImage * image = [UIImage imageWithContentsOfFile:[TOPCamerPic_Path stringByAppendingPathComponent:picName]];
        NSData * imgData = UIImageJPEGRepresentation(image, 0.5);
        NSString * encodeString = [imgData base64EncodedStringWithOptions:0];
        [imgArray addObject:encodeString];
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:imgArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary * dic = [NSMutableDictionary new];
    [dic setValue:[TOPUUID top_getUUID] forKey:@"deviceId"];
    [dic setValue:@"userId" forKey:@"userId"];
    [dic setValue:self.suggestionModel.userEmail forKey:@"email"];
    [dic setValue:self.suggestionModel.suggestionType forKey:@"type"];
    [dic setValue:self.suggestionModel.suggestionDetail forKey:@"detail"];
    [dic setValue:@(5) forKey:@"appType"];
    [dic setValue:strJson forKey:@"files"];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_loading", @"")];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [[TOPScannerHttpRequest shareManager]top_PostNetDataWith:TOP_TRUserFeedBack withDic:dic andSuccess:^(NSDictionary * _Nonnull responseObject) {
        [SVProgressHUD dismiss];
        NSString * statusString = [NSString stringWithFormat:@"%@",responseObject[@"status"]];
        if ([statusString isEqualToString:@"1"]) {
            [self top_submitSuccess];
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_submittedsuccessfully", @"") duration:1];
        }
    } andFailure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}
#pragma mark -- 提交成功后的事件
- (void)top_submitSuccess{
    [TOPWHCFileManager top_removeItemAtPath:TOPCamerPic_Path];
    [TOPScanerShare top_writeUserSuggestion:@""];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    if (indexPath.section == 0) {
        TOPQuestionTypeCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPQuestionTypeCell class])];
        cell.titleLab.text = self.suggestionModel.suggestionType;
        cell.selectState = self.suggestionModel.selectState;
        return cell;
    }else{
        if (indexPath.row == 0 || indexPath.row == 1) {
            TOPQuestionDescribeCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPQuestionDescribeCell class])];
            cell.row = indexPath.row;
            if (indexPath.row == 0) {
                cell.textContent = self.suggestionModel.suggestionDetail;
                cell.placerString = [NSLocalizedString(@"topscan_suggestioncontenttitle", @"") stringByAppendingString:@" :"];
            }else{
                cell.textContent = self.suggestionModel.userEmail;
                cell.placerString = [NSLocalizedString(@"topscan_email", @"") stringByAppendingString:@" :"];
            }
            cell.top_startEdit = ^(UITextView * _Nonnull myTV) {
                weakSelf.titleTV = myTV;
            };
            cell.top_sendEditcontent = ^(NSString * _Nonnull contentString, NSInteger row) {
                if (row == 0) {
                    weakSelf.suggestionModel.suggestionDetail = contentString;
                }else{
                    weakSelf.suggestionModel.userEmail = contentString;
                }
                [weakSelf top_setSubmitBtnState];
            };
            return cell;
        }else{
            TOPQuestionImgCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPQuestionImgCell class])];
            cell.reloadType = self.reloadType;
            cell.imagesArray = [self.suggestionModel.picArray mutableCopy];
            cell.top_addScreenshotImg = ^{//添加图片
                [weakSelf top_addPicture];
            };
            cell.top_deleteCurrentPic = ^(NSString * _Nonnull picName) {
                [weakSelf top_deleteSelectPic:picName];
            };
            cell.top_showScreenshotImg = ^(NSInteger currentIndex) {//展示图片
                [weakSelf top_pushImgShowVC:currentIndex];
            };  
            return cell;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 40)];
    headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, TOPScreenWidth-15, 20)];
    titleLab.textColor = RGBA(102, 102, 102, 1.0);
    titleLab.font = [UIFont systemFontOfSize:14];
    titleLab.textAlignment = NSTextAlignmentNatural;
    if (section == 0) {
        titleLab.text = NSLocalizedString(@"topscan_questiontype", @"");
    }else{
        titleLab.text = NSLocalizedString(@"topscan_questiondescrible", @"");
    }
    [headerView addSubview:titleLab];
    [titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(headerView).offset(15);
        make.top.equalTo(headerView).offset(10);
        make.height.mas_equalTo(20);
    }];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 50)];
    footerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, TOPScreenWidth-30, 50)];
    titleLab.numberOfLines = 0;
    titleLab.textColor = RGBA(102, 102, 102, 1.0);
    titleLab.font = [UIFont systemFontOfSize:12];
    titleLab.textAlignment = NSTextAlignmentCenter;
    if (section == 1) {
        if (TOPBottomSafeHeight) {
            titleLab.text = NSLocalizedString(@"topscan_suggestionremindx", @"");
        }else{
            titleLab.text = NSLocalizedString(@"topscan_suggestionremind", @"");
        }
    }
    [footerView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(footerView).offset(15);
        make.trailing.equalTo(footerView).offset(-15);
        make.top.bottom.equalTo(footerView);
    }];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 45;
    }else{
        if (indexPath.row == 0) {
            return 170;
        }else if(indexPath.row == 1){
            return 50;
        }else{
            if (IS_IPAD) {
                return 260;
            }
            return 160;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 0.01;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.titleTV resignFirstResponder];
            [self top_showTOPSuggestionTypeView];
            self.suggestionModel.selectState = YES;
            [self.suggestionTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark -- TOPSuggestionTypeView
- (void)top_showTOPSuggestionTypeView{
    WS(weakSelf);
    TOPSuggestionTypeView * typeView = [[TOPSuggestionTypeView alloc]init];
    typeView.top_sendSuggestionType = ^(NSString * _Nonnull suggestionType) {
        weakSelf.suggestionModel.selectState = NO;
        weakSelf.suggestionModel.suggestionType = suggestionType;
        [weakSelf top_hideTOPSuggestionTypeView];
    };
    typeView.backgroundColor = [UIColor blackColor];
    typeView.frame = CGRectMake(25, 40+45, TOPScreenWidth-50, 1);
    typeView.typeArray = [[self suggestionTypeArray] mutableCopy];
    self.typeView = typeView;
    [self.view addSubview:self.coverView];
    [self.view addSubview:typeView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [UIView animateWithDuration:0.4 animations:^{
        typeView.frame = CGRectMake(25, 40+45, TOPScreenWidth-50, 50*6-20);
        typeView.myTableView.frame = CGRectMake(0, 0, TOPScreenWidth-50, 50*6-20);
    }];
    [typeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(25);
        make.trailing.equalTo(self.view).offset(-25);
        make.top.equalTo(self.view).offset(40+45);
        make.height.mas_equalTo(50*6-20);
    }];
}
#pragma mark -- 隐藏TOPSuggestionTypeView
- (void)top_hideTOPSuggestionTypeView{
    [self.suggestionTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.coverView removeFromSuperview];
    [self.typeView removeFromSuperview];
    self.coverView = nil;
    self.typeView = nil;
}
#pragma mark -- 手势点击事件
- (void)top_clickTip{
    self.suggestionModel.selectState = NO;
    [self top_hideTOPSuggestionTypeView];
}
#pragma mark -- 跳转到展示页
- (void)top_pushImgShowVC:(NSInteger)currentIndex{
    WS(weakSelf);
    TOPShowScreenshotVC * showPicVC = [TOPShowScreenshotVC new];
    showPicVC.currentIndex = currentIndex;
    showPicVC.top_showBackBlock = ^{
        weakSelf.reloadType = NO;
        weakSelf.suggestionModel.picArray = [[TOPDocumentHelper top_sortPicArryBuyName:TOPCamerPic_Path] mutableCopy];
        [weakSelf.suggestionTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    };
    showPicVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:showPicVC animated:YES];
}
#pragma mark -- 删除选择的图片
- (void)top_deleteSelectPic:(NSString *)picName{
    NSArray * array = [TOPDocumentHelper top_sortPicArryBuyName:TOPCamerPic_Path];
    for (NSString * tempString in array) {
        if ([tempString isEqualToString:picName]){
            NSString * imgPath = [TOPCamerPic_Path stringByAppendingPathComponent:picName];
            if ([TOPWHCFileManager top_isExistsAtPath:imgPath]) {
                [TOPWHCFileManager top_removeItemAtPath:imgPath];
            }
        }
    }
    self.reloadType = NO;
    self.suggestionModel.picArray = [[TOPDocumentHelper top_sortPicArryBuyName:TOPCamerPic_Path] mutableCopy];
    [self.suggestionTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)top_addPicture{
    if (self.suggestionModel.picArray.count<9) {
        NSInteger maxImagesCount = 9 - self.suggestionModel.picArray.count;
        //到相册选取图片
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:self pushPhotoPickerVc:YES];
        imagePickerVc.isSelectOriginalPhoto = YES;
        imagePickerVc.allowTakePicture = NO;
        imagePickerVc.allowTakeVideo = NO;
        imagePickerVc.allowPickingVideo = NO;
        imagePickerVc.allowPickingImage = YES;
        imagePickerVc.allowPickingOriginalPhoto = NO;
        imagePickerVc.allowPickingGif = NO;
        imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
        // 4. 照片排列按修改时间升序
        imagePickerVc.sortAscendingByModificationDate = YES;
        imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }
}
- (void)top_saveAssetsRefreshUI:(NSArray *)assets imagePickerController:(TZImagePickerController *)picker{
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [self top_handleLibiaryPhoto:assets completion:^(NSArray *imagePaths) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            weakSelf.reloadType = YES;
            weakSelf.suggestionModel.picArray = [imagePaths mutableCopy];
            [picker dismissViewControllerAnimated:YES completion:nil];
            [weakSelf.suggestionTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        });
    }];
}

#pragma mark -TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    [self top_saveAssetsRefreshUI:assets imagePickerController:picker];
}

#pragma mark -- 处理相册图片 -- 大图压缩控制在1200w像素内，保存，返回图片路径
- (void)top_handleLibiaryPhoto:(NSArray *)assets completion:(void (^)(NSArray *imagePaths))completion {
    WS(weakSelf);
    dispatch_queue_t queueE = dispatch_queue_create("group.queue", DISPATCH_QUEUE_CONCURRENT);//并发队列
    dispatch_group_t groupE = dispatch_group_create();
    dispatch_queue_t serialQue= dispatch_queue_create("serial.queue",DISPATCH_QUEUE_SERIAL);//串行队列
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);//控制最大并发数为3
    for (int i = 0; i < assets.count; i ++) {
        dispatch_async(serialQue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_group_async(groupE, queueE, ^{
                dispatch_group_enter(groupE);
                [[TZImageManager manager] getOriginalPhotoDataWithAsset:assets[i] completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        if ([info[@"PHImageResultIsDegradedKey"] boolValue] == NO) {
                            CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
                            if (freeSize<50) {
                                CGFloat imgSize;
                                if ([TOPScanerShare top_saveOriginalImage] == TOPSettingSaveNO) {
                                    imgSize = data.length/1024/1024+4;//不保存原图 4m是预留空间
                                }else{
                                    imgSize = (data.length/1024/1024)*2+4;//保存原图时是图片空间的2倍
                                }
                                if (freeSize<imgSize) {//手机剩余空间不足
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
                                    });
                                }else{
                                    [weakSelf top_savePicData:data index:i];
                                }
                            }else{
                                [weakSelf top_savePicData:data index:i];
                            }
                        }
                        dispatch_semaphore_signal(semaphore);
                        dispatch_group_leave(groupE);
                    });
                }];
            });
            if (i == assets.count - 1) {
                dispatch_group_notify(groupE, dispatch_get_main_queue(), ^{
                    NSArray * array = [TOPDocumentHelper top_sortPicArryBuyName:TOPCamerPic_Path];
                    if (array.count) {
                        if (completion) completion(array);
                    } else {
                        NSArray * items = [TOPDocumentHelper top_sortItemAthPath:TOPCamerPic_Path];
                        if (items.count) {
                            if (completion) completion(items);
                        } else {
                            [SVProgressHUD dismissWithDelay:1];
                        }
                    }
                });
            }
        });
    }
}
#pragma mark -- 保存相册图片数据到本地
- (void)top_savePicData:(NSData *)data index:(NSInteger)i{
    UIImage * getPicImg = [TOPPictureProcessTool top_fetchOriginalImageWithData:data withSize:3000000.0];
    NSData * imgData = UIImageJPEGRepresentation(getPicImg, 0.2);

    NSString *fileName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:i],TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [TOPCamerPic_Path stringByAppendingPathComponent:fileName];

    //写入显示的图片
    BOOL result = [imgData writeToFile:fileEndPath atomically:YES];
    if (!result) {//路径错误，重新保存
        if (fileEndPath == nil) {
            fileEndPath = @"";
        }
        [FIRAnalytics logEventWithName:@"HomeView_pathError" parameters:@{@"path": fileEndPath}];
        [FIRAnalytics logEventWithName:@"HomeView_contentError" parameters:@{@"content": @(imgData.length)}];
    }
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -- UI
- (void)top_setupUI{
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    if (isRTL()) {//黑色
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backAction)];
    }
    self.title = NSLocalizedString(@"topscan_settingusersuggestion", @"");
    UIButton * submitBtn = [[UIButton alloc]initWithFrame:CGRectMake(30, TOPScreenHeight-TOPNavBarAndStatusBarHeight-40-TOPBottomSafeHeight-15, TOPScreenWidth-30*2, 40)];
    submitBtn.backgroundColor = TOPAPPGreenColor;
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [submitBtn setTitle:NSLocalizedString(@"topscan_suggestionsubmit", @"") forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitBtn.layer.masksToBounds = YES;
    submitBtn.layer.cornerRadius = 10;
    [submitBtn addTarget:self action:@selector(top_submitAction) forControlEvents:UIControlEventTouchUpInside];
    self.submitBtn = submitBtn;
    [self.view addSubview:submitBtn];
    [self.view addSubview:self.suggestionTabView];
    
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(30);
        make.trailing.equalTo(self.view).offset(-30);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+15));
        make.height.mas_equalTo(40);
    }];
    [self.suggestionTabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(submitBtn.mas_top);
    }];
}
- (UITableView *)suggestionTabView{
    if (!_suggestionTabView) {
        _suggestionTabView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight) style:UITableViewStyleGrouped];
        _suggestionTabView.delegate = self;
        _suggestionTabView.dataSource = self;
        _suggestionTabView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _suggestionTabView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _suggestionTabView.showsVerticalScrollIndicator = NO;
        [_suggestionTabView registerClass:[TOPQuestionTypeCell class] forCellReuseIdentifier:NSStringFromClass([TOPQuestionTypeCell class])];
        [_suggestionTabView registerClass:[TOPQuestionDescribeCell class] forCellReuseIdentifier:NSStringFromClass([TOPQuestionDescribeCell class])];
        [_suggestionTabView registerClass:[TOPQuestionImgCell class] forCellReuseIdentifier:NSStringFromClass([TOPQuestionImgCell class])];

    }
    return _suggestionTabView;
}
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight)];
        _coverView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTip)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}
- (NSArray *)suggestionTypeArray{
    NSArray * array = @[NSLocalizedString(@"topscan_questiontypecrash", @""),NSLocalizedString(@"topscan_backup", @""),NSLocalizedString(@"topscan_questiontypetaking", @""),NSLocalizedString(@"topscan_questiontypephoto", @""),NSLocalizedString(@"topscan_questiontypeocr", @""),NSLocalizedString(@"topscan_fax", @""),NSLocalizedString(@"topscan_questiontypeshare", @""),NSLocalizedString(@"topscan_questiontypeinterface", @""),NSLocalizedString(@"topscan_questiontypefeatures", @""),NSLocalizedString(@"topscan_questiontypeother", @"")];
    return array;
}

@end
