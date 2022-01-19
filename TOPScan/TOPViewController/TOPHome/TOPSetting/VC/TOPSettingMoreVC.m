//
//  TOPSettingMoreVC.m
//  SimpleScan
//
//  Created by admin3 on 2022/1/10.
//  Copyright © 2022 admin3. All rights reserved.
//

#import "TOPSettingMoreVC.h"
#import "TOPSettingCell.h"
#import "TOPSettingWebViewController.h"
#import "TOPSettingWebViewController.h"
#import "TOPSettingWebViewController.h"
#import "TOPSuggestionsVC.h"
@interface TOPSettingMoreVC ()<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate>
@property (nonatomic ,strong)NSMutableArray * dataArray;
@property (nonatomic ,strong)UITableView * tableView;

@end

@implementation TOPSettingMoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self top_setTopView];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(self.view);
    }];
    [self top_generalSData];
}
#pragma mark -- 导航栏视图
- (void)top_setTopView{
    self.title = NSLocalizedString(@"topscan_more", @"");
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(settingView_BackHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(settingView_BackHomeAction)];
    }
}
- (void)settingView_BackHomeAction{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 更多的展开数据源
- (void)top_generalSData{
    NSString * rowIcon = [NSString new];
    if (isRTL()) {
        rowIcon = @"top_reverpushVCRow";
    }else{
        rowIcon = @"top_pushVCRow";
    }
    NSDictionary *dic1 = @{@"settingIcon":@"top_settingFAQ",
                           @"rowIcon":rowIcon,
                           @"arrayCount":@(4),
                           @"settingAction":@(TOPSettingVCActionSupportFAQ),
                           @"title":NSLocalizedString(@"topscan_faq", @"")};
    NSDictionary *dic2 = @{@"settingIcon":@"top_settingPrivacy",
                           @"rowIcon":rowIcon,
                           @"arrayCount":@(4),
                           @"settingAction":@(TOPSettingVCActionSupportPrivacy),
                           @"title":NSLocalizedString(@"topscan_privacypolicy", @"")};
    NSDictionary *dic3 = @{@"settingIcon":@"top_settingUserAgreement",
                           @"rowIcon":rowIcon,
                           @"arrayCount":@(4),
                           @"settingAction":@(TOPSettingVCActionSupportUserAgreement),
                           @"title":NSLocalizedString(@"topscan_settinguseragreement", @"")};
    NSDictionary *dic4 = @{@"settingIcon":@"top_userSuggestion",
                           @"rowIcon":rowIcon,
                           @"arrayCount":@(4),
                           @"settingAction":@(TOPSettingVCActionSupportUserSuggestion),
                           @"title":NSLocalizedString(@"topscan_settingusersuggestion", @"")};
    NSArray * temp = @[dic1,dic2,dic3,dic4];
    self.dataArray = [temp mutableCopy];
    [self.tableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TOPSettingCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPSettingCell class])];
    cell.indexPath = indexPath;
    cell.dic = self.dataArray[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 15)];
    headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];;
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerF = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 20)];
    footerF.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];;
    return footerF;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dic = self.dataArray[indexPath.row];
    [self didSelectSettingRow:dic];
}

- (void)didSelectSettingRow:(NSDictionary *)dic{
    TOPSettingVCAction actionType = [dic[@"settingAction"] integerValue];
    switch (actionType) {
        case TOPSettingVCActionSupportFAQ:
            [self top_supportFAQ];
            break;
        case TOPSettingVCActionSupportPrivacy:
            [self top_supportPrivacyPolicy];
            break;
        case TOPSettingVCActionSupportUserAgreement:
            [self top_supportUserAgreement];
            break;
        case TOPSettingVCActionSupportUserSuggestion:
            [self top_useFreedback];
            break;
        default:
            
            break;
    }
}
#pragma mark -- FAQ
- (void)top_supportFAQ{
    NSString * titleString = NSLocalizedString(@"topscan_faq", @"");
    [FIRAnalytics logEventWithName:@"settingView_WebViewSupportFAQ" parameters:nil];

    TOPSettingWebViewController * webVC = [TOPSettingWebViewController new];
    webVC.titleString = titleString;
    webVC.urlString = TOP_TRFAQURL;
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark -- Privacy Policy
- (void)top_supportPrivacyPolicy{
    NSString * titleString = NSLocalizedString(@"topscan_privacypolicy", @"");
    [FIRAnalytics logEventWithName:@"settingView_PrivacyPolicy" parameters:nil];

    TOPSettingWebViewController * webVC = [TOPSettingWebViewController new];
    webVC.titleString = titleString;
    webVC.urlString = TOP_TRPrivacyPolicyURL;
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark -- 用户反馈
- (void)top_useFreedback{
    TOPSuggestionsVC * suVC = [TOPSuggestionsVC new];
    suVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:suVC animated:YES];
}
- (void)top_supportUserAgreement{
    NSString * titleString = NSLocalizedString(@"topscan_settinguseragreement", @"");
    [FIRAnalytics logEventWithName:@"settingView_UserAgreement" parameters:nil];

    TOPSettingWebViewController * webVC = [TOPSettingWebViewController new];
    webVC.titleString = titleString;
    webVC.urlString = TOP_TRUserAgreementURL;
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        [_tableView registerClass:[TOPSettingCell class] forCellReuseIdentifier:NSStringFromClass([TOPSettingCell class])];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
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
