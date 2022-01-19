#import "TOPTranslateModelsViewController.h"
#import "TOPTranslateModelCell.h"
#import "TOPTranslateModel.h"
#import <MLKitTranslate/MLKTranslateLanguage.h>
#import <MLKitTranslate/MLKTranslator.h>
#import <MLKitTranslate/MLKTranslatorOptions.h>
#import <MLKitLanguageID/MLKitLanguageID.h>
#import <MLKitCommon/MLKitCommon.h>
#import <MLKitTranslate/MLKitTranslate.h>

#define KCellHeight 55

@interface TOPTranslateModelsViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *recentLanguageArr;
@property (nonatomic, strong) NSMutableArray *allLanguageArr;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic,assign) BOOL isSearching;//正在搜索
@property (nonatomic,strong) NSMutableArray *resultArray;//搜索结果
@property (nonatomic,strong) MLKTranslateRemoteModel *loadingModel;

@end

@implementation TOPTranslateModelsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self top_initMyNavigationBar];
    [self top_initMyUIView];
    [self top_initMyData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = [TOPDocumentHelper top_barStyle];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view).offset(110);
            make.bottom.equalTo(self.view).offset(-keyboardrect.size.height);
        }];
    }];
}
#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self.view);
            make.top.equalTo(self.view).offset(110);
        }];
    }];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    if ([TOPDocumentHelper top_isdark]) {
        [UIApplication sharedApplication].windows[0].backgroundColor = TOPAppDarkBackgroundColor;
    }else{
        [UIApplication sharedApplication].windows[0].backgroundColor = [UIColor whiteColor];
    }
}
#pragma mark -- 设置导航栏
- (void)top_initMyNavigationBar {
    [self top_initLeftBtn];
    [self top_initCancleBackBtn:@selector(top_clickCancleBtn)];
}

#pragma mark
- (void)top_initLeftBtn{
    NSString *btnTitle = self.sourceLanguage.length ? NSLocalizedString(@"topscan_translatesourcelanguage", @"") : NSLocalizedString(@"topscan_translatetargetlanguage", @"");
    UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, 55)];
    noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
    noClassLab.textAlignment = NSTextAlignmentNatural;
    noClassLab.font = PingFang_M_FONT_(18);
    noClassLab.text = btnTitle;
    [self.view addSubview:noClassLab];
    [noClassLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(15);
        make.top.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(150, 55));
    }];
}

#pragma mark -- 导航栏返回按钮
- (void)top_initCancleBackBtn:(SEL)selector {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(TOPScreenWidth - 70, 0, 52, 55)];
     [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 25)];
    [btn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    [btn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [btn.titleLabel setFont:PingFang_M_FONT_(16)];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(52, 55));
    }];
}

- (void)top_clickCancleBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 布局视图
- (void)top_initMyUIView {
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:RGB(251, 252, 252)];
    UIView *searchBarBgView = [self top_searchBgView];
    [searchBarBgView addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(searchBarBgView).offset(5);
        make.top.equalTo(searchBarBgView).offset(10);
        make.trailing.equalTo(searchBarBgView).offset(-35);
        make.height.mas_equalTo(35);
    }];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(110);
    }];
}

#pragma mark -- 初始化数据源
- (void)top_initMyData {
    NSArray *models = [TOPScanerShare top_codeLanguageMap].allKeys;
    for (MLKTranslateLanguage model in models) {
        TOPTranslateModel *translate = [self top_buildTranslateModel:model];
        [self.allLanguageArr addObject:translate];
    }
    NSArray *temps = [NSArray arrayWithArray:self.allLanguageArr];
    temps = [temps sortedArrayUsingComparator:^NSComparisonResult(TOPTranslateModel *  _Nonnull obj1, TOPTranslateModel *  _Nonnull obj2) {
        NSString *string1 = [[obj1.language substringToIndex:1] lowercaseString];
        NSString *string2 = [[obj2.language substringToIndex:1] lowercaseString];
        return [string1 compare:string2];
    }];
    self.allLanguageArr = [temps mutableCopy];
    NSArray *recentArr = [TOPScanerShare top_recentLanguageModels];
    if (!recentArr.count) {
        recentArr = @[[TOPScanerShare top_sourceLanguage], [TOPScanerShare top_targetLanguage],  MLKTranslateLanguageAfrikaans, MLKTranslateLanguageArabic, MLKTranslateLanguageBelarusian];
        [TOPScanerShare top_writeLanguageModelsSave:recentArr];
    }
    for (MLKTranslateLanguage model in recentArr) {
        TOPTranslateModel *translate = [self top_buildTranslateModel:model];
        [self.recentLanguageArr addObject:translate];
    }
    [self.tableView reloadData];
}

