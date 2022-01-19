#define CoverH 200
#define AddBtn_W 66
#define AddBtn_H 35
#define AllCollectionViewH 350

#import "TOPSetTagViewController.h"
#import "TOPTagsCollectionView.h"
#import "TOPTagsCellSpaceFlowLayout.h"
#import "TOPSetTagsCell.h"
#import "TOPTagsReusableHeader.h"

@interface TOPSetTagViewController ()<UISearchBarDelegate>
@property (nonatomic ,strong)TOPTagsCollectionView * equalCollectionView;
@property (nonatomic ,strong)TOPTagsCollectionView * allCollectionView;
@property (nonatomic ,strong)UISearchBar * searchBar;
@property (nonatomic ,copy) NSString * searchStr;
@property (nonatomic ,strong)NSMutableArray * allTagArray;
@property (nonatomic ,strong)NSMutableArray * equalArray;
@property (nonatomic ,strong)NSMutableArray * defaulArray;
@end

@implementation TOPSetTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"topscan_tagssettag", @"");
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_ST_BackHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_ST_BackHomeAction)];
    }
 
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 55, 44)];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightBtn setTitle:NSLocalizedString(@"topscan_tagsdone", @"") forState:UIControlStateNormal];
    [rightBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(top_ST_ClickRightItems) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = barItem;
    
    [self top_setupUI];
    [self top_loadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
#pragma mark --lazy
- (NSMutableArray *)allTagArray{
    if (!_allTagArray) {
        _allTagArray = [NSMutableArray new];
    }
    return _allTagArray;
}

- (NSMutableArray *)equalArray{
    if (!_equalArray) {
        _equalArray = [NSMutableArray new];
    }
    return _equalArray;
}

- (NSMutableArray *)defaulArray{
    if (!_defaulArray) {
        _defaulArray = [NSMutableArray new];
    }
    return _defaulArray;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (TOPTagsCollectionView *)equalCollectionView{
    if (!_equalCollectionView) {
        WS(weakSelf);
        TOPTagsCellSpaceFlowLayout * layout = [[TOPTagsCellSpaceFlowLayout alloc]initWithType:AlignWithLeft betweenOfCell:10];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
        _equalCollectionView = [[TOPTagsCollectionView alloc]initWithFrame:CGRectMake(0, 70, TOPScreenWidth, CoverH-AddBtn_H-30) collectionViewLayout:layout];
        _equalCollectionView.backgroundColor = [UIColor clearColor];
        _equalCollectionView.top_clickCellchangeState = ^(TOPTagsModel * _Nonnull model) {
            [weakSelf top_changeEqualTagModelStateAndReloadData:model];
        };
    }
    return _equalCollectionView;
}

- (TOPTagsCollectionView *)allCollectionView{
    if (!_allCollectionView) {
        WS(weakSelf);
        TOPTagsCellSpaceFlowLayout * layout = [[TOPTagsCellSpaceFlowLayout alloc]initWithType:AlignWithLeft betweenOfCell:10];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
        _allCollectionView = [[TOPTagsCollectionView alloc]initWithFrame:CGRectMake(0,CoverH+10, TOPScreenWidth, AllCollectionViewH) collectionViewLayout:layout];
        _allCollectionView.backgroundColor = [UIColor clearColor];
        _allCollectionView.top_clickCellchangeState = ^(TOPTagsModel * _Nonnull model) {
            [weakSelf top_changeAllTagModelStateAndReloadData:model];
        };
    }
    return _allCollectionView;
}

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(15, 15, TOPScreenWidth-45-AddBtn_W, AddBtn_H)];
        _searchBar.placeholder = NSLocalizedString(@"topscan_tagssearchplaceholder", @"");
        _searchBar.layer.cornerRadius = 35/2;
        _searchBar.backgroundImage = [[UIImage alloc]init];
        _searchBar.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:TOPAppBackgroundColor];
        _searchBar.showsCancelButton = NO;
        _searchBar.barStyle = UIBarStyleDefault;
        _searchBar.keyboardType = UIKeyboardTypeDefault;
        _searchBar.returnKeyType = UIReturnKeyDefault;
        _searchBar.delegate = self;
        if (@available(iOS 13.0, *)) {
            UITextField * searchField = _searchBar.searchTextField;
            if (searchField) {
                NSMutableDictionary * dic = [@{NSForegroundColorAttributeName:[UIColor top_textColor:TOPAPPViewSecondDarkColor defaultColor:[UIColor grayColor]],NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} mutableCopy];
                NSMutableAttributedString * attplace = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"topscan_tagssearchplaceholder", @"") attributes:dic];
                searchField.attributedPlaceholder = attplace;
                [searchField setBackgroundColor:[UIColor clearColor]];
                searchField.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:[UIColor grayColor]];
                searchField.font = [UIFont systemFontOfSize:14];
                searchField.leftView = nil;
                searchField.clearButtonMode = UITextFieldViewModeNever;
            }
        } else {
            UITextField * searchField = [_searchBar valueForKey:@"_searchField"];
            if (searchField) {
                searchField.leftView = nil;
                searchField.clearButtonMode = UITextFieldViewModeNever;
                [searchField setBackgroundColor:[UIColor clearColor]];
                searchField.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:[UIColor grayColor]];
                searchField.font = [UIFont systemFontOfSize:14];
                [searchField setValue:[UIColor top_textColor:TOPAPPViewSecondDarkColor defaultColor:RGBA(153, 153, 153, 1.0)] forKeyPath:@"_placeholderLabel.textColor"];
            }
            
        }
    }
    return _searchBar;
}
#pragma mark -- 返回
- (void)top_ST_BackHomeAction{
    NSMutableArray * nameArray = [NSMutableArray new];
    for (TOPTagsModel * tagModel in self.equalArray) {
        [nameArray addObject:tagModel.name];
    }
    NSLog(@"getDefaulArray==%@",[self getDefaulArray]);
    NSLog(@"equalArray==%@",nameArray);
    if (self.equalArray.count>0 && ![[self getDefaulArray] isEqualToArray:nameArray]) {
        WS(weakSelf);
        TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_note", @"")
                                                                       message:NSLocalizedString(@"topscan_tagstagnotecontent", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:[NSLocalizedString(@"topscan_batchsave", @"") uppercaseString]  style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [weakSelf top_ST_ClickRightItems];
        }];
        

        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:[NSLocalizedString(@"topscan_cancel", @"") uppercaseString] style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -- 保存添加的标签
- (void)top_ST_ClickRightItems{
    [FIRAnalytics logEventWithName:@"ST_ClickDone" parameters:nil];
    NSString * homeTagsPath = [TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString];
    NSArray * homeTagsPathArray = [TOPDocumentHelper top_getCurrentFileAndPath:homeTagsPath];
    NSMutableArray *docIds = @[].mutableCopy;
    NSMutableDictionary *tagData = @{}.mutableCopy;
    NSMutableArray *newTags = @[].mutableCopy;
    for (DocumentModel * docModel in self.dataArray) {
        if (docModel.tagsPath.length>0) {
        }
        [docIds addObject:docModel.docId];
        if (self.equalArray.count>0) {
            for (TOPTagsModel * tagModel in self.defaulArray) {//删除取消的标签
                if (![self.equalArray containsObject:tagModel]) {
                    NSString * getTagsPath = [docModel.tagsPath stringByAppendingPathComponent:tagModel.name];
                    [TOPWHCFileManager top_removeItemAtPath:getTagsPath];
                }
            }
            docModel.tagsPath =  [TOPDocumentHelper top_createTagsPath:docModel.path];
            NSString *tagStr = @"";
            for (TOPTagsModel * tagModel in self.equalArray) {
                [TOPDocumentHelper top_createTagsBottomPathTagsPath:docModel.tagsPath withCreatePath:tagModel.name];
                if (!tagData.allKeys.count) {
                    tagStr = [tagStr stringByAppendingFormat:@"%@/",tagModel.name];
                }
                if (![homeTagsPathArray containsObject:tagModel.name]) {
                    [TOPDocumentHelper top_createTagsBottomPathTagsPath:homeTagsPath withCreatePath:tagModel.name];
                    if (![newTags containsObject:tagModel.name]) {
                        [newTags addObject:tagModel.name];
                    }
                }
            }
            if (!tagData.allKeys.count) {
                [tagData setValue:tagStr forKey:@"tags"];
            }
        }else{
            [TOPWHCFileManager top_removeItemAtPath:docModel.tagsPath];
        }
    }
    [TOPEditDBDataHandler top_createTags:newTags];
    [TOPEditDBDataHandler top_updateDocumentTags:tagData byDocIds:docIds];
    if (self.top_saveFinishAction) {
        self.top_saveFinishAction();
    }
    [self.searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 添加标签
- (void)top_clickAddBtn{
    [FIRAnalytics logEventWithName:@"clickAddBtn" parameters:nil];
    if (self.searchStr.length>0) {
        TOPTagsModel * model = [TOPTagsModel new];
        model.name = self.searchStr;
        model.selectStatus = YES;
        
        NSMutableArray * nameArray = [NSMutableArray new];
        for (TOPTagsModel * tagModel in self.equalArray) {
            [nameArray addObject:tagModel.name];
        }
        
        if ([nameArray containsObject:self.searchStr]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_tagsalreadyexists", @"")];
            [SVProgressHUD dismissWithDelay:1.0];
        }else{
            [self.equalArray addObject:model];
            [self.allTagArray addObject:model];
        }
        self.searchStr = nil;
        self.searchBar.text = nil;
        [self top_searchData];
    }
}

#pragma mark --UI
- (void)top_setupUI{
    UIView * coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, TOPScreenWidth, CoverH)];
    coverView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    [coverView addSubview:self.searchBar];
    
    UIButton * addBtn = [[UIButton alloc]initWithFrame:CGRectMake(TOPScreenWidth-15-AddBtn_W, 15, AddBtn_W, AddBtn_H)];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [addBtn setTitle:NSLocalizedString(@"topscan_addto", @"") forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addBtn setBackgroundColor:TOPAPPGreenColor];
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.cornerRadius = 16;
    addBtn.titleLabel.numberOfLines = 1;
    addBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    addBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
    [addBtn addTarget:self action:@selector(top_clickAddBtn) forControlEvents:UIControlEventTouchUpInside];
    [coverView addSubview:addBtn];
    
    [self.view addSubview:coverView];
    
    [coverView addSubview:self.equalCollectionView];
    [self.view addSubview:self.allCollectionView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view).offset(10);
        make.height.mas_equalTo(CoverH);
    }];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(10);
        make.top.equalTo(self.view).offset(15);
        make.trailing.equalTo(self.view).offset(-(45+AddBtn_W));
        make.height.mas_equalTo(AddBtn_H);
    }];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(15);
        make.trailing.equalTo(self.view).offset(-15);
        make.size.mas_equalTo(CGSizeMake(AddBtn_W, AddBtn_H));
    }];
    [self.equalCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view).offset(70);
        make.height.mas_equalTo(CoverH-AddBtn_H-30);
    }];
    [self.allCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view).offset(CoverH+10);
        make.height.mas_equalTo(AllCollectionViewH);
    }];
}

