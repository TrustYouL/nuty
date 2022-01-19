#import "TOPProgressSlider.h"
#import "TOPWaterPipeView.h"

@interface TOPProgressSlider ()

@property (nonatomic, strong) UIView *bgView;//背景
@property (nonatomic, strong) TOPWaterPipeView *stripeView;//渐变色进度条
@property (nonatomic, strong) UILabel *progressLab;//进度显示 0%~100%

@end

@implementation TOPProgressSlider

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)top_configContentView {
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.bgView addSubview:self.progressLab];
    [self.bgView addSubview:self.stripeView];
    [self.progressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.top.equalTo(self.stripeView.mas_bottom).offset(10);
    }];
    [self.stripeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.width.mas_equalTo(200.0/375.0 * TOPScreenWidth);
        make.top.equalTo(self.bgView).offset(0);
        make.height.mas_equalTo(10);
    }];
}

- (void)top_showWithStatus:(NSString *)status {
    [self top_configContentView];
    self.progressLab.text = status;
}

- (void)top_showProgress:(CGFloat)currentProgress withStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *valStr = [NSString stringWithFormat:@"%.f%%",currentProgress * 100];
        self.progressLab.text = [NSString stringWithFormat:@"%@ %@", status, valStr];
        [self setProgressValue:currentProgress];
    });
}

- (void)top_resetProgress {
    [self setProgressValue:0];
}

- (void)setProgressValue:(CGFloat)val {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.stripeView setProgress:val];
    });
}

- (void)dismiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressLab removeFromSuperview];
        self.progressLab = nil;
        [self.stripeView removeFromSuperview];
        self.stripeView = nil;
        [self.bgView removeFromSuperview];
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    });
}

- (void)hide{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLab.hidden = YES;
        self.stripeView.hidden = YES;
        self.bgView.hidden = YES;
    });
}

- (void)show{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLab.hidden = NO;
        self.stripeView.hidden = NO;
        self.bgView.hidden = NO;
    });
}
#pragma mark -- lazy
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor clearColor];
    }
    return _bgView;
}

- (UILabel *)progressLab {
    if (!_progressLab) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_M_FONT_(12);
        noClassLab.text = @"";
        _progressLab = noClassLab;
    }
    return _progressLab;
}

- (TOPWaterPipeView *)stripeView {
    if (!_stripeView) {
        _stripeView = [[TOPWaterPipeView alloc] initWithFrame:CGRectMake(0, 0, (200.0/375.0 * TOPScreenWidth), 10)];
    }
    return _stripeView;
}

@end
