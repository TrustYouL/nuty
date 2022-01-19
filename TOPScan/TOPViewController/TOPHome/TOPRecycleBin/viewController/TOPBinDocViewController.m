#define Bottom_H 49

#import "TOPBinDocViewController.h"
#import "TOPDocumentCollectionView.h"
#import "TOPEditSelectedHeaderView.h"
#import "TOPBinDocument.h"
#import "TOPBinImageBrowseViewController.h"
#import "TOPCropTipView.h"

@interface TOPBinDocViewController ()<GADBannerViewDelegate>
@property (nonatomic, strong) TOPDocumentCollectionView *collectionView;
@property (nonatomic, strong) UIButton *restoreBtn;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) TOPEditSelectedHeaderView *editSelectedView;

@property (nonatomic, strong) NSMutableArray *selectedDocsIndexArray;
@property (nonatomic, strong) NSMutableArray *homeDataArray;
@property (nonatomic, strong) GADBannerView * scBannerView;
@property (nonatomic, assign) CGFloat adViewH;
@property (nonatomic, assign) CGSize currentSize;
@property (nonatomic, assign) BOOL isBanner;

@end

@implementation TOPBinDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adViewH = 0.0;
    self.isBanner = NO;
    self.title = self.docModel.name;
    [TOPScanerShare shared].isEditing = NO;
    [self top_configNavBar];
    [self top_configContentView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self top_loadBinData];
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self top_loadDocDataAndAD:self.view.size];
            });
        }];
    } else {
        [self top_loadDocDataAndAD:self.view.size];
    }
}
#pragma mark -- 加载横幅广告
- (void)top_loadDocDataAndAD:(CGSize)size{
    self.currentSize = size;
    if (![TOPPermissionManager top_enableByAdvertising]) {//要展示广告
        if (!self.isBanner) {//横幅没有加载过
            [self top_AddBannerViewWithSize:size];
        }else{//已经加载出了广告
            if (!self.scBannerView.hidden) {
                GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(size.width);
                self.adViewH = adSize.size.height;
            }
            [self top_adFinishContentFatherFream];
        }
    } else {//是会员移除横幅广告
        [self top_removeBannerView];
        [self top_adFailContentFatherFream];
    }
}
#pragma mark -- 隐藏横幅广告视图
- (void)top_removeBannerView{
    [self top_adFailContentFatherFream];
    [self.scBannerView removeFromSuperview];
    self.scBannerView = nil;
    self.isBanner = NO;
}
- (void)top_backHomeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 加载数据
- (void)top_loadBinData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * tempAllDataArray = @[].mutableCopy;
        TOPBinDocument *folderModel = [TOPBinQueryHandler top_appDocumentById:self.docModel.docId];
        folderModel.filePath = self.docModel.path;
        tempAllDataArray = [TOPBinDataHandler top_buildBinDocumentDataWithDB:folderModel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!tempAllDataArray.count) {
                [self top_backHomeAction];
                return;
            }
            self.homeDataArray = tempAllDataArray;
            self.collectionView.listArray = tempAllDataArray;
            [self.collectionView reloadData];
            self.rightBtn.hidden = !tempAllDataArray.count;
        });
    });
}

#pragma mark -- 删除
- (void)top_takeDeleteAlert {
    [self top_showCropTip];
}

- (void)top_showCropTip {
    BOOL showTip = [TOPScanerShare top_deleteFileAlert];
    if (showTip) {
        NSString *msg = [NSString stringWithFormat:@"%@ \n %@",NSLocalizedString(@"topscan_deleteoption", @""), NSLocalizedString(@"topscan_recyclebindeletetip", @"")];
        UIWindow *window = [UIApplication sharedApplication].windows[0];
        __weak typeof(self) weakSelf = self;
        TOPCropTipView *tipView = [[TOPCropTipView alloc] initWithTipMessage:msg];
        tipView.okBlock = ^{
            [weakSelf top_deleteHandle];
        };
        [window addSubview:tipView];
        [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(window);
        }];
    } else {
        [self top_deleteHandle];
    }
}

#pragma mark -- 删除
- (void)top_clickDeleteBtn {
    [self top_takeDeleteAlert];
}

- (void)top_deleteHandle {
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.selectedDocsIndexArray.count == self.homeDataArray.count) {//全选
            [TOPWHCFileManager top_removeItemAtPath:self.docModel.path];
            [TOPBinEditDataHandler top_deleteDocumentWithId:self.docModel.docId];
        } else {
            NSMutableArray *imgs = @[].mutableCopy;
            for (DocumentModel *model in self.selectedDocsIndexArray) {
                [imgs addObject:model.docId];
                [TOPWHCFileManager top_removeItemAtPath:model.path];
            }
            [TOPBinEditDataHandler top_deleteImagesWithIds:imgs];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (self.selectedDocsIndexArray.count == self.homeDataArray.count) {
                [self top_docIsEmpty];
                return;
            }
            [self top_cancleSelectAction];
            [self top_loadBinData];
        });
    });
}

