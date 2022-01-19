#import "TOPTrackingSliderView.h"
#import "TOPTrackingSlider.h"
@interface TOPTrackingSliderView()<TOPTrackingSliderDelegate>
@end
@implementation TOPTrackingSliderView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpWithFrame:frame];
    }
    return self;
}
- (void)setUpWithFrame:(CGRect)frame{
    _uiSlider = [[TOPTrackingSlider alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
    _uiSlider.delegate = self;
    _uiSlider.minimumValue = 0;
    _uiSlider.maximumValue = 1;
    _uiSlider.value = 0;
    _uiSlider.tintColor = [UIColor redColor];
    _uiSlider.thumbTintColor = [UIColor greenColor];
    [self addSubview:_uiSlider];
}

- (void)topCurrentValueOfSlider:(TOPTrackingSlider *)slider{
    if ([self.delegate respondsToSelector:@selector(top_topCurrentSlider:)]) {
        [self.delegate top_topCurrentSlider:slider];
    }
}
- (void)topBeginSwipSlider:(TOPTrackingSlider *)slider{
}
- (void)topEndSwipSlider:(TOPTrackingSlider *)slider{
}
- (void)setIsVertical:(BOOL)isVertical{
    _isVertical = isVertical;
    if (_isVertical == YES) {
        self.uiSlider.transform = CGAffineTransformMakeRotation(1.57079633);
    }
}
- (void)setMinValue:(CGFloat)minValue{
    _minValue = minValue;
    _uiSlider.minimumValue = minValue;
}
- (void)setMaxValue:(CGFloat)maxValue{
    _maxValue = maxValue;
    _uiSlider.maximumValue = maxValue;
}
- (void)setDefaultValue:(CGFloat)defaultValue{
    _uiSlider.value = defaultValue;
}
- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor{
    _minimumTrackTintColor = minimumTrackTintColor;
    _uiSlider.minimumTrackTintColor = minimumTrackTintColor;
}
- (void)setMaxmumTrackTintColor:(UIColor *)maxmumTrackTintColor{
    _maxmumTrackTintColor = maxmumTrackTintColor;
    _uiSlider.maximumTrackTintColor = maxmumTrackTintColor;
}
- (void)setCircleImg:(UIImage *)circleImg{
    [_uiSlider setThumbImage:circleImg forState:UIControlStateNormal];
    [_uiSlider setThumbImage:circleImg forState:UIControlStateHighlighted];
}
#pragma mark -- 解决在UIScrollView中滑动冲突的问题
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return CGRectContainsPoint(self.uiSlider.frame, point);
}

@end
