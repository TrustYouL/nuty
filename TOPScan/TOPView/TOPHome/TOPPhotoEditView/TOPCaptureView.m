#import "TOPCaptureView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Resize.h"
@interface TOPCaptureView ()<UIGestureRecognizerDelegate,AVCapturePhotoCaptureDelegate>
{
    BOOL _isflashOn;
    CGFloat _effectiveScale;
    CGFloat _beginGestureScale;
}
@property (nonatomic,strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic,strong) AVCaptureStillImageOutput *imageOutPut;
@property (nonatomic,strong) UIView *focusView;
@property (nonatomic,strong) UIView *lineOneH;
@property (nonatomic,strong) UIView *lineTwoH;
@property (nonatomic,strong) UIView *lineOneV;
@property (nonatomic,strong) UIView *lineTwoV;
@property (nonatomic,strong) CMMotionManager  *cmmotionManager;
@property (nonatomic,assign) UIDeviceOrientation orientation;
@end

@implementation TOPCaptureView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
                 WithDelegate:(id<TOPCaptureViewDelegate>)delegate{
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        self.backgroundColor = [UIColor whiteColor];
        [self top_commonInit];
    }
    return self;
}
- (UIView *)lineOneV{
    if (!_lineOneV) {
        _lineOneV = [[UIView alloc]initWithFrame:CGRectMake(0, (self.frame.size.height-2)/3,TOPScreenWidth, 1)];
        _lineOneV.backgroundColor = RGBA(255, 255, 255, 0.5);
        _lineOneV.layer.shadowColor = [UIColor blackColor].CGColor;
        _lineOneV.layer.shadowOffset = CGSizeMake(0, 0);
        _lineOneV.layer.shadowOpacity = 1;
    }
    return _lineOneV;
}

- (UIView *)lineTwoV{
    if (!_lineTwoV) {
        _lineTwoV = [[UIView alloc]initWithFrame:CGRectMake(0, ((self.frame.size.height-2)/3)*2, TOPScreenWidth, 1)];
        _lineTwoV.backgroundColor = RGBA(255, 255, 255, 0.5);
        _lineTwoV.layer.shadowColor = [UIColor blackColor].CGColor;
        _lineTwoV.layer.shadowOffset = CGSizeMake(0, 0);
        _lineTwoV.layer.shadowOpacity = 1;
    }
    return _lineTwoV;
}

- (UIView *)lineOneH{
    if (!_lineOneH) {
        _lineOneH = [[UIView alloc]initWithFrame:CGRectMake((self.frame.size.width-2)/3, 0, 1, self.frame.size.height)];
        _lineOneH.backgroundColor = RGBA(255, 255, 255, 0.5);
        _lineOneH.layer.shadowColor = [UIColor blackColor].CGColor;
        _lineOneH.layer.shadowOffset = CGSizeMake(0, 0);
        _lineOneH.layer.shadowOpacity = 1;
    }
    return _lineOneH;
}

- (UIView *)lineTwoH{
    if (!_lineTwoH) {
        _lineTwoH = [[UIView alloc]initWithFrame:CGRectMake(((self.frame.size.width-2)/3)*2, 0, 1, self.frame.size.height)];
        _lineTwoH.backgroundColor = RGBA(255, 255, 255, 0.5);
        _lineTwoH.layer.shadowColor = [UIColor blackColor].CGColor;
        _lineTwoH.layer.shadowOffset = CGSizeMake(0, 0);
        _lineTwoH.layer.shadowOpacity = 1;
    }
    return _lineTwoH;
}

