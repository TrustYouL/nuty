#import "TOPCameraFilterRemindView.h"
@interface TOPCameraFilterRemindView()
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UIImageView * listImg;
@property (nonatomic ,strong)UILabel * btnLabel;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,assign)CGFloat topH;
@end
@implementation TOPCameraFilterRemindView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = RGBA(51, 51, 51, 0.8);
        
        _iconImg = [UIImageView new];
        _iconImg.backgroundColor = [UIColor clearColor];
        _iconImg.image = [UIImage imageNamed:@"top_filterIcon"];
        
        _listImg = [UIImageView new];
        _listImg.backgroundColor = [UIColor clearColor];
        _listImg.image = [UIImage imageNamed:@"top_filterListIcon"];
        
        _btnLabel = [UILabel new];
        _btnLabel.backgroundColor = [UIColor clearColor];
        _btnLabel.userInteractionEnabled = YES;
        _btnLabel.font = PingFang_R_FONT_( 15);
        _btnLabel.textColor = [UIColor whiteColor];
        _btnLabel.textAlignment = NSTextAlignmentCenter;
        _btnLabel.text = NSLocalizedString(@"topscan_nextstep" ,@"");
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_tapAction:)];
        [_btnLabel addGestureRecognizer:tap];
        
        _titleLab = [UILabel new];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.font = [UIFont systemFontOfSize:14];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _topH = TOPStatusBarHeight;
       
        [self addSubview:_iconImg];
        [self addSubview:_listImg];
        [self addSubview:_btnLabel];
        [self addSubview:_titleLab];

        [self top_setupFream];
    }
    return self;
}

- (void)top_setupFream{
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-130);
        make.top.equalTo(self).offset(_topH);
        make.size.mas_equalTo(CGSizeMake(50, 40));
    }];
    [_listImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-5);
        make.left.equalTo(self).offset(5);
        make.top.equalTo(_iconImg.mas_bottom).offset(10);
        make.height.mas_equalTo(((TOPScreenWidth-10)/1080)*297);
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(_listImg.mas_bottom).offset(10);
        make.height.mas_equalTo(15);
    }];
    [_btnLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-25);
        make.top.equalTo(_titleLab.mas_bottom).offset(25);
        make.size.mas_equalTo(CGSizeMake(94, 34));
    }];
    
    [self layoutIfNeeded];
    [self top_drawDashLine:_btnLabel lineLength:2 lineSpacing:1 lineColor:[UIColor whiteColor]];

    _titleLab.text = NSLocalizedString(@"topscan_camerafilterremind", @"");
}

- (void)top_drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setFrame:lineView.bounds];
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:lineView.bounds cornerRadius:7].CGPath;
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    [shapeLayer setStrokeColor:lineColor.CGColor];
    [shapeLayer setLineWidth:1];
    [shapeLayer setLineDashPattern:@[@(lineLength), @(lineSpacing)]];
    [lineView.layer addSublayer:shapeLayer];
  }

- (void)top_tapAction:(UITapGestureRecognizer *)tap{
    if (self.top_btnAction) {
        self.top_btnAction();
    }
}

@end