#pragma mark -- 构造数据模型
- (TOPTranslateModel *)top_buildTranslateModel:(MLKTranslateLanguage)model {
    NSString *languageName = [NSLocale.currentLocale localizedStringForLanguageCode:model];
    TOPTranslateModel *translate = [[TOPTranslateModel alloc] init];
    translate.language = languageName;
    translate.languageCode = model;
    if (self.sourceLanguage.length) {
        if ([self.sourceLanguage isEqualToString:model]) {
            translate.isSelected = YES;
        }
    } else {
        if ([self.targetLanguage isEqualToString:model]) {
            translate.isSelected = YES;
        }
    }
    translate.isDownloaded = [self top_isLanguageDownloaded:model];
    return translate;
}

- (BOOL)top_isLanguageDownloaded:(MLKTranslateLanguage)language {
  MLKTranslateRemoteModel *model = [self modelForLanguage:language];
  MLKModelManager *modelManager = [MLKModelManager modelManager];
  return [modelManager isModelDownloaded:model];
}

- (MLKTranslateRemoteModel *)modelForLanguage:(MLKTranslateLanguage)language {
  return [MLKTranslateRemoteModel translateRemoteModelWithLanguage:language];
}

#pragma mark -- 下载语言模型
- (void)top_downloadLanguageModel {
    TOPTranslateModel *model = self.selectedIndex.section == 1 ? self.allLanguageArr[self.selectedIndex.row] : self.recentLanguageArr[self.selectedIndex.row];
    MLKModelDownloadConditions *conditions =
        [[MLKModelDownloadConditions alloc] initWithAllowsCellularAccess:NO
                                             allowsBackgroundDownloading:YES];
    MLKTranslateRemoteModel *frenchModel =
        [MLKTranslateRemoteModel translateRemoteModelWithLanguage:model.languageCode];
    [[MLKModelManager modelManager] downloadModel:frenchModel
                                                       conditions:conditions];
    [self top_downloadSuccess];
    [self top_downloadFail];
}

#pragma mark -- 下载/删除完成后刷新
- (void)top_updateDownloadModel:(BOOL)isloaded {
    MLKTranslateRemoteModel *model = self.loadingModel;
    for (TOPTranslateModel *obj in self.recentLanguageArr) {
        if ([obj.languageCode isEqualToString:model.language]) {
            obj.isDownloaded = isloaded;
            obj.isLoading = NO;
            break;
        }
    }
    for (TOPTranslateModel *obj in self.allLanguageArr) {
        if ([obj.languageCode isEqualToString:model.language]) {
            obj.isDownloaded = isloaded;
            obj.isLoading = NO;
            break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)top_updateStoploadModel {
    for (TOPTranslateModel *obj in self.recentLanguageArr) {
        if (obj.isLoading) {
            obj.isLoading = NO;
        }
    }
    for (TOPTranslateModel *obj in self.allLanguageArr) {
        if (obj.isLoading) {
            obj.isLoading = NO;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark -- 下载成功回调
- (void)top_downloadSuccess {
    __weak typeof(self) weakSelf = self;
    [NSNotificationCenter.defaultCenter addObserverForName:MLKModelDownloadDidSucceedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_ocr", @"")];
            [SVProgressHUD dismissWithDelay:1];
        });
        if (weakSelf == nil || note.userInfo == nil) {
            return;
        }
        MLKTranslateRemoteModel *model = note.userInfo[MLKModelDownloadUserInfoKeyRemoteModel];
        if ([model isKindOfClass:[MLKTranslateRemoteModel class]]) {
            self.loadingModel = model;
        }
        [weakSelf top_updateDownloadModel:YES];
    }];
}

#pragma mark -- 下载失败回调
- (void)top_downloadFail {
    __weak typeof(self) weakSelf = self;
    [NSNotificationCenter.defaultCenter addObserverForName:MLKModelDownloadDidFailNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_ocrdownfail", @"")];
            [SVProgressHUD dismissWithDelay:1];
        });
        if (weakSelf == nil || note.userInfo == nil) {
            return;
        }
        [weakSelf top_updateStoploadModel];
    }];
}

