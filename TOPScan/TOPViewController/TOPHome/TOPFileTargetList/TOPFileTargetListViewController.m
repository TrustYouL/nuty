#define AddFolder_W 310
#define AddFolder_H 240
#define AddFolderSingle_H 190
#define FolderViewTypeAdd @"FolderViewTypeAdd"

#import "TOPFileTargetListViewController.h"
#import "TOPFileTargetTableView.h"
#import "TOPFileTargetHandler.h"
#import "TOPAddFolderView.h"

@interface TOPFileTargetListViewController ()<MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) TOPFileTargetTableView *tableView;
@property (nonatomic, strong) TOPDocPasswordView * passwordView;
@property (nonatomic, strong) UIView * coverView;
@property (nonatomic, strong) TOPFileTargetModel * fileModel;
@property (strong, nonatomic) TOPFileTargetHandler *fileTargetHander;
@property (nonatomic, assign) BOOL isShowFailToast;
@property (nonatomic, strong) TOPAddFolderView * addFolderView;
@property (nonatomic, copy) NSString * folderViewType;

@end

@implementation TOPFileTargetListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    [self top_initMyNavigationBar];
    [self top_initMyUIView];
    [self top_initMyData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self top_adaptationSystemUpgrade];
}

#pragma mark -- 设置导航栏
- (void)top_initMyNavigationBar {
    self.title = self.fileHandleType == TOPFileHandleTypeCopy ? NSLocalizedString(@"topscan_graffiticopyto", @"") : NSLocalizedString(@"topscan_graffitimoveto", @"");
    [self.navigationController.navigationBar setBarTintColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]]];
    [self top_adaptationSystemUpgrade];
    [self top_initCancleBackBtn:@selector(top_clickCancleBtn)];
    [self top_initRightNavBtn:@selector(top_clickAddFileBtn)];
}
#pragma mark -- 导航栏返回按钮
- (void)top_initCancleBackBtn:(SEL)selector {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, (52), 44)];
     [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 25)];
    [btn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    [btn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [btn.titleLabel setFont:PingFang_M_FONT_(16)];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

#pragma mark -- 导航栏右侧按钮
- (void)top_initRightNavBtn:(SEL)selector {
    NSString *imageName = self.fileTargetType == TOPFileTargetTypeFolder ? @"top_addfolder_icon" : @"top_addDoc_black";
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    [rightBtn setTintColor:kBlackColor];
    [self.navigationItem setRightBarButtonItem:rightBtn];
}

#pragma mark -- 布局视图
- (void)top_initMyUIView {
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:kWhiteColor];;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView.fileTargetType = self.fileTargetType;
    __weak typeof(self) weakSelf = self;
    self.tableView.top_didSelectFileBlock = ^(TOPFileTargetModel * model) {
        weakSelf.fileModel = model;
        if (model.isCurrentFile) {
            [weakSelf top_dismissAndBlockBack];
        }else{
            [weakSelf top_judgeClickDocPasswordState];
        }
    };
}

#pragma mark -- 初始化数据源
- (void)top_initMyData {
    self.fileTargetHander.currentFilePath = self.currentFilePath;
    self.fileTargetHander.fileHandleType = self.fileHandleType;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *dataArray = [self.fileTargetHander top_getFileArrayWithType:self.fileTargetType];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dataArray.count) {
                self.tableView.dataArray = dataArray;
                [self.tableView reloadData];
            }
        });
    });
}

#pragma mark -- 事件处理
#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    
    if (self.addFolderView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            self.addFolderView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_W, AddFolder_W, AddFolder_W);
        }];
    }
    
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
    if (![self.passwordView.tField isFirstResponder]&&![self.passwordView.againField isFirstResponder]&&![self.addFolderView.tField  isFirstResponder]) {
        [self top_clickTapAction];
    }
}

- (void)top_passwordViewActionWithPassword:(NSString *)password WithType:(NSInteger)actionType{
    switch (actionType) {
        case TOPMenuItemsFunctionCopyMove:
            [self top_setLockCopyMove:password];
            break;
        default:
            break;
    }
}

