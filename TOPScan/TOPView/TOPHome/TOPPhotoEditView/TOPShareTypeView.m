#import "TOPShareTypeView.h"
#import "TOPShareTypeCell.h"
#import "TOPShareCancelCell.h"
@interface TOPShareTypeView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *picArray;
@property (nonatomic, copy) NSString *cancelTitle;
@property (nonatomic, copy) void(^cancelBlock)(void);
@property (nonatomic, copy) void(^selectBlock)(NSInteger row ,NSString * totalSize);
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isFinish;
@property (nonatomic, assign) CGFloat itemSpace;

@end
@implementation TOPShareTypeView

- (instancetype)initWithTitleView:(UIView *)titleView titleArray:(NSArray *)titleArray picArray:(NSArray *)picArray cancelTitle:(NSString *)cancelTitle cancelBlock:(void (^)(void))cancelBlock selectBlock:(void (^)(NSInteger, NSString * _Nonnull))selectBlock
{
    if (self = [super init]) {
        
        self.titleArray = [NSArray array];
        self.picArray = [NSArray array];
        self.headView = titleView;
        self.titleArray = titleArray;
        self.picArray = picArray;
        self.cancelTitle = cancelTitle;
        self.cancelBlock = cancelBlock;
        self.selectBlock = selectBlock;
        self.isFinish = NO;
        self.itemSpace = 10;
        _popType = TOPPopUpBounceViewTypeShare;
        [self top_createUI];
        
    }
    return self;
}


- (void)top_createUI
{
    UIView * backView = [[UIView alloc]initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    backView.layer.cornerRadius = 10;
    backView.layer.masksToBounds = YES;
    backView.hidden = YES;
    self.backView = backView;
    
    self.frame = [UIScreen mainScreen].bounds;
    [self addSubview:self.maskView];
    [self addSubview:self.backView];
    [self addSubview:self.tableView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    CGFloat sectionHeaderHeight = self.showSectionHeader ? 60 : 0;
    [self top_tableView_makMas:sectionHeaderHeight];
}

- (void)setShowSectionHeader:(BOOL)showSectionHeader {
    _showSectionHeader = showSectionHeader;
    if (_showSectionHeader) {
        CGFloat sectionHeaderHeight = 60;
        [self top_tableView_makMas:sectionHeaderHeight];
    }
}

- (void)top_tableView_makMas:(CGFloat)sectionHeaderHeight{
    if (IS_IPAD) {
        [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.mas_equalTo(self.tableView.rowHeight*(self.titleArray.count+1)+sectionHeaderHeight+2*self.itemSpace+TOPBottomSafeHeight+30);
            make.width.mas_equalTo(IPAD_CELLW+30);
        }];
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.mas_equalTo(self.tableView.rowHeight*(self.titleArray.count+1)+sectionHeaderHeight+2*self.itemSpace);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.trailing.equalTo(self);
            make.height.mas_equalTo(self.tableView.rowHeight*(self.titleArray.count+1)+sectionHeaderHeight+2*self.itemSpace+TOPBottomSafeHeight+30);
        }];
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(self.itemSpace);
            make.top.equalTo(self.mas_bottom);
            make.trailing.equalTo(self).offset(-self.itemSpace);
            make.height.mas_equalTo(self.tableView.rowHeight*(self.titleArray.count+1)+sectionHeaderHeight+2*self.itemSpace);
        }];
    }

    [self.tableView reloadData];
}
- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = RGBA(51, 51, 51, 0.4);
    }
    return _maskView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 50;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
        _tableView.separatorInset = UIEdgeInsetsMake(0, -50, 0, 0);
        _tableView.layer.cornerRadius = 10;
        [_tableView registerClass:[TOPShareTypeCell class] forCellReuseIdentifier:NSStringFromClass([TOPShareTypeCell class])];
        [_tableView registerClass:[TOPShareCancelCell class] forCellReuseIdentifier:NSStringFromClass([TOPShareCancelCell class])];

    }
    return _tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TOPShareTypeCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPShareTypeCell class]) forIndexPath:indexPath];
        cell.titleArray = [self.titleArray mutableCopy];
        cell.picArray = [self.picArray mutableCopy];
        cell.selectArray = [self.selectArray mutableCopy];
        cell.showSectionHeader = self.showSectionHeader;
        cell.row = indexPath.row;
        cell.popType = _popType;
        if ([TOPScanerShare top_singleFileUserDefinedFileSizeState] && self.showSectionHeader) {//是否开启自定义文件大小
            cell.numberLab.text = [NSString stringWithFormat:@"(%@ %@)",NSLocalizedString(@"topscan_about", @""),[TOPDocumentHelper top_memorySizeStr:self.totalSizeNum * [TOPScanerShare top_userDefinedFileSize]/100.0]];
        } else {
            cell.numberLab.text = [NSString stringWithFormat:@"(%@)",self.numberStr];
        }
        
        if (indexPath.row == self.titleArray.count-1) {
            cell.lineView.hidden = YES;
        }else{
            cell.lineView.hidden = NO;
        }
        return cell;
        
    }else{
        TOPShareCancelCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPShareCancelCell class]) forIndexPath:indexPath];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.titleArray.count : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(self.itemSpace, 10, IPAD_CELLW-2*self.itemSpace, self.itemSpace)];
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return self.itemSpace;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.showSectionHeader && !section) {
        CGFloat viewHeight = 60, viewWidth = IPAD_CELLW-2*self.itemSpace;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
        UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, viewWidth - 130, viewHeight)];
        noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        noClassLab.textAlignment = NSTextAlignmentNatural;
        noClassLab.adjustsFontSizeToFitWidth = YES;
        noClassLab.font = PingFang_R_FONT_(15);
        noClassLab.text = NSLocalizedString(@"topscan_userdefinedsize", @"");
        [headerView addSubview:noClassLab];
        
        UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(viewWidth - 51 - 20, 15, 51, 31)];
        switchBtn.on = [TOPScanerShare top_singleFileUserDefinedFileSizeState];
        [switchBtn addTarget:self action:@selector(top_switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [headerView addSubview:switchBtn];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 59, viewWidth - 20*2, 1)];
        line.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(235, 235, 235, 1.0)];
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (self.showSectionHeader && !section) ? 50 : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        if (self.selectBlock) {
            self.selectBlock(indexPath.row,self.numberStr);
        }
        [self top_dismissView];
    }
    else
    {
        self.cancelBlock();
        [self top_dismissView];
    }
}

