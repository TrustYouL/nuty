#import "TOPHomePageHeaderView.h"

@implementation TOPHomePageHeaderView
- (instancetype)init{
    
    self = [super init];
    if (self) {
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    UIButton * searchBtn = [UIButton new];
    searchBtn.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(255, 255, 255, 0.1)];
    searchBtn.tag = 1000;
    [searchBtn addTarget:self action:@selector(top_itemSelect:) forControlEvents:UIControlEventTouchUpInside];
    searchBtn.layer.masksToBounds = YES;
    searchBtn.layer.cornerRadius = 35/2;

    TOPImageTitleButtonStyle butStyle;
    butStyle = ETitleLeftImageRightCenter;
    TOPImageTitleButton *settingBtn = [[TOPImageTitleButton alloc] initWithStyle:(butStyle)];
    [settingBtn setImage:[UIImage imageNamed:@"top_bar_setting"] forState:UIControlStateNormal];
    settingBtn.backgroundColor = [UIColor clearColor];
    settingBtn.tag = 1001;
    [settingBtn addTarget:self action:@selector(top_itemSelect:) forControlEvents:UIControlEventTouchUpInside];

    NSString *vipImg = [TOPAppTools needShowDiscountThemeView] ?  @"top_red_gift" : @"top_vip_logo";
    TOPImageTitleButton *vipBtn = [[TOPImageTitleButton alloc] initWithStyle:(butStyle)];
    [vipBtn setImage:[UIImage imageNamed:vipImg] forState:UIControlStateNormal];
    vipBtn.tag = 1002;
    [vipBtn addTarget:self action:@selector(top_itemSelect:) forControlEvents:UIControlEventTouchUpInside];
    if ([TOPAppTools needShowDiscountThemeView]) {
        [self top_shakeImage:vipBtn.imageView];
    }
    UIImageView * imgView = [UIImageView new];
    imgView.image = [UIImage imageNamed:@"top_homesearch"];
    
    UILabel * titleLab = [UILabel new];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont boldSystemFontOfSize:16];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.hidden = YES;
    titleLab.tag = 1003;
    
    [self addSubview:settingBtn];
    [self addSubview:searchBtn];
    [self addSubview:vipBtn];
    [self addSubview:imgView];
    [self addSubview:titleLab];
    
    CGFloat searchR = 0;
    if (![TOPUserInfoManager shareInstance].isVip) {//不是会员
        vipBtn.hidden = NO;
        searchR = 45;
    }else{
        vipBtn.hidden = YES;
        searchR = 20;
    }
    [settingBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(5);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    [vipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-5);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    [searchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(settingBtn.mas_trailing).offset(5);
        make.trailing.equalTo(self).offset(-searchR);
        make.top.equalTo(self).offset(4.5);
        make.height.mas_equalTo(35);
    }];
    [imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(settingBtn.mas_trailing).offset(15);
        make.centerY.equalTo(searchBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(40);
        make.trailing.equalTo(self).offset(-40);
        make.top.bottom.equalTo(self);
    }];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    
}
- (void)top_changeChildHideState:(NSString *)titleString{
    for (UIView * view in self.subviews) {
        if (view.tag == 1001) {
            view.hidden = NO;
        }else if(view.tag == 1003){
            UILabel * titleLab = (UILabel *)view;
            titleLab.hidden = NO;
            titleLab.text = titleString;
        }else{
            view.hidden = YES;
        }
    }
}
- (void)top_itemSelect:(UIButton*)btn{
    if (self.top_DocumentHeadClickHandler) {
        self.top_DocumentHeadClickHandler(btn.tag - 1000,btn.selected);
    }
}
- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}

- (void)top_shakeImage:(UIImageView *)imageView {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animation setDuration:0.1];
    animation.fromValue = @(-M_1_PI/2);
    animation.toValue = @(M_1_PI/2);
    animation.repeatCount = 15;
    animation.autoreverses = YES;
    imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    [imageView.layer addAnimation:animation forKey:@"rotation"];
}

@end
