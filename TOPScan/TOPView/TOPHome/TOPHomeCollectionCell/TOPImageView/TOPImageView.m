#import "TOPImageView.h"
#define WIDTH(_view) CGRectGetWidth(_view.bounds)
#define HEIGHT(_view) CGRectGetHeight(_view.bounds)
#define MAXX(_view) CGRectGetMaxX(_view.frame)
#define MAXY(_view) CGRectGetMaxY(_view.frame)
#define MINX(_view) CGRectGetMinX(_view.frame)
#define MINY(_view) CGRectGetMinY(_view.frame)
#define MID_LINE_INTERACT_WIDTH 44
#define MID_LINE_INTERACT_HEIGHT 44
typedef NS_ENUM(NSInteger, TKCropAreaCornerPosition) {
    TKCropAreaCornerPositionTopLeft,
    TKCropAreaCornerPositionTopRight,
    TKCropAreaCornerPositionBottomLeft,
    TKCropAreaCornerPositionBottomRight
};
typedef NS_ENUM(NSInteger, TKMidLineType) {
    
    TKMidLineTypeTop,
    TKMidLineTypeBottom,
    TKMidLineTypeLeft,
    TKMidLineTypeRight
    
};
@interface UIImage(Handler)
@end
@implementation UIImage(Handler)
- (UIImage *)top_imageAtRect:(CGRect)rect
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
    
}
@end
@interface CornerView: UIView

@property (assign, nonatomic) CGFloat lineWidth;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) TKCropAreaCornerPosition cornerPosition;
@property (assign, nonatomic) CornerView *relativeViewX;
@property (assign, nonatomic) CornerView *relativeViewY;
@property (strong, nonatomic) CAShapeLayer *cornerShapeLayer;

- (void)updateSizeWithWidth: (CGFloat)width height: (CGFloat)height;
@end
@implementation CornerView
- (instancetype)initWithFrame:(CGRect)frame lineColor: (UIColor *)lineColor lineWidth: (CGFloat)lineWidth {
    
    self = [super initWithFrame: frame];
    if(self) {
        self.lineColor = lineColor;
        self.lineWidth = lineWidth;
    }
    return self;
}
- (void)setCornerPosition:(TKCropAreaCornerPosition)cornerPosition {

    _cornerPosition = cornerPosition;
    [self top_drawCornerLines];
    
}
- (void)setLineWidth:(CGFloat)lineWidth {
    
    _lineWidth = lineWidth;
    [self top_drawCornerLines];
    
}
- (void)top_drawCornerLines {
    
    if(_cornerShapeLayer && _cornerShapeLayer.superlayer) {
        [_cornerShapeLayer removeFromSuperlayer];
    }
    _cornerShapeLayer = [CAShapeLayer layer];
    _cornerShapeLayer.lineWidth = _lineWidth;
    _cornerShapeLayer.strokeColor = _lineColor.CGColor;
    _cornerShapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *cornerPath = [UIBezierPath bezierPath];
    CGFloat paddingX = _lineWidth / 2.0f;
    CGFloat paddingY = _lineWidth / 2.0f;
    switch (_cornerPosition) {
        case TKCropAreaCornerPositionTopLeft: {
            [cornerPath moveToPoint:CGPointMake(WIDTH(self), paddingY)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, HEIGHT(self))];
            break;
        }
        case TKCropAreaCornerPositionTopRight: {
            [cornerPath moveToPoint:CGPointMake(0, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, HEIGHT(self))];
            break;
        }
        case TKCropAreaCornerPositionBottomLeft: {
            [cornerPath moveToPoint:CGPointMake(paddingX, 0)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, HEIGHT(self) - paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self), HEIGHT(self) - paddingY)];
            break;
        }
        case TKCropAreaCornerPositionBottomRight: {
            [cornerPath moveToPoint:CGPointMake(WIDTH(self) - paddingX, 0)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, HEIGHT(self) - paddingY)];
            [cornerPath addLineToPoint:CGPointMake(0, HEIGHT(self) - paddingY)];
            break;
        }
        default:
            break;
    }
    _cornerShapeLayer.path = cornerPath.CGPath;
    [self.layer addSublayer: _cornerShapeLayer];
    
}
- (void)updateSizeWithWidth: (CGFloat)width height: (CGFloat)height {
    
    switch (_cornerPosition) {
        case TKCropAreaCornerPositionTopLeft: {
            self.frame = CGRectMake(MINX(self), MINY(self), width, height);
            break;
        }
        case TKCropAreaCornerPositionTopRight: {
            self.frame = CGRectMake(MAXX(self) - width, MINY(self), width, height);
            break;
        }
        case TKCropAreaCornerPositionBottomLeft: {
            self.frame = CGRectMake(MINX(self), MAXY(self) - height, width, height);
            break;
        }
        case TKCropAreaCornerPositionBottomRight: {
            self.frame = CGRectMake(MAXX(self) - width, MAXY(self) - height, width, height);
            break;
        }
        default:
            break;
    }
    [self top_drawCornerLines];
    
}
- (void)setLineColor:(UIColor *)lineColor {
    
    _lineColor = lineColor;
    _cornerShapeLayer.strokeColor = lineColor.CGColor;
    
}
@end

