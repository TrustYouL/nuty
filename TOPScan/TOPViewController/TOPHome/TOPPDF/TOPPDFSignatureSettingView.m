#import "TOPPDFSignatureSettingView.h"
#import "TOPColorMenuView.h"

@interface TOPPDFSignatureSettingView()
@property (strong, nonatomic) TOPColorMenuView *colorMenuView;

@end

#define SignatureSettingBGHeight 118

@implementation TOPPDFSignatureSettingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBA(37, 43, 49, 0.7);
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width, height = [UIScreen mainScreen].bounds.size.height;
        self.frame = CGRectMake(0, height, width, SignatureSettingBGHeight);
        self.backgroundColor = [UIColor clearColor];
        [self top_configContentView];
    }
    return self;
}

- (void)setCurrentColor:(UIColor *)currentColor {
    _currentColor = currentColor;
    self.colorMenuView.currentColor = _currentColor;
}

- (void)top_configContentView {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,  CGRectGetHeight(self.bounds)- SignatureSettingBGHeight, CGRectGetWidth(self.bounds), SignatureSettingBGHeight)];
    bgView.backgroundColor = RGBA(38, 43, 48, 0.7);
    [self addSubview:bgView];
    [bgView addSubview:[self top_opacitySliderView]];
    //颜色菜单
    _colorMenuView = [[TOPColorMenuView alloc] initWithFrame:CGRectMake(0, 50, CGRectGetWidth(self.bounds), 60)];
    _colorMenuView.colorsArray = [self top_menuColors];
    _colorMenuView.currentColor = self.currentColor;
    __weak typeof(self) weakSelf = self;
    _colorMenuView.didSelectedItemBlock = ^(UIColor * _Nonnull textColor) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_currentColor = textColor;
        [strongSelf top_reloadTextColor];
    };
    [bgView addSubview:_colorMenuView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches  anyObject] locationInView:self];
    CGRect rect = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - SignatureSettingBGHeight);
    if (CGRectContainsPoint(rect, touchPoint)) {
        [self top_dismissSelf];
    }
}

- (void)top_dismissSelf {
    if (self.top_clickCancelBlock) {
        self.top_clickCancelBlock();
    }
}

- (void)top_reloadTextColor {
    if (self.top_changeColorBlock) {
        self.top_changeColorBlock(self.currentColor);
    }
}

- (void)setSaturationValue:(CGFloat)saturationValue {
    _saturationValue = saturationValue;
    UISlider *opacitySlider = [self viewWithTag:101];
    opacitySlider.value = _saturationValue;
}

- (void)top_sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    if (slider.tag == 101) {//opacity
        _saturationValue = slider.value;
        if (self.top_changeSaturationValueBlock) {
            self.top_changeSaturationValueBlock(_saturationValue);
        }
    }
}

- (NSArray *)top_menuColors {
    NSArray *colors = @[RGB(255, 255, 255),
                        RGB(51, 151, 240),
                        RGB(112, 193, 80),
                        RGB(253, 203, 91),
                        RGB(254, 141, 53),
                        RGB(0, 0, 0),
                        RGB(208, 44, 37),
                        RGB(29, 65, 246),
                        RGB(75, 42, 24),
                        RGB(236, 73, 86),
                        RGB(208, 11, 106),
                        RGB(164, 7, 186)];
    return colors;
}

- (UIView *)top_opacitySliderView {
    UIView *opacityView = [[UIView alloc] initWithFrame:CGRectMake(0, 14, CGRectGetWidth(self.bounds), 30)];
    opacityView.backgroundColor = [UIColor clearColor];
    UIImage *noClassImg = [UIImage imageNamed:@"top_pdf_shape_low"];
    UIImageView *leftIcon = [[UIImageView alloc] initWithImage:noClassImg];
    leftIcon.frame = CGRectMake(45, 4, 24, 21);
    [opacityView addSubview:leftIcon];
    UIImage *noClassImg1 = [UIImage imageNamed:@"top_pdf_shape_high"];
    UIImageView *rightIcon = [[UIImageView alloc] initWithImage:noClassImg1];
    rightIcon.frame = CGRectMake(CGRectGetWidth(self.bounds) - 45 - 24, 4, 24, 21);
    [opacityView addSubview:rightIcon];
    UISlider *_sizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftIcon.frame) + 14, 0, (CGRectGetMinX(rightIcon.frame) - 14 - CGRectGetMaxX(leftIcon.frame) - 14), 30)];
    _sizeSlider.thumbTintColor = kWhiteColor;
    _sizeSlider.minimumTrackTintColor = kTopicBlueColor;
    _sizeSlider.maximumTrackTintColor = RGBA(255, 255, 255, 0.9);
    _sizeSlider.minimumValue = 0.0;
    _sizeSlider.maximumValue = 2.0;
    _sizeSlider.value = 1.0;
    _sizeSlider.tag = 101;
     [_sizeSlider addTarget:self action:@selector(top_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [opacityView addSubview:_sizeSlider];
    return opacityView;
}

@end
