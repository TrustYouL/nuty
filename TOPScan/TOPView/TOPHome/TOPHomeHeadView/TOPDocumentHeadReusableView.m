#define TopView_H 55

#import "TOPDocumentHeadReusableView.h"
@interface TOPDocumentHeadReusableView()
@property (nonatomic, strong)UIView * vipBackView;
@property (nonatomic, strong)UIButton * viewTypeBtn;
@property (nonatomic, strong)UIButton * addFolderBtn;
@end
@implementation TOPDocumentHeadReusableView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        [self top_setupUITopH:0];
    }
    return self;
}

- (void)top_setupUITopH:(CGFloat)topH{
    NSMutableArray * tempArray = [NSMutableArray new];
    
    TOPImageTitleButton *tagBtn = [[TOPImageTitleButton alloc] initWithStyle:(EFitTitleLeftImageRight)];
    tagBtn.padding = CGSizeMake(2, 2);
    [tagBtn setImage:[UIImage imageNamed:@"top_below"] forState:UIControlStateNormal];
    [tagBtn setImage:[UIImage imageNamed:@"top_beup"] forState:UIControlStateSelected];
    tagBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [tagBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGB(51, 51, 51)] forState:UIControlStateNormal];
    [tagBtn addTarget:self action:@selector(top_tagBtnSelect:) forControlEvents:UIControlEventTouchUpInside];
    tagBtn.titleLabel.minimumScaleFactor = 0.8;
    self.tagBtn = tagBtn;
    [tempArray addObject:tagBtn];
    [self addSubview:tagBtn];
    
    NSArray *iconArray = @[@"top_headermore_icon",@"top_selectstate_icon",[self viewTypeImgString],@"top_picture_icon",@"top_addfolder_icon"];
    for (int i = 0; i < iconArray.count; i ++) {
        UIButton * btn = [[UIButton alloc]init];
        [btn setImage:[UIImage imageNamed:iconArray[i]] forState:UIControlStateNormal];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn.titleLabel setFont:[self fontsWithSize:12]];
        btn.selected = NO;
        btn.tag = 1000 + i;
        if (i == iconArray.count-1) {
            self.addFolderBtn = btn;
        }
        if (i == 2) {
            self.viewTypeBtn = btn;
        }
        [btn addTarget:self action:@selector(top_itemSelect:) forControlEvents:UIControlEventTouchUpInside];
        [tempArray addObject:btn];
        [self addSubview:btn];
    }
    
    _vipBackView = [UIView new];
    _vipBackView.backgroundColor = [UIColor top_viewControllerBackGroundColor:RGB(0, 0, 0) defaultColor:TOPAppBackgroundColor];
    if (_isShowVip) {
        [tempArray addObject:_vipBackView];
        [self addSubview:_vipBackView];
    }
    [self top_setViewFream:tempArray];
    if ([tempArray containsObject:_vipBackView]) {
        [self top_setVipChildView];
    }
}
- (NSString *)viewTypeImgString{
    NSString * tempString = [NSString new];
    if ([TOPScanerShare top_listType] == ShowThreeGoods) {
        tempString = @"top_viewtype_icon";
    }else{
        tempString = @"top_viewtype_icon-3";
    }
    return tempString;
}
- (void)top_refreshViewTypeBtn{
    [self.viewTypeBtn setImage:[UIImage imageNamed:[self viewTypeImgString]] forState:UIControlStateNormal];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _vipBackView.backgroundColor = [UIColor top_viewControllerBackGroundColor:RGB(0, 0, 0) defaultColor:TOPAppBackgroundColor];
    [self.tagBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGB(51, 51, 51)] forState:UIControlStateNormal];
}
- (void)top_setViewFream:(NSMutableArray * )tempArray{
    TOPImageTitleButton * tempBtn1 = tempArray[0];
    UIButton * btn1 = tempArray[1];
    UIButton * btn2 = tempArray[2];
    UIButton * btn3 = tempArray[3];
    UIButton * btn4 = tempArray[4];
    UIButton * btn5 = tempArray[5];

    CGFloat btnwidth = 32;
    CGFloat btnY = 0;
    
    [tempBtn1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(10);
        make.top.equalTo(self).offset(btnY);
        make.size.mas_equalTo(CGSizeMake(150, TopView_H));
    }];
    [btn1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-10);
        make.top.equalTo(self).offset(btnY);
        make.size.mas_equalTo(CGSizeMake(btnwidth, TopView_H));
    }];
    [btn2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(btn1.mas_leading);
        make.top.equalTo(self).offset(btnY);
        make.size.mas_equalTo(CGSizeMake(btnwidth, TopView_H));
    }];
    [btn3 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(btn2.mas_leading);
        make.top.equalTo(self).offset(btnY);
        make.size.mas_equalTo(CGSizeMake(btnwidth, TopView_H));
    }];
    [btn4 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(btn3.mas_leading);
        make.top.equalTo(self).offset(btnY);
        make.size.mas_equalTo(CGSizeMake(btnwidth, TopView_H));
    }];
    [btn5 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(btn4.mas_leading);
        make.top.equalTo(self).offset(btnY);
        make.size.mas_equalTo(CGSizeMake(btnwidth, TopView_H));
    }];
}

