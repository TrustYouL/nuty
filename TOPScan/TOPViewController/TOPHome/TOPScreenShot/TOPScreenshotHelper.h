#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPScreenshotHelper : NSObject
+ (UIImage *)top_screenshotOfView:(UIView *)view;
+ (UIImage *)screenshot;
+ (UIImage *)top_screenshotWithStatusBar:(BOOL)withStatusBar;
+ (UIImage *)top_screenshotWithStatusBar:(BOOL)withStatusBar rect:(CGRect)rect;
+ (UIImage *)top_screenshotWithStatusBar:(BOOL)withStatusBar rect:(CGRect)rect orientation:(UIInterfaceOrientation)o;
@end

NS_ASSUME_NONNULL_END
