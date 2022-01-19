#import "TOPLoadingCircleView.h"

@interface TOPLoadingCircleView ()
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) CAGradientLayer *circleColorLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation TOPLoadingCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    self.backgroundColor = [UIColor clearColor];
    [self.circleView.layer insertSublayer:self.circleColorLayer atIndex:0];
    self.circleView.layer.mask = self.maskLayer;
    self.circleView.hidden = YES;
}


#pragma mark -- loop animation
- (void)top_loopAnimation {
    CABasicAnimation *animation=[CABasicAnimation     animationWithKeyPath:@"transform.rotation.z"]; ;
    // 设定动画选项
    animation.duration = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = HUGE_VALF;
    // 设定旋转角度
    animation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI]; // 终止角度
    [self.circleView.layer addAnimation:animation forKey:@"rotate-layer"];
}

- (void)top_startLoading {
    self.circleView.hidden = NO;
    [self top_loopAnimation];
}

- (void)dismiss {
    if (!self.circleView.hidden) {
        self.circleView.hidden = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.circleView removeFromSuperview];
            self.circleView = nil;
            self.circleColorLayer = nil;
            self.maskLayer = nil;
        });
    }
}

#pragma mark -- lazy
- (UIView *)circleView {
    if (!_circleView) {
        UIView *circleView = [[UIView alloc] init];
        circleView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        circleView.backgroundColor = [UIColor blueColor];
        [self addSubview:circleView];
        _circleView = circleView;
    }
    return _circleView;
}

- (CAGradientLayer *)circleColorLayer {
    if (!_circleColorLayer) {
        CAGradientLayer *layer = [[CAGradientLayer alloc] init];
        layer.frame = self.bounds;
        layer.locations = @[@0.2, @1.0];
        [layer setStartPoint:CGPointMake(0.0, 0.0)];
        [layer setEndPoint:CGPointMake(1.0, 0.0)];
        NSArray *colors = @[(__bridge id)[UIColor whiteColor].CGColor,(__bridge id)kTopicBlueColor.CGColor];
        [layer setColors:colors];
        _circleColorLayer = layer;
    }
    return _circleColorLayer;
}

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        CAShapeLayer *layer=[[CAShapeLayer alloc]init];
        CGMutablePathRef pathRef=CGPathCreateMutable();
        CGPathAddRelativeArc(pathRef, nil, self.frame.size.width/2.0, self.frame.size.height/2.0, self.frame.size.width<self.frame.size.height?self.frame.size.width/2.0-5:self.frame.size.height/2.0-5, 0, 2*M_PI);
        layer.path = pathRef;
        layer.lineWidth = 2;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = [UIColor blackColor].CGColor;
        CGPathRelease(pathRef);
        _maskLayer = layer;
    }
    return _maskLayer;
}

@end
