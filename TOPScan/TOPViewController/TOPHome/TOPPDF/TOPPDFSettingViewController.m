#import "TOPPDFSettingViewController.h"
#import "TOPPDFInfoCell.h"
#import "TOPPageNumCell.h"
#import "TOPPageNumModel.h"
#import "TOPPageDirectionModel.h"

@interface TOPPDFSettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *typeDatas;
@property (nonatomic, strong) NSMutableArray *directionDatas;
@property (assign, nonatomic) TOPPDFPageNumLayoutType pageNumLayout;
@property (assign, nonatomic) TOPPDFPageDirectionType pageDirection;

@end

@implementation TOPPDFSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:ViewBgColor];
    [self top_configUI];
    [self top_initUIData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    [self top_initNavBar];
    [self.tableView reloadData];
}

#pragma mark -- 导航栏
- (void)top_initNavBar {
    [self.navigationController.navigationBar setBarTintColor:[UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor]];
    if (isRTL()) {
        [self top_setBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_setBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
}

- (void)top_setBackButton:(nullable NSString *)imgName withSelector:(SEL)selector {
    TOPImageTitleButton * btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
    btn.frame = CGRectMake(0, 0, 44, 44);
    if (isRTL()) {
        btn.style = EImageLeftTitleRightCenter;
    }else{
        btn.style = EImageLeftTitleRightLeft;
    }
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

#pragma mark -- 界面布局
- (void)top_configUI {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
}

- (void)top_initUIData {
    self.pageDirection = [TOPScanerShare top_pdfDirection];
    self.pageNumLayout = [TOPScanerShare top_pdfNumberType];
    NSArray *temp = @[@(PDFSettingTypeFileName), @(PDFSettingTypePageNumber), @(PDFSettingTypePageDirection)];
    self.dataArray = [temp mutableCopy];
    [self top_pageNumTypeData];
    [self top_pageDirectionData];
}

#pragma mark -- 返回
- (void)top_backHomeAction {
    if (self.signatureArr.count && (self.pageDirection != [TOPScanerShare top_pdfDirection] || self.pageNumLayout != [TOPScanerShare top_pdfNumberType])) {
        [self top_deleteSignatureAlert];
    } else {
        [self top_setUpdate];
    }
}

- (void)top_setUpdate {
    if (self.pageDirection != [TOPScanerShare top_pdfDirection]) {
        if (self.top_editPDFDirectionBlock) {
            self.top_editPDFDirectionBlock();
        }
    }
    if (self.pageNumLayout != [TOPScanerShare top_pdfNumberType]) {
        if (self.top_editPDFNumLayoutBlock) {
            self.top_editPDFNumLayoutBlock();
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 删除签名提示
- (void)top_deleteSignatureAlert {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_changepdfsizealert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_yes", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        
        [self top_setUpdate];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_no", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        [TOPScanerShare top_writeSavePDFNumberType:self.pageNumLayout];
        [TOPScanerShare top_writeSavePDFDirection:self.pageDirection];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 更新PDF名称
- (void)top_updataPDFName {
    [FIRAnalytics logEventWithName:@"PDFSettingVC_updataPDFName" parameters:nil];
    if ([self.pdfName length]) {
        if (self.top_editPDFNameBlock) {
            self.top_editPDFNameBlock(self.pdfName);
        }
    } else {
        [self top_emptyNameAlert];
    }
}

- (void)top_emptyNameAlert {
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_emptypdfnamealert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
    }];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 更新PDF页码排版
- (void)top_updatePDFNumber:(NSInteger)index {
    [FIRAnalytics logEventWithName:@"PDFSettingVC_updatePDFNumber" parameters:nil];
    TOPPageNumModel *model = self.typeDatas[index];
    [TOPScanerShare top_writeSavePDFNumberType:model.pageNumLayout];
}

#pragma mark -- 更新PDF朝向
- (void)top_updatePDFDirection:(NSInteger)index {
    [FIRAnalytics logEventWithName:@"PDFSettingVC_updatePDFDirection" parameters:nil];
    TOPPageDirectionModel *model = self.directionDatas[index];
    [TOPScanerShare top_writeSavePDFDirection:model.pageDirectionType];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 49;
    switch (indexPath.section) {
        case 0:
            cellHeight = 49;
            break;
        case 1:
            cellHeight = 225;
            break;
        case 2:
            cellHeight = 173;
            break;
        default:
            break;
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {//显示用户头像
        TOPPDFInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPPDFInfoCell class])];
        if (!cell) {
            cell = [[TOPPDFInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([TOPPDFInfoCell class])];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.section < self.dataArray.count) {
            cell.cellContent = self.pdfName;
        }
        cell.top_didEditedBlock = ^(NSString * _Nonnull content) {
            weakSelf.pdfName = content;
            [weakSelf top_updataPDFName];
        };
        return cell;
    } else if (indexPath.section == 1) {
        TOPPageNumCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPPageNumCell class])];
        if (!cell) {
            cell = [[TOPPageNumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([TOPPageNumCell class])];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.section < self.dataArray.count) {
            [cell top_configCellWithData:self.typeDatas title:NSLocalizedString(@"topscan_pdfpagenumber", @"")];
            cell.showVip = ![TOPPermissionManager top_enableByPDFPageNO];
            cell.top_didSelectedBlock = ^(NSInteger item) {
                [weakSelf top_updatePDFNumber:item];
            };
            cell.top_permissionPDFPageNOBlock = ^{
                [weakSelf top_subscriptionService];
            };
        }
        return cell;
        
    } else if (indexPath.section == 2) {
        TOPPageNumCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPPageNumCell class])];
        if (!cell) {
            cell = [[TOPPageNumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([TOPPageNumCell class])];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.section < self.dataArray.count) {
            [cell top_configCellWithData:self.directionDatas title:NSLocalizedString(@"topscan_pdfpagedirection", @"")];
            cell.top_didSelectedBlock = ^(NSInteger item) {
                [weakSelf top_updatePDFDirection:item];
            };
        }
        return cell;
    }

    return [UITableViewCell new];
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


#pragma mark -- lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionHeaderHeight = 10;
        _tableView.sectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:ViewBgColor];
        [_tableView registerClass:[TOPPDFInfoCell class] forCellReuseIdentifier:NSStringFromClass([TOPPDFInfoCell class])];
        [_tableView registerClass:[TOPPageNumCell class] forCellReuseIdentifier:NSStringFromClass([TOPPageNumCell class])];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

- (NSMutableArray *)typeDatas {
    if (!_typeDatas) {
        _typeDatas = @[].mutableCopy;
    }
    return _typeDatas;
}

- (NSMutableArray *)directionDatas {
    if (!_directionDatas) {
        _directionDatas = @[].mutableCopy;
    }
    return _directionDatas;
}

- (void)top_pageNumTypeData {
    NSDictionary *dic1 = @{@"typeTitle": NSLocalizedString(@"topscan_pdfpagenumberno", @""),
                           @"typeImage": @"top_pageNum_bottom",
                           @"typeHighImage": @"top_pagestate_selected",
                           @"TOPPDFPageNumLayoutType": @(TOPPDFPageNumLayoutTypeNull),
                           @"isHigh": @(1)};
    NSDictionary *dic2 = @{@"typeTitle": NSLocalizedString(@"topscan_pdfpagenumberlowerl", @""),
                           @"typeImage": @"top_pageNum_bottom",
                           @"typeHighImage": @"top_pagestate_selected",
                           @"TOPPDFPageNumLayoutType": @(TOPPDFPageNumLayoutTypeBottomLeft),
                           @"isHigh": @(0)};
    NSDictionary *dic3 = @{@"typeTitle": NSLocalizedString(@"topscan_pdfpagenumberbottomc", @""),
                           @"typeImage": @"top_pageNum_bottom",
                           @"typeHighImage": @"top_pagestate_selected",
                           @"TOPPDFPageNumLayoutType": @(TOPPDFPageNumLayoutTypeBottomCenter),
                           @"isHigh": @(0)};
    NSDictionary *dic4 = @{@"typeTitle": NSLocalizedString(@"topscan_pdfpagenumberlowerr", @""),
                           @"typeImage": @"top_pageNum_bottom",
                           @"typeHighImage": @"top_pagestate_selected",
                           @"TOPPDFPageNumLayoutType": @(TOPPDFPageNumLayoutTypeBottomRight),
                           @"isHigh": @(0)};
    NSDictionary *dic5 = @{@"typeTitle": NSLocalizedString(@"topscan_pdfpagenumberupperl", @""),
                           @"typeImage": @"top_pageNum_bottom",
                           @"typeHighImage": @"top_pagestate_selected",
                           @"TOPPDFPageNumLayoutType": @(TOPPDFPageNumLayoutTypeTopLeft),
                           @"isHigh": @(0)};
    NSDictionary *dic6 = @{@"typeTitle": NSLocalizedString(@"topscan_pdfpagenumberheadc", @""),
                           @"typeImage": @"top_pageNum_bottom",
                           @"typeHighImage": @"top_pagestate_selected",
                           @"TOPPDFPageNumLayoutType": @(TOPPDFPageNumLayoutTypeTopCenter),
                           @"isHigh": @(0)};
    NSDictionary *dic7 = @{@"typeTitle": NSLocalizedString(@"topscan_pdfpagenumberupperr", @""),
                           @"typeImage": @"top_pageNum_bottom",
                           @"typeHighImage": @"top_pagestate_selected",
                           @"TOPPDFPageNumLayoutType": @(TOPPDFPageNumLayoutTypeTopRight),
                           @"isHigh": @(0)};
    
    NSArray *temp = @[dic1, dic2, dic3, dic4, dic5, dic6, dic7];
    for (NSDictionary *cellDic in temp) {
        TOPPageNumModel *model = [[TOPPageNumModel alloc] init];
        model.typeTitle = cellDic[@"typeTitle"];
        model.typeImage = cellDic[@"typeImage"];
        model.typeHighImage = cellDic[@"typeHighImage"];
        model.pageNumLayout = [cellDic[@"TOPPDFPageNumLayoutType"] integerValue];
        model.isHigh = NO;
        if (model.pageNumLayout == self.pageNumLayout) {
            model.isHigh = YES;
        }
        [self.typeDatas addObject:model];
    }
}

- (void)top_pageDirectionData {
    NSDictionary *dic1 = @{@"typeTitle": NSLocalizedString(@"topscan_pdfdirectionauto", @""),
                           @"typeImage": @"top_page_autoSize",
                           @"typeHighImage": @"top_autoSize_selected",
                           @"TOPPDFPageDirectionType": @(TOPPDFPageDirectionTypeAutoSize),
                           @"isHigh": @(1)};
    NSDictionary *dic2 = @{@"typeTitle": NSLocalizedString(@"topscan_pdfdirectionlandscape", @""),
                           @"typeImage": @"top_page_landscape",
                           @"typeHighImage": @"top_landscape_selected",
                           @"TOPPDFPageDirectionType": @(TOPPDFPageDirectionTypeLandscape),
                           @"isHigh": @(0)};
    NSDictionary *dic3 = @{@"typeTitle": NSLocalizedString(@"topscan_pdfaddsignature", @""),
                           @"typeImage": @"top_page_portrait",
                           @"typeHighImage": @"top_portrait_selected",
                           @"TOPPDFPageDirectionType": @(TOPPDFPageDirectionTypePortrait),
                           @"isHigh": @(0)};
    
    NSArray *temp = @[dic1, dic2, dic3];
    for (NSDictionary *cellDic in temp) {
        TOPPageDirectionModel *model = [[TOPPageDirectionModel alloc] init];
        model.typeTitle = cellDic[@"typeTitle"];
        model.typeImage = cellDic[@"typeImage"];
        model.typeHighImage = cellDic[@"typeHighImage"];
        model.pageDirectionType = [cellDic[@"TOPPDFPageDirectionType"] integerValue];
        model.isHigh = NO;
        if (model.pageDirectionType == self.pageDirection) {
            model.isHigh = YES;
        }
        [self.directionDatas addObject:model];
    }
}

@end
