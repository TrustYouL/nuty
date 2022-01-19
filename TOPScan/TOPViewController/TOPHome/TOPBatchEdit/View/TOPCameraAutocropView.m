#import "TOPCameraAutocropView.h"
@interface TOPCameraAutocropView()
@property (nonatomic ,strong)UIImageView * cropIcon;
@property (nonatomic ,strong)UIImageView * cropShowView;
@property (nonatomic ,strong)UILabel * okLabel;
@property (nonatomic ,strong)UIView * lineGroudView;

@property (nonatomic ,strong)UILabel * autocropLabel;

@property (nonatomic ,strong)UILabel * titleLabFirst;
@property (nonatomic ,strong)UILabel * titleLabSecond;
@property (nonatomic ,assign)CGFloat topH;

@end
@implementation TOPCameraAutocropView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGBA(51, 51, 51, 0.8);

        _cropIcon = [UIImageView new];
        _cropIcon.image = [UIImage imageNamed:@"top_cropCameraIcon"];
        _cropIcon.backgroundColor = [UIColor clearColor];
        
        _lineGroudView = [[UIView alloc] init];
        _lineGroudView.backgroundColor = [UIColor clearColor];
        
        _cropShowView = [UIImageView new];
        _cropShowView.backgroundColor = [UIColor clearColor];
        
        _cropShowView.image = [UIImage imageNamed:@"top_cropCameraShow"];

        _autocropLabel = [UILabel new];
        _autocropLabel.backgroundColor = [UIColor clearColor];
        _autocropLabel.userInteractionEnabled = YES;
        _autocropLabel.font = PingFang_R_FONT_( 10);
        _autocropLabel.textColor = [UIColor whiteColor];
        _autocropLabel.textAlignment = NSTextAlignmentNatural;
        _autocropLabel.text = NSLocalizedString(@"topscan_cropautomaticcameraaip" ,@"");
        
        _okLabel = [UILabel new];
        _okLabel.backgroundColor = [UIColor clearColor];
        _okLabel.userInteractionEnabled = YES;
        _okLabel.font = PingFang_R_FONT_( 15);
        _okLabel.textColor = [UIColor whiteColor];
        _okLabel.textAlignment = NSTextAlignmentCenter;
        _okLabel.text = NSLocalizedString(@"topscan_ok" ,@"");
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_tapAction:)];
        [_okLabel addGestureRecognizer:tap];
        
        _titleLabFirst = [UILabel new];
        _titleLabFirst.backgroundColor = [UIColor clearColor];
        _titleLabFirst.textColor = [UIColor whiteColor];
        _titleLabFirst.textAlignment = NSTextAlignmentCenter;
        _titleLabFirst.font = [UIFont systemFontOfSize:11];
        
        _titleLabSecond = [UILabel new];
        _titleLabSecond.backgroundColor = [UIColor clearColor];
        _titleLabSecond.textColor = [UIColor whiteColor];
        _titleLabSecond.textAlignment = NSTextAlignmentCenter;
        _titleLabSecond.font = [UIFont systemFontOfSize:11];
        _topH = TOPStatusBarHeight;
      
        [self addSubview:_lineGroudView];
        [self addSubview:_cropIcon];
        [self addSubview:_cropShowView];
        [self addSubview:_autocropLabel];
        [self addSubview:_titleLabFirst];
        [self addSubview:_titleLabSecond];
        [self addSubview:_okLabel];
        [self top_setupFream];
    }
    return self;
}

- (void)top_setupFream{
    [_cropIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(_topH);
        make.right.equalTo(self).offset(-88);
        make.size.mas_equalTo(CGSizeMake(50, 40));
    }];
    [_lineGroudView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_cropIcon.mas_bottom).offset(10);
        make.right.equalTo(self).offset(-35);
        make.size.mas_equalTo(CGSizeMake(150, 115));
    }];
    [_cropShowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_cropIcon.mas_bottom).offset(20);
        make.right.equalTo(self).offset(-40);
        make.size.mas_equalTo(CGSizeMake(140, 30));
    }];
    [_autocropLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_cropIcon.mas_bottom).offset(20);
        make.right.equalTo(self).offset(-105);
        make.size.mas_equalTo(CGSizeMake(70, 30));
    }];
    [_okLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lineGroudView.mas_bottom).offset(25);
        make.right.equalTo(self).offset(-35);
        make.size.mas_equalTo(CGSizeMake(95, 35));
    }];
    [_titleLabSecond mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-35);
        make.bottom.equalTo(_okLabel.mas_top).offset(-40);
        make.size.mas_equalTo(CGSizeMake(150, 15));
    }];
    [_titleLabFirst mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-35);
        make.bottom.equalTo(_titleLabSecond.mas_top).offset(-5);
        make.size.mas_equalTo(CGSizeMake(150, 15));
    }];
    [self layoutIfNeeded];
    [self top_drawDashLine:_lineGroudView lineLength:2 lineSpacing:1 lineColor:[UIColor whiteColor] cornerRadius:20];
    [self top_drawDashLine:_okLabel lineLength:2 lineSpacing:1 lineColor:[UIColor whiteColor] cornerRadius:7];

    _titleLabFirst.text = NSLocalizedString(@"topscan_cameracropremindfirst", @"");
    _titleLabSecond.text = NSLocalizedString(@"topscan_cameracropremindsecond", @"");
}
- (void)top_drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor cornerRadius:(CGFloat)radius {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setFrame:lineView.bounds];
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:lineView.bounds cornerRadius:radius].CGPath;
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
