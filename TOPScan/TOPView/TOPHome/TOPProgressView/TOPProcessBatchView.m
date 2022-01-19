#import "TOPProcessBatchView.h"
#import "TOPBatchStripeView.h"

@interface TOPProcessBatchView ()
@property (nonatomic, strong) UIView *bgView;//阴影蒙版
@property (nonatomic, strong) TOPBatchStripeView *stripeView;//渐变色进度条
@property (nonatomic, strong) UIView *maskView;//阴影蒙版
@property (nonatomic, strong) UILabel *progressLab;//进度显示 (1/10)
@property (nonatomic, strong) UILabel *rateLab;//进度半分比显示 0%~100%

@end
@implementation TOPProcessBatchView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)top_configContentView {
    self.backgroundColor = [UIColor clearColor];
    if (!_stripeView) {
        [self addSubview:self.stripeView];
        [self.stripeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(self);
        }];
    }
}

- (void)show{
    [self top_configContentView];
}

- (void)top_showProgress:(CGFloat)currentProgress{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setProgressValue:currentProgress];
    });
}

- (void)setProgressValue:(CGFloat)val {
    if (_stripeView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.stripeView setProgress:val];
        });
    }
}

- (void)dismiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.stripeView removeFromSuperview];
        self.stripeView = nil;
    });
}

- (TOPBatchStripeView *)stripeView {
    if (!_stripeView) {
        _stripeView = [[TOPBatchStripeView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)]; 
    }
    return _stripeView;
}

@end
