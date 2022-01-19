#import "TOPShareFileView.h"
#import "TOPShareFileModel.h"
#import "TOPShareFileCell.h"

@interface TOPShareFileView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, assign) BOOL showFinish;
@property (nonatomic, assign) CGFloat bgView_Height;
@property (nonatomic, copy) NSString *doneTitle;
@property (nonatomic, copy) void(^cancelBlock)(void);
@property (nonatomic, copy) void(^selectBlock)(TOPShareFileModel *cellModel);

@end

@implementation TOPShareFileView

- (instancetype)initWithItemArray:(NSArray *)items doneTitle:(NSString *)doneTitle cancelBlock:(void (^)(void))cancelBlock selectBlock:(void (^)(TOPShareFileModel * cellModel))selectBlock {
    if (self = [super init]) {
        self.itemArray = [NSMutableArray arrayWithArray:items];
        self.selectIndex = 0;
        self.showFinish = NO;
        self.doneTitle = doneTitle;
        self.cancelBlock = cancelBlock;
        self.selectBlock = selectBlock;
        [self top_configContentView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self top_showView];
        });
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [self.tableView reloadData];
}
- (void)top_showView {
    [UIView animateWithDuration:0.3 animations:^{
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).offset(-self.bgView_Height - TOPBottomSafeHeight+10);
        }];
        self.maskView.backgroundColor = RGBA(0, 0, 0, 0.5);
        [self.bgView.superview layoutIfNeeded];
    }completion:^(BOOL finished) {
        self.showFinish = YES;
    }];
}

- (void)top_dismissView {
    [UIView animateWithDuration:0.3 animations:^{
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
        }];
        self.maskView.alpha = 0;
        [self.bgView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.cancelBlock();
    [self top_dismissView];
}

- (void)top_clickCloseBtn {
    self.cancelBlock();
    [self top_dismissView];
}

- (void)top_clickDoneBtn {
    if (self.selectBlock) {
        TOPShareFileModel *model = self.itemArray[self.selectIndex];
        self.selectBlock(model);
    }
    [self top_dismissView];
}

#pragma mark -- 加载视图
- (void)top_configContentView {
    [self addSubview:self.maskView];
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.closeBtn];
    [self.bgView addSubview:self.doneBtn];
    [self.bgView addSubview:self.tableView];
    
    [self top_resetBgViewHeight];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    
    if (IS_IPAD) {
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.mas_equalTo(self.bgView_Height);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.mas_equalTo(self.bgView_Height);
        }];
    }
    
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(22);
        make.top.equalTo(self.bgView).offset(12);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
    }];
    
    [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bgView).offset(-15);
        make.centerY.equalTo(self.closeBtn.mas_centerY);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(60);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(15);
        make.trailing.equalTo(self.bgView).offset(-15);
        make.top.equalTo(self.bgView).offset(45);
        make.bottom.equalTo(self.bgView).offset(-10);
    }];
}

#pragma mark -- 重置背景视图的高度
- (void)top_resetBgViewHeight {
    self.bgView_Height = 430;
    if (self.itemArray.count > self.selectIndex) {
        TOPShareFileModel *model = self.itemArray[self.selectIndex];
        if (model.sectionData.count == 0) {
            self.bgView_Height = 290;
        }
    }
}

#pragma mark -- 重置背景视图布局
- (void)top_updateBgViewLayout {
    [self top_resetBgViewHeight];
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom).offset(-self.bgView_Height - TOPBottomSafeHeight+10);
        make.height.mas_equalTo(self.bgView_Height);
    }];
}

#pragma mark -- tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!section) {
        return self.itemArray.count;
    } else {
        TOPShareFileModel *model = self.itemArray[self.selectIndex];
        return model.sectionData.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    TOPShareFileModel *model = self.itemArray[self.selectIndex];
    if (model.sectionData.count > 0) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TOPShareFileCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPShareFileCell class]) forIndexPath:indexPath];
    if (!indexPath.section) {
        TOPShareFileModel *model = self.itemArray[indexPath.row];
        [cell top_configCellWithData:model];
    }
    if (indexPath.section == 1) {
        TOPShareFileModel *model = self.itemArray[self.selectIndex];
        TOPShareFileModel *sectionModel = model.sectionData[indexPath.row];
        [cell top_configCellWithData:sectionModel];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, IPAD_CELLW - 30, 32)];
    UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, 200, 32)];
    noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
    noClassLab.textAlignment = NSTextAlignmentNatural;
    noClassLab.adjustsFontSizeToFitWidth = YES;
    noClassLab.font = PingFang_R_FONT_(15);
    noClassLab.text = section == 0 ? NSLocalizedString(@"topscan_filetype", @"") : NSLocalizedString(@"topscan_fileformat", @"");//NSLocalizedString(@"topscan_userdefinedsize", @"");
    [headerView addSubview:noClassLab];
    [noClassLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(headerView).offset(7);
        make.top.equalTo(headerView);
        make.size.mas_equalTo(CGSizeMake(200, 32));
    }];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    TOPShareFileModel *model = self.itemArray[self.selectIndex];
    if (!section) {
        return 32;
    } else {
        if (model.sectionData.count > 0) {
            return 32;
        } else {
            return 0;
        }
    }
}

#pragma mark -- tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        self.selectIndex = indexPath.row;
        for (int i = 0; i < self.itemArray.count; i ++) {
            TOPShareFileModel *model = self.itemArray[i];
            if (i == indexPath.row) {
                model.isSelected = YES;
            } else {
                model.isSelected = NO;
            }
        }
        [self.tableView reloadData];
        [self top_updateBgViewLayout];
    } else {
        TOPShareFileModel *model = self.itemArray[self.selectIndex];
        for (int i = 0; i < model.sectionData.count; i ++) {
            TOPShareFileModel *sectionModel = model.sectionData[i];
            if (i == indexPath.row) {
                sectionModel.isSelected = YES;
                model.isZip = sectionModel.zipItem;
            } else {
                sectionModel.isSelected = NO;
            }
        }
        [self.tableView reloadData];
    }
}

#pragma mark -- 重新绘制cell边框
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            CGFloat cornerRadius = 10.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(CGRectMake(0, 0, IPAD_CELLW - 30, 50), 0, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:[UIColor colorWithWhite:1.f alpha:0.8f]].CGColor;

            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+50, bounds.size.height-lineHeight, bounds.size.width-50, lineHeight);
//                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                lineLayer.backgroundColor =[UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:RGBA(205, 205, 205, 1.0)].CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}

- (void)top_updateSubViewsLayout {
    [self.tableView reloadData];
}

#pragma mark -- lazy
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor clearColor];
    }
    return _maskView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
        _bgView.layer.cornerRadius = 10;
    }
    return _bgView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 50;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
        [_tableView registerClass:[TOPShareFileCell class] forCellReuseIdentifier:NSStringFromClass([TOPShareFileCell class])];
    }
    return _tableView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, (52), 44)];
        [btn setImage:[UIImage imageNamed:@"top_menu_close"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(top_clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn = btn;
    }
    return _closeBtn;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(TOPScreenWidth - 75, 0, 60, 30)];
        [btn setTitle:self.doneTitle forState:UIControlStateNormal];
        [btn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [btn.titleLabel setFont:PingFang_R_FONT_(17)];
        [btn addTarget:self action:@selector(top_clickDoneBtn) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn = btn;
    }
    return _doneBtn;
}

@end
