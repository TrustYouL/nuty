#import "TOPNextSettingShowView.h"
#import "TOPSettingShowViewCell.h"
#import "TOPShowImgMoreCell.h"
@interface TOPNextSettingShowView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic ,strong)NSMutableArray * formatterArray;//保存时间格式
@property (nonatomic ,strong)NSMutableArray * currentTimeArray;//保存当前时间
@property (nonatomic ,strong)NSMutableArray * jpgQualityArray;//照片质量选择
@property (nonatomic ,strong)NSMutableArray * processArray;//默认渲染模式
@property (nonatomic ,strong)NSMutableArray * imgMoreArray;//图片展示更多数据
@property (nonatomic ,strong)TOPSettingFormatModel * formatterModel;

@end
@implementation TOPNextSettingShowView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 55)];
        headerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
        
        UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(TOPScreenWidth-60, 0, 40, 55)];
        [cancelBtn setImage:[UIImage imageNamed:@"top_menu_close"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(top_clickToHide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:headerView];
        [self addSubview:cancelBtn];
        [self addSubview:self.tableView];

        [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self);
            make.height.mas_equalTo(55);
        }];
        
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-20);
            make.top.equalTo(self);
            make.height.mas_equalTo(55);
            make.width.mas_equalTo(40);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.top.equalTo(self).offset(55);
            make.bottom.equalTo(self).offset(-10);
        }];
    }
    return self;
}
- (void)setEnterType:(TOPFormatterViewEnterType)enterType{
    _enterType = enterType;
    if (_enterType == TOPFormatterViewEnterTypeSetting) {
        [self top_loadData];
    }else if (_enterType == TOPFormatterViewEnterTypeJPGQuality){
        self.tableView.scrollEnabled = NO;
        [self top_congfigJPGQualityData];
    }else if(_enterType == TOPFormatterViewEnterTypeDefaultProcess){
        [self top_loadProcessData];
    }else if(_enterType == TOPFormatterViewEnterTypeDocTime){
        [self top_loadDocTimeData];
    }else if (TOPFormatterViewEnterTypeImgMore){
        [self top_loadImgMore];
    }
}
- (void)top_loadImgMore{
    NSDictionary * dic1 = @{@"icon":@"top_photoshow_retake",
                            @"title":NSLocalizedString(@"topscan_retake", @""),
                            @"type":@(TOPPhotoShowViewImageBottomViewActionRetake),
                            @"showVip":@(NO)};
    NSDictionary * dic2 = @{@"icon":@"top_photoshow_watermark",
                            @"title":NSLocalizedString(@"topscan_addwatermark", @""),
                            @"type":@(TOPPhotoShowViewImageBottomViewActionWatermark),
                            @"showVip":@(NO)};
    NSDictionary * dic3 = @{@"icon":@"top_childvc_upload",
                            @"title":NSLocalizedString(@"topscan_upload", @""),
                            @"type":@(TOPPhotoShowViewImageBottomViewActionUpload),
                            @"showVip":@(![TOPPermissionManager top_enableByUploadFile])};
    NSDictionary * dic4 = @{@"icon":@"top_childvc_moreOCR",
                            @"title":NSLocalizedString(@"topscan_ocr", @""),
                            @"type":@(TOPPhotoShowViewImageBottomViewActionOcrRecognizer),
                            @"showVip":@(NO)};
    NSDictionary * dic5 = @{@"icon":@"top_photoshow_printing",
                            @"title":NSLocalizedString(@"topscan_printing", @""),
                            @"type":@(TOPPhotoShowViewImageBottomViewActionPrint),
                            @"showVip":@(NO)};
    NSDictionary * dic6 = @{@"icon":@"top_photoshow_note",
                            @"title":NSLocalizedString(@"topscan_note", @""),
                            @"type":@(TOPPhotoShowViewImageBottomViewActionNote),
                            @"showVip":@(NO)};
    NSDictionary * dic7 = @{@"icon":@"top_photoshow_picdetail",
                            @"title":NSLocalizedString(@"topscan_picdetailtitle", @""),
                            @"type":@(TOPHomeMoreFunctionPicDetail),
                            @"showVip":@(NO)};
    NSArray * tempArray = @[dic1,dic2,dic3,dic4,dic5,dic6,dic7];
    self.imgMoreArray = [tempArray mutableCopy];
    [self.tableView reloadData];
}
- (void)top_loadDocTimeData{
    NSArray * tempArray = @[@"yyyy/MM/dd HH:mm",@"MM/dd/yyyy HH:mm",@"dd/MM/yyyy HH:mm",@"yy/MM/dd HH:mm",@"MM/dd/yy HH:mm",@"dd/MM/yy HH:mm"];
    NSMutableArray * saveArray = [NSMutableArray new];
    for (int i = 0; i<tempArray.count; i++) {
        TOPSettingFormatModel * model = [TOPSettingFormatModel new];
        model.timeStyle = tempArray[i];
        model.formatString = [TOPDocumentHelper top_getCurrentTimeAndSendFormatterString:tempArray[i]];
        if ([tempArray[i] isEqualToString:[TOPScanerShare top_documentDateType]]) {
            model.isSelect = YES;
        }else{
            model.isSelect = NO;
        }
        [saveArray addObject:model];
    }
    self.processArray = saveArray;
    [self.tableView reloadData];
}
- (void)top_loadProcessData{
    NSInteger type = [TOPScanerShare top_lastFilterType] ? TOPProcessTypeLastFilter : [TOPScanerShare top_defaultProcessType];
    NSInteger selectRow = [self.filterArray indexOfObject:@(type)];
    
    NSMutableArray * tempArray = [NSMutableArray new];
    for (int i = 0; i<self.dataArray.count; i++) {
        TOPSettingFormatModel * model = [TOPSettingFormatModel new];
        model.formatString = self.dataArray[i];
        model.processType = [self.filterArray[i] integerValue];
        if (i == selectRow) {
            model.isSelect = YES;
        }else{
            model.isSelect = NO;
        }
        [tempArray addObject:model];
    }
    
    self.processArray = tempArray;
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}
- (void)top_loadData{
    NSArray * formatterStringArray = @[@"MMM dd, yyyy, HH.mm",
                                       @"MM-dd-yyyy HH.mm",
                                       @"yyyy-MM-dd HH.mm",
                                       @"dd-MM-yyyy HH.mm",
                                       @"MMM dd, yyyy",
                                       @"MM-dd-yyyy",
                                       @"MMM dd, yyyy, HH.mm",
                                       @"MM-dd-yyyy HH.mm",
                                       @"MMM dd, yyyy",
                                       @"MM-dd-yyyy",
                                       @"yyyy-MM-dd",
                                       @"dd-MM-yyyy",
                                       @"yyyy.MM.dd_HH.mm",
                                       @"MM.dd.yyyy_HH.mm",
                                       @"dd.MM.yyyy_HH.mm"];
    NSInteger selectRow = 0;
    self.formatterModel = [TOPSettingFormatModel new];
    self.formatterModel = [NSKeyedUnarchiver unarchiveObjectWithFile:TOPSettingFormatter_Path];
    for (int m = 0; m<formatterStringArray.count; m++) {
        NSString * saveString = [NSString new];
        if (m<6) {
            saveString = [NSString stringWithFormat:@"Doc %@",formatterStringArray[m]];
        }else{
            saveString = formatterStringArray[m];
        }
        if ([saveString isEqualToString:self.formatterModel.formatString]) {
            selectRow = m;
        }
        [self.formatterArray addObject:saveString];
    }
    
    for (int n = 0; n<formatterStringArray.count; n++) {
        TOPSettingFormatModel * model = [TOPSettingFormatModel new];
        if (n == selectRow) {
            model.isSelect = YES;
        }else{
            model.isSelect = NO;
        }
        if (n<6) {
            model.formatString = [NSString stringWithFormat:@"Doc %@",[TOPDocumentHelper top_getCurrentTimeAndSendFormatterString:formatterStringArray[n]]];
        }else{
            model.formatString = [TOPDocumentHelper top_getCurrentTimeAndSendFormatterString:formatterStringArray[n]];
        }
        [self.currentTimeArray addObject:model];
    }
    
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    });
}

