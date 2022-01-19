#define  cell_H 45

#import "TOPSettingShowView.h"
#import "TOPScanSettingShowViewCell.h"
@interface TOPSettingShowView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIButton * cancelBtn;
@end
@implementation TOPSettingShowView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        [self top_setTopAndBottomView];
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(cell_H, 0, cell_H, 0));
        }];
    }
    return self;
}

- (void)top_setTopAndBottomView{
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 250, cell_H)];
    titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    titleLab.font = [UIFont boldSystemFontOfSize:18];
    titleLab.textAlignment = NSTextAlignmentNatural;
    self.titleLab = titleLab;
    [self addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(250, cell_H));
    }];
    
    UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(TOPScreenWidth-80-40, self.bounds.size.height-cell_H, 80, cell_H)];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [cancelBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(top_clickCancel) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn = cancelBtn;
    [self addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-5);
        make.bottom.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(80, cell_H));
    }];
    
}
- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    self.tableView.frame = CGRectMake(0, cell_H, self.bounds.size.width, self.bounds.size.height-cell_H*2);
    self.cancelBtn.frame = CGRectMake(TOPScreenWidth-80-40, self.bounds.size.height-cell_H, 80, cell_H);
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(cell_H, 0, cell_H, 0));
    }];
    [self.cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-5);
        make.bottom.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(80, cell_H));
    }];
    [self.tableView reloadData];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[TOPScanSettingShowViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPScanSettingShowViewCell class])];
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
    TOPScanSettingShowViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPScanSettingShowViewCell class]) forIndexPath:indexPath];
    cell.titleLab.text = self.dataArray[indexPath.row];
    
    NSInteger selectRow;
    if ([self.showType isEqualToString:TOPPageSize]) {
        selectRow = [TOPScanerShare top_pageSizeType] - 1;
    }else if ([self.showType isEqualToString:TOPCollagePageSize]) {
        selectRow = [self.pdfSizeArray indexOfObject:@([TOPScanerShare top_collagePageSizeValue])];
    }else{
        NSInteger type = [TOPScanerShare top_lastFilterType] ? TOPProcessTypeLastFilter : [TOPScanerShare top_defaultProcessType];
        selectRow = [self.filterArray indexOfObject:@(type)];
    }
    if (indexPath.row == selectRow) {
        cell.iconImg.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
    }else{
        cell.iconImg.image = [UIImage imageNamed:@"top_scamerbatch_AllNormal"];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, cell_H)];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, cell_H)];
    footerView.backgroundColor = [UIColor whiteColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cell_H;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.showType isEqualToString:TOPCollagePageSize]) {
        NSInteger pageSize = [self.pdfSizeArray[indexPath.row] integerValue];
        [TOPScanerShare top_writeCollagePageSizeValue:pageSize];
    }else if ([self.showType isEqualToString:TOPPageSize]) {
        NSInteger pageSize = [self.pdfSizeArray[indexPath.row] integerValue];
        [TOPScanerShare top_writePageSizeType:pageSize];
    }else{
        //当选择最后一个渲染类型时要特殊对待
        NSInteger processType = [self.filterArray[indexPath.row] integerValue];
        if (processType == TOPProcessTypeLastFilter) {
            [TOPScanerShare top_writeLastFilterType:1];
        }else{
            [TOPScanerShare top_writeLastFilterType:0];
            [TOPScanerShare top_writeDefaultProcessType:processType];
        }
    }
    [self.tableView reloadData];
    if (self.top_clickDismiss) {
        self.top_clickDismiss(indexPath.row+1, self.showType);
    }
}

- (void)top_clickCancel{
    if (self.top_clickDismiss) {
        self.top_clickDismiss(0, self.showType);
    }
}

- (void)setShowType:(NSString *)showType{
    _showType = showType;
    if ([self.showType isEqualToString:TOPCollagePageSize]) {
        self.titleLab.text = NSLocalizedString(@"topscan_changepagesize", @"");
    }else{
        self.titleLab.text = NSLocalizedString(@"topscan_defaultprocess", @"");
    }
}

@end
