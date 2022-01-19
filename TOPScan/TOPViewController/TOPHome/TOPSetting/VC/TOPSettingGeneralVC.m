#define  cell_H 45
#define  EmailLocationY 20
#define  ProcessCell_H 50*7

#import "TOPSettingGeneralVC.h"
#import "TOPSettingModel.h"
#import "TOPScanSettingCell.h"
#import "TOPScanSettingLastCell.h"
#import "TOPPdfSizeSettingView.h"
#import "TOPSettingEmailView.h"
#import "TOPNextSettingShowView.h"
#import "TOPSettingOcrAccountVC.h"
#import "TOPScanDarkModelCell.h"
#import "TOPSettingDarkModeVC.h"
#import "TOPScreenShotStateCell.h"
@interface TOPSettingGeneralVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic ,strong)UIView * backView;
@property (nonatomic ,copy)NSArray * pageSizeArray;
@property (nonatomic ,copy)NSArray * defaultProcessArray;
@property (nonatomic ,strong)NSMutableArray * sectionOneArray;
@property (nonatomic ,strong)NSMutableArray * sectionTwoArray;
@property (nonatomic ,strong)TOPPdfSizeSettingView * pdfSizeView;
@property (nonatomic ,strong)TOPSettingEmailView * showEmailView;
@property (nonatomic ,strong)TOPNextSettingShowView * showJPGQualityView;
@property (nonatomic ,strong)TOPNextSettingShowView * showProcessView;

@end

@implementation TOPSettingGeneralVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"topscan_settinggeneral", @"");
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_backHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_backHomeAction)];
    }
    [self top_loadData];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    [self.navigationController.navigationBar setTitleTextAttributes:
         @{NSForegroundColorAttributeName:[UIColor top_textColor:[UIColor whiteColor] defaultColor:TOPAPPGreenColor]}];
}
#pragma mark -- 横竖屏切换时重新设置titleView
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (self.pdfSizeView) {
        [self.pdfSizeView.collectionView reloadData];
    }
}
- (void)top_backHomeAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.sectionOneArray.count;
    }
    return self.sectionTwoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TOPSettingModel * model = self.sectionOneArray[indexPath.row];
        if (model.myContent.length) {
            TOPScanSettingCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPScanSettingCell class]) forIndexPath:indexPath];
            cell.model = model;
            return cell;
        }else{
            TOPScanSettingLastCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPScanSettingLastCell class]) forIndexPath:indexPath];
            cell.titleLab.text = model.myTitle;
            return cell;
        }
    }else{
        TOPSettingModel * model = self.sectionTwoArray[indexPath.row];
        if (model.settingAction == TOPSettingVCBackgroundDarkStyle) {
            TOPScanDarkModelCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPScanDarkModelCell class]) forIndexPath:indexPath];
            cell.model = model;
            return cell;
        }else{
            TOPScreenShotStateCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPScreenShotStateCell class]) forIndexPath:indexPath];
            cell.titleLab.text = model.myTitle;
            return cell;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 10)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TOPSettingModel * model = self.sectionOneArray[indexPath.row];
        return model.cellHeight;
    }else{
        TOPSettingModel * model = self.sectionTwoArray[indexPath.row];
        if (model.settingAction == TOPSettingVCBackgroundDarkStyle) {
            return 60;
        }else{
            return model.cellHeight;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self top_didSelectedSettingGeneralAction:indexPath];
}

