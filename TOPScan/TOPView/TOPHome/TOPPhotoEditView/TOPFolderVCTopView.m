#define TopView_H 44

#import "TOPFolderVCTopView.h"
@interface TOPFolderVCTopView()
@property (nonatomic ,strong)NSMutableArray * btnArray;
@property (nonatomic ,strong)UILabel * titleLab;;
@end
@implementation TOPFolderVCTopView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        [self top_setupUITopH];
    }
    return self;
}

- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray new];
    }
    return _btnArray;
}
- (void)top_setupUITopH{
    NSString * backIcon = [NSString new];
    if (isRTL()) {
        backIcon = @"top_nav_reverseback_ico";
    }else{
        backIcon = @"top_nav_back_ico";
    }
    NSArray *titleArray = @[@"top_headermore_icon-2",@"top_selectstate_icon-2",[self viewTypeImgString],@"top_picture_icon-2",@"top_addfolder_icon-2",backIcon];
    for (int i = 0; i < titleArray.count; i ++) {
        CGFloat btnwidth = 32;
        CGFloat btnHeight = TOPNavBarHeight;
        CGFloat btnX = TOPScreenWidth - ((i+1) * btnwidth+10);
        CGFloat btnY = 0;
        TOPImageTitleButton * btn = [[TOPImageTitleButton alloc]init];
        if (i == titleArray.count-1) {
            btn.frame = CGRectMake(0, btnY, btnwidth, btnHeight);
            if (isRTL()) {
                btn.style = EImageLeftTitleRightCenter;
            }else{
                btn.style = EImageLeftTitleRightLeft;
            }
        }else{
            btn.frame = CGRectMake(btnX, btnY, btnwidth, btnHeight);
            btn.style = EFitTitleLeftImageRight;
        }
        [btn setImage:[UIImage imageNamed:titleArray[i]] forState:UIControlStateNormal];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn.titleLabel setFont:[self fontsWithSize:12]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.selected = NO;
        btn.tag = 1000 + i;
        [btn addTarget:self action:@selector(top_itemSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnArray addObject:btn];
        [self addSubview:btn];
    }
    UILabel * titleLab = [UILabel new];
    titleLab.font = [UIFont systemFontOfSize:16];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.lineBreakMode = NSLineBreakByTruncatingHead;
    titleLab.userInteractionEnabled = YES;
    [self.btnArray addObject:titleLab];
    [self addSubview:titleLab];

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTap:)];
    [titleLab addGestureRecognizer:tap];

    [self top_setChangeFream:6];
    self.titleLab.hidden = YES;
}
- (NSString *)viewTypeImgString{
    NSString * tempString = [NSString new];
    if ([TOPScanerShare top_listType] == ShowThreeGoods) {
        tempString = @"top_viewtype_icon-2";
    }else{
        tempString = @"top_viewtype_icon-4";
    }
    return tempString;
}
- (void)top_refreshViewTypeBtn{
    TOPImageTitleButton * btn2 = self.btnArray[2]; 
    [btn2 setImage:[UIImage imageNamed:[self viewTypeImgString]] forState:UIControlStateNormal];
}
- (void)top_setChangeFream:(CGFloat)intervalW{
    TOPImageTitleButton * btn0 = self.btnArray[0];
    TOPImageTitleButton * btn1 = self.btnArray[1];
    TOPImageTitleButton * btn2 = self.btnArray[2];
    TOPImageTitleButton * btn3 = self.btnArray[3];
    TOPImageTitleButton * btn4 = self.btnArray[4];
    TOPImageTitleButton * btn5 = self.btnArray[5];
    UILabel * titleLab = self.btnArray[6];
    CGFloat btnwidth = 32-5;
    CGFloat btnHeight = TopView_H;
    [btn0 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self);
        make.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(btnwidth, btnHeight));
    }];
    [btn1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(btn0.mas_leading).offset(-intervalW);
        make.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(btnwidth, btnHeight));
    }];
    [btn2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(btn1.mas_leading).offset(-intervalW);
        make.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(btnwidth, btnHeight));
    }];
    [btn3 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(btn2.mas_leading).offset(-intervalW);
        make.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(btnwidth, btnHeight));
    }];
    [btn4 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(btn3.mas_leading).offset(-intervalW);
        make.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(btnwidth, btnHeight));
    }];
    [btn5 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(10);
        make.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(btnwidth, btnHeight));
    }];
    [titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(btn5.mas_trailing).offset(5);
        make.trailing.equalTo(btn4.mas_leading).offset(-5);
        make.top.equalTo(self);
        make.height.mas_equalTo(btnHeight);
    }];
    self.titleLab = titleLab;
}
- (void)top_itemSelect:(UIButton*)btn{
    btn.selected = !btn.selected;
    if (self.top_DocumentHeadClickHandler) { 
        self.top_DocumentHeadClickHandler(btn.tag - 1000,btn.selected);
    }
}
- (void)top_setupUITopHAgain{
    [UIView animateWithDuration:0.3 animations:^{
        [self top_setChangeFream:4];
        self.titleLab.hidden = NO;
        [self layoutIfNeeded];
    }];
}
- (void)top_setupUITopHRestore{
    [UIView animateWithDuration:0.3 animations:^{
        [self top_setChangeFream:6];
        self.titleLab.hidden = YES;
        [self layoutIfNeeded];
    }];
}
- (void)setTitleString:(NSString *)titleString{
    self.titleLab.text = titleString;
}
- (void)top_clickTap:(UIGestureRecognizer *)tap{
    if (self.top_clickTap) {
        self.top_clickTap();
    }
}
- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}

@end
