#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@interface TOPQRCodeReader : NSObject
#pragma mark - Creating and Inializing QRCode Readers
- (nonnull id)init;
- (nonnull id)initWithMetadataObjectTypes:(nonnull NSArray *)metadataObjectTypes;
+ (nonnull instancetype)readerWithMetadataObjectTypes:(nonnull NSArray *)metadataObjectTypes;
#pragma mark - Checking the Reader Availabilities
+ (BOOL)isAvailable;
+ (BOOL)supportsMetadataObjectTypes:(nonnull NSArray *)metadataObjectTypes;
#pragma mark - Checking the Metadata Items Types
@property (strong, nonatomic, readonly) NSArray * _Nonnull metadataObjectTypes;
#pragma mark - Viewing the Camera
@property (strong, nonatomic, readonly) AVCaptureVideoPreviewLayer * _Nonnull previewLayer;
#pragma mark - Controlling the Reader
- (void)startScanning;
- (void)top_stopScanning;
- (BOOL)running;
- (void)switchDeviceInput;
- (BOOL)hasFrontDevice;
- (BOOL)isTorchAvailable;
- (void)toggleTorch;
- (void)toggleTorchClose;
#pragma mark - Getting Inputs and Outputs
@property (readonly) AVCaptureDeviceInput * _Nonnull defaultDeviceInput;
@property (readonly) AVCaptureDeviceInput * _Nullable frontDeviceInput;
@property (readonly) AVCaptureMetadataOutput * _Nonnull metadataOutput;
#pragma mark - Managing the Orientation
+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
#pragma mark - Managing the Block
- (void)setCompletionWithBlock:(nullable void (^) (NSString * _Nullable resultAsString))completionBlock;

@end
