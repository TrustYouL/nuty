#import "TOPSettingDarkModeVC.h"
#import "TOPSettingModel.h"
#import "TOPScanDarkChooseCell.h"
#import "TOPScanDarkSystemCell.h"
@interface TOPSettingDarkModeVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic ,strong)NSMutableArray * systemArray;
@property (nonatomic ,strong)NSMutableArray * customArray;
@end

@implementation TOPSettingDarkModeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    self.title = NSLocalizedString(@"topscan_darkmode", @"");
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    [self top_setupUI];
    [self top_loadData];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
    self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
         @{NSForegroundColorAttributeName:[UIColor top_textColor:[UIColor whiteColor] defaultColor:TOPAPPGreenColor]}];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    [self top_adaptationSystemUpgrade];
}
#pragma mark -- 适配系统更新
- (void)top_adaptationSystemUpgrade {
    NSDictionary *textAtt = @{NSForegroundColorAttributeName:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)],
                              NSFontAttributeName:[UIFont systemFontOfSize:18]};
    if (@available(iOS 15.0, *)){
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        appearance.titleTextAttributes = textAtt;
        appearance.shadowColor = [UIColor clearColor];
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.standardAppearance = appearance;
    } else {
        [self.navigationController.navigationBar setTitleTextAttributes:textAtt];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
- (void)top_setupUI{
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(self.view);
    }];
}
- (void)top_loadData{
    [self.systemArray removeAllObjects];
    [self.customArray removeAllObjects];
    NSDictionary *dic1 = @{@"checkValue":@(TOPSettingCellTypeFirstKind),
                           @"settingAction":@(TOPSettingVCBackgroundStstemStyle),
                           @"title":NSLocalizedString(@"topscan_darkmodefollowsystem", @""),
                           @"content":NSLocalizedString(@"topscan_darkmodeldescrible", @"")};
    NSDictionary *dic2 = @{@"checkValue":@(TOPSettingCellTypeFirstKind),
                           @"settingAction":@(TOPSettingVCBackgroundNotStstemWhiteStyle),
                           @"title":NSLocalizedString(@"topscan_lightmode", @""),
                           @"content":@""};
    NSDictionary *dic3 = @{@"checkValue":@(TOPSettingCellTypeFirstKind),
                           @"settingAction":@(TOPSettingVCBackgroundNotStstemDarkStyle),
                           @"title":NSLocalizedString(@"topscan_darkmode", @""),
                           @"content":@""};
    NSArray *darkArray = @[dic1];
    NSArray *customArray = @[dic2,dic3];
    for (NSDictionary * dic in darkArray) {
        TOPSettingModel * docModel = [self top_buildSettingModel:dic];
        [self.systemArray addObject:docModel];
    }
    if (@available(iOS 13.0, *)) {
        if ([TOPScanerShare top_darkModel] != UIUserInterfaceStyleUnspecified) {
            for (NSDictionary * dic in customArray) {
                TOPSettingModel * docModel = [self top_buildSettingModel:dic];
                [self.customArray addObject:docModel];
            }
        }
    }
    [self.tableView reloadData];
}
- (TOPSettingModel *)top_buildSettingModel:(NSDictionary *)dic {
    TOPSettingModel * docModel = [[TOPSettingModel alloc] init];
    docModel.myTitle = dic[@"title"];
    docModel.myContent = dic[@"content"];
    docModel.checkValue = [dic[@"checkValue"] integerValue];
    docModel.settingAction = [dic[@"settingAction"] integerValue];
    return docModel;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.customArray.count) {
        return 2;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.systemArray.count;
    }
    return self.customArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TOPSettingModel * model = self.systemArray[indexPath.row];
        TOPScanDarkSystemCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPScanDarkSystemCell class]) forIndexPath:indexPath];
        cell.model = model;
        WS(weakSelf);
        cell.top_switchBtnAction = ^(BOOL switchOn) {
            [weakSelf top_switchStateReloadData:switchOn];
        };
        return cell;
    }else{
        TOPSettingModel * model = self.customArray[indexPath.row];
        TOPScanDarkChooseCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPScanDarkChooseCell class]) forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 10)];
        headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        return headerView;
    }else{
        UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 30)];
        headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 200, 20)];
        titleLab.text = NSLocalizedString(@"topscan_darkmodchoosetitle",@"");
        titleLab.textColor = RGBA(180, 180, 180, 1.0);
        titleLab.font = [UIFont systemFontOfSize:13];
        titleLab.textAlignment = NSTextAlignmentNatural;
        [headerView addSubview:titleLab];
        return headerView;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 0.01)];
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 90;
    }
    return 55;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }
    return 35;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (@available(iOS 13.0 ,*)) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (indexPath.row == 0) {
                    [TOPScanerShare top_writeDarkModelStyle:UIUserInterfaceStyleLight];
                }else{
                    [TOPScanerShare top_writeDarkModelStyle:UIUserInterfaceStyleDark];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].windows[0].overrideUserInterfaceStyle = [TOPScanerShare top_darkModel];
                    [self.tableView reloadData];
                });
            });
        }
    }
}
- (void)top_switchStateReloadData:(BOOL)switchOn{
    if (@available(iOS 13.0 ,*)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (switchOn) {
                [TOPScanerShare top_writeDarkModelStyle:UIUserInterfaceStyleUnspecified];
            }else{
                if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    [TOPScanerShare top_writeDarkModelStyle:UIUserInterfaceStyleDark];
                }else if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleLight){
                    [TOPScanerShare top_writeDarkModelStyle:UIUserInterfaceStyleLight];
                }else{
                    [TOPScanerShare top_writeDarkModelStyle:UIUserInterfaceStyleUnspecified];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].windows[0].overrideUserInterfaceStyle = [TOPScanerShare top_darkModel];
                [self top_loadData];
            });
        });
    }
}
- (void)top_backHomeAction{
    if (self.top_backToRefresh) {
        self.top_backToRefresh();
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        [_tableView registerClass:[TOPScanDarkChooseCell class] forCellReuseIdentifier:NSStringFromClass([TOPScanDarkChooseCell class])];
        [_tableView registerClass:[TOPScanDarkSystemCell class] forCellReuseIdentifier:NSStringFromClass([TOPScanDarkSystemCell class])];
    }
    return _tableView;
}
- (NSMutableArray *)systemArray{
    if (!_systemArray) {
        _systemArray = [NSMutableArray new];
    }
    return _systemArray;
}
- (NSMutableArray *)customArray{
    if (!_customArray) {
        _customArray = [NSMutableArray new];
    }
    return _customArray;
}

@end
