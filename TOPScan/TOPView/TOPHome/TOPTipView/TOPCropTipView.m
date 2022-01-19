#import "TOPCropTipView.h"

@interface TOPCropTipView ()
/** 背景蒙层 */
@property (nonatomic, strong) UIView *maskView;
/** 背景视图  圆角*/
@property (nonatomic, strong) UIView *bgView;
@property (strong, nonatomic) UIImageView *tipIcon;
@property (strong, nonatomic) UILabel *tipMsgLabel;
@property (strong, nonatomic) UILabel *showAskLabel;
@property (strong, nonatomic) UIButton *askCheckBtn;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *okBtn;
@property (copy, nonatomic) NSString *tipMsg;
@property (strong, nonatomic) UIButton *easyBtn;//覆盖在文字和checkBtn上，方便点击

@end

@implementation TOPCropTipView

- (instancetype)initWithTipMessage:(NSString *)msg {
    self = [super init];
    if (self) {
        _tipMsg = msg;
        [self top_configContentView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self top_showView];
        });
    }
    return self;
}

- (void)top_showView {
    [UIView animateWithDuration:0.3 animations:^{
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
        }];
        self.maskView.backgroundColor = RGBA(0, 0, 0, 0.5);
        [self.bgView.superview layoutIfNeeded];
    }completion:^(BOOL finished) {
        
    }];
}

- (void)top_dismissView {
    [UIView animateWithDuration:0.3 animations:^{
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(TOPScreenHeight);
        }];
        self.maskView.alpha = 0;
        [self.bgView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)top_configContentView {
    [self addSubview:self.maskView];
    [self addSubview:self.bgView];
    [self top_setSubViewsLayout];
}

- (void)top_setSubViewsLayout {
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(TOPScreenHeight);
        make.height.mas_equalTo(264);
        make.width.mas_equalTo(310);
    }];
    
    [self.tipIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.top.equalTo(self.bgView).offset(25);
        make.height.width.mas_equalTo(59);
    }];
    
    [self.tipMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipIcon.mas_bottom).offset(20);
        make.leading.equalTo(self.bgView).offset(32);
        make.trailing.equalTo(self.bgView).offset(-32);
    }];
    
    [self.askCheckBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipMsgLabel.mas_bottom).offset(22);
        make.height.width.mas_equalTo(20);
        make.trailing.equalTo(self.showAskLabel.mas_leading).offset(-8);
    }];
    
    [self.showAskLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.centerY.equalTo(self.askCheckBtn);
    }];
    
    [self.easyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.askCheckBtn);
        make.height.mas_equalTo(20);
        make.leading.equalTo(self.askCheckBtn);
        make.trailing.equalTo(self.showAskLabel);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgView).offset(-12);
        make.leading.equalTo(self.bgView).offset(45);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(26);
    }];
    
    [self.okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgView).offset(-12);
        make.trailing.equalTo(self.bgView).offset(-45);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(26);
    }];
}

- (void)top_clickAskBtn {
    if (self.askCheckBtn.isSelected) {
        self.askCheckBtn.selected = NO;
        [self.askCheckBtn setImage:[UIImage imageNamed:@"top_select_n_1"] forState:UIControlStateNormal];
    } else {
        self.askCheckBtn.selected = YES;
        [self.askCheckBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllSelect"] forState:UIControlStateNormal];
    }
}

- (void)top_clickEasyBtn {
    if (self.easyBtn.isSelected) {
        self.easyBtn.selected = NO;
        [self.askCheckBtn setImage:[UIImage imageNamed:@"top_select_n_1"] forState:UIControlStateNormal];
    } else {
        self.easyBtn.selected = YES;
        [self.askCheckBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllSelect"] forState:UIControlStateNormal];
    }
}

- (void)top_clickCancelBtn {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self top_dismissView];
}

- (void)top_clickOkBtn {
    if (self.easyBtn.selected) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cropTipAsk"];
        [TOPScanerShare top_writeDeleteFileAlert:NO];
    }
    if (self.okBlock) {
        self.okBlock();
    }
    [self top_dismissView];
}

#pragma mark -- lazy
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor clearColor];
    }
    return _maskView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
        _bgView.layer.cornerRadius = 10;
    }
    return _bgView;
}

- (UIImageView *)tipIcon {
    if (!_tipIcon) {
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_tipBulb"]];
        [self.bgView addSubview:icon];
        _tipIcon = icon;
    }
    return _tipIcon;
}

- (UILabel *)tipMsgLabel {
    if (!_tipMsgLabel) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_R_FONT_(13);
        noClassLab.numberOfLines = 0;
        noClassLab.text = self.tipMsg;
        [self.bgView addSubview:noClassLab];
        _tipMsgLabel = noClassLab;
    }
    return _tipMsgLabel;
}

- (UIButton *)askCheckBtn {
    if (!_askCheckBtn) {
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [ovalBtn setImage:[UIImage imageNamed:@"top_select_n_1"] forState:UIControlStateNormal];
        [self.bgView addSubview:ovalBtn];
        [ovalBtn addTarget:self action:@selector(top_clickAskBtn) forControlEvents:UIControlEventTouchUpInside];
        _askCheckBtn = ovalBtn;
    }
    return _askCheckBtn;
}

- (UILabel *)showAskLabel {
    if (!_showAskLabel) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = kTabbarNormal;
        noClassLab.textAlignment = NSTextAlignmentNatural;
        noClassLab.font = PingFang_R_FONT_(12);
        noClassLab.text = NSLocalizedString(@"topscan_tipask", @"");
        [self.bgView addSubview:noClassLab];
        _showAskLabel = noClassLab;
    }
    return _showAskLabel;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [ovalBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
        ovalBtn.titleLabel.font = PingFang_R_FONT_(15);
        ovalBtn.titleLabel.textAlignment = NSTextAlignmentNatural;
        [ovalBtn setTitleColor:kTabbarNormal forState:UIControlStateNormal];
        [self.bgView addSubview:ovalBtn];
        [ovalBtn addTarget:self action:@selector(top_clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn = ovalBtn;
    }
    return _cancelBtn;
}

- (UIButton *)okBtn {
    if (!_okBtn) {
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [ovalBtn setTitle:NSLocalizedString(@"topscan_ok", @"") forState:UIControlStateNormal];
        ovalBtn.titleLabel.font = PingFang_R_FONT_(15);
        ovalBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [ovalBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
        [self.bgView addSubview:ovalBtn];
        [ovalBtn addTarget:self action:@selector(top_clickOkBtn) forControlEvents:UIControlEventTouchUpInside];
        _okBtn = ovalBtn;
    }
    return _okBtn;
}

- (UIButton *)easyBtn {
    if (!_easyBtn) {
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgView addSubview:ovalBtn];
        [ovalBtn addTarget:self action:@selector(top_clickEasyBtn) forControlEvents:UIControlEventTouchUpInside];
        _easyBtn = ovalBtn;
    }
    return _easyBtn;
}

@end
