#import "TOPSearchDevicesView.h"

@interface TOPSearchDevicesView ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation TOPSearchDevicesView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    [self addSubview:self.titleLab];
    [self addSubview:self.activityIndicator];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(13);
        make.trailing.equalTo(self).offset(-60);
        make.centerY.equalTo(self);
    }];
    
    self.titleLab.text = NSLocalizedString(@"topscan_searching", @"");
    [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-13);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.activityIndicator startAnimating];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
}
#pragma mark -- lazy
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = kTabbarNormal;
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.font = PingFang_R_FONT_(14);
    }
    return _titleLab;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.frame = CGRectMake(0, 0, 20, 20);
        _activityIndicator.backgroundColor = [UIColor clearColor];
    }
    return _activityIndicator;
}

@end
