#define SortView_H 60
#define EditTagsView_W 310
#define ViewTypeChangeTags @"changeTags"
#define ViewTypeAddTags @"addTags"

#import "TOPTagsManagerViewController.h"
#import "TOPTagsManagerTableView.h"
#import "TOPTagsManagerCell.h"
#import "TOPWMDragView.h"
#import "TOPEditTagsOneView.h"
#import "TOPEditTagsTwoView.h"
#import "TOPShareTypeView.h"
@interface TOPTagsManagerViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)TOPWMDragView * addTagsView;
@property (nonatomic,strong)TOPEditTagsOneView * editTagsOneView;
@property (nonatomic,strong)TOPEditTagsTwoView * editTagsTwoView;
@property (nonatomic,strong)TOPTagsListModel * currentModel;
@property (nonatomic,assign)NSInteger currentRow;
@property (nonatomic,strong)UITableView * tableView;
@property (nonatomic,strong)NSMutableArray * defaultTagsArray;
@property (nonatomic,strong)NSMutableArray * tagsArray;
@property (nonatomic,strong)UIView * coverView;
@property (nonatomic,strong)UIButton * editBtn;
@property (nonatomic,strong)UIButton * sortByBtn;
@property (nonatomic,copy)NSString * viewType;
@property (nonatomic,strong)UIView * backView;
@end

@implementation TOPTagsManagerViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwill:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keybaordhide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"topscan_tagstagmanager", @"");
    self.view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    if (isRTL()) {
        [self top_initBackButton:@"top_RTLbackItem" withSelector:@selector(top_STM_BackHomeAction)];
    }else{
        [self top_initBackButton:@"top_backItem" withSelector:@selector(top_STM_BackHomeAction)];
    }

    [self top_setDefaultRightBarButtonItems];
    [self top_setupUI];
    [self top_enterLoadData];
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 50*2+10, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight-10-50*2)];
        _backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        
        UIImageView * img = [[UIImageView alloc]initWithFrame:CGRectMake((TOPScreenWidth-60)/2, _backView.height/2-30-60, 60, 60)];
        img.image = [UIImage imageNamed:@"top_tagnodata"];
        
        UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, _backView.height/2-10, TOPScreenWidth-40, 20)];
        titleLab.textColor = RGBA(188, 188, 188, 1.0);
        titleLab.font = [UIFont systemFontOfSize:18];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = NSLocalizedString(@"topscan_tagscreatelabs", @"");
        
        [_backView addSubview:img];
        [_backView addSubview:titleLab];
    }
    return _backView;
}

- (void)top_setDefaultRightBarButtonItems{
    NSArray * imageArray = @[@"top_tagEdit",@"top_tagsSort"];
    NSMutableArray * btnArray = [NSMutableArray new];
    for (int i = 0; i<imageArray.count; i++) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 30)];
        btn.tag = i+10;
        if (i == 0) {
            [btn setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:NSLocalizedString(@"topscan_tagsdone", @"")] forState:UIControlStateSelected];
            self.editBtn = btn;
        }else{
            [btn setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
            self.sortByBtn = btn;
        }
         
        [btn setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(top_STM_ClickRightItems:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * barItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        [btnArray addObject:barItem];
    }
    self.navigationItem.rightBarButtonItems = btnArray;
}
#pragma mark -- UI
- (void)top_setupUI{
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.addTagsView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
    
    [self.addTagsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view).offset(-(30+TOPBottomSafeHeight));
        make.height.width.mas_equalTo(65);
    }];
}

- (TOPEditTagsOneView *)editTagsOneView{
    if (!_editTagsOneView) {
        WS(weakSelf);
        _editTagsOneView = [[TOPEditTagsOneView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, EditTagsView_W, EditTagsView_W)];
        _editTagsOneView.top_clickToSendString = ^(NSString * _Nonnull editString) {
            if ([weakSelf.viewType isEqualToString:ViewTypeChangeTags]) {
                [weakSelf top_STM_ChangeTagsWithName:editString];
            }else{
                [weakSelf top_STM_addTagsAction:editString];
            }
            [weakSelf top_tapAction];
        };
        
        _editTagsOneView.top_clickToHide = ^{
            [weakSelf top_tapAction];
        };
    }
    return _editTagsOneView;
}

