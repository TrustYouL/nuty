#import <UIKit/UIKit.h>

@interface FFAbstractDotView : UIView
- (void)setDotColor:(UIColor *)dotColor;
- (void)setCurrentDotColor:(UIColor *)currentDotColor;
- (void)changActiveState:(BOOL)active;
@end
