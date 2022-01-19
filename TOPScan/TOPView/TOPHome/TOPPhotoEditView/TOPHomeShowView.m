#import "TOPHomeShowView.h"
#import "TOPHomeShowViewCell.h"
#import "TOPOcrTypeShowCell.h"
#import "TOPTagsListCell.h"
@interface TOPHomeShowView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic ,strong)UIButton * footerBtn;
@end
@implementation TOPHomeShowView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
        if ([TOPDocumentHelper top_isdark]) {
            [self top_darkLayerView];
        }else{
            [self top_layerView];
        }
        [self addSubview:self.tableView];
        [self addSubview:self.footerBtn];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
        if ([TOPDocumentHelper top_isdark]) {
            [self top_darkLayerView];
        }else{
            [self top_layerView];
        }
    
        [self addSubview:self.tableView];
        [self addSubview:self.footerBtn];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
    self.footerBtn.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
    self.tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];

    if ([TOPDocumentHelper top_isdark]) {
        [self top_darkLayerView];
    }else{
        [self top_layerView];
    }
}
- (void)top_layerView{
    self.layer.cornerRadius = 3;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.5;
    self.clipsToBounds = NO;
}
- (void)top_darkLayerView{
    self.layer.cornerRadius = 3;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 1;
    self.clipsToBounds = NO;
}
- (UIButton *)footerBtn{
    if (!_footerBtn) {
        _footerBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.height-40, self.width, 0)];
        _footerBtn.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
        [_footerBtn setImage:[UIImage imageNamed:@"top_tagFooter"] forState:UIControlStateNormal];
        [_footerBtn addTarget:self action:@selector(top_clickFooter) forControlEvents:UIControlEventTouchUpInside];
        _footerBtn.layer.cornerRadius = 3;
    }
    return _footerBtn;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.layer.cornerRadius = 3;
        _tableView.layer.masksToBounds = YES;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        [_tableView registerClass:[TOPHomeShowViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPHomeShowViewCell class])];
        [_tableView registerClass:[TOPOcrTypeShowCell class] forCellReuseIdentifier:NSStringFromClass([TOPOcrTypeShowCell class])];
        [_tableView registerClass:[TOPTagsListCell class] forCellReuseIdentifier:NSStringFromClass([TOPTagsListCell class])];

    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.showType == TOPHomeShowViewLocationTypeTopRight) {
        TOPHomeShowViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPHomeShowViewCell class]) forIndexPath:indexPath];
        cell.titleLab.text = self.dataArray[indexPath.row];
        cell.iconImg.image = [UIImage imageNamed:self.iconArray[indexPath.row]];
        if (indexPath.row == self.dataArray.count-1) {
            cell.lineView.hidden = YES;
        }else{
            cell.lineView.hidden = NO;
        }
        return cell;
    }else if(self.showType == TOPHomeShowViewLocationTypeMiddle){
        TOPOcrTypeShowCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPOcrTypeShowCell class]) forIndexPath:indexPath];
        cell.row = indexPath.row;
        cell.titleLab.text = self.dataArray[indexPath.row];
        if(indexPath.row == 0) {
            cell.vipLogoView.hidden = [TOPPermissionManager top_enableByOCROnline];
        }
        return cell;
    }else if (self.showType == TOPHomeShowViewLocationTypeTopLeft){
        TOPTagsListCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPTagsListCell class]) forIndexPath:indexPath];
        TOPTagsListModel * model = self.dataArray[indexPath.row];
        cell.model = model;
        return cell;
    }
    else{
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 40)];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 40)];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.showType == TOPHomeShowViewLocationTypeMiddle) {
        return 60;
    }else{
        return 45;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.showType == TOPHomeShowViewLocationTypeTopLeft) {
        TOPTagsListModel * model = self.dataArray[indexPath.row];
        if (self.top_clickTagsCell) {
            self.top_clickTagsCell(model);
        }
    }else{
        if (self.top_clickCellAction) {
            self.top_clickCellAction(indexPath.row);
        }
    }
}

- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self->_showType == TOPHomeShowViewLocationTypeTopLeft) {//表明是标签列表 对标签列表数据重新排序
            [self top_sortDataAgain];//标签数据重新排序
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.leading.trailing.bottom.equalTo(self);
            }];
            [self.tableView reloadData];
        });
    });
}

- (void)setShowType:(TOPHomeShowViewLocationType)showType{
    _showType = showType;
    if (_showType == TOPHomeShowViewLocationTypeMiddle) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 15;
    }
    if (_showType == TOPHomeShowViewLocationTypeTopLeft) {
        self.tableView.scrollEnabled = YES;
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.equalTo(self);
            make.bottom.equalTo(self).offset(-50);
        }];
        [self.footerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self);
            make.height.mas_equalTo(50);
        }];
    }else{
        self.tableView.scrollEnabled = NO;
        self.footerBtn.frame = CGRectMake(0, 0, self.width, 0);
    }
}
#pragma mark -- 对标签数据重新排序
- (void)top_sortDataAgain{
    NSMutableArray * tempArray = [NSMutableArray new];
    NSMutableArray * tempArray1 = [NSMutableArray new];
    for (TOPTagsListModel * model in _dataArray) {
        if (model.tagPath) {
            [tempArray addObject:model];
        }else{
            [tempArray1 addObject:model];
        }
    }
    NSMutableArray * sortArray = [TOPDataModelHandler top_sortTagsFileData:tempArray atPath:@""];
    [tempArray1 addObjectsFromArray:sortArray];
    _dataArray = [tempArray1 mutableCopy];
}
- (void)top_clickFooter{
    if (self.top_clickTagsFooterBtn) {
        self.top_clickTagsFooterBtn();
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
