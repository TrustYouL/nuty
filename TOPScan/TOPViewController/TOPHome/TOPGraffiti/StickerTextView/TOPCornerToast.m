#import "TOPCornerToast.h"

@interface TAToastLable : UILabel
- (void)setTaostText:(NSString *)text;

@end

@implementation TAToastLable

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        self.backgroundColor = RGBA(0, 0, 0, 0.6);
        self.numberOfLines = 0;
        self.textAlignment = NSTextAlignmentCenter;
        self.textColor = kWhiteColor;
        self.font = PingFang_R_FONT_(14);
    }
    return self;
}

- (void)setTaostText:(NSString *)text {
    [self setText:text];
    CGFloat SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    CGFloat SCREEN_HEIGHT = [UIScreen mainScreen].bounds.size.height;
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font} context:nil];
    CGFloat width = rect.size.width + 20;
    CGFloat height = rect.size.height + 40;
    CGFloat x = (SCREEN_WIDTH-width)/2;
    CGFloat y = SCREEN_HEIGHT/2 - height;
    self.frame = CGRectMake(x, y, width, height);
}

@end

@interface TOPCornerToast () {
    NSTimer *countTimer;
}
@property (nonatomic, strong) TAToastLable *toastLab;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

static CGFloat changeCount;

@implementation TOPCornerToast

+ (instancetype)shareInstance {
    
    static TOPCornerToast *singleTon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[TOPCornerToast alloc] init];
    });
    return singleTon;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _toastLab = [[TAToastLable alloc] init];
        countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
        countTimer.fireDate = [NSDate distantFuture];
    }
    return self;
}

#pragma makr -- 弹出toast
- (void)makeToast:(NSString *)message {
    [self makeToast:message duration:1.0];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)duration {
    if (![message length]) {
        return;
    }
    [self top_hiddenToast];
    [self hiddenLoadingView];
    [self.toastLab setTaostText:message];
    [self.maskView addSubview:self.toastLab];
    self.toastLab.alpha = 1.0;
    countTimer.fireDate = [NSDate distantPast];
    changeCount = duration;
}

- (void)setToastCenter:(CGPoint)center {
    self.toastLab.center = (center);
}

- (void)changeTime {
    if (changeCount -- <= 0) {
        [self top_hiddenToast];
        [self hiddenLoadingView];
    }
}

- (void)top_hiddenToast {
    if (self.toastLab.alpha == 1.0) {
        countTimer.fireDate = [NSDate distantFuture];
        self.toastLab.alpha = 0;
        [self.toastLab removeFromSuperview];
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }
}

#pragma mark -- 加载动画
- (void)makeLoading {
    [self.activityIndicator startAnimating];
    countTimer.fireDate = [NSDate distantPast];
    changeCount = 10;
}

- (void)hiddenLoadingView {
    if (_activityIndicator) {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        [self.maskView removeFromSuperview];
        self.activityIndicator = nil;
        self.maskView = nil;
    }
}

- (void)dealloc {
    [countTimer invalidate];
    countTimer = nil;
}

//遮罩层
- (UIView *)maskView {
    if (!_maskView) {
        UIView *mask = [[UIView alloc] init];
        mask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.05];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:mask];
        mask.frame = window.bounds;
        mask.userInteractionEnabled = NO;
        _maskView = mask;
    }
    return _maskView;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGFloat SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
        CGFloat SCREEN_HEIGHT = [UIScreen mainScreen].bounds.size.height;
        _activityIndicator.frame = CGRectMake(0, 0, 60, 60);
        _activityIndicator.layer.cornerRadius = 5;
        _activityIndicator.layer.masksToBounds = YES;
        _activityIndicator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.maskView addSubview:_activityIndicator];
        _activityIndicator.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    }
    return _activityIndicator;
}

@end
