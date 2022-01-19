#define AddFolder_W 310
#define AddFolder_H 240
#define AddFolderSingle_H 190

#import "TOPHomeTopMergeVC.h"
#import "TOPDocumentCollectionView.h"
#import "TOPDocumentTableView.h"
#import "TOPNextFolderViewController.h"
#import "TOPHomeChildViewController.h"
#import "TOPMergeTableView.h"
#import "TOPHomeViewController.h"
#import "TOPNextCollectionView.h"

@interface TOPHomeTopMergeVC ()<UISearchBarDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic ,strong) UIView * contentFatherView;
@property (nonatomic, strong) TOPNextCollectionView *nextCollView;
@property (nonatomic, strong) TOPDocumentCollectionView *collectionView;
@property (nonatomic, strong) TOPMergeTableView *tableView;
@property (nonatomic, strong) TOPDocPasswordView * passwordView;
@property (nonatomic, strong) NSMutableArray *selectedDocsIndexArray;
@property (nonatomic, strong) NSMutableArray *homeDataArray;
@property (nonatomic, strong) NSArray *allDocArray;
@property (nonatomic, strong) UIButton * mergeBtn;
@property (nonatomic, strong) UIButton * cancelBtn;
@property (nonatomic, strong) UIButton * rightBtn;
@property (nonatomic, strong) UIImageView * blankImg;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UIView * coverView;
@property (nonatomic, assign) BOOL isShowFailToast;
@end
@implementation TOPHomeTopMergeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    [self mergeVC_top_setupUI];
    [self top_setupBottomView];
    [self top_mergeVC_LoadSanBoxData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self top_setTopRightView];
    [TOPScanerShare shared].isEditing = YES;
    [self top_clickCancelBtn];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [TOPScanerShare shared].isEditing = NO;
    [self.rightBtn removeFromSuperview];
}

- (NSMutableArray *)selectedDocsIndexArray {
    if (!_selectedDocsIndexArray) {
        _selectedDocsIndexArray = [@[] mutableCopy];
    }
    return _selectedDocsIndexArray;
}

- (NSMutableArray *)homeDataArray{
    if (!_homeDataArray) {
        _homeDataArray = [NSMutableArray new];
    }
    return _homeDataArray;
}

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTapAction)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

#pragma mark -- 密码弹框
- (TOPDocPasswordView *)passwordView{
    if (!_passwordView) {
        WS(weakSelf);
        _passwordView = [[TOPDocPasswordView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolderSingle_H)];
        _passwordView.top_sendPassword = ^(NSString * _Nonnull password, NSInteger actionType ,BOOL isShowFailToast) {
            weakSelf.isShowFailToast = isShowFailToast;
            [weakSelf top_passwordViewActionWithPassword:password WithType:actionType];
        };
        _passwordView.top_clickToHide = ^{
            [weakSelf top_clickTapAction];
        };
        _passwordView.top_clickToHelp = ^{
            [weakSelf top_settingView_SendFeedback];
        };
    }
    return _passwordView;
}

#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    
    if (self.passwordView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            if (self.passwordView.actionType == TOPHomeMoreFunctionSetLockFirst) {
                self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_H, AddFolder_W, AddFolder_H);
            }else{
                self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolderSingle_H, AddFolder_W, AddFolderSingle_H);
            }
        }];
    }
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    if (![self.passwordView.tField isFirstResponder]&&![self.passwordView.againField isFirstResponder]) {
        [self top_clickTapAction];
    }
}

- (void)top_clickTapAction{
    [UIView animateWithDuration:0.3 animations:^{
        [self.passwordView removeFromSuperview];
        [self.coverView removeFromSuperview];
        self.passwordView = nil;
        self.coverView = nil;
    }];
}