#pragma mark -- 还原
- (void)top_clickRestoreBtn {
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.selectedDocsIndexArray.count == self.homeDataArray.count) {//全选
            [self top_restoreDocumentHandler:self.docModel];
        } else {
            for (DocumentModel *model in self.selectedDocsIndexArray) {
                [self top_restoreImageHandler:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_showSuccessTip];
            if (self.selectedDocsIndexArray.count == self.homeDataArray.count) {
                [self top_docIsEmpty];
                return;
            }
            [self top_cancleSelectAction];
            [self top_loadBinData];
        });
    });
}

- (void)top_docIsEmpty {
    [self top_cancleSelectAction];
    [self top_backHomeAction];
}

- (void)top_showSuccessTip {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_recyclebinsuccess", @"")];
    [SVProgressHUD dismissWithDelay:1];
}

#pragma mark -- 还原图片
- (void)top_restoreImageHandler:(DocumentModel *)model {
    NSString *targetPath = [TOPBinDataHandler top_restoreImageParentPath:model.docId];
    if ([TOPDocumentHelper top_directoryHasJPG:targetPath]) {//有图片 ,往文档中加图片，排在最后
        NSString *imgPath = [TOPBinHelper top_restoreImage:model.path atPath:targetPath];
        NSString *imgName = [TOPWHCFileManager top_fileNameAtPath:imgPath suffix:YES];
        NSString *parentId = [TOPBinDataHandler top_imageParentId:model.docId];
        [TOPEditDBDataHandler top_addBinImageFileAtDocument:@[imgName] WithId:parentId];
    } else {//无图片，则新建文档
        [TOPBinHelper top_restoreImage:model.path atPath:targetPath];
        DocumentModel *newObj = [TOPBinDataHandler top_restoreNewDocModel:targetPath withDelParentId:model.docId];
        [TOPEditDBDataHandler top_setDocTime:newObj.docId withBinDocId:self.docModel.docId];
    }
    [TOPBinEditDataHandler top_deleteImagesWithIds:@[model.docId]];
}

#pragma mark -- 还原文档
- (void)top_restoreDocumentHandler:(DocumentModel *)model {
    if ([TOPBinDataHandler top_needNewDocument:model.docId]) {//是否需要新建文档
        NSString *targetPath = [TOPBinDataHandler top_restoreDocumentPath:model.docId];
        [TOPBinHelper top_restoreDocument:model.path atPath:targetPath];
        NSString *newDocId = @"";
        if ([[TOPWHCFileManager top_directoryAtPath:targetPath] isEqualToString:[TOPDocumentHelper top_getDocumentsPathString]]) {
            DocumentModel *newObj = [TOPDBDataHandler top_addNewDocModel:targetPath];
            newDocId = newObj.docId;
        } else {
            NSString *parentId = [TOPBinDataHandler top_documentParentId:model.docId];
            TOPAppDocument *newObj = [TOPEditDBDataHandler top_addDocumentAtFolder:targetPath WithParentId:parentId];
            newDocId = newObj.Id;
        }
        [TOPEditDBDataHandler top_setDocTime:newDocId withBinDocId:model.docId];
        [TOPBinEditDataHandler top_deleteDocumentWithId:model.docId];
    } else {//将回收站文档内的图片合并到appDoc中
        TOPBinDocument *folderModel = [TOPBinQueryHandler top_appDocumentById:model.docId];
        folderModel.filePath = model.path;
        NSMutableArray *tempAllDataArray = [TOPBinDataHandler top_buildBinDocumentDataWithDB:folderModel];
        for (DocumentModel *imgObj in tempAllDataArray) {
            [self top_restoreImageHandler:imgObj];
        }
        [TOPWHCFileManager top_removeItemAtPath:model.path];
    }
}

#pragma mark -- 查看图片详情
- (void)top_checkDetailWithImages:(NSArray *)images atIndex:(NSIndexPath *)idxPath {
    __weak typeof(self) weakSelf = self;
    TOPBinImageBrowseViewController * imageBraowerVC = [[TOPBinImageBrowseViewController alloc] init];
    imageBraowerVC.dataArray = [images mutableCopy];
    imageBraowerVC.currentIndex = idxPath.item;
    imageBraowerVC.top_deleteAllDataBlock = ^{//数据全部删除的回调
        //删除文件夹路径
        [TOPWHCFileManager top_removeItemAtPath:weakSelf.docModel.path];
        [TOPEditDBDataHandler top_deleteDocumentWithId:weakSelf.docModel.docId];
        [weakSelf top_backHomeAction];
    };
    [self.navigationController pushViewController:imageBraowerVC animated:YES];
}

