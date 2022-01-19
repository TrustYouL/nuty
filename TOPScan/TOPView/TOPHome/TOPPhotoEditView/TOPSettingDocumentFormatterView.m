#define AllPageBtn_W  90
#define CurrentPageBtn_W  120

#import "TOPSettingDocumentFormatterView.h"
#import "TOPSettingFormatterCell.h"
#import "TOPOcrAgainExoprtCell.h"
#import "TOPSettingFormatModel.h"
@interface TOPSettingDocumentFormatterView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic ,strong)UIButton * cancelBtn;
@property (nonatomic ,strong)UIButton * allPageBtn;
@property (nonatomic ,strong)UIButton * currentPageBtn;
@property (nonatomic ,strong)NSMutableArray * formatterArray;//保存时间格式
@property (nonatomic ,strong)NSMutableArray * currentTimeArray;//保存当前时间
@property (nonatomic ,strong)NSMutableArray * languageShowArray;//保存ocr语言解析的数据
@property (nonatomic ,strong)NSMutableArray * endpointArray;//节点数据
@property (nonatomic ,strong)NSMutableArray * top_exportArray;//导出
@property (nonatomic ,strong)NSMutableArray *jpgQualityArray;//图片质量
@property (nonatomic ,strong)TOPSettingFormatModel * formatterModel;
@end

@implementation TOPSettingDocumentFormatterView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        [self addSubview:self.tableView];
        
        UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-90, self.bounds.size.height-60, 70, 60)];
        cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [cancelBtn setTitle:[NSLocalizedString(@"topscan_cancel", @"") uppercaseString] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(top_clickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        self.cancelBtn = cancelBtn;
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self);
            make.bottom.equalTo(self).offset(-60);
        }];
        
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-20);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(70);
        }];
    }
    return self;
}

- (void)setEnterType:(TOPFormatterViewEnterType)enterType{
    _enterType = enterType;
    if (_enterType == TOPFormatterViewEnterTypeSetting) {
        [self top_loadData];
    }else if(_enterType == TOPFormatterViewEnterTypeTextAgainLanguage){
        [self top_textAgainLanguage];
    }else if(_enterType == TOPFormatterViewEnterTypeTextAgainEndpoint){
        self.tableView.scrollEnabled = NO;
        [self top_textAgainEndpoint];
    }else if (_enterType == TOPFormatterViewEnterTypeTextAgainExport || _enterType == TOPFormatterViewEnterTypeTextAgainShare){
        self.cancelBtn.hidden = YES;
        self.tableView.scrollEnabled = NO;
        self.tableView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(self);
        }];
        [self top_textAgainExport];
    }else if (_enterType == TOPFormatterViewEnterTypeJPGQuality){
        self.tableView.scrollEnabled = NO;
        [self top_congfigJPGQualityData];
    }
}

- (void)top_congfigJPGQualityData {
    NSArray *qualityStringArray = @[
        @{@"title":NSLocalizedString(@"topscan_superhigh", @""),@"value":@(10000000)},
        @{@"title":NSLocalizedString(@"topscan_picturequalityheight", @""),@"value":@(8000000)},
        @{@"title":NSLocalizedString(@"topscan_medium", @""),@"value":@(6000000)},
        @{@"title":NSLocalizedString(@"topscan_picturequalitylow", @""),@"value":@(4000000)},];
    for (NSDictionary *dic in qualityStringArray) {
        TOPSettingFormatModel * model = [[TOPSettingFormatModel alloc] init];
        model.formatString = dic[@"title"];
        model.pixValue = [dic[@"value"] floatValue];
        if (model.pixValue == TOP_TRSSMaxPiexl) {
            model.isSelect = YES;
        } else {
            model.isSelect = NO;
        }
        [self.jpgQualityArray addObject:model];
    }
}

- (void)top_textAgainExport{
    [self.top_exportArray removeAllObjects];
    NSArray * titleArray = @[NSLocalizedString(@"topscan_ocrexporttxt", @""),[NSLocalizedString(@"topscan_graffititext", @"") uppercaseString],NSLocalizedString(@"topscan_ocrexportcopy", @"")];
    NSArray * iconArray = @[@"top_ShareTXT",@"top_exporttext",@"top_ocr_textcopy"];
    for (int i = 0; i<titleArray.count; i++) {
        TOPSettingFormatModel * model = [TOPSettingFormatModel new];
        model.iconImg = iconArray[i];
        model.formatString = titleArray[i];
        [self.top_exportArray addObject:model];
    }
    [self.tableView reloadData];
}