- (void)top_backHomeAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)top_mergeVC_LoadSanBoxData{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * tempAllDataArray = [NSMutableArray new];
        if ([self.pathString isEqualToString:[TOPDocumentHelper top_appBoxDirectory]]) {
            tempAllDataArray = self.addDocArray;
        }else{
            TOPAPPFolder *appfld = [TOPDBQueryService top_appFolderById:self.docModel.docId];
            appfld.filePath = self.pathString;
            tempAllDataArray = [TOPDBDataHandler top_buildFolderSecondaryDataWithDB:appfld];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            self.homeDataArray = tempAllDataArray;
            self.allDocArray = [self top_allDocData];
            self.collectionView.listArray = tempAllDataArray;
            [self.collectionView setShowType:[TOPScanerShare top_listType]];
            self.tableView.listArray = tempAllDataArray;
            [self.tableView reloadData];
            self.nextCollView.listArray = tempAllDataArray;
            [self.nextCollView reloadData];
            [self top_showRightBtn];
            
            if(self.homeDataArray.count == 0){
                self.blankImg.hidden = NO;
                self.tableView.hidden = YES;
                self.collectionView.hidden = YES;
                self.nextCollView.hidden = YES;
            }else{
                self.blankImg.hidden = YES;
                self.tableView.hidden = NO;
                self.collectionView.hidden = NO;
                self.nextCollView.hidden = NO;
            }
            
            if ([TOPScanerShare top_listType] == ShowListGoods) {
                self.tableView.hidden = NO;
                self.collectionView.hidden = YES;
                self.nextCollView.hidden = YES;
            }else if([TOPScanerShare top_listType] == ShowListNextGoods){
                self.tableView.hidden = YES;
                self.collectionView.hidden = YES;
                self.nextCollView.hidden = NO;
            }else{
                self.tableView.hidden = YES;
                self.collectionView.hidden = NO;
                self.nextCollView.hidden = YES;
            }
           
            [self top_determineBottomBtnState];
        });
    });
}
#pragma mark -- 数据加载完成 如果有doc文档才显示右上角按钮
- (void)top_showRightBtn{
    for (DocumentModel * model in self.homeDataArray) {
        if ([model.type isEqualToString:@"1"]) {
            self.rightBtn.hidden = NO;
            return;
        }
    }
}
#pragma mark -- 讲所有的doc文档提出来 用作逻辑判断
- (NSArray *)top_allDocData{
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if ([model.type isEqualToString:@"1"]) {
            [tempArray addObject:model];
        }
    }
    return [tempArray copy];
}
- (void)top_setTopRightView{
    TOPImageTitleButton * rightBtn = [[TOPImageTitleButton alloc]initWithFrame:CGRectMake(TOPScreenWidth-150,2, 130, 40)];
    rightBtn.hidden = YES;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightBtn setTitle:NSLocalizedString(@"topscan_allselect", @"") forState:UIControlStateNormal];
    [rightBtn setTitle:NSLocalizedString(@"topscan_cancelallselect", @"") forState:UIControlStateSelected];
    [rightBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(top_selectAllAction:) forControlEvents:UIControlEventTouchUpInside];
    if (isRTL()) {
        rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }else{
        rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    self.rightBtn = rightBtn;
    [self.navigationController.navigationBar addSubview:rightBtn];
    [rightBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.navigationController.navigationBar).offset(-20);
        make.centerY.equalTo(self.navigationController.navigationBar);
        make.size.mas_equalTo(CGSizeMake(130, 40));
    }];
    [self top_showRightBtn];
}
#pragma mark -- 右上角按钮的点击事件
- (void)top_selectAllAction:(UIButton *)sender{
    BOOL selectState;
    sender.selected = !sender.selected;
    selectState = sender.selected;
    for (DocumentModel * model in self.homeDataArray) {
        if ([model.type isEqualToString:@"1"]) {
            model.selectStatus = selectState;
        }
    }
    if (selectState) {
        self.selectedDocsIndexArray = [self.allDocArray mutableCopy];
    }else{
        [self.selectedDocsIndexArray removeAllObjects];
    }
    [self top_determineBottomBtnState];
    [self.tableView reloadData];
    [self.collectionView setShowType:[TOPScanerShare top_listType]];
    [self.nextCollView reloadData];
}
- (void)mergeVC_top_setupUI{
    UIImageView * blankImg = [[UIImageView alloc]initWithFrame:CGRectMake((TOPScreenWidth-100)/2, (TOPScreenHeight-(266*100)/325-100)/2, 100, (266*100)/325)];
    blankImg.backgroundColor = [UIColor clearColor];
    blankImg.image = [UIImage imageNamed:@"top_blankView"];
    self.blankImg = blankImg;
    [self.view addSubview:blankImg];
    [self.view addSubview:self.contentFatherView];
    [self top_addCollectionView];
    [self top_addTableView];
    [self top_addNextCollView];
    
    [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+49));
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentFatherView);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentFatherView);
    }];
    [self.nextCollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentFatherView);
    }];
    [blankImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
    }];
}
- (void)top_addCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionHeadersPinToVisibleBounds = YES;
     
    self.collectionView = [[TOPDocumentCollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-49) collectionViewLayout:layout];
    self.collectionView.isMerge = YES;
    self.collectionView.isMoveState = NO;
    self.collectionView.isShowHeaderView = NO;
    
    WS(weakSelf);
    self.collectionView.top_pushNextControllerHandler = ^(DocumentModel * model) {
        [weakSelf top_pushToNextMergeVC:model];
    };
    
    self.collectionView.top_longPressCheckItemHandler = ^(NSInteger index, BOOL selected) {
        DocumentModel *model = weakSelf.homeDataArray[index];
        if ([model.type isEqualToString:@"1"]) {
            model.selectStatus = selected;
            if (selected) {
                [weakSelf.selectedDocsIndexArray addObject:model];
            } else {
                [weakSelf.selectedDocsIndexArray removeObject:model];
            }
            [weakSelf top_determineBottomBtnState];
        }
    };
    [self.contentFatherView addSubview:self.collectionView];
}
- (void)top_addNextCollView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionHeadersPinToVisibleBounds = YES;
     
    self.nextCollView = [[TOPNextCollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-49) collectionViewLayout:layout];
    self.nextCollView.isMerge = YES;
    WS(weakSelf);
    self.nextCollView.top_pushNextControllerHandler = ^(DocumentModel * model) {
        [weakSelf top_pushToNextMergeVC:model];
    };
    
    self.nextCollView.top_longPressCheckItemHandler = ^(DocumentModel * model, BOOL selected) {
        if ([model.type isEqualToString:@"1"]) {
            model.selectStatus = selected;
            if (selected) {
                [weakSelf.selectedDocsIndexArray addObject:model];
            } else {
                [weakSelf.selectedDocsIndexArray removeObject:model];
            }
            [weakSelf top_determineBottomBtnState];
        }
    };
    [self.contentFatherView addSubview:self.nextCollView];
}
- (void)top_addTableView{
    WS(weakSelf);
    self.tableView = [[TOPMergeTableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-49) style:UITableViewStylePlain];
    self.tableView.isMerge = YES;
    self.tableView.top_pushNextControllerHandler = ^(DocumentModel * _Nonnull model) {
        [weakSelf top_pushToNextMergeVC:model];
    };
    self.tableView.top_longPressCheckItemHandler = ^(NSInteger index, BOOL selected) {
        DocumentModel *model = weakSelf.homeDataArray[index];
        if ([model.type isEqualToString:@"1"]) {
            model.selectStatus = selected;
            if (selected) {
                [weakSelf.selectedDocsIndexArray addObject:model];
            } else {
                [weakSelf.selectedDocsIndexArray removeObject:model];
            }
            [weakSelf top_determineBottomBtnState];
        }
    };
    [self.contentFatherView addSubview:self.tableView];
}
- (void)top_pushToNextMergeVC:(DocumentModel *)model {
    TOPHomeTopMergeVC * nextFonderVC = [TOPHomeTopMergeVC new];
    nextFonderVC.pathString = model.path;
    nextFonderVC.docModel = model;
    nextFonderVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextFonderVC animated:YES];
}