#pragma mark -- equalCollectionView cell的点击事件处理
- (void)top_changeEqualTagModelStateAndReloadData:(TOPTagsModel *)model{
    [FIRAnalytics logEventWithName:@"changeEqualTagModelStateAndReloadData" parameters:nil];
    if ([self.equalArray containsObject:model]) {
        [self.equalArray removeObject:model];
    }
    
    for (TOPTagsModel * allModel in self.allTagArray) {
        if ([allModel.name isEqualToString:model.name]) {
            allModel.selectStatus = NO;
        }
    }
    [self top_refreshcollectionView];
}

#pragma mark -- allCollectionView cell的点击事件处理
- (void)top_changeAllTagModelStateAndReloadData:(TOPTagsModel *)model{
    [FIRAnalytics logEventWithName:@"changeAllTagModelStateAndReloadData" parameters:nil];
    if ([self.allTagArray containsObject:model]) {
        model.selectStatus = !model.selectStatus;
    }
    
    NSMutableArray * nameArray = [NSMutableArray new];
    for (TOPTagsModel * eqModel in self.equalArray) {
        [nameArray addObject:eqModel.name];
    }
    
    if ([nameArray containsObject:model.name]) {
        NSMutableArray * tempArray = [self.equalArray copy];
        for (TOPTagsModel * tagModel in tempArray) {
            if ([tagModel.name isEqualToString:model.name]) {
                [self.equalArray removeObject:tagModel];
            }
        }
    }else{
        [self.equalArray addObject:model];
    }
    [self top_searchData];
}

