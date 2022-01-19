//
//  SCLastPreviewViewController.m
//  SimpleScan
//
//  Created by admin3 on 2021/8/31.
//  Copyright © 2021 admin3. All rights reserved.
//
#define AddFolder_W 310
#define AddFolder_H 240
#define AddFolderSingle_H 190

#import "SCRecentPreviewViewController.h"
#import "TOPHomeChildViewController.h"
#import "TOPPhotoShowTextAgainVC.h"
#import "TOPShowLongImageViewController.h"
#import "TOPSetTagViewController.h"
#import "TOPHomeChildBatchViewController.h"
#import "TOPSettingViewController.h"
#import "TOPLoadSelectDriveViewController.h"

#import "SCMainPreviewView.h"
#import "TOPTopHideView.h"
#import "TOPHomePageHeaderView.h"
#import "TOPShareFileDataHandler.h"
#import "TOPShareFileView.h"
#import "TOPShareFileModel.h"
#import "TOPShareDownSizeView.h"
#import "TOPSettingEmailAgainView.h"
#import "TOPChildMoreView.h"
#import "TOPHeadMenuModel.h"
#import "TOPAddFolderView.h"
@interface SCRecentPreviewViewController ()<GADBannerViewDelegate,UIPrintInteractionControllerDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) UIView * coverView;//覆盖层
@property (nonatomic, strong) TOPSettingEmailAgainView * emailAgainView;
@property (nonatomic, strong) TOPDocPasswordView * passwordView;//密码弹框
@property (nonatomic, strong) SCMainPreviewView * mainView;
@property (nonatomic, strong) GADBannerView * scBannerView;//横幅广告
@property (nonatomic, assign) BOOL isBanner;//YES表示获取banner广告成功 默认值为NO
@property (nonatomic, strong) DocumentModel * lastModel;
@property (nonatomic, assign) BOOL isShowFailToast;//密码错误时是否弹出提示
@property (nonatomic, assign) NSInteger pdfType;//当是email分享时 判断是分享的pdf还是图片 0是pdf 1是图片
@property (nonatomic, assign) NSInteger emailType;//判断是不是分享类型 0为share 1为email 2为more里的shareMyself
@property (nonatomic, strong) TOPShareFileView *shareFilePopView;
@property (nonatomic, strong) TOPAddFolderView * addFolderView;
@property (nonatomic, strong) TOPSettingEmailModel * emailModel;
@property (nonatomic, assign) CGFloat  totalSizeNum;//选中文件大小
@property (nonatomic, strong) NSMutableArray  *emailArray;
@end

@implementation SCRecentPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    [self top_setupUI];
//    [self loadAllData];
    [self top_restoreBannerAD:self.view.size];//横幅广告
}