#pragma mark -- 底部按钮的状态
- (void)top_determineBottomBtnState{
    if (self.selectedDocsIndexArray.count>0) {
        [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.cancelBtn.enabled = YES;
        if (self.selectedDocsIndexArray.count == self.allDocArray.count) {
            self.rightBtn.selected = YES;
        }else{
            self.rightBtn.selected = NO;
        }
    }else{
        [self.cancelBtn setTitleColor:RGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
        self.cancelBtn.enabled = NO;
        self.rightBtn.selected = NO;
    }
    
    NSString * mergeTitle = [NSString stringWithFormat:@"%@(%ld)",NSLocalizedString(@"topscan_merge", @""),self.selectedDocsIndexArray.count];
    [self.mergeBtn setTitle:mergeTitle forState:UIControlStateNormal];
    if (self.selectedDocsIndexArray.count>1) {
        [self.mergeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.mergeBtn.enabled = YES;
 
    }else{
        [self.mergeBtn setTitleColor:RGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
        self.mergeBtn.enabled = NO;
    }
}
- (void)top_setupBottomView{
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-49, TOPScreenWidth,49)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
    
    UIView * safeView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    safeView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];;
    
    UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, (TOPScreenWidth-1)/2-20, 49)];
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancelBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(top_clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn = cancelBtn;
    
    UIView * midLine = [[UIView alloc]initWithFrame:CGRectMake((TOPScreenWidth-1)/2, 12, 1, 25)];
    midLine.backgroundColor = [UIColor whiteColor];
    
    UIButton * mergeBtn = [[UIButton alloc]initWithFrame:CGRectMake((TOPScreenWidth-1)/2+1+10,0 , (TOPScreenWidth-1)/2-20, 49)];
    mergeBtn.backgroundColor = [UIColor clearColor];
    mergeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [mergeBtn setTitle:NSLocalizedString(@"topscan_merge", @"") forState:UIControlStateNormal];
    [mergeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [mergeBtn addTarget:self action:@selector(top_clickMergeBtn) forControlEvents:UIControlEventTouchUpInside];
    self.mergeBtn = mergeBtn;
    
    [self.view addSubview:bottomView];
    [self.view addSubview:safeView];
    [bottomView addSubview:cancelBtn];
    [bottomView addSubview:midLine];
    [bottomView addSubview:mergeBtn];
    [safeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
    }];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        make.height.mas_equalTo(49);
    }];
    [midLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bottomView);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(25);
    }];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(bottomView);
        make.trailing.equalTo(midLine.mas_leading);
    }];
    [mergeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.bottom.equalTo(bottomView);
        make.leading.equalTo(midLine.mas_trailing);
    }];
}

