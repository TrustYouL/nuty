#define thumbBound_x 10
#define thumbBound_y 20
#import "TOPTrackingSlider.h"

@interface TOPTrackingSlider()
{
    CGRect lastBounds;
}
@end
@implementation TOPTrackingSlider
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - subclassed
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    BOOL begin = [super beginTrackingWithTouch:touch withEvent:event];
    if (begin) {
        if ([self.delegate respondsToSelector:@selector(topCurrentValueOfSlider:)]) {
            [self.delegate topCurrentValueOfSlider:self];
        }
        if ([self.delegate respondsToSelector:@selector(topBeginSwipSlider:)]) {
            [self.delegate topBeginSwipSlider:self];
        }
    }
    return begin;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL continueTrack = [super continueTrackingWithTouch:touch withEvent:event];
    if (continueTrack) {
        if ([self.delegate respondsToSelector:@selector(topCurrentValueOfSlider:)]) {
            [self.delegate topCurrentValueOfSlider:self];
        }
    }
    return continueTrack;
}
- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [super cancelTrackingWithEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    if ([self.delegate respondsToSelector:@selector(topCurrentValueOfSlider:)]) {
        [self.delegate topCurrentValueOfSlider:self];
    }
    if ([self.delegate respondsToSelector:@selector(topEndSwipSlider:)]) {
        [self.delegate topEndSwipSlider:self];
    }
}
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    rect.origin.x = rect.origin.x;
    rect.size.width = rect.size.width ;
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    
    lastBounds = result;
    return result;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *result = [super hitTest:point withEvent:event];

      if (point.x < 0 || point.x > self.bounds.size.width){

        return result;

      }

if ((point.y >= -thumbBound_y) && (point.y < lastBounds.size.height + thumbBound_y)) {
        float value = 0.0;
        value = point.x - self.bounds.origin.x;
        value = value/self.bounds.size.width;
        
        value = value < 0? 0 : value;
        value = value > 1? 1: value;
        
        value = value * (self.maximumValue - self.minimumValue) + self.minimumValue;
        [self setValue:value animated:YES];
    }
    return result;
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL result = [super pointInside:point withEvent:event];
    if (!result && point.y > -10) {
        if ((point.x >= lastBounds.origin.x - thumbBound_x) && (point.x <= (lastBounds.origin.x + lastBounds.size.width + thumbBound_x)) && (point.y < (lastBounds.size.height + thumbBound_y))) {
            result = YES;
        }
      
    }
      return result;
}

@end