- (void)top_textAgainEndpoint{
    [self.endpointArray removeAllObjects];
    //当前界面显示用到
    NSString * endpointString = [NSString new];
    if ([TOPScanerShare top_saveOcrEndpoint] == nil) {
        NSDictionary * lauguageDic = [TOPScanerShare top_saveOcrLanguage];
        endpointString = [TOPDocumentHelper top_getEndPoint:lauguageDic];
    }else{
        NSDictionary * endpointDic = [TOPScanerShare top_saveOcrEndpoint];
        if (endpointDic.allKeys.count>0) {
            endpointString = endpointDic.allValues[0];
        }
    }
    NSMutableArray * tempArray = [NSMutableArray new];
    NSArray * endpointData = [TOPDocumentHelper top_getEndpointData];
    for (int n = 0; n<endpointData.count; n++) {
        NSDictionary * dic = endpointData[n];
        TOPSettingFormatModel * model = [TOPSettingFormatModel new];
        if (dic.allKeys.count>0) {
            model.formatString = dic.allKeys[0];
            if ([dic.allValues[0] isEqual:endpointString]) {
                model.isSelect = YES;
            }else{
                model.isSelect = NO;
            }
            [tempArray addObject:model];
        }
    }
    [self.endpointArray addObjectsFromArray:tempArray];
    [self.tableView reloadData];
}

- (void)top_textAgainLanguage{
    [self.languageShowArray removeAllObjects];
    //当前界面显示用到
    NSInteger selectRow = 0;
    NSDictionary * languageDic = [TOPScanerShare top_saveOcrLanguage];
    NSString * compareString = [NSString new];
    if (languageDic.allKeys.count>0) {
        compareString = languageDic.allKeys[0];
    }
    for (int n = 0; n<self.languageArray.count; n++) {
        NSDictionary * dic = self.languageArray[n];
        TOPSettingFormatModel * model = [TOPSettingFormatModel new];
        if (dic.allKeys.count>0) {
            model.formatString = dic.allKeys[0];
            if ([model.formatString isEqualToString:compareString]) {
                selectRow = n;
                model.isSelect = YES;
            }else{
                model.isSelect = NO;
            }
            [self.languageShowArray addObject:model];
        }
    }
    
    [self.tableView reloadData];
    //滚动到当前选中行
    if (self.languageShowArray.count>0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //滚动到当前选中行
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        });
    }
}

- (void)top_loadData{
    NSArray * formatterStringArray = @[@"MMM dd yyyy HH.mm",
                                       @"MM-dd-yyy HH.mm",
                                       @"yyyy-MM-dd HH.mm",
                                       @"dd-MM-yyyy HH.mm",
                                       @"MMM dd yyyy",
                                       @"MM-dd-yyyy",
                                       @"MMM dd yyyy HH.mm",
                                       @"MM-dd-yyyy HH.mm",
                                       @"MMM dd yyyy",
                                       @"MM-dd-yyyy",
                                       @"yyyy-MM-dd",
                                       @"dd-MM-yyyy",
                                       @"yyyy.MM.dd_HH.mm",
                                       @"MM.dd.yyyy_HH.mm",
                                       @"dd.MM.yyyy_HH.mm"];
    NSInteger selectRow = 0;
    self.formatterModel = [TOPSettingFormatModel new];
    self.formatterModel = [NSKeyedUnarchiver unarchiveObjectWithFile:TOPSettingFormatter_Path];
    
    //写入文档到本地时用到
    for (int m = 0; m<formatterStringArray.count; m++) {
        NSString * saveString = [NSString new];
        if (m<6) {
            saveString = [NSString stringWithFormat:@"Doc %@",formatterStringArray[m]];
        }else{
            saveString = formatterStringArray[m];
        }
        //确定选中的位置
        if ([saveString isEqualToString:self.formatterModel.formatString]) {
            selectRow = m;
        }
        [self.formatterArray addObject:saveString];
    }
    //当前界面显示用到
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
        //滚动到当前选中行
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    });
}

