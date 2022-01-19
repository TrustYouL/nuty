#define COR1 16
#define COR2 14
#import "TOPDocNameShowView.h"
@interface TOPDocNameShowView()
@property (nonatomic,strong)UIView * shadowView;
@property (nonatomic,strong)UIView * grayView;
@property (nonatomic,strong)UIImageView * picImg;
@property (nonatomic,strong)UILabel * titleLab;
@property (nonatomic,strong)UILabel * timeLab;
@property (nonatomic,strong)UIImageView * iconImg;
@property (nonatomic,strong)UILabel * tagsLab;
@property (nonatomic,strong)UILabel * cor1;
@property (nonatomic,strong)UILabel * cor2;
@end
@implementation TOPDocNameShowView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    _shadowView = [UIView new];
    _shadowView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _shadowView.layer.cornerRadius = 5;
    _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    _shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    _shadowView.layer.shadowOpacity = 0.3;
    if ([TOPDocumentHelper top_isdark]) {
        _shadowView.clipsToBounds = YES;
    }else{
        _shadowView.clipsToBounds = NO;
    }
    
    _grayView = [UIView new];
    _grayView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:RGBA(230, 230, 230, 1.0)];
    
    _picImg = [UIImageView new];
    _picImg.image = [UIImage imageNamed:@"top_docIcon"];
    
    _titleLab = [UILabel new];
    _titleLab.lineBreakMode = NSLineBreakByTruncatingTail;//防止遇见空格换行
    _titleLab.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    _titleLab.textAlignment = NSTextAlignmentNatural;
    _titleLab.font = [self fontsWithSize:14];
    _titleLab.backgroundColor = [UIColor clearColor];
    
    _timeLab = [[UILabel alloc] init];
    _timeLab.textColor = RGBA(153, 153, 153, 1.0);
    _timeLab.font = [self fontsWithSize:12];
    _timeLab.textAlignment = NSTextAlignmentNatural;
    
    _cor1 = [UILabel new];
    _cor1.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    _cor1.textAlignment = NSTextAlignmentCenter;
    _cor1.font = [self fontsWithSize:15];
    _cor1.backgroundColor = [UIColor clearColor];
    _cor1.layer.cornerRadius = COR1/2;
    _cor1.layer.borderColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)].CGColor;
    _cor1.layer.borderWidth = 0.5;
    
    _cor2 = [[UILabel alloc] init];
    _cor2.textColor = RGBA(153, 153, 153, 1.0);
    _cor2.font = [self fontsWithSize:12];
    _cor2.textAlignment = NSTextAlignmentCenter;
    _cor2.backgroundColor = [UIColor clearColor];
    _cor2.layer.cornerRadius = COR2/2;
    _cor2.layer.borderColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(153, 153, 153, 1.0)].CGColor;
    _cor2.layer.borderWidth = 0.5;
    
    _iconImg = [UIImageView new];
    _iconImg.image = [UIImage imageNamed:@"top_biaoqian"];

    _tagsLab = [UILabel new];
    _tagsLab.lineBreakMode = NSLineBreakByTruncatingTail;
    _tagsLab.textColor = RGBA(153, 153, 153, 1.0);
    _tagsLab.textAlignment = NSTextAlignmentNatural;
    _tagsLab.font = [self fontsWithSize:12];
    _tagsLab.backgroundColor = [UIColor clearColor];

    [self addSubview:_shadowView];
    [_shadowView addSubview:_grayView];
    [_shadowView addSubview:_picImg];
    [_shadowView addSubview:_titleLab];
    [_shadowView addSubview:_timeLab];
    [_shadowView addSubview:_cor1];
    [_shadowView addSubview:_cor2];
    [_shadowView addSubview:_iconImg];
    [_shadowView addSubview:_tagsLab];
    [self top_setupFream];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    if ([TOPDocumentHelper top_isdark]) {
        _shadowView.clipsToBounds = YES;
    }else{
        _shadowView.clipsToBounds = NO;
    }
    _cor1.layer.cornerRadius = COR1/2;
    _cor1.layer.borderColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)].CGColor;
    _cor1.layer.borderWidth = 0.5;
    
    _cor2.layer.cornerRadius = COR2/2;
    _cor2.layer.borderColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(153, 153, 153, 1.0)].CGColor;
    _cor2.layer.borderWidth = 0.5;
}
- (void)top_setupFream{
    [_shadowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(25);
        make.size.mas_equalTo(CGSizeMake(170, 165));
    }];
    [_grayView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(_shadowView);
        make.height.mas_equalTo(100);
    }];
    [_picImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_shadowView);
        make.top.equalTo(_shadowView).offset(10);
        make.size.mas_equalTo(CGSizeMake(70, 80));
    }];
    CGFloat leftW = 10;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_shadowView).offset(leftW);
        make.top.equalTo(_grayView.mas_bottom).offset(5);
        make.height.mas_equalTo(15);
    }];
    [_timeLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_shadowView).offset(leftW);
        make.top.equalTo(_titleLab.mas_bottom).offset(5);
        make.height.mas_equalTo(15);
    }];
    [_cor1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_titleLab.mas_trailing).offset(5);
        make.centerY.equalTo(_titleLab.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(COR1, COR1));
    }];
    [_cor2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_timeLab.mas_trailing).offset(5);
        make.centerY.equalTo(_timeLab.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(COR2, COR2));
    }];
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_shadowView).offset(leftW);
        make.top.equalTo(_timeLab.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(23/2, 23/2));
    }];
    [_tagsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImg.mas_trailing).offset(5);
        make.trailing.equalTo(_shadowView).offset(-10);
        make.top.equalTo(_timeLab.mas_bottom).offset(2);
        make.height.mas_equalTo(15);
    }];
    _titleLab.text = NSLocalizedString(@"topscan_settingtemplate", @"");
    _timeLab.text = [TOPDocumentHelper top_getCurrentTime];
    _tagsLab.text = NSLocalizedString(@"topscan_settingfamily", @"");
    _cor1.text = @"1";
    _cor2.text = @"2";
}

- (void)setDocName:(NSString *)docName{
    _docName = docName;
    _titleLab.text = _docName;
    [self top_reloadUI];
}

- (void)top_setDocTime:(NSString *)doctime{
    _doctime = doctime;
    _timeLab.text = _doctime;
    [self top_reloadUI];
}

- (void)top_reloadUI{
    CGFloat titleH = [TOPDocumentHelper top_getSizeWithStr:_docName Height:15 Font:14].width+5+5+COR1;
    if (titleH>=165) {
        [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_shadowView).offset(5);
            make.trailing.equalTo(_shadowView).offset(-(5+COR1+5));
            make.top.equalTo(_grayView.mas_bottom).offset(5);
            make.height.mas_equalTo(15);
        }];
        [_cor1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_shadowView).offset(-5);
            make.centerY.equalTo(_titleLab.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(COR1, COR1));
        }];
    }else{
        [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_shadowView).offset(5);
            make.top.equalTo(_grayView.mas_bottom).offset(5);
            make.height.mas_equalTo(15);
        }];
        [_cor1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_titleLab.mas_trailing).offset(5);
            make.centerY.equalTo(_titleLab.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(COR1, COR1));
        }];
    }
    [_timeLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_shadowView).offset(5);
        make.top.equalTo(_titleLab.mas_bottom).offset(5);
        make.height.mas_equalTo(15);
    }];
    [_cor2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_timeLab.mas_trailing).offset(5);
        make.centerY.equalTo(_timeLab.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(COR2, COR2));
    }];
}

@end