- (void)top_switchValueChanged:(id)sender{
    UISwitch *whichSwitch = (UISwitch *)sender;
    BOOL setting = whichSwitch.isOn;
    [TOPScanerShare top_writeUserDefinedFileSizeState:setting];
    [self.tableView reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.isFinish) {
        [self top_showView];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.cancelBlock();
    [self top_dismissView];
}

- (void)top_showView
{
    CGFloat sectionHeaderHeight = self.showSectionHeader ? 60 : 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).offset(-(self.tableView.rowHeight*(self.titleArray.count+1)+sectionHeaderHeight+2*self.itemSpace+TOPBottomSafeHeight));
        }];
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).offset(-(self.tableView.rowHeight*(self.titleArray.count+1)+sectionHeaderHeight+2*self.itemSpace+TOPBottomSafeHeight+20));
        }];
        self.maskView.backgroundColor = RGBA(0, 0, 0, 0.5);
        [self.tableView.superview layoutIfNeeded];
    }completion:^(BOOL finished) {
        self.isFinish = YES;
    }];
}

- (void)top_dismissView
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
        }];
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
        }];
        self.maskView.alpha = 0;
        [self.tableView.superview layoutIfNeeded];

    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setNumberStr:(NSString *)numberStr{
    _numberStr = numberStr;
    [self.tableView reloadData];
}

- (void)setPopType:(TOPPopUpBounceViewType)popType{
    _popType = popType;
    if (popType == TOPPopUpBounceViewTypeSort || popType ==TOPPopUpBounceViewTypeTagSort) {
        self.backView.hidden = NO;
        self.itemSpace = 15;
    }else{
        self.backView.hidden = YES;
        self.itemSpace = 10;
    }
    [self top_tableView_makMas:_showSectionHeader];
    [self.tableView reloadData];
}

- (void)setSelectArray:(NSArray *)selectArray{
    _selectArray = selectArray;
    [self.tableView reloadData];
}

@end