#pragma mark -- 点击doc时有无密码的判断
- (void)top_judgeClickDocPasswordState{
    NSString * passwordPath = self.fileModel.docPasswordPath;
    if ([TOPWHCFileManager top_isExistsAtPath:passwordPath]) {
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        [keyWindow addSubview:self.coverView];
        [keyWindow addSubview:self.passwordView];
        [self top_markupCoverMask];
        self.passwordView.actionType = TOPMenuItemsFunctionCopyMove;
    }else{
        [self top_dismissAndBlockBack];
    }
}

#pragma mark -- 有密码时的copy move
- (void)top_setLockCopyMove:(NSString *)password{
    [FIRAnalytics logEventWithName:@"setLockCopyMove" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_clickTapAction];
        [self top_dismissAndBlockBack];
    }else{
        [self top_writePasswordFail];
    }
}

- (void)top_writePasswordFail{
    if (self.isShowFailToast) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_writepasswordfail", @"") duration:1];
    }
}

- (void)top_clickTapAction{
    [UIView animateWithDuration:0.3 animations:^{
        [self.passwordView removeFromSuperview];
        [self.coverView removeFromSuperview];
        [self.addFolderView removeFromSuperview];
        self.passwordView = nil;
        self.coverView = nil;
        self.addFolderView = nil;
    }];
}

- (void)top_dismissAndBlockBack{
    if (self.top_callBackFilePathBlock) {
        self.top_callBackFilePathBlock(self.fileModel.path);
    }
}

