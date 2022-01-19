#define Bottom_H 49

#import "TOPBinHomeViewController.h"
#import "TOPDocumentCollectionView.h"
#import "TOPBinDocViewController.h"
#import "TOPEditSelectedHeaderView.h"
#import "TOPBinDocument.h"
#import "TOPHomeShowView.h"
#import "TOPBinSettingViewController.h"
#import "TOPCropTipView.h"

@interface TOPBinHomeViewController ()<GADBannerViewDelegate>
@property (nonatomic, strong) TOPDocumentCollectionView *collectionView;
@property (nonatomic, strong) UIButton *restoreBtn;//
@property (nonatomic, strong) UIButton *deleteBtn;//
@property (nonatomic, strong) UIButton *rightBtn;//右上角选择按钮
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *emptyTipView;
@property (nonatomic, strong) TOPEditSelectedHeaderView *editSelectedView;
@property (nonatomic, strong) UILabel  *fileSizeLab;
@property (nonatomic, strong) UILabel  *saveTimeLab;
@property (nonatomic, strong) UIView * coverView;//更多功能的覆盖层
@property (nonatomic, strong) TOPHomeShowView * topMoreView;

@property (nonatomic, strong) NSMutableArray *selectedDocsIndexArray;//选中的文件
@property (nonatomic, strong) NSMutableArray *homeDataArray;//全部文件的数据
@property (nonatomic, strong) GADBannerView * scBannerView;//横幅广告
@property (nonatomic, assign) CGFloat adViewH;//广告试图的高度
@property (nonatomic, assign) CGSize currentSize;
@property (nonatomic, assign) BOOL isBanner;//YES表示获取banner广告成功 默认值为NO

@end

@implementation TOPBinHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adViewH = 0.0;
    self.isBanner = NO;
    self.title = self.docModel.name ? : NSLocalizedString(@"topscan_recyclebin", @"");
    [TOPScanerShare shared].isEditing = NO;
    [self top_configNavBar];
    [self top_configContentView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self top_loadBinData];
    [self top_resetSaveTime];
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

- (void)top_resetSaveTime {
    NSInteger days = [TOPScanerShare top_saveBinFileTime];
    self.saveTimeLab.text = [NSLocalizedString(@"topscan_recyclebinsavetip", @"") stringByReplacingOccurrencesOfString:@"30" withString:[NSString stringWithFormat:@"%@",@(days)]];
}

#pragma mark -- 清除过期文件 -- 90天
- (void)top_clearExpiredFile {
    [TOPBinDataHandler top_checkExpiredFile];
}

#pragma mark -- 加载数据
- (void)top_loadBinData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * tempAllDataArray = @[].mutableCopy;
        if (!self.docModel) {//首页
            [self top_clearExpiredFile];
            tempAllDataArray = [TOPBinDataHandler top_buildBinHomeDataWithDB];
        } else {
            TOPBinFolder *folderModel = [TOPBinQueryHandler top_appFolderById:self.docModel.docId];
            tempAllDataArray = [TOPBinDataHandler top_buildBinFolderDataWithDB:folderModel];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!tempAllDataArray.count && !self.docModel) {
                self.collectionView.hidden = YES;
                self.bottomView.hidden = YES;
                self.fileSizeLab.hidden = YES;
            } else {
                [self top_sumAllFileSize];
            }
            self.homeDataArray = tempAllDataArray;
            self.collectionView.listArray = tempAllDataArray;
            [self.collectionView reloadData];
            self.rightBtn.hidden = !tempAllDataArray.count;
        });
    });
}

- (void)top_sumAllFileSize {
    if (self.docModel) {
        self.fileSizeLab.hidden = YES;
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        long total = [TOPBinDataHandler top_sumAllBinFileSize];
        NSString *sizeStr = [TOPDocumentHelper top_memorySizeStr:(total *1.0)];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"contentSize==%f height==%f",self.collectionView.contentSize.height,self.collectionView.bounds.size.height);

            self.fileSizeLab.hidden = self.collectionView.contentSize.height > (self.collectionView.bounds.size.height - 30) ? YES : NO;
            self.fileSizeLab.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"topscan_filesize", @""), sizeStr];
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
        for (DocumentModel *model in self.selectedDocsIndexArray) {
            [TOPWHCFileManager top_removeItemAtPath:model.path];
            if ([model.type isEqualToString:@"0"]) {
                [TOPBinEditDataHandler top_deleteFolderWithId:model.docId];
            } else {
                [TOPBinEditDataHandler top_deleteDocumentWithId:model.docId];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self top_cancleSelectAction];
            [self top_loadBinData];
        });
    });
}