#pragma mark -- 设置 DocManagement
- (void)top_didSelectedSettingGeneralAction:(NSIndexPath *)indexPath {
    TOPSettingModel *model = [TOPSettingModel new];
    if (indexPath.section == 0) {
        model = self.sectionOneArray[indexPath.row];
    }else{
        model = self.sectionTwoArray[indexPath.row];
    }
    TOPSettingVCAction actionType = model.settingAction;
    switch (actionType) {
        case TOPSettingVCActionGeneralPageSize:
        case TOPSettingVCActionGeneralDefaultProcess:
            [self top_settingView_AddAndShowView:@[] :indexPath.row];
            break;
        case TOPSettingVCActionGeneralEmail:
            [self top_settingView_AddAndShowEmailView];
            break;
        case TOPSettingVCActionGeneralJPGQuality:
            [self top_settingView_AddJPGQualityView];
            break;
        case TOPSettingVCActionOCRAccount:
            [self top_settingView_AccountSet];
            break;
        case TOPSettingVCBackgroundDarkStyle:
            [self top_settingDarkModel];
            break;
        default:
            break;
    }
}
#pragma mark -- 暗黑设置完成之后刷新数据
- (void)top_refreshDarkState{
    NSString * contentString = [NSString new];
    if (@available(iOS 13.0 ,*)) {
        if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleUnspecified) {
            contentString = NSLocalizedString(@"topscan_darkmodefollowsystem", @"");
        }else if([TOPScanerShare top_darkModel] == UIUserInterfaceStyleDark){
            contentString = NSLocalizedString(@"topscan_darkmodeopened", @"");
        }else{
            contentString = NSLocalizedString(@"topscan_darkmodeclosed", @"");
        }
    }
    TOPSettingModel * darkModel = self.sectionOneArray.lastObject;
    darkModel.myContent = contentString;
    [self.tableView reloadData];
}
#pragma mark -- 暗黑模式设置界面
- (void)top_settingDarkModel{
    WS(weakSelf);
    TOPSettingDarkModeVC *darkVC = [[TOPSettingDarkModeVC alloc] init];
    darkVC.top_backToRefresh = ^{
        [weakSelf top_refreshDarkState];
    };
    [self.navigationController pushViewController:darkVC animated:YES];
}
#pragma mark -- OCR账户管理
- (void)top_settingView_AccountSet{
    TOPSettingOcrAccountVC *accountVC = [[TOPSettingOcrAccountVC alloc] init];
    accountVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:accountVC animated:YES];
}
#pragma mark -- 图片质量弹框
- (void)top_settingView_AddJPGQualityView{
    [FIRAnalytics logEventWithName:@"settingView_AddJPGQualityView" parameters:nil];
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.backView];
    [keyWindow addSubview:self.showJPGQualityView];
    [self top_markupCoverMask];
    [self.showJPGQualityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(keyWindow);
        make.top.equalTo(keyWindow.mas_bottom);
        make.height.mas_equalTo(50*6+TOPBottomSafeHeight+10);
    }];
    [keyWindow layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0.5;
        [self.showJPGQualityView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keyWindow);
            make.bottom.equalTo(keyWindow).offset(10);
            make.height.mas_equalTo(50*6+TOPBottomSafeHeight+10);
        }];
        [keyWindow layoutIfNeeded];
    }];
}
#pragma mark -- 设置默认邮箱
- (void)top_settingView_AddAndShowEmailView{
    [FIRAnalytics logEventWithName:@"settingView_AddAndShowEmailView" parameters:nil];
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.backView];
    [keyWindow addSubview:self.showEmailView];
    [self top_markupCoverMask];
    [self.showEmailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(keyWindow);
        make.top.equalTo(keyWindow.mas_bottom);
        make.height.mas_equalTo(TOPScreenHeight-(TOPNavBarAndStatusBarHeight+EmailLocationY));
    }];
    [keyWindow layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0.5;
        [self.showEmailView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keyWindow);
            make.bottom.equalTo(keyWindow);
            make.top.equalTo(keyWindow).offset(TOPNavBarAndStatusBarHeight+EmailLocationY);
        }];
        self.showEmailView.isKeyBoardShow = YES;
        [keyWindow layoutIfNeeded];
    }];
    
}
#pragma mark -- 设置pdf默认纸张大小和图片默认渲染模式
- (void)top_settingView_AddAndShowView:(NSArray *)listArray :(NSInteger)row{
    [FIRAnalytics logEventWithName:@"settingView_AddAndShowView" parameters:@{@"listArray":listArray,@"row":@(row)}];
    TOPSettingModel *model = self.sectionOneArray[row];
    TOPSettingVCAction actionType = model.settingAction;
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.backView];
    [self top_markupCoverMask];
    if (actionType == TOPSettingVCActionGeneralPageSize) {
        [keyWindow addSubview:self.pdfSizeView];
        [self.pdfSizeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keyWindow);
            make.top.equalTo(keyWindow.mas_bottom);
            make.height.mas_equalTo(560+TOPBottomSafeHeight+10);
        }];
        [keyWindow layoutIfNeeded];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.backView.alpha = 0.5;
            [self.pdfSizeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(keyWindow);
                make.bottom.equalTo(keyWindow).offset(10);
                make.height.mas_equalTo(560+TOPBottomSafeHeight+10);
            }];
            [keyWindow layoutIfNeeded];
        }];
    } else if (actionType == TOPSettingVCActionGeneralDefaultProcess) {
        [keyWindow addSubview:self.showProcessView];
        [self.showProcessView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keyWindow);
            make.top.equalTo(keyWindow.mas_bottom);
            make.height.mas_equalTo(ProcessCell_H+TOPBottomSafeHeight+10);
            
        }];
        [keyWindow layoutIfNeeded];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.backView.alpha = 0.5;
            [self.showProcessView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(keyWindow);
                make.bottom.equalTo(keyWindow).offset(10);
                make.height.mas_equalTo(ProcessCell_H+TOPBottomSafeHeight+10);
            }];
            [keyWindow layoutIfNeeded];
        }];
    }
}
#pragma mark -- 本地保存pdf尺寸
- (void)top_choosePdfSizeAndCreat:(TOPPdfSizeModel *)model{
    [TOPScanerShare top_writePageSizeType:model.pdfType];
    for (TOPSettingModel * setModel in self.sectionOneArray) {
        if (setModel.settingAction == TOPSettingVCActionGeneralPageSize) {
            setModel.myContent = self.pageSizeArray[[TOPScanerShare top_pageSizeType]-1];
            break;
        }
    }
    [self.tableView reloadData];
}
#pragma mark -- 渲染模式弹窗消失
- (void)top_settingView_ClickProcessDismissAndReloadData{
    [self top_settingView_ClickTap];
    for (TOPSettingModel * model in self.sectionOneArray) {
        if (model.settingAction == TOPSettingVCActionGeneralDefaultProcess) {
            NSInteger type = [TOPScanerShare top_lastFilterType] ? TOPProcessTypeLastFilter : [TOPScanerShare top_defaultProcessType];
            NSInteger typeIndex = [[self top_processTypeArray] indexOfObject:@(type)];
            model.myContent = self.defaultProcessArray[typeIndex];
            break;
        }
    }
    [self.tableView reloadData];
}
#pragma mark - 弹窗消失的手势
- (void)top_settingView_ClickTap{
    [FIRAnalytics logEventWithName:@"settingView_ClickTap" parameters:nil];
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    if (!_showEmailView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.backView.alpha = 0;
            if ([keyWindow.subviews containsObject:self.showJPGQualityView]) {
                [self.showJPGQualityView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(keyWindow);
                    make.top.equalTo(keyWindow.mas_bottom);
                    make.height.mas_equalTo(50*6+TOPBottomSafeHeight+10);
                }];
            }
            
            if ([keyWindow.subviews containsObject:self.pdfSizeView]) {
                [self.pdfSizeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(keyWindow);
                    make.top.equalTo(keyWindow.mas_bottom);
                    make.height.mas_equalTo(560+TOPBottomSafeHeight+10);
                }];
            }
            
            if ([keyWindow.subviews containsObject:self.showProcessView]) {
                [self.showProcessView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(keyWindow);
                    make.top.equalTo(keyWindow.mas_bottom);
                    make.height.mas_equalTo(ProcessCell_H+TOPBottomSafeHeight+10);
                }];
            }
            [keyWindow layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.backView removeFromSuperview];
            [self.showJPGQualityView removeFromSuperview];
            [self.pdfSizeView removeFromSuperview];
            [self.showProcessView removeFromSuperview];
            
            self.backView = nil;
            self.showJPGQualityView = nil;
            self.pdfSizeView = nil;
            self.showProcessView = nil;
        }];
    }
}