#pragma mark -- 开始选择
- (void)top_beginSelectAction {
    [TOPScanerShare shared].isEditing = YES;
    [self top_showEditSelectedHeader];
    [self top_showBottomView];
    [self.collectionView reloadData];
    [self top_refreshBottomBtnState];
}

#pragma mark -- 取消 退出编辑状态
- (void)top_cancleSelectAction {
    [TOPScanerShare shared].isEditing = NO;
    [self top_hiddenEditSelectedHeader];
    [self top_hiddenBottomView];
    [self top_allSelectAction:NO];
}

#pragma mark -- 全选/取消全选
- (void)top_allSelectAction:(BOOL)selected {
    for (DocumentModel * model in self.homeDataArray) {
        model.selectStatus = selected;
    }
    if (selected) {
        self.selectedDocsIndexArray = [self.homeDataArray mutableCopy];
    }else{
        [self.selectedDocsIndexArray removeAllObjects];
    }
    self.collectionView.listArray = self.homeDataArray;
    [self.collectionView reloadData];
    
    [self top_refreshBottomBtnState];
}

#pragma mark -- 显示选择编辑
- (void)top_showEditSelectedHeader {
    __weak typeof(self) weakSelf = self;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.editSelectedView];
    [self.editSelectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(window).offset(TOPStatusBarHeight);
        make.leading.trailing.equalTo(window);
        make.height.mas_equalTo(TOPNavBarHeight);
    }];
    [self.editSelectedView.superview layoutIfNeeded];
    self.editSelectedView.top_cancleEditHandler = ^{
        [weakSelf top_cancleSelectAction];
    };
    self.editSelectedView.top_selectAllHandler = ^(BOOL selected) {
        [weakSelf top_allSelectAction:selected];
    };
}

#pragma mark -- 隐藏选择编辑
- (void)top_hiddenEditSelectedHeader {
    [self.editSelectedView removeFromSuperview];
    self.editSelectedView = nil;
}

#pragma mark -- 设置导航栏
- (void)top_configNavBar {
    if (isRTL()) {//黑色
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    } else {
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self top_setTopRightView];
}

- (void)top_configContentView {
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    
    [self top_setupCollectionView];
    [self top_setupBottomView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(Bottom_H);
        make.height.mas_equalTo(Bottom_H);
    }];
}

- (void)top_setupCollectionView {
    [self.view addSubview:self.collectionView];
    [self.collectionView setShowType:ShowListDetailGoods];
    
    __weak typeof(self) weakSelf = self;
    _collectionView.top_longPressEditHandler = ^(NSIndexPath * _Nonnull idxPath){
        [weakSelf top_beginSelectAction];
    };
    self.collectionView.top_showPhotoHandler = ^(NSMutableArray * _Nonnull pathArray, NSIndexPath * _Nonnull idxPath) {
        [weakSelf top_checkDetailWithImages:pathArray atIndex:idxPath];
    };
    self.collectionView.top_longPressCheckItemHandler = ^(NSInteger index, BOOL selected) {
        DocumentModel *model = weakSelf.homeDataArray[index];
        model.selectStatus = selected;
        if (selected) {
            [weakSelf.selectedDocsIndexArray addObject:model];
        } else {
            [weakSelf.selectedDocsIndexArray removeObject:model];
        }
        [weakSelf top_refreshBottomBtnState];
    };
    self.collectionView.top_clickTxtOCR = ^(NSMutableArray * _Nonnull pathArray, NSIndexPath * _Nonnull idxPath) {
        [weakSelf top_needRestoreFileAlert];
    };
}

- (void)top_needRestoreFileAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"")
                                                                   message:NSLocalizedString(@"topscan_restorefirst", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
    }];

    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)top_refreshBottomBtnState {
    if (self.selectedDocsIndexArray.count>0) {
        [self.deleteBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
        self.deleteBtn.enabled = YES;
        [self.restoreBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
        self.restoreBtn.enabled = YES;
        if (self.selectedDocsIndexArray.count == self.homeDataArray.count) {
            self.editSelectedView.allSelectBtn.selected = YES;
        }else{
            self.editSelectedView.allSelectBtn.selected = NO;
        }
    } else {
        self.editSelectedView.allSelectBtn.selected = NO;
        [self.deleteBtn setTitleColor:kTabbarNormal forState:UIControlStateNormal];
        self.deleteBtn.enabled = NO;
        [self.restoreBtn setTitleColor:kTabbarNormal forState:UIControlStateNormal];
        self.restoreBtn.enabled = NO;
    }
}

- (void)top_showBottomView {
    [UIView animateWithDuration:0.3 animations:^{
        if (self.isBanner) {
            [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
            }];
            [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H+self.adViewH));
            }];
        }else{
            [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
            }];
            [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
            }];
        }
        [self.bottomView.superview layoutIfNeeded];
    }];
}

