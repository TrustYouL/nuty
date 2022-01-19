#import "TOPDocumentRemindVC.h"
#import "TOPRemindSwitchCell.h"
#import "TOPRemindTimeCell.h"
#import "TOPRemindContentCell.h"
#import "TOPCalendar.h"
#import "TOPDocNoticeModel.h"

@interface TOPDocumentRemindVC ()<UITableViewDelegate,UITableViewDataSource,TOPCalendarDelegate>
@property (nonatomic ,strong)UIView * coverView;
@property (nonatomic ,weak) TOPCalendar *calendar;
@property (nonatomic ,strong)UITableView * myTableView;
@property (nonatomic ,assign)BOOL isFirst;//是不是第一次设置通知
@property (nonatomic ,assign)BOOL isHave;//是否开启了通知权限(设置过了通知时用到)
@property (nonatomic ,assign)BOOL isContain;//设置过通知之后 再次进入该界面 用于设置通知开关的默认状态（这个属性是判断doc通知是否还有效）
@property (nonatomic ,strong)UIButton * returnBtn;//收键盘按钮
@property (nonatomic ,strong)UITextView * titleTV;
@property (nonatomic ,strong)TOPDocNoticeModel * noticeModel;//通知模型
@property (nonatomic ,strong)UILabel * tipLab;

@end

@implementation TOPDocumentRemindVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isContain = NO;
    self.isHave = NO;
    self.isFirst = NO;
    [self top_setNavView];
    [self top_setupUI];
    [self top_loadData];

    // Do any additional setup after loading the view.
}

#pragma mark -- 创建数据模型
- (void)top_loadData{
    TOPDocNoticeModel * model = [TOPDocNoticeModel new];
    model.noticeID = self.docModel.docId;
    model.noticeState = self.docModel.docNoticeLock;
    model.noticeBody = self.docModel.remindNote;
    if (self.docModel.remindTitle) {
        model.noticeTitle = self.docModel.remindTitle;
    }else{
        model.noticeTitle = [self.docModel.path lastPathComponent];
    }
    [self top_setDefaultNoticeModel:model];
    self.noticeModel = model;
    [self.myTableView reloadData];
}
#pragma mark -- 设置显示时间的默认值
- (void)top_setDefaultNoticeModel:(TOPDocNoticeModel *)noticeModel{
    NSString * showString = [NSString new];
    NSDate * saveDate = [NSDate new];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    if (self.docModel.remindTime) {
        saveDate = self.docModel.remindTime;
    }else{
        self.isFirst = YES;
        saveDate = [[NSDate date] dateByAddingTimeInterval:[self top_setOrderedAscendingDate:dateFormatter]*60];
    }
    showString = [dateFormatter stringFromDate:saveDate];
    noticeModel.noticeDate = saveDate;
    noticeModel.noticeShowTime = showString;
}
#pragma mark -- 计算当前时间离整点时间还差多少分钟
- (NSInteger)top_setOrderedAscendingDate:(NSDateFormatter *)dateFormatter{
    NSString * formatterString = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger minutesNum = [[[formatterString componentsSeparatedByString:@":"] lastObject] integerValue];//当前是多少分钟
    NSInteger differenceNum = 60 - minutesNum;//与整点的分钟差
    return differenceNum;
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkAppNoticeState) name:TOP_TRCodeReaderReStatr object:nil];//注册后台进入前台的通知
    if (!self.isFirst) {
        [self checkAppNoticeState];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)checkAppNoticeState{
    [[UNUserNotificationCenter currentNotificationCenter]getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {//用户还未做出选择
            self.noticeModel.noticeState = NO;
            self.isHave = NO;
        }else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {// 用户未授权通知
            self.noticeModel.noticeState = NO;
            self.isHave = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.myTableView reloadData];
            });
        }else{//用户已经授权通知
            self.isHave = YES;
            [self top_judgeNoticeState];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDate *currentDate = [NSDate date];//当前时间  当前时间和保存的时间做比较
                self.noticeModel.noticeState = [self top_compareBothDate:currentDate withSaveData:self.noticeModel.noticeDate];
                [self.myTableView reloadData];
            });
        }
    }];
}