- (void)top_hideTOPSettingEmailView{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0;
        [self.showEmailView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keyWindow);
            make.top.equalTo(keyWindow.mas_bottom);
            make.height.mas_equalTo(TOPScreenHeight-(TOPNavBarAndStatusBarHeight+EmailLocationY));
        }];
        [keyWindow layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.showEmailView.isKeyBoardShow = YES;
        [self.backView removeFromSuperview];
        [self.showEmailView removeFromSuperview];
        
        self.backView = nil;
        self.showEmailView = nil;
    }];
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
- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_settingView_ClickTap)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

#pragma mark -- 默认渲染模式
- (TOPNextSettingShowView *)showProcessView {
    WS(weakSelf);
    if (!_showProcessView) {
        _showProcessView = [[TOPNextSettingShowView alloc]initWithFrame:CGRectMake(0,TOPScreenHeight, TOPScreenWidth, ProcessCell_H+TOPBottomSafeHeight+10)];
        _showProcessView.filterArray = [self top_processTypeArray];
        _showProcessView.dataArray = self.defaultProcessArray;
        _showProcessView.enterType = TOPFormatterViewEnterTypeDefaultProcess;
        _showProcessView.top_clickToDismiss = ^{
            [weakSelf top_settingView_ClickTap];
        };
        _showProcessView.top_selectedProcessBlock = ^{
            [weakSelf top_settingView_ClickProcessDismissAndReloadData];
        };
    }
    return _showProcessView;
}