- (CMMotionManager *)cmmotionManager{
    if (_cmmotionManager == nil) {
        _cmmotionManager = [[CMMotionManager alloc]init];
    }
    return _cmmotionManager;
}
- (AVCaptureDevice *)captureDevice{
    if (_captureDevice == nil) {
        //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _captureDevice;
}
- (AVCaptureDeviceInput *)captureDeviceInput{
    if (_captureDeviceInput == nil) {
        //使用设备初始化输入
        _captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.captureDevice
                                                                    error:nil];
    }
    return _captureDeviceInput;
}
- (AVCaptureStillImageOutput *)imageOutPut{
    if (_imageOutPut == nil) {
        //生成输出对象
        _imageOutPut = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *myOutputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecTypeJPEG,AVVideoCodecKey,nil];
        [_imageOutPut setOutputSettings:myOutputSettings];
    }
    return _imageOutPut;
}
- (AVCaptureVideoPreviewLayer *)capturePreviewLayer{
    if (_capturePreviewLayer == nil) {
        _capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
        _capturePreviewLayer.backgroundColor = [UIColor blackColor].CGColor;
        CGRect layerRect = [[self layer] bounds];
        _capturePreviewLayer.frame = CGRectMake(0, 0, self.width, self.height);
        [_capturePreviewLayer setBounds:layerRect];
        [_capturePreviewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
        _capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _capturePreviewLayer.connection.videoOrientation = [self top_videoOrientationFromCurrentDeviceOrientation];
    }
    return _capturePreviewLayer;
}

- (AVCaptureVideoOrientation) top_videoOrientationFromCurrentDeviceOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationUnknown:
            return AVCaptureVideoOrientationPortrait;
    }
    return AVCaptureVideoOrientationPortrait;
}

- (UIView *)focusView
{
    if (_focusView == nil) {
        _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        _focusView.layer.borderWidth = 1.0;
        _focusView.layer.borderColor =[UIColor greenColor].CGColor;
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.hidden = YES;
    }
    return _focusView;
}
- (AVCaptureSession *)captureSession
{
    if (_captureSession == nil) {
        //生成会话，用来结合输入输出
        _captureSession = [[AVCaptureSession alloc]init];
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
            _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        }
        if ([_captureSession canAddInput:self.captureDeviceInput]) {
            [_captureSession addInput:self.captureDeviceInput];
        }
        if ([_captureSession canAddOutput:self.imageOutPut]) {
            [_captureSession addOutput:self.imageOutPut];
        }
    }
    return _captureSession;
}

- (void)top_commonInit
{
    _effectiveScale = 1.0;
    _beginGestureScale = 1.0;
    [self top_customCamera];
    [self addSubview:self.focusView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_focusGesture:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
    
    UIPinchGestureRecognizer *pich = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(top_handlePinchGesture:)];
    [self addGestureRecognizer:pich];
}