- (void)top_congfigJPGQualityData{
    BOOL superHighShow = ![TOPPermissionManager top_enableByImageSuperHigh];
    BOOL highShow = ![TOPPermissionManager top_enableByImageHigh];
    NSArray *qualityStringArray = @[
        @{@"title":NSLocalizedString(@"topscan_superhigh", @""),@"value":@(10000000),@"showVip":@(superHighShow)},
        @{@"title":NSLocalizedString(@"topscan_picturequalityheight", @""),@"value":@(8000000),@"showVip":@(highShow)},
        @{@"title":NSLocalizedString(@"topscan_medium", @""),@"value":@(6000000),@"showVip":@(NO)},
        @{@"title":NSLocalizedString(@"topscan_picturequalitylow", @""),@"value":@(4000000),@"showVip":@(NO)},];
    for (NSDictionary *dic in qualityStringArray) {
        TOPSettingFormatModel * model = [[TOPSettingFormatModel alloc] init];
        model.formatString = dic[@"title"];
        model.pixValue = [dic[@"value"] floatValue];
        model.showVip = [dic[@"showVip"] boolValue];
        if (model.pixValue == TOP_TRSSMaxPiexl) {
            model.isSelect = YES;
        } else {
            model.isSelect = NO;
        }
        [self.jpgQualityArray addObject:model];
    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 55, self.width, self.height-55-10)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:[UIColor whiteColor]];
        [_tableView registerClass:[TOPSettingShowViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPSettingShowViewCell class])];
        [_tableView registerClass:[TOPShowImgMoreCell class] forCellReuseIdentifier:NSStringFromClass([TOPShowImgMoreCell class])];

    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_enterType == TOPFormatterViewEnterTypeSetting) {
        return self.currentTimeArray.count;
    }else if(_enterType == TOPFormatterViewEnterTypeJPGQuality){
        return self.jpgQualityArray.count;
    }else if (_enterType == TOPFormatterViewEnterTypeImgMore){
        return self.imgMoreArray.count;
    }else{
        return self.processArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_enterType == TOPFormatterViewEnterTypeImgMore) {
        TOPShowImgMoreCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPShowImgMoreCell class]) forIndexPath:indexPath];
        cell.moreDic = self.imgMoreArray[indexPath.row];
        return cell;
    }else{
        TOPSettingFormatModel * model = [TOPSettingFormatModel new];
        if (_enterType == TOPFormatterViewEnterTypeSetting) {
            model = self.currentTimeArray[indexPath.row];
        }else if(_enterType == TOPFormatterViewEnterTypeJPGQuality){
            model = self.jpgQualityArray[indexPath.row];
        }else{
            model = self.processArray[indexPath.row];
        }
        
        TOPSettingShowViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPSettingShowViewCell class]) forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 55)];
    headerView.backgroundColor = TOPAPPViewMainDarkColor;
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 55)];
    footerView.backgroundColor = TOPAPPViewMainDarkColor;
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TOPSettingFormatModel * formatModel = [TOPSettingFormatModel new];
    if (_enterType == TOPFormatterViewEnterTypeSetting) {
        formatModel.formatString = self.formatterArray[indexPath.row];
        self.formatterModel = formatModel;
        [NSKeyedArchiver archiveRootObject:self.formatterModel toFile:TOPSettingFormatter_Path];
        for (int i = 0 ; i < self.currentTimeArray.count; i ++) {
            TOPSettingFormatModel * model = self.currentTimeArray[i];
            model.isSelect = NO;
            if (indexPath.row == i) {
                model.isSelect = YES;
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.top_clickCell) {
                self.top_clickCell(formatModel.formatString);
            }
        });
    }else if(_enterType == TOPFormatterViewEnterTypeJPGQuality){
        formatModel = self.jpgQualityArray[indexPath.row];
        if (![self top_ValidateImagePermission:formatModel.pixValue]) {
            if (self.top_permissionAlertBlock) {
                self.top_permissionAlertBlock();
            }
            return;
        }
        [[NSUserDefaults standardUserDefaults] setFloat:formatModel.pixValue forKey:TOP_TRSSMaxPiexlKey];
        for (int i = 0 ; i < self.jpgQualityArray.count; i ++) {
            TOPSettingFormatModel * model = self.jpgQualityArray[i];
            model.isSelect = NO;
            if (indexPath.row == i) {
                model.isSelect = YES;
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.top_selectedJPGQualityBlock) {
                self.top_selectedJPGQualityBlock(formatModel.formatString, indexPath.row);
            }
        });
    }else if(_enterType == TOPFormatterViewEnterTypeDocTime){
        formatModel = self.processArray[indexPath.row];
        [[TOPDateFormatter shareInstance] top_removeSingleTon];
        [TOPScanerShare top_writeDocumentDateType:formatModel.timeStyle];
        for (int i = 0 ; i < self.processArray.count; i ++) {
            TOPSettingFormatModel * model = self.processArray[i];
            model.isSelect = NO;
            if (indexPath.row == i) {
                model.isSelect = YES;
            }
        }
        if (self.top_clickCell) {
            self.top_clickCell(formatModel.formatString);
        }
    }else if (_enterType == TOPFormatterViewEnterTypeImgMore){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.top_imgMoreBlock) {
                self.top_imgMoreBlock(self.imgMoreArray[indexPath.row]);
            }
        });
    }else{
        formatModel = self.processArray[indexPath.row];
        for (int i = 0 ; i < self.processArray.count; i ++) {
            TOPSettingFormatModel * model = self.processArray[i];
            model.isSelect = NO;
            if (indexPath.row == i) {
                model.isSelect = YES;
            }
        }
        NSInteger processType = formatModel.processType;
        if (processType == TOPProcessTypeLastFilter) {
            [TOPScanerShare top_writeLastFilterType:1];
        }else{
            [TOPScanerShare top_writeLastFilterType:0];
            [TOPScanerShare top_writeDefaultProcessType:processType];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.top_selectedProcessBlock) {
                self.top_selectedProcessBlock();
            }
        });
    }
    [self.tableView reloadData];
}