- (void)top_clickCancelBtn{
    self.rightBtn.selected = NO;
    [self.selectedDocsIndexArray removeAllObjects];
    for (DocumentModel * model in self.homeDataArray) {
        model.selectStatus = NO;
    }
    self.collectionView.listArray = self.homeDataArray;
    [self.collectionView setShowType:[TOPScanerShare top_listType]];
    self.tableView.listArray = self.homeDataArray;
    [self.tableView reloadData];
    self.nextCollView.listArray = self.homeDataArray;
    [self.nextCollView reloadData];
    [self top_determineBottomBtnState];
}

- (void)top_clickMergeBtn{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * tempArray = [NSMutableArray new];
        for (DocumentModel * model in self.selectedDocsIndexArray) {
            if ([TOPWHCFileManager top_isExistsAtPath:model.docPasswordPath]) {
                [tempArray addObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (tempArray.count>0) {
                UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
                [keyWindow addSubview:self.coverView];
                [keyWindow addSubview:self.passwordView];
                [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.top.bottom.equalTo(keyWindow);
                }];
                self.passwordView.actionType = TOPMenuItemsFunctionMerge;
            }else{
                [self top_mergeVC_MergeFileMethod];
            }
        });
    });
}

- (void)top_passwordViewActionWithPassword:(NSString *)password WithType:(NSInteger)actionType{
    switch (actionType) {
        case TOPMenuItemsFunctionMerge:
            [self top_SetLockMergeFile:password];
            break;
        default:
            break;
    }
}
#pragma mark -- 有密码时的合并
- (void)top_SetLockMergeFile:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_SetLockPushChildVC" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_clickTapAction];
        [self top_mergeVC_MergeFileMethod];
    }else{
        [self top_writePasswordFail];
    }
}

- (void)top_writePasswordFail{
    if (self.isShowFailToast) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_writepasswordfail", @"") duration:1];
    }
}
#pragma mark -- 合并方式选择
- (void)top_mergeVC_MergeFileMethod {
    [FIRAnalytics logEventWithName:@"mergeVC_MergeFileMethod" parameters:nil];
    TOPSCAlertController *alertController = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_mergefilemethodtitle", @"") message:nil preferredStyle: IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_mergefilemethodkeepold", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_mergeVC_MergeAndKeepOldFile];
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_mergefilemethoddeleteold", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self top_mergeVC_MergeAndDeleteOldFile];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    UIColor * titleColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor];
    UIColor * canelColor = TOPAPPGreenColor;
    [cancelAction setValue:canelColor forKey:@"_titleTextColor"];
    [archiveAction setValue:titleColor forKey:@"_titleTextColor"];
    [otherAction setValue:titleColor forKey:@"_titleTextColor"];
    [alertController addAction:archiveAction];
    [alertController addAction:otherAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- 合并且保留原文件 等同于拷贝文件
- (void)top_mergeVC_MergeAndKeepOldFile{
    [FIRAnalytics logEventWithName:@"homeView_MergeAndKeepOldFile" parameters:nil];
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *docPaht = [TOPDocumentHelper top_getDocumentsPathString];
        NSString *mergerFilePath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:docPaht];
        NSMutableArray *selectFiles = [self top_SelectFileArray];
        for (int i = 0; i < selectFiles.count; i ++) {
            DocumentModel *model = selectFiles[i];
            if (!i) {
                [TOPDocumentHelper top_copyFileItemsAtPath:model.path toNewFileAtPath:mergerFilePath];
            } else {
                [TOPDocumentHelper top_writeNewPic:model.path toNewFileAtPath:mergerFilePath delete:NO];
            }
        }
        TOPAppDocument *appDoc = [TOPEditDBDataHandler top_addDocumentAtFolder:mergerFilePath WithParentId:self.docModel.docId];
        [TOPFileDataManager shareInstance].docModel = [TOPDBDataHandler top_buildDocumentModelWithData:appDoc];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_mergesuccess", @"")];
            [SVProgressHUD dismissWithDelay:1];
            [self top_mergeVC_JumpToHomeChildVC:mergerFilePath];
        });
    });
}

