#import <UIKit/UIKit.h>
#import "TOPTrackingSlider.h"
NS_ASSUME_NONNULL_BEGIN
@protocol TOPTrackingSliderViewDelegate <NSObject>
- (void)top_topCurrentSlider:(TOPTrackingSlider *)slider;
@end
@interface TOPTrackingSliderView : UIView
@property (nonatomic, strong) TOPTrackingSlider *uiSlider;
@property (nonatomic, assign) BOOL isVertical;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat defaultValue;
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
@property (nonatomic, strong) UIColor *maxmumTrackTintColor;
@property (nonatomic, strong) UIImage *circleImg;
@property (nonatomic, unsafe_unretained) id<TOPTrackingSliderViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
