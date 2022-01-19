#import "TOPBinSettingViewController.h"
#import "TOPSettingCellModel.h"
#import "TOPSingleSwitchCell.h"
#import "TOPSingleTextCell.h"
#import "TOPScrollChooseView.h"

@interface TOPBinSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray *settingData;
@property (nonatomic ,strong) TOPScrollChooseView *scrollChooseView;

@end

@implementation TOPBinSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_recyclebin", @""), NSLocalizedString(@"topscan_questionsetting", @"")];
    [self top_configNavBar];
    [self top_configContentView];
    [self top_loadData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}

- (void)top_backHomeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.settingData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TOPSettingCellModel * model = self.settingData[indexPath.section];
    if (model.cellType == TOPCustomCellTypeSingleSwitch) {//switch
        TOPSingleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPSingleSwitchCell class]) forIndexPath:indexPath];
        cell.model = model;
        cell.top_changeSwitchValueBlock = ^(BOOL open) {
            [TOPScanerShare top_writeDeleteFileAlert:open];
        };
        return cell;
    } else if (model.cellType == TOPCustomCellTypeSingleText) {
        TOPSingleTextCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPSingleTextCell class]) forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 57;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 10)];
    view.backgroundColor = [ UIColor clearColor];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 0.01)];
    v.backgroundColor = [ UIColor clearColor];
    return v;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TOPSettingCellModel * model = self.settingData[indexPath.section];
    if (model.cellType == TOPCustomCellTypeSingleText) {
        if (model.action == TOPSettingVCSaveBinFileTime) {
            [self top_showPickerView];
        }
    }
}

- (NSArray *)top_pickData {
    return @[@30, @60, @90, @120, @150, @180, @210, @240, @270, @300, @330, @360];
}

- (void)top_showPickerView {
    NSInteger days = [TOPScanerShare top_saveBinFileTime];
    NSInteger index = [[self top_pickData] indexOfObject:@(days)];
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    TOPScrollChooseView *scrollChooseView = [[TOPScrollChooseView alloc] initWithQuestionArray:[self top_pickData] withDefaultDesc:index];
    scrollChooseView.unableEdit = YES;
    [scrollChooseView top_showView];
    __weak typeof(self) weakSelf = self;
    scrollChooseView.confirmBlock = ^(NSInteger selectedValue) {
        NSInteger pickDays = [[[weakSelf top_pickData] objectAtIndex:selectedValue] integerValue];
        [TOPScanerShare top_writeSaveBinFileTime:pickDays];
        [weakSelf top_loadData];
        [weakSelf.tableView reloadData];
    };
    [keyWindow addSubview:scrollChooseView];
    self.scrollChooseView = scrollChooseView;
    [scrollChooseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(keyWindow);
    }];
}

- (void)hidePickerView {
    
}

- (void)top_loadData {
    [self.settingData removeAllObjects];
    NSInteger days = [TOPScanerShare top_saveBinFileTime];
    NSString *saveTime = [NSString stringWithFormat:@"%@%@",@(days),NSLocalizedString(@"topscan_howmuchmonth", @"")];
    NSDictionary *dic1 = @{@"isOpen":@([TOPScanerShare top_deleteFileAlert]),
                           @"cellType":@(TOPCustomCellTypeSingleSwitch),
                           @"showLine":@(0),
                           @"title":NSLocalizedString(@"topscan_deletealert", @""),
                           @"content":@"",
                           @"action":@(TOPSettingVCDeleteAlertSwitch)};
    NSDictionary *dic2 = @{@"isOpen":@(0),
                           @"cellType":@(TOPCustomCellTypeSingleText),
                           @"showLine":@(0),
                           @"title":NSLocalizedString(@"topscan_savefiletime", @""),
                           @"content":saveTime,
                           @"action":@(TOPSettingVCSaveBinFileTime)};
    NSArray *dicArr = @[dic1,dic2];
    for (NSDictionary * dic in dicArr) {
        TOPSettingCellModel * docModel = [self top_buildSettingModel:dic];
        [self.settingData addObject:docModel];
    }
}

- (TOPSettingCellModel *)top_buildSettingModel:(NSDictionary *)dic {
    TOPSettingCellModel * docModel = [[TOPSettingCellModel alloc] init];
    docModel.title = dic[@"title"];
    docModel.content = dic[@"content"];
    docModel.cellType = [dic[@"cellType"] integerValue];
    docModel.isOpen = [dic[@"isOpen"] integerValue];
    docModel.showLine = [dic[@"showLine"] integerValue];
    docModel.action = [dic[@"action"] integerValue];
    return docModel;
}

- (void)top_configNavBar {
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    } else {
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}

- (void)top_configContentView {
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(self.view);
    }];
}

#pragma mark -- lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        [_tableView registerClass:[TOPSingleSwitchCell class] forCellReuseIdentifier:NSStringFromClass([TOPSingleSwitchCell class])];
        [_tableView registerClass:[TOPSingleTextCell class] forCellReuseIdentifier:NSStringFromClass([TOPSingleTextCell class])];
    }
    return _tableView;
}

- (NSMutableArray *)settingData {
    if (!_settingData) {
        _settingData = @[].mutableCopy;
    }
    return _settingData;
}

@end