@interface MidLineView : UIView
@property (strong, nonatomic) CAShapeLayer *lineLayer;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) CGFloat lineHeight;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) TKMidLineType type;
@end
@implementation MidLineView
- (instancetype)initWithLineWidth: (CGFloat)lineWidth lineHeight: (CGFloat)lineHeight lineColor: (UIColor *)lineColor {
    
    self = [super initWithFrame: CGRectMake(0, 0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT)];
    if(self) {
        self.lineWidth = lineWidth;
        self.lineHeight = lineHeight;
        self.lineColor = lineColor;
    }
    return self;

}
- (void)setType:(TKMidLineType)type {

    _type = type;
    [self top_drawMidLine];
    
}
- (void)setLineWidth:(CGFloat)lineWidth {
    
    _lineWidth = lineWidth;
    [self top_drawMidLine];
    
}
- (void)setLineColor:(UIColor *)lineColor {
    
    _lineColor = lineColor;
    _lineLayer.strokeColor = lineColor.CGColor;
    
}
- (void)setLineHeight:(CGFloat)lineHeight {
    
    _lineHeight = lineHeight;
    _lineLayer.lineWidth = lineHeight;
    
}
- (void)top_drawMidLine {
    
    if(_lineLayer && _lineLayer.superlayer) {
        [_lineLayer removeFromSuperlayer];
    }
    _lineLayer = [CAShapeLayer layer];
    _lineLayer.strokeColor = _lineColor.CGColor;
    _lineLayer.lineWidth = _lineHeight;
    _lineLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *midLinePath = [UIBezierPath bezierPath];
    switch (_type) {
        case TKMidLineTypeTop:
        case TKMidLineTypeBottom: {
            [midLinePath moveToPoint:CGPointMake((WIDTH(self) - _lineWidth) / 2.0, HEIGHT(self) / 2.0)];
            [midLinePath addLineToPoint:CGPointMake((WIDTH(self) + _lineWidth) / 2.0, HEIGHT(self) / 2.0)];
            break;
        }
        case TKMidLineTypeRight:
        case TKMidLineTypeLeft: {
            [midLinePath moveToPoint:CGPointMake(WIDTH(self) / 2.0, (HEIGHT(self) - _lineWidth) / 2.0)];
            [midLinePath addLineToPoint:CGPointMake(WIDTH(self) / 2.0, (HEIGHT(self) + _lineWidth) / 2.0)];
            break;
        }
        default:
            break;
    }
    _lineLayer.path = midLinePath.CGPath;
    [self.layer addSublayer: _lineLayer];
    
}
@end

@interface CropAreaView : UIView
@property (strong, nonatomic) CAShapeLayer *crossLineLayer;
@property (assign, nonatomic) CGFloat crossLineWidth;
@property (strong, nonatomic) UIColor *crossLineColor;
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) CAShapeLayer *borderLayer;
@property (assign, nonatomic) BOOL showCrossLines;
@end
@implementation CropAreaView

- (instancetype)init {
    
    self = [super init];
    if(self) {
        [self top_createBorderLayer];
    }
    return self;
}
- (void)setFrame:(CGRect)frame {
    
    [super setFrame: frame];
    if(_showCrossLines) {
        [self top_showCrossLineLayer];
    }
    [self top_resetBorderLayerPath];

}
- (void)top_showCrossLineLayer {

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(WIDTH(self) / 3.0, 0)];
    [path addLineToPoint: CGPointMake(WIDTH(self) / 3.0, HEIGHT(self))];
    [path moveToPoint:CGPointMake(WIDTH(self) / 3.0 * 2.0, 0)];
    [path addLineToPoint: CGPointMake(WIDTH(self) / 3.0 * 2.0, HEIGHT(self))];
    [path moveToPoint:CGPointMake(0, HEIGHT(self) / 3.0)];
    [path addLineToPoint: CGPointMake(WIDTH(self), HEIGHT(self) / 3.0)];
    [path moveToPoint:CGPointMake(0, HEIGHT(self) / 3.0 * 2.0)];
    [path addLineToPoint: CGPointMake(WIDTH(self), HEIGHT(self) / 3.0 * 2.0)];
    if(!_crossLineLayer) {
        _crossLineLayer = [CAShapeLayer layer];
        [self.layer addSublayer: _crossLineLayer];
    }
    _crossLineLayer.lineWidth = _crossLineWidth;
    _crossLineLayer.strokeColor = _crossLineColor.CGColor;
    _crossLineLayer.path = path.CGPath;

}
- (void)setCrossLineWidth:(CGFloat)crossLineWidth {
    
    _crossLineWidth = crossLineWidth;
    _crossLineLayer.lineWidth = crossLineWidth;
    
}
- (void)setCrossLineColor:(UIColor *)crossLineColor {
    
    _crossLineColor = crossLineColor;
    _crossLineLayer.strokeColor = crossLineColor.CGColor;
    
}
- (void)setShowCrossLines:(BOOL)showCrossLines {
    
    if(_showCrossLines && !showCrossLines) {
        [_crossLineLayer removeFromSuperlayer];
        _crossLineLayer = nil;
    }
    else if(!_showCrossLines && showCrossLines) {
        [self top_showCrossLineLayer];
    }
    _showCrossLines = showCrossLines;

}
- (void)top_createBorderLayer {
    
    if(_borderLayer && _borderLayer.superlayer) {
        [_borderLayer removeFromSuperlayer];
    }
    _borderLayer = [CAShapeLayer layer];
    [self.layer addSublayer: _borderLayer];
    
}
- (void)top_resetBorderLayerPath {
    
    UIBezierPath *layerPath = [UIBezierPath bezierPathWithRect: CGRectMake(_borderWidth / 2.0f, _borderWidth / 2.0f, WIDTH(self) - _borderWidth, HEIGHT(self) - _borderWidth)];
    _borderLayer.lineWidth = _borderWidth;
    _borderLayer.fillColor = nil;
    _borderLayer.path = layerPath.CGPath;
    
}
- (void)setBorderWidth:(CGFloat)borderWidth {
    
    _borderWidth = borderWidth;
    [self top_resetBorderLayerPath];
    
}
- (void)setBorderColor:(UIColor *)borderColor {
    
    _borderColor = borderColor;
    _borderLayer.strokeColor = borderColor.CGColor;
    
}
- (UIView *) hitTest:(CGPoint) point withEvent:(UIEvent *)event {
    
    for(UIView *subView in self.subviews) {
        if(CGRectContainsPoint(subView.frame, point)) {
            return subView;
        }
    }
    if(CGRectContainsPoint(self.bounds, point)) {
        return self;
    }
    return nil;
    
}
@end
@interface TOPImageView()