#pragma mark -- 图片质量
- (TOPNextSettingShowView *)showJPGQualityView {
    WS(weakSelf);
    if (!_showJPGQualityView) {
        _showJPGQualityView = [[TOPNextSettingShowView alloc]initWithFrame:CGRectMake(0,TOPScreenHeight, TOPScreenWidth, 50*6+TOPBottomSafeHeight+10)];
        _showJPGQualityView.enterType = TOPFormatterViewEnterTypeJPGQuality;
        _showJPGQualityView.top_clickToDismiss = ^{
            [weakSelf top_settingView_ClickTap];
        };
        _showJPGQualityView.top_selectedJPGQualityBlock = ^(NSString * _Nonnull keyString, NSInteger row) {
            for (TOPSettingModel * docModel in weakSelf.sectionOneArray) {
                if (docModel.settingAction == TOPSettingVCActionGeneralJPGQuality) {
                    [weakSelf top_settingView_ClickTap];
                    docModel.myContent = keyString;
                    [weakSelf.tableView reloadData];
                    break;
                }
            }
        };
        _showJPGQualityView.top_permissionAlertBlock = ^{
            [weakSelf top_settingView_ClickTap];
            [weakSelf top_subscriptionService];
        };
    }
    return _showJPGQualityView;
}
#pragma mark -- email弹窗
- (TOPSettingEmailView *)showEmailView{
    WS(weakSelf);
    if (!_showEmailView) {
        _showEmailView = [[TOPSettingEmailView alloc]initWithFrame:CGRectMake(0,TOPScreenHeight, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-EmailLocationY)];
        _showEmailView.top_clickToDismiss = ^{
            [weakSelf top_hideTOPSettingEmailView];
        };
        
        _showEmailView.top_keyboardToChangeFream = ^{
        };
        
        _showEmailView.top_returnToOriginalFream = ^{
        };
    }
    return _showEmailView;
}

