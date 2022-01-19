#import "TOPWaterPipeView.h"

@interface TOPWaterPipeView ()
//为了增加一个表示进度条的进行，可们可以使用mask属性来屏蔽一部分
@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CAGradientLayer *progressColorLayer;

@end

@implementation TOPWaterPipeView
@synthesize maskLayer,progress;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat hei = frame.size.height;
        self.backgroundColor = kWhiteColor;
        self.layer.cornerRadius = hei/2.0;
        maskLayer = [CALayer layer];
        [maskLayer setFrame:CGRectMake(0, 0, 0, hei)];
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
        layer.cornerRadius = self.frame.size.height/2.0;
        _progressColorLayer = layer;
    }
    return _progressColorLayer;
}
@end