- (TOPEditTagsTwoView *)editTagsTwoView{
    if (!_editTagsTwoView) {
        WS(weakSelf);
        _editTagsTwoView = [[TOPEditTagsTwoView alloc]initWithFrame:CGRectMake(0, TOPScreenHeight, EditTagsView_W, EditTagsView_W)];
        _editTagsTwoView.top_clickToSendString = ^(NSString * _Nonnull editString) {
            if ([weakSelf.viewType isEqualToString:ViewTypeChangeTags]) {
                [weakSelf top_STM_ChangeTagsWithName:editString];
            }else{
                [weakSelf top_STM_addTagsAction:editString];
            }
            [weakSelf top_tapAction];
        };
        
        _editTagsTwoView.top_clickToHide = ^{
            [weakSelf top_tapAction];
        };
    }
    return _editTagsTwoView;
}

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        _coverView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_tapAction)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}
#pragma mark -- 获取数据
- (void)top_enterLoadData{
    if (self.dataArray.count == 0) {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray * tagsListArray = [NSMutableArray new];
        if (self.dataArray.count == 0) {
            tagsListArray = [TOPDataModelHandler top_getTagsListManagerData];
        }else{
            tagsListArray = self.dataArray;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.defaultTagsArray removeAllObjects];
            [self.tagsArray removeAllObjects];
            for (TOPTagsListModel * model in tagsListArray) {
                TOPTagsManagerModel * managerModel = [TOPTagsManagerModel new];
                managerModel.tagsListModel = model;
                if ([model.tagName isEqualToString:TOP_TRTagsAllDocesKey]||[model.tagName isEqualToString:TOP_TRTagsUngroupedKey]) {
                    managerModel.isEdit = NO;
                    [self.defaultTagsArray addObject:managerModel];
                }else{
                    managerModel.isEdit = self.editBtn.selected;
                    [self.tagsArray addObject:managerModel];
                    NSMutableArray * sortArray = [TOPDataModelHandler top_tagsManagerListSort:self.tagsArray];
                    self.tagsArray = [sortArray mutableCopy];
                }
            }
            [self top_addNoDataView];
            [self.tableView reloadData];
        });
    });
}
- (void)top_reLoadData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray * tagsListArray = [TOPDataModelHandler top_getTagsListManagerData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.defaultTagsArray removeAllObjects];
            [self.tagsArray removeAllObjects];
            for (TOPTagsListModel * model in tagsListArray) {
                TOPTagsManagerModel * managerModel = [TOPTagsManagerModel new];
                managerModel.tagsListModel = model;
                if ([model.tagName isEqualToString:TOP_TRTagsAllDocesKey]||[model.tagName isEqualToString:TOP_TRTagsUngroupedKey]) {
                    managerModel.isEdit = NO;
                    [self.defaultTagsArray addObject:managerModel];
                }else{
                    managerModel.isEdit = self.editBtn.selected;
                    [self.tagsArray addObject:managerModel];
                    NSMutableArray * sortArray = [TOPDataModelHandler top_tagsManagerListSort:self.tagsArray];
                    self.tagsArray = [sortArray mutableCopy];
                }
            }
            
            [self top_addNoDataView];
            [self.tableView reloadData];
        });
    });
}

- (void)top_addNoDataView{
    if (self.tagsArray.count) {
        [self.backView removeFromSuperview];
        self.backView = nil;
    }else{
        [self.tableView addSubview:self.backView];
    }
}
#pragma mark -- 添加标签按钮
- (TOPWMDragView*)addTagsView{
    if (!_addTagsView) {
        CGRect rect = CGRectZero;
        rect = CGRectMake(TOPScreenWidth - 95, TOPScreenHeight - TOPNavBarAndStatusBarHeight - 110, 70, 70);
        WS(weakSelf);
        _addTagsView = [[TOPWMDragView alloc] initWithFrame:rect];
        _addTagsView.imageView.image = [UIImage imageNamed:@"icon_addTags_gai"];
        _addTagsView.backgroundColor = [UIColor clearColor];
        _addTagsView.layer.cornerRadius = 30;
        _addTagsView.layer.masksToBounds =  YES;
        _addTagsView.isKeepBounds = NO;

        _addTagsView.clickDragViewBlock = ^(TOPWMDragView *dragView){
            [weakSelf top_STM_addTagsEditView];
        };
    }
    return _addTagsView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight-TOPNavBarAndStatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[TOPTagsManagerCell class] forCellReuseIdentifier:NSStringFromClass([TOPTagsManagerCell class])];
    }
    return _tableView;
}

- (NSMutableArray *)defaultTagsArray{
    if (!_defaultTagsArray) {
        _defaultTagsArray = [NSMutableArray new];
    }
    return _defaultTagsArray;
}

- (NSMutableArray *)tagsArray{
    if (!_tagsArray) {
        _tagsArray = [NSMutableArray new];
    }
    return _tagsArray;
}