- (void)top_cameraLineShowState:(BOOL)isShow{
    if (isShow) {
        [self addSubview:self.lineOneV];
        [self addSubview:self.lineTwoV];
        [self addSubview:self.lineOneH];
        [self addSubview:self.lineTwoH];
        [self.lineOneV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(1);
        }];
        [self.lineTwoV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(1);
        }];
        NSArray * array1 = @[self.lineOneV ,self.lineTwoV];
        [self distributeSpacingVerticallyWith:array1];//按钮的等间距设置
        [self.lineOneH mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(1);
        }];
        [self.lineTwoH mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(1);
        }];
        NSArray * array2 = @[self.lineOneH,self.lineTwoH];
        [self top_distributeSpacingHorizontallyWith:array2];
    }else{
        [self.lineOneH removeFromSuperview];
        [self.lineTwoH removeFromSuperview];
        [self.lineOneV removeFromSuperview];
        [self.lineTwoV removeFromSuperview];
        self.lineOneH = nil;
        self.lineTwoH = nil;
        self.lineOneV = nil;
        self.lineTwoV = nil;
    }
}
- (void)top_startAccelerometerUpdates{
    if([self.cmmotionManager isDeviceMotionAvailable]) {
       __weak typeof(self) weakSelf = self;
        [self.cmmotionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            CGFloat xx = accelerometerData.acceleration.x;
            CGFloat yy = -accelerometerData.acceleration.y;
            CGFloat zz = accelerometerData.acceleration.z;
            CGFloat device_angle = M_PI / 2.0f - atan2(yy, xx);
            if (device_angle > M_PI){
                device_angle -= 2 * M_PI;
            }
            if ((zz < -.60f) || (zz > .60f)) {
                weakSelf.orientation = UIDeviceOrientationUnknown;
            }else{
                if ( (device_angle > -M_PI_4) && (device_angle < M_PI_4) ){
                    weakSelf.orientation = UIDeviceOrientationPortrait;
                }else if ((device_angle < -M_PI_4) && (device_angle > -3 * M_PI_4)){
                    weakSelf.orientation = UIDeviceOrientationLandscapeLeft;
                }else if ((device_angle > M_PI_4) && (device_angle < 3 * M_PI_4)){
                    weakSelf.orientation = UIDeviceOrientationLandscapeRight;
                }else{
                    weakSelf.orientation = UIDeviceOrientationPortraitUpsideDown;
                }
            }
        }];
    }
}
- (void)top_endAccelerometerUpdates
{
    [self.cmmotionManager stopAccelerometerUpdates];
    self.cmmotionManager = nil;
    
    _effectiveScale = 1.0;
    [self top_changeEffectiveScale];
}
- (void)top_customCamera{
        
    [self.layer addSublayer:self.capturePreviewLayer];
    if ([self.captureDevice lockForConfiguration:nil]) {
        if ([self.captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [self.captureDevice unlockForConfiguration];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.captureSession startRunning];
    });
}
#pragma mark -- 聚焦框
- (void)top_focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self top_focusAtPoint:point];
}
- (void)top_focusAtPoint:(CGPoint)point{
    CGSize size = self.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.captureDevice lockForConfiguration:&error]) {
        if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.captureDevice setFocusPointOfInterest:focusPoint];
            [self.captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([self.captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.captureDevice setExposurePointOfInterest:focusPoint];
            [self.captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        [self.captureDevice unlockForConfiguration];
        self.focusView.center = point;
        self.focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.focusView.hidden = YES;
            }];
        }];
    }
}
#pragma mark -- 闪光灯开关
- (void)top_flashSwitch{
    if ([self.captureDevice lockForConfiguration:nil]) {
        AVCaptureFlashMode flashModel;
        AVCaptureTorchMode trochModel;
        TOPCameraFlashType type = [TOPScanerShare top_cameraFlashType];
        if (type == TOPCameraFlashTypeTroch) {
            if ([self.captureDevice hasTorch]) {
                trochModel = AVCaptureTorchModeOn;
                self.captureDevice.torchMode = trochModel;
                [self.captureDevice unlockForConfiguration];
            }
        }else{
            if ([self.captureDevice hasTorch]) {
                self.captureDevice.torchMode = AVCaptureTorchModeOff;
            }
            if ([self.captureDevice hasFlash]) {
                if (type == TOPCameraFlashTypeAuto) {
                    flashModel = AVCaptureFlashModeAuto;
                }else if (type == TOPCameraFlashTypeOn){
                    flashModel = AVCaptureFlashModeOn;
                }else{
                    flashModel = AVCaptureFlashModeOff;
                }
                if ([self.captureDevice isFlashModeSupported:flashModel]) {
                    [self.captureDevice setFlashMode:flashModel];
                }
                [self.captureDevice unlockForConfiguration];
            }
        }
    }
}

- (void)top_flashSwitchOff{
    if ([self.captureDevice lockForConfiguration:nil]) {
        if ([self.captureDevice hasFlash]) {
            self.captureDevice.flashMode = AVCaptureFlashModeOff;
        }
        if ([self.captureDevice hasTorch]) {
            self.captureDevice.torchMode = AVCaptureTorchModeOff;
        }
        [self.captureDevice unlockForConfiguration];
    }
}
#pragma mark -- 改变前后摄像头
- (void)top_changeCamera{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[self.captureDeviceInput device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.capturePreviewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.captureSession beginConfiguration];
            [self.captureSession removeInput:self.captureDeviceInput];
            if ([self.captureSession canAddInput:newInput]) {
                [self.captureSession addInput:newInput];
                self.captureDeviceInput = newInput;
            } else {
                [self.captureSession addInput:self.captureDeviceInput];
            }
            [self.captureSession commitConfiguration];
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}
#pragma mark - 拍照 截取照片
- (void)top_shutterCamera
{
    CABasicAnimation *twinkleAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    twinkleAnim.fromValue = @(1);
    twinkleAnim.toValue = @(0);
    twinkleAnim.duration = 0.2;
    [self.layer addAnimation:twinkleAnim forKey:nil];
    
    AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection || !videoConnection.enabled || !videoConnection.active) {
        NSLog(@"take photo failed!");
        return;
    }
    [videoConnection setVideoScaleAndCropFactor:_effectiveScale];
    
    if (@available(iOS 11.0, *)) {//震动反馈
        UIImpactFeedbackGenerator * feedbackGenerator = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleLight];
        [feedbackGenerator impactOccurred];
    }
    __weak typeof(self) weakSelf = self;
    [self.imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
            NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *originImage = [[UIImage alloc] initWithData:imageData];
            CGSize size = CGSizeMake(originImage.size.width ,originImage.size.height );
            UIImage *scaledImage = [originImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                                     bounds:size
                                                       interpolationQuality:kCGInterpolationHigh];
            CGRect cropFrame = CGRectMake((scaledImage.size.width - size.width),
                                          (scaledImage.size.height - size.height),
                                          size.width, size.height);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *croppedImage = nil;
            if (weakSelf.captureDeviceInput.device.position == AVCaptureDevicePositionFront) {
                croppedImage = [scaledImage croppedImage:cropFrame
                                         WithOrientation:UIImageOrientationUpMirrored];
            }else{
                croppedImage = [scaledImage croppedImage:cropFrame];
            }
            //横屏时旋转image
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage * sendImg = [croppedImage changeImageWithOrientation:weakSelf.orientation];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(top_shutterCameraWithImage:)]) {
                    [weakSelf.delegate top_shutterCameraWithImage:sendImg];
                }
            });
        });
    }];
}