- (void)top_setupUI{
    UIImageView * backImg = [UIImageView new];
    backImg.image = [UIImage imageNamed:@"top_last_backImg"];
    [self.view addSubview:backImg];
    [self.view addSubview:self.mainView];
    self.mainView.hidden = YES;
    [backImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-(44+TOPBottomSafeHeight));
        make.size.mas_equalTo(CGSizeMake(115, 102));
    }];
    [self.mainView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TOPTabBarHeight);
    }];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    //关闭透明
    [[UINavigationBar appearance] setTranslucent:NO];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lastView_GetCamera) name:TOP_TRCenterBtnGetCamera object:nil];
    //监听键盘，键盘出现
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    //监听键盘隐藏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
    [self top_setupNavBar];
    [self loadAllData];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
}
- (void)lastView_HomeTopSetting{
    //设置界面
    TOPSettingViewController * setVC = [TOPSettingViewController new];
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:setVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark --UI 布局界面
- (void)top_setupNavBar {
    TOPHomePageHeaderView * homeHeaderView = [self setMyHomeHeaderView];
    self.navigationItem.titleView = homeHeaderView;
    [homeHeaderView top_setupUI];
    [homeHeaderView top_changeChildHideState:NSLocalizedString(@"topscan_tabbartitlerecent", @"")];
}
- (void)loadAllData{
    [self top_initFileManager];
    [self top_loadData];
//    [self top_restoreBannerAD:self.view.size];//横幅广告
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self top_restoreBannerAD:self.view.size];//横幅广告
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;//关闭手势
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.tabBarController.selectedIndex != 0) {
        [self top_removeBannerView];//移除横幅广告
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self top_removeBannerView];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;//激活手势
    };
}
- (void)top_initFileManager {
    DocumentModel *model = [[DocumentModel alloc] init];
    model.docId = @"000000";
    model.type = @"0";
    model.path = [TOPDocumentHelper top_getDocumentsPathString];
    [TOPFileDataManager shareInstance].docModel = model;
}
#pragma mark -- 横竖屏切换时重新设置titleView
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
//    [self top_removeBannerView];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        /*
        if (self.tabBarController.selectedIndex == 0) {
            [self top_restoreBannerAD:size];
        }*/
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self top_setupNavBar];
    /*
    if (self.tabBarController.selectedIndex == 0) {
        [self top_restoreBannerAD:size];
    }*/
    if (self.shareFilePopView) {
        [self.shareFilePopView top_updateSubViewsLayout];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//加一个0.5s的延时 不然获取的屏幕方向是旋转之前的方向
        [self.mainView setCenterViewSubViews];
    });
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
    if (_passwordView) {
        if (![self.passwordView.tField isFirstResponder]&&![self.passwordView.againField isFirstResponder]) {
            [self lastView_ClickTapAction];
        }
    }
    if (_addFolderView) {
        if (![self.addFolderView.tField  isFirstResponder]) {
            [self lastView_ClickTapAction];
        }
    }
}
#pragma mark -- 获取所有doc文档 按修改日期的倒序排列 由新到旧 取第一个数据
- (void)top_loadData{
    if (!self.lastModel) {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DocumentModel * model = [TOPDBDataHandler top_buildLastDocDataWithDB];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (model) {
                model.selectStatus = YES;
                self.lastModel = model;
                self.mainView.hidden = NO;
                self.mainView.lastModel = self.lastModel;
            }else{
                self.mainView.hidden = YES;
            }
        });
    });
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
- (void)lastView_GetCamera{
    [FIRAnalytics logEventWithName:@"lastView_GetCamera" parameters:nil];
    TOPEnterCameraType cameraTpye = TOPShowFolderCameraType;
    TOPSCameraViewController *camera = [[TOPSCameraViewController alloc]init];
    camera.pathString = [TOPDocumentHelper top_appBoxDirectory];
    camera.fileType = cameraTpye;
    camera.backType = TOPHomeChildViewControllerBackTypeDismiss;
    
    TOPPresentNavViewController * nav = [[TOPPresentNavViewController alloc]initWithRootViewController:camera];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
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
#pragma mark -- 点击按钮时判断文档有无密码 有密码就把功能类型传过去
- (void)judgeDocPasswordState:(NSInteger)tag{
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        NSNumber * funcNum = [self functionTypeArray][tag];
        if ([funcNum integerValue] == TOPMenuItemsFunctionShare || [funcNum integerValue] == TOPMenuItemsFunctionEmail || [funcNum integerValue] == TOPMenuItemsFunctionFax) {//分享,发送email，发送传真时判断有没有开启app的蜂窝数据
            if (isReopened) {//没有开启给出提示
                [self top_showCellularView];
            }else{
                [self top_wlanOpenedJudgePasswordViewState:tag];
            }
        }else{
            [self top_wlanOpenedJudgePasswordViewState:tag];
        }
    }];
}
- (void)top_wlanOpenedJudgePasswordViewState:(NSInteger)tag{
    if ([TOPWHCFileManager top_isExistsAtPath:self.lastModel.docPasswordPath]) {
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        [keyWindow addSubview:self.coverView];
        [self top_markupCoverMask];
        [keyWindow addSubview:self.passwordView];
        NSNumber * num = [self functionTypeArray][tag];
        switch ([num integerValue]) {
            case TOPMenuItemsFunctionShare:
                self.passwordView.actionType = TOPMenuItemsFunctionShare;
                break;
            case TOPMenuItemsFunctionEmail:
                self.passwordView.actionType = TOPMenuItemsFunctionEmail;
                break;
            case TOPMenuItemsFunctionFax:
                self.passwordView.actionType = TOPMenuItemsFunctionFax;
                break;
            case TOPMenuItemsFunctionMore:
                self.passwordView.actionType = TOPMenuItemsFunctionMore;
                break;
            case TOPMenuItemsFunctionDoc:
                self.passwordView.actionType = TOPMenuItemsFunctionDoc;
                break;
            default:
                break;
        }
    }else{
        [self previewFunction:tag];
    }
}
#pragma mark -- doc没有密码点击事件
- (void)previewFunction:(NSInteger)tag{
    NSNumber * num = [self functionTypeArray][tag];
    switch ([num integerValue]) {
        case TOPMenuItemsFunctionShare:
            [self last_docShare];
            break;
        case TOPMenuItemsFunctionEmail:
            [self last_docEmail];
            break;
        case TOPMenuItemsFunctionFax:
            [self last_docFax];
            break;
        case TOPMenuItemsFunctionMore:
            [self last_docMore];
            break;
        case TOPMenuItemsFunctionDoc:
            [self last_docPush];
            break;
        case TOPMenuItemsFunctionRename:
            [self lastView_ClickToChangeDocName];
            break;
        default:
            break;
    }
}
#pragma mark -- doc密码的视图的点击事件 根据功能类型做逻辑处理
- (void)top_passwordViewActionWithPassword:(NSString *)password WithType:(NSInteger)actionType{
    switch (actionType) {
        case TOPHomeMoreFunctionSetLockFirst://第一次写入密码
            [self lastView_ClickTapAction];
            [self last_WritePasswordToDoc:password];
            break;
        case TOPHomeMoreFunctionSetLock://有默认密码时设置密码
            [self last_SetLockagain:password];
            break;
        case TOPHomeMoreFunctionPDFPassword:
            [self lastView_ClickTapAction];
            [self top_setPdfPassword:password];
            break;
        case TOPMenuItemsFunctionShare:
            [self last_hasLockShare:password];
            break;
        case TOPMenuItemsFunctionEmail:
            [self last_hasLockEmail:password];
            break;
        case TOPMenuItemsFunctionFax:
            [self last_hasLockFax:password];
            break;
        case TOPMenuItemsFunctionMore:
            [self last_hasLockMore:password];
            break;
        case TOPMenuItemsFunctionDoc:
            [self last_hasLockPush:password];
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
#pragma mark -- 写入密码
- (void)last_WritePasswordToDoc:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_WritePasswordToDoc" parameters:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * docPasswordPath = self.lastModel.docPasswordPath;
        if (docPasswordPath.length>0) {
            NSArray * getArray = [docPasswordPath componentsSeparatedByString:TOP_TRDocPasswordPathString];
            NSString * lastString = getArray.lastObject;
            if (![lastString isEqualToString:password]) {//与默认密码不一致的就删除 然后重新写入
                [TOPWHCFileManager top_removeItemAtPath:docPasswordPath];
                [TOPDocumentHelper top_creatDocPasswordWithPath:self.lastModel.path withPassword:password];
            }
        }else{
            [TOPDocumentHelper top_creatDocPasswordWithPath:self.lastModel.path withPassword:password];//没有默认密码直接写入
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //写入完成之后给出密码提示
            [[TOPCornerToast shareInstance]makeToast:[NSString stringWithFormat:@"%@%@",[NSLocalizedString(@"topscan_colletiondocpasswordtitle", @"") stringByAppendingString:@":"],password]];
            [TOPScanerShare top_writeDocPasswordSave:password];
            [self top_loadData];
        });
    });
}
#pragma mark -- 有默认密码时设置密码
- (void)last_SetLockagain:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_SetLockagain" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self lastView_ClickTapAction];
        [self last_WritePasswordToDoc:password];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的分享