- (void)top_clickCancelBtn:(UIButton *)sender{
    if (self.top_clickToDismiss) {
        self.top_clickToDismiss();
    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-60);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        [_tableView registerClass:[TOPSettingFormatterCell class] forCellReuseIdentifier:NSStringFromClass([TOPSettingFormatterCell class])];
        [_tableView registerClass:[TOPOcrAgainExoprtCell class] forCellReuseIdentifier:NSStringFromClass([TOPOcrAgainExoprtCell class])];

    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_enterType == TOPFormatterViewEnterTypeSetting) {
        return self.currentTimeArray.count;
    }else if(_enterType == TOPFormatterViewEnterTypeTextAgainLanguage){
        return self.languageShowArray.count;
    }else if(_enterType == TOPFormatterViewEnterTypeTextAgainEndpoint){
        return self.endpointArray.count;
    }else if(_enterType == TOPFormatterViewEnterTypeJPGQuality){
        return self.jpgQualityArray.count;
    }else{
        return self.top_exportArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TOPSettingFormatModel * model = [TOPSettingFormatModel new];
    if (_enterType == TOPFormatterViewEnterTypeSetting) {
        model = self.currentTimeArray[indexPath.row];
    }else if(_enterType == TOPFormatterViewEnterTypeTextAgainLanguage){
        model = self.languageShowArray[indexPath.row];
    }else if(_enterType == TOPFormatterViewEnterTypeTextAgainEndpoint){
        model = self.endpointArray[indexPath.row];
    }else if(_enterType == TOPFormatterViewEnterTypeJPGQuality){
        model = self.jpgQualityArray[indexPath.row];
    }else{
        model = self.top_exportArray[indexPath.row];
    }
    
    if (_enterType == TOPFormatterViewEnterTypeTextAgainExport || _enterType == TOPFormatterViewEnterTypeTextAgainShare) {
        TOPOcrAgainExoprtCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPOcrAgainExoprtCell class]) forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }else{
        TOPSettingFormatterCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPSettingFormatterCell class]) forIndexPath:indexPath];
        cell.model = model;

        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, self.bounds.size.width-30, 40)];
    titleLab.text = NSLocalizedString(@"topscan_ocrchooseendpoint", @"");
    titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    titleLab.font = [UIFont boldSystemFontOfSize:18];
    titleLab.textAlignment = NSTextAlignmentNatural;
    [headerView addSubview:titleLab];
   
    UILabel * exportTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 60, 40)];
    exportTitle.font = [UIFont systemFontOfSize:18];
    exportTitle.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(150, 150, 150, 1.0)];
    exportTitle.textAlignment = NSTextAlignmentNatural;
    exportTitle.text = _enterType == TOPFormatterViewEnterTypeTextAgainShare ? NSLocalizedString(@"topscan_share", @"") : NSLocalizedString(@"topscan_ocrtextexport", @"");
    [headerView addSubview:exportTitle];
    
    TOPImageTitleButtonStyle btnStyle;
    if (isRTL()) {
        btnStyle = ETitleLeftImageRightCenter;
    }else{
        btnStyle = EImageLeftTitleRightCenter;
    }
    TOPImageTitleButton * allPageBtn = [[TOPImageTitleButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-15-AllPageBtn_W, 10, AllPageBtn_W, 40)];
    allPageBtn.style = btnStyle;
    allPageBtn.padding = CGSizeMake(5, 5);
    allPageBtn.selected = NO;
    allPageBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [allPageBtn setTitle:NSLocalizedString(@"topscan_ocragainallpage", @"") forState:UIControlStateNormal];
    [allPageBtn setImage:[UIImage imageNamed:@"top_select_n_1"] forState:UIControlStateNormal];
    [allPageBtn setImage:[UIImage imageNamed:@"top_exoprtbtnselect"] forState:UIControlStateSelected];
    [allPageBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    [allPageBtn addTarget:self action:@selector(top_clickAllPageBtn:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:allPageBtn];
    self.allPageBtn = allPageBtn;
   
    TOPImageTitleButton * currentPageBtn = [[TOPImageTitleButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-15-AllPageBtn_W-10-CurrentPageBtn_W, 10, CurrentPageBtn_W, 40)];
    currentPageBtn.style = btnStyle;
    currentPageBtn.padding = CGSizeMake(5, 5);
    currentPageBtn.selected = YES;
    currentPageBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [currentPageBtn setTitle:NSLocalizedString(@"topscan_ocragaincurrentpage", @"") forState:UIControlStateNormal];
    [currentPageBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    [currentPageBtn setImage:[UIImage imageNamed:@"top_select_n_1"] forState:UIControlStateNormal];
    [currentPageBtn setImage:[UIImage imageNamed:@"top_exoprtbtnselect"] forState:UIControlStateSelected];
    [currentPageBtn addTarget:self action:@selector(top_clickCurrentPageBtn:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:currentPageBtn];
    self.currentPageBtn = currentPageBtn;
    
    if (_enterType == TOPFormatterViewEnterTypeTextAgainEndpoint) {
        titleLab.hidden = NO;
        exportTitle.hidden = YES;
        allPageBtn.hidden = YES;
        currentPageBtn.hidden = YES;
    }else if(_enterType == TOPFormatterViewEnterTypeTextAgainExport || _enterType == TOPFormatterViewEnterTypeTextAgainShare){
        titleLab.hidden = YES;
        exportTitle.hidden = NO;
        if (self.dataArray.count>1) {
            allPageBtn.hidden = NO;
            currentPageBtn.hidden = NO;
        }else{
            allPageBtn.hidden = YES;
            currentPageBtn.hidden = YES;
        }
    }else{
        titleLab.hidden = YES;
        exportTitle.hidden = YES;
        allPageBtn.hidden = YES;
        currentPageBtn.hidden = YES;
    }
    [titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(headerView).offset(15);
        make.trailing.equalTo(headerView).offset(-15);
        make.top.equalTo(headerView).offset(10);
        make.bottom.equalTo(headerView);
    }];
    [exportTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(headerView).offset(15);
        make.top.equalTo(headerView).offset(10);
        make.bottom.equalTo(headerView);
        make.width.mas_equalTo(60);
    }];
    [allPageBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(headerView).offset(-15);
        make.top.equalTo(headerView).offset(10);
        make.bottom.equalTo(headerView);
        make.width.mas_equalTo(AllPageBtn_W);
    }];
    [currentPageBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(allPageBtn.mas_leading).offset(-10);
        make.top.equalTo(headerView).offset(10);
        make.bottom.equalTo(headerView);
        make.width.mas_equalTo(CurrentPageBtn_W);
    }];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_enterType == TOPFormatterViewEnterTypeTextAgainExport || _enterType == TOPFormatterViewEnterTypeTextAgainShare) {
        return 50;
    }
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_enterType == TOPFormatterViewEnterTypeTextAgainEndpoint||_enterType == TOPFormatterViewEnterTypeTextAgainExport || _enterType == TOPFormatterViewEnterTypeTextAgainShare) {
        return 50;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

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
    }else if(_enterType == TOPFormatterViewEnterTypeTextAgainLanguage){
        formatModel = self.languageShowArray[indexPath.row];
        if (self.top_clickCellSendLanguageDic) {
            self.top_clickCellSendLanguageDic(formatModel.formatString, indexPath.row);
        }
    }else if(_enterType == TOPFormatterViewEnterTypeTextAgainEndpoint){
        formatModel = self.endpointArray[indexPath.row];
        if (self.top_clickCellSendLanguageDic) {
            self.top_clickCellSendLanguageDic(formatModel.formatString, indexPath.row);
        }
    }else if(_enterType == TOPFormatterViewEnterTypeJPGQuality){
        formatModel = self.jpgQualityArray[indexPath.row];
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
    }else{
        if (self.top_clickCellSendExportType) {
            self.top_clickCellSendExportType(self.allPageBtn.selected, indexPath.row);
        }
    }
    
    [self.tableView reloadData];
}

- (void)top_clickAllPageBtn:(UIButton *)sender{
    sender.selected = YES;
    self.currentPageBtn.selected = NO;
}

- (void)top_clickCurrentPageBtn:(UIButton *)sender{
    sender.selected = YES;
    self.allPageBtn.selected = NO;
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

- (NSMutableArray *)languageArray{
    if (!_languageArray) {
        _languageArray = [NSMutableArray new];
    }
    return _languageArray;
}

- (NSMutableArray *)languageShowArray{
    if (!_languageShowArray) {
        _languageShowArray = [NSMutableArray new];
    }
    return _languageShowArray;
}

- (NSMutableArray *)endpointArray{
    if (!_endpointArray) {
        _endpointArray = [NSMutableArray new];
    }
    return _endpointArray;
}

- (NSMutableArray *)top_exportArray{
    if (!_top_exportArray) {
        _top_exportArray = [NSMutableArray new];
    }
    return _top_exportArray;
}

- (NSMutableArray *)jpgQualityArray{
    if (!_jpgQualityArray) {
        _jpgQualityArray = [[NSMutableArray alloc] init];
    }
    return _jpgQualityArray;
}

@end