- (NSArray *)top_fileOrderTypeArray{
    NSArray * tempArray = @[@(FolderDocumentCreateDescending),@(FolderDocumentCreateAscending),@(FolderDocumentUpdateDescending),@(FolderDocumentUpdateAscending),@(FolderDocumentFileNameAToZ),@(FolderDocumentFileNameZToA)];
    return tempArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.defaultTagsArray.count;
    }else{
        return self.tagsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf);
    TOPTagsManagerCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPTagsManagerCell class]) forIndexPath:indexPath];
    if (indexPath.section == 0) {
        [self.tableView setEditing:NO animated:YES];
        cell.model = self.defaultTagsArray[indexPath.item];
        if (indexPath.row == self.defaultTagsArray.count-1) {
            cell.lineView.hidden = YES;
        }else{
            cell.lineView.hidden = NO;
        }
    }else{
        TOPTagsManagerModel * tagModel = self.tagsArray[indexPath.row];
        [self.tableView setEditing:tagModel.isEdit animated:YES];
        cell.model = tagModel;
        if (indexPath.row == self.tagsArray.count-1) {
            cell.lineView.hidden = YES;
        }else{
            cell.lineView.hidden = NO;
        }
    }
    
    cell.top_clickToEdit = ^(TOPTagsManagerModel * _Nonnull model) {
        weakSelf.currentRow = indexPath.row;
        [weakSelf top_STM_ChangeTagsName:model];
    };
    cell.top_clickToBack = ^(TOPTagsManagerModel * _Nonnull model) {
        if (!weakSelf.editBtn.selected) {
            TOPTagsListModel * listModel = model.tagsListModel;
            [TOPScanerShare top_writeSaveTagsName:model.tagsListModel.tagName];
            if (weakSelf.top_clickTagManageBlock) {
                weakSelf.top_clickTagManageBlock(listModel);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    };
    
    return  cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 10)];
    header.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 10)];
    footerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 6;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 6;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TOPTagsListModel * listModel = [TOPTagsListModel new];
    if (indexPath.section == 1) {
        TOPTagsManagerModel * managerModel = self.tagsArray[indexPath.row];
        if (!self.tableView.editing) {
            listModel = managerModel.tagsListModel;
            [TOPScanerShare top_writeSaveTagsName:managerModel.tagsListModel.tagName];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        TOPTagsManagerModel * managerModel = self.defaultTagsArray[indexPath.row];
        listModel = managerModel.tagsListModel;
        [TOPScanerShare top_writeSaveTagsName:managerModel.tagsListModel.tagName];
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (self.top_clickTagManageBlock) {
        self.top_clickTagManageBlock(listModel);
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    if (indexPath.section == 1) {
        UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:NSLocalizedString(@"topscan_delete", @"") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            completionHandler(YES);
            TOPTagsManagerModel * managerModel = self.tagsArray[indexPath.row];
            [self top_STM_TagsDelete:managerModel];
        }];
        deleteRowAction.image = [UIImage imageNamed:@"top_sideDelete"];
        deleteRowAction.backgroundColor = [UIColor redColor];
        
        UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
        return config;
    }
    return nil;
}

- (void)top_tapAction{
    [UIView animateWithDuration:0.3 animations:^{
        [self.editTagsOneView removeFromSuperview];
        [self.editTagsTwoView removeFromSuperview];
        [self.coverView removeFromSuperview];
        self.editTagsOneView = nil;
        self.editTagsTwoView = nil;
        self.coverView = nil;
    }];
}
- (void)top_STM_BackHomeAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 键盘出现
- (void)keyboardwill:(NSNotification *)sender{
    NSDictionary *dict=[sender userInfo];
    NSValue *value=[dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardrect = [value CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        self.editTagsOneView.frame = CGRectMake((TOPScreenWidth-EditTagsView_W)/2, keyboardrect.origin.y-15-EditTagsView_W, EditTagsView_W, EditTagsView_W);
        self.editTagsTwoView.frame = CGRectMake((TOPScreenWidth-EditTagsView_W)/2, keyboardrect.origin.y-15-EditTagsView_W, EditTagsView_W, EditTagsView_W);
    }];
}

#pragma mark -- 键盘消失
- (void)keybaordhide:(NSNotification *)sender{
    if (![self.editTagsOneView.tField isFirstResponder]&&![self.editTagsOneView.tField isFirstResponder]) {
        [self top_tapAction];
    }
}

