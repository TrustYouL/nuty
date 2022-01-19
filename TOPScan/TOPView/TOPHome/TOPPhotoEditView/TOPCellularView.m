#import "TOPCellularView.h"

@implementation TOPCellularView
- (instancetype)init{
    if (self = [super init]) {
        [self top_creatUI];
    }
    return self;
}
- (void)top_creatUI{
    self.frame = [UIScreen mainScreen].bounds;
    [self addSubview:self.maskView];
    [self addSubview:self.contentView];
    
    [self.maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(270, 270));
    }];
    UILabel * titleLab = [UILabel new];
    titleLab.numberOfLines = 2;
    titleLab.font = [UIFont boldSystemFontOfSize:15];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    titleLab.text = NSLocalizedString(@"topscan_wlantitle", @"");
    
    UILabel * skipLab = [UILabel new];
    skipLab.numberOfLines = 2;
    skipLab.font = [UIFont systemFontOfSize:11];
    skipLab.textAlignment = NSTextAlignmentCenter;
    skipLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    skipLab.text = NSLocalizedString(@"topscan_wlancontent", @"");

    UIButton * settingBtn = [UIButton new];
    settingBtn.tag = 1001;
    [settingBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [settingBtn setTitle:NSLocalizedString(@"topscan_questionsetting", @"") forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * okBtn = [UIButton new];
    okBtn.tag = 1002;
    [okBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [okBtn setTitle:NSLocalizedString(@"topscan_ok", @"") forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView * img = [UIImageView new];
    img.image = [UIImage imageNamed:@"top_turnoffwlan"];
    [self.contentView addSubview:titleLab];
    [self.contentView addSubview:skipLab];
    [self.contentView addSubview:settingBtn];
    [self.contentView addSubview:okBtn];
    [self.contentView addSubview:img];

    [titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView).offset(-10);
        make.leading.equalTo(self.contentView).offset(25);
        make.trailing.equalTo(self.contentView).offset(-25);
        make.height.mas_equalTo(45);
    }];
    [img mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(titleLab.mas_top).offset(-10);
        make.size.mas_equalTo(CGSizeMake(183, 72));
    }];
    [skipLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLab.mas_bottom).offset(0);
        make.leading.equalTo(self.contentView).offset(45);
        make.trailing.equalTo(self.contentView).offset(-45);
        make.height.mas_equalTo(35);
    }];
    [settingBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(35);
        make.bottom.equalTo(self.contentView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(80, 50));
    }];
    [okBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-35);
        make.bottom.equalTo(self.contentView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(80, 50));
    }];
}
- (void)top_clickBtn:(UIButton *)sender{
    [self top_dismissView];
    if (sender.tag == 1001) {
        if (self.top_settingBlock) {
            self.top_settingBlock();
        }
    }
}
- (void)top_dismissView
{
    [self removeFromSuperview];
}
- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 15;
    }
    return _contentView;
}
- (UIView*)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc]init];
        _maskView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_dismissView)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

@end