- (void)last_hasLockShare:(NSString *)password{
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self lastView_ClickTapAction];
        [self last_docShare];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的email
- (void)last_hasLockEmail:(NSString *)password{
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self lastView_ClickTapAction];
        [self last_docEmail];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的Fax
- (void)last_hasLockFax:(NSString *)password{
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self lastView_ClickTapAction];
        [self last_docFax];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的更多
- (void)last_hasLockMore:(NSString *)password{
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self lastView_ClickTapAction];
        [self last_docMore];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 有密码时的页面跳转
- (void)last_hasLockPush:(NSString *)password{
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self lastView_ClickTapAction];
        [self last_docPush];
    }else{
        [self top_writePasswordFail];
    }
}
#pragma mark -- 密码错误提示
- (void)top_writePasswordFail{
    if (self.isShowFailToast) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_writepasswordfail", @"") duration:1];
    }
}
#pragma mark -- 没密码时的分享
- (void)last_docShare{
    self.emailType = 0;
    [self lastShareView];
}
#pragma mark -- 没密码时的email
- (void)last_docEmail{
    self.emailType = 1;
    [self lastShareView];
}
#pragma mark -- 给自己发送email
- (void)last_docEmailSelf{
    self.emailType = 2;
    [self lastShareView];
}
#pragma mark -- 没密码时的Fax
- (void)last_docFax{
    [self lastView_FaxTip];
}
#pragma mark -- 没密码时的更多
- (void)last_docMore{
    [self lastView_MenuItemsMore];
}
#pragma mark -- 没密码时的页面跳转
- (void)last_docPush{
    [self top_clickDocPushChildVCWithPath];
}
#pragma mark -- 弹出修改文件夹名称视图
- (void)lastView_ClickToChangeDocName{
    [FIRAnalytics logEventWithName:@"homeView_ClickToChangeFolderName" parameters:nil];
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    self.coverView.backgroundColor = RGBA(51, 51, 51, 0);
    [keyWindow addSubview:self.coverView];
    [self top_markupCoverMask];
    [keyWindow addSubview:self.addFolderView];

    self.addFolderView.picName = @"top_docIcon";
    self.addFolderView.tagsName = self.lastModel.name;
}
#pragma mark -- 修改文件夹功能 通过本地数据模型的数据库id获取对应的数据库模型 然后根据数据库模型里的父类id获取同层级的所有数据库模型 然后将这里数据库模型对应的名称保存起来 用作名称去重逻辑判断
- (void)top_ClickToChangeFolderNameAction:(NSString *)name{
    //1.判断有没有重名 2.没有重名再修改 修改本地名称 修改数据库保存的名称
    TOPAppDocument * appDocument = [TOPDBQueryService top_appDocumentById:self.lastModel.docId];
    RLMResults <TOPAppDocument *> * appArray = [TOPDBQueryService top_documentsByParentId:appDocument.parentId];
    NSMutableSet * addArray = [NSMutableSet new];
    for (TOPAppDocument * tempModel in appArray) {
        [addArray addObject:tempModel.name];
    }
    if ([addArray containsObject:name]) {
        //当编辑的文字和原来的文件夹名称相同时 不做修改 也不用给出提示
        if (![name isEqualToString:self.lastModel.name]) {
            [self lastView_DocAlreadyAlert];
        }
        return;
    }
    
    //输入的名字为空时 就不修改
    if (name.length == 0) {
        return;
    }
    [TOPDocumentHelper top_changeDocumentName:self.lastModel.path folderText:name];
    [TOPEditDBDataHandler top_editDocumentName:name withId:self.lastModel.docId];
    [self top_loadData];
}
- (void)lastView_DocAlreadyAlert{
    [FIRAnalytics logEventWithName:@"homeView_FolderAlreadyAlert" parameters:nil];
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
#pragma mark -- 开始打印
- (void)lastView_PrintFunction{
    [TOPDocumentHelper top_appReopenedNetworkState:^(BOOL isReopened) {
        if (isReopened) {
            [self top_showCellularView];
        }else{
            [self dealPrintData];
        }
    }];
}
- (void)dealPrintData{
    [FIRAnalytics logEventWithName:@"lastView_PrintFunction" parameters:nil];
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //先生成pdf再打印
        //先清空pdf文件夹里的内容
        [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
        NSMutableArray * imgArray = [NSMutableArray new];
        NSString * pdfName = [NSString new];
        DocumentModel * printModel = self.lastModel;
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

- (void)lastShareView{
    [FIRAnalytics logEventWithName:@"lastShareView" parameters:nil];
    NSMutableArray *shareDatas = [TOPShareFileDataHandler top_fetchShareFileData:@[self.lastModel]];
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
                if (weakSelf.emailType == 1||weakSelf.emailType == 2) {
                    [weakSelf lastView_EmailTip:shareArray];
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
            
            sizeView.compressType = cellModel.fileType;
            sizeView.dataArray = [@[self.lastModel] mutableCopy];
            sizeView.totalNum = cellModel.fileSize;
            sizeView.numberStr = [TOPDocumentHelper top_memorySizeStr:cellModel.fileSize];
        } else if (cellModel.fileType == TOPShareFileLongJPG) {
            [FIRAnalytics logEventWithName:@"recentView_ShareLongImage" parameters:nil];
            [weakSelf top_prejudgeImages];
        } else if (cellModel.fileType == TOPShareFileTxt) {
            [FIRAnalytics logEventWithName:@"recentView_shareText" parameters:nil];
            [weakSelf top_shareText];
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
                DocumentModel * model = self.lastModel;
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
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (weakSelf.emailType == 1||weakSelf.emailType == 2) {
                        [weakSelf lastView_EmailTip:shareArray];
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
                DocumentModel * model = self.lastModel;
                //在folder文件夹下 获取图片
                if ([model.type isEqualToString:@"1"]) {
                    [shareArray addObjectsFromArray:[weakSelf top_getDocumentShareImgURL:model]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (weakSelf.emailType == 1||weakSelf.emailType == 2) {
                        [weakSelf lastView_EmailTip:shareArray];
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
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * childArray = [NSMutableArray new];
        NSMutableArray *dataArray = [TOPDataModelHandler top_buildDocumentSecondaryDataAtPath:self.lastModel.path];
        [childArray addObjectsFromArray:dataArray];
        //将ocr识别过的图片和没有识别过的图片区分开
        NSMutableArray * ocrArray = [NSMutableArray new];
        for (DocumentModel * ocrModel in childArray) {
            if ([TOPWHCFileManager top_isExistsAtPath:ocrModel.ocrPath]) {
                [ocrArray addObject:ocrModel];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            NSLog(@"ocrArray==%ld childArray==%ld",ocrArray.count,childArray.count);
            if (ocrArray.count == childArray.count) {
                //所选图片都已经ocr识别过
                TOPPhotoShowTextAgainVC * ocrTextVC = [TOPPhotoShowTextAgainVC new];
                ocrTextVC.dataArray = ocrArray;
                ocrTextVC.backType = TOPPhotoShowTextAgainVCBackTypePopRoot;
                ocrTextVC.dataType = TOPOCRDataTypeSingleDocument;
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
                ocrVC.dataType = TOPOCRDataTypeSingleDocument;
                ocrVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ocrVC animated:YES];
            }
        });
    });
}
#pragma mark -- 预判图片数量是否过多
- (void)top_prejudgeImages {
    static NSInteger maxNum = 30;//30张图片为界限
    NSMutableArray * imgArray = [[NSMutableArray alloc] init];
    NSArray *images = @[];
    images = [TOPDocumentHelper top_getJPEGFile:self.lastModel.path];
    for (NSString *content in images) {
        [imgArray addObject:content];
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
        NSArray *imgArray = [TOPDataModelHandler top_selectedImageArray:@[self.lastModel]];
        UIImage *resultImg = [TOPPictureProcessTool top_mergedImages:imgArray];
        NSString *showPath = [TOPDocumentHelper top_longImageFileString];
        [TOPDocumentHelper top_saveImage:resultImg atPath:showPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
//            [self lastView_CancleSelectAction];
            TOPShowLongImageViewController * longImgVC = [TOPShowLongImageViewController new];
            longImgVC.showPath = showPath;
            longImgVC.pathString = [TOPDocumentHelper top_getDocumentsPathString];
            longImgVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:longImgVC animated:YES];
        });
    });
}
#pragma mark-- 发送email
- (void)lastView_EmailTip:(NSArray *)emailArray{
    if (emailArray.count) {
        [FIRAnalytics logEventWithName:@"lastView_EmailTip" parameters:@{@"emailArray":emailArray}];
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
        if (self.emailType == 1) {
            [self recentView_ShowMailCompose:self.emailModel.toEmail array:emailArray];
        }
        if (self.emailType == 2) {
            if (self.emailModel.myselfEmail.length>0) {
                [self recentView_ShowMailCompose:self.emailModel.myselfEmail array:emailArray];
            }else{
                //弹出提示框
                self.emailArray = [emailArray mutableCopy];
                [self lastView_ShowEmailArray];
            }
        }
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
- (void)lastView_ShowEmailArray{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:self.coverView];
    [self top_markupCoverMask];
    [window addSubview:self.emailAgainView];
}
#pragma mark -- 更多试图里的事件
- (void)previewView_MoreViewAction:(NSInteger)index{
    switch (index) {
        case TOPHomeMoreFunctionPicCollage:
            [self top_homeMoreCollage];
            break;
        case TOPHomeMoreFunctionDocTag:
            [self lastView_SetTag];
            break;
        case TOPHomeMoreFunctionPrint:
            [self lastView_PrintFunction];
            break;
        case TOPHomeMoreFunctionBatchEdit:
            [self lastView_MoreViewBatchEdit];
            break;
        case TOPHomeMoreFunctionEmailMySelef:
            if (![TOPPermissionManager top_enableByEmailMySelf]) {
                [self top_subscriptionService];
                return;
            }
            [self last_docEmailSelf];
            break;
        case TOPHomeMoreFunctionSaveToGrallery:
            [self lastView_SaveToGalleryTip];
            break;
        case TOPHomeMoreFunctionSetLock:
            [self lastView_SetLock];
            break;
        case TOPHomeMoreFunctionUnLock:
            [self lastView_DocUnlock];
            break;
        case TOPHomeMoreFunctionPDFPassword:
            [self top_showPdfSetView];
            break;
        case TOPHomeMoreFunctionPDF://pdf
            [self top_jumpToEditPDFVC];
            break;
        case TOPHomeMoreFunctionUpload:
            [self lastView_uploadDrive];
            break;
        case TOPHomeMoreFunctionDocRemaind:
            [self lastView_setDocReminder];
            break;
        case TOPHomeMoreFunctionOCR:
            if (![TOPDocumentHelper top_getSelectFolderDocPicState:@[self.lastModel]]) {
                [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
                return;
            }
            [self top_shareText];
            break;
        case TOPHomeMoreFunctionDocRename:
            [self previewFunction:5];
            break;
        case TOPHomeMoreFunctionDocCollection:
            [self lastView_DocCollection];
            break;
        default:
            break;
    }
}
- (void)lastView_DocCollection{
    if (self.lastModel.collectionstate) {
        self.lastModel.collectionstate = 0;
    }else{
        self.lastModel.collectionstate = 1;
    }
    self.mainView.lastModel = self.lastModel;
    [TOPEditDBDataHandler top_editDocumentCollectionState:self.lastModel.collectionstate withId:self.lastModel.docId];
}
#pragma mark -- PDF预览
- (void)top_jumpToEditPDFVC{
        TOPEditPDFViewController * pdfVC = [[TOPEditPDFViewController alloc] init];
        pdfVC.docModel = self.lastModel;
        pdfVC.filePath = self.lastModel.path;
        pdfVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pdfVC animated:YES];
}
#pragma mark -- 设置文档提醒
- (void)lastView_setDocReminder{
    TOPDocumentRemindVC * remindVC = [TOPDocumentRemindVC new];
    remindVC.docModel = self.lastModel;
    remindVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
    remindVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:remindVC animated:YES];
}
#pragma mark -- uploadDrive 上传第三方网盘
- (void)lastView_uploadDrive{
    if (![TOPDocumentHelper top_getSelectFolderDocPicState:@[self.lastModel]]) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_filenull", @"")];
        return;
    }
    [FIRAnalytics logEventWithName:@"homeuploadDrive" parameters:nil];
    TOPLoadSelectDriveViewController *uploadVC = [[TOPLoadSelectDriveViewController alloc] init];
    uploadVC.uploadDatas = [NSMutableArray arrayWithArray:@[self.lastModel]];
    TOPPresentNavViewController *nav = [[TOPPresentNavViewController alloc] initWithRootViewController:uploadVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark --设置pdf密码的弹出视图
- (void)top_showPdfSetView{
    [FIRAnalytics logEventWithName:@"EditPDFVC_pdfPassword" parameters:nil];
    if (![TOPPermissionManager top_enableByEmailMySelf]) {
        [self top_subscriptionService];
        return;
    }
    NSString *pass = [TOPScanerShare top_pdfPassword];
    if ([pass length]) {//已经设置了密码
        [TOPScanerShare top_writePDFPassword:@""];
        [[TOPCornerToast shareInstance] makeToast:[NSLocalizedString(@"topscan_setpdfpasswordtitle", @"") stringByAppendingString:@":"]];
    } else {
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
#pragma mark -- 去订阅
- (void)top_subscriptionService {
    TOPSubscriptionPayListViewController * generalVC = [[TOPSubscriptionPayListViewController alloc] init];
    generalVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:generalVC animated:YES];
}
#pragma mark --设置密码
- (void)lastView_SetLock{
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
#pragma mark -- 清除doc文档密码
- (void)lastView_DocUnlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TOPWHCFileManager top_removeItemAtPath:self.lastModel.docPasswordPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_successfullyunlocked", @"")];
            [self top_loadData];
        });
    });
    
}
#pragma mark -- 跳转到childVC
- (void)top_clickDocPushChildVCWithPath{
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    childVC.docModel = self.lastModel;
    childVC.pathString = self.lastModel.path;
    childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
    childVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:childVC animated:YES];
}
- (void)lastView_MoreViewBatchEdit{
    //获取Documents/Documents里面的文件夹
    TOPAppDocument *docObj = [TOPDBQueryService top_appDocumentById:self.lastModel.docId];
    if (docObj.costTime > 500) {//大于0.5s的耗时
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TOPAppDocument *appDoc = [TOPDBQueryService top_appDocumentById:self.lastModel.docId];
        appDoc.filePath = self.lastModel.path;
        NSMutableArray *dataArray = [TOPDBDataHandler top_buildDocumentDataWithDB:appDoc];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            TOPHomeChildBatchViewController * batchVC = [TOPHomeChildBatchViewController new];
            batchVC.dataArray = dataArray;
            batchVC.isAllData = YES;
            batchVC.childVCPath = self.lastModel.path;;
            batchVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:batchVC animated:YES];
        });
    });
}
#pragma mark-- 保存到Gallery文件夹
- (void)lastView_SaveToGalleryTip{
    [FIRAnalytics logEventWithName:@"lastView_SaveToGalleryTip" parameters:nil];
    NSArray * emailArray = [TOPDocumentHelper top_getSelectFolderPicture:@[self.lastModel]];
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
#pragma mark -- 传真
- (void)lastView_FaxTip{
    [FIRAnalytics logEventWithName:@"lastView_FaxTip" parameters:nil];
    if (![TOPDocumentHelper top_getSelectFolderDocPicState:@[self.lastModel]]) {
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
        for (NSString * pathString in [TOPDocumentHelper top_getSelectFolderPicture:@[self.lastModel]]) {
            UIImage * img = [UIImage imageWithContentsOfFile:pathString];
            if (img) {
                [editArray addObject:img];
            }
        }
        
        pdfName = [NSString stringWithFormat:@"%@",self.lastModel.name];
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
    CGFloat memorySize = [TOPDocumentHelper top_calculateSelectFilesSize:@[self.lastModel]];//[TOPDocumentHelper top_totalMemorySize:tempPathArray];
    self.totalSizeNum = memorySize;
}
#pragma mark -- 设置标签
- (void)lastView_SetTag{
    TOPSetTagViewController * tagVC = [[TOPSetTagViewController alloc]init];
    tagVC.dataArray = [@[self.lastModel] mutableCopy];
    tagVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tagVC animated:YES];
}
#pragma mark -- 拼图
- (void)top_homeMoreCollage{
    WS(weakSelf);
    [[TOPProgressStripeView shareInstance] top_showWithStatus:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"topscan_buildingpdf", @"")]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //先生成pdf再打印
        //先清空pdf文件夹里的内容
        [TOPWHCFileManager top_removeItemAtPath:TOPPDF_Path];
        DocumentModel * printModel = self.lastModel;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TOPProgressStripeView shareInstance] dismiss];
            TOPCollageViewController *collageVC = [[TOPCollageViewController alloc] init];
            collageVC.filePath = printModel.path;
            collageVC.docModel = printModel;
            collageVC.top_backBtnAction = ^{
                
            };
            collageVC.top_finishBtnAction = ^{
                [weakSelf top_loadData];
            };
            collageVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:collageVC animated:YES];
        });
    });
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
#pragma mark-- 更多弹框
- (void)lastView_MenuItemsMore{
    WS(weakSelf);
    NSString * lockStateString;
    NSString * lockStateIcon;
    NSString * collectionIcon = [NSString new];
    NSArray * moreArray = [NSArray new];
    NSArray * titleArray = [NSArray new];
    NSArray * iconArray = [NSArray new];
    if (self.lastModel.collectionstate) {
        collectionIcon = @"top_childvc_morehasCollected";
    }else{
        collectionIcon = @"top_childvc_moreCollection";
    }
    if ([TOPWHCFileManager top_isExistsAtPath:self.lastModel.docPasswordPath]) {
        lockStateString = NSLocalizedString(@"topscan_docpasswordunlockicon", @"");
        lockStateIcon = @"top_unlock";
        if ([self.lastModel.number integerValue]>1) {
            moreArray = @[@(TOPHomeMoreFunctionUnLock),@(TOPHomeMoreFunctionDocRename),@(TOPHomeMoreFunctionBatchEdit),@(TOPHomeMoreFunctionDocCollection),@(TOPHomeMoreFunctionEmailMySelef),@(TOPHomeMoreFunctionDocRemaind),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery),@(TOPHomeMoreFunctionPDFPassword)];
        }else{
            moreArray = @[@(TOPHomeMoreFunctionUnLock),@(TOPHomeMoreFunctionDocRename),@(TOPHomeMoreFunctionEmailMySelef),@(TOPHomeMoreFunctionDocCollection),@(TOPHomeMoreFunctionDocRemaind),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery),@(TOPHomeMoreFunctionPDFPassword)];
        }
    }else{
        lockStateString = NSLocalizedString(@"topscan_docpasswordicon", @"");
        lockStateIcon = @"top_lock";
        if ([self.lastModel.number integerValue]>1) {
            moreArray = @[@(TOPHomeMoreFunctionSetLock),@(TOPHomeMoreFunctionDocRename),@(TOPHomeMoreFunctionBatchEdit),@(TOPHomeMoreFunctionDocCollection),@(TOPHomeMoreFunctionEmailMySelef),@(TOPHomeMoreFunctionDocRemaind),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery),@(TOPHomeMoreFunctionPDFPassword)];
        }else{
            moreArray = @[@(TOPHomeMoreFunctionSetLock),@(TOPHomeMoreFunctionDocRename),@(TOPHomeMoreFunctionEmailMySelef),@(TOPHomeMoreFunctionDocCollection),@(TOPHomeMoreFunctionDocRemaind),@(TOPHomeMoreFunctionOCR),@(TOPHomeMoreFunctionSaveToGrallery),@(TOPHomeMoreFunctionPDFPassword)];
        }
    }
    
    NSString *pdfPasswordTitle = [[TOPScanerShare top_pdfPassword] length] > 0 ? NSLocalizedString(@"topscan_pdfpasswordclear", @"") : NSLocalizedString(@"topscan_pdfpassword", @"");
    if ([self.lastModel.number integerValue]>1) {
        titleArray = @[lockStateString,
                       NSLocalizedString(@"topscan_siderename", @""),
                       NSLocalizedString(@"topscan_batchedit", @""),
                       NSLocalizedString(@"topscan_childimportant", @""),
                       NSLocalizedString(@"topscan_emailmyself", @""),
                       NSLocalizedString(@"topscan_homemoredocremind", @""),
                       NSLocalizedString(@"topscan_ocr",@""),
                       NSLocalizedString(@"topscan_savetogallery", @""),
                       pdfPasswordTitle];
        iconArray = @[lockStateIcon,@"top_folderRename",@"top_childvc_batchedit",collectionIcon,@"top_childvc_moreemail",@"top_childvc_morebell",@"top_childvc_moreOCR",@"top_childvc_morepic",@"top_menu_pdfPassword"];
    }else{
        titleArray = @[lockStateString,
                       NSLocalizedString(@"topscan_siderename", @""),
                       NSLocalizedString(@"topscan_emailmyself", @""),
                       NSLocalizedString(@"topscan_childimportant", @""),
                       NSLocalizedString(@"topscan_homemoredocremind", @""),
                       NSLocalizedString(@"topscan_ocr",@""),
                       NSLocalizedString(@"topscan_savetogallery", @""),
                       pdfPasswordTitle];
        iconArray = @[lockStateIcon,@"top_folderRename",@"top_childvc_moreemail",collectionIcon,@"top_childvc_morebell",@"top_childvc_moreOCR",@"top_childvc_morepic",@"top_menu_pdfPassword"];
    }
    TOPChildMoreView * moreView = [[TOPChildMoreView alloc]initWithTitleView:[UIView new] optionsArr:titleArray iconArr:iconArray  cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
    } selectBlock:^(NSInteger index) {
        NSNumber *num =moreArray[index];
        [weakSelf previewView_MoreViewAction:num.integerValue];
    }];
    moreView.menuItems = moreArray;
    NSArray *menuItems = [self top_headMenuSelectItems];
    moreView.docModel = self.lastModel;
    moreView.headMenuItems = menuItems;
    moreView.showHeadMenu = YES;
    moreView.top_selectedHeadMenuBlock = ^(NSInteger item) {
        TOPHeadMenuModel *model = menuItems[item];
        [weakSelf previewView_MoreViewAction:model.functionItem];
    };
}
- (NSArray *)top_headMenuSelectItems {
    BOOL showVip = NO;
    NSDictionary *dic1 = @{
        @"functionItem":@(TOPHomeMoreFunctionDocTag),
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
        @"functionItem":@(TOPHomeMoreFunctionPDF),
        @"title":NSLocalizedString(@"topscan_editpdf", @""),
        @"iconName":@"top_menu_editpdf",
        @"showVip":@(showVip)};
    showVip = ![TOPPermissionManager top_enableByCollageSave];
    NSDictionary *dic5 = @{
        @"functionItem":@(TOPHomeMoreFunctionPicCollage),
        @"title":NSLocalizedString(@"topscan_collage", @""),
        @"iconName":@"top_menu_collage",
        @"showVip":@(showVip)};
    
    NSArray *dics = @[dic1,dic2,dic3, dic4,dic5];
    NSMutableArray *temp = @[].mutableCopy;
    for (NSDictionary *dic in dics) {
        TOPHeadMenuModel *item1 = [[TOPHeadMenuModel alloc] init];
        item1.functionItem = [dic[@"functionItem"] integerValue];
        item1.title = dic[@"title"];
        item1.iconName = dic[@"iconName"];
        item1.showVip = [dic[@"showVip"] boolValue];
        [temp addObject:item1];
    }
    return temp;
}
#pragma mark -- 隐藏视图
- (void)lastView_ClickTapAction{
    [UIView animateWithDuration:0.3 animations:^{
        self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, TOPScreenHeight, AddFolder_W, AddFolder_H);
        self.addFolderView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, TOPScreenHeight, AddFolder_W, AddFolder_W);
    }completion:^(BOOL finished) {
        [self.coverView removeFromSuperview];
        [self.passwordView removeFromSuperview];
        [self.emailAgainView removeFromSuperview];
        [self.addFolderView removeFromSuperview];

        self.emailAgainView = nil;
        self.coverView = nil;
        self.passwordView = nil;
        self.addFolderView = nil;
    }];
}
#pragma mark -- 加载横幅广告
- (void)top_changeBannerViewFream:(CGSize)size{
    if (![TOPPermissionManager top_enableByAdvertising]) {//不是会员，要展示广告
        if (!self.isBanner) {//横幅没有加载过
            [self top_previewView_AddBannerViewWithSize:size];
        }
    } else {//是会员移除横幅广告
        [self top_removeBannerView];
        [self.mainView top_setupUI:[self recevieAdFail]];
    }
}
#pragma mark -- 隐藏横幅广告视图
- (void)top_removeBannerView{
    [self.scBannerView removeFromSuperview];
    self.scBannerView = nil;
    self.isBanner = NO;
}
#pragma mark -- 横幅广告
- (void)top_previewView_AddBannerViewWithSize:(CGSize)currentSize{
    GADAdSize adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(currentSize.width);
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
    [FIRAnalytics logEventWithName:@"lastView_bannerReceiveAd" parameters:nil];
    if (bannerView) {
        bannerView.hidden = NO;
        self.isBanner = YES;
        [self.mainView top_setupUI:[self recevieAdSuccessed]];
    }
}
#pragma mark -- 获取横幅广告失败
- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    /*
    if (!self.isBanner) {
        [self top_removeBannerView];
        [self.mainView top_setupUI:[self recevieAdFail]];
    }*/
    self.scBannerView.hidden = YES;
    self.isBanner = NO;
    [self.mainView top_setupUI:[self recevieAdFail]];
}

