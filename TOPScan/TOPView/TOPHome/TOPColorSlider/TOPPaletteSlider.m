#import "TOPPaletteSlider.h"

@interface TOPPaletteSlider()
@property (strong, nonatomic) CAShapeLayer *cicleShape;
@property (strong, nonatomic) UIView *sliderView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

#define SSThumbWidth 20
#define SSThumbHeight 28
@implementation TOPPaletteSlider

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self top_setup];
    }
    return self;
}

- (void)top_setup {
    [self addSubview:self.sliderView];
    [self addSubview:self.thumbView];
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.center.equalTo(self);
        make.height.mas_equalTo(10);
    }];
    
    [self.thumbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(SSThumbWidth, SSThumbHeight));
    }];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    CGPoint point = [touch locationInView:self];
    self.thumbView.frame = CGRectMake(point.x - SSThumbWidth/2, self.thumbView.frame.origin.y,
                            self.thumbView.frame.size.width, self.thumbView.frame.size.height);
    return YES;
}


- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint point = [touch locationInView:self];
    CGFloat thumb_x = point.x - SSThumbWidth/2;
    if (thumb_x < - SSThumbWidth/2) {
        thumb_x = - SSThumbWidth/2;
    }
    if (thumb_x > self.bounds.size.width - SSThumbWidth/2) {
        thumb_x = self.bounds.size.width - SSThumbWidth/2;
    }
    CGPoint colorPoint = CGPointMake(thumb_x+SSThumbWidth/2, 5);
    UIColor *color = [self colorOfPoint:colorPoint];
    if (colorPoint.x > 2 && colorPoint.x < self.sliderView.frame.size.width - 5) {
        self.cicleShape.fillColor = [color CGColor];
        self.selectedColor = color;
    }
    self.thumbView.frame = CGRectMake(thumb_x,self.thumbView.frame.origin.y,
                                        self.thumbView.frame.size.width, self.thumbView.frame.size.height);

    return YES;
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (UIColor *)colorOfPoint:(CGPoint)point {
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.gradientLayer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}

- (UIView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.bounds.size.height-10)/2.0, self.bounds.size.width, 10)];
        NSArray *colorArray = @[(id)[[UIColor colorWithHex:0xFB0006] CGColor],
                           (id)[[UIColor colorWithHex:0xFAFF0A] CGColor],
                          (id)[[UIColor colorWithHex:0x22FF08] CGColor],
                           (id)[[UIColor colorWithHex:0x114c97] CGColor],
                           (id)[[UIColor colorWithHex:0x3500A8] CGColor]];
        NSArray *colorLocationArray = @[@0.1, @0.3, @0.5, @0.7, @1];
        _gradientLayer =  [CAGradientLayer layer];
        _gradientLayer.frame = CGRectMake(0,0,self.frame.size.width,10);
        _gradientLayer.masksToBounds = YES;
        _gradientLayer.cornerRadius = 5;
        [_gradientLayer setLocations:colorLocationArray];
        [_gradientLayer setColors:colorArray];
        [_gradientLayer setStartPoint:CGPointMake(0, 0)];
        [_gradientLayer setEndPoint:CGPointMake(1, 0)];
        [_sliderView.layer addSublayer:_gradientLayer];
        _sliderView.userInteractionEnabled = NO;
    }
    return _sliderView;
}

- (UIView *)thumbView {
    if (!_thumbView) {
        _thumbView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, self.sliderView.frame.origin.y-SSThumbHeight + 5, SSThumbWidth, SSThumbHeight)];
        _thumbView.alpha = 1.0;
        
        UIColor *cicleFillColor = [UIColor redColor];
        UIColor *cicleStrokeColor = ForbidBg;
        UIColor *triangleFillColor = ForbidBg;
        UIColor *triangleStrokeColor = ForbidBg;
        
        CAShapeLayer *cicleShape= [CAShapeLayer new];
        cicleShape.fillColor = cicleFillColor.CGColor; //填充颜色
        cicleShape.strokeColor = cicleStrokeColor.CGColor; //边框颜色
        cicleShape.lineWidth = 3.0f; //边框的宽度
        //圆形
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(SSThumbWidth/2, SSThumbWidth/2) radius:SSThumbWidth/2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
        cicleShape.path = bezierPath.CGPath;
        [_thumbView.layer addSublayer:cicleShape];
        _cicleShape = cicleShape;
        
        
        CAShapeLayer *triangleShape= [CAShapeLayer new];
        triangleShape.fillColor = triangleFillColor.CGColor; //填充颜色
        triangleShape.strokeColor = triangleStrokeColor.CGColor; //边框颜色
        triangleShape.lineWidth = 1.0f; //边框的宽度
        //三角形
        UIBezierPath *trianglePath = [UIBezierPath new];
        [trianglePath moveToPoint:CGPointMake(SSThumbWidth/2, SSThumbHeight)];
        [trianglePath addLineToPoint:CGPointMake(SSThumbWidth/2 - 7, SSThumbWidth - 1)];
        [trianglePath addLineToPoint:CGPointMake(SSThumbWidth/2 + 7, SSThumbWidth - 1)];
        [trianglePath closePath];
        triangleShape.path = trianglePath.CGPath;
        [_thumbView.layer addSublayer:triangleShape];
        _thumbView.userInteractionEnabled = NO;
    }
    return _thumbView;
}

@end
