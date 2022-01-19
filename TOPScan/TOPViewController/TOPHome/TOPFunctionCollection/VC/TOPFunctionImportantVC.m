#define AddFolder_W 310
#define AddFolder_H 190
#import "TOPFunctionImportantVC.h"
#import "TOPHomeChildViewController.h"
#import "TOPListTableViewTagsCell.h"
#import "TOPListTableViewCell.h"
@interface TOPFunctionImportantVC ()<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate>
@property (nonatomic, strong)UIView * coverView;
@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic ,strong)NSMutableArray * allFileArray;
@property (nonatomic, strong)DocumentModel * selectDocModel;
@property (nonatomic, strong)TOPDocPasswordView * passwordView;
@property (nonatomic, assign)BOOL isShowFailToast;
@end

@implementation TOPFunctionImportantVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    self.title = self.selectModel.titleString;
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    [self top_setupUI];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    [self top_loadData];
}
- (void)top_loadData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RLMResults<TOPAppDocument *> *collectionDocuments = [TOPDBQueryService top_documentsByCollecting];
        NSMutableArray * tempArray = [TOPDBDataHandler top_buildTagDocModleDataWithDB:collectionDocuments];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.allFileArray = tempArray;
            [self.tableView reloadData];
            if (tempArray.count) {
                self.tableView.hidden = NO;
            }else{
                self.tableView.hidden = YES;
            }
        });
    });
}
#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    if (self.passwordView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
            self.passwordView.frame = CGRectMake((TOPScreenWidth-AddFolder_W)/2, keyboardrect.origin.y-15-AddFolder_H, AddFolder_W, AddFolder_H);
        }];
    }
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    if (![self.passwordView.tField isFirstResponder]&&![self.passwordView.againField isFirstResponder]) {
        [self top_clickTapAction];
    }
}
#pragma mark -- 隐藏视图
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allFileArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DocumentModel *model = self.allFileArray[indexPath.row];
    if (model.tagsArray.count>0||model.collectionstate) {
        TOPListTableViewTagsCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListTableViewTagsCell class]) forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }else{
        TOPListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListTableViewCell class]) forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DocumentModel *model = self.allFileArray[indexPath.row];
    self.selectDocModel = model;
    [self top_judgeClickDocPasswordState];
}
#pragma mark -- 点击cell跳转到其他界面
- (void)top_judgeClickDocPasswordState{
    NSString * passwordPath = self.selectDocModel.docPasswordPath;
    if (passwordPath.length>0) {
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        [keyWindow addSubview:self.coverView];
        [keyWindow addSubview:self.passwordView];
        self.passwordView.actionType = TOPMenuItemsFunctionPushVC;
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(keyWindow);
        }];
    }else{
        [self top_clickCellAndPushVC];
    }
}
#pragma mark -- 密码匹配
- (void)top_passwordViewActionWithPassword:(NSString *)password WithType:(NSInteger)actionType{
    [FIRAnalytics logEventWithName:@"home_SetLockagain" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_clickTapAction];
        [self top_clickCellAndPushVC];
    }else{
        [self top_writePasswordFail];
    }
}
- (void)top_clickCellAndPushVC{
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    childVC.docModel = self.selectDocModel;
    childVC.pathString = self.selectDocModel.path;
    childVC.upperPathString = [TOPDocumentHelper top_appBoxDirectory];
    childVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:childVC animated:YES];
}
#pragma mark -- 密码不正确的提示
- (void)top_writePasswordFail{
    if (self.isShowFailToast) {
        [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_writepasswordfail", @"") duration:1];
    }
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
#pragma mark -- lazy
- (NSMutableArray *)allFileArray{
    if (!_allFileArray) {
        _allFileArray = [NSMutableArray new];
    }
    return _allFileArray;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-40) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[TOPListTableViewTagsCell class] forCellReuseIdentifier:NSStringFromClass([TOPListTableViewTagsCell class])];
        [_tableView registerClass:[TOPListTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPListTableViewCell class])];
    }
    return _tableView;
}
#pragma mark -- 密码弹框
- (TOPDocPasswordView *)passwordView{
    if (!_passwordView) {
        WS(weakSelf);
        _passwordView = [[TOPDocPasswordView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, AddFolder_W, AddFolder_H)];
        _passwordView.top_sendPassword = ^(NSString * _Nonnull password, NSInteger actionType,BOOL isShowFailToast) {
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
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTapAction)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}
- (void)top_setupUI{
    UIImageView * blankImg = [UIImageView new];
    blankImg.image = [UIImage imageNamed:@"top_importantblank"];
    
    [self.view addSubview:blankImg];
    [self.view addSubview:self.tableView];
    
    [blankImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-40);
        make.size.mas_equalTo(CGSizeMake(150, 130));
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(self.view);
    }];
}


@end
