//
//  SCRecentViewController.m
//  SimpleScan
//
//  Created by admin3 on 2021/8/31.
//  Copyright © 2021 admin3. All rights reserved.
//
#define Bottom_H 60
#define AddFolder_W 310
#define AddFolder_H 240
#define AddFolderSingle_H 190
#define FolderViewTypeChange @"FolderViewTypeChange"

#import "SCHomeListViewController.h"
#import "TOPSettingViewController.h"
#import "TOPUnlockFunctionViewController.h"
#import "TOPHomeChildViewController.h"
#import "TOPShowLongImageViewController.h"
#import "TOPPhotoShowTextAgainVC.h"
#import "TOPFileTargetListViewController.h"
#import "TOPSetTagViewController.h"
#import "TOPLoadSelectDriveViewController.h"
#import "TOPRestoreViewController.h"
#import "TOPMainTabBarController.h"

#import "TOPTopHideView.h"
#import "TOPHomePageHeaderView.h"
#import "SCRecentHeadView.h"
#import "TOPDocumentTableView.h"
#import "TOPShareFileDataHandler.h"
#import "TOPShareFileView.h"
#import "TOPShareFileModel.h"
#import "TOPShareDownSizeView.h"
#import "TOPAddFolderView.h"
#import "TOPPhotoLongPressView.h"
#import "TOPChildMoreView.h"
#import "TOPHeadMenuModel.h"
#import "TOPMainTabBar.h"
#import "TOPBinHomeViewController.h"

@interface SCHomeListViewController ()<GADBannerViewDelegate,MFMailComposeViewControllerDelegate,UIPrintInteractionControllerDelegate,UIDocumentPickerDelegate,GADAdLoaderDelegate,GADNativeAdLoaderDelegate>
@property (nonatomic, strong) UILabel *fileSizeLab;//文件大小的lab
@property (nonatomic, strong) UIView * coverView;//覆盖层
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) UIView * contentFatherView;//列表视图的父视图
@property (nonatomic, strong) TOPPhotoLongPressView *pressUpView;
@property (nonatomic, strong) TOPPhotoLongPressView *pressBootomView;
@property (nonatomic, strong) TOPAddFolderView * addFolderView;
@property (nonatomic, strong) TOPDocPasswordView * passwordView;//密码弹框
@property (nonatomic, strong) TOPDocumentTableView * tableView;
@property (nonatomic, strong) SCRecentHeadView * middleView;//中间标题视图
@property (nonatomic, strong) TOPTopHideView * topHideView;//顶部视图
@property (nonatomic, strong) GADBannerView * scBannerView;//横幅广告
@property (nonatomic, assign) BOOL isBanner;//YES表示获取banner广告成功 默认值为NO
@property (nonatomic, assign) CGFloat adViewH;//广告试图的高度
@property (nonatomic, strong) NSMutableArray * selectedDocsIndexArray;//选中的doc文档
@property (nonatomic, strong) NSMutableArray  * homeDataArray;//所有的doc文档
@property (nonatomic, strong) NSMutableArray *homeMoreArray;//更多部分
@property (nonatomic, strong) DocumentModel * docModel;//点击的doc文档
@property (nonatomic, assign) BOOL isShowFailToast;//密码错误时是否弹出提示
@property (nonatomic, assign) NSInteger emailType;//判断是不是email分享 为1是
@property (nonatomic, assign) NSInteger pdfType;//当是email分享时 判断是分享的pdf还是图片 0是pdf 1是图片
@property (nonatomic, strong) TOPSettingEmailModel * emailModel;
@property (nonatomic, strong) TOPShareFileView *shareFilePopView;
@property (nonatomic, copy) NSString * folderViewType;//视图的功能类型
@property (nonatomic, assign) CGFloat  totalSizeNum;//选中文件大小
@property (nonatomic, strong) GADAdLoader *adLoader;//原生广告
@property (nonatomic, strong) DocumentModel * nativeAdModel;//原生广告模型
@property (nonatomic, assign) NSInteger navADIndex;//原生广告在数据源中的位置 当在tab的子视图控制器相互切换时原生广告不重新加载位置也不变

@end

@implementation SCHomeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self top_setupUI];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //关闭透明
    [[UINavigationBar appearance] setTranslucent:NO];
    
    [self top_setupNavBar];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recentView_GetCamera) name:TOP_TRCenterBtnGetCamera object:nil];
    //监听键盘，键盘出现
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    //监听键盘隐藏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self loadAllData];
}
- (void)loadAllData{
    [self top_initFileManager];//这里需要考虑一下
    if (![TOPScanerShare shared].isEditing) {
        [self loadRecentData];
    }
}
-(void)viewDidAppear:(BOOL)animated {//只能在界面已经加载完成后才能加手势禁用，如果在viewWillAppear时禁用会影响上一个界面的手势活跃状态
    [super viewDidAppear:animated];
    [self top_restoreBannerAD:self.view.size];//横幅广告
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;//关闭手势
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;//激活手势
    };
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.tabBarController.selectedIndex != 1) {
        [self top_removeBannerView];//移除横幅广告
    }
    if (![TOPScanerShare shared].isEditing) {//不是编辑状态
        if (self.tabBarController.selectedIndex == 1) {//当tab展示的子控制器是当前界面的控制器 以此为基础控制器跳转界面之后 将原生广告置空 ，在tab上相互切换时原生广告不做处理
            self.nativeAdModel = nil;
            self.navADIndex = 0;
        }
    }
}
#pragma mark -- 横竖屏切换时重新设置titleView
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
//    [self top_removeBannerView];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        /*
        if (self.tabBarController.selectedIndex == 1) {
            [self top_restoreBannerAD:size];
        }*/
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self top_setupNavBar];
    /*
    if (self.tabBarController.selectedIndex == 1) {
        [self top_restoreBannerAD:size];
    }*/
    if (self.shareFilePopView) {
        [self.shareFilePopView top_updateSubViewsLayout];
    }
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    self.fileSizeLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kTabbarNormal];
}
- (void)top_restoreBannerAD:(CGSize)size{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self top_changeBannerViewFream:size];
            });
        }];
    } else {
        [self top_changeBannerViewFream:size];
    }
}
- (void)top_initFileManager {
    DocumentModel *model = [[DocumentModel alloc] init];
    model.docId = @"000000";
    model.type = @"0";
    model.path = [TOPDocumentHelper top_getDocumentsPathString];
    [TOPFileDataManager shareInstance].docModel = model;
}
- (void)recentView_GetCamera{
    [FIRAnalytics logEventWithName:@"recentView_GetCamera" parameters:nil];
    TOPEnterCameraType cameraTpye = TOPShowFolderCameraType;
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = [TOPDocumentHelper top_appBoxDirectory];
    camera.fileType = cameraTpye;
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    if (_addFolderView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            self.addFolderView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_W, AddFolder_W, AddFolder_W);
        }];
    }
    if (_passwordView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            if (self.passwordView.actionType == TOPHomeMoreFunctionSetLockFirst|| self.passwordView.actionType == TOPHomeMoreFunctionPDFPassword) {
                self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_H, AddFolder_W, AddFolder_H);
            }else{
                self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolderSingle_H, AddFolder_W, AddFolderSingle_H);
            }
        }];
    }
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    if (_addFolderView) {
        if (![self.addFolderView.tField  isFirstResponder]) {
            [self recentView_ClickTapAction];
        }
    }
    if (_passwordView) {
        if (![self.passwordView.tField isFirstResponder]&&![self.passwordView.againField isFirstResponder]) {
            [self recentView_ClickTapAction];
        }
    }
}
#pragma mark -- 获取所有doc文档 按修改日期的倒序排列 由新到旧
- (void)loadRecentData{
    if (!self.homeDataArray.count) {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * tempArray = [TOPDBDataHandler top_buildRecentDocDataWithDB];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            self.homeDataArray = [tempArray mutableCopy];
            if (self.homeDataArray.count) {//有数据才弹广告
                if (![TOPPermissionManager top_enableByAdvertising]) {//不是会员展示广告
                    if (self.nativeAdModel) {//原生广告不为nil时直接添加到数据源
                        [self top_adReceiveFinishAndRefreshUI];
                    }
                }
            }
            self.tableView.listArray = self.homeDataArray;
            [self.tableView reloadData];
            [self top_restoreNativeAd];
            [self top_sumAllFileSize];
        });
    });
}
#pragma mark -- 显示文件大小的lab
- (void)top_sumAllFileSize {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        long total = [TOPDocumentHelper top_calculateAllFilesSize:self.homeDataArray];
        NSString *sizeStr = [TOPDocumentHelper top_memorySizeStr:(total *1.0)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BOOL isShow = self.tableView.contentSize.height > (self.tableView.bounds.size.height - 30) ? YES : NO;
            if (!self.homeDataArray.count) {
                self.fileSizeLab.hidden = YES;
            }else{
                self.fileSizeLab.hidden = isShow;
            }
            self.fileSizeLab.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"topscan_filesize", @""), sizeStr];
        });
    
    });
}
- (void)top_restoreNativeAd{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    [FIRAnalytics logEventWithName:@"ATTrackingManagerAuthorized" parameters:nil];
                }else{
                    [FIRAnalytics logEventWithName:@"ATTrackingManagerDenied" parameters:nil];
                }
                [self top_nativeAdShowState];
            });
        }];
    } else {
        [self top_nativeAdShowState];
    }
}
#pragma mark -- 文档数据获取之后根据用户状态将原生广告数据添加进去
- (void)top_nativeAdShowState{
    if (self.homeDataArray.count) {//有数据才弹广告
        if (![TOPPermissionManager top_enableByAdvertising]) {//不是会员展示广告
            if (!self.nativeAdModel) {//原生数据模型是nil时重新加载
                [self top_getNativeAd];//原生广告
            }
        }else{//是会员
            if (self.nativeAdModel) {
                self.nativeAdModel = nil;
            }
        }
    }
}
#pragma mark -- 点击doc时有无密码的判断
- (void)top_judgeClickDocPasswordState{
    NSString * passwordPath = self.docModel.docPasswordPath;
    if (passwordPath.length>0) {
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        [keyWindow addSubview:self.coverView];
        [self top_markupCoverMask];
        [keyWindow addSubview:self.passwordView];
        self.passwordView.actionType = TOPMenuItemsFunctionPushVC;
    }else{
        [self top_clickDocPushChildVCWithPath];
    }
}
#pragma mark -- 没有蜂窝数据时点击分享时给出的弹框
- (void)top_showCellularView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    TOPCellularView *cellularView = [[TOPCellularView alloc]init];
    cellularView.top_settingBlock = ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    };
    [keyWindow addSubview:cellularView];
    [cellularView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}
