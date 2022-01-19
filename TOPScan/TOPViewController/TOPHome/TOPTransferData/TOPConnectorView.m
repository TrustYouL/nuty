#import "TOPConnectorView.h"
#import <SDWebImage/UIImage+GIF.h>

@interface TOPConnectorView ()
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic ,strong) UIImageView *leftIcon;
@property (nonatomic ,strong) UIImageView *rightIcon;
@property (nonatomic ,strong) UILabel *leftLab;
@property (nonatomic ,strong) UILabel *rightLab;
@property (nonatomic ,strong) UILabel *tipLab;
@property (nonatomic ,strong) UIImageView *connectImg;

@property (nonatomic, copy) NSString *btnTitle;
@property (nonatomic, assign) CGFloat bgView_Height;
@property (nonatomic, assign) BOOL sender;

@property (nonatomic, copy) void(^cancelBlock)(void);
@property (nonatomic, copy) void(^completeBlock)(void);

@end

@implementation TOPConnectorView

- (instancetype)initWithTitle:(NSString *)title role:(BOOL)sender cancelBlock:(void (^)(void))cancelBlock completeBlock:(void (^)(void))completeBlock {
    if (self = [super init]) {
        self.btnTitle = title;
        self.sender = sender;
        self.bgView_Height = 340.0 / 375.0 * TOPScreenWidth;
        self.cancelBlock = cancelBlock;
        self.completeBlock = completeBlock;
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
            make.top.equalTo(self.mas_bottom).offset(-self.bgView_Height - TOPBottomSafeHeight);
        }];
        self.maskView.backgroundColor = RGBA(0, 0, 0, 0.5);
        [self.bgView.superview layoutIfNeeded];
    }completion:^(BOOL finished) {
        
    }];
}

- (void)top_dismissView {
    [UIView animateWithDuration:0.3 animations:^{
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
        }];
        self.maskView.alpha = 0;
        [self.bgView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self top_dismissView];
}

- (void)top_clickCloseBtn {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self top_dismissView];
}

- (void)top_clickDoneBtn {
    if (self.sender) {
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    } else {
        if (self.completeBlock) {
            self.completeBlock();
        }
    }
    [self top_dismissView];
}


#pragma mark -- 加载视图
- (void)top_configContentView {
    [self addSubview:self.maskView];
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.closeBtn];
    [self.bgView addSubview:self.doneBtn];
    [self.bgView addSubview:self.leftIcon];
    [self.bgView addSubview:self.rightIcon];
    [self.bgView addSubview:self.leftLab];
    [self.bgView addSubview:self.rightLab];
    [self.bgView addSubview:self.connectImg];
    [self.bgView addSubview:self.tipLab];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.mas_bottom);
        make.height.mas_equalTo(self.bgView_Height+TOPBottomSafeHeight);
    }];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bgView).offset(-16);
        make.top.equalTo(self.bgView).offset(10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
    }];
    [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgView).offset(-24);
        make.centerX.equalTo(self.bgView);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(234);
    }];
    
    CGFloat imgLeading = 72 * TOPScreenWidth / 375.0;
    [self.leftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(imgLeading);
        make.top.equalTo(self.closeBtn.mas_bottom).offset(0);
    }];
    [self.rightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bgView).offset(-imgLeading);
        make.top.equalTo(self.leftIcon.mas_top).offset(0);
    }];
    
    [self.leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.leftIcon.mas_centerX).offset(0);
        make.top.equalTo(self.leftIcon.mas_bottom).offset(3);
    }];
    [self.rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.rightIcon.mas_centerX).offset(0);
        make.top.equalTo(self.rightIcon.mas_bottom).offset(3);
    }];
    
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.bottom.equalTo(self.doneBtn.mas_top).offset(-31);
    }];
    
    [self.connectImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.centerY.equalTo(self.leftIcon.mas_centerY).offset(0);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    
    if (self.sender) {
        self.leftLab.text = NSLocalizedString(@"topscan_thisdevice", @"");
    } else {
        self.rightLab.text = NSLocalizedString(@"topscan_thisdevice", @"");
    }
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.bgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
    self.leftLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
    self.rightLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
    self.tipLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
}
- (void)setPeerId:(NSString *)peerId {
    _peerId = peerId;
    if (self.sender) {
        self.tipLab.text = NSLocalizedString(@"topscan_connecting", @"");
        self.rightLab.text = peerId;
    } else {
        if ([[[NSLocale preferredLanguages] firstObject] hasPrefix:@"zh"]) {
            self.tipLab.text = [NSString stringWithFormat:@"(%@) %@",self.peerId,NSLocalizedString(@"topscan_requestfrom", @"")];
        } else {
            self.tipLab.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"topscan_requestfrom", @""),self.peerId];
        }
        self.leftLab.text = peerId;
    }
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
        _bgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
        _bgView.layer.cornerRadius = 10;
    }
    return _bgView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, (52), 44)];
        [btn setImage:[UIImage imageNamed:@"top_menu_close"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(top_clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn = btn;
    }
    return _closeBtn;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(TOPScreenWidth - 75, 0, 60, 30)];
        [btn setTitle:self.btnTitle forState:UIControlStateNormal];
        [btn setTitleColor:kWhiteColor forState:UIControlStateNormal];
        [btn setBackgroundColor:kTopicBlueColor];
        btn.layer.cornerRadius = 22;
        [btn.titleLabel setFont:PingFang_R_FONT_(14)];
        [btn addTarget:self action:@selector(top_clickDoneBtn) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn = btn;
    }
    return _doneBtn;
}

- (UIImageView *)leftIcon {
    if (!_leftIcon) {
        _leftIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_iphone_logo"]];
    }
    return _leftIcon;
}

- (UIImageView *)rightIcon {
    if (!_rightIcon) {
        _rightIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_iphone_logo"]];
    }
    return _rightIcon;
}

- (UIImageView *)connectImg {
    if (!_connectImg) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"connecting" ofType:@"gif"];
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage sd_imageWithGIFData:imageData];
        _connectImg = [[UIImageView alloc] initWithImage:image];
    }
    return _connectImg;
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        _leftLab.textAlignment = NSTextAlignmentCenter;
        _leftLab.font = PingFang_R_FONT_(14);
    }
    return _leftLab;
}

- (UILabel *)rightLab {
    if (!_rightLab) {
        _rightLab = [[UILabel alloc] init];
        _rightLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        _rightLab.textAlignment = NSTextAlignmentCenter;
        _rightLab.font = PingFang_R_FONT_(14);
    }
    return _rightLab;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        _tipLab.textAlignment = NSTextAlignmentCenter;
        _tipLab.font = PingFang_R_FONT_(14);
    }
    return _tipLab;
}

@end
