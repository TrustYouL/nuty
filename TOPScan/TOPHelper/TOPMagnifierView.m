#import "TOPMagnifierView.h"

@interface TOPMagnifierView ()
@property (nonatomic, strong) CALayer *contentLayer;
@end
@implementation TOPMagnifierView
-(instancetype)init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 120, 120);
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = TOPAPPGreenColor.CGColor;
        self.layer.cornerRadius = 120/2;
        self.layer.masksToBounds = YES;
        self.windowLevel = UIWindowLevelAlert;
        
        self.contentLayer = [CALayer layer];
        self.contentLayer.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
        self.contentLayer.frame = self.bounds;
        self.contentLayer.delegate = self;
        self.contentLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:self.contentLayer];
    }
    return self;
}

#pragma mark -- 放大镜准心
- (void)top_aimPint:(CGPoint)centerPoint {
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    CGFloat dotSize = 5.0;
    [linePath moveToPoint:(CGPoint){centerPoint.x - dotSize, centerPoint.y}];
    [linePath addLineToPoint:(CGPoint){centerPoint.x + dotSize, centerPoint.y}];
    UIBezierPath *verticalPath = [UIBezierPath bezierPath];
    [verticalPath moveToPoint:(CGPoint){centerPoint.x, centerPoint.y - dotSize}];
    [verticalPath addLineToPoint:(CGPoint){centerPoint.x, centerPoint.y + dotSize}];
    [linePath appendPath:verticalPath];
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.bounds = self.bounds;
    lineLayer.position = centerPoint;
    lineLayer.lineWidth = 0.5;
    lineLayer.strokeColor = kCommonBlackTextColor.CGColor; //   边线颜色
    lineLayer.path = linePath.CGPath;
    lineLayer.fillColor  = nil;   //  默认是black
    [self.contentLayer addSublayer:lineLayer];
}

#pragma mark set the point of magnifier
-(void)setPointTomagnify:(CGPoint)pointTomagnify
{
    _pointTomagnify = pointTomagnify;
    CGPoint center = CGPointMake(pointTomagnify.x, self.center.y);
    if (pointTomagnify.y > CGRectGetHeight(self.bounds) * 0.5) {
        center.y = pointTomagnify.y - CGRectGetHeight(self.bounds)/2+80;
    }
    if (pointTomagnify.x > TOPScreenWidth / 2) {
        self.center = CGPointMake(40+15, 100);
    } else {
        self.center = CGPointMake(TOPScreenWidth - (40+15), 100);
    }
    [self.contentLayer setNeedsDisplay];
}

#pragma mark  invoke  by setNeedDisplay
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    float width = CGRectGetWidth(self.frame);
    float height = CGRectGetHeight(self.frame);
    CGContextTranslateCTM(ctx,width * 0.5, height * 0.5);
    CGContextScaleCTM(ctx, 2.5, 2.5);
    CGContextTranslateCTM(ctx, -self.pointTomagnify.x, -self.pointTomagnify.y);
    [self.magnifyView.layer renderInContext:ctx];
    [self top_aimPint:CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2)];
}
@end
