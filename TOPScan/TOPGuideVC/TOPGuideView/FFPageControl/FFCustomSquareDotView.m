#import "FFCustomSquareDotView.h"

static const NSTimeInterval timeInterval = 0.5f;

@interface FFCustomSquareDotView ()
@property(nonatomic, strong) UIColor *dotColor;
@property(nonatomic, strong) UIColor *currentDotColor;
@end

@implementation FFCustomSquareDotView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    
    return self;
}

- (void)initialization
{
    self.layer.cornerRadius = self.frame.size.height/2;
    self.dotColor = [UIColor whiteColor];
    self.currentDotColor = [UIColor grayColor];
    self.backgroundColor    = self.dotColor;
}

#pragma mark - implement method
- (void)changActiveState:(BOOL)active
{
    if (active) {
        [self animateToActiveState];
    } else {
        [self animateToInactiveState];
    }
}

- (void)animateToActiveState
{
    self.layer.cornerRadius = self.frame.size.height/2*0.8;
    [UIView animateWithDuration:timeInterval animations:^{
        self.backgroundColor = self.currentDotColor;
        self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:nil];
}

- (void)animateToInactiveState
{
    self.layer.cornerRadius = self.frame.size.height/2;
    [UIView animateWithDuration:timeInterval animations:^{
        self.backgroundColor = self.dotColor;
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)setDotColor:(UIColor *)dotColor
{
    _dotColor = dotColor;
    self.backgroundColor = dotColor;
}

- (void)setCurrentDotColor:(UIColor *)currentDotColor
{
    _currentDotColor = currentDotColor;
    self.backgroundColor = currentDotColor;
}

@end
