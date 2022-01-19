#define kCameraToolsViewHeight 128 * (TOPScreenHeight / 667.)
#define DistancePerSecond   3
#define CodeScanReaderW (TOPScreenWidth*3)/5.0

#import "TOPCodeReaderView.h"
#import "TOPQRCodeReader.h"
#import "TOPQRCodeReaderDelegate.h"
@interface TOPCodeReaderView(){
    BOOL canAnimate;
    NSInteger animationCount;
    CAShapeLayer *cropLayer;//遮层

}
@property (strong, nonatomic) TOPQRCodeReader * codeReader;

@property (strong,nonatomic) UIImageView *leftTopFrame;
@property (strong,nonatomic) UIImageView *rightTopFrame;
@property (strong,nonatomic) UIImageView *leftBottomFrame;
@property (strong,nonatomic) UIImageView *rightBottomFrame;

@property (retain,nonatomic) UIImageView *line;
@property (assign, nonatomic) CGFloat imageX;
@property (assign, nonatomic) CGFloat imageY;
@property (assign, nonatomic) BOOL isReset;

@property (assign, nonatomic) CGFloat scanWidth;
@property (assign, nonatomic) CGFloat scanHeight;
@end
@implementation TOPCodeReaderView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self top_setupUI];
        [self setupCodeReader];
        _isReset = YES;
    }
    return self;
}

- (void)top_setupUI{
    _imageX = (TOPScreenWidth-CodeScanReaderW)/2;
    _imageY = (TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight-CodeScanReaderW)/2;
    _scanWidth = CodeScanReaderW;
    self.scanHeight =  CodeScanReaderW;
    [self initView];
}

- (void)setupCodeReader{
    _codeReader = [TOPQRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,
                                                                AVMetadataObjectTypeEAN13Code,
                                                                AVMetadataObjectTypeEAN8Code,
                                                                AVMetadataObjectTypeUPCECode,
                                                                AVMetadataObjectTypeCode39Code,
                                                                AVMetadataObjectTypeCode39Mod43Code,
                                                                AVMetadataObjectTypeCode93Code,
                                                                AVMetadataObjectTypeCode128Code,
                                                                AVMetadataObjectTypePDF417Code]];
    [self.layer insertSublayer:_codeReader.previewLayer atIndex:0];
    [_codeReader.previewLayer setFrame:CGRectMake(0,0, TOPScreenWidth, TOPScreenHeight - kCameraToolsViewHeight-TOPNavBarAndStatusBarHeight-TOPBottomSafeHeight)];
    if ([_codeReader.previewLayer.connection isVideoOrientationSupported]) {
      UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

      _codeReader.previewLayer.connection.videoOrientation = [TOPQRCodeReader videoOrientationFromInterfaceOrientation:orientation];
    }
    WS(weakSelf);
    [_codeReader setCompletionWithBlock:^(NSString *resultAsString) {
        NSLog(@"resultAsString==%@",resultAsString);
        if (resultAsString.length>0) {
            if (weakSelf.codeReaderFinish) {
                weakSelf.codeReaderFinish(resultAsString);
            }
        }
    }];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self configureCropRect:CGRectMake(_imageX, _imageY, _scanWidth, _scanHeight)];
    self.leftTopFrame.frame = CGRectMake(_imageX, _imageY, 24, 24);
    self.leftBottomFrame.frame = CGRectMake(_imageX, _scanHeight + _imageY - 24, 24, 24);
    self.rightTopFrame.frame = CGRectMake(self.width - _imageX - 24, _imageY, 24, 24);
    self.rightBottomFrame.frame = CGRectMake(self.width - _imageX - 24, _scanHeight + _imageY - 24, 24, 24);
}

- (void)initView{
    canAnimate = NO;
    animationCount = 0;
    
    self.leftTopFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"top_camera_frame_left_top"]];
    self.leftBottomFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"top_camera_frame_left_bottom"]];
    self.rightTopFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"top_camera_frame_right_top"]];
    self.rightBottomFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"top_camera_frame_right_bottom"]];
    
    [self addSubview:self.leftTopFrame];
    [self addSubview:self.leftBottomFrame];
    [self addSubview:self.rightTopFrame];
    [self addSubview:self.rightBottomFrame];
    [self addSubview:self.line];
}

//设置扫描区域框
- (void)configureCropRect:(CGRect)cropRect {
    if (_isReset) {
        cropLayer = [[CAShapeLayer alloc]init];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, nil, cropRect);
        CGPathAddRect(path, nil, self.bounds);
        
        cropLayer.fillRule = kCAFillRuleEvenOdd;
        cropLayer.path = path;
        cropLayer.fillColor = RGBA(0, 0, 0, 0.2).CGColor;
        [cropLayer setNeedsDisplay];
        [self.layer addSublayer:cropLayer];
        _isReset = NO;
        CGPathRelease(path);
    }
}

- (void)animationAction{
    [self.line.layer removeAllAnimations];
    [UIView animateWithDuration:1.4 delay:0.01 options:UIViewAnimationOptionRepeat animations:^{
        CGRect rect = self.line.frame;
        rect.origin.y += CodeScanReaderW-2;
        self.line.frame = rect;
    } completion:^(BOOL finished) {
        CGRect rect1 = self.line.frame;
        rect1.origin.y -= CodeScanReaderW-2;
        self.line.frame = rect1;
    }];
}
#pragma mark LazyLoad
- (UIImageView *)line{
    if (!_line) {
        _line = [[UIImageView alloc] initWithFrame:(CGRect){self.imageX+10, self.imageY , self.width - self.imageX * 2-20,2}];
        _line.backgroundColor = TOPAPPGreenColor;
    }
    return _line;
}
- (void)startRun{
    [_codeReader startScanning];
}

- (void)stopRun{
    [_codeReader top_stopScanning];
}

- (void)toggleTorch{
    [_codeReader toggleTorch];
}

- (void)toggleTorchClose{
    [_codeReader toggleTorchClose];
}

@end