- (void)top_STM_ClickRightItems:(UIButton *)sender{
    if (sender.tag == 10) {
        sender.selected = !sender.selected;
        if (sender.selected) {
            self.sortByBtn.hidden = YES;
        }else{
            self.sortByBtn.hidden = NO;
        }
        for (TOPTagsManagerModel * model in self.tagsArray) {
            model.isEdit = sender.selected;
        }
        [self.tableView reloadData];
    }else{
        [self top_STM_TagsManagerSortBy];
    }
}

#pragma mark ---排列
- (void)top_STM_TagsManagerSortBy{
    [FIRAnalytics logEventWithName:@"homeView_HomeHeaderSortBy" parameters:nil];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    WS(weakSelf);
    NSArray *titleArray = @[NSLocalizedString(@"topscan_creatdataascend", @""),NSLocalizedString(@"topscan_creatdatadescend", @""),NSLocalizedString(@"topscan_updatedataascend", @""),NSLocalizedString(@"topscan_updatedatadescend", @""),NSLocalizedString(@"topscan_filenameatoz", @""), NSLocalizedString(@"topscan_filenameztoa", @"")];
    NSArray *picArray = @[@"top_docCreatDe",@"top_docCreatAs",@"top_docUpdateDe",@"top_docUpdateAs",@"top_docAZ",@"top_docZA"];
    NSArray *selectArray = @[@"top_docCreatSelectDe",@"top_docCreatSelectAs",@"top_docUpdateSelectDe",@"top_docUpdateSelectAs",@"top_docSelectAZ",@"top_docSelectZA"];
    TOPShareTypeView * sortPopView2 = [[TOPShareTypeView alloc]initWithTitleView:[UIView new] titleArray:titleArray picArray:picArray cancelTitle:NSLocalizedString(@"topscan_cancel", @"") cancelBlock:^{
        
    } selectBlock:^(NSInteger row, NSString * _Nonnull totalSize) {
        NSArray * tempArray = [weakSelf top_fileOrderTypeArray];
        [TOPScanerShare top_writSortTagsType:[tempArray[row] integerValue]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray * sortArray = [TOPDataModelHandler top_tagsManagerListSort:weakSelf.tagsArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.tagsArray = sortArray;
                [weakSelf.tableView reloadData];
            });
        });
    }];
    sortPopView2.selectArray = selectArray;
    sortPopView2.popType = TOPPopUpBounceViewTypeTagSort;
    [window addSubview:sortPopView2];
    [sortPopView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(window);
    }];
}

#pragma mark ---删除标签
- (void)top_STM_TagsDelete:(TOPTagsManagerModel *)model{
    [FIRAnalytics logEventWithName:@"STM_TagsDelete" parameters:nil];
    WS(weakSelf);
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_tagstagdelete", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        [weakSelf top_deleteOldTag:model];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark --删除标签文件夹名称 视图
- (void)top_deleteOldTag:(TOPTagsManagerModel *)model {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TOPTagsListModel * listModel = model.tagsListModel;
        NSArray * docArray = listModel.docArray;
        for (DocumentModel * docModel in docArray) {
            NSString * deletePath = [docModel.tagsPath stringByAppendingPathComponent:model.tagsListModel.tagName];
            NSLog(@"deletePath==%@",deletePath);
            [TOPWHCFileManager top_removeItemAtPath:deletePath];
        }
        
        NSString *rootTagsPath =  [TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString];
        NSString *deleteRootTagsPath = [rootTagsPath stringByAppendingPathComponent:model.tagsListModel.tagName];
        [TOPWHCFileManager top_removeItemAtPath:deleteRootTagsPath];
        [TOPEditDBDataHandler top_deleteTag:model.tagsListModel.tagName];
        
        NSString * saveTag = [TOPScanerShare top_saveTagsName];
        if ([saveTag isEqualToString:model.tagsListModel.tagName]) {
            [TOPScanerShare top_writeSaveTagsName:TOP_TRTagsAllDocesKey];
        }
        [self top_reLoadData];
    });
}