#pragma mark -- 根据选中的数据来确定密码视图的展示与否
- (void)top_judgePasswordViewState:(NSInteger)index{
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        NSArray *funcIndexArray = [self recentView_FuncItems];
        NSNumber *funcNum = funcIndexArray[index];
        if ([funcNum integerValue] == TOPMenuItemsFunctionShare) {//分享时判断有没有开启app的蜂窝数据
            if (isReopened) {//没有开启给出提示
                [self top_showCellularView];
            }else{
                [self top_wlanOpenedJudgePasswordViewState:index];
            }
        }else{
            [self top_wlanOpenedJudgePasswordViewState:index];
        }
    }];
}
- (void)top_wlanOpenedJudgePasswordViewState:(NSInteger)index{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * passwordArray = [TOPDocumentHelper top_getSelectLockState:self.homeDataArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (passwordArray.count>0) {
                UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
                [keyWindow addSubview:self.coverView];
                [self top_markupCoverMask];
                [keyWindow addSubview:self.passwordView];
                NSArray *funcIndexArray = [self recentView_FuncItems];
                NSNumber *funcNum = funcIndexArray[index];
                switch ([funcNum integerValue]) {
                    case TOPMenuItemsFunctionShare:
                        self.passwordView.actionType = TOPMenuItemsFunctionShare;
                        break;
                    case TOPMenuItemsFunctionMerge:
                        self.passwordView.actionType = TOPMenuItemsFunctionMerge;
                        break;
                    case TOPMenuItemsFunctionCopyMove:
                        self.passwordView.actionType = TOPMenuItemsFunctionCopyMove;
                        break;
                    case TOPMenuItemsFunctionDelete:
                        self.passwordView.actionType = TOPMenuItemsFunctionDelete;
                        break;
                    case TOPMenuItemsFunctionMore:
                        self.passwordView.actionType = TOPMenuItemsFunctionMore;
                        break;
                    case TOPMenuItemsFunctionRename:
                        self.passwordView.actionType = TOPMenuItemsFunctionRename;
                        break;
                    default:
                        break;
                }
            }else{
                [self recentView_InvokeMenuFunctionAtIndex:index];
            }
        });
    });
}
#pragma mark -- 调用底部菜单事件
- (void)recentView_InvokeMenuFunctionAtIndex:(NSInteger)index {
    [FIRAnalytics logEventWithName:@"recentView_FunctionAtIndex" parameters:@{@"index":@(index)}];
    /*
    NSMutableArray * selectTempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if (model.selectStatus) {
            [selectTempArray addObject:model];
        }
    }
    if (selectTempArray.count == 0) {
        return;
    }*/
    NSArray *funcIndexArray = [self recentView_FuncItems];
    NSNumber *funcNum = funcIndexArray[index];
    switch ([funcNum integerValue]) {
        case TOPMenuItemsFunctionShare:
            [self recentView_ShareTip];
            break;
        case TOPMenuItemsFunctionMerge:
            [self recentView_MergeFileMethod];
            break;
        case TOPMenuItemsFunctionCopyMove:
            [self recentView_EditFileMethod];
            break;
        case TOPMenuItemsFunctionDelete:
            [self recentView_DeleteTip];
            break;
        case TOPMenuItemsFunctionMore:
            [self recentView_EditMoreMethod];
            NSLog(@"更多");
            break;
        case TOPMenuItemsFunctionRename:
            [self recentView_ClickToChangeFolderName];
            break;
        default:
            break;
    }
}
#pragma mark -- doc密码的视图的点击事件
- (void)top_passwordViewActionWithPassword:(NSString *)password WithType:(NSInteger)actionType{
    switch (actionType) {
        case TOPHomeMoreFunctionSetLockFirst://第一次写入密码
            [self recentView_ClickTapAction];
            [self recent_WritePasswordToDoc:password];
            break;
        case TOPHomeMoreFunctionSetLock://有默认密码时设置密码
            [self recent_SetLockagain:password];
            break;
        case TOPHomeMoreFunctionPDFPassword:
            [self recentView_ClickTapAction];
            [self recentView_CancleSelectAction];
            [self top_setPdfPassword:password];
            break;
        case TOPMenuItemsFunctionShare://分享
            [self recent_SetLockShare:password];
            break;
        case TOPMenuItemsFunctionMerge://合并
            [self recent_SetLockMerge:password];
            break;
        case TOPMenuItemsFunctionCopyMove://移动
            [self recent_SetLockMove:password];
            break;
        case TOPMenuItemsFunctionDelete://删除
            [self recent_SetLockDelete:password];
            break;
        case TOPMenuItemsFunctionMore://更多
            [self recent_SetLockMore:password];
            break;
        case TOPMenuItemsFunctionRename://重命名
            [self recent_SetLockRename:password];
            break;
        case TOPMenuItemsFunctionPushVC://
            [self recent_SetLockPushChildVC:password];
            break;
            break;
        default:
            break;
    }
}
#pragma mark -- 设置pdf密码
- (void)top_setPdfPassword:(NSString *)password{
    [TOPScanerShare top_writePDFPassword:password];
    [[TOPCornerToast shareInstance] makeToast:[NSString stringWithFormat:@"%@ %@", [NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"],password]];
}
#pragma mark -- 有默认密码时设置密码
- (void)recent_SetLockagain:(NSString *)password{
    [FIRAnalytics logEventWithName:@"recent_SetLockagain" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self recentView_ClickTapAction];
        [self recent_WritePasswordToDoc:password];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 写入密码
- (void)recent_WritePasswordToDoc:(NSString *)password{
    [FIRAnalytics logEventWithName:@"recent_WritePasswordToDoc" parameters:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //将选中的数据放入selectArray
        NSMutableArray * selectArray = [NSMutableArray new];
        for (DocumentModel * homeModel in self.homeDataArray) {
            if (homeModel.selectStatus) {
                [selectArray addObject:homeModel];
            }
        }
        
        for (DocumentModel * docModel in selectArray) {
            if ([docModel.type isEqualToString:@"1"]) {
                NSString * docPasswordPath = docModel.docPasswordPath;
                if (docPasswordPath.length>0) {
                    NSArray * getArray = [docPasswordPath componentsSeparatedByString:TOP_TRDocPasswordPathString];
                    NSString * lastString = getArray.lastObject;
                    if (![lastString isEqualToString:password]) {//与默认密码不一致的就删除 然后重新写入
                        [TOPWHCFileManager top_removeItemAtPath:docPasswordPath];
                        [TOPDocumentHelper top_creatDocPasswordWithPath:docModel.path withPassword:password];
                    }
                }else{
                    [TOPDocumentHelper top_creatDocPasswordWithPath:docModel.path withPassword:password];//没有默认密码直接写入
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //写入完成之后给出密码提示
            [[TOPCornerToast shareInstance]makeToast:[NSString stringWithFormat:@"%@%@",[NSLocalizedString(@"topscan_colletiondocpasswordtitle", @"") stringByAppendingString:@":"],password]];
            [TOPScanerShare top_writeDocPasswordSave:password];
            [self recentView_CancleSelectAction];
            [self loadRecentData];
        });
    });
}
#pragma mark -- 有密码时的更多
- (void)recent_SetLockMore:(NSString *)password{
    [FIRAnalytics logEventWithName:@"recent_SetLockMore" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self recentView_ClickTapAction];
        [self recentView_EditMoreMethod];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的合并
- (void)recent_SetLockMerge:(NSString *)password{
    [FIRAnalytics logEventWithName:@"recent_SetLockMerge" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self recentView_ClickTapAction];
        [self recentView_MergeFileMethod];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的移动
- (void)recent_SetLockMove:(NSString *)password{
    [FIRAnalytics logEventWithName:@"recent_SetLockMove" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self recentView_ClickTapAction];
        [self recentView_EditFileMethod];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的分享
- (void)recent_SetLockShare:(NSString *)password{
    [FIRAnalytics logEventWithName:@"recent_SetLockShare" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self recentView_ClickTapAction];
        [self recentView_ShareTip];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的删除
- (void)recent_SetLockDelete:(NSString *)password{
    [FIRAnalytics logEventWithName:@"recent_SetLockDelete" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self recentView_ClickTapAction];
        [self recentView_DeleteTip];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的重命名
- (void)recent_SetLockRename:(NSString *)password{
    [FIRAnalytics logEventWithName:@"recent_SetLockRename" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self recentView_ClickTapAction];
        [self recentView_ClickToChangeFolderName];
    }else{
        [self top_writePasswordFail];
    }
}
- (void)recent_SetLockPushChildVC:(NSString *)password{
    [FIRAnalytics logEventWithName:@"recent_SetLockPushChildVC" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self recentView_ClickTapAction];
        [self top_clickDocPushChildVCWithPath];
    }else{
        [self top_writePasswordFail];
    }
}
- (void)top_writePasswordFail{
    if (self.isShowFailToast) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_writepasswordfail", @"") duration:1];
    }
}
#pragma mark --判断设置标签按钮的显示与不显示
- (NSInteger)top_judgeSetTagsState{
    NSInteger moreType = TOPHomeMoreFunctionTypeDefault;
    //将选中的数据放入selectArray
    NSMutableArray * selectArray = [NSMutableArray new];
    for (DocumentModel * homeModel in self.homeDataArray) {
        if (homeModel.selectStatus) {
            [selectArray addObject:homeModel];
        }
    }
    
    //遍历selectArray将document类型的数据放入documentArray
    NSMutableArray * documentArray = [NSMutableArray new];
    for (DocumentModel * docModel in selectArray) {
        if ([docModel.type isEqualToString:@"1"]) {
            [documentArray addObject:docModel];
        }
    }
    
    //遍历selectArray将folder类型的数据放入folderArray
    NSMutableArray * folderArray = [NSMutableArray new];
    for (DocumentModel * docModel in selectArray) {
        if ([docModel.type isEqualToString:@"0"]) {
            [folderArray addObject:docModel];
        }
    }
    //遍历documentArray将有密码数据放入tempArray
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * docModel in documentArray) {
        if (docModel.docPasswordPath.length>0) {
            [tempArray addObject:docModel];
        }
    }
    //选中了一个数据
    if (selectArray.count == 1) {
        if (documentArray.count == selectArray.count) {//选中的一个数据是doc文档
            if (tempArray.count == documentArray.count) {//文档有密码
                moreType = TOPHomeMoreFunctionTypeOneDocUnLock;
            }else{
                moreType = TOPHomeMoreFunctionTypeOneDocSetLock;
            }
        }else{//选中的一个数据是folder文件夹
            moreType= TOPHomeMoreFunctionTypeOneFolder;
        }
    }
    //选中多个数据
    if (selectArray.count>1) {
        if (documentArray.count == selectArray.count&&documentArray.count>0) {//选中的全是doc文档
            if (tempArray.count == documentArray.count) {//选中的文档都有密码
                moreType = TOPHomeMoreFunctionTypeSomeDocUnLock;
            }else{
                moreType = TOPHomeMoreFunctionTypeSomeDocSetLock;
            }
        }else if (folderArray.count == selectArray.count&&folderArray.count>0){//选中的全是folder文件夹
            moreType = TOPHomeMoreFunctionTypeSomeFolder;
        }else{//选中的既有doc文档又有folder文件夹
            moreType = TOPHomeMoreFunctionTypeFolderAndDoc;
        }
    }
    return moreType;
}

- (void)recentView_EditMoreMethod{
    [FIRAnalytics logEventWithName:@"recentView_EditMoreMethod" parameters:nil];
    [self.homeMoreArray removeAllObjects];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    WS(weakSelf);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger moreType = [self top_judgeSetTagsState];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray * titleArray = [NSArray new];
            NSArray * iconArray = [NSArray new];
            NSArray * moreArray = [NSArray new];
            NSString *passwordTitle = [[TOPScanerShare top_pdfPassword] length] ? NSLocalizedString(@"topscan_pdfpasswordclear", @"") : NSLocalizedString(@"topscan_pdfpassword", @"");
            if (moreType == TOPHomeMoreFunctionTypeSomeDocUnLock) {
                titleArray = @[NSLocalizedString(@"topscan_docpasswordunlockicon", @""),NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_ocr", @""),NSLocalizedString(@"topscan_savetogallery", @"")];
                iconArray = @[@"top_unlock",@"top_homemail",@"top_childvc_moreOCR",@"top_childvc_morepic"];
                moreArray = @[@(TOPHomeMoreFunctionUnLock),@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery)];
            }else if(moreType == TOPHomeMoreFunctionTypeSomeDocSetLock){
                titleArray = @[NSLocalizedString(@"topscan_docpasswordicon", @""),NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_ocr", @""),NSLocalizedString(@"topscan_savetogallery", @"")];
                iconArray = @[@"top_lock",@"top_homemail",@"top_childvc_moreOCR",@"top_childvc_morepic",];
                moreArray = @[@(TOPHomeMoreFunctionSetLock),@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery)];
            }else if(moreType == TOPHomeMoreFunctionTypeOneDocUnLock){//homeMoreDocRemind
                titleArray = @[NSLocalizedString(@"topscan_docpasswordunlockicon", @""),NSLocalizedString(@"topscan_editpdf", @""),NSLocalizedString(@"topscan_siderename", @""),NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_homemoredocremind", @""),NSLocalizedString(@"topscan_ocr", @""),NSLocalizedString(@"topscan_savetogallery", @""),passwordTitle];
                iconArray = @[@"top_unlock",@"top_editPDF",@"top_folderRename",@"top_homemail",@"top_childvc_morebell",@"top_childvc_moreOCR",@"top_childvc_morepic",@"top_menu_pdfPassword"];
                moreArray = @[@(TOPHomeMoreFunctionUnLock),@(TOPHomeMoreFunctionPDF),@(TOPHomeMoreFunctionDocRename),@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionDocRemaind),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery),@(TOPHomeMoreFunctionPDFPassword)];
            }else if(moreType == TOPHomeMoreFunctionTypeOneDocSetLock){
                titleArray = @[NSLocalizedString(@"topscan_docpasswordicon", @""),NSLocalizedString(@"topscan_editpdf", @""),NSLocalizedString(@"topscan_siderename", @""),NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_homemoredocremind", @""),NSLocalizedString(@"topscan_ocr", @""),NSLocalizedString(@"topscan_savetogallery", @""),passwordTitle];
                iconArray = @[@"top_lock",@"top_editPDF",@"top_folderRename",@"top_homemail",@"top_childvc_morebell",@"top_childvc_moreOCR",@"top_childvc_morepic",@"top_menu_pdfPassword"];
                moreArray = @[@(TOPHomeMoreFunctionSetLock),@(TOPHomeMoreFunctionPDF),@(TOPHomeMoreFunctionDocRename),@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionDocRemaind),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery),@(TOPHomeMoreFunctionPDFPassword)];
            }else if(moreType == TOPHomeMoreFunctionTypeFolderAndDoc){
                titleArray = @[NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_ocr", @""),NSLocalizedString(@"topscan_savetogallery", @"")];
                iconArray = @[@"top_homemail",@"top_childvc_moreOCR",@"top_childvc_morepic"];
                moreArray = @[@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery)];
            }else if(moreType == TOPHomeMoreFunctionTypeSomeFolder){
                titleArray = @[NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_ocr", @""),NSLocalizedString(@"topscan_savetogallery", @"")];
                iconArray = @[@"top_homemail",@"top_childvc_moreOCR",@"top_childvc_morepic"];
                moreArray = @[@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery)];
            }else if(moreType == TOPHomeMoreFunctionTypeOneFolder){
                titleArray = @[NSLocalizedString(@"topscan_siderename", @""),NSLocalizedString(@"topscan_email", @""),NSLocalizedString(@"topscan_ocr", @""),NSLocalizedString(@"topscan_savetogallery", @"")];
                iconArray = @[@"top_folderRename",@"top_homemail",@"top_childvc_moreOCR",@"top_childvc_morepic"];
                moreArray = @[@(TOPHomeMoreFunctionFolderRename),@(TOPHomeMoreFunctionEmail),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery)];
            }
            
            [self.homeMoreArray addObjectsFromArray:moreArray];
            
            DocumentModel * docModel = [DocumentModel new];
            if (self.selectedDocsIndexArray.count == 1) {
                docModel = self.selectedDocsIndexArray[0];
            }
            TOPChildMoreView * moreView = [[TOPChildMoreView alloc]initWithTitleView:[UIView new] optionsArr:titleArray iconArr:iconArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
            } selectBlock:^(NSInteger index) {
                NSNumber * num = weakSelf.homeMoreArray[index];
                [weakSelf recentView_ClickMoreViewAction:[num integerValue]];
            }];
            moreView.menuItems = moreArray;
            NSArray *menuItems = [self top_headMenuItems:moreType];
            moreView.docModel = docModel;
            moreView.headMenuItems = menuItems;
            moreView.showHeadMenu = YES;
            moreView.top_selectedHeadMenuBlock = ^(NSInteger item) {
                TOPHeadMenuModel *model = menuItems[item];
                [weakSelf recentView_ClickMoreViewAction:model.functionItem];
            };
            [window addSubview:moreView];
        });
    });
}

