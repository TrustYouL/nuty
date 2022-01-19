#import "UIImageView+SSTouch.h"
#import <objc/runtime.h>
static void *TouchSizeKey = &TouchSizeKey;

@implementation UIImageView (SSTouch)

- (void)setTouchSize:(CGSize)touchSize {
    objc_setAssociatedObject(self, &TouchSizeKey, [NSValue valueWithCGSize:touchSize], OBJC_ASSOCIATION_COPY);
}
- (CGSize)touchSize {
    NSValue *touchSizeValue = objc_getAssociatedObject(self, &TouchSizeKey);
    CGSize touchSize = touchSizeValue.CGSizeValue;
    if (!touchSizeValue) {
        touchSize = self.bounds.size;
    }
    return touchSize;
}
#pragma mark - method rewrite
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGFloat widthDelta = self.touchSize.width - CGRectGetWidth(self.bounds);
    CGFloat heightDelta = self.touchSize.height - CGRectGetHeight(self.bounds);
    CGRect bounds = CGRectInset(self.bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    
    return CGRectContainsPoint(bounds, point);
}
@end