@property (strong, nonatomic) UIView *cropMaskView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) CornerView *topLeftCorner;
@property (strong, nonatomic) CornerView *topRightCorner;
@property (strong, nonatomic) CornerView *bottomLeftCorner;
@property (strong, nonatomic) CornerView *bottomRightCorner;
@property (strong, nonatomic) CropAreaView *cropAreaView;
@property (strong, nonatomic) UIPanGestureRecognizer *topLeftPan;
@property (strong, nonatomic) UIPanGestureRecognizer *topRightPan;
@property (strong, nonatomic) UIPanGestureRecognizer *bottomLeftPan;
@property (strong, nonatomic) UIPanGestureRecognizer *bottomRightPan;
@property (strong, nonatomic) UIPanGestureRecognizer *cropAreaPan;
@property (strong, nonatomic) UIPinchGestureRecognizer *cropAreaPinch;
@property (assign, nonatomic) CGSize pinchOriSize;
@property (assign, nonatomic) CGPoint cropAreaOriCenter;
@property (assign, nonatomic) CGRect cropAreaOriFrame;
@property (strong, nonatomic) MidLineView *topMidLine;
@property (strong, nonatomic) MidLineView *leftMidLine;
@property (strong, nonatomic) MidLineView *bottomMidLine;
@property (strong, nonatomic) MidLineView *rightMidLine;
@property (strong, nonatomic) UIPanGestureRecognizer *topMidPan;
@property (strong, nonatomic) UIPanGestureRecognizer *bottomMidPan;
@property (strong, nonatomic) UIPanGestureRecognizer *leftMidPan;
@property (strong, nonatomic) UIPanGestureRecognizer *rightMidPan;
@property (assign, nonatomic) CGFloat paddingLeftRight;
@property (assign, nonatomic) CGFloat paddingTopBottom;
@property (assign, nonatomic) CGFloat imageAspectRatio;
@end
@implementation TOPImageView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: frame];
    if(self) {
        [self top_commonInit];
    }
    return self;
    
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder: aDecoder];
    if(self) {
        [self top_commonInit];
    }
    return self;
    
}
- (void)top_commonInit {
    [self top_setUp];
    [self top_createCorners];
    [self top_resetCropAreaOnCornersFrameChanged];
    [self top_bindPanGestures];
}
- (void)dealloc {
    [_cropAreaView removeObserver: self forKeyPath: @"frame"];
    [_cropAreaView removeObserver: self forKeyPath: @"center"];
}
- (void)top_setUp {
    
    _imageView = [[UIImageView alloc]initWithFrame: self.bounds];
    _imageView.contentMode = UIViewContentModeScaleToFill;
    _imageView.userInteractionEnabled = YES;
    _imageAspectRatio = 0;
    [self addSubview: _imageView];
    
    _cropMaskView = [[UIView alloc]initWithFrame: _imageView.bounds];
    _cropMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    _cropMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_imageView addSubview: _cropMaskView];
    
    UIColor *defaultColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor colorWithWhite: 1 alpha: 0.8]];
    _cropAreaBorderLineColor = defaultColor;
    _cropAreaCornerLineColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    _cropAreaBorderLineWidth = 4;
    _cropAreaCornerLineWidth = 6;
    _cropAreaCornerWidth = 30;
    _cropAreaCornerHeight = 30;
    _cropAspectRatio = 0;
    _minSpace = 30;
    _cropAreaCrossLineWidth = 4;
    _cropAreaCrossLineColor = defaultColor;
    _cropAreaMidLineWidth = 40;
    _cropAreaMidLineHeight = 6;
    _cropAreaMidLineColor = defaultColor;
    
    _cropAreaView = [[CropAreaView alloc] init];
    _cropAreaView.borderWidth = _cropAreaBorderLineWidth;
    _cropAreaView.borderColor = _cropAreaBorderLineColor;
    _cropAreaView.crossLineColor = _cropAreaCrossLineColor;
    _cropAreaView.crossLineWidth = _cropAreaCrossLineWidth;
    _cropAreaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_imageView addSubview: _cropAreaView];
    
    [_cropAreaView addObserver: self
                    forKeyPath: @"frame"
                       options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context: NULL];
    [_cropAreaView addObserver: self
                    forKeyPath: @"center"
                       options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context: NULL];
    
}
#pragma mark - PanGesture Bind
- (void)top_bindPanGestures {
    _topLeftPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _topRightPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _bottomLeftPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _bottomRightPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    
    [_topLeftCorner addGestureRecognizer: _topLeftPan];
    [_topRightCorner addGestureRecognizer: _topRightPan];
    [_bottomLeftCorner addGestureRecognizer: _bottomLeftPan];
    [_bottomRightCorner addGestureRecognizer: _bottomRightPan];
}
#pragma mark - PinchGesture CallBack
- (void)handleCropAreaPinch: (UIPinchGestureRecognizer *)pinchGesture {
    switch (pinchGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _pinchOriSize = _cropAreaView.frame.size;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint center = _cropAreaView.center;
            CGFloat cornerMargin = _cropAreaCornerLineWidth - _cropAreaBorderLineWidth;
            CGFloat width = _pinchOriSize.width * pinchGesture.scale;
            CGFloat height = _pinchOriSize.height * pinchGesture.scale;
            CGFloat widthMax = MIN(WIDTH(_imageView) - center.x - cornerMargin, center.x - cornerMargin) * 2;
            CGFloat widthMin = _minSpace + _cropAreaCornerWidth * 2.0 - cornerMargin * 2.0;
            CGFloat heightMax = MIN(HEIGHT(_imageView) - center.y - cornerMargin, center.y - cornerMargin) * 2;
            CGFloat heightMin = _minSpace + _cropAreaCornerWidth * 2.0 - cornerMargin * 2;

            BOOL isMinimum = NO;
            if(_cropAspectRatio > 1) {
                if(height <= heightMin) {
                    height = heightMin;
                    width = height * _cropAspectRatio;
                    isMinimum = YES;
                }
            }
            else {
                if(width <= widthMin) {
                    width = widthMin;
                    height = width / (_cropAspectRatio == 0 ? 1 : _cropAspectRatio);
                    isMinimum = YES;
                }
            }
            if(!isMinimum) {
                CGFloat selfAspectRatio = WIDTH(_imageView) / HEIGHT(_imageView);
                if(_cropAspectRatio == 0) {
                    if(width >= widthMax) {
                        width = MIN(width, WIDTH(_imageView) - 2 * cornerMargin);
                        center.x = center.x > WIDTH(_imageView) / 2.0 ? WIDTH(_imageView) - width / 2.0 - cornerMargin : width / 2.0 + cornerMargin;
                    }
                    if(height > heightMax) {
                        height = MIN(height, HEIGHT(_imageView) - 2 * cornerMargin);
                        center.y = center.y > HEIGHT(_imageView) / 2.0 ? HEIGHT(_imageView) - height / 2.0 - cornerMargin : height / 2.0 + cornerMargin;
                    }

                }
                else if(selfAspectRatio > _cropAspectRatio) {
                    if(height >= heightMax) {
                        height = MIN(height, HEIGHT(_imageView) - 2 * cornerMargin);
                        center.y = center.y > HEIGHT(_imageView) / 2.0 ? HEIGHT(_imageView) - height / 2.0 - cornerMargin : height / 2.0 + cornerMargin;
                    }
                    width = height * _cropAspectRatio;
                    if(width > widthMax) {
                        center.x = center.x > WIDTH(_imageView) / 2.0 ? WIDTH(_imageView) - width / 2.0 - cornerMargin : width / 2.0 + cornerMargin;
                    }
                }
                else {
                    if(width >= widthMax) {
                        width = MIN(width, WIDTH(_imageView) - 2 * cornerMargin);
                        center.x = center.x > WIDTH(_imageView) / 2.0 ? WIDTH(_imageView) - width / 2.0 - cornerMargin : width / 2.0 + cornerMargin;
                    }
                    height = width / _cropAspectRatio;
                    if(height > heightMax) {
                        center.y = center.y > HEIGHT(_imageView) / 2.0 ? HEIGHT(_imageView) - height / 2.0 - cornerMargin : height / 2.0 + cornerMargin;
                    }
                }
            }
            _cropAreaView.bounds = CGRectMake(0, 0, width, height);
            _cropAreaView.center = center;
            [self top_resetCornersOnCropAreaFrameChanged];
            [self top_resetCropAreaOnCornersFrameChanged];
            break;
        }
        default:
            break;
    }
    
}
#pragma mark - PanGesture CallBack
- (void)handleCropAreaPan: (UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _cropAreaOriCenter = _cropAreaView.center;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGesture translationInView: _imageView];
            CGPoint willCenter = CGPointMake(_cropAreaOriCenter.x + translation.x, _cropAreaOriCenter.y + translation.y);
            CGFloat cornerMargin = _cropAreaCornerLineWidth - _cropAreaBorderLineWidth;
            CGFloat centerMinX = WIDTH(_cropAreaView) / 2.0f + cornerMargin;
            CGFloat centerMaxX = WIDTH(_imageView) - WIDTH(_cropAreaView) / 2.0f - cornerMargin;
            CGFloat centerMinY = HEIGHT(_cropAreaView) / 2.0f + cornerMargin;
            CGFloat centerMaxY = HEIGHT(_imageView) - HEIGHT(_cropAreaView) / 2.0f - cornerMargin;
            _cropAreaView.center = CGPointMake(MIN(MAX(centerMinX, willCenter.x), centerMaxX), MIN(MAX(centerMinY, willCenter.y), centerMaxY));
            [self top_resetCornersOnCropAreaFrameChanged];
            break;
        }
        default:
            break;
    }
  
}
- (void)handleMidPan: (UIPanGestureRecognizer *)panGesture {
    self.isChange = YES;
    MidLineView *midLineView = (MidLineView *)panGesture.view;
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _cropAreaOriFrame = _cropAreaView.frame;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGesture translationInView: _cropAreaView];
            switch (midLineView.type) {
                case TKMidLineTypeTop: {
                    CGFloat minHeight = _minSpace + (_cropAreaCornerHeight - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxHeight = CGRectGetMaxY(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth);
                    CGFloat willHeight = MIN(MAX(minHeight, CGRectGetHeight(_cropAreaOriFrame) - translation.y), maxHeight);
                    CGFloat deltaY = willHeight - CGRectGetHeight(_cropAreaOriFrame);
                    _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), CGRectGetMinY(_cropAreaOriFrame) - deltaY, CGRectGetWidth(_cropAreaOriFrame), willHeight);
                    break;
                }
                case TKMidLineTypeBottom: {
                    CGFloat minHeight = _minSpace + (_cropAreaCornerHeight - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxHeight = HEIGHT(_imageView) - CGRectGetMinY(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth);
                    CGFloat willHeight = MIN(MAX(minHeight, CGRectGetHeight(_cropAreaOriFrame) + translation.y), maxHeight);
                    _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), CGRectGetMinY(_cropAreaOriFrame), CGRectGetWidth(_cropAreaOriFrame), willHeight);
                    break;
                }
                case TKMidLineTypeLeft: {
                    CGFloat minWidth = _minSpace + (_cropAreaCornerWidth - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxWidth = CGRectGetMaxX(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth);
                    CGFloat willWidth = MIN(MAX(minWidth, CGRectGetWidth(_cropAreaOriFrame) - translation.x), maxWidth);
                    CGFloat deltaX = willWidth - CGRectGetWidth(_cropAreaOriFrame);
                    _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame) - deltaX, CGRectGetMinY(_cropAreaOriFrame), willWidth, CGRectGetHeight(_cropAreaOriFrame));
                    break;
                }
                case TKMidLineTypeRight: {
                    CGFloat minWidth = _minSpace + (_cropAreaCornerWidth - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxWidth = WIDTH(_imageView) - CGRectGetMinX(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth);
                    CGFloat willWidth = MIN(MAX(minWidth, CGRectGetWidth(_cropAreaOriFrame) + translation.x), maxWidth);
                    _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), CGRectGetMinY(_cropAreaOriFrame), willWidth, CGRectGetHeight(_cropAreaOriFrame));
                    break;
                }
                default:
                    break;
            }
            [self top_resetCornersOnCropAreaFrameChanged];
            break;
        }
        case UIGestureRecognizerStateEnded:
            break;
        default:
            break;
    }
}
- (void)handleCornerPan: (UIPanGestureRecognizer *)panGesture {
    self.isChange = self;
    CornerView *panView = (CornerView *)panGesture.view;
    CornerView *relativeViewX = panView.relativeViewX;
    CornerView *relativeViewY = panView.relativeViewY;
    CGPoint locationInImageView = [panGesture locationInView: _imageView];
    NSInteger xFactor = MINX(relativeViewY) > MINX(panView) ? -1 : 1;
    NSInteger yFactor = MINY(relativeViewX) > MINY(panView) ? -1 : 1;
    
    CGFloat spaceX = MIN(MAX((locationInImageView.x - relativeViewY.center.x) * xFactor + _cropAreaCornerWidth - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2, _minSpace + _cropAreaCornerWidth * 2 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2), xFactor < 0 ? relativeViewY.center.x + _cropAreaCornerWidth / 2.0 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2 : WIDTH(_imageView) - relativeViewY.center.x + _cropAreaCornerWidth / 2.0 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2);
    
    CGFloat spaceY = MIN(MAX((locationInImageView.y - relativeViewX.center.y) * yFactor + _cropAreaCornerHeight - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2, _minSpace + _cropAreaCornerHeight * 2 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2), yFactor < 0 ? relativeViewX.center.y + _cropAreaCornerHeight / 2.0 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2 : HEIGHT(_imageView) - relativeViewX.center.y + _cropAreaCornerHeight / 2.0 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2);
    
    if(_cropAspectRatio > 0) {
        if(_cropAspectRatio >= 1) {
            spaceY = MAX(spaceX / _cropAspectRatio, _minSpace + _cropAreaCornerHeight * 2 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2);
            spaceX = spaceY * _cropAspectRatio;
        }
        else {
            spaceX = MAX(spaceY * _cropAspectRatio, _minSpace + _cropAreaCornerWidth * 2 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2);
            spaceY = spaceX / _cropAspectRatio;
        }
    }

    CGFloat centerX = (spaceX - _cropAreaCornerWidth + _cropAreaCornerLineWidth * 2 -  _cropAreaBorderLineWidth * 2) * xFactor + relativeViewY.center.x;
    CGFloat centerY = (spaceY - _cropAreaCornerHeight + _cropAreaCornerLineWidth * 2 - _cropAreaBorderLineWidth * 2) * yFactor + relativeViewX.center.y;
    panView.center = CGPointMake(MIN(MAX(_cropAreaCornerWidth / 2.0, centerX), WIDTH(_imageView) - _cropAreaCornerWidth / 2.0), MIN(MAX(_cropAreaCornerHeight / 2.0, centerY), HEIGHT(_imageView) - _cropAreaCornerHeight / 2.0));
    relativeViewX.frame = CGRectMake(MINX(panView), MINY(relativeViewX), WIDTH(relativeViewX), HEIGHT(relativeViewX));
    relativeViewY.frame = CGRectMake(MINX(relativeViewY), MINY(panView), WIDTH(relativeViewY), HEIGHT(relativeViewY));
    [self top_resetCropAreaOnCornersFrameChanged];
    [self top_resetCropTransparentArea];
}
#pragma mark - Position/Resize Corners&CropArea
- (void)top_resetCornersOnCropAreaFrameChanged {
    _topLeftCorner.frame = CGRectMake(MINX(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth, MINY(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth, _cropAreaCornerWidth, _cropAreaCornerHeight);
    _topRightCorner.frame = CGRectMake(MAXX(_cropAreaView) - _cropAreaCornerWidth + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, MINY(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth, _cropAreaCornerWidth, _cropAreaCornerHeight);
    _bottomLeftCorner.frame = CGRectMake(MINX(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth, MAXY(_cropAreaView) - _cropAreaCornerHeight + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, _cropAreaCornerWidth, _cropAreaCornerHeight);
    _bottomRightCorner.frame = CGRectMake(MAXX(_cropAreaView) - _cropAreaCornerWidth + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, MAXY(_cropAreaView) - _cropAreaCornerHeight + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, _cropAreaCornerWidth, _cropAreaCornerHeight);
}

- (void)top_resetCropAreaOnCornersFrameChanged {
    _cropAreaView.frame = CGRectMake(MINX(_topLeftCorner) + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, MINY(_topLeftCorner) + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, MAXX(_topRightCorner) - MINX(_topLeftCorner) - 2 * _cropAreaCornerLineWidth + 2 * _cropAreaBorderLineWidth, MAXY(_bottomLeftCorner) - MINY(_topLeftCorner) - 2 * _cropAreaCornerLineWidth + 2 * _cropAreaBorderLineWidth);
}
- (void)top_resetCropTransparentArea {

    UIBezierPath *path = [UIBezierPath bezierPathWithRect: _imageView.bounds];
    UIBezierPath *clearPath = [[UIBezierPath bezierPathWithRect: _cropAreaView.frame] bezierPathByReversingPath];
    [path appendPath: clearPath];
    CAShapeLayer *shapeLayer = (CAShapeLayer *)_cropMaskView.layer.mask;
    if(!shapeLayer) {
        shapeLayer = [CAShapeLayer layer];
        [_cropMaskView.layer setMask: shapeLayer];
    }
    shapeLayer.path = path.CGPath;

}
- (void)top_resetCornersOnSizeChanged {
    [_topLeftCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    [_topRightCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    [_bottomLeftCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    [_bottomRightCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
}
- (void)top_createCorners {
    
    _topLeftCorner = [[CornerView alloc]initWithFrame: CGRectMake(0, 0, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor:_cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _topLeftCorner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    _topLeftCorner.cornerPosition = TKCropAreaCornerPositionTopLeft;

    _topRightCorner = [[CornerView alloc]initWithFrame: CGRectMake(WIDTH(_imageView) -  _cropAreaCornerWidth, 0, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor: _cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _topRightCorner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    _topRightCorner.cornerPosition = TKCropAreaCornerPositionTopRight;
    
    _bottomLeftCorner = [[CornerView alloc]initWithFrame: CGRectMake(0, HEIGHT(_imageView) -  _cropAreaCornerHeight, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor: _cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _bottomLeftCorner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    _bottomLeftCorner.cornerPosition = TKCropAreaCornerPositionBottomLeft;
    
    _bottomRightCorner = [[CornerView alloc]initWithFrame: CGRectMake(WIDTH(_imageView) - _cropAreaCornerWidth, HEIGHT(_imageView) -  _cropAreaCornerHeight, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor: _cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _bottomRightCorner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    _bottomRightCorner.cornerPosition = TKCropAreaCornerPositionBottomRight;
    
    _topLeftCorner.relativeViewX = _bottomLeftCorner;
    _topLeftCorner.relativeViewY = _topRightCorner;
    
    _topRightCorner.relativeViewX = _bottomRightCorner;
    _topRightCorner.relativeViewY = _topLeftCorner;
    
    _bottomLeftCorner.relativeViewX = _topLeftCorner;
    _bottomLeftCorner.relativeViewY = _bottomRightCorner;
    
    _bottomRightCorner.relativeViewX = _topRightCorner;
    _bottomRightCorner.relativeViewY = _bottomLeftCorner;

    [_imageView addSubview: _topLeftCorner];
    [_imageView addSubview: _topRightCorner];
    [_imageView addSubview: _bottomLeftCorner];
    [_imageView addSubview: _bottomRightCorner];
}
- (void)top_createMidLines {
    
    _topMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _topMidLine.type = TKMidLineTypeTop;
    
    _bottomMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _bottomMidLine.type = TKMidLineTypeBottom;
    
    _leftMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _leftMidLine.type = TKMidLineTypeLeft;
    
    _rightMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _rightMidLine.type = TKMidLineTypeRight;
    
    _topMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_topMidLine addGestureRecognizer: _topMidPan];
    
    _bottomMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_bottomMidLine addGestureRecognizer: _bottomMidPan];

    _leftMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_leftMidLine addGestureRecognizer: _leftMidPan];

    _rightMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_rightMidLine addGestureRecognizer: _rightMidPan];

    [_cropAreaView addSubview: _topMidLine];
    [_cropAreaView addSubview: _bottomMidLine];
    [_cropAreaView addSubview: _leftMidLine];
    [_cropAreaView addSubview: _rightMidLine];
    
}
- (void)top_removeMidLines {

    [_topMidLine removeFromSuperview];
    [_bottomMidLine removeFromSuperview];
    [_leftMidLine removeFromSuperview];
    [_rightMidLine removeFromSuperview];
    
    _topMidLine = nil;
    _bottomMidLine = nil;
    _leftMidLine = nil;
    _rightMidLine = nil;
    
}
- (void)top_resetMidLines {
    CGFloat lineMargin = _cropAreaMidLineHeight / 2.0 - _cropAreaBorderLineWidth;
    _topMidLine.frame = CGRectMake((WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH) / 2.0, - MID_LINE_INTERACT_HEIGHT / 2.0 - lineMargin+_cropAreaMidLineHeight, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    _bottomMidLine.frame = CGRectMake((WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH) / 2.0, HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT / 2.0 + lineMargin-_cropAreaMidLineHeight, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    _leftMidLine.frame = CGRectMake(- MID_LINE_INTERACT_WIDTH / 2.0 - lineMargin+_cropAreaMidLineHeight, (HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT) / 2.0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    _rightMidLine.frame = CGRectMake(WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH / 2.0 + lineMargin-_cropAreaMidLineHeight, (HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT) / 2.0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
}
- (void)top_resetImageView {
    if(_imageAspectRatio > 1) {
        _paddingLeftRight = 0;
        _paddingTopBottom = floor((HEIGHT(self) - WIDTH(self) / _imageAspectRatio) / 2.0);
        _imageView.frame = CGRectMake(0, _paddingTopBottom, WIDTH(self), floor(WIDTH(self) / _imageAspectRatio));
    }
    else {
        _paddingTopBottom = 0;
        _paddingLeftRight = floor((WIDTH(self) - HEIGHT(self) * _imageAspectRatio) / 2.0);
        _imageView.frame = CGRectMake(_paddingLeftRight, 0, floor(HEIGHT(self) * _imageAspectRatio), HEIGHT(self));
    }
}
#pragma mark - Setter & Getters
- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    _cropMaskView.backgroundColor = maskColor;
}
- (void)setToCropImage:(UIImage *)toCropImage {
    _toCropImage = toCropImage;
    _imageAspectRatio = toCropImage.size.width / toCropImage.size.height;
    _imageView.image = toCropImage;
    [self top_resetImageView];
}
- (void)setNeedScaleCrop:(BOOL)needScaleCrop {
    if(!_needScaleCrop && needScaleCrop) {
        _cropAreaPinch = [[UIPinchGestureRecognizer alloc]initWithTarget: self action:@selector(handleCropAreaPinch:)];
        [_cropAreaView addGestureRecognizer: _cropAreaPinch];
    }
    else if(_needScaleCrop && !needScaleCrop){
        [_cropAreaView removeGestureRecognizer: _cropAreaPinch];
        _cropAreaPinch = nil;
    }
    _needScaleCrop = needScaleCrop;
}
- (void)setCropAreaCrossLineWidth:(CGFloat)cropAreaCrossLineWidth {
    _cropAreaCrossLineWidth = cropAreaCrossLineWidth;
    _cropAreaView.crossLineWidth = cropAreaCrossLineWidth;
}
- (void)setCropAreaCrossLineColor:(UIColor *)cropAreaCrossLineColor {
    _cropAreaCrossLineColor = cropAreaCrossLineColor;
    _cropAreaView.crossLineColor = cropAreaCrossLineColor;
}
- (void)setCropAreaMidLineWidth:(CGFloat)cropAreaMidLineWidth {
    _cropAreaMidLineWidth = cropAreaMidLineWidth;
    _topMidLine.lineWidth = cropAreaMidLineWidth;
    _bottomMidLine.lineWidth = cropAreaMidLineWidth;
    _leftMidLine.lineWidth = cropAreaMidLineWidth;
    _rightMidLine.lineWidth = cropAreaMidLineWidth;
    if(_showMidLines) {
        [self top_resetMidLines];
    }
}
- (void)setCropAreaMidLineHeight:(CGFloat)cropAreaMidLineHeight {
    _cropAreaMidLineHeight = cropAreaMidLineHeight;
    _topMidLine.lineHeight = cropAreaMidLineHeight;
    _bottomMidLine.lineHeight = cropAreaMidLineHeight;
    _leftMidLine.lineHeight = cropAreaMidLineHeight;
    _rightMidLine.lineHeight = cropAreaMidLineHeight;
    if(_showMidLines) {
        [self top_resetMidLines];
    }
}
- (void)setCropAreaMidLineColor:(UIColor *)cropAreaMidLineColor {
    _cropAreaMidLineColor = cropAreaMidLineColor;
    _topMidLine.lineColor = cropAreaMidLineColor;
    _bottomMidLine.lineColor = cropAreaMidLineColor;
    _leftMidLine.lineColor = cropAreaMidLineColor;
    _rightMidLine.lineColor = cropAreaMidLineColor;
}
- (void)setCropAreaBorderLineWidth:(CGFloat)cropAreaBorderLineWidth {
    _cropAreaBorderLineWidth = cropAreaBorderLineWidth;
    _cropAreaView.borderWidth = cropAreaBorderLineWidth;
    [self top_resetCropAreaOnCornersFrameChanged];
}
- (void)setCropAreaBorderLineColor:(UIColor *)cropAreaBorderLineColor {
    _cropAreaBorderLineColor = cropAreaBorderLineColor;
    _cropAreaView.borderColor = cropAreaBorderLineColor;
}
- (void)setCropAreaCornerLineColor:(UIColor *)cropAreaCornerLineColor {
    _cropAreaCrossLineColor = cropAreaCornerLineColor;
    _topLeftCorner.lineColor = cropAreaCornerLineColor;
    _topRightCorner.lineColor = cropAreaCornerLineColor;
    _bottomLeftCorner.lineColor = cropAreaCornerLineColor;
    _bottomRightCorner.lineColor = cropAreaCornerLineColor;
}
- (void)setCropAreaCornerLineWidth:(CGFloat)cropAreaCornerLineWidth {
    _cropAreaCornerLineWidth = cropAreaCornerLineWidth;
    _topLeftCorner.lineWidth = cropAreaCornerLineWidth;
    _topRightCorner.lineWidth = cropAreaCornerLineWidth;
    _bottomLeftCorner.lineWidth = cropAreaCornerLineWidth;
    _bottomRightCorner.lineWidth = cropAreaCornerLineWidth;
}
- (void)setCropAreaCornerWidth:(CGFloat)cropAreaCornerWidth {
    _cropAreaCornerWidth = cropAreaCornerWidth;
    [self top_resetCornersOnSizeChanged];
    [self top_resetCropAreaOnCornersFrameChanged];
}
- (void)setCropAreaCornerHeight:(CGFloat)cropAreaCornerHeight {
    _cropAreaCornerHeight = cropAreaCornerHeight;
    [self top_resetCornersOnSizeChanged];
    [self top_resetCropAreaOnCornersFrameChanged];
}
- (void)setCropAspectRatio:(CGFloat)cropAspectRatio {
    if(_cropAspectRatio == cropAspectRatio) return;
    _cropAspectRatio = MAX(cropAspectRatio, 0);
    CGFloat cornerMargin = _cropAreaCornerLineWidth - _cropAreaBorderLineWidth;
    CGFloat selfAspectRatio = WIDTH(_imageView) / HEIGHT(_imageView);
    CGFloat width, height;
    if(_cropAspectRatio == 0) {
        width = WIDTH(_imageView) - 2 * cornerMargin;
        height = HEIGHT(_imageView) - 2 * cornerMargin;
        if(_showMidLines) {
            [self top_createMidLines];
            [self top_resetMidLines];
        }
    }
    else {
        [self top_removeMidLines];
        if(selfAspectRatio > _cropAspectRatio) {
            height = HEIGHT(_imageView) - 2 * cornerMargin;
            width = height * _cropAspectRatio;
        }
        else {
            width = WIDTH(_imageView) - 2 * cornerMargin;
            height = width / _cropAspectRatio;
        }
    }
    _cropAreaView.frame = CGRectMake((WIDTH(_imageView) - width) / 2.0, (HEIGHT(_imageView) - height) / 2.0, width, height);
    [self top_resetCornersOnCropAreaFrameChanged];
    [self top_resetCropTransparentArea];

}
- (void)setShowMidLines:(BOOL)showMidLines {
    
    if(_cropAspectRatio == 0) {
        if(!_showMidLines && showMidLines) {
            [self top_createMidLines];
            [self top_resetMidLines];
        }
        else if(_showMidLines && !showMidLines) {
            [self top_removeMidLines];
        }
    }
    _showMidLines = showMidLines;
    
}
- (void)setShowCrossLines:(BOOL)showCrossLines {

    _showCrossLines = showCrossLines;
    _cropAreaView.showCrossLines = _showCrossLines;
    
}
- (void)setFrame:(CGRect)frame {
    
    [super setFrame: frame];
    [self top_resetImageView];
    
}
- (void)setCenter:(CGPoint)center {
    
    [super setCenter: center];
    [self top_resetImageView];
    
}
#pragma mark - KVO CallBack
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if([object isEqual: _cropAreaView]) {
        if(_showMidLines){
            [self top_resetMidLines];
        }
        [self top_resetCropTransparentArea];
    }
}
#pragma Instance Methods
- (UIImage *)top_currentCroppedImage {
    if (self.isChange) {
        CGFloat scaleFactor = WIDTH(_imageView) / _toCropImage.size.width;
        return [_toCropImage top_imageAtRect: CGRectMake((MINX(_cropAreaView) + _cropAreaBorderLineWidth) / scaleFactor, (MINY(_cropAreaView) + _cropAreaBorderLineWidth) / scaleFactor, (WIDTH(_cropAreaView) - 2 * _cropAreaBorderLineWidth) / scaleFactor, (HEIGHT(_cropAreaView) - 2 * _cropAreaBorderLineWidth) / scaleFactor)];
    }else{
        return self.toCropImage;
    }
}

- (CGRect)top_currentCroppedImageRect{
    CGFloat scaleFactor = WIDTH(_imageView) / _toCropImage.size.width;
    return CGRectMake((MINX(_cropAreaView) + _cropAreaBorderLineWidth) / scaleFactor, (MINY(_cropAreaView) + _cropAreaBorderLineWidth) / scaleFactor, (WIDTH(_cropAreaView) - 2 * _cropAreaBorderLineWidth) / scaleFactor, (HEIGHT(_cropAreaView) - 2 * _cropAreaBorderLineWidth) / scaleFactor);
}
@end


