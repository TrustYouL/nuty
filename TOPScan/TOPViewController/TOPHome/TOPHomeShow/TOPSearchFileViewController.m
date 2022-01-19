//
//  TOPSearchFileViewController.m
//  SimpleScan
//
//  Created by admin3 on 2020/8/6.
//  Copyright © 2020 admin3. All rights reserved.
//
#define AddFolder_W 310
#define AddFolder_H 240
#define AddFolderSingle_H 190
#import "TOPSearchFileViewController.h"
#import "TOPDocumentCollectionView.h"
#import "TOPDocumentTableView.h"
#import "TOPHomeChildViewController.h"
#import "TOPSearchBarView.h"
#import "TOPNextCollectionView.h"

@interface TOPSearchFileViewController ()<UISearchBarDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic ,strong) UIView * contentFatherView;//列表视图的父视图
@property (nonatomic, strong) TOPDocumentCollectionView *collectionView;
@property (nonatomic, strong) TOPDocumentTableView *tableView;
@property (nonatomic, strong) TOPNextCollectionView *nextCollView;
@property (nonatomic, strong) TOPDocPasswordView * passwordView;//密码弹框
@property (nonatomic, strong) DocumentModel * docModel;
@property (nonatomic, strong) UISearchBar * searchBar;
@property (nonatomic, strong) UIView * coverView;
@property (nonatomic, strong) UIView * barView;
@property (nonatomic, copy) NSString * searchStr;//保存搜索字符
@property (nonatomic, strong) NSMutableArray * searchArray;
@property (nonatomic, assign) BOOL isShowFailToast;//密码错误时是否弹出提示
@end

@implementation TOPSearchFileViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self top_searchFile_AddSearchBar:CGRectMake(0, 0, TOPScreenWidth, TOPNavBarHeight)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self top_setBackButton];
    [self searchFile_top_setupUI];
}
- (void)top_setBackButton{
    TOPImageTitleButton * btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageLeftTitleRightLeft)];
    btn.frame = CGRectMake(0, 0, 44, 60);
    if (isRTL()) {
        [btn setImage:[UIImage imageNamed:@"top_nav_reverseback_ico"] forState:UIControlStateNormal];
        btn.style = EImageLeftTitleRightCenter;
    }else{
        [btn setImage:[UIImage imageNamed:@"top_nav_back_ico"] forState:UIControlStateNormal];
        btn.style = EImageLeftTitleRightLeft;
    }
    [btn addTarget:self action:@selector(searchFile_BackNextAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //监听键盘，键盘出现
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    //监听键盘隐藏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.navigationBarHidden = NO;
//    self.navigationController.navigationBar.barTintColor = TOPAPPGreenColor;
    [self.searchBar becomeFirstResponder];
    [self top_loadSanBoxData];
    self.searchBar.text = self.searchStr;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self.barView removeFromSuperview];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark -- 横竖屏切换时重新设置titleView
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self top_searchFile_AddSearchBar:CGRectMake(0, 0, size.width, size.height)];
//    self.navigationItem.titleView = self.barView;
}
#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.height.mas_equalTo(TOPScreenHeight - TOPNavBarAndStatusBarHeight-keyboardrect.size.height);
        }];
    }];
    
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
    if (![self.passwordView.tField isFirstResponder]&&![self.passwordView.againField isFirstResponder]) {
        [self.contentFatherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(self.view);
        }];
        [self top_ClickTapAction];
    }
}

- (void)top_passwordViewActionWithPassword:(NSString *)password WithType:(NSInteger)actionType{
    switch (actionType) {
        case TOPMenuItemsFunctionPushVC:
            [self top_SetLockPushChildVC:password];
            break;
        default:
            break;
    }
}