#pragma mark -- 删除语言包
- (void)top_deleteTranslateModel {
    TOPTranslateModel *model = self.selectedIndex.section == 1 ? self.allLanguageArr[self.selectedIndex.row] : self.recentLanguageArr[self.selectedIndex.row];
    MLKTranslateRemoteModel *frenchModel =
        [MLKTranslateRemoteModel translateRemoteModelWithLanguage:model.languageCode];
    __weak typeof(self) weakSelf = self;
    [[MLKModelManager modelManager] deleteDownloadedModel:frenchModel completion:^(NSError * _Nullable error) {
        if (error != nil) {
            return;
        }
        weakSelf.loadingModel = frenchModel;
        [weakSelf top_updateDownloadModel:NO];
    }];
}

#pragma mark -- 删除语言包提示
- (void)top_deleteTranslateModelAlert {
    TOPTranslateModel *model = self.selectedIndex.section == 1 ? self.allLanguageArr[self.selectedIndex.row] : self.recentLanguageArr[self.selectedIndex.row];
    NSString *msg = [NSString stringWithFormat:@"%@ (%@)",NSLocalizedString(@"topscan_deletelanguagepack", @""),model.language];
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_yes", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        
        [self top_deleteTranslateModel];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_no", @"") style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearching) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.resultArray.count;
    }
    if (!section) {
        return self.recentLanguageArr.count;
    }
    return self.allLanguageArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TOPTranslateModel *model = [[TOPTranslateModel alloc] init];
    if (self.isSearching) {
        if (indexPath.row < self.resultArray.count) {
            model = self.resultArray[indexPath.row];
        }
    } else {
        model = indexPath.section == 1 ? self.allLanguageArr[indexPath.row] : self.recentLanguageArr[indexPath.row];
    }
    TOPTranslateModelCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPTranslateModelCell class]) forIndexPath:indexPath];
    [cell top_configCellWithData:model];
    __weak typeof(self) weakSelf = self;
    cell.top_clickDownloadBlock = ^{
        weakSelf.selectedIndex = indexPath;
        [weakSelf top_downloadLanguageModel];
    };
    cell.top_deleteLanguageModelBlock = ^{
        weakSelf.selectedIndex = indexPath;
        [weakSelf top_deleteTranslateModelAlert];
    };
    return cell;
}


#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return KCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TOPTranslateModel *model = [[TOPTranslateModel alloc] init];
    if (self.isSearching) {
        model = self.resultArray[indexPath.row];
    } else {
        model = indexPath.section == 1 ? self.allLanguageArr[indexPath.row] : self.recentLanguageArr[indexPath.row];
    }
    if (self.top_selectedLanguageBlock) {
        self.top_selectedLanguageBlock(model.languageCode);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- headerInSection
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.isSearching ? 0 :34;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.isSearching) {
        return nil;
    }
    NSArray *titles = @[NSLocalizedString(@"topscan_ocrrecentanguages", @""), NSLocalizedString(@"topscan_ocralllanguages", @"")];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 34)];
    bgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:RGB(251, 252, 252)];
    
    UILabel *sectionTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, TOPScreenWidth - 30, 30)];
    sectionTitleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kTabbarNormal];
    sectionTitleLab.textAlignment = NSTextAlignmentNatural;
    sectionTitleLab.font = PingFang_R_FONT_(13);
    sectionTitleLab.text = titles[section];
    [bgView addSubview:sectionTitleLab];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 0.5)];
    topLine.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGB(224, 224, 224)];
    [bgView addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 33.5, TOPScreenWidth, 0.5)];
    bottomLine.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGB(224, 224, 224)];
    [bgView addSubview:bottomLine];
    [sectionTitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bgView).offset(15);
        make.trailing.equalTo(bgView).offset(-15);
        make.top.equalTo(bgView).offset(2);
        make.height.mas_equalTo(30);
    }];
    [topLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(bgView);
        make.height.mas_equalTo(0.5);
    }];
    [topLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(bgView);
        make.height.mas_equalTo(0.5);
    }];
    return bgView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