- (NSArray *)top_headMenuItems:(TOPHomeMoreFunctionType)moreType {
    BOOL showVip = NO;
    NSArray * headMenuItems = [NSArray new];
    if (moreType == TOPHomeMoreFunctionTypeSomeDocUnLock||moreType == TOPHomeMoreFunctionTypeSomeDocSetLock) {
        NSDictionary *dic1 = @{
            @"functionItem":@(TOPHomeMoreFunctionSetTags),
            @"title":NSLocalizedString(@"topscan_doctag", @""),
            @"iconName":@"top_menu_docTag",
            @"showVip":@(showVip)};
        showVip = ![TOPPermissionManager top_enableByUploadFile];
        NSDictionary *dic2 = @{
            @"functionItem":@(TOPHomeMoreFunctionUpload),
            @"title":NSLocalizedString(@"topscan_upload", @""),
            @"iconName":@"top_homeUpload",
            @"showVip":@(showVip)};
        showVip = NO;
        NSDictionary *dic3 = @{
            @"functionItem":@(TOPHomeMoreFunctionFax),
            @"title":NSLocalizedString(@"topscan_fax", @""),
            @"iconName":@"top_menu_fax_colorful",
            @"showVip":@(showVip)};
        headMenuItems = @[dic1,dic2,dic3];
        //        headMenuItems = @[dic1,dic3];
    }else if(moreType == TOPHomeMoreFunctionTypeOneDocUnLock||moreType == TOPHomeMoreFunctionTypeOneDocSetLock){
        NSDictionary *dic1 = @{
            @"functionItem":@(TOPHomeMoreFunctionSetTags),
            @"title":NSLocalizedString(@"topscan_doctag", @""),
            @"iconName":@"top_menu_docTag",
            @"showVip":@(showVip)};
        showVip = ![TOPPermissionManager top_enableByUploadFile];
        NSDictionary *dic2 = @{
            @"functionItem":@(TOPHomeMoreFunctionUpload),
            @"title":NSLocalizedString(@"topscan_upload", @""),
            @"iconName":@"top_homeUpload",
            @"showVip":@(showVip)};
        showVip = NO;
        NSDictionary *dic3 = @{
            @"functionItem":@(TOPHomeMoreFunctionPrint),
            @"title":NSLocalizedString(@"topscan_printing", @""),
            @"iconName":@"top_menu_print_colorful",
            @"showVip":@(showVip)};
        NSDictionary *dic4 = @{
            @"functionItem":@(TOPHomeMoreFunctionFax),
            @"title":NSLocalizedString(@"topscan_fax", @""),
            @"iconName":@"top_menu_fax_colorful",
            @"showVip":@(showVip)};
        showVip = ![TOPPermissionManager top_enableByCollageSave];
        NSDictionary *dic5 = @{
            @"functionItem":@(TOPHomeMoreFunctionPicCollage),
            @"title":NSLocalizedString(@"topscan_collage", @""),
            @"iconName":@"top_menu_collage",
            @"showVip":@(showVip)};
        headMenuItems = @[dic1,dic2,dic3,dic4,dic5];
        //        headMenuItems = @[dic1,dic3,dic4,dic5];
    }else if(moreType == TOPHomeMoreFunctionTypeFolderAndDoc||moreType == TOPHomeMoreFunctionTypeSomeFolder||moreType == TOPHomeMoreFunctionTypeOneFolder){
        showVip = ![TOPPermissionManager top_enableByUploadFile];
        NSDictionary *dic1 = @{
            @"functionItem":@(TOPHomeMoreFunctionUpload),
            @"title":NSLocalizedString(@"topscan_upload", @""),
            @"iconName":@"top_homeUpload",
            @"showVip":@(showVip)};
        showVip = NO;
        NSDictionary *dic2 = @{
            @"functionItem":@(TOPHomeMoreFunctionFax),
            @"title":NSLocalizedString(@"topscan_fax", @""),
            @"iconName":@"top_menu_fax_colorful",
            @"showVip":@(showVip)};
        headMenuItems = @[dic1,dic2];
        //        headMenuItems = @[dic2];
    }
    NSMutableArray *temp = @[].mutableCopy;
    for (NSDictionary *dic in headMenuItems) {
        TOPHeadMenuModel *item1 = [[TOPHeadMenuModel alloc] init];
        item1.functionItem = [dic[@"functionItem"] integerValue];
        item1.title = dic[@"title"];
        item1.iconName = dic[@"iconName"];
        item1.showVip = [dic[@"showVip"] boolValue];
        [temp addObject:item1];
    }
    return temp;
}
#pragma mark -- 底部更多视图点击
- (void)recentView_ClickMoreViewAction:(TOPHomeMoreFunction)functionType{
    [FIRAnalytics logEventWithName:@"recentView_ClickMoreViewAction" parameters:nil];
    switch (functionType) {
        case TOPHomeMoreFunctionSaveToGrallery:
            [self recentView_SaveToGalleryTip];
            break;
        case TOPHomeMoreFunctionPDF:
            [self top_jumpToEditPDFVC];
            break;
        case TOPHomeMoreFunctionFax:
            [self recentView_FaxTip];
            break;
        case TOPHomeMoreFunctionSetTags:
            [self recent_SetTag];
            break;
        case TOPHomeMoreFunctionSetLock:
            [self recent_SetLock];
            break;
        case TOPHomeMoreFunctionUnLock:
            [self recent_DocUnlock];
            break;
        case TOPHomeMoreFunctionEmail:
            self.emailType = 1;
            [self recentView_InvokeMenuFunctionAtIndex:TOPMenuItemsFunctionShare];
            break;
        case TOPHomeMoreFunctionFolderRename:
        case TOPHomeMoreFunctionDocRename:
            [self top_judgePasswordViewState:5];
            break;
        case TOPHomeMoreFunctionPDFPassword:
            [self top_showPdfSetView];
            break;
        case TOPHomeMoreFunctionUpload:
            [self recentView_uploadDrive];
            break;
        case TOPHomeMoreFunctionDownDriveFile:
            [self recentView_downDriveFile];
            break;
        case TOPHomeMoreFunctionPrint:
            [self top_homeMorePrintFunction];
            break;
        case TOPHomeMoreFunctionPicCollage:
            [self top_homeMoreCollage];
            break;
        case TOPHomeMoreFunctionOCR://文档识别
            if (![TOPDocumentHelper top_getSelectFolderDocPicState:self.homeDataArray]) {
                [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
                return;
            }
            [self top_shareText];
            [self recentView_CancleSelectAction];
            break;
        case TOPHomeMoreFunctionDocRemaind:
            [self recentView_setDocReminder];
            [self recentView_CancleSelectAction];
            break;
        default:
            break;
    }
}
#pragma mark -- 设置文档提醒
- (void)recentView_setDocReminder{
    [FIRAnalytics logEventWithName:@"recentView_setDocReminder" parameters:nil];
    DocumentModel * docModel = [DocumentModel new];
    if (self.selectedDocsIndexArray.count>0) {
        docModel = self.selectedDocsIndexArray[0];
    }
    TOPDocumentRemindVC * remindVC = [TOPDocumentRemindVC new];
    remindVC.docModel = docModel;
    remindVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
    remindVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:remindVC animated:YES];
}
#pragma mark -- 拼图
- (void)top_homeMoreCollage{
    [FIRAnalytics logEventWithName:@"top_homeMoreCollage" parameters:nil];
    WS(weakSelf);
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if ([model.type isEqual:@"1"]&&model.selectStatus) {
            [tempArray addObject:model];
        }
    }
    
    if (tempArray.count == 1) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //先生成pdf再打印
            //先清空pdf文件夹里的内容
            [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
            DocumentModel * printModel = tempArray[0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [self top_changeUpDownShowViewState];
                TOPCollageViewController *collageVC = [[TOPCollageViewController alloc] init];
                collageVC.filePath = printModel.path;
                collageVC.docModel = printModel;
                collageVC.top_backBtnAction = ^{
                    if ([TOPScanerShare shared].isEditing) {
                        [weakSelf recentView_ShowPressUpView];
                        [weakSelf recentView_RefreshViewWithSelectItem];
                    }
                };
                collageVC.top_finishBtnAction = ^{
                    if ([TOPScanerShare shared].isEditing) {
                        [weakSelf recentView_CancleSelectAction];
                        [self loadRecentData];
                    }
                };
                [self.navigationController pushViewController:collageVC animated:YES];
            });
        });
    }
}
- (void)top_changeUpDownShowViewState{
    [UIView animateWithDuration:0.3 animations:^{
        [self recentView_CancleSelectResetFream];
    } completion:^(BOOL finished) {
        [self.pressUpView  removeFromSuperview];
        [self.pressBootomView removeFromSuperview];
        [self.bottomView removeFromSuperview];
        self.pressBootomView = nil;
        self.pressUpView = nil;
        self.bottomView = nil;
    }];
}
#pragma mark -- 开始打印
- (void)top_homeMorePrintFunction{
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self top_dealPrintingData];
        }
    }];
}
- (void)top_dealPrintingData{
    [FIRAnalytics logEventWithName:@"homeMorePrintFunction" parameters:nil];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if ([model.type isEqual:@"1"]&&model.selectStatus) {
            [tempArray addObject:model];
        }
    }
    
    if (tempArray.count == 1) {
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //先生成pdf再打印
            //先清空pdf文件夹里的内容
            [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
            NSMutableArray * imgArray = [NSMutableArray new];
            NSString * pdfName = [NSString new];
            DocumentModel * printModel = tempArray[0];
            NSArray * picArray = [TOPDocumentHelper top_sortPicsAtPath:printModel.path];
            
            for (NSString * imgName in picArray) {
                UIImage * img = [UIImage imageWithContentsOfFile:[printModel.path stringByAppendingPathComponent:imgName]];
                if (img) {
                    [imgArray addObject:img];
                }
            }
            pdfName = [NSString stringWithFormat:@"%@-1",printModel.name];
            //合成pdf
            NSString * path = [TOPDocumentHelper top_creatNOPasswordPDF:imgArray documentName:pdfName progress:^(CGFloat myProgress) {
                [[TOPProgressStripeView shareInstance] top_showProgress:myProgress withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [self top_showPrintVC:path];
            });
        });
    }
}
#pragma mark -- 打印
- (void)top_showPrintVC:(NSString *)itemPath {
    NSData * imgData = [NSData dataWithContentsOfFile:itemPath];
    NSMutableArray * items = [NSMutableArray new];
    if (imgData) {
        [items addObject:imgData];
    }
    if (!items.count) {
        return;
    }
    UIPrintInteractionController * printVC = [UIPrintInteractionController sharedPrintController];
    if (printVC) {
        UIPrintInfo * printInfo = [UIPrintInfo printInfo];
        //打印输出类型
        printInfo.outputType = UIPrintInfoOutputGeneral;
        //默认应用程序名称
        printInfo.jobName = @"PDF";
        //双面打印信息，NONE为双面禁止
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        //打印纵向还是横向
        printInfo.orientation = UIPrintInfoOrientationPortrait;
        printVC.printInfo = printInfo;
        printVC.delegate = self;
        printVC.printingItems = items;
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                NSLog(@"FAILED! due to error in domain %@ with error code %lu", error.domain, error.code);
            }
        };
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [printVC presentFromRect:self.view.frame inView:self.view animated:YES completionHandler:completionHandler];
        }
        else {
            [printVC presentAnimated:YES completionHandler:completionHandler];
        }
    }
}