- (TOPPdfSizeSettingView *)pdfSizeView{
    if (!_pdfSizeView) {
        WS(weakSelf);
        _pdfSizeView = [[TOPPdfSizeSettingView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, TOPScreenWidth, 560+TOPBottomSafeHeight)];
        _pdfSizeView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        _pdfSizeView.top_choosePdfSize = ^(TOPPdfSizeModel * _Nonnull model) {
            [weakSelf top_settingView_ClickTap];
            [weakSelf top_choosePdfSizeAndCreat:model];
        };
        _pdfSizeView.top_dismissAction = ^{
            [weakSelf top_settingView_ClickTap];
        };
    }
    return _pdfSizeView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TOPScanSettingCell class] forCellReuseIdentifier:NSStringFromClass([TOPScanSettingCell class])];
        [_tableView registerClass:[TOPScanSettingLastCell class] forCellReuseIdentifier:NSStringFromClass([TOPScanSettingLastCell class])];
        [_tableView registerClass:[TOPScanDarkModelCell class] forCellReuseIdentifier:NSStringFromClass([TOPScanDarkModelCell class])];
        [_tableView registerClass:[TOPScreenShotStateCell class] forCellReuseIdentifier:NSStringFromClass([TOPScreenShotStateCell class])];
    }
    return _tableView;
}