- (NSMutableArray *)getDefaulArray{
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * docModel in self.dataArray) {
        NSArray * tagsArray = docModel.tagsArray;
        [tempArray addObjectsFromArray:tagsArray];
    }
    
    NSMutableArray * dateMutablearray = [NSMutableArray new];
    for (int i = 0; i < tempArray.count; i ++) {
        TOPTagsModel * tagModel = tempArray[i];
        NSMutableArray *tempTagArray = [@[] mutableCopy];
        [tempTagArray addObject:tagModel];
        for (int j = i+1; j < tempArray.count; j ++) {
            TOPTagsModel *jtagModel = tempArray[j];
            if([tagModel.name isEqualToString:jtagModel.name]){
                [tempTagArray addObject:jtagModel];
                [tempArray removeObjectAtIndex:j];
                j -= 1;
            }
        }
        [dateMutablearray addObject:tempTagArray];
    }
    
    NSMutableArray * equalArray = [NSMutableArray new];
    if (dateMutablearray.count>0) {
        for (NSArray * dArray in dateMutablearray) {
            if (dArray.count>0) {
                TOPTagsModel * tagModel = dArray[0];
                if (dArray.count == self.dataArray.count) {
                    tagModel.selectStatus = YES;
                    [equalArray addObject:tagModel.name];
                }
            }
        }
    }
    
    return equalArray;
}
#pragma mark -- 初始化数据
- (void)top_loadData{
    NSMutableArray * tempArray = [NSMutableArray new];
    for (DocumentModel * docModel in self.dataArray) {
        NSArray * tagsArray = docModel.tagsArray;
        [tempArray addObjectsFromArray:tagsArray];
    }
    
    NSMutableArray * dateMutablearray = [NSMutableArray new];
    for (int i = 0; i < tempArray.count; i ++) {
        TOPTagsModel * tagModel = tempArray[i];
        NSMutableArray *tempTagArray = [@[] mutableCopy];
        [tempTagArray addObject:tagModel];
        for (int j = i+1; j < tempArray.count; j ++) {
            TOPTagsModel *jtagModel = tempArray[j];
            if([tagModel.name isEqualToString:jtagModel.name]){
                [tempTagArray addObject:jtagModel];
                [tempArray removeObjectAtIndex:j];
                j -= 1;
            }
        }
        [dateMutablearray addObject:tempTagArray];
    }
    
    NSMutableArray * equalArray = [NSMutableArray new];
    if (dateMutablearray.count>0) {
        for (NSArray * dArray in dateMutablearray) {
            if (dArray.count>0) {
                TOPTagsModel * tagModel = dArray[0];
                if (dArray.count == self.dataArray.count) {
                    tagModel.selectStatus = YES;
                    [equalArray addObject:tagModel];
                }
            }
        }
    }
    self.equalArray = [equalArray mutableCopy];
    self.defaulArray = [equalArray mutableCopy];
    
    NSMutableArray * rootTagArray = [TOPDBDataHandler top_buildAllTagsDataWithDB];
    NSMutableArray * rootTempArray = [NSMutableArray new];
    for (int i = 0; i < rootTagArray.count; i ++) {
        TOPTagsModel * tagModel = rootTagArray[i];
        for (int j = 0; j < equalArray.count; j ++) {
            TOPTagsModel *jtagModel = equalArray[j];
            if([tagModel.name isEqualToString:jtagModel.name]){
                tagModel.selectStatus = YES;
            }
        }
        [rootTempArray addObject:tagModel];
    }
    
    self.allTagArray = rootTempArray;
    [self top_refreshcollectionView];
}