#pragma mark --更改标签文件夹名称 视图
- (void)top_STM_ChangeTagsName:(TOPTagsManagerModel *)model{
    TOPTagsListModel * listModel = model.tagsListModel;
    self.currentModel = listModel;
    self.viewType = ViewTypeChangeTags;
    
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.coverView];
    [self top_markupCoverMask];
    if ([TOPScanerShare top_listType] == ShowListGoods) {
        [keyWindow addSubview:self.editTagsTwoView];
        self.editTagsTwoView.tagsName = listModel.tagName;
    }else{
        [keyWindow addSubview:self.editTagsOneView];
        self.editTagsOneView.tagsName = listModel.tagName;
    }
}
#pragma mark --更改标签文件夹名称功能
- (void)top_STM_ChangeTagsWithName:(NSString *)name{
    for (TOPTagsManagerModel * managerModel in self.tagsArray) {
        if ([managerModel.tagsListModel.tagName isEqualToString:name]) {//重名
            if (![name isEqualToString:self.currentModel.tagName]) {
                [self top_STM_TagsAlreadyAlert];
            }
            return;
        }
    }
    if (name.length == 0) {
        return;
    }
    
    NSMutableArray *docIds = @[].mutableCopy;
    NSArray * docArray = self.currentModel.docArray;
    for (DocumentModel * docModel in docArray) {
        NSString * changePath = [docModel.tagsPath stringByAppendingPathComponent:self.currentModel.tagName];
        [TOPDocumentHelper top_changeDocumentName:changePath folderText:name];
        [docIds addObject:docModel.docId];
    }
    [TOPEditDBDataHandler top_updateTag:self.currentModel.tagName withNewName:name];
    [TOPEditDBDataHandler top_updateDocumentTags:@{@"tags": [NSString stringWithFormat:@"%@/",name]} byDocIds:docIds];
    NSString *rootTagsPath =  [TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString];
    NSString *deleteRootTagsPath = [rootTagsPath stringByAppendingPathComponent:self.currentModel.tagName];
    [TOPDocumentHelper top_changeDocumentName:deleteRootTagsPath folderText:name];
        
    NSString * saveTag = [TOPScanerShare top_saveTagsName];
    if ([saveTag isEqualToString:self.currentModel.tagName]) {
        [TOPScanerShare top_writeSaveTagsName:name];
    }
    
    self.currentModel.tagName = name;
    TOPTagsManagerModel * managerModel = [TOPTagsManagerModel new];
    managerModel.tagsListModel = self.currentModel;
    managerModel.isEdit = self.editBtn.selected;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.tagsArray replaceObjectAtIndex:self.currentRow withObject:managerModel];
        NSMutableArray * sortArray = [TOPDataModelHandler top_tagsManagerListSort:self.tagsArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tagsArray = sortArray;
            [self.tableView reloadData];
        });
    });
}

- (void)top_STM_TagsAlreadyAlert{
    [FIRAnalytics logEventWithName:@"STM_TagsAlreadyAlert" parameters:nil];
    TOPSCAlertController* alert = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_remind", @"")
                                                                   message:NSLocalizedString(@"topscan_tagsalreadyexists", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark -- 显示添加tags视图
- (void)top_STM_addTagsEditView{
    [FIRAnalytics logEventWithName:@"STM_addTagsEditView" parameters:nil];
    self.viewType = ViewTypeAddTags;

    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [keyWindow addSubview:self.coverView];
    [self top_markupCoverMask];
    if ([TOPScanerShare top_listType] == ShowListGoods) {
        [keyWindow addSubview:self.editTagsTwoView];
        self.editTagsTwoView.placeholder = NSLocalizedString(@"topscan_tagstagmanageraddplac", @"");
    }else{
        [keyWindow addSubview:self.editTagsOneView];
        self.editTagsOneView.placeholder = NSLocalizedString(@"topscan_tagstagmanageraddplac", @"");

    }
}
#pragma mark -- 添加tags功能
- (void)top_STM_addTagsAction:(NSString *)name{
    NSString * homeTagsPath = [TOPDocumentHelper top_getBelongDocumentPathString:TOP_TRTagsPathString];
    NSArray * homeTagsPathArray = [TOPDocumentHelper top_getCurrentFileAndPath:homeTagsPath];
    if ([homeTagsPathArray containsObject:name]) {
        [self top_STM_TagsAlreadyAlert];
        return;
    }
    
    if (name.length == 0) {
        return;
    }
    [TOPDocumentHelper top_createTagsBottomPathTagsPath:homeTagsPath withCreatePath:name];
    
    TOPTagsListModel * listModel = [TOPTagsListModel new];
    listModel.tagName = name;
    listModel.tagNum = [NSString stringWithFormat:@"%d",0];
    TOPTagsManagerModel * manageModel = [TOPTagsManagerModel new];
    manageModel.tagsListModel = listModel;
    manageModel.isEdit = self.editBtn.selected;
    [self.tagsArray addObject:manageModel];
    [TOPEditDBDataHandler top_createTags:@[name]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * sortArray = [TOPDataModelHandler top_tagsManagerListSort:self.tagsArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tagsArray removeAllObjects];
            self.tagsArray = sortArray;
            
            [self top_addNoDataView];
            [self.tableView reloadData];
        });
    });
}

- (void)top_markupCoverMask{
    UIWindow * keyWindow = [UIApplication sharedApplication].windows[0];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(keyWindow);
    }];
}

@end