#pragma mark -- 还原
- (void)top_clickRestoreBtn {
    if (self.selectedDocsIndexArray.count > 5) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:NSLocalizedString(@"topscan_moveprocessing", @"")];
    } else {
        [SVProgressHUD show];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int i = 0;
        for (DocumentModel *model in self.selectedDocsIndexArray) {
            i ++;
            if ([model.type isEqualToString:@"0"]) {
                [self top_restoreFolderHandler:model];
            } else {
                [self top_restoreDocumentHandler:model];
            }
            CGFloat moveProgressValue = i / (self.selectedDocsIndexArray.count * 1.0);
            [[TOPProgressStripeView shareInstance] top_showProgress:moveProgressValue withStatus:NSLocalizedString(@"topscan_moveprocessing", @"")];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [self top_showSuccessTip];
            [self top_cancleSelectAction];
            [self top_loadBinData];
        });
    });
}

- (void)top_showSuccessTip {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_recyclebinsuccess", @"")];
    [SVProgressHUD dismissWithDelay:1];
}

#pragma mark -- 还原文件夹
- (void)top_restoreFolderHandler:(DocumentModel *)model {
    NSString *targetPath = [TOPBinDataHandler top_restoreFolderPath:model.docId];
    [TOPBinHelper top_restoreFolder:model.path atPath:targetPath];
    NSArray *fileData = @[@[targetPath], @[], @[]];
    [TOPDBDataHandler top_restoreFileData:fileData];
    [TOPBinEditDataHandler top_deleteFolderWithId:model.docId];
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
        DocumentModel *newObj = [TOPDBDataHandler top_addNewDocModel:targetPath];
        [TOPEditDBDataHandler top_setDocTime:newObj.docId withBinDocId:model.docId];
    }
    [TOPBinEditDataHandler top_deleteImagesWithIds:@[model.docId]];
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

#pragma mark -- 跳转到下一级界面
- (void)top_pushToNextVC:(DocumentModel *)docModel {
    if ([docModel.type isEqualToString:@"0"]) {//文件夹
        TOPBinHomeViewController *vc = [[TOPBinHomeViewController alloc] init];
        vc.docModel = docModel;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        TOPBinDocViewController *vc = [[TOPBinDocViewController alloc] init];
        vc.docModel = docModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
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
#pragma mark -- 清空提醒
- (void)top_top_clearUpTakeAlert {
    if (!self.homeDataArray.count) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_recyclebinempty", @"")];
        return;
    }
    BOOL showTip = [TOPScanerShare top_deleteFileAlert];
    if (showTip) {
        __weak typeof(self) weakSelf = self;
        //提示框添加文本输入框
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_clearUpalert", @"")
                                                                       message:NSLocalizedString(@"topscan_recyclebindeletetip", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [weakSelf top_clearUp];
        }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self top_clearUp];
    }
}

#pragma mark ---清空
- (void)top_clearUp {
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (DocumentModel *model in self.homeDataArray) {
            [TOPWHCFileManager top_removeItemAtPath:model.path];
            if ([model.type isEqualToString:@"0"]) {
                [TOPBinEditDataHandler top_deleteFolderWithId:model.docId];
            } else {
                [TOPBinEditDataHandler top_deleteDocumentWithId:model.docId];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self top_loadBinData];
        });
    });
}

#pragma mark --- 设置
- (void)top_binSettings {
    TOPBinSettingViewController *vc = [[TOPBinSettingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark ---更多
- (void)top_showHomeBinHeaderMore {
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
    self.coverView.backgroundColor = [UIColor clearColor];
    self.coverView.userInteractionEnabled = YES;
    NSArray * dataArray = @[NSLocalizedString(@"topscan_deleteall", @""),NSLocalizedString(@"topscan_questionsetting", @"")];
    NSArray * iconArray = @[@"top_deleteShowImg", @"top_pdf_setting"];
    [keyWindow addSubview:self.topMoreView];
    
    [self.topMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(keyWindow).offset(-10);
        make.top.equalTo(keyWindow).offset(TOPNavBarAndStatusBarHeight);
        make.size.mas_equalTo(CGSizeMake(210, dataArray.count*45));
    }];
    self.topMoreView.showType = TOPHomeShowViewLocationTypeTopRight;
    self.topMoreView.dataArray = dataArray;
    self.topMoreView.iconArray = iconArray;
}

- (NSArray *)moreItems {
    NSArray *moreArray = @[@(TOPBinMoreFunctionDeleteAll),@(TOPBinMoreFunctionSetting)];
    return moreArray;
}

- (void)top_homeBin_HomeBinHeaderMoreAction:(NSInteger)row{
    NSNumber * rowNum = [self moreItems][row];
    switch ([rowNum integerValue]) {
        case TOPBinMoreFunctionDeleteAll:
            [self top_top_clearUpTakeAlert];
            break;
        case TOPBinMoreFunctionSetting:
            [self top_binSettings];
            break;
            
        default:
            break;
    }
}

- (void)top_hiddenMoreView {
    [self.coverView removeFromSuperview];
    [self.topMoreView removeFromSuperview];
    self.topMoreView = nil;
    self.coverView = nil;
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
    [self.view addSubview:self.emptyTipView];
    [self.emptyTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self top_setupCollectionView];
    [self top_setupBottomView];
    [self.view addSubview:self.fileSizeLab];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(Bottom_H);
        make.height.mas_equalTo(Bottom_H);
    }];
    [self.fileSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.collectionView.mas_bottom).offset(0);
        make.height.mas_equalTo(30);
    }];
}