#pragma mark -- 点击cancel
- (void)top_clickCancleBtn {
    if (self.top_clickCancelBlock) {
        self.top_clickCancelBlock();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 写入文件数据
- (void)top_addFileData:(NSString *)filePath {
    TOPFileTargetModel *model = [[TOPFileTargetModel alloc] init];
    NSString *parentId = @"000000";
    NSString * dir = [TOPWHCFileManager top_directoryAtPath:filePath];
    if ([dir isEqualToString:[TOPDocumentHelper top_getFoldersPathString]]) {//判断上级目录是不是首页
        parentId = @"000000";
    }else{
        if ([TOPFileDataManager shareInstance].docModel.docId) {
            parentId = [TOPFileDataManager shareInstance].docModel.docId;
        }
    }
    
    if (self.fileTargetType == TOPFileTargetTypeFolder) {
        TOPAPPFolder *folder = [TOPEditDBDataHandler top_addFolderAtFile:filePath WithParentId:parentId];
        model.docId = folder.Id;
    } else {
        TOPAppDocument *currentDoc = [TOPDBQueryService top_appDocumentById:parentId];
        TOPAppDocument *doc = [TOPEditDBDataHandler top_addDocumentAtFolder:filePath WithParentId:currentDoc.parentId];
        model.docId = doc.Id;
    }
    [TOPFileDataManager shareInstance].fileModel = model;
}

#pragma mark--点击创建文件夹
- (void)top_addFolderAction:(NSString *)name{
    NSString *filePath = self.fileTargetType == TOPFileTargetTypeFolder ? self.currentFilePath : [TOPWHCFileManager top_directoryAtPath:self.currentFilePath];
    if (self.fileTargetType == TOPFileTargetTypeFolder && [[TOPDocumentHelper top_getDocumentsPathString] isEqualToString:self.currentFilePath]) {
        filePath = [TOPDocumentHelper top_getFoldersPathString];
    }
    NSString *folderPathStr = [NSString new];
    if (name.length>0) {
        folderPathStr = [filePath  stringByAppendingPathComponent:name];
        NSString *isCreate =  [TOPDocumentHelper  top_createFolders:folderPathStr];
        if ([isCreate isEqualToString:@"1"]) {
            [self top_addFileData:folderPathStr];
            if (self.top_callBackFilePathBlock) {
                self.top_callBackFilePathBlock(folderPathStr);
            }
        } else if ([isCreate isEqualToString:@"0"]){
            [self top_folderAlreadyAlert];
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_creationfailed", @"")];
            [SVProgressHUD dismissWithDelay:1];
        }
    }else{
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_creationfailed", @"")];
    }
    [SVProgressHUD dismissWithDelay:2];
}

#pragma mark -- 去订阅
- (void)top_subscriptionService {
    if ([TOPAppTools needShowDiscountThemeView]) {
        [[TOPDiscountThemeView shareInstance] top_showDiscountTheme:@"20211123_year_sub"];
        return;
    } 
    TOPSubscriptionPayListViewController * generalVC = [[TOPSubscriptionPayListViewController alloc] init];
    generalVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:generalVC animated:YES];
}

#pragma mark -- 点击创建文件夹时的弹出视图
- (void)top_clickAddFileBtn {
    if (![TOPPermissionManager top_enableByCreateFolder]) {
        if (self.fileTargetType == TOPFileTargetTypeFolder) {
            if ([[TOPDocumentHelper top_getDocumentsPathString] isEqualToString:self.currentFilePath]) {
                RLMResults<TOPAPPFolder *> *folders = [TOPDBQueryService top_homeFoldersBySorted];
                if (folders.count >= 3) {
                    [self top_subscriptionService];
                    return;
                }
            } else {//次页面
                [self top_subscriptionService];
                return;
            }
        }
    }
    NSString *alertTitle = self.fileTargetType == TOPFileTargetTypeFolder ? TOPRNewFolderString : TOPRNewDocumentString;
    NSString *filePath = self.fileTargetType == TOPFileTargetTypeFolder ? self.currentFilePath : [TOPWHCFileManager top_directoryAtPath:self.currentFilePath];
    if (self.fileTargetType == TOPFileTargetTypeFolder && [[TOPDocumentHelper top_getDocumentsPathString] isEqualToString:self.currentFilePath]) {
        filePath = [TOPDocumentHelper top_getFoldersPathString];
    }
    NSString *fileName = nil;
    if (self.fileTargetType == TOPFileTargetTypeDocument) {
        fileName = [TOPDocumentHelper top_newDefaultDocumentNameAtPath:filePath];
    } else {
        NSString *defaultPath = [filePath stringByAppendingPathComponent:alertTitle];
        fileName = [TOPDocumentHelper top_newDocumentFileName:defaultPath];
    }
    WS(weakSelf);
    TopEditFolderAndDocNameVC * editVC = [TopEditFolderAndDocNameVC new];
    editVC.top_clickToSendString = ^(NSString * _Nonnull nameString) {
        [weakSelf top_addFolderAction:nameString];
    };
    editVC.defaultString = fileName;
    editVC.picName = self.fileTargetType == TOPFileTargetTypeFolder ? @"top_changefolder":@"top_changedoc";
    editVC.editing = self.fileTargetType == TOPFileTargetTypeFolder ? TopFileNameEditTypeAddFolder:TopFileNameEditTypeAddDoc;
    editVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark -- 文件名重复提示
- (void)top_folderAlreadyAlert{
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_duplicationname", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}
#pragma mark -- Send feedback
- (void)top_settingView_SendFeedback{
    [FIRAnalytics logEventWithName:@"settingView_SendFeedback" parameters:nil];
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        return;
    }
    if (![mailClass canSendMail]) {
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
#pragma mark -- lazy
- (TOPFileTargetTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TOPFileTargetTableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight) style:UITableViewStylePlain];
    }
    return _tableView;
}

- (TOPFileTargetHandler *)fileTargetHander {
    if (!_fileTargetHander) {
        _fileTargetHander = [[TOPFileTargetHandler alloc] init];
    }
    return _fileTargetHander;
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

- (TOPAddFolderView *)addFolderView{
    if (!_addFolderView) {
        WS(weakSelf);
        _addFolderView = [[TOPAddFolderView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolder_W)];
        _addFolderView.top_clickToSendString = ^(NSString * _Nonnull editString) {
            if ([weakSelf.folderViewType isEqualToString:FolderViewTypeAdd]) {
                [weakSelf top_addFolderAction:editString];
            }
            [weakSelf top_clickTapAction];
        };
        
        _addFolderView.top_clickToHide = ^{
            [weakSelf top_clickTapAction];
        };
    }
    return _addFolderView;
}
- (void)top_markupCoverMask{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
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

@end
