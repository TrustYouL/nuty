#import "TOPNewScoreView.h"
@interface TOPNewScoreView()
@property (nonatomic ,strong)UIView * maskView;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UILabel * tipLab;
@property (nonatomic ,strong)UIView * backView;
@property (nonatomic ,strong)UIButton * submitBtn;
@property (nonatomic ,strong)UIButton * cancelBtn;
@property (nonatomic ,assign)NSInteger scoreNum;
@property (nonatomic ,strong)NSMutableArray * btnArray;
@end
@implementation TOPNewScoreView
- (instancetype)init{
    if (self = [super init]) {
        self.scoreNum = 0;
        [self top_addchildView];
        [self top_setupFream];
    }
    return self;
}
- (void)clickOthBtn:(UIButton *)sender{
    if (sender.tag == 1001+10) {
        if (self.top_submitScore) {
            self.top_submitScore(self.scoreNum);
        }
    }
    [self removeFromSuperview];
}
- (void)top_clickBtn:(UIButton *)sender{
    _submitBtn.enabled = YES;
    [_submitBtn setBackgroundColor:TOPAPPGreenColor];
    
    self.scoreNum = sender.tag-1001;
    [self top_changeBtnState];
}
- (void)top_changeBtnState{
    for (UIButton * btn in self.btnArray) {
        if (btn.tag-1001<=self.scoreNum) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }
}
- (void)top_addchildView{
    _maskView = [UIView new];
    _maskView.backgroundColor = RGBA(51, 51, 51, 0.5);
    _backView = [UIView new];
    _backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _backView.layer.cornerRadius = 8;
    _backView.layer.masksToBounds = YES;
    
    _titleLab = [UILabel new];
    _titleLab.text = NSLocalizedString(@"topscan_newsuggestiontitle", @"");
    _titleLab.font = [UIFont boldSystemFontOfSize:18];
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(20, 20, 20, 1.0)];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    
    _tipLab = [UILabel new];
    _tipLab.text = NSLocalizedString(@"topscan_newsuggestioncontent", @"");
    _tipLab.font = [UIFont systemFontOfSize:16];
    _tipLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    _tipLab.textAlignment = NSTextAlignmentCenter;
    _tipLab.numberOfLines = 0;
    
    _submitBtn = [UIButton new];
    _submitBtn.tag = 1001+10;
    _submitBtn.enabled = NO;
    _submitBtn.layer.cornerRadius = 50/2;
    _submitBtn.layer.masksToBounds = YES;
    _submitBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_submitBtn setBackgroundColor:RGBA(36, 196, 164, 0.5)];
    [_submitBtn setTitle:NSLocalizedString(@"topscan_suggestionsubmit", @"") forState:UIControlStateNormal];
    [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(clickOthBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _cancelBtn = [UIButton new];
    _cancelBtn.tag = 1001+11;
    [_cancelBtn setImage:[UIImage imageNamed:@"top_Share_close"] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(clickOthBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_maskView];
    [self addSubview:_backView];
    [self addSubview:_cancelBtn];
    [_backView addSubview:_titleLab];
    [_backView addSubview:_tipLab];
    [_backView addSubview:_submitBtn];

    for (int i = 0; i<5; i++) {
        UIButton * btn = [UIButton new];
        btn.tag = 1001+1+i;
        [btn setImage:[UIImage imageNamed:@"top_newscoredis"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"top_newscoresel"] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:@"top_newscoresel"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:btn];
        [self.btnArray addObject:btn];
    }
}
- (void)top_setupFream{
    UIButton * btn1 = self.btnArray[0];
    UIButton * btn2 = self.btnArray[1];
    UIButton * btn3 = self.btnArray[2];
    UIButton * btn4 = self.btnArray[3];
    UIButton * btn5 = self.btnArray[4];

    [_maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [_backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-20);
        make.size.mas_equalTo(CGSizeMake(340, 265));
    }];
    [_cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(_backView.mas_bottom).offset(30);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    [btn3 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_backView);
        make.size.mas_equalTo(CGSizeMake(37, 37));
    }];
    [btn2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(btn3.mas_centerY);
        make.trailing.equalTo(btn3.mas_leading).offset(-15);
        make.size.mas_equalTo(CGSizeMake(37, 37));
    }];
    [btn1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(btn2.mas_centerY);
        make.trailing.equalTo(btn2.mas_leading).offset(-15);
        make.size.mas_equalTo(CGSizeMake(37, 37));
    }];
    [btn4 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(btn3.mas_centerY);
        make.leading.equalTo(btn3.mas_trailing).offset(15);
        make.size.mas_equalTo(CGSizeMake(37, 37));
    }];
    [btn5 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(btn4.mas_centerY);
        make.leading.equalTo(btn4.mas_trailing).offset(15);
        make.size.mas_equalTo(CGSizeMake(37, 37));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_backView).offset(25);
        make.leading.equalTo(_backView).offset(20);
        make.trailing.equalTo(_backView).offset(-20);
    }];
    [_tipLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLab.mas_bottom).offset(20);
        make.leading.equalTo(_backView).offset(20);
        make.trailing.equalTo(_backView).offset(-20);
    }];
    [_submitBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btn3.mas_bottom).offset(30);
        make.leading.equalTo(_backView).offset(20);
        make.trailing.equalTo(_backView).offset(-20);
        make.height.mas_equalTo(50);
    }];
}
- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray new];
    }
    return _btnArray;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