#pragma mark -- uploadDrive 上传第三方网盘
- (void)recentView_uploadDrive{
    if (![TOPDocumentHelper top_getSelectFolderDocPicState:self.homeDataArray]) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
        return;
    }
    [FIRAnalytics logEventWithName:@"recentView_uploadDrive" parameters:nil];
    TOPLoadSelectDriveViewController *uploadVC = [[TOPLoadSelectDriveViewController alloc] init];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if (model.selectStatus) {
            [tempArray addObject:model];
        }
    }
    uploadVC.uploadDatas = [NSMutableArray arrayWithArray:tempArray];
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:uploadVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- downloadDrive 下载第三方网盘
- (void)recentView_downDriveFile{
    [FIRAnalytics logEventWithName:@"recentView_downDriveFile" parameters:nil];
    TOPLoadSelectDriveViewController *uploadVC = [[TOPLoadSelectDriveViewController alloc] init];
    uploadVC.openDrivetype = TOPDriveOpenStyleTypeDownFile;
    uploadVC.downloadFileSavePath = [TOPDocumentHelper top_getDocumentsPathString];
    uploadVC.downloadFileType = TOPDownloadFileToDriveAddPathTypeHome;
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:uploadVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- 去订阅
- (void)top_subscriptionService {
    TOPSubscriptionPayListViewController * generalVC = [[TOPSubscriptionPayListViewController alloc] init];
    generalVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:generalVC animated:YES];
}
#pragma mark --设置pdf密码的弹出视图
- (void)top_showPdfSetView{
    [FIRAnalytics logEventWithName:@"EditPDFVC_pdfPassword" parameters:nil];
    if (![TOPPermissionManager top_enableByEmailMySelf]) {
        [self recentView_CancleSelectAction];
        [self top_subscriptionService];
        return;
    }
    NSString *pass = [TOPScanerShare top_pdfPassword];
    if ([pass length]) {//已经设置了密码
        [TOPScanerShare top_writePDFPassword:@""];
        [[TOPCornerToast shareInstance] makeToast:[NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"]];
    } else {
        //        [self top_showPasswordView];
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        if (!_coverView) {
            [keyWindow addSubview:self.coverView];
            [self top_markupCoverMask];
        }
        if (!_passwordView) {
            self.passwordView.actionType = TOPHomeMoreFunctionPDFPassword;
            [keyWindow addSubview:self.passwordView];
        }
    }
}
#pragma mark -- 清除doc文档密码
- (void)recent_DocUnlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (DocumentModel * selecModel in self.selectedDocsIndexArray) {
            if (selecModel.docPasswordPath.length>0) {
                [TOPWHCFileManager top_removeItemAtPath:selecModel.docPasswordPath];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_successfullyunlocked", @"")];
            [self recentView_CancleSelectAction];
            [self loadRecentData];
        });
    });
    
}
#pragma mark --设置密码
- (void)recent_SetLock{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    NSString * password = [TOPScanerShare top_docPassword];
    if (password.length == 0) {//保存本地的密码如果是空的 就重新全局遍历一次 看文档是不是有密码
        [SVProgressHUD show];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TOPDocumentHelper top_defaultPassword];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            NSString * defaultPassword = [TOPScanerShare top_docPassword];
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0);
            if (defaultPassword.length == 0) {
                self.passwordView.actionType = TOPHomeMoreFunctionSetLockFirst;
            }else{
                self.passwordView.actionType = TOPHomeMoreFunctionSetLock;
            }
            [keyWindow addSubview:self.coverView];
            [self top_markupCoverMask];
            [keyWindow addSubview:self.passwordView];
        });
    });
}
#pragma mark -- 设置标签
- (void)recent_SetTag{
    NSMutableArray * selectDocArray = [NSMutableArray new];
    [selectDocArray addObjectsFromArray:self.selectedDocsIndexArray];
    TOPSetTagViewController * tagVC = [[TOPSetTagViewController alloc]init];
    tagVC.dataArray = selectDocArray;
    tagVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tagVC animated:YES];
    [self recentView_CancleSelectAction];
}
#pragma mark -- 传真
- (void)recentView_FaxTip{
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self recentView_ShowFaxTip];
        }
    }];
}
- (void)recentView_ShowFaxTip{
    [FIRAnalytics logEventWithName:@"recentView_FaxTip" parameters:nil];
    if (![TOPDocumentHelper top_getSelectFolderDocPicState:self.homeDataArray]) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
        return;
    }
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self recentView_CalculateSelectNumber];
        CGFloat freeSize = [TOPDocumentHelper top_freeDiskSpaceInBytes];
        if (freeSize<self.totalSizeNum/1024.0/1024.0+5) {//判定手机存储空间大小够不够
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_storagespacenotenough", @"") duration:1];
            });
            return;
        }
        NSString * pdfName;
        NSMutableArray * editArray = [NSMutableArray new];
        for (NSString * pathString in [TOPDocumentHelper top_getSelectFolderPicture:self.homeDataArray]) {
            UIImage * img = [UIImage imageWithContentsOfFile:pathString];
            if (img) {
                [editArray addObject:img];
            }
        }
        
        for (DocumentModel * model in self.homeDataArray) {
            if (model.selectStatus) {
                pdfName = [NSString stringWithFormat:@"%@",model.name];
            }
        }
        [TOPDocumentHelper top_creatPDF:editArray documentName:pdfName pageSizeType:[TOPScanerShare top_pageSizeType] success:^(id  _Nonnull responseObj) {
            NSString * pdfPathString = responseObj;
            [TOPDocumentHelper top_jumpToSimpleFax:pdfPathString];
        }];
    });
}
#pragma mark-- 计算选中文件的大小
- (void)recentView_CalculateSelectNumber{
    [FIRAnalytics logEventWithName:@"recentView_CalculateSelectNumber" parameters:nil];
    //计算选中所有图片的大小
    CGFloat memorySize = [TOPDocumentHelper top_calculateSelectFilesSize:self.homeDataArray];//[TOPDocumentHelper top_totalMemorySize:tempPathArray];
    self.totalSizeNum = memorySize;
}
#pragma mark -- PDF预览
- (void)top_jumpToEditPDFVC{
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if ([model.type isEqual:@"1"]&&model.selectStatus) {
            [tempArray addObject:model];
        }
    }
    if (tempArray.count == 1) {
        [self recentView_CancleSelectAction];
        DocumentModel * printModel = tempArray[0];
        TOPEditPDFViewController * pdfVC = [[TOPEditPDFViewController alloc] init];
        pdfVC.docModel = printModel;
        pdfVC.filePath = printModel.path;
        pdfVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pdfVC animated:YES];
    }
}
#pragma mark-- 保存到Gallery文件夹
- (void)recentView_SaveToGalleryTip{
    [FIRAnalytics logEventWithName:@"recentView_SaveToGalleryTip" parameters:nil];
    NSArray * emailArray = [TOPDocumentHelper top_getSelectFolderPicture:self.homeDataArray];
    if (!emailArray.count) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
        return;
    }
    //保存
    WS(weakSelf);
    [TOPDocumentHelper top_saveImagePathArray:emailArray toFolder:TOPSaveToGallery_Path tipShow:YES showAlter:^(BOOL isExisted) {
        if (!isExisted) {
            [SVProgressHUD dismiss];
            [TOPDocumentHelper top_creatGalleryFolder:TOPSaveToGallery_Path];
            //提示框添加文本输入框
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_albumpermissiontitle", @"")
                                                                           message:NSLocalizedString(@"topscan_albumpermissionguide", @"")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_setting", @"") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                return;
            }];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * action) {
                return;
            }];
            [alert addAction:okAction];
            [alert addAction:cancelAction];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }
    }];
}
#pragma mark -- 合并
- (void)recentView_MergeFileMethod{
    [FIRAnalytics logEventWithName:@"recentView_MergeFileMethod" parameters:nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_mergefilemethodtitle", @"") message:nil preferredStyle:IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_mergefilemethodkeepold", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self recentView_MergeAndKeepOldFile];
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_mergefilemethoddeleteold", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self recentView_MergeAndDeleteOldFile];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    UIColor * titleColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor];
    [archiveAction setValue:titleColor forKey:@"_titleTextColor"];
    [otherAction setValue:titleColor forKey:@"_titleTextColor"];
    [alertController addAction:archiveAction];
    [alertController addAction:otherAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark -- 合并且保留原文件 等同于拷贝文件
- (void)recentView_MergeAndKeepOldFile{
    [FIRAnalytics logEventWithName:@"recentView_MergeAndKeepOldFile" parameters:nil];
    NSMutableArray *selectFiles = [self recentView_SelectFileArray];
    NSString *showTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(1-%@)",@(selectFiles.count)] : @"";
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_mergeing", @""),showTitle]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //创建合并后的文件
        NSString *docPaht = [TOPDocumentHelper top_getDocumentsPathString];
        NSString *mergerFilePath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:docPaht];
        //遍历选中的文件 逐个拷贝：
        for (int i = 0; i < selectFiles.count; i ++) {
            DocumentModel *model = selectFiles[i];
            NSString *progressTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(%@-%@)",@(i +1),@(selectFiles.count)] : @"";
            if (!i) {//第一个文件作为主文件，名称排序从这里开始，故一个文件中的图片不用改名称直接转移
                [TOPDocumentHelper top_copyFileItemsAtPath:model.path toNewFileAtPath:mergerFilePath progress:^(CGFloat copyProgressValue) {
                    [[TOPProgressStripeView shareInstance] top_showProgress:copyProgressValue withStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_mergeing", @""),progressTitle]];
                }];
            } else {//其他的作为副文件，名称排序接着前一个文件：如主文件最后一张图片是1005，那么这里从1006开始
                [TOPDocumentHelper top_writeNewPic:model.path toNewFileAtPath:mergerFilePath delete:NO progress:^(CGFloat copyProgressValue) {
                    [[TOPProgressStripeView shareInstance] top_showProgress:copyProgressValue withStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_mergeing", @""),progressTitle]];
                }];
            }
        }
        TOPAppDocument *appDoc = [TOPEditDBDataHandler top_addDocumentAtFolder:mergerFilePath WithParentId:@"000000"];
        [TOPFileDataManager shareInstance].docModel = [TOPDBDataHandler top_buildDocumentModelWithData:appDoc];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_mergesuccess", @"")];
            [SVProgressHUD dismissWithDelay:1];
            [self recentView_CancleSelectAction];
            [self recentView_JumpToHomeChildVC:mergerFilePath];
        });
    });
}
#pragma mark -- 合并且删除原文件 等同往主文件移动文件
- (void)recentView_MergeAndDeleteOldFile{
    [FIRAnalytics logEventWithName:@"recentView_MergeAndDeleteOldFile" parameters:nil];
    NSMutableArray *selectFiles = [self recentView_SelectFileArray];
    NSString *showTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(1-%@)",@(selectFiles.count)] : @"";
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_mergeing", @""),showTitle]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *mergerFilePath = @"";
        NSString *mainDocId = @"";
        //移动文件
        //遍历选中的文件 逐个转移：
        if (selectFiles.count) {//第一个文件作为主文件，名称排序从这里开始
            DocumentModel *mainDoc = selectFiles[0];
            mergerFilePath = mainDoc.path;
            mainDocId = mainDoc.docId;
        }
        for (int i = 0; i < selectFiles.count; i ++) {
            if (!i) {//第一个文件中的图片不用转移
                continue;
            }
            DocumentModel *model = selectFiles[i];
            NSString *progressTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(%@-%@)",@(i +1),@(selectFiles.count)] : @"";
            //其他的作为副文件，名称排序接着前一个文件：如主文件最后一张图片是1005，那么这里从1006开始
            NSMutableArray *newImages = [TOPDocumentHelper top_writeNewPic:model.path toNewFileAtPath:mergerFilePath delete:YES progress:^(CGFloat copyProgressValue) {
                [[TOPProgressStripeView shareInstance] top_showProgress:copyProgressValue withStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_mergeing", @""),progressTitle]];
            }];
            [TOPEditDBDataHandler top_batchEditImagePathWithId:model.docId toNewDoc:mainDocId withImageNames:newImages];
        }
        [TOPFileDataManager shareInstance].docModel = selectFiles[0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_mergesuccess", @"")];
            [SVProgressHUD dismissWithDelay:1];
            [self recentView_CancleSelectAction];
            [self recentView_JumpToHomeChildVC:mergerFilePath];
        });
    });
}
#pragma mark -- 跳转到文档详情界面
- (void)recentView_JumpToHomeChildVC:(NSString *)path {
    if (path.length) {
        [FIRAnalytics logEventWithName:@"recentView_JumpToHomeChildVC" parameters:@{@"path":path}];
        TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
        childVC.docModel = [TOPFileDataManager shareInstance].docModel;
        childVC.pathString = path;
        childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
        childVC.hidesBottomBarWhenPushed = YES;
        childVC.addType = @"add";
        childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
        childVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:childVC animated:YES];
    }
}
#pragma mark -- 移动
- (void)recentView_EditFileMethod{
    [FIRAnalytics logEventWithName:@"recentView_EditFileMethod" parameters:nil];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_graffitimoveto", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self recentView_MoveToFileSelect];
        [self recentView_CancleSelectResetFream];
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ocrtextcopy", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self recentView_CopyFileSelect];
        [self recentView_CancleSelectResetFream];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    UIColor * titleColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kBlackColor];
    [archiveAction setValue:titleColor forKey:@"_titleTextColor"];
    [otherAction setValue:titleColor forKey:@"_titleTextColor"];
    [alertController addAction:archiveAction];
    [alertController addAction:otherAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark -- 选择移动的终点文件夹
- (void)recentView_MoveToFileSelect {
    [FIRAnalytics logEventWithName:@"recentView_MoveToFileSelect" parameters:nil];
    __weak typeof(self) weakSelf = self;
    TOPFileTargetListViewController *targetListVC = [[TOPFileTargetListViewController alloc] init];
    targetListVC.currentFilePath = [self top_currentDocDirectoryAtPath];
    targetListVC.fileHandleType = TOPFileHandleTypeMove;
    targetListVC.fileTargetType = TOPFileTargetTypeFolder;
    __weak typeof(targetListVC) weakTargetListVC = targetListVC;
    targetListVC.top_callBackFilePathBlock = ^(NSString * _Nonnull path) {
        [weakTargetListVC dismissViewControllerAnimated:YES completion:nil];
        [weakSelf recentView_MoveToFileAtPath:path];
    };
    targetListVC.top_clickCancelBlock = ^{
        [weakSelf recentView_CancleSelectChangeFream];
    };
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:targetListVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- 当前文档的上级目录
- (NSString *)top_currentDocDirectoryAtPath {
    NSMutableArray *selectFile = @[].mutableCopy;
    NSMutableSet *selectParentId = [[NSMutableSet alloc] init];
    for (DocumentModel * model in self.homeDataArray) {
        if (model.selectStatus) {//过滤不同上级目录的文档
            TOPAppDocument *doc = [TOPDBQueryService top_appDocumentById:model.docId];
            [selectParentId addObject:doc.parentId];
            [selectFile addObject:model];
        }
    }
    NSString *currentFilePath = [TOPDocumentHelper top_getDocumentsPathString];
    if (selectParentId.count == 1) {//如果上级目录只有一个
        DocumentModel *model = selectFile.firstObject;
        currentFilePath = [TOPWHCFileManager top_directoryAtPath:model.path];
    }
    return currentFilePath;
}
#pragma mark -- 移动文件
- (void)recentView_MoveToFileAtPath:(NSString *)path {
    if (path.length) {
        [FIRAnalytics logEventWithName:@"recentView_MoveToFileAtPath" parameters:@{@"path":path}];
        //遍历选中的文件 逐个转移：
        NSMutableArray *selectFiles = [self recentView_SelectFileArray];
        NSString *showTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(1-%@)",@(selectFiles.count)] : @"";
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_moveprocessing", @""),showTitle]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *paths = @[].mutableCopy;
            NSMutableArray *moveFiles = @[].mutableCopy;//需要移动的文档
            for (int i = 0; i < selectFiles.count; i ++) {
                DocumentModel *model = selectFiles[i];
                if ([path isEqualToString:[TOPWHCFileManager top_directoryAtPath:model.path]]) {//目标跟目录和当前文档跟目录一致不需要移动
                    continue;
                }
                NSString * targetPath = [TOPDocumentHelper top_createNewDocument:model.name atFolderPath:path];
                NSString *progressTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(%@-%@)",@(i +1),@(selectFiles.count)] : @"";
                [TOPDocumentHelper top_moveFileItemsAtPath:model.path toNewFileAtPath:targetPath progress:^(CGFloat moveProgressValue) {
                    [[TOPProgressStripeView shareInstance] top_showProgress:moveProgressValue withStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_moveprocessing", @""),progressTitle]];
                }];
                [paths addObject:targetPath];
                [moveFiles addObject:model];
            }
            for (int i = 0; i < moveFiles.count; i ++) {
                DocumentModel *model = moveFiles[i];
                NSString *targetPath = paths[i];
                NSString *docName = [TOPWHCFileManager top_fileNameAtPath:targetPath suffix:YES];
                //修改文档路径id、父id、名称
                [TOPEditDBDataHandler top_editDocumentPath:docName withParentId:[TOPFileDataManager shareInstance].fileModel.docId withId:model.docId];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_movesuccess", @"")];
                [SVProgressHUD dismissWithDelay:1];
                [self recentView_CancleSelectAction];
                [self loadRecentData];
            });
        });
    }
}
#pragma mark -- 选择拷贝的终点文件夹
- (void)recentView_CopyFileSelect {
    [FIRAnalytics logEventWithName:@"recentView_CopyFileSelect" parameters:nil];
    __weak typeof(self) weakSelf = self;
    TOPFileTargetListViewController *targetListVC = [[TOPFileTargetListViewController alloc] init];
    targetListVC.currentFilePath = [TOPDocumentHelper top_getDocumentsPathString];
    targetListVC.fileHandleType = TOPFileHandleTypeCopy;
    targetListVC.fileTargetType = TOPFileTargetTypeFolder;
    __weak typeof(targetListVC) weakTargetListVC = targetListVC;
    targetListVC.top_callBackFilePathBlock = ^(NSString * _Nonnull path) {
        [weakTargetListVC dismissViewControllerAnimated:YES completion:nil];
        [weakSelf recentView_CopyFileAtPath:path];
    };
    targetListVC.top_clickCancelBlock = ^{
        [weakSelf recentView_CancleSelectChangeFream];
    };
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:targetListVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- 拷贝文件
- (void)recentView_CopyFileAtPath:(NSString *)path {
    if (path.length) {
        [FIRAnalytics logEventWithName:@"recentView_CopyFileAtPath" parameters:@{@"topath":path}];
        NSMutableArray *selectFiles = [self recentView_SelectFileArray];
        NSString *showTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(1-%@)",@(selectFiles.count)] : @"";
        [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_copyprocessing", @""),showTitle]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //遍历选中的文件 逐个拷贝：
            for (int i = 0; i < selectFiles.count; i ++) {
                DocumentModel *model = selectFiles[i];
                NSString * targetPath = [TOPDocumentHelper top_createNewDocument:model.name atFolderPath:path];
                NSString *progressTitle = selectFiles.count > 1 ? [NSString stringWithFormat:@"(%@-%@)",@(i +1),@(selectFiles.count)] : @"";
                [TOPDocumentHelper top_copyFileItemsAtPath:model.path toNewFileAtPath:targetPath progress:^(CGFloat copyProgressValue) {
                    [[TOPProgressStripeView shareInstance] top_showProgress:copyProgressValue withStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_copyprocessing", @""),progressTitle]];
                }];
                [TOPEditDBDataHandler top_copyDocument:model.docId atFolder:targetPath WithParentId:[TOPFileDataManager shareInstance].fileModel.docId];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TOPProgressStripeView shareInstance] dismiss];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_copysuccess", @"")];
                [SVProgressHUD dismissWithDelay:1];
                [self recentView_CancleSelectAction];
                [self loadRecentData];
            });
        });
    }
}
- (void)recentView_ShareTip{
    if (![TOPDocumentHelper top_getSelectFolderDocPicState:self.homeDataArray]) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
        return;
    }
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self recentView_ShareTipNew];
        }
    }];
}
#pragma mark -- 修改名称试图
- (void)recentView_ClickToChangeFolderName{
    [FIRAnalytics logEventWithName:@"recentView_ClickToChangeFolderName" parameters:nil];
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    self.coverView.backgroundColor = RGBA(51, 51, 51, 0);
    [keyWindow addSubview:self.coverView];
    [self top_markupCoverMask];
    [keyWindow addSubview:self.addFolderView];
    
    DocumentModel * renameModel = [DocumentModel new];
    for (DocumentModel * tempModel in self.homeDataArray) {
        if (tempModel.selectStatus) {
            renameModel = tempModel;
        }
    }
    if ([renameModel.type isEqualToString:@"0"]) {
        self.addFolderView.picName = @"top_wenjianjia_icon";
    }else{
        self.addFolderView.picName = @"top_docIcon";
    }
    self.addFolderView.tagsName = renameModel.name;
    self.folderViewType = FolderViewTypeChange;
}
#pragma mark -- 修改名称功能
- (void)recentView_ClickToChangeFolderNameAction:(NSString *)name{
    DocumentModel * renameModel = [DocumentModel new];
    for (DocumentModel * tempModel in self.homeDataArray) {
        if (tempModel.selectStatus) {
            renameModel = tempModel;
        }
    }
    
    for (DocumentModel * model in self.homeDataArray) {
        if ([model.type isEqual:renameModel.type]&&[model.name isEqualToString:name]) {
            //当编辑的文字和原来的文件夹名称相同时 不用给出提示
            if (![name isEqualToString:renameModel.name]) {
                [self recentView_FolderAlreadyAlert];
            }
            return;
        }
    }
    
    //修改的名字为空时 就不修改
    if (name.length == 0) {
        return;
    }
    [TOPDocumentHelper top_changeDocumentName:renameModel.path folderText:name];
    if ([renameModel.type isEqualToString:@"0"]) {
        [TOPEditDBDataHandler top_editFolderName:name withId:renameModel.docId];
    } else {
        [TOPEditDBDataHandler top_editDocumentName:name withId:renameModel.docId];
    }
    [self recentView_CancleSelectAction];
    [self loadRecentData];
}
- (void)recentView_FolderAlreadyAlert{
    [FIRAnalytics logEventWithName:@"recentView_FolderAlreadyAlert" parameters:nil];
    //提示框添加文本输入框
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_hasfolder", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}
#pragma mark -- 删除提示
- (void)recentView_DeleteTip{
    [FIRAnalytics logEventWithName:@"recentView_DeleteTip" parameters:nil];
    weakify(self);
    //提示框添加文本输入框
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_deleteoption", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [weakSelf recentView_deleteHandle];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark -- 执行删除操作
- (void)recentView_deleteHandle {
    if (self.selectedDocsIndexArray.count > 10) {
        [SVProgressHUD show];
    }
    weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *editArray = [NSMutableArray array];
        for (DocumentModel *model in  weakSelf.homeDataArray) {
            @autoreleasepool {
                if (!model.isAd) {
                    if (!model.selectStatus) {
                        [editArray addObject:model];
                    }else{
                        //如果有源文件的话也要删除掉
                        if ([model.type isEqualToString:@"0"]) {
                            [self recentView_deleteFolderToBin:model];
                        } else {
                            [self recentView_deleteDocumentToBin:model];
                        }
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            //删除了之后 没有图片处于选中状态 底部按钮是不能点击的
            NSArray * picArray = @[@"top_downview_disableshare",@"top_dissmissEmail",@"top_downview_dissmissSave",@"top_dissmissPrinting",@"top_downview_disabledelete"];
            [weakSelf.pressBootomView top_changePressViewBtnStatue:picArray enabled:NO];
            //选中数量为0
            [weakSelf.pressUpView top_configureSelectedCount:0];
            [weakSelf loadRecentData];
            if (editArray.count == 0) {
                weakSelf.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
            }
            [weakSelf recentView_CancleSelectAction];
            [self top_takeTipOfRecycleBin];
        });
    });
}

#pragma mark -- 移动文档到回收站
- (void)recentView_deleteDocumentToBin:(DocumentModel *)model {
    [TOPWHCFileManager top_removeItemAtPath:model.docPasswordPath];
    NSString *binDocPath = [TOPBinHelper top_moveDocumentToBin:model.path];
    RLMResults<TOPImageFile *> *images = [TOPDBQueryService top_imageFilesByParentId:model.docId];
    if (images.count) {
        TOPImageFile *img = images[0];
        [TOPBinEditDataHandler top_saddBinDocWithParentId:img.pathId atPath:binDocPath];
    }
    [TOPEditDBDataHandler top_deleteDocumentWithId:model.docId];
}

#pragma mark -- 移动文件夹到回收站
- (void)recentView_deleteFolderToBin:(DocumentModel *)model {
    NSString *binDocPath = [TOPBinHelper top_moveFolderToBin:model.path];
    [TOPBinEditDataHandler top_addFolderAtFile:binDocPath WithParentId:model.docId];
    [TOPEditDBDataHandler top_deleteFolderWithId:model.docId];
}

- (void)top_takeTipOfRecycleBin {
    BOOL tipRecycleBin = [[NSUserDefaults standardUserDefaults] boolForKey:@"tipRecycleBinKey"];
    if (!tipRecycleBin) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"tipRecycleBinKey"];
        
        WS(weakSelf);
        //提示框添加文本输入框
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"")
                                                                       message:NSLocalizedString(@"topscan_recyclebininstructions", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_longpresstip", @"") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_recyclebin", @"") style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
            [weakSelf recentView_RecycleBin];
        }];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark --- 回收站