#pragma mark -- 有密码时的界面跳转
- (void)top_SetLockPushChildVC:(NSString *)password{
    [FIRAnalytics logEventWithName:@"home_SetLockPushChildVC" parameters:nil];
    if ([password isEqualToString:[TOPScanerShare top_docPassword]]) {
        [self top_ClickTapAction];
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

- (void)top_ClickTapAction{
    [UIView animateWithDuration:0.3 animations:^{
        [self.passwordView removeFromSuperview];
        [self.coverView removeFromSuperview];
        self.passwordView = nil;
        self.coverView = nil;
    }];
}
#pragma mark -- loadData
- (void)top_loadSanBoxData{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"topscan_loading", @"")];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * tempSearchArray = [NSMutableArray new];
        NSMutableArray * tempAllDataArray = [NSMutableArray new];
        RLMResults<TOPAppDocument *> *documents = nil;
        //根据保存的标签名称获取该标签下的数据
        NSString * tagsName = [TOPScanerShare top_saveTagsName];
        if ([tagsName isEqualToString:TOP_TRTagsAllDocesKey]) {
            NSString *docId = self.fatherDocModel.docId;
            documents = [docId isEqualToString:@"000000"] ? [TOPDBQueryService top_allDocumentsBySorted] : [TOPDBQueryService top_documentsByParentId:docId];
        } else if ([tagsName isEqualToString:TOP_TRTagsUngroupedKey]) {
            documents = [TOPDBQueryService top_unGroupedDocumentsBySorted];
        } else {
            documents = [TOPDBQueryService top_documentsBySortedWithTag:tagsName];
        }
        tempAllDataArray = [TOPDBDataHandler top_buildTagDocModleDataWithDB:documents];
        if (self.searchStr.length == 0) {
            //所有数据
            [tempSearchArray addObjectsFromArray:tempAllDataArray];
        }else{
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name CONTAINS [cd] %@",self.searchStr];
            [tempSearchArray addObjectsFromArray:[tempAllDataArray filteredArrayUsingPredicate:predicate]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            self.searchArray = tempSearchArray;
            [self top_refreshSearchUI:tempSearchArray];
        });
    });
}

#pragma mark -- 搜索时不用在此获取数据 直接用进入界面保存的数据
- (void)top_searchFile_LoadSanBoxData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * tempSearchArray = [NSMutableArray new];
        //所有的doc文档数据
        if (self.searchStr.length == 0) {
            //所有数据
            [tempSearchArray addObjectsFromArray:self.searchArray];
        }else{
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name CONTAINS [cd] %@",self.searchStr];
            [tempSearchArray addObjectsFromArray:[self.searchArray filteredArrayUsingPredicate:predicate]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self top_refreshSearchUI:tempSearchArray];
        });
    });
}

- (void)top_refreshSearchUI:(NSMutableArray *)dataArray{
    self.collectionView.listArray = dataArray;
    [self.collectionView setShowType:[TOPScanerShare top_listType]];
    
    self.tableView.listArray = dataArray;
    self.tableView.isCan = NO;
    [self.tableView reloadData];
    
    self.nextCollView.listArray = dataArray;
    [self.nextCollView reloadData];
    
    if ([TOPScanerShare top_listType] == ShowListGoods) {
        self.tableView.hidden = NO;
        self.nextCollView.hidden = YES;
        self.collectionView.hidden = YES;
    }else if([TOPScanerShare top_listType] == ShowListNextGoods){
        self.tableView.hidden = YES;
        self.nextCollView.hidden = NO;
        self.collectionView.hidden = YES;
    }else{
        self.tableView.hidden = YES;
        self.nextCollView.hidden = YES;
        self.collectionView.hidden = NO;
    }
}

- (void)top_searchFile_AddSearchBar:(CGRect)fream{
    TOPSearchBarView * barView = [[TOPSearchBarView alloc]init];
    self.navigationItem.titleView = barView;
    UISearchBar * searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth-100, 35)];
    searchBar.tintColor = [UIColor whiteColor];
    searchBar.placeholder = NSLocalizedString(@"topscan_search", @"");
    searchBar.layer.cornerRadius = 35/2;
    searchBar.backgroundImage = [[UIImage alloc]init];
    searchBar.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(255,255 ,255 , 0.1)];
    searchBar.showsCancelButton = NO;
    searchBar.barStyle = UIBarStyleDefault;
    searchBar.keyboardType = UIKeyboardTypeDefault;
    searchBar.returnKeyType = UIReturnKeyDefault;
    searchBar.delegate = self;
    [searchBar setImage:[UIImage imageNamed:@"top_sousuo"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];

    if (@available(iOS 13.0, *)) {
        UITextField * searchField = searchBar.searchTextField;
        if (searchField) {
            NSMutableDictionary * dic = [@{NSForegroundColorAttributeName:[UIColor top_textColor:TOPAPPViewSecondDarkColor defaultColor:[UIColor whiteColor]],NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} mutableCopy];
            NSMutableAttributedString * attplace = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"topscan_search", @"") attributes:dic];
            searchField.attributedPlaceholder = attplace;
            [searchField setBackgroundColor:[UIColor clearColor]];
            searchField.textColor = [UIColor whiteColor];
            searchField.font = [UIFont systemFontOfSize:14];
        }
    } else {
        UITextField * searchField = [searchBar valueForKey:@"_searchField"];
        if (searchField) {
            [searchField setBackgroundColor:[UIColor clearColor]];
            searchField.textColor = [UIColor whiteColor];
            searchField.font = [UIFont systemFontOfSize:14];
            [searchField setValue:[UIColor top_textColor:TOPAPPViewSecondDarkColor defaultColor:[UIColor whiteColor]] forKeyPath:@"_placeholderLabel.textColor"];
        }
    }
    [barView addSubview:searchBar];
    CGFloat searchL = 0;
    if (!isRTL()) {
        searchL = -15;
    }
    [searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(barView).offset(searchL);
        make.trailing.equalTo(barView).offset(-20);
        make.top.equalTo(barView).offset(4.5);
        make.height.mas_equalTo(35);
    }];
    self.searchBar = searchBar;
}

