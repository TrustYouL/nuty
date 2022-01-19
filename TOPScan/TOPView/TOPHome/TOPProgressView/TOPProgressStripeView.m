#import "TOPProgressStripeView.h"
#define kProgressView_W       315
#define kProgressView_H       124
#define kStripeViewLeftSpace  24

@interface StripeView : UIView
@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CAGradientLayer *progressColorLayer;
-(void)setProgress:(CGFloat)value;

@end

@implementation StripeView
@synthesize maskLayer,progress;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBA(238.0, 238.0, 238.0, 1);
        self.layer.cornerRadius = 2.5;
        maskLayer = [CALayer layer];
        [maskLayer setFrame:CGRectMake(0, 0, 0, frame.size.height)];
        [maskLayer setBackgroundColor:[UIColor blackColor].CGColor];
        [self.progressColorLayer setMask:maskLayer];
        [self.layer addSublayer:self.progressColorLayer];
    }
    return self;
}

- (void)setProgress:(CGFloat)value {
    if (progress != value) {
        progress = MIN(1.0, fabs(value));
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [self progressAnimation];
}

#pragma mark -- 进度条动画
- (void)progressAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [CATransaction setAnimationDuration:0.016];
    maskLayer.frame = CGRectMake(0, 0, CGRectGetWidth([self bounds]) * progress, CGRectGetHeight([self bounds]));
    [CATransaction commit];
}

- (CAGradientLayer *)progressColorLayer {
    if (!_progressColorLayer) {
        CAGradientLayer *layer = [[CAGradientLayer alloc] init];
        layer.frame = self.bounds;
        [layer setStartPoint:CGPointMake(0.0, 0.0)];
        [layer setEndPoint:CGPointMake(1.0, 1.0)];
        NSArray *colors = @[(__bridge id)[UIColor colorWithRed:116/255.0 green:176/255.0 blue:248/255.0 alpha:1.0].CGColor,(__bridge id)TOPAPPGreenColor.CGColor];
        [layer setColors:colors];
        layer.cornerRadius = 2.5;
        _progressColorLayer = layer;
    }
    return _progressColorLayer;
}

@end

@interface TOPProgressStripeView ()
@property (nonatomic, strong) UIView *bgView;//阴影蒙版
@property (nonatomic, strong) StripeView *stripeView;//渐变色进度条
@property (nonatomic, strong) UIView *maskView;//阴影蒙版
@property (nonatomic, strong) UILabel *progressLab;//进度显示 (1/10)
@property (nonatomic, strong) UILabel *rateLab;//进度半分比显示 0%~100%

@end

@implementation TOPProgressStripeView

+ (instancetype)shareInstance {
    static TOPProgressStripeView *singleTon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[TOPProgressStripeView alloc] init];
    });
    return singleTon;
}

- (void)top_configContentView {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (!window) {
        return;
    }
    [window addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(window);
    }];
    
    [self.maskView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.maskView);
        make.size.mas_equalTo(CGSizeMake(kProgressView_W, kProgressView_H));
    }];
    
    [self.bgView addSubview:self.progressLab];
    [self.bgView addSubview:self.stripeView];
    [self.bgView addSubview:self.rateLab];
    [self.progressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(kStripeViewLeftSpace);
        make.trailing.equalTo(self.bgView).offset(-kStripeViewLeftSpace);
        make.top.equalTo(self.bgView).offset(35);
        make.height.mas_equalTo(20);
    }];
    [self.stripeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(kStripeViewLeftSpace);
        make.trailing.equalTo(self.bgView).offset(-kStripeViewLeftSpace);
        make.top.equalTo(self.bgView).offset(68);
        make.height.mas_equalTo(5);
    }];
    [self.rateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(kStripeViewLeftSpace);
        make.trailing.equalTo(self.bgView).offset(-kStripeViewLeftSpace);
        make.top.equalTo(self.bgView).offset(68+5);
        make.height.mas_equalTo(12);
    }];
}

- (void)top_showWithStatus:(NSString *)status {
    [self top_configContentView];
    self.progressLab.text = status;
    self.rateLab.text = @"0%";
}

- (void)top_showProgress:(CGFloat)currentProgress withStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLab.text = status;
        [self setProgressValue:currentProgress];
    });
}

- (void)top_resetProgress {
    [self setProgressValue:0];
}

- (void)setProgressValue:(CGFloat)val {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (val <= 1.0) {
            self.rateLab.text = [NSString stringWithFormat:@"%.f%%",val * 100];
            [self.stripeView setProgress:val];
        }
    });
}

- (void)dismiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressLab removeFromSuperview];
        self.progressLab = nil;
        [self.stripeView removeFromSuperview];
        self.stripeView = nil;
        [self.rateLab removeFromSuperview];
        self.rateLab = nil;
        [self.bgView removeFromSuperview];
        self.bgView = nil;
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    });
}

- (void)hide{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLab.hidden = YES;
        self.stripeView.hidden = YES;
        self.rateLab.hidden = YES;
        self.bgView.hidden = YES;
    });
}

- (void)show{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLab.hidden = NO;
        self.stripeView.hidden = NO;
        self.rateLab.hidden = NO;
        self.bgView.hidden = NO;
    });
}
#pragma mark -- lazy
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.frame = CGRectMake((TOPScreenWidth - kProgressView_W)/2, TOPScreenHeight/2 - kProgressView_H/2, kProgressView_W, kProgressView_H);
        _bgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(217.0, 217.0, 217.0, 1)];
        _bgView.layer.cornerRadius = 5;
    }
    return _bgView;
}

//蒙版
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc]init];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }
    return _maskView;
}

- (UILabel *)progressLab {
    if (!_progressLab) {
        UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(kStripeViewLeftSpace, 35, CGRectGetWidth(self.bgView.bounds) - kStripeViewLeftSpace*2, 20)];
        noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_M_FONT_(17);
        noClassLab.text = @"";
        _progressLab = noClassLab;
    }
    return _progressLab;
}

- (UILabel *)rateLab {
    if (!_rateLab) {
        UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(kStripeViewLeftSpace, CGRectGetMaxY(self.stripeView.frame) + 5, CGRectGetWidth(self.bgView.bounds) - kStripeViewLeftSpace*2, 12)];
        noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        noClassLab.textAlignment = NSTextAlignmentRight;
        noClassLab.font = PingFang_M_FONT_(10);
        noClassLab.text = @"";
        _rateLab = noClassLab;
    }
    return _rateLab;
}

- (StripeView *)stripeView {
    if (!_stripeView) {
        _stripeView = [[StripeView alloc] initWithFrame:CGRectMake(kStripeViewLeftSpace, 68, CGRectGetWidth(self.bgView.bounds) - kStripeViewLeftSpace*2, 5)];
    }
    return _stripeView;
}

@end