- (void)recentView_RecycleBin {
    TOPBinHomeViewController *binHome = [[TOPBinHomeViewController alloc] init];
    binHome.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:binHome animated:YES];
}

- (void)recentView_ShareTipNew{
    NSMutableArray *shareDatas = [TOPShareFileDataHandler top_fetchShareFileData:[self removeAdModelArray]];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    WS(weakSelf);
    TOPShareFileView *shareFileView = [[TOPShareFileView alloc] initWithItemArray:shareDatas doneTitle:NSLocalizedString(@"topscan_share", @"") cancelBlock:^{
        
    } selectBlock:^(TOPShareFileModel * cellModel) {
        weakSelf.pdfType = cellModel.fileType;
        [weakSelf top_selectShareFileQuantity:cellModel];
    }];
    [window addSubview:shareFileView];
    [shareFileView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(window);
    }];
    self.shareFilePopView = shareFileView;
}
#pragma mark -- 选中分享图片的质量 文件大于1M时才会弹出
- (void)top_selectShareFileQuantity:(TOPShareFileModel *)cellModel {
    WS(weakSelf);
    float unitRate = 1024.0;
    float foldSize = cellModel.fileSize / (unitRate * unitRate);
    if (foldSize > 1) {//文件大于1M
        if (cellModel.fileType == TOPShareFilePDF || cellModel.fileType == TOPShareFileJPG) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            
            NSArray * titleArray = @[NSLocalizedString(@"topscan_originalsize", @""),NSLocalizedString(@"topscan_medium", @""),NSLocalizedString(@"topscan_small", @"")];
            if ([TOPScanerShare top_userDefinedFileSize] > 0) {
                titleArray = @[NSLocalizedString(@"topscan_originalsize", @""),NSLocalizedString(@"topscan_medium", @""),NSLocalizedString(@"topscan_small", @""),NSLocalizedString(@"topscan_userdefinedsize", @"")];
            }
            TOPShareDownSizeView * sizeView = [[TOPShareDownSizeView alloc]initWithTitleView:[UIView new] optionsArr:titleArray  cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
                
            } selectBlock:^(NSMutableArray * shareArray) {
                if (weakSelf.emailType == 1) {
                    [weakSelf recentView_EmailTip:shareArray];
                } else {
                    //分享功能
                    if (cellModel.isZip) {
                        [weakSelf top_shareZipFile:shareArray];
                    } else {
                        [weakSelf top_presentActivityVC:shareArray];
                    }
                }
            }];
            
            [window addSubview:sizeView];
            [sizeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.bottom.equalTo(window);
            }];
            NSMutableArray * tempArray = [NSMutableArray new];
            for (DocumentModel * model in weakSelf.homeDataArray) {
                if (model.selectStatus) {
                    [tempArray addObject:model];
                }
            }
            sizeView.compressType = cellModel.fileType;
            sizeView.dataArray = tempArray;
            sizeView.totalNum = cellModel.fileSize;
            sizeView.numberStr = [TOPDocumentHelper top_memorySizeStr:cellModel.fileSize];
        } else if (cellModel.fileType == TOPShareFileLongJPG) {
            [FIRAnalytics logEventWithName:@"recentView_ShareLongImage" parameters:nil];
            [weakSelf top_prejudgeImages];
        } else if (cellModel.fileType == TOPShareFileTxt) {
            [FIRAnalytics logEventWithName:@"recentView_shareText" parameters:nil];
            [weakSelf top_shareText];
            [weakSelf recentView_CancleSelectAction];
        }
    } else {
        if(cellModel.fileType == TOPShareFilePDF) {
            [SVProgressHUD show];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //pdf分享
                //先清空pdf文件夹里的内容
                [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
                NSArray * pathArray = [NSArray new];
                NSMutableArray * shareArray = [NSMutableArray new];
                //所有选中文件夹的图片集合
                //一个文件夹合成一张pdf图 多个文件夹合成多张pdf图片
                for (DocumentModel * model in weakSelf.homeDataArray) {
                    if (model.selectStatus) {
                        //每个文件夹的图片集合
                        NSMutableArray * imgArray = [NSMutableArray new];
                        //在folder文件夹下 获取图片
                        if ([model.type isEqualToString:@"0"]) {
                            NSMutableArray * documentArray = [NSMutableArray new];
                            //folder下的Documents文件夹中的所有文件夹的路径，图片都是存放在documents文件夹中的文件夹里的
                            NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:model.path documentArray:documentArray];
                            //遍历出文件夹路径
                            for (NSString * documentPath in getArry) {
                                //Documents文件夹下的文件夹里的图片名称集合 及路径下的图片名称集合
                                NSArray * documentArray = [TOPDocumentHelper top_getCurrentFileAndPath:documentPath];
                                for (NSString * picName in documentArray) {
                                    //拼接成图片路径 文件夹路径+图片名称=图片路径
                                    NSString * picPath = [documentPath stringByAppendingPathComponent:picName];
                                    UIImage * img = [UIImage imageWithContentsOfFile:picPath];
                                    if (img) {
                                        [imgArray addObject:img];
                                    }
                                }
                            }
                        }
                        
                        if ([model.type isEqualToString:@"1"]) {
                            //单个文件夹下的所有图片的名称集合
                            pathArray = [TOPDocumentHelper top_getCurrentFileAndPath:model.path];
                            for (NSString * pcStr in pathArray) {
                                NSString * fullPath = [NSString stringWithFormat:@"%@/%@",model.path,pcStr];
                                UIImage * img = [UIImage imageWithContentsOfFile:fullPath];
                                if (img) {
                                    [imgArray addObject:img];
                                }
                            }
                        }
                        //合成pdf图片
                        NSString * path = [TOPDocumentHelper top_creatPDF:imgArray documentName:model.name];
                        NSURL * file = [NSURL fileURLWithPath:path];
                        if (file) {
                            [shareArray addObject:file];
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (weakSelf.emailType == 1) {
                        [weakSelf recentView_EmailTip:shareArray];
                    }else{
                        //分享功能
                        [weakSelf top_presentActivityVC:shareArray];
                    }
                });
            });
        } else if(cellModel.fileType == TOPShareFileJPG){
            [SVProgressHUD show];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //直接图片分享
                NSMutableArray * shareArray = [NSMutableArray new];
                for (DocumentModel * model in weakSelf.homeDataArray) {
                    if (model.selectStatus) {
                        //在doc文件夹下 获取图片
                        if ([model.type isEqualToString:@"1"]) {
                            [shareArray addObjectsFromArray:[weakSelf top_getDocumentShareImgURL:model]];
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (weakSelf.emailType == 1) {
                        [weakSelf recentView_EmailTip:shareArray];
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //分享功能
                            [weakSelf top_presentActivityVC:shareArray];
                        });
                    }
                });
            });
        } else if(cellModel.fileType == TOPShareFileLongJPG) {
            [FIRAnalytics logEventWithName:@"recentView_ShareLongImage" parameters:nil];
            [weakSelf top_drawLongImagePreview];
        } else {
            [FIRAnalytics logEventWithName:@"recentView_shareText" parameters:nil];
            [weakSelf top_shareText];
            [weakSelf recentView_CancleSelectAction];
        }
    }
}
#pragma mark -- 分享图片时document文件夹下图片的url集合
- (NSMutableArray *)top_getDocumentShareImgURL:(DocumentModel *)model{
    NSArray * pathArray = [TOPDocumentHelper top_getCurrentFileAndPath:model.path];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (NSString * pcStr in pathArray) {
        NSString * nameIndex = [NSString stringWithFormat:@"%ld",[pathArray indexOfObject:pcStr]+1];
        NSString * docName = [model.path componentsSeparatedByString:@"/"].lastObject;
        NSString * savePath = [NSString stringWithFormat:@"%@_%@.jpg",docName,nameIndex];//保存压缩后的图片路的径最后一部分
        NSString * fullPath = [NSString stringWithFormat:@"%@/%@",model.path,pcStr];//原图片的路径
        NSString * compressFile = [NSString new];
        if (pathArray.count > 5) {
            compressFile = [TOPDocumentHelper top_saveCompressPDFImage:fullPath savePath:savePath maxCompression:1.0];
            
        }else{
            compressFile = [TOPDocumentHelper top_saveCompressImage:fullPath savePath:savePath maxCompression:1.0];
        }
        if (compressFile.length) {
            NSURL * file = [NSURL fileURLWithPath:compressFile];
            [tempArray addObject:file];
        }
    }
    return tempArray;
}
#pragma mark -- 选中的文件
- (NSMutableArray *)recentView_SelectFileArray {
    NSMutableArray *selectTempArray = [@[] mutableCopy];
    selectTempArray = [self.selectedDocsIndexArray mutableCopy];
    return selectTempArray;
}
#pragma mark -- 预判图片数量是否过多
- (void)top_prejudgeImages {
    static NSInteger maxNum = 30;//30张图片为界限
    NSMutableArray * imgArray = [[NSMutableArray alloc] init];
    for (DocumentModel * model in [self recentView_SelectFileArray]) {
        NSArray *images = @[];
        if ([model.type isEqualToString:@"1"]) {//doc下的图片
            images = [TOPDocumentHelper top_getJPEGFile:model.path];
        }
        for (NSString *content in images) {
            [imgArray addObject:content];
        }
    }
    if (imgArray.count >= maxNum) {
        [self top_phoneMemoryAlert];
    }else{
        [self top_drawLongImagePreview];
    }
}
- (void)top_phoneMemoryAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_note", @"")
                                                                   message:NSLocalizedString(@"topscan_phonememoryalert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_continueshare", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [self top_drawLongImagePreview];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark -- 合成长图并预览
- (void)top_drawLongImagePreview {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *imgArray = [TOPDataModelHandler top_selectedImageArray:[self recentView_SelectFileArray]];
        UIImage *resultImg = [TOPPictureProcessTool top_mergedImages:imgArray];
        NSString *showPath = [TOPDocumentHelper top_longImageFileString];
        [TOPDocumentHelper top_saveImage:resultImg atPath:showPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self recentView_CancleSelectAction];
            TOPShowLongImageViewController * longImgVC = [TOPShowLongImageViewController new];
            longImgVC.showPath = showPath;
            longImgVC.pathString = [TOPDocumentHelper top_getDocumentsPathString];
            longImgVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:longImgVC animated:YES];
        });
    });
}
#pragma mark -- 分享压缩文件
- (void)top_shareZipFile:(NSMutableArray *)shareArray {
    if ([self top_needCreateZip:shareArray]) {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *shareFiles = [self top_createZipWithShareFile:shareArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self top_presentActivityVC:shareFiles];
            });
        });
    } else {
        [self top_presentActivityVC:shareArray];
    }
}
#pragma mark -- 判断是否需要压缩
- (BOOL)top_needCreateZip:(NSMutableArray *)shareArray {
    BOOL createZip = NO;
    if (self.pdfType == 0) {//pdf 大于一张压缩
        if (shareArray.count > 1) {
            createZip = YES;
        }
    } else {
        if (shareArray.count > 9) {//图片大于9张压缩
            createZip = YES;
        }
    }
    return createZip;
}
#pragma mark -- 压缩需要分享的文件
- (NSMutableArray *)top_createZipWithShareFile:(NSMutableArray *)shareArray {
    NSMutableArray *shareFiles = @[].mutableCopy;
    NSString *zipFile = [TOPDocumentHelper top_getBelongTemporaryPathString:NSLocalizedString(@"topscan_sharezipname", @"")];
    NSMutableArray *zipPaths = @[].mutableCopy;
    for (NSURL *url in shareArray) {
        [zipPaths addObject:url.path];
    }
    BOOL successed = [SSZipArchive createZipFileAtPath:zipFile withFilesAtPaths:zipPaths];
    if (successed) {
        [shareFiles addObject:[NSURL fileURLWithPath:zipFile]];
    }
    return shareFiles;
}
#pragma mark -- 弹出系统分享界面
- (void)top_presentActivityVC:(NSMutableArray *)shareArray {
    UIActivityViewController * activiVC = [[UIActivityViewController alloc]initWithActivityItems:shareArray applicationActivities:nil];
    NSArray * excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    activiVC.excludedActivityTypes = excludedActivityTypes;
    if (IS_IPAD) {
        activiVC.popoverPresentationController.sourceView = self.view;
        activiVC.popoverPresentationController.sourceRect = CGRectMake(0, 0, 50, 10);
        activiVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController: activiVC animated:YES completion:nil];
}
#pragma mark -- 分享text 即文档的ocr识别
- (void)top_shareText{
    //选中的数据
    NSMutableArray * selectArray = [NSMutableArray new];
    for (DocumentModel * allModel in self.homeDataArray) {
        if (allModel.selectStatus) {
            [selectArray addObject:allModel];
        }
    }
    //获取选中文件夹中 所有document类型的文件夹路径
    NSMutableArray * documentArray = [NSMutableArray new];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * selectModel in selectArray) {
        if ([selectModel.type isEqual:@"1"]) {
            [documentArray addObject:selectModel];
        }else{
            NSMutableArray * getArry = [TOPDocumentHelper top_showAllFileWithPath:selectModel.path documentArray:tempArray];
            for (NSString * docPath in getArry) {
                DocumentModel *dtModel = [TOPDataModelHandler top_buildDocumentTargetModelWithPath:docPath];
                [documentArray addObject:dtModel];
            }
        }
    }
    //获取document类型文件夹下的数据 即与图片的数据
    NSMutableArray * childArray = [NSMutableArray new];
    for (DocumentModel * documentModel in documentArray) {
        NSMutableArray *dataArray = [TOPDataModelHandler top_buildDocumentSecondaryDataAtPath:documentModel.path];
        [childArray addObjectsFromArray:dataArray];
    }
    //将ocr识别过的图片和没有识别过的图片区分开
    NSMutableArray * ocrArray = [NSMutableArray new];
    for (DocumentModel * ocrModel in childArray) {
        if ([TOPWHCFileManager top_isExistsAtPath:ocrModel.ocrPath]) {
            [ocrArray addObject:ocrModel];
        }
    }
    
    NSLog(@"ocrArray==%ld childArray==%ld",ocrArray.count,childArray.count);
    if (ocrArray.count == childArray.count) {
        //所选图片都已经ocr识别过
        TOPPhotoShowTextAgainVC * ocrTextVC = [TOPPhotoShowTextAgainVC new];
        ocrTextVC.dataArray = ocrArray;
        ocrTextVC.backType = TOPPhotoShowTextAgainVCBackTypePopRoot;
        if (documentArray.count>1) {
            ocrTextVC.dataType = TOPOCRDataTypeMultipleDocument;
        }else{
            ocrTextVC.dataType = TOPOCRDataTypeSingleDocument;
        }
        ocrTextVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ocrTextVC animated:YES];
    }else{
        //进入ocr识别界面进行识别
        TOPPhotoShowOCRVC * ocrVC = [TOPPhotoShowOCRVC new];
        ocrVC.currentIndex = 0;
        ocrVC.dataArray = childArray;
        ocrVC.backType = TOPPhotoShowTextAgainVCBackTypePopRoot;
        ocrVC.ocrAgain = TOPPhotoShowOCRVCAgainTypeOCRNot;
        ocrVC.finishType = TOPPhotoShowOCRVCAgainFinishNot;
        if (documentArray.count>1) {
            ocrVC.dataType = TOPOCRDataTypeMultipleDocument;
        }else{
            ocrVC.dataType = TOPOCRDataTypeSingleDocument;
        }
        ocrVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ocrVC animated:YES];
    }
}