- (void)top_setVipChildView{
    UIImageView * backImg = [UIImageView new];
    backImg.backgroundColor = RGBA(11, 152, 124, 1.0);
    backImg.layer.cornerRadius = 10;
    backImg.layer.masksToBounds = YES;
//    backImg.image = [UIImage imageNamed:@"top_vipBackImg"];
    
    UIImageView * iconImg = [UIImageView new];
    iconImg.image = [UIImage imageNamed:@"top_vipIcon"];
    
    UILabel * noAdsLab = [UILabel new];
    noAdsLab.textColor = [UIColor whiteColor];
    noAdsLab.font = [UIFont systemFontOfSize:14];
    noAdsLab.textAlignment = NSTextAlignmentNatural;
    noAdsLab.text = NSLocalizedString(@"topscan_noads", @"");
    
    UILabel * unlimitLab = [UILabel new];
    unlimitLab.textColor = [UIColor whiteColor];
    unlimitLab.font = [UIFont systemFontOfSize:14];
    unlimitLab.textAlignment = NSTextAlignmentNatural;
    unlimitLab.text = NSLocalizedString(@"topscan_unlimitedfeatures", @"");

    UIButton * freeBtn = [UIButton new];
    freeBtn.backgroundColor = [UIColor whiteColor];
    freeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [freeBtn setTitle:NSLocalizedString(@"topscan_freetrial", @"") forState:UIControlStateNormal];
    [freeBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [freeBtn addTarget:self action:@selector(top_clickFreeBtn) forControlEvents:UIControlEventTouchUpInside];
    freeBtn.layer.cornerRadius = 30/2;
    
    [_vipBackView addSubview:backImg];
    [_vipBackView addSubview:iconImg];
    [_vipBackView addSubview:noAdsLab];
    [_vipBackView addSubview:unlimitLab];
    [_vipBackView addSubview:freeBtn];
    [backImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_vipBackView).offset(10);
        make.trailing.equalTo(_vipBackView).offset(-10);
        make.top.equalTo(_vipBackView).offset(10);
        make.bottom.equalTo(_vipBackView);
    }];
    [iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_vipBackView).offset(25);
        make.centerY.equalTo(_vipBackView);
        make.size.mas_equalTo(CGSizeMake(49, 49));
    }];
    [noAdsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(iconImg.mas_trailing).offset(15);
        make.top.equalTo(_vipBackView).offset(22);
        make.size.mas_equalTo(CGSizeMake(150, 15));
    }];
    [unlimitLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(iconImg.mas_trailing).offset(15);
        make.bottom.equalTo(_vipBackView).offset(-12);
        make.size.mas_equalTo(CGSizeMake(150, 15));
    }];
    [freeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_vipBackView).offset(-25);
        make.centerY.equalTo(backImg.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(90, 30));
    }];
}
- (void)top_itemSelect:(UIButton*)btn{
    btn.selected = !btn.selected;
    if (self.top_DocumentHeadClickHandler) {
        self.top_DocumentHeadClickHandler(btn.tag - 1000,btn.selected);
    }
}
- (void)top_tagBtnSelect:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.top_tagBtnClick) {
        self.top_tagBtnClick(sender.selected);
    }
}
- (void)top_clickBtnSelect:(UIButton *)sender{
    
}
- (void)top_clickFreeBtn{
    if (self.top_freeTrial) {
        self.top_freeTrial();
    }
}
- (void)setModel:(TOPTagsListModel *)model{
    NSString * tagsName = model.tagName;
    NSString * num = model.tagNum;
    if ([tagsName isEqualToString:TOP_TRTagsAllDocesKey]) {
        tagsName = TOP_TRTagsAllDocesName;
    }else if([tagsName isEqualToString:TOP_TRTagsUngroupedKey]){
        tagsName = TOP_TRTagsUngroupedName;
    }
    NSString *titStr = [NSString stringWithFormat:@"%@(%@)",tagsName,num];
    CGSize labSize = [TOPDocumentHelper top_getSizeWithStr:titStr Width:140 Font:17];
    if (labSize.width >= 110) {
        self.tagBtn.style = ETitleLeftImageRightLeft;
    } else {
        if (isRTL()) {
            self.tagBtn.style = ETitleLeftImageRightCenter;
        }else{
            self.tagBtn.style = EFitTitleLeftImageRight;
        }
    }
    [self.tagBtn setTitle:titStr forState:UIControlStateNormal];
    [TOPScanerShare top_writeSaveTagsName:model.tagName];
    if ([model.tagName isEqualToString:TOP_TRTagsAllDocesKey]) {
        self.addFolderBtn.hidden = NO;
    }else{
        self.addFolderBtn.hidden = YES;
    }
}

- (void)setIsShowVip:(BOOL)isShowVip{
    _isShowVip = isShowVip;
    if (isShowVip) {
        [self addSubview:_vipBackView];
        [_vipBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self);
            make.top.equalTo(self).offset(TopView_H);
        }];
        [self top_setVipChildView];
    }else{
        if (_vipBackView) {
            [_vipBackView removeFromSuperview];
        }
    }
}
- (void)setAllDocsString:(NSString *)allDocsString{
}
@end