- (CGSize)recevieAdSuccessed{
    CGSize topSize ;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;//ipad切换横竖屏时 字体大小 lab的间距也随着改变
    if (IS_IPAD) {
        if (orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown) {//竖屏
            topSize = CGSizeMake(50+50, 20);
        }else{
            topSize = CGSizeMake(50+30, 20);
        }
    }else{
        topSize = CGSizeMake(50, 20);
    }
    return topSize;
}
- (CGSize)recevieAdFail{
    CGSize topSize ;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;//ipad切换横竖屏时 字体大小 lab的间距也随着改变
    if (IS_IPAD) {
        if (orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown) {//竖屏
            topSize = CGSizeMake(75+50, 50);
        }else{
            topSize = CGSizeMake(75+30, 50);
        }
    }else{
        topSize = CGSizeMake(75, 50);
    }
    return topSize;
}
- (NSArray *)functionTypeArray{
    NSArray * functionArray = @[@(TOPMenuItemsFunctionShare),@(TOPMenuItemsFunctionEmail),@(TOPMenuItemsFunctionFax),@(TOPMenuItemsFunctionMore),@(TOPMenuItemsFunctionDoc),@(TOPMenuItemsFunctionRename)];
    return functionArray;
}
- (SCMainPreviewView *)mainView{
    if (!_mainView) {
        WS(weakSelf);
        _mainView = [SCMainPreviewView new];
        _mainView.previewFunctionType = ^(NSInteger tag) {
            [weakSelf judgeDocPasswordState:tag];
        };
    }
    return _mainView;
}
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lastView_ClickTapAction)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
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
            [weakSelf lastView_ClickTapAction];
        };
        
        _passwordView.top_clickToHelp = ^{
            [weakSelf top_settingView_SendFeedback];
        };
    }
    return _passwordView;
}
- (TOPSettingEmailAgainView *)emailAgainView{
    WS(weakSelf);
    if (!_emailAgainView) {
        _emailAgainView = [[TOPSettingEmailAgainView alloc]initWithFrame:CGRectMake(20, (TOPScreenHeight-210)/2, TOPScreenWidth-40, 210)];
        _emailAgainView.contentType = weakSelf.emailType;
        _emailAgainView.top_sendBackEmail = ^(NSString * _Nonnull email) {
            [weakSelf recentView_ShowMailCompose:email array:weakSelf.emailArray];
        };
        
        _emailAgainView.top_returnEdit = ^{
            [weakSelf lastView_ClickTapAction];
        };
    }
    return _emailAgainView;
}
- (TOPHomePageHeaderView *)setMyHomeHeaderView{
    WS(weakSelf);
    TOPHomePageHeaderView * homeHeaderView = [[TOPHomePageHeaderView alloc]init];
    homeHeaderView.backgroundColor = [UIColor clearColor];
    homeHeaderView.top_DocumentHeadClickHandler = ^(NSInteger index, BOOL selected) {
        switch (index) {
            case 0:
//                [weakSelf top_HomeTopSearch];
                break;
            case 1:
                [weakSelf lastView_HomeTopSetting];
                break;
            case 2:
//                [weakSelf top_HomeTopUpgradeVip];
                break;
            default:
                break;
        }
    };
    return homeHeaderView;
}
- (TOPAddFolderView *)addFolderView{
    if (!_addFolderView) {
        WS(weakSelf);
        _addFolderView = [[TOPAddFolderView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolder_W)];
        _addFolderView.top_clickToSendString = ^(NSString * _Nonnull editString) {
            [weakSelf top_ClickToChangeFolderNameAction:editString];
            [weakSelf lastView_ClickTapAction];
        };
        
        _addFolderView.top_clickToHide = ^{
            [weakSelf lastView_ClickTapAction];
        };
    }
    return _addFolderView;
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