#pragma mark-- 发送email
- (void)recentView_EmailTip:(NSArray *)emailArray{
    if (emailArray.count) {
        [FIRAnalytics logEventWithName:@"recentView_EmailTip" parameters:@{@"emailArray":emailArray}];
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        
        if (!mailClass) {
            return;
        }
        
        if (![mailClass canSendMail]) {
            //提示框添加文本输入框
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_bind", @"")
                                                                           message:NSLocalizedString(@"topscan_bindcontent", @"")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
            }];
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        //设置界面保存的email数据
        self.emailModel = [NSKeyedUnarchiver unarchiveObjectWithFile:TOPSettingEmail_Path];
        [self recentView_ShowMailCompose:self.emailModel.toEmail array:emailArray];
    }
}
- (void)recentView_ShowMailCompose:(NSString *)email array:(NSArray *)emailArray{
    MFMailComposeViewController * mailCompose = [[MFMailComposeViewController alloc]init];
    mailCompose.mailComposeDelegate = self;
    NSArray * toRecipients = [NSArray arrayWithObjects:email,nil];
    [mailCompose setToRecipients:toRecipients];
    [mailCompose setSubject:self.emailModel.subject];
    [mailCompose setMessageBody:self.emailModel.body isHTML:YES];
    
    NSLog(@"emailArray==%@",emailArray);
    if (emailArray.count>0) {
        if (self.pdfType == 1) {
            for (int i = 0; i<emailArray.count; i++) {
                NSData * imgData = [NSData dataWithContentsOfURL:emailArray[i]];
                if (imgData) {
                    NSURL * imgPath = emailArray[i];
                    NSString * photoName = [TOPDocumentHelper top_decodeFromPercentEscapeString:[imgPath.absoluteString componentsSeparatedByString:@"/"].lastObject];
                    [mailCompose addAttachmentData:imgData mimeType:@"image" fileName:photoName];
                }
            }
            [self presentViewController:mailCompose animated:YES completion:^{
                
            }];
        }
        
        if (self.pdfType == 0) {
            for (int i = 0; i<emailArray.count; i++) {
                NSData * pdfData = [NSData dataWithContentsOfURL:emailArray[i]];
                if (pdfData) {
                    NSURL * pdfPath = emailArray[i];
                    NSString * photoName = [TOPDocumentHelper top_decodeFromPercentEscapeString:[pdfPath.absoluteString componentsSeparatedByString:@"/"].lastObject];
                    [mailCompose addAttachmentData:pdfData mimeType:@"application/pdf" fileName:photoName];
                }
            }
            [self presentViewController:mailCompose animated:YES completion:^{
                
            }];
        }
    }
}
#pragma mark -- 去掉原生广告之后的数据
- (NSMutableArray *)removeAdModelArray{
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {
        if (!model.isAd) {
            [tempArray addObject:model];
        }
    }
    return tempArray;
}
#pragma mark -- 跳转到childVC
- (void)top_clickDocPushChildVCWithPath{
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    childVC.docModel = self.docModel;
    childVC.pathString = self.docModel.path;
    childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
    childVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:childVC animated:YES];
}
#pragma mark -- 隐藏视图
- (void)recentView_ClickTapAction{
    [UIView animateWithDuration:0.3 animations:^{
        self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, TOPScreenHeight, AddFolder_W, AddFolder_H);
        self.addFolderView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, TOPScreenHeight, AddFolder_W, AddFolder_W);
    }completion:^(BOOL finished) {
        [self.addFolderView removeFromSuperview];
        [self.coverView removeFromSuperview];
        [self.passwordView removeFromSuperview];
        
        self.addFolderView = nil;
        self.coverView = nil;
        self.passwordView = nil;
    }];
}
#pragma mark -- 跳转到搜索界面
- (void)recentList_TopSearch{
    TOPSearchFileViewController * searchFileVC = [TOPSearchFileViewController new];
    searchFileVC.fatherDocModel = [TOPFileDataManager shareInstance].docModel;
    searchFileVC.pathString = [TOPDocumentHelper top_appBoxDirectory];
    searchFileVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchFileVC animated:NO];
}
#pragma mark -- 跳转到设置界面
- (void)recentList_TopSetting{
    TOPSettingViewController * setVC = [TOPSettingViewController new];
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:setVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- 跳转到购买会员
- (void)recentList_TopUpgradeVip{
    if ([TOPUserInfoManager shareInstance].isVip) {
        [self top_userVipDetail];
    }else{
        [self top_userUpGradeVip];
    }
}
#pragma mark -- 用户升级VIP
- (void)top_userUpGradeVip {
    TOPSubscriptionPayListViewController *subscriptVC = [[TOPSubscriptionPayListViewController alloc] init];
    subscriptVC.closeType = TOPSubscriptOverCloseTypeDissmiss;
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:subscriptVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark -- 用户订阅详情
- (void)top_userVipDetail{
    TOPUnlockFunctionViewController *functionVC = [[TOPUnlockFunctionViewController alloc] init];
    functionVC.isHiddenBottomSubScript = YES;
    functionVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:functionVC animated:YES];
}
- (void)recentList_TopViewWithType:(NSInteger)index{
    NSArray * topArray = [self recentList_TopArray];
    NSNumber * num = topArray[index];
    switch ([num integerValue]) {
        case TOPHomeVCTopHideViewStateBackup://备份与还原
            [self recentView_Backup];
            break;
        case TOPHomeVCTopHideViewStateImportPic://导入图片
            [self recentView_ImportPic];
            break;
        case TOPHomeVCTopHideViewStateSyntheticPDF://合并PDF
            [self recentView_SyntheticPDF];
            break;
        case TOPHomeVCTopHideViewStateImportDoc://导入图片
            [self recentView_ImportDoc];
            break;
        case TOPHomeVCTopHideViewStateFunctionMore:
            [self recentView_MoreFunction];
            break;
        default:
            break;
    }
}
#pragma mark -- 备份与还原
- (void)recentView_Backup{
    [FIRAnalytics logEventWithName:@"recentView_Backup" parameters:nil];
    TOPRestoreViewController * webVC = [TOPRestoreViewController new];
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark -- 导入图片
- (void)recentView_ImportPic{
    [FIRAnalytics logEventWithName:@"recentView_ImportPic" parameters:nil];
    NSArray *documentTypes = @[@"public.image"];
    [self top_getIcouldView:documentTypes];
}
#pragma mark -- 合并
- (void)recentView_SyntheticPDF{
    [FIRAnalytics logEventWithName:@"recentView_SyntheticPDF" parameters:nil];
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *dataArray = [TOPDBDataHandler top_buildHomeDataWithDB];//[TOPDataModelHandler buildHomeData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            TOPHomeTopMergeVC * mergeVC = [TOPHomeTopMergeVC new];
            mergeVC.addDocArray = dataArray;
            mergeVC.pathString = [TOPDocumentHelper top_appBoxDirectory];
            mergeVC.docModel = [TOPFileDataManager shareInstance].docModel;
            mergeVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:mergeVC animated:YES];
        });
    });
    /*
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * model in self.homeDataArray) {//去除原生广告模型
        if (!model.isAd) {
            [tempArray addObject:model];
        }
    }
    if (tempArray.count) {
        TOPHomeTopMergeVC * mergeVC = [TOPHomeTopMergeVC new];
        mergeVC.docModel = [TOPFileDataManager shareInstance].docModel;
        mergeVC.addDocArray = [tempArray mutableCopy];
        mergeVC.pathString = [TOPDocumentHelper top_appBoxDirectory];
        mergeVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:mergeVC animated:YES];
    }*/
}
#pragma mark -- 导入文档
- (void)recentView_ImportDoc{
    [FIRAnalytics logEventWithName:@"recentView_ImportDoc" parameters:nil];
    NSArray *documentTypes = @[@"public.image",@"com.adobe.pdf"];
    [self top_getIcouldView:documentTypes];
}