- (BOOL)top_ValidateImagePermission:(CGFloat)quantity {
    if (quantity == 8000000) {
        if (![TOPPermissionManager top_enableByImageHigh]) {
            return NO;
        }
    } else {
        if (quantity == 10000000) {
            if (![TOPPermissionManager top_enableByImageSuperHigh]) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)top_clickToHide{
    if (self.top_clickToDismiss) {
        self.top_clickToDismiss();
    }
}
#pragma mark -- lazy
- (NSMutableArray *)formatterArray{
    if (!_formatterArray) {
        _formatterArray = [NSMutableArray new];
    }
    return _formatterArray;
}

- (NSMutableArray *)currentTimeArray{
    if (!_currentTimeArray) {
        _currentTimeArray = [NSMutableArray new];
    }
    return _currentTimeArray;
}

- (NSMutableArray *)jpgQualityArray{
    if (!_jpgQualityArray) {
        _jpgQualityArray = [[NSMutableArray alloc] init];
    }
    return _jpgQualityArray;
}

- (NSMutableArray *)processArray{
    if (!_processArray) {
        _processArray = [[NSMutableArray alloc] init];
    }
    return _processArray;
}
- (NSMutableArray *)imgMoreArray{
    if (!_imgMoreArray) {
        _imgMoreArray = [NSMutableArray new];
    }
    return _imgMoreArray;
}

@end