- (void)searchFile_top_setupUI{
    [self.view addSubview:self.contentFatherView];
    [self.contentFatherView addSubview:self.collectionView];
    [self.contentFatherView addSubview:self.nextCollView];
    [self.contentFatherView addSubview:self.tableView];

    [self.contentFatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentFatherView);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentFatherView);
    }];
    [self.nextCollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentFatherView);
    }];
}

- (TOPDocumentCollectionView *)collectionView{
    if (!_collectionView) {
        WS(weakSelf);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
       
        _collectionView = [[TOPDocumentCollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight) collectionViewLayout:layout];
        _collectionView.isMoveState = NO;
        _collectionView.isShowHeaderView = NO;
        _collectionView.top_pushNextControllerHandler = ^(DocumentModel * model) {
            weakSelf.docModel = model;
            [weakSelf top_judgeClickDocPasswordState];
        };
    }
    return _collectionView;
}

- (TOPDocumentTableView *)tableView{
    if (!_tableView) {
        WS(weakSelf);
        _tableView = [[TOPDocumentTableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight) style:UITableViewStylePlain];
        _tableView.isShowHeaderView = NO;
        _tableView.top_pushNextControllerHandler = ^(DocumentModel * model) {
            weakSelf.docModel = model;
            [weakSelf top_judgeClickDocPasswordState];
        };
    }
    return _tableView;
}
- (TOPNextCollectionView *)nextCollView{
    if (!_nextCollView) {
        WS(weakSelf);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
       
        _nextCollView = [[TOPNextCollectionView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - TOPNavBarAndStatusBarHeight) collectionViewLayout:layout];
        _nextCollView.isMainVC = NO;
        _nextCollView.top_pushNextControllerHandler = ^(DocumentModel * model) {
            weakSelf.docModel = model;
            [weakSelf top_judgeClickDocPasswordState];
        };
    }
    return _nextCollView;
}
#pragma mark -- 点击doc时有无密码的判断
- (void)top_judgeClickDocPasswordState{
    NSString * passwordPath = self.docModel.docPasswordPath;
    if (passwordPath.length>0) {
        UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
        [keyWindow addSubview:self.coverView];
        [keyWindow addSubview:self.passwordView];
        self.passwordView.actionType = TOPMenuItemsFunctionPushVC;
    }else{
        [self top_clickDocPushChildVCWithPath];
    }
}

#pragma mark -- 跳转到childVC
- (void)top_clickDocPushChildVCWithPath{
    TOPHomeChildViewController *childVC = [[TOPHomeChildViewController alloc] init];
    childVC.docModel = self.docModel;
    childVC.pathString = self.docModel.path;
    childVC.upperPathString = self.pathString;
    childVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:childVC animated:YES];
}
#pragma mark --UISearchBarDelegate
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString * sendStr = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    self.searchStr = sendStr;
    [self top_searchFile_LoadSanBoxData];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchStr = searchBar.text;
    [self top_searchFile_LoadSanBoxData];
    [searchBar resignFirstResponder];
}
 
- (void)searchFile_BackNextAction{
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark -- lazy
- (NSMutableArray *)searchArray{
    if (!_searchArray) {
        _searchArray = [NSMutableArray new];
    }
    return _searchArray;
}
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_ClickTapAction)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
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
            [weakSelf top_ClickTapAction];
        };
        
        _passwordView.top_clickToHelp = ^{
            [weakSelf top_settingView_SendFeedback];
        };
    }
    return _passwordView;
}
#pragma mark -- lazy
- (UIView *)contentFatherView {
    if (!_contentFatherView) {
        _contentFatherView = [[UIView alloc] init];
        _contentFatherView.backgroundColor = [UIColor clearColor];
    }
    return _contentFatherView;
}

@end
