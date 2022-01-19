#import "TOPRoundedButton.h"

@interface TOPRoundedButton ()

@property (nonatomic, assign) BOOL isTapped;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *backgroundView;

@end
static inline BOOL TO_ROUNDED_BUTTON_FLOAT_IS_ZERO(CGFloat value) {
    return (value > -FLT_EPSILON) && (value < FLT_EPSILON);
}

static inline BOOL TO_ROUNDED_BUTTON_FLOATS_MATCH(CGFloat firstValue, CGFloat secondValue) {
    return fabs(firstValue - secondValue) > FLT_EPSILON;
}

@implementation TOPRoundedButton

#pragma mark - View Creation -

- (instancetype)initWithText:(NSString *)text
{
    if (self = [super initWithFrame:(CGRect){0,0, 288.0f, 50.0f}]) {
        [self roundedButtonCommonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self roundedButtonCommonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self roundedButtonCommonInit];
    }
    
    return self;
}

- (void)roundedButtonCommonInit
{
    _cornerRadius = (_cornerRadius > FLT_EPSILON) ?: 12.0f;
    _tappedTextAlpha = (_tappedTextAlpha > FLT_EPSILON) ?: 0.77f;
    _tapAnimationDuration = (_tapAnimationDuration > FLT_EPSILON) ?: 0.4f;
    _tappedButtonScale = (_tappedButtonScale > FLT_EPSILON) ?: 0.95f;
    _tappedTintColorBrightnessOffset = !TO_ROUNDED_BUTTON_FLOAT_IS_ZERO(_tappedTintColorBrightnessOffset) ?: -0.1f;
    
    [self updateTappedTintColorForTintColor];
    UIFont *buttonFont = [UIFont systemFontOfSize:17.0f weight:UIFontWeightBold];
    if (@available(iOS 11.0, *)) {
        // Apply resizable button metrics to font
        UIFontMetrics *metrics = [[UIFontMetrics alloc] initForTextStyle:UIFontTextStyleBody];
        buttonFont = [metrics scaledFontForFont:buttonFont];
    }
    [self bringSubviewToFront:self.imageView];
    [self addTarget:self action:@selector(didTouchDownInside) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDownRepeat];
    [self addTarget:self action:@selector(didTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(didDragOutside) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchCancel];
    [self addTarget:self action:@selector(didDragInside) forControlEvents:UIControlEventTouchDragEnter];
}

#pragma mark - View Displaying -

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel sizeToFit];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    [self setNeedsLayout];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    [self setNeedsLayout];
}

- (void)updateTappedTintColorForTintColor
{
    if (TO_ROUNDED_BUTTON_FLOAT_IS_ZERO(_tappedTintColorBrightnessOffset)) {
        return;
    }
    
    _tappedTintColor = [[self class] brightnessAdjustedColorWithColor:self.tintColor
                                                               amount:_tappedTintColorBrightnessOffset];
}

#pragma mark - Interaction -

- (void)didTouchDownInside
{
    self.isTapped = YES;
    [self setLabelAlphaTappedAnimated:NO];
    [self setBackgroundColorTappedAnimated:NO];
    [self setButtonScaledTappedAnimated:YES];
}

- (void)didTouchUpInside
{
    self.isTapped = NO;
    [self setLabelAlphaTappedAnimated:YES];
    [self setBackgroundColorTappedAnimated:YES];
    [self setButtonScaledTappedAnimated:YES];
    
    [self sendActionsForControlEvents:UIControlEventPrimaryActionTriggered];
    if (self.tappedHandler) { self.tappedHandler(); }
}

- (void)didDragOutside
{
    self.isTapped = NO;
    [self setLabelAlphaTappedAnimated:YES];
    [self setBackgroundColorTappedAnimated:YES];
    [self setButtonScaledTappedAnimated:YES];
}

- (void)didDragInside
{
    self.isTapped = YES;
    [self setLabelAlphaTappedAnimated:YES];
    [self setBackgroundColorTappedAnimated:YES];
    [self setButtonScaledTappedAnimated:YES];
}

#pragma mark - Animation -