#pragma mark -- 添加观察者观察手机是否在打电话 闹钟 处在分屏模式下
- (void)top_addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.captureSession];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sessionWasInterrupted:(NSNotification*)notification{
    [FIRAnalytics logEventWithName:@"sessionWasInterrupted" parameters:nil];
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    NSLog(@"Capture session was interrupted with reason %ld", (long)reason);
    if (self.top_getCurrentState) {
        self.top_getCurrentState(NO);
        [self.captureSession stopRunning];
    }
    
    //在此禁止掉拍照功能，同时添加提醒
    if (reason == AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient ||
        reason == AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient) {
        if (self.top_getCurrentState) {
            self.top_getCurrentState(NO);
            [self.captureSession stopRunning];
        }
    }
    else if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps) {
        if (self.top_getCurrentState) {
            self.top_getCurrentState(NO);
            [self.captureSession stopRunning];
        }
        
    }
    else if (@available(iOS 11.1, *)) {
        if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableDueToSystemPressure) {
            if (self.top_getCurrentState) {
                self.top_getCurrentState(NO);
                [self.captureSession stopRunning];
            }
        }
    } else {
        // Fallback on earlier versions
        if (self.top_getCurrentState) {
            self.top_getCurrentState(NO);
            [self.captureSession stopRunning];
        }
    }
     
}

- (void)sessionInterruptionEnded:(NSNotification*)notification{
    [FIRAnalytics logEventWithName:@"sessionInterruptionEnded" parameters:nil];
   //在此可以恢复拍照功能
    if (self.top_getCurrentState) {
        self.top_getCurrentState(YES);
        [self.captureSession startRunning];
    }
}

#pragma mark --缩放手势 用于调整焦距
- (void)top_handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:recognizer.view];
        CGPoint convertedLocation = [self.capturePreviewLayer convertPoint:location
                                                                 fromLayer:self.layer];
        if ( ! [self.capturePreviewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        _effectiveScale = _beginGestureScale * recognizer.scale;
        _effectiveScale = MAX(_effectiveScale, 1.0);
        CGFloat maxScaleAndCropFactor = [[self.imageOutPut connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        if (_effectiveScale > maxScaleAndCropFactor)
            _effectiveScale = maxScaleAndCropFactor;
        [self top_changeEffectiveScale];
    }
}
- (void)top_changeEffectiveScale
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [self.capturePreviewLayer setAffineTransform:CGAffineTransformMakeScale(_effectiveScale, _effectiveScale)];
    [CATransaction commit];

}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        _beginGestureScale = _effectiveScale;
    }
    return YES;
}
#pragma - 保存至相册
+ (void)top_saveImageToPhotoAlbum:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, nil, NULL);
}
#pragma mark - 检查相机权限
- (BOOL)top_canUserCamear{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted ||
        authStatus ==AVAuthorizationStatusDenied) {

        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"topscan_camerapermissiontitle", @"") message:NSLocalizedString(@"topscan_camerapermissionguide", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"topscan_questionsetting", @"") otherButtonTitles:NSLocalizedString(@"topscan_cancel", @""), nil];
        alertView.tag = 100;
        [alertView show];
        return NO;
    }else{
        return YES;
    }
    return YES;
}
- (void)dealloc
{
    if ([self.captureSession isRunning] || self.cmmotionManager.isAccelerometerActive) {
        [self.captureSession stopRunning];
        self.captureSession = nil;
        [self top_endAccelerometerUpdates];
    }
    
    [self removeObservers];
}
@end