- (void)top_setupCollectionView {
    [self.view addSubview:self.collectionView];
    [self.collectionView setShowType:ShowThreeGoods];
    
    __weak typeof(self) weakSelf = self;
    //开始长按
    _collectionView.top_longPressEditHandler = ^(NSIndexPath * _Nonnull idxPath){
        [weakSelf top_beginSelectAction];
    };
    //跳转去下一界面
    self.collectionView.top_pushNextControllerHandler = ^(DocumentModel * model) {
        [weakSelf top_pushToNextVC:model];
    };
    //记录文件选中先后顺序
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
    self.collectionView.top_didScrolInBottom = ^(BOOL isBottom) {
        if (!weakSelf.docModel) {
            weakSelf.fileSizeLab.hidden = !isBottom;
        }
    };
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
                make.leading.trailing.top.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
            }];
        }
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(Bottom_H);
        }];
        [self.bottomView.superview layoutIfNeeded];
    }];
}

- (void)top_setTopRightView {
    [self top_setRightButtons:@[@"blackMore",@"blackSelectState"]];
}
- (void)top_setRightButtons:(NSArray *)imgNames {
    if (imgNames.count) {
        NSString *imgName = imgNames[0];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 32)];
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(top_showHomeBinHeaderMore) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        NSString *imgName2 = imgNames[1];
        UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 32)];
        [btn2 setImage:[UIImage imageNamed:imgName2] forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(top_beginSelectAction) forControlEvents:UIControlEventTouchUpInside];
        self.rightBtn = btn2;
        UIBarButtonItem *barItem2 = [[UIBarButtonItem alloc] initWithCustomView:btn2];
        self.navigationItem.rightBarButtonItems = @[barItem,barItem2];
    }
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
    [mergeBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
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

- (UIView *)emptyTipView {
    if (!_emptyTipView) {
        _emptyTipView = [[UIView alloc] init];
        _emptyTipView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:kWhiteColor];
        UIImageView *emptyLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_bin_empty"]];
        emptyLogo.backgroundColor = [UIColor clearColor];
        [_emptyTipView addSubview:emptyLogo];
        
        UILabel *tipLab = [[UILabel alloc] init];
        tipLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor];
        tipLab.textAlignment = NSTextAlignmentCenter;
        tipLab.font = PingFang_R_FONT_(17);
        tipLab.text = NSLocalizedString(@"topscan_recyclebinempty", @"");
        [_emptyTipView addSubview:tipLab];
        
        UILabel *alertLab = [[UILabel alloc] init];
        alertLab.textColor = kTabbarNormal;
        alertLab.textAlignment = NSTextAlignmentCenter;
        alertLab.font = PingFang_R_FONT_(12);
        [_emptyTipView addSubview:alertLab];
        self.saveTimeLab = alertLab;
        [emptyLogo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_emptyTipView).offset(150);
            make.centerX.equalTo(_emptyTipView);
            make.width.mas_equalTo(97);
            make.height.mas_equalTo(102);
        }];
        
        [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(emptyLogo.mas_bottom).offset(40);
            make.centerX.equalTo(_emptyTipView);
            make.height.mas_equalTo(20);
        }];
        
        [alertLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tipLab.mas_bottom).offset(12);
            make.centerX.equalTo(_emptyTipView);
            make.height.mas_equalTo(15);
        }];
        [self top_resetSaveTime];
        
    }
    return _emptyTipView;
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
    if (!self.isBanner) {//google广告没有出现过
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
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        }];
    }
}
- (UILabel*)fileSizeLab {
    if (!_fileSizeLab) {
        _fileSizeLab = [[UILabel alloc] initWithFrame:CGRectMake((100) , TOPStatusBarHeight + 8, TOPScreenWidth - (200), (18))];
        _fileSizeLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kTabbarNormal];
        _fileSizeLab.font = [self fontsWithSize:13];
        _fileSizeLab.textAlignment = NSTextAlignmentCenter;
        self.fileSizeLab.hidden = YES;
    }
    return _fileSizeLab;;
}

- (TOPHomeShowView *)topMoreView{
    if (!_topMoreView) {
        __weak typeof(self) weakSelf = self;
        _topMoreView = [[TOPHomeShowView alloc]init];
        _topMoreView.top_clickCellAction = ^(NSInteger row) {
            [weakSelf top_hiddenMoreView];
            [weakSelf top_homeBin_HomeBinHeaderMoreAction:row];
        };
        
        _topMoreView.top_clickDismiss = ^{
            
        };
    }
    return _topMoreView;
}

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_hiddenMoreView)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

@end