- (NSMutableArray *)sectionOneArray{
    if (!_sectionOneArray) {
        _sectionOneArray = [NSMutableArray new];
    }
    return _sectionOneArray;
}
- (NSMutableArray *)sectionTwoArray{
    if (!_sectionTwoArray) {
        _sectionTwoArray = [NSMutableArray new];
    }
    return _sectionTwoArray;
}
- (void)top_loadData{
    self.pageSizeArray = @[NSLocalizedString(@"topscan_letter", @"")
                           ,NSLocalizedString(@"topscan_a4", @"")
                           ,NSLocalizedString(@"topscan_legal", @"")
                           ,NSLocalizedString(@"topscan_a3", @"")
                           ,NSLocalizedString(@"topscan_a5", @"")
                           ,NSLocalizedString(@"topscan_businesscard", @"")
                           ,NSLocalizedString(@"topscan_b4", @"")
                           ,NSLocalizedString(@"topscan_b5", @"")
                           ,NSLocalizedString(@"topscan_tabloid", @"")
                           ,NSLocalizedString(@"topscan_executive", @"")
                           ,NSLocalizedString(@"topscan_postcard", @"")
                           ,NSLocalizedString(@"topscan_flsa", @"")
                           ,NSLocalizedString(@"topscan_flse", @"")
                           ,NSLocalizedString(@"topscan_arch_a", @"")
                           ,NSLocalizedString(@"topscan_arch_b", @"")];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[TOPPictureProcessTool top_processTitles]];
    [tempArray addObject:NSLocalizedString(@"topscan_lastfilter", @"")];
    self.defaultProcessArray = tempArray;
    
    NSDictionary *dic0 = @{@"checkValue":@(TOPSettingCellTypeFirstKind),
                           @"settingAction":@(TOPSettingVCActionOCRAccount),
                           @"title":NSLocalizedString(@"topscan_ocraccount", @""),
                           @"content":@""};
    NSDictionary *dic1 = @{@"checkValue":@(TOPSettingCellTypeFirstKind),
                           @"settingAction":@(TOPSettingVCActionGeneralPageSize),
                           @"title":NSLocalizedString(@"topscan_defaultpagesize", @""),
                           @"content":self.pageSizeArray[[TOPScanerShare top_pageSizeType]-1]};
    NSInteger type = [TOPScanerShare top_lastFilterType] ? TOPProcessTypeLastFilter : [TOPScanerShare top_defaultProcessType];
    NSInteger typeIndex = [[self top_processTypeArray] indexOfObject:@(type)];
    NSDictionary *dic2 = @{@"checkValue":@(TOPSettingCellTypeFirstKind),
                           @"settingAction":@(TOPSettingVCActionGeneralDefaultProcess),
                           @"title":NSLocalizedString(@"topscan_defaultprocess", @""),
                           @"content":self.defaultProcessArray[typeIndex]};
    NSDictionary *dic3 = @{@"checkValue":@(TOPSettingCellTypeFirstKind),
                           @"settingAction":@(TOPSettingVCActionGeneralJPGQuality),
                           @"title":NSLocalizedString(@"topscan_picquality", @""),
                           @"content":[self top_picQualityDes:TOP_TRSSMaxPiexl]};
    NSDictionary *dic4 = @{@"checkValue":@(TOPSettingCellTypeFirstKind),
                           @"settingAction":@(TOPSettingVCActionGeneralEmail),
                           @"title":NSLocalizedString(@"topscan_email", @""),
                           @"content":@""};
    NSString * contentString = [NSString new];
    if (@available(iOS 13.0 ,*)) {
        if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleUnspecified) {
            contentString = NSLocalizedString(@"topscan_darkmodefollowsystem", @"");
        }else if([TOPScanerShare top_darkModel] == UIUserInterfaceStyleDark){
            contentString = NSLocalizedString(@"topscan_darkmodeopened", @"");
        }else{
            contentString = NSLocalizedString(@"topscan_darkmodeclosed", @"");
        }
    }
    NSDictionary *dic5 = @{@"checkValue":@(TOPSettingCellTypeFirstKind),
                           @"settingAction":@(TOPSettingVCBackgroundDarkStyle),
                           @"title":NSLocalizedString(@"topscan_darkmode", @""),
                           @"content":contentString};
    NSDictionary *dic6 = @{@"checkValue":@(TOPSettingCellTypeFirstKind),
                           @"settingAction":@(TOPSettingVCBackgroundScreenShotState),
                           @"title":NSLocalizedString(@"topscan_shottipshare", @""),
                           @"content":@""};
    NSArray *generalData = [NSArray new];
    NSArray *sectionTwo = [NSArray new];
    if (@available(iOS 13.0 , *)) {
        generalData = @[dic0,dic1, dic2, dic3, dic4];
        sectionTwo = @[dic6,dic5];
    }else{
        generalData = @[dic0,dic1, dic2, dic3, dic4];
        sectionTwo = @[dic6];
    }
    for (NSDictionary *dic in generalData) {
        TOPSettingModel * docModel = [self top_buildSettingModel:dic];
        [self.sectionOneArray addObject:docModel];
    }
    for (NSDictionary *dic in sectionTwo) {
        TOPSettingModel * docModel = [self top_buildSettingModel:dic];
        [self.sectionTwoArray addObject:docModel];
    }
}

- (TOPSettingModel *)top_buildSettingModel:(NSDictionary *)dic {
    TOPSettingModel * docModel = [[TOPSettingModel alloc] init];
    docModel.myTitle = dic[@"title"];
    docModel.myContent = dic[@"content"];
    docModel.checkValue = [dic[@"checkValue"] integerValue];
    docModel.settingAction = [dic[@"settingAction"] integerValue];
    return docModel;
}

- (NSString *)top_picQualityDes:(CGFloat)pix {
    NSString *temp = NSLocalizedString(@"topscan_medium", @"");
    if (pix == 10000000) {
        temp = NSLocalizedString(@"topscan_superhigh", @"");
    } else if (pix == 8000000) {
        temp = NSLocalizedString(@"topscan_picturequalityheight", @"");
    } else if (pix == 6000000) {
        temp = NSLocalizedString(@"topscan_medium", @"");
    } else if (pix == 4000000) {
        temp = NSLocalizedString(@"topscan_picturequalitylow", @"");
    }
    return temp;
}
- (NSArray *)top_processTypeArray{
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[TOPPictureProcessTool top_processTypeArray]];
    [tempArray addObject:@(TOPProcessTypeLastFilter)];
    return tempArray;
}

- (void)top_markupCoverMask{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}

@end
