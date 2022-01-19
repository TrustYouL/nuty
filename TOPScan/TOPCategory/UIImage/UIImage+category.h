#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface UIImage (category)
+(UIImage *_Nonnull)fixOrientation:(UIImage *_Nonnull)image;
- (UIImage *_Nullable)box_imageAtAppropriateScaleFactor;
- (UIImage *)fixOrientation;
@end
