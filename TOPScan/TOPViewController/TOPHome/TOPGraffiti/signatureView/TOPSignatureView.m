#import "TOPSignatureView.h"

#define SCREEN_HEIGHT  [[UIScreen mainScreen] bounds].size.width
#define IS_IPHONE_6_PLUS   SCREEN_HEIGHT > 667

@implementation TOPSignatureView
void ProviderReleaseData (void *info, const void *data, size_t size)
{
    free((void*)data);
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        minX = minY = maxX = maxY = -1;

        _move = CGPointMake(0, 0);
        _start = CGPointMake(0, 0);
        _lineWidth = 3;
        _color = [UIColor blackColor];
        _pathArray = [NSMutableArray array];
        _enableDrawing = YES;
        _beingDrawing = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawPicture:context];
}

- (void)drawPicture:(CGContextRef)context {
    for (NSArray * attribute in _pathArray) {
        if (attribute.count>2) {
            CGPathRef pathRef = (__bridge CGPathRef)(attribute[0]);
            CGContextAddPath(context, pathRef);
            [attribute[1] setStroke];
            CGContextSetLineWidth(context, [attribute[2] floatValue]);
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            CGContextDrawPath(context, kCGPathStroke);
        }
    }
    self.beingDrawing = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.addDrawPathBlock) {
        self.addDrawPathBlock();
    }
    if (self.touchBeginBlock) {
        self.touchBeginBlock();
    }
    UITouch *touch = [touches anyObject];
    _path = CGPathCreateMutable();
    NSArray *attributeArry = @[(__bridge id)(_path),_color,[NSNumber numberWithFloat:_lineWidth]];
    [_pathArray addObject:attributeArry];
    _start = [touch locationInView:self];
    CGPoint startPoint =_start;
    if (minX == -1) {
        minX = startPoint.x;
    }
    if (maxX == -1) {
        maxX = startPoint.x;
    }
    if (minY == -1) {
        minY = startPoint.y;
    }
    if (maxY == -1) {
        maxY = startPoint.y;
    }
    CGPathMoveToPoint(_path, NULL,_start.x, _start.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _isAlreadySignture = YES;
    if (self.beingDrawing) {
        return;
    }
    CGPathRelease(_path);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _move = [touch locationInView:self];
    CGPoint touchPoint = _move;
    maxX = maxX > touchPoint.x ? maxX : touchPoint.x;
    minX = minX < touchPoint.x ? minX : touchPoint.x;
    maxY = maxY > touchPoint.y ? maxY : touchPoint.y;
    minY = minY < touchPoint.y ? minY : touchPoint.y;
    CGPathAddLineToPoint(_path, NULL, _move.x, _move.y);
    self.beingDrawing = YES;
    [self setNeedsDisplay];
}


- (UIImage *)getDrawingImg {
    minX = minX <= 0 ? 0 : minX;
    minY = minY <= 0 ? 0 : minY;
    maxX = maxX >= self.bounds.size.width ? self.bounds.size.width : maxX;
    maxY = maxY >= self.bounds.size.height ? self.bounds.size.height : maxY;
    float width = maxX - minX > 5 ? maxX - minX : 5;
    float height = maxY - minY > 5 ? maxY - minY : 5;
    minX = minX - 3;
    minY = minY - 3;
    width = width + 5;
    height = height + 5;
    CGFloat times = [UIScreen mainScreen].scale;

    CGRect rect = CGRectMake(minX*times, minY*times, width*times, height*times);
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    [self.layer drawInContext:UIGraphicsGetCurrentContext()];
    UIImage *signatureImage = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef newImageRef = CGImageCreateWithImageInRect([signatureImage CGImage], rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

- (void)setEnableDrawing:(BOOL)enableDrawing {
    _enableDrawing = enableDrawing;
    self.userInteractionEnabled = enableDrawing;
}
-(void)undo
{
    if (self.pathArray.count) {
        [self.reDoArray addObject:self.pathArray.lastObject];
        [_pathArray removeLastObject];
        if (_pathArray.count <=0) {
            _isAlreadySignture = NO;

        }
        [self setNeedsDisplay];
    }
}

#pragma mark -- 恢复
- (void)redo {
    if (self.reDoArray.count) {
        [self.pathArray addObject:self.reDoArray.lastObject];
        [self.reDoArray removeLastObject];
        [self setNeedsDisplay];
    }
}
-(void)clear
{
    [_pathArray removeAllObjects];
    _isAlreadySignture = NO;

    [self setNeedsDisplay];
}

- (NSMutableArray *)reDoArray {
    if (!_reDoArray) {
        _reDoArray = [[NSMutableArray alloc] init];
    }
    return _reDoArray;
}

@end
