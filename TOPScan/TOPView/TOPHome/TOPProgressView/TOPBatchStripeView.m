#import "TOPBatchStripeView.h"
@interface TOPBatchStripeView ()
@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, strong) CAGradientLayer *progressColorLayer;
-(void)setProgress:(CGFloat)value;

@end
@implementation TOPBatchStripeView
@synthesize maskLayer,progress;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
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
    [CATransaction setAnimationDuration:0.02];
    maskLayer.frame = CGRectMake(0, 0, CGRectGetWidth([self bounds]) * progress, CGRectGetHeight([self bounds]));
    [CATransaction commit];
}

- (CAGradientLayer *)progressColorLayer {
    if (!_progressColorLayer) {
        CAGradientLayer *layer = [[CAGradientLayer alloc] init];
        layer.frame = self.bounds;
        [layer setStartPoint:CGPointMake(0.0, 0.0)];
        [layer setEndPoint:CGPointMake(1.0, 1.0)];
        NSArray *colors = @[(__bridge id)TOPAPPGreenColor.CGColor,(__bridge id)TOPAPPGreenColor.CGColor];
        [layer setColors:colors];
        layer.cornerRadius = 2.5;
        _progressColorLayer = layer;
    }
    return _progressColorLayer;
}

@end
