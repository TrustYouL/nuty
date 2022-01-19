#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TOPCaptureViewFlashModeOff,
    TOPCaptureViewFlashModeOn,
    TOPCaptureViewFlashModeAuto,
} TOPCaptureViewFlashSwitch;
@protocol  TOPCaptureViewDelegate<NSObject>
- (void)top_captureAuthorizationFail;
- (void)top_shutterCameraWithImage:(UIImage *)image;
@end
@interface TOPCaptureView : UIView
@property (nonatomic, weak) id <TOPCaptureViewDelegate> delegate;
@property(nonatomic) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureDevice *captureDevice;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (nonatomic,assign) TOPCaptureViewFlashSwitch flashState;
@property (nonatomic, copy)void (^top_getCurrentState)(BOOL currentState);
- (instancetype)initWithFrame:(CGRect)frame WithDelegate:(id <TOPCaptureViewDelegate>)delegate;
- (void)top_flashSwitch;
- (void)top_flashSwitchOff;
- (void)top_changeCamera;
- (void)top_shutterCamera;
- (void)top_cameraLineShowState:(BOOL)isShow;
+ (void)top_saveImageToPhotoAlbum:(UIImage*)savedImage;
- (void)top_startAccelerometerUpdates;
- (void)top_endAccelerometerUpdates;
- (BOOL)top_canUserCamear;
@end