- (void)top_hiddenBottomView {
    [UIView animateWithDuration:0.3 animations:^{
        if (self.isBanner) {
            [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
            }];
        }else{
            [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.bottom.equalTo(self.view);
            }];
        }
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(Bottom_H);
        }];
        [self.bottomView.superview layoutIfNeeded];
    }];
}

- (void)top_setTopRightView {
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 32)];
    [btn2 setImage:[UIImage imageNamed:@"blackSelectState"] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(top_beginSelectAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem2 = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    self.rightBtn = btn2;
    self.navigationItem.rightBarButtonItem = barItem2;
}


- (void)top_setupBottomView {
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-Bottom_H, TOPScreenWidth,Bottom_H)];
    bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    
    UIView * safeView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight, TOPScreenWidth, TOPBottomSafeHeight)];
    safeView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];;
    
    UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, (TOPScreenWidth-1)/2-20, Bottom_H)];
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancelBtn setTitle:NSLocalizedString(@"topscan_delete", @"") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(top_clickDeleteBtn) forControlEvents:UIControlEventTouchUpInside];
    self.deleteBtn = cancelBtn;
    
    UIView * midLine = [[UIView alloc]initWithFrame:CGRectMake((TOPScreenWidth-1)/2, 12, 1, 25)];
    midLine.backgroundColor = TOPAPPGreenColor;
    
    UIButton * mergeBtn = [[UIButton alloc]initWithFrame:CGRectMake((TOPScreenWidth-1)/2+1+10,0 , (TOPScreenWidth-1)/2-20, Bottom_H)];
    mergeBtn.backgroundColor = [UIColor clearColor];
    mergeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [mergeBtn setTitle:NSLocalizedString(@"topscan_restoretitle", @"") forState:UIControlStateNormal];
    [mergeBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
    [mergeBtn addTarget:self action:@selector(top_clickRestoreBtn) forControlEvents:UIControlEventTouchUpInside];
    self.restoreBtn = mergeBtn;
    
    [self.view addSubview:bottomView];
    [self.view addSubview:safeView];
    [bottomView addSubview:cancelBtn];
    [bottomView addSubview:midLine];
    [bottomView addSubview:mergeBtn];
    self.bottomView = bottomView;
    
    [safeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(TOPBottomSafeHeight);
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

#pragma mark -- lazy
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

- (TOPDocumentCollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
         
        _collectionView = [[TOPDocumentCollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-Bottom_H) collectionViewLayout:layout];
        _collectionView.isMoveState = NO;
        _collectionView.isShowHeaderView = NO;
        [_collectionView addGestureRecognizer];
    }
    return _collectionView;
}

- (TOPEditSelectedHeaderView *)editSelectedView {
    if (!_editSelectedView) {
        _editSelectedView = [[TOPEditSelectedHeaderView alloc] init];
        _editSelectedView.title = self.title;
    }
    return _editSelectedView;
}
#pragma mark -- 横幅广告
- (void)top_AddBannerViewWithSize:(CGSize)currentSize{
    GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(currentSize.width);
    self.adViewH = adSize.size.height;
    NSString * adID = @"ca-app-pub-3940256099942544/2934735716";
    adID = [TOPDocumentHelper top_bannerAdID][5];
    GADBannerView * scbannerView = [[GADBannerView alloc] init];
    scbannerView.adSize = adSize;
    scbannerView.delegate = self;
    scbannerView.adUnitID = adID;
    scbannerView.rootViewController = self;
    self.scBannerView = scbannerView;
    [self.view addSubview:self.scBannerView];
    [self.scBannerView loadRequest:[GADRequest request]];
    self.scBannerView.hidden = YES;
    [self.scBannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
    }];
}
#pragma mark -- 获取横幅广告成功
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView{
    [FIRAnalytics logEventWithName:@"homeView_bannerReceiveAd" parameters:nil];
    if (bannerView) {
        bannerView.hidden = NO;
        self.isBanner = YES;
        [self top_adFinishContentFatherFream];
    }
}

#pragma mark -- 获取横幅广告失败
- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"error==%@",error);
    if (!self.isBanner) {
        [self top_removeBannerView];
    }
}
- (void)top_adFinishContentFatherFream{
    if ([TOPScanerShare shared].isEditing == YES) {
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
        }];
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H+self.adViewH));
        }];
    }else{
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
        }];
    }
}
- (void)top_adFailContentFatherFream{
    if ([TOPScanerShare shared].isEditing == YES) {
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        }];
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
        }];
    }else{
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(self.view);
        }];
    }
}

@end