- (void)top_getIcouldView:(NSArray *)typeArray{
    //开启透明
    [[UINavigationBar appearance] setTranslucent:YES];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc]initWithDocumentTypes:typeArray inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle =  UIModalPresentationFullScreen;
    [self presentViewController:documentPicker animated:YES completion:nil];
}
- (void)recentView_MoreFunction{
    self.tabBarController.selectedIndex = 3;
    TOPMainTabBarController * tabVC = (TOPMainTabBarController *)self.tabBarController;
    TOPMainTabBar * tabbar = (TOPMainTabBar *)self.tabBarController.tabBar;
    tabVC.tabIndex = 4;
    tabbar.tabIndex = 4;
}
#pragma mark -- 取消选择
- (void)recentView_CancleSelectAction {
    [FIRAnalytics logEventWithName:@"recentView_CancleSelectAction" parameters:nil];
    [UIView animateWithDuration:0.3 animations:^{
        [self recentView_CancleSelectResetFream];
    } completion:^(BOOL finished) {
        [self.pressUpView  removeFromSuperview];
        [self.pressBootomView removeFromSuperview];
        [self.bottomView removeFromSuperview];
        self.pressBootomView = nil;
        self.pressUpView = nil;
        self.bottomView = nil;
    }];
    self.tabBarController.tabBar.hidden = NO;
    [self recentView_ShowHeaderView];
    //图片退出编辑状态
    [TOPScanerShare shared].isEditing = NO;
    //还原选中状态
    [self.selectedDocsIndexArray removeAllObjects];
    for (DocumentModel *model in self.homeDataArray) {
        model.selectStatus = NO;
    }
    self.tableView.listArray = self.homeDataArray;
    [self.tableView reloadData];
}
#pragma mark -- 全选
- (void)recentView_AllSelectAction:(BOOL)selected {
    [FIRAnalytics logEventWithName:@"recentView_AllSelectAction" parameters:@{@"select":@(selected)}];
    [self.selectedDocsIndexArray removeAllObjects];
    NSMutableArray *editArray = [NSMutableArray array];
    for (DocumentModel *model in  self.homeDataArray) {
        if (!model.isAd) {
            model.selectStatus = selected;
            if (selected) {
                [self.selectedDocsIndexArray addObject:model];
            }
        }
        [editArray addObject:model];
    }
    [self recentView_RefreshViewWithSelectItem];
    self.tableView.listArray = editArray;
    [self.tableView reloadData];
}
#pragma mark -- 根据选中的文件来刷新界面底部按钮状态
- (void)recentView_RefreshViewWithSelectItem {
    [FIRAnalytics logEventWithName:@"recentView_RefreshViewWithSelectItem" parameters:nil];
    [TOPScanerShare shared].isEditing = YES;
    //对选中的文档和文件夹计数
    NSInteger docCount = 0;
    NSInteger folderCount = 0;
    TOPItemsSelectedState selectedState = TOPItemsSelectedNone;
    NSMutableArray *selectedArray = [NSMutableArray array];
    for (DocumentModel *model in self.homeDataArray) {
        if (model.selectStatus == YES) {
            [selectedArray addObject:model];
            if ([model.type isEqualToString:@"1"]) {//doc
                docCount ++;
            }
            if ([model.type isEqualToString:@"0"]) {//folder
                folderCount ++;
            }
        }
    }
    //枚举选中文件情况
    if (!selectedArray.count) {
        selectedState = TOPItemsSelectedNone;
    } else {
        if (docCount == 1 && !folderCount) {
            selectedState = TOPItemsSelectedOneDoc;
        } else if (docCount > 1 && !folderCount) {
            selectedState = TOPItemsSelectedSomeDoc;
        } else if (folderCount == 1 && !docCount) {
            selectedState = TOPItemsSelectedOneFolder;
        } else if (folderCount > 1 && !docCount) {
            selectedState = TOPItemsSelectedSomeFolder;
        } else if (docCount == 1 && folderCount == 1) {
            selectedState = TOPItemsSelectedOneDoc | TOPItemsSelectedOneFolder;
        } else if (docCount == 1 && folderCount > 1) {
            selectedState = TOPItemsSelectedOneDoc | TOPItemsSelectedSomeFolder;
        } else if (docCount > 1 && folderCount == 1) {
            selectedState = TOPItemsSelectedSomeDoc | TOPItemsSelectedOneFolder;
        } else if (docCount > 1 && folderCount > 1) {
            selectedState = TOPItemsSelectedSomeDoc | TOPItemsSelectedSomeFolder;
        }
    }
    [self.pressUpView top_configureSelectedCount:selectedArray.count];
    if (selectedArray.count == [self removeAdModelArray].count) {
        self.pressUpView.allSelectBtn.selected = YES;
    }else{
        self.pressUpView.allSelectBtn.selected = NO;
    }
    [self.pressBootomView top_changePressViewBtnState:selectedState];
}

#pragma mark -- 长按开始编辑中文件时弹出菜单
- (void)recentView_ShowPressUpView{
    [FIRAnalytics logEventWithName:@"recentView_ShowPressUpView" parameters:nil];
    weakify(self);
    SS(strongSelf);
    weakSelf.tabBarController.tabBar.hidden = YES;
    [TOPScanerShare shared].isEditing = YES;
    [strongSelf recentView_HideHeaderView];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    if (!strongSelf.pressUpView) {
        strongSelf.pressUpView = [[TOPPhotoLongPressView alloc] initWithPressUpFrame:CGRectMake(0, -TOPNavBarAndStatusBarHeight, TOPScreenWidth, TOPNavBarAndStatusBarHeight)];
        //取消按钮
        strongSelf.pressUpView.top_cancleEditHandler = ^{
            [weakSelf recentView_CancleSelectAction];
        };
        
        //全选,取消全选
        strongSelf.pressUpView.top_selectAllHandler = ^(BOOL selected) {
            [weakSelf recentView_AllSelectAction:selected];
        };
        
        [window addSubview:strongSelf.pressUpView];
        [strongSelf.pressUpView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(window);
            make.top.equalTo(window).offset(-TOPNavBarAndStatusBarHeight);
            make.height.mas_equalTo(TOPNavBarAndStatusBarHeight);
        }];
    }
    
    if (!strongSelf.pressBootomView) {
        NSArray * sendPicArray = [strongSelf recentView_SendPicArray];
        NSArray * sendNameArray = [strongSelf recentView_SendNameArray];
        strongSelf.pressBootomView = [[TOPPhotoLongPressView alloc] initWithPressBottomFrame: CGRectMake(0, TOPScreenHeight, TOPScreenWidth, (60)) sendPicArray:sendPicArray sendNameArray:sendNameArray];
        strongSelf.pressBootomView.selectedImgs = [strongSelf recentView_SendPicArray];
        strongSelf.pressBootomView.disableImgs = [strongSelf recentView_PicArray];
        strongSelf.pressBootomView.funcArray = [strongSelf recentView_FuncItems];
        strongSelf.pressBootomView.top_longPressBootomItemHandler = ^(NSInteger index) {
            __weak typeof(self) weakSelf = self;
            weakSelf.emailType = 0;
            [weakSelf top_judgePasswordViewState:index];
        };
        [self.view addSubview:strongSelf.pressBootomView];
        [strongSelf.pressBootomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(Bottom_H);
            make.height.mas_equalTo(Bottom_H);
        }];
        
        UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, TOPScreenWidth, TOPBottomSafeHeight)];
        bottomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
        self.bottomView = bottomView;
        [self.view addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(TOPBottomSafeHeight);
            make.height.mas_equalTo(TOPBottomSafeHeight);
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self recentView_CancleSelectChangeFream];
        }];
    });
}

- (void)recentView_CancleSelectChangeFream{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [self.pressUpView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(window);
    }];
    if (!self.isBanner) {
        [self.pressBootomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        }];
    }else{
        [self.scBannerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        }];
        [self.pressBootomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
        }];
    }
    
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
    [window layoutIfNeeded];
    [self.view layoutIfNeeded];
}

- (void)recentView_CancleSelectResetFream{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    if ([window.subviews containsObject:self.pressUpView]&&[self.view.subviews containsObject:self.pressBootomView]&&[self.view.subviews containsObject:self.bottomView]) {
        [self.pressUpView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(window).offset(-TOPNavBarAndStatusBarHeight);
        }];
        if (!self.isBanner) {
            [self.pressBootomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view).offset(Bottom_H);
            }];
        }else{
            [self.scBannerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
            }];
            [self.pressBootomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view).offset(Bottom_H+self.adViewH+TOPBottomSafeHeight);
            }];
        }
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(TOPBottomSafeHeight);
        }];
        [window layoutIfNeeded];
        [self.view layoutIfNeeded];
    }
}
- (void)recentView_HideHeaderView{
    [UIView animateWithDuration:0.3 animations:^{
        if (!self.isBanner) {
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
            }];
        }else{
            [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H+self.adViewH));
            }];
        }
        [self.view layoutIfNeeded];
    }];
    [self.tableView reloadData];
}
- (void)recentView_ShowHeaderView{
    if (!self.isBanner) {
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self.view);
            make.top.equalTo(self.middleView.mas_bottom);
            make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight));
        }];
    }else{
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.middleView.mas_bottom);
            make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight+self.adViewH));
        }];
    }
    [self.tableView reloadData];
}
#pragma mark -- UIDocumentPickerDelegate
#pragma mark- iCloud Drive
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(nonnull NSArray<NSURL *> *)urls {
    //授权
    WS(weakSelf);
    BOOL fileAuthorized = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc]init]; NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) { //读取文件
            NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
            //            NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            NSData *fileData = [NSData dataWithContentsOfURL:newURL];
            if (error) {
                NSLog(@"读取错误error == %@",error);
            }else {
                NSLog(@"fileName: %@\nfileUrl: %@", fileName, newURL);
                if ([fileName hasSuffix:@".pdf"] || [fileName hasSuffix:@".PDF"]) {
                    CGPDFDocumentRef fromPDFDoc = CGPDFDocumentCreateWithURL((CFURLRef)newURL);
                    if (fromPDFDoc == NULL) {
                        NSLog(@"can't open '%@'", newURL); CFRelease((__bridge CFURLRef)newURL);
                    }else{
                        NSString * sendName = [NSString new];
                        if ([fileName hasSuffix:@".pdf"]) {
                            sendName = [[fileName componentsSeparatedByString:@".pdf"] firstObject];
                        }else{
                            sendName = [[fileName componentsSeparatedByString:@".PDF"] firstObject];
                        }
                        [weakSelf top_dealWithPDF:fromPDFDoc withPath:newURL alertTitle:NSLocalizedString(@"topscan_decryption", @"") alertMessage:@"pdf" fileName:sendName];
                    }
                }
                NSString * lowString = fileName.lowercaseString;
                if ([lowString hasSuffix:@".jpg"] || [lowString hasSuffix:@".png"]|| [lowString hasSuffix:@".jpeg"]) {
                    UIImage *photo = [UIImage imageWithData:fileData];
                    if (photo) {
                        NSString *endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
                        [weakSelf top_writeImageDataToDocument:photo withIndex:0 withPath:endPath];
                        [weakSelf top_icloudFinishAndPushWithPath:endPath];
                    }
                }
            }
        }];
    }
}
- (void)top_dealWithPDF:(CGPDFDocumentRef)fromPDFDoc withPath:(NSURL *)newURL alertTitle:(NSString *)title alertMessage:(NSString *)message fileName:(NSString *)fileName{
    if (CGPDFDocumentIsEncrypted (fromPDFDoc)) {//判断pdf是否加密
        WS(weakSelf);
        if (!CGPDFDocumentUnlockWithPassword (fromPDFDoc, "")) {//判断密码是否为""
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(alert) weakAlert = alert;
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                __strong typeof(weakAlert) strongAlert = weakAlert;
                
                UITextField *  textField=   strongAlert.textFields.firstObject;
                //去除textfieled的前后空格
                textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if (textField.text != NULL && CGPDFDocumentUnlockWithPassword (fromPDFDoc, [textField.text UTF8String])) {
                    //使用password对pdf进行解密，密码有效返回yes
                    [weakSelf top_pushSendControllerMothodWithPassword:textField.text withPath:fromPDFDoc fileName:fileName];
                }else{
                    [weakSelf top_dealWithPDF:fromPDFDoc withPath:newURL alertTitle:NSLocalizedString(@"topscan_error", @"") alertMessage:NSLocalizedString(@"topscan_pdferror", @"") fileName:fileName];
                }
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_skip", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                return;
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedString(@"topscan_placeholderpassword", @"");
            }];
            [alert addAction:cancelAction];
            
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }else{
        [self top_pushSendControllerMothodWithPassword:nil withPath:fromPDFDoc fileName:fileName];
    }
}

#pragma mark -- 倒入pdf的处理
- (void)top_pushSendControllerMothodWithPassword:(NSString *)passwordStr withPath:(CGPDFDocumentRef)fromPDFDoc fileName:(NSString *)fileName{
    NSString * endPath = [NSString new];
    if (fileName.length>0) {
        NSString *filePath = [[TOPDocumentHelper top_getDocumentsPathString] stringByAppendingPathComponent:fileName];
        endPath = [TOPDocumentHelper top_createDirectoryAtPath:filePath];
    }else{
        endPath = [TOPDocumentHelper top_createDefaultDocumentAtFolderPath:[TOPDocumentHelper top_getDocumentsPathString]];
    }
    
    WS(weakSelf);
    [[TOPProgressStripeView shareInstance]top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
    [TOPDocumentHelper top_getUIImageFromPDFPageWithpdfpathUrl:fromPDFDoc password:passwordStr docPath:endPath  progress:^(CGFloat progressString) {
        //拆分成pdf的进度条
        [[TOPProgressStripeView shareInstance]top_showProgress:progressString withStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_processing", @"")]];
    } success:^(id  _Nonnull responseObj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            [weakSelf top_icloudFinishAndPushWithPath:endPath];
        });
    }];
}
#pragma mark -- icloud图片写入doc文件夹
- (void)top_writeImageDataToDocument:(UIImage *)image withIndex:(NSInteger)index withPath:(NSString *)endPath{
    //创建文件夹[TOPDocumentHelper top_getDocumentsPathString] 并写入图片
    NSString *imgName  = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:index],TOP_TRJPGPathSuffixString];
    NSString *oriName = [NSString stringWithFormat:@"%@%@%@%@",TOPRSimpleScanOriginalString,[TOPDocumentHelper top_getFormatCurrentTime],[TOPDocumentHelper top_getFileNameNumber:index],TOP_TRJPGPathSuffixString];
    NSString *fileEndPath =  [endPath stringByAppendingPathComponent:imgName];
    NSString *oriEndPath = [endPath stringByAppendingPathComponent:oriName];
    [UIImageJPEGRepresentation(image,TOP_TRPicScale) writeToFile:fileEndPath atomically:YES];
    [UIImageJPEGRepresentation(image,TOP_TRPicScale) writeToFile:oriEndPath atomically:YES];
}

