#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TOPTrackingSliderDelegate;
@interface TOPTrackingSlider : UISlider
@property (nonatomic, unsafe_unretained) id<TOPTrackingSliderDelegate>delegate;
@end

@protocol TOPTrackingSliderDelegate <NSObject>
- (void)topCurrentValueOfSlider:(TOPTrackingSlider *)slider;
- (void)topBeginSwipSlider:(TOPTrackingSlider *)slider;
- (void)topEndSwipSlider:(TOPTrackingSlider *)slider;
@end
NS_ASSUME_NONNULL_END
