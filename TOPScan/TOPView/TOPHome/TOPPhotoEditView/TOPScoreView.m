#define star_W 16
#define star_Top 20

#import "TOPScoreView.h"
@interface TOPScoreView()
@property (nonatomic ,strong)UIImageView * oneStar;
@property (nonatomic ,strong)UIImageView * twoStar;
@property (nonatomic ,strong)UIImageView * threeStar;
@property (nonatomic ,strong)UIImageView * fourStar;
@property (nonatomic ,strong)UIImageView * fiveStar;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIButton * cancelBtn;
@property (nonatomic ,strong)UIButton * fiveStarBtn;

@end
@implementation TOPScoreView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4;
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    _titleLab = [UILabel new];
    _titleLab.font = [UIFont systemFontOfSize:16];
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.numberOfLines = 0;
    
    _oneStar = [UIImageView new];
    _twoStar = [UIImageView new];
    _threeStar = [UIImageView new];
    _fourStar = [UIImageView new];
    _fiveStar = [UIImageView new];
    
    _cancelBtn = [UIButton new];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_cancelBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(top_clickCancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    _fiveStarBtn = [UIButton new];
    _fiveStarBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_fiveStarBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [_fiveStarBtn addTarget:self action:@selector(top_clickFiveAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_titleLab];
    [self addSubview:_oneStar];
    [self addSubview:_twoStar];
    [self addSubview:_threeStar];
    [self addSubview:_fourStar];
    [self addSubview:_fiveStar];
    [self addSubview:_cancelBtn];
    [self addSubview:_fiveStarBtn];
    [self top_setupFream];
}

- (void)top_setupFream{
    NSString * titleString = NSLocalizedString(@"topscan_scoretitle", @"");
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(30);
        make.trailing.equalTo(self).offset(-30);
        make.top.equalTo(self).offset(20);
    }];
    [_threeStar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLab.mas_bottom).offset(star_Top);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(23, 22));
    }];
    [_fourStar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_threeStar.mas_trailing).offset(star_W);
        make.centerY.equalTo(_threeStar.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(23, 22));
    }];
    [_fiveStar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_fourStar.mas_trailing).offset(star_W);
        make.centerY.equalTo(_threeStar.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(23, 22));
    }];
    [_twoStar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_threeStar.mas_leading).offset(-star_W);
        make.centerY.equalTo(_threeStar.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(23, 22));
    }];
    [_oneStar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_twoStar.mas_leading).offset(-star_W);
        make.centerY.equalTo(_threeStar.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(23, 22));
    }];
    [_cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(25);
        make.bottom.equalTo(self).offset(-20);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    [_fiveStarBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-25);
        make.bottom.equalTo(self).offset(-20);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    
    [_cancelBtn setTitle:NSLocalizedString(@"topscan_scorecancel", @"") forState:UIControlStateNormal];
    [_fiveStarBtn setTitle:NSLocalizedString(@"topscan_scorefivestar", @"") forState:UIControlStateNormal];
    _oneStar.image = [UIImage imageNamed:@"top_scorestar"];
    _twoStar.image = [UIImage imageNamed:@"top_scorestar"];
    _threeStar.image = [UIImage imageNamed:@"top_scorestar"];
    _fourStar.image = [UIImage imageNamed:@"top_scorestar"];
    _fiveStar.image = [UIImage imageNamed:@"top_scorestar"];
    _titleLab.text = titleString;

}

- (void)top_clickCancelAction{
    if (self.top_clickCancelBtn) {
        self.top_clickCancelBtn();
    }
}

- (void)top_clickFiveAction{
    if (self.top_clickFiveStarBtn) {
        self.top_clickFiveStarBtn();
    }
}

@end