#pragma mark -- 合并且删除原文件 等同往主文件移动文件
- (void)top_mergeVC_MergeAndDeleteOldFile {
    [FIRAnalytics logEventWithName:@"homeView_MergeAndDeleteOldFile" parameters:nil];
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *mergerFilePath = @"";
        NSString *mainDocId = @"";
        NSMutableArray *selectFiles = [self top_SelectFileArray];
        if (selectFiles.count) {
            DocumentModel *mainDoc = selectFiles[0];
            mergerFilePath = mainDoc.path;
            mainDocId = mainDoc.docId;
        }
        for (int i = 0; i < selectFiles.count; i ++) {
            if (!i) {
                continue;
            }
            DocumentModel *model = selectFiles[i];
            NSString *progressTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(%@-%@)",@(i +1),@(selectFiles.count)] : @"";
            NSMutableArray *newImages = [TOPDocumentHelper top_writeNewPic:model.path toNewFileAtPath:mergerFilePath delete:YES progress:^(CGFloat copyProgressValue) {
                [[TOPProgressStripeView shareInstance] top_showProgress:copyProgressValue withStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_mergeing", @""),progressTitle]];
            }];
            [TOPEditDBDataHandler top_batchEditImagePathWithId:model.docId toNewDoc:mainDocId withImageNames:newImages];
        }
        [TOPFileDataManager shareInstance].docModel = selectFiles[0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_mergesuccess", @"")];
            [SVProgressHUD dismissWithDelay:1];
            [self top_mergeVC_JumpToHomeChildVC:mergerFilePath];
        });
    });
}

- (void)top_mergeVC_JumpToHomeChildVC:(NSString *)path {
    if (path.length) {
        [FIRAnalytics logEventWithName:@"homeView_JumpToHomeChildVC" parameters:@{@"path":path}];
        TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
        childVC.docModel = [TOPFileDataManager shareInstance].docModel;;
        childVC.pathString = path;
        childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
        childVC.hidesBottomBarWhenPushed = YES;
        childVC.addType = @"add";
        childVC.backType = TOPHomeChildViewControllerBackTypePopRoot;
        childVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:childVC animated:YES];
    }
}
#pragma mark -- 选中的文件
- (NSMutableArray *)top_SelectFileArray {
    NSMutableArray *selectTempArray = [@[] mutableCopy];
    selectTempArray = [self.selectedDocsIndexArray mutableCopy];
    return selectTempArray;
}
#pragma mark -- Send feedback
- (void)top_settingView_SendFeedback{
    [FIRAnalytics logEventWithName:@"settingView_SendFeedback" parameters:nil];
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        return;
    }
    if (![mailClass canSendMail]) {
        //提示框添加文本输入框
        TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_bind", @"")
                                                                       message:NSLocalizedString(@"topscan_bindcontent", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
          
        }];
        [alert addAction:okAction];

        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    MFMailComposeViewController * mailCompose = [[MFMailComposeViewController alloc]init];
    mailCompose.mailComposeDelegate = self;
    [mailCompose setSubject:NSLocalizedString(@"topscan_passwordhelpsubject", @"")];
    NSArray * toRecipients = [NSArray arrayWithObjects:SimplescannerEmail,nil];
    [mailCompose setToRecipients:toRecipients];
    
    NSString *emailBody = [NSString stringWithFormat:@"Model:%@\n %@\n App:%@",[TOPAppTools deviceVersion],[TOPAppTools SystemVersion],[TOPAppTools getAppVersion]];
    [mailCompose setMessageBody:emailBody isHTML:NO];
    [self presentViewController:mailCompose animated:YES completion:^{
           
    }];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSString * msg ;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"取消发送邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"保存邮件成功";
            break;
        case MFMailComposeResultSent:
            msg = @"邮件发送成功";
            break;
        case MFMailComposeResultFailed:
            msg = @"保存或者发送邮件失败";
            break;
        default:
            msg = @"66666";
            break;
    }
    NSLog(@"msg===%@",msg);
}
- (UIView *)contentFatherView {
    if (!_contentFatherView) {
        _contentFatherView = [[UIView alloc] init];
        _contentFatherView.backgroundColor = [UIColor clearColor];
    }
    return _contentFatherView;
}
@end