#pragma mark --UISearchBarDelegate
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.isSearching = YES;
    NSString * sendStr = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    [self top_searchResult:sendStr];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (!searchText.length) {
        [self top_searchResult:@""];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    self.isSearching = NO;
    [self.tableView reloadData];
}

#pragma mark -- 搜索
- (void)top_searchResult:(NSString *)text {
    if (self.isSearching) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.resultArray removeAllObjects];
            if (text.length) {
                NSPredicate * predicate = [NSPredicate predicateWithFormat:@"language CONTAINS[cd] %@",text];
                [self.resultArray addObjectsFromArray:[self.allLanguageArr filteredArrayUsingPredicate:predicate]];
            } else {
                self.isSearching = NO;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }
}

#pragma mark -- lazy
- (UIView *)top_searchBgView {
    UIView *searchBarBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, TOPScreenWidth, 55)];
    searchBarBgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
    [self.view addSubview:searchBarBgView];
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 0.5)];
    topLine.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGB(224, 224, 224)];
    [searchBarBgView addSubview:topLine];
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 54.5, TOPScreenWidth, 0.5)];
    bottomLine.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGB(224, 224, 224)];
    [searchBarBgView addSubview:bottomLine];
    
    [searchBarBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.top.equalTo(self.view).offset(55);
        make.size.mas_equalTo(CGSizeMake(TOPScreenWidth, 55));
    }];
    [topLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(searchBarBgView);
        make.height.mas_equalTo(0.5);
    }];
    [bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(searchBarBgView);
        make.height.mas_equalTo(0.5);
    }];
    return searchBarBgView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(5, 10, TOPScreenWidth-40, 35)];
        _searchBar.placeholder = NSLocalizedString(@"topscan_search", @"");
        _searchBar.backgroundImage = [[UIImage alloc]init];
        _searchBar.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(255,255,255, 1.0)];
        _searchBar.showsCancelButton = NO;
        _searchBar.barStyle = UIBarStyleDefault;
        _searchBar.keyboardType = UIKeyboardTypeDefault;
        _searchBar.returnKeyType = UIReturnKeyDone;
        _searchBar.enablesReturnKeyAutomatically = NO;
        _searchBar.delegate = self;
        [_searchBar setImage:[UIImage imageNamed:@"top_search_language"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];

        UITextField * searchField;
        if (@available(iOS 13.0, *)) {
            searchField = _searchBar.searchTextField;
            if (searchField) {
                NSMutableDictionary * dic = [@{NSForegroundColorAttributeName:[UIColor top_textColor:TOPAPPViewSecondDarkColor defaultColor:RGB(153, 153, 153)],NSFontAttributeName:[UIFont boldSystemFontOfSize:17]} mutableCopy];
                NSMutableAttributedString * attplace = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"topscan_search", @"") attributes:dic];
                searchField.attributedPlaceholder = attplace;
            }
        } else {
            searchField = [_searchBar valueForKey:@"_searchField"];
            [searchField setValue:[UIColor top_textColor:TOPAPPViewSecondDarkColor defaultColor:RGBA(153, 153, 153, 1.0)] forKeyPath:@"_placeholderLabel.textColor"];
        }
        if (searchField) {
            [searchField setBackgroundColor:[UIColor clearColor]];
            searchField.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
            searchField.font = [UIFont systemFontOfSize:17];
        }
    }
    return _searchBar;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 110, TOPScreenWidth, TOPScreenHeight-110-TOPBottomSafeHeight-TOPNavBarAndStatusBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:RGB(251, 252, 252)];
        [_tableView registerClass:[TOPTranslateModelCell class] forCellReuseIdentifier:NSStringFromClass([TOPTranslateModelCell class])];
    }
    return _tableView;
}

- (NSMutableArray *)allLanguageArr {
    if (!_allLanguageArr) {
        _allLanguageArr = @[].mutableCopy;
    }
    return _allLanguageArr;
}

- (NSMutableArray *)recentLanguageArr {
    if (!_recentLanguageArr) {
        _recentLanguageArr = @[].mutableCopy;
    }
    return _recentLanguageArr;
}

- (NSMutableArray *)resultArray {
    if (!_resultArray) {
        _resultArray  = @[].mutableCopy;
    }
    return _resultArray;
}

@end