#pragma mark -- 刷新collectionView
- (void)top_refreshcollectionView{
    self.equalCollectionView.dataArray = self.equalArray;
    self.allCollectionView.headerTitle = NSLocalizedString(@"topscan_tagsalltagstitle", @"");
    self.allCollectionView.dataArray = self.allTagArray;
}

#pragma mark -- 搜索的数据处理及视图刷新
- (void)top_searchData{
    [FIRAnalytics logEventWithName:@"searchData" parameters:nil];
    NSMutableArray * tempSearchArray = [NSMutableArray new];
    if (self.searchStr.length == 0) {
        [tempSearchArray addObjectsFromArray:self.allTagArray];
    }else{
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@",self.searchStr];
        NSLog(@"predicateArray===%@",[self.allTagArray filteredArrayUsingPredicate:predicate]);
        [tempSearchArray addObjectsFromArray:[self.allTagArray filteredArrayUsingPredicate:predicate]];
    }
    
    self.allCollectionView.headerTitle = NSLocalizedString(@"topscan_tagsalltagstitle", @"");
    self.allCollectionView.dataArray = tempSearchArray;
    self.equalCollectionView.dataArray = self.equalArray;
}
#pragma mark -- UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    self.searchStr = searchBar.text;
    return YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (![text isEqualToString:@"\n"]) {
        for (NSString * speialString in [TOPDocumentHelper top_specialStringArray]) {
            if ([text isEqualToString:speialString]) {
                return NO;
            }
        }
        NSString * sendStr = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
        self.searchStr = sendStr;
        [self top_searchData];
    }
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