- (void)setBackgroundColorTappedAnimated:(BOOL)animated
{
    if (!self.tappedTintColor) { return; }
    
    void (^updateTitleOpacity)(void) = ^{
    };
    
    
    void (^animationBlock)(void) = ^{
    };
    
    void (^completionBlock)(BOOL) = ^(BOOL completed){
        if (completed == NO) { return; }
        updateTitleOpacity();
    };
    
    if (!animated) {
        animationBlock();
        completionBlock(YES);
    }
    else {
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:self.tapAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:animationBlock
                         completion:completionBlock];
    }
    
}

- (void)setLabelAlphaTappedAnimated:(BOOL)animated
{
    if (self.tappedTextAlpha > 1.0f - FLT_EPSILON) { return; }
    
    CGFloat alpha = self.isTapped ? self.tappedTextAlpha : 1.0f;
    void (^animationBlock)(void) = ^{
        self.titleLabel.alpha = alpha;
    };
    
    if (!animated) {
        [self.titleLabel.layer removeAnimationForKey:@"opacity"];
        animationBlock();
        return;
    }
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    [UIView animateWithDuration:self.tapAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animationBlock
                     completion:nil];
}

- (void)setButtonScaledTappedAnimated:(BOOL)animated
{
    if (self.tappedButtonScale < FLT_EPSILON) { return; }
    
    CGFloat scale = self.isTapped ? self.tappedButtonScale : 1.0f;
    void (^animationBlock)(void) = ^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity,
                                                              scale,
                                                              scale);
    };
    if (!animated) {
        animationBlock();
        return;
    }
    
    [UIView animateWithDuration:self.tapAnimationDuration
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.5f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animationBlock
                     completion:nil];
}

#pragma mark - Public Accessors -

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    self.titleLabel.attributedText = attributedText;
    [self.titleLabel sizeToFit];
    [self setNeedsLayout];
}

- (NSAttributedString *)attributedText
{
    return self.titleLabel.attributedText;
}

- (void)setText:(NSString *)text
{
    self.titleLabel.text = text;
    [self.titleLabel sizeToFit];
    [self setNeedsLayout];
}
- (NSString *)text { return self.titleLabel.text; }

- (void)setTextFont:(UIFont *)textFont
{
    self.titleLabel.font = textFont;
    self.textPointSize = 0.0f;
}
- (UIFont *)textFont { return self.titleLabel.font; }

- (void)setTextColor:(UIColor *)textColor
{
    self.titleLabel.textColor = textColor;
}
- (UIColor *)textColor { return self.titleLabel.textColor; }

- (void)setTextPointSize:(CGFloat)textPointSize
{
    if (_textPointSize == textPointSize) { return; }
    _textPointSize = textPointSize;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:textPointSize];
    [self setNeedsLayout];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self updateTappedTintColorForTintColor];
    self.backgroundView.backgroundColor = tintColor;
    self.titleLabel.backgroundColor = tintColor;
    [self setNeedsLayout];
}

- (void)setTappedTintColor:(UIColor *)tappedTintColor
{
    if (_tappedTintColor == tappedTintColor) { return; }
    _tappedTintColor = tappedTintColor;
    _tappedTintColorBrightnessOffset = 0.0f;
    [self setNeedsLayout];
}

- (void)setTappedTintColorBrightnessOffset:(CGFloat)tappedTintColorBrightnessOffset
{
    if (TO_ROUNDED_BUTTON_FLOATS_MATCH(_tappedTintColorBrightnessOffset,
                                       tappedTintColorBrightnessOffset))
    {
        return;
    }
    
    _tappedTintColorBrightnessOffset = tappedTintColorBrightnessOffset;
    [self updateTappedTintColorForTintColor];
    [self setNeedsLayout];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (fabs(cornerRadius - _cornerRadius) < FLT_EPSILON) {
        return;
    }
    
    _cornerRadius = cornerRadius;
    self.backgroundView.layer.cornerRadius = _cornerRadius;
    [self setNeedsLayout];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    self.containerView.alpha = enabled ? 1 : 0.4;
}

- (CGFloat)minimumWidth
{
    return self.titleLabel.frame.size.width;
}

+ (UIColor *)brightnessAdjustedColorWithColor:(UIColor *)color amount:(CGFloat)amount
{
    if (!color) { return nil; }
    
    CGFloat h, s, b, a;
    if (![color getHue:&h saturation:&s brightness:&b alpha:&a]) { return nil; }
    b += amount;
    b = MAX(b, 0.0f); b = MIN(b, 1.0f);
    return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
}

@end