#pragma mark -- icloud处理完成之后的跳转
- (void)top_icloudFinishAndPushWithPath:(NSString *)endPath{
    DocumentModel *model = [TOPDBDataHandler top_addNewDocModel:endPath];
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    childVC.docModel = model;
    childVC.pathString = endPath;
    childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
    childVC.addType = @"add";
    childVC.backType = TOPHomeChildViewControllerBackTypePopVC;
    childVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:childVC animated:YES];
}

#pragma mark -- Send feedback
- (void)top_settingView_SendFeedback{
    [FIRAnalytics logEventWithName:@"settingView_SendFeedback" parameters:nil];
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        return;
    }
    if (![mailClass canSendMail]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_bind", @"")
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
#pragma mark -- 原生广告
- (void)top_getNativeAd{
    NSString * adID = @"ca-app-pub-3940256099942544/3986624511";
    /*
    if ([TOPScanerShare top_listType] == ShowTwoGoods) {
        adID = [TOPDocumentHelper top_nativeAdID][0];
    }else if([TOPScanerShare top_listType] == ShowThreeGoods){
        adID = [TOPDocumentHelper top_nativeAdID][1];
    }else if([TOPScanerShare top_listType] == ShowListGoods){
        adID = [TOPDocumentHelper top_nativeAdID][2];
    }*/
    adID = [TOPDocumentHelper top_nativeAdID][2];
    GADMultipleAdsAdLoaderOptions *multipleAdsOptions = [[GADMultipleAdsAdLoaderOptions alloc] init];
    multipleAdsOptions.numberOfAds = 1;
    
    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
    videoOptions.startMuted = YES ;
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:adID
                                       rootViewController:self
                                                  adTypes:@[kGADAdLoaderAdTypeNative]
                                                  options:@[multipleAdsOptions,videoOptions]];
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:[GADRequest request]];
    
}
- (void)adLoaderDidFinishLoading:(GADAdLoader *) adLoader {
    // The adLoader has finished loading ads, and a new request can be sent.
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error{
}
#pragma mark -- 获取原生广告成功
- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    [FIRAnalytics logEventWithName:@"recentView_nativeDidReceiveAd" parameters:nil];
    NSLog(@"nativeAd==%@ images==%@",nativeAd,nativeAd.images);
    DocumentModel * nativeAdModel = [DocumentModel new];
    nativeAdModel.adModel = nativeAd;
    nativeAdModel.isAd = YES;
    self.nativeAdModel = nativeAdModel;
    [self top_adReceiveFinishAndRefreshUI];
    [self top_sumAllFileSize];//显示文件大小的lab
    [self.tableView reloadData];
}
#pragma mark -- 原生广告接收完成并刷新UI
- (void)top_adReceiveFinishAndRefreshUI {
    if (self.nativeAdModel) {
        NSInteger adIndex = 0;
        if (self.navADIndex) {
            if (self.navADIndex>self.homeDataArray.count) {//如果广告在列表的最后一个 当删除doc文档时self.navADIndex会比
                self.navADIndex = self.homeDataArray.count;
            }
            adIndex = self.navADIndex;
        }else{
            adIndex = [TOPDocumentHelper top_adMobIndexWithListType:ShowListGoods byItemCount:self.homeDataArray.count];
            self.navADIndex = adIndex;
        }
        [self.homeDataArray insertObject:self.nativeAdModel atIndex:adIndex];
        self.tableView.listArray = self.homeDataArray;
    }
}
#pragma mark -- 加载横幅广告
- (void)top_changeBannerViewFream:(CGSize)size{
    if (![TOPPermissionManager top_enableByAdvertising]) {//不是会员，要展示广告
        if (!self.isBanner) {//横幅没有加载过
            [self top_previewView_AddBannerViewWithSize:size];
        }
    } else {//是会员移除横幅广告
        [self top_removeBannerView];
        [self top_changeTabFreamWhenBannerFail];
    }
}
#pragma mark -- 隐藏横幅广告视图
- (void)top_removeBannerView{
    [self top_changeTabFreamWhenBannerFail];
    [self.scBannerView removeFromSuperview];
    self.scBannerView = nil;
    self.isBanner = NO;
}
#pragma mark -- 横幅广告
- (void)top_previewView_AddBannerViewWithSize:(CGSize)currentSize{
    GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(currentSize.width);
    self.adViewH = adSize.size.height;
    NSString * adID = @"ca-app-pub-3940256099942544/2934735716";
    adID = [TOPDocumentHelper top_bannerAdID][0];
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
        make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
    }];
}
#pragma mark -- 获取横幅广告成功
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView{
    [FIRAnalytics logEventWithName:@"recentView_bannerReceiveAd" parameters:nil];
    if (bannerView) {
        bannerView.hidden = NO;
        self.isBanner = YES;
        [self top_changeTabFreamWhenBannerSuccess];
        [self top_sumAllFileSize];
    }
}
#pragma mark -- 获取横幅广告失败
- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"error==%@",error);
    [self top_changeTabFreamWhenBannerFail];
    [self top_sumAllFileSize];
    self.isBanner = NO;
    bannerView.hidden = YES;
}
- (void)top_changeTabFreamWhenBannerSuccess{
    if ([TOPScanerShare shared].isEditing == YES) {
        [self.pressBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+self.adViewH));
            make.height.mas_equalTo(60);
        }];
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H+self.adViewH));
        }];
        [self.scBannerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
        }];
    }else{
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.middleView.mas_bottom);
            make.bottom.equalTo(self.view).offset(-(TOPTabBarHeight+self.adViewH));
        }];
    }
}
- (void)top_changeTabFreamWhenBannerFail{
    if ([TOPScanerShare shared].isEditing == YES) {
        [self.pressBootomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOPBottomSafeHeight);
            make.height.mas_equalTo(60);
        }];
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-(TOPBottomSafeHeight+Bottom_H));
        }];
    }else{
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.middleView.mas_bottom);
            make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
        }];
    }
}
#pragma mark -- 编辑选中文件时 底部菜单的数据源
- (NSArray *)recentView_SendPicArray {
    NSArray * temp = @[@"top_downview_share",@"top_downview_merge",@"top_downview_copyFile",@"top_downview_selectdelete",@"top_downview_moreFun"];//,@"top_downview_moreFun"
    return temp;
}

- (NSArray *)recentView_PicArray {
    NSArray * temp = @[@"top_downview_disableshare",@"top_downview_disablemerge",@"top_downview_disablecopy",@"top_downview_disabledelete",@"top_downview_disablemorefun"];//,@"top_downview_disablemorefun"
    return temp;
}

- (NSArray *)recentView_FuncItems {
    NSArray * temp = @[@(TOPMenuItemsFunctionShare),@(TOPMenuItemsFunctionMerge),@(TOPMenuItemsFunctionCopyMove),@(TOPMenuItemsFunctionDelete),@(TOPMenuItemsFunctionMore),@(TOPMenuItemsFunctionRename)];//,@(TOPMenuItemsFunctionMore)
    return temp;
}

- (NSArray *)recentView_SendNameArray {//
    NSArray * temp = @[NSLocalizedString(@"topscan_share", @""),NSLocalizedString(@"topscan_merge", @""),NSLocalizedString(@"topscan_copy", @""),NSLocalizedString(@"topscan_delete", @""),NSLocalizedString(@"topscan_more", @"")];//,NSLocalizedString(@"topscan_more", @"")
    return temp;
}
- (NSArray *)recentList_TopArray{
    NSArray * hideArray = @[@(TOPHomeVCTopHideViewStateBackup),@(TOPHomeVCTopHideViewStateImportPic),@(TOPHomeVCTopHideViewStateSyntheticPDF),@(TOPHomeVCTopHideViewStateImportDoc),@(TOPHomeVCTopHideViewStateFunctionMore)];
    return hideArray;
}
#pragma mark --顶部视图
- (TOPTopHideView *)topHideView{
    if (!_topHideView) {
        WS(weakSelf);
        _topHideView = [[TOPTopHideView alloc]init];
//        _topHideView.backgroundColor = TOPAppBackgroundColor;
        _topHideView.top_topViewAction = ^(NSInteger index) {
            [weakSelf recentList_TopViewWithType:index];
        };
    }
    return _topHideView;
}
- (TOPHomePageHeaderView *)setMyHomeHeaderView{
    WS(weakSelf);
    TOPHomePageHeaderView * homeHeaderView = [[TOPHomePageHeaderView alloc]init];
    homeHeaderView.backgroundColor = [UIColor clearColor];
    homeHeaderView.top_DocumentHeadClickHandler = ^(NSInteger index, BOOL selected) {
        switch (index) {
            case 0:
                [weakSelf recentList_TopSearch];
                break;
            case 1:
                [weakSelf recentList_TopSetting];
                break;
            case 2:
                [weakSelf recentList_TopUpgradeVip];
                break;
            default:
                break;
        }
    };
    return homeHeaderView;
}
- (SCRecentHeadView *)middleView{
    if (!_middleView) {
        WS(weakSelf);
        _middleView = [SCRecentHeadView new];
        _middleView.selectAllItem = ^{
            [weakSelf recentView_ShowPressUpView];
            [weakSelf recentView_RefreshViewWithSelectItem];
            [weakSelf.tableView reloadData];
        };
    }
    return _middleView;
}
- (TOPDocumentTableView *)tableView{
    if (!_tableView) {
        weakify(self);
        _tableView = [[TOPDocumentTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.isShowHeaderView = NO;
        _tableView.isFromSecondFolderVC = NO;
        _tableView.top_DocumentHomeHandler = ^(NSInteger index,BOOL selected) {
//            [weakSelf recentView_PresentPopViewWithType:index selected:selected];
        };
        _tableView.top_pushNextControllerHandler = ^(DocumentModel * model) {
            if ([model.type isEqualToString:@"0"]) {
//                [weakSelf top_jumpToNextFolderVC:model];
            }else{
                weakSelf.docModel = model;
                [weakSelf top_judgeClickDocPasswordState];
            }
        };
        
        _tableView.top_longPressEditHandler = ^(NSIndexPath * _Nonnull idxPath){
            [weakSelf recentView_ShowPressUpView];
        };
        //记录文件选中先后顺序
        _tableView.top_longPressCheckItemHandler = ^(NSInteger index, BOOL selected) {
            DocumentModel *model = weakSelf.homeDataArray[index];
            if (!model.isAd) {
                model.selectStatus = selected;
                if (selected) {
                    [weakSelf.selectedDocsIndexArray addObject:model];
                } else {
                    [weakSelf.selectedDocsIndexArray removeObject:model];
                }
            }
        };
        _tableView.top_longPressCalculateSelectedHander = ^{
            [weakSelf recentView_RefreshViewWithSelectItem];
        };
        
        //侧滑分享
        _tableView.top_clickSideToShare = ^ {
            weakSelf.emailType = 0;
            [weakSelf top_judgePasswordViewState:0];
        };
        
        //侧滑发送Email
        _tableView.top_clickSideToEmail = ^{
            weakSelf.emailType = 1;
            [weakSelf top_judgePasswordViewState:0];
        };
        
        //侧滑重命名
        _tableView.top_clickSideToRename = ^{
            [weakSelf top_judgePasswordViewState:5];
        };
        
        //侧滑点击删除
        _tableView.top_clickSideToDelete = ^{
            [weakSelf top_judgePasswordViewState:3];
        };
        _tableView.top_didScrolInBottom = ^(BOOL isBottom) {
            weakSelf.fileSizeLab.hidden = !isBottom;
        };
        [_tableView addGestureRecognizer];
    }
    return _tableView;
}
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(recentView_ClickTapAction)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}
- (TOPAddFolderView *)addFolderView{
    if (!_addFolderView) {
        WS(weakSelf);
        _addFolderView = [[TOPAddFolderView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolder_W)];
        _addFolderView.top_clickToSendString = ^(NSString * _Nonnull editString) {
            [weakSelf recentView_ClickToChangeFolderNameAction:editString];
            [weakSelf recentView_ClickTapAction];
        };
        
        _addFolderView.top_clickToHide = ^{
            [weakSelf recentView_ClickTapAction];
        };
    }
    return _addFolderView;
}
#pragma mark -- 密码弹框
- (TOPDocPasswordView *)passwordView{
    if (!_passwordView) {
        WS(weakSelf);
        _passwordView = [[TOPDocPasswordView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolderSingle_H)];
        _passwordView.top_sendPassword = ^(NSString * _Nonnull password, NSInteger actionType,BOOL isShowFailToast) {
            weakSelf.isShowFailToast = isShowFailToast;
            [weakSelf top_passwordViewActionWithPassword:password WithType:actionType];
        };
        _passwordView.top_clickToHide = ^{
            [weakSelf recentView_ClickTapAction];
        };
        
        _passwordView.top_clickToHelp = ^{
            [weakSelf top_settingView_SendFeedback];
        };
    }
    return _passwordView;
}
- (NSMutableArray *)selectedDocsIndexArray {
    if (!_selectedDocsIndexArray) {
        _selectedDocsIndexArray = [@[] mutableCopy];
    }
    return _selectedDocsIndexArray;
}

- (NSMutableArray*)homeDataArray{
    if (!_homeDataArray) {
        _homeDataArray = [NSMutableArray array];
    }
    return _homeDataArray;
}
- (NSMutableArray*)homeMoreArray{
    if (!_homeMoreArray) {
        _homeMoreArray = [NSMutableArray new];
    }
    return _homeMoreArray;
}
#pragma mark -- lazy
- (UIView *)contentFatherView {
    if (!_contentFatherView) {
        _contentFatherView = [[UIView alloc] init];
        _contentFatherView.backgroundColor = [UIColor clearColor];
    }
    return _contentFatherView;
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
#pragma mark --UI 布局界面
- (void)top_setupNavBar {
    TOPHomePageHeaderView * homeHeaderView = [self setMyHomeHeaderView];
    self.navigationItem.titleView = homeHeaderView;
    [homeHeaderView top_setupUI];
}
- (void)top_setupUI{
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    [self.view addSubview:self.topHideView];
    [self.view addSubview:self.middleView];
    [self.view addSubview:self.contentFatherView];
    [self.contentFatherView addSubview:self.tableView];
    [self.contentFatherView addSubview:self.fileSizeLab];

    [self.topHideView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    [self.middleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.topHideView.mas_bottom).offset(-10);
        make.height.mas_equalTo(50);
    }];
    [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.middleView.mas_bottom);
        make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
    }];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentFatherView);
    }];
    [self.fileSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentFatherView);
        make.height.mas_equalTo(30);
    }];
}
#pragma mark -- 设置约束
- (void)top_markupCoverMask{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
