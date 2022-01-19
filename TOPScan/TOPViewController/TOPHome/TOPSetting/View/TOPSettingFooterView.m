#define Space_W 25
#import "TOPSettingFooterView.h"

@implementation TOPSettingFooterView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        _backView = [UIView new];
        _backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _backView.layer.cornerRadius = 20;
        _backView.layer.masksToBounds = YES;
                
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:17];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        
        _faxBtn = [UIButton new];
        _faxBtn.tag = 1000+0;
        [_faxBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _faxLab = [UILabel new];
        _faxLab.font = [UIFont systemFontOfSize:14];
        _faxLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _faxLab.textAlignment = NSTextAlignmentCenter;
        
        _faxReceiveBtn = [UIButton new];
        _faxReceiveBtn.tag = 1000+1;
        [_faxReceiveBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _faxReceiveLab = [UILabel new];
        _faxReceiveLab.font = [UIFont systemFontOfSize:14];
        _faxReceiveLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _faxReceiveLab.textAlignment = NSTextAlignmentCenter;
        
        _versionLab = [UILabel new];
        _versionLab.font = [UIFont systemFontOfSize:11];
        _versionLab.textColor = RGBA(153, 153, 153, 1.0);
        _versionLab.textAlignment = NSTextAlignmentCenter;
       
        [self addSubview:_backView];
        [self addSubview:_titleLab];
        [self addSubview:_faxBtn];
        [self addSubview:_faxLab];
        [self addSubview:_faxReceiveBtn];
        [self addSubview:_faxReceiveLab];
        [self addSubview:_versionLab];
        [self top_setupUI];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    _backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    _faxLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    _faxReceiveLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
}
- (void)top_setupUI{
    
    [_backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.trailing.equalTo(self).offset(-20);
        make.top.equalTo(self).offset(15);
        make.bottom.equalTo(self).offset(-50);
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(35);
        make.top.equalTo(self).offset(35);
        make.size.mas_equalTo(CGSizeMake(250, 20));
    }];
    [_faxBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-(TOPScreenWidth/2+Space_W));
        make.top.equalTo(_titleLab.mas_bottom).offset(25);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    [_faxLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_faxBtn.mas_centerX);
        make.top.equalTo(_faxBtn.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    [_faxReceiveBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(TOPScreenWidth/2+Space_W);
        make.top.equalTo(_titleLab.mas_bottom).offset(25);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    [_faxReceiveLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_faxReceiveBtn.mas_centerX);
        make.top.equalTo(_faxReceiveBtn.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    [_versionLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(_backView.mas_bottom).offset(30);
        make.size.mas_equalTo(CGSizeMake(250, 15));
    }];
    
    _titleLab.text = NSLocalizedString(@"topscan_settingourapp", @"");
    [_faxBtn setImage:[UIImage imageNamed:@"top_settingFaxIcon"] forState:UIControlStateNormal];
    [_faxReceiveBtn setImage:[UIImage imageNamed:@"top_SettingFaxReceiveIcon"] forState:UIControlStateNormal];
   
    _faxLab.text = @"Simple Fax";
    _faxReceiveLab.text = @"Fax Receive";
    _versionLab.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_version", @""),[TOPAppTools getAppVersion]];
}

- (void)top_clickBtn:(UIButton *)sender{
    if (self.top_clickBtnBlock) {
        self.top_clickBtnBlock(sender.tag-1000);
    }
}

@end
