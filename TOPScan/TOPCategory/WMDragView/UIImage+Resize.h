#import <UIKit/UIKit.h>

@interface UIImage (Resize)
- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)croppedImage:(CGRect)bounds
          WithOrientation:(UIImageOrientation)orientation;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;

- (CGAffineTransform)transformForOrientation:(CGSize)newSize;
- (UIImage *)fixOrientation;
- (UIImage *)rotatedByDegrees:(CGFloat)degrees;
+ (UIImage *)croppedImageFromView:(UIView *)theView;
- (UIImage *)changeImageWithOrientation:(UIDeviceOrientation)deviceOrientation;
- (UIImage *)normalizedOrientationImage;
@end
