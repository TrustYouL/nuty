#import "TOPChildTipView.h"
@interface TOPChildTipView()
@property (nonatomic,strong)UIImageView * leftImg;
@property (nonatomic,strong)UIImageView * arrowImg;
@property (nonatomic,strong)UIImageView * rightImg;
@property (nonatomic,strong)UIButton * getBtn;
@end
@implementation TOPChildTipView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGBA(51, 51, 51, 0.7);
        [self top_setUI];
    }
    return self;
}

- (void)top_setUI{
    _leftImg = [UIImageView new];
    _leftImg.image = [UIImage imageNamed:@"top_longpress"];
    _leftImg.backgroundColor = [UIColor clearColor];
    
    _arrowImg = [UIImageView new];
    _arrowImg.backgroundColor = [UIColor clearColor];
    if (isRTL()) {
        _arrowImg.image = [UIImage imageNamed:@"top_pressreversearrow"];
    }else{
        _arrowImg.image = [UIImage imageNamed:@"top_pressarrow"];
    }
    _rightImg = [UIImageView new];
    _rightImg.backgroundColor = [UIColor clearColor];
    
    _getBtn = [UIButton new];
    _getBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _getBtn.backgroundColor = TOPAPPGreenColor;
    [_getBtn setTitle:NSLocalizedString(@"topscan_longpresstip", @"") forState:UIControlStateNormal];
    [_getBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_getBtn addTarget:self action:@selector(top_clickBtn) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:_leftImg];
    [self addSubview:_arrowImg];
    [self addSubview:_rightImg];
    [self addSubview:_getBtn];
    [self top_setViewFream];
}

- (void)top_setViewFream{
    [_rightImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-10);
        make.top.equalTo(self).offset(TOPNavBarAndStatusBarHeight+10);
        make.size.mas_equalTo(CGSizeMake((TOPScreenWidth-30)/2, (TOPScreenWidth-30)/2+85));
    }];
    [_arrowImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(TOPNavBarAndStatusBarHeight+((TOPScreenWidth-30)/2+85)/2);
        make.size.mas_equalTo(CGSizeMake(90, 10));
    }];
    [_leftImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(10+(TOPScreenWidth-30)/4);
        make.top.equalTo(self).offset(TOPNavBarAndStatusBarHeight+((TOPScreenWidth-30)/2+85)/2-10);
        make.size.mas_equalTo(CGSizeMake(55, 80));
    }];
    [_getBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-30);
        make.bottom.equalTo(self).offset(-90);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    _getBtn.layer.cornerRadius = 40/2;
    [self layoutIfNeeded];
    [self backGroundViewLine:1 lineColor:[UIColor whiteColor]];
}

- (void)top_clickBtn{
    [self removeFromSuperview];
}

-(void)backGroundViewLine:(CGFloat)lineWidth lineColor:(UIColor *)lineColor {
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = lineColor.CGColor;
    border.cornerRadius = 25/2;
    border.fillColor = nil;
    border.path = [UIBezierPath bezierPathWithRect:_rightImg.bounds].CGPath;
    border.frame = _rightImg.bounds;
    border.lineWidth = lineWidth;
    border.lineDashPattern = @[@(1), @(2)];
    [_rightImg.layer addSublayer:border];
}
@end