- (void)top_clickCellToChangeRemindState:(BOOL)SwichState{
    [[UNUserNotificationCenter currentNotificationCenter]getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {//用户还未做出选择
            //弹出授权框
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert + UNAuthorizationOptionBadge + UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        self.noticeModel.noticeState = self.docModel.docNoticeLock;
                    }else{
                        self.noticeModel.noticeState = NO;
                    }
                    [self.myTableView reloadData];
                });
            }];
        }else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {// 用户未授权通知
            self.noticeModel.noticeState = NO;
            [self top_setStatusDenied];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.myTableView reloadData];
            });
        }else{//用户已经授权通知
            [self top_judgeNoticeState];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.noticeModel.noticeState = SwichState;
                [self.myTableView reloadData];
            });
        }
    }];
}
#pragma mark --用户未授权通知时 给出弹框
- (void)top_setStatusDenied{
        UIAlertController *noticeNotificationAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_docreminedtitle", @"") message:NSLocalizedString(@"topscan_docreminedcontent", @"") preferredStyle:UIAlertControllerStyleAlert];
        [noticeNotificationAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.noticeModel.noticeState = NO;
                [self.myTableView reloadData];
            });
        }]];
        
        [noticeNotificationAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_setting", @"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSURL *appSettingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:appSettingsUrl]) {
                [[UIApplication sharedApplication] openURL:appSettingsUrl options:@{} completionHandler:nil];
            }
        }]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:noticeNotificationAlertController animated:YES completion:NULL];
        });
}
#pragma mark--设置通知按钮的状态
- (BOOL)top_compareBothDate:(NSDate*)currentDate withSaveData:(NSDate *)saveDate{
    BOOL noticeState = NO;
    NSComparisonResult result = [saveDate compare:currentDate];
    if (result == NSOrderedDescending&&self.noticeModel.noticeState&&self.isContain) {//设置过通知 再次进入该界面 通知按钮默认状态是打开的 需要满足三个条件:1.设置的时间大于当前时间 2.通知的发送状态是打开的 3.设置的通知是有效的即没有弹出过 这里一定要判断 因为本地时间是可以修改的 弹出过的通知时间可以通过修改本地时间的手段来满足大于本地时间的条件 所以只判断通知时间大于当前时间就认定通知有效并不全面
        noticeState = YES;
    }
    return noticeState;
}
#pragma mark -- UI
- (void)top_setupUI{
    [self.view addSubview:self.myTableView];
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}
- (void)top_setNavView{
    if (isRTL()) {//黑色
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backAction)];
    }
    UIButton * saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [saveBtn setTitle:NSLocalizedString(@"topscan_tagsdone", @"") forState:UIControlStateNormal];
    [saveBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(top_clickRightItems) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = barItem;
}
#pragma mark -- 返回
- (void)top_backAction{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 手势隐藏日历
- (void)top_tapClick:(UITapGestureRecognizer *)tap{
    [self top_hideCalederView];
}
#pragma mark -- 判断设置的本地通知是否弹出过
- (void)top_judgeNoticeState{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        for (UNNotificationRequest *req in requests){
            NSLog(@"存在的ID:%@\n",req.identifier);
            if ([req.identifier isEqualToString:self.noticeModel.noticeID]) {
                self.isContain = YES;
            }
        }
    }];
}
#pragma mark -- save
- (void)top_clickRightItems{
    [self.titleTV resignFirstResponder];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    NSComparisonResult result = [self.noticeModel.noticeDate compare:[NSDate date]];
    if (self.noticeModel.noticeState) {//通知开关开着
        if (result == NSOrderedAscending || result == NSOrderedSame) {//如果选择的时间比当前时间小 就将时间设置为整点时间
            [self top_setCalendarView];
            [self top_setToastLab];
        }else{
            [self top_saveDocModelValue];
            NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval selectInterval = [self.noticeModel.noticeDate timeIntervalSince1970];
            NSDictionary * modelDic = @{@"docModel":self.docModel.mj_keyValues,@"upperPathString":self.upperPathString};
            [TOPDocumentHelper top_removeNotificationWithIdentifierID:self.noticeModel.noticeID];
            [TOPDocumentHelper top_addLocalNotificationWithTitle:self.noticeModel.noticeTitle subTitle:@"" body:self.noticeModel.noticeBody timeInterval:selectInterval-currentInterval identifier:self.noticeModel.noticeID userInfo:modelDic repeats:8];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{//通知开关关闭的
        [self top_saveDocModelValue];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -- 写入数据
- (void)top_saveDocModelValue{
    if (self.noticeModel.noticeTitle.length == 0) {
        self.noticeModel.noticeTitle = [self.docModel.path lastPathComponent];
    }
    [TOPEditDBDataHandler top_editDocumentNoticeModel:self.noticeModel];
    self.docModel.remindTime = self.noticeModel.noticeDate;
    self.docModel.remindTitle = self.noticeModel.noticeTitle;
    self.docModel.remindNote = self.noticeModel.noticeBody;
    self.docModel.docNoticeLock = self.noticeModel.noticeState;
}
#pragma mark - 日历代理返回
- (void)top_calendar:(TOPCalendar *)calendar didClickSureButtonWithDate:(NSString *)date{
    //字符串转时间NSDate
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"]; //设定时间的格式
    NSDate *tempDate = [dateFormatter dateFromString:date];//将字符串转换为时间对象
    NSComparisonResult result = [tempDate compare:[NSDate date]];
    if (self.noticeModel.noticeState) {//通知开关是开着的
        if (result == NSOrderedAscending || result == NSOrderedSame) {//如果选择的时间比当前时间小 就将时间设置为当前时间+5分钟
            self.noticeModel.noticeDate = [[NSDate date] dateByAddingTimeInterval:[self top_setOrderedAscendingDate:dateFormatter]*60];
        }else{
            self.noticeModel.noticeDate = tempDate;//选中时间
        }
    }else{//通知开关是关着的
        self.noticeModel.noticeDate = tempDate;//选中时间
    }
   
    //NSDate转特定的时间显示格式
    NSDateFormatter *showFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    showFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [showFormatter setDateFormat:@"MM/dd/yyyy HH:mm"]; //设定时间的格式
    NSString *showString = [showFormatter  stringFromDate:self.noticeModel.noticeDate];

    [self top_hideCalederView];
    self.noticeModel.noticeShowTime = showString;
    [self.myTableView reloadData];
}
- (void)top_clickToDismiss{
    [self top_hideCalederView];
}
#pragma mark -- 隐藏日历
- (void)top_hideCalederView{
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha = 0;
        self.calendar.alpha = 0;
    }completion:^(BOOL finished) {
        [self.coverView removeFromSuperview];
        [self.calendar removeFromSuperview];
        self.coverView = nil;
        self.calendar = nil;
    }];
}
#pragma mark -- delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            TOPRemindSwitchCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPRemindSwitchCell class])];
            cell.noticeState = self.noticeModel.noticeState;
            cell.top_sendNoticeState = ^(BOOL noticeState) {
                if (!weakSelf.isFirst) {
                    if (weakSelf.isHave) {
                        weakSelf.noticeModel.noticeState = noticeState;
                    }else{
                        [weakSelf top_setStatusDenied];
                    }
                }else{
                    [weakSelf top_clickCellToChangeRemindState:noticeState];
                }
               
            };
            return cell;
        }else{
            TOPRemindTimeCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPRemindTimeCell class])];
            cell.timeString = self.noticeModel.noticeShowTime;
            cell.top_clickAndSetTime = ^{
                [weakSelf.titleTV resignFirstResponder];
                [weakSelf top_setCalendarView];
            };
            return cell;
        }
    }else{
        TOPRemindContentCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPRemindContentCell class])];
        cell.row = indexPath.row;
        if (indexPath.row == 0) {
            cell.textContent = self.noticeModel.noticeTitle;
            cell.placerString = [NSLocalizedString(@"topscan_remindtitle", @"") stringByAppendingString:@" :"];
        }else{
            cell.textContent = self.noticeModel.noticeBody;
            cell.placerString = [NSLocalizedString(@"topscan_note", @"") stringByAppendingString:@" :"];
        }
        cell.top_startEdit = ^(UITextView * _Nonnull myTV) {
            weakSelf.titleTV = myTV;
        };
        cell.top_sendEditcontent = ^(NSString * _Nonnull contentString, NSInteger row) {
            if (row == 0) {
                weakSelf.noticeModel.noticeTitle = contentString;
            }else{
                weakSelf.noticeModel.noticeBody = contentString;
            }
        };
        return cell;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 10)];
    headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:RGBA(235, 235, 235, 1.0)];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 10)];
    if (section == 0) {
        footerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:RGBA(235, 235, 235, 1.0)];
    }else{
        footerView.backgroundColor = [UIColor clearColor];
    }
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 45;
    }else{
        if (indexPath.row == 0) {
            return 60;
        }else{
            if (IS_IPAD) {
                return 300;
            }
            return 180;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}
- (UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight) style:UITableViewStyleGrouped];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.scrollEnabled = NO;
        _myTableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_myTableView registerClass:[TOPRemindSwitchCell class] forCellReuseIdentifier:NSStringFromClass([TOPRemindSwitchCell class])];
        [_myTableView registerClass:[TOPRemindTimeCell class] forCellReuseIdentifier:NSStringFromClass([TOPRemindTimeCell class])];
        [_myTableView registerClass:[TOPRemindContentCell class] forCellReuseIdentifier:NSStringFromClass([TOPRemindContentCell class])];
    }
    return _myTableView;
}

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        _coverView.alpha = 0;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_tapClick:)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}
#pragma mark -- 日历视图
- (void)top_setCalendarView{
    CGRect currentRect;
    if (IS_IPAD) {
        currentRect = CGRectMake((TOPScreenWidth-400)/2, (TOPScreenHeight-400)/2, 400, 400);
    }else{
        currentRect = CGRectMake(10, (TOPScreenHeight-400)/2, TOPScreenWidth-20, 400);
    }
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    TOPCalendar *calendar = [[TOPCalendar alloc] initWithFrame:currentRect];
    calendar.currentDate = self.noticeModel.noticeDate;
    calendar.alpha = 0;
    calendar.delegate = self;
    calendar.showTimePicker = YES;
    self.calendar = calendar;
    [keyWindow addSubview:self.coverView];
    [keyWindow addSubview:self.calendar];
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha = 1;
        self.calendar.alpha = 1;
    }];
}
#pragma mark -- 吐词提示
- (void)top_setToastLab{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    NSString * toastString = NSLocalizedString(@"topscan_docreminetime", @"");
    UILabel * tipLab = [UILabel new];
    tipLab.layer.cornerRadius = 8;
    tipLab.layer.masksToBounds = YES;
    tipLab.backgroundColor = RGBA(0, 0, 0, 0.6);
    tipLab.numberOfLines = 0;
    tipLab.alpha = 1;
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.textColor = kWhiteColor;
    tipLab.font = PingFang_R_FONT_(14);
    tipLab.text = toastString;
    self.tipLab = tipLab;
    [keyWindow addSubview:tipLab];
    

    CGRect rect = [tipLab.text boundingRectWithSize:CGSizeMake(TOPScreenWidth - 60, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:tipLab.font} context:nil];
    CGFloat width = rect.size.width + 20;
    CGFloat height = rect.size.height + 40;
    CGFloat x = (TOPScreenWidth-width)/2;
    CGFloat y = self.calendar.origin.y+self.calendar.bounds.size.height+10;
    if (IS_IPAD) {
        tipLab.frame = CGRectMake((TOPScreenWidth-400)/2, y, 400, height);
    }else{
        tipLab.frame = CGRectMake(x, y, width, height);
    }
    [self performSelector:@selector(top_hiddenToast) withObject:nil afterDelay:1.5];//
}
#pragma mark -- 1.5s后隐藏吐词
- (void)top_hiddenToast{
    [self.tipLab removeFromSuperview];
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
