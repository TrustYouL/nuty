#import "TOPWatermarkSettingView.h"
#import "TOPPaletteSlider.h"

#define InputViewHeight 200
#define SSMarginLeft 45

@interface TOPWatermarkSettingView ()

@property (nonatomic, strong) TOPPaletteSlider *paletteSlider;
@property (strong, nonatomic) UIView *selectedColorItem;

@end

@implementation TOPWatermarkSettingView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self top_configContentView];
    }
    return self;
}

- (instancetype)initWithFontSie:(CGFloat)fontsize opacity:(CGFloat)opacity {
    self = [super init];
    if (self) {
       _opacityValue = opacity;
        _fontSize = fontsize;
        self.frame = CGRectMake(0, TOPScreenHeight, TOPScreenWidth, InputViewHeight);
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    self.backgroundColor = RGBA(0, 0, 0, 0.3);
    UIView *colorBgView = [[UIView alloc] init];
    colorBgView.frame = CGRectMake(0,CGRectGetHeight(self.bounds) - 60,TOPScreenWidth,60);
    colorBgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
    [self addSubview:colorBgView];
    
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(30,95,TOPScreenWidth - 60,60);
    view.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:[UIColor whiteColor]];
    view.layer.shadowColor = [UIColor colorWithRed:8/255.0 green:29/255.0 blue:41/255.0 alpha:0.16].CGColor;
    view.layer.shadowOffset = CGSizeMake(0,4);
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowRadius = 5;
    view.layer.cornerRadius = 10;    
    [self addSubview:view];
    

    CGFloat palette_X = (TOPScreenWidth - 270)/2;
    self.paletteSlider = [[TOPPaletteSlider alloc] initWithFrame:CGRectMake(palette_X, CGRectGetMinY(view.frame)+6, 270, 54)];
    [self addSubview:self.paletteSlider];
    [self.paletteSlider addTarget:self action:@selector(top_palletteChangeColor) forControlEvents:UIControlEventValueChanged];
    [self addSubview:[self top_opacitySliderView]];
    [self addSubview:[self top_brushSliderView]];
    
    [self top_colorMenu];
}

- (void)top_palletteChangeColor {
    self.currentColor = self.paletteSlider.selectedColor;
    [self top_changeSetting];
}

- (void)top_changeSetting {
    if (self.top_changeSettingBlock) {
        self.top_changeSettingBlock(self.currentColor, self.fontSize, self.opacityValue);
    }
}

- (void)top_sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    if (slider.tag == 100) {
        _opacityValue = slider.value;
    }
    if (slider.tag == 101) {
        _fontSize = slider.value;
    }
    [self top_changeSetting];
}

- (UIView *)top_opacitySliderView {
    UIView *opacityView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, CGRectGetWidth(self.bounds), 30)];
    opacityView.backgroundColor = [UIColor clearColor];
    UIImage *noClassImg = [UIImage imageNamed:@"top_waterMark_opacity"];
    UIImageView *noClass = [[UIImageView alloc] initWithImage:noClassImg];
    noClass.frame = CGRectMake(SSMarginLeft, 3, 24, 24);
    [opacityView addSubview:noClass];
    UISlider *_sizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(noClass.frame) + 20, 0, CGRectGetWidth(self.bounds) - (CGRectGetMaxX(noClass.frame) + 20 + 50), 30)];
    _sizeSlider.thumbTintColor = kTopicBlueColor;
    _sizeSlider.minimumValue = 0.0;
    _sizeSlider.maximumValue = 1.0;
    _sizeSlider.minimumTrackTintColor = kTopicBlueColor;
    _sizeSlider.maximumTrackTintColor = kWhiteColor;
    _sizeSlider.value = _opacityValue;
    _sizeSlider.tag = 100;
     [_sizeSlider addTarget:self action:@selector(top_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [opacityView addSubview:_sizeSlider];
    return opacityView;
}

- (UIView *)top_brushSliderView {
    UIView *brushView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, CGRectGetWidth(self.bounds), 30)];
    brushView.backgroundColor = [UIColor clearColor];
    UIImage *noClassImg = [UIImage imageNamed:@"top_waterMark_font"];
    UIImageView *noClass = [[UIImageView alloc] initWithImage:noClassImg];
    noClass.frame = CGRectMake(SSMarginLeft, 3, 24, 24);
    [brushView addSubview:noClass];
    UISlider *_sizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(noClass.frame) + 20, 0, CGRectGetWidth(self.bounds) - (CGRectGetMaxX(noClass.frame) + 20 + 50), 30)];
    _sizeSlider.thumbTintColor = kTopicBlueColor;
    _sizeSlider.minimumValue = 10;
    _sizeSlider.maximumValue = 60;
    _sizeSlider.minimumTrackTintColor = kTopicBlueColor;
    _sizeSlider.maximumTrackTintColor = kWhiteColor;
    _sizeSlider.value = _fontSize;
    _sizeSlider.tag = 101;
     [_sizeSlider addTarget:self action:@selector(top_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [brushView addSubview:_sizeSlider];
    return brushView;
}

- (void)setCurrentColor:(UIColor *)currentColor {
    if (currentColor) {
        _currentColor = currentColor;
        [self top_setSelectedItemWithColor:_currentColor];
    }
}

- (NSArray *)colorsArray {
    NSArray *colors = @[[UIColor colorWithHex:0x000000],
                        [UIColor colorWithHex:0xFB0006],
                        [UIColor colorWithHex:0xFAFF0A],
                        [UIColor colorWithHex:0x22FF08],
                        [UIColor colorWithHex:0x114c97],
                        [UIColor colorWithHex:0x3500A8]];
    return colors;
}

- (void)top_setSelectedItemWithColor:(UIColor *)color {
    [self.selectedColorItem removeFromSuperview];
    self.selectedColorItem = nil;
    NSArray *colors = [self colorsArray];
    CGFloat menuHeight = 26;
    CGFloat itemWidth = 26;
    CGFloat itemY = 15 + CGRectGetHeight(self.bounds) - 49;
    CGFloat itemX = (TOPScreenWidth - (26*6 + 20*5))/2.0;
    for (int i = 0; i < colors.count; i ++) {
        UIColor *itemColor = colors[i];
        if ([self top_isEqualColor:itemColor toColor:color]) {
            self.selectedColorItem = [[UIView alloc] initWithFrame:CGRectMake(itemX + i*(itemWidth + 20), itemY, itemWidth, menuHeight)];
            self.selectedColorItem.layer.cornerRadius = menuHeight/2.0;
            self.selectedColorItem.backgroundColor = itemColor;
            break;
        }
    }
    if (self.selectedColorItem) {
        [self addSubview:self.selectedColorItem];
        [self top_highlightSelectColor:self.selectedColorItem];
    }
}


- (void)top_colorMenu {
    NSArray *colors = [self colorsArray];
    CGFloat menuHeight = 26;
    CGFloat itemWidth = 26;
    CGFloat itemY = 25 + CGRectGetHeight(self.bounds) - 60;
    CGFloat itemX = (TOPScreenWidth - (26*6 + 20*5))/2.0;
    for (int i = 0; i < colors.count; i ++) {
        UIColor *itemColor = colors[i];
        UIView *item = [self colorView];
        item.layer.cornerRadius = menuHeight/2.0;
        item.backgroundColor = itemColor;
        item.frame = CGRectMake(itemX + i*(itemWidth + 20), itemY, itemWidth, menuHeight);
        [self addSubview:item];
    }
}

#pragma mark -- 判断两个颜色是否相同
- (BOOL)top_isEqualColor:(UIColor *)color1 toColor:(UIColor *)color2 {
    NSArray *rgbs1 = [self top_getRGBWithColor:color1];
    NSArray *rgbs2 = [self top_getRGBWithColor:color2];
    BOOL isEq = YES;
    for (int i = 0; i < rgbs1.count; i ++) {
        CGFloat rgbItem = [rgbs1[i] floatValue];
        if (i < rgbs2.count) {
            CGFloat rgbItem2 = [rgbs2[i] floatValue];
            if (rgbItem != rgbItem2) {
                isEq = NO;
                break;
            }
        }
    }
    return isEq;
}

#pragma mark -- 获取颜色的r、g、b
- (NSArray *)top_getRGBWithColor:(UIColor *)color {
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return @[@(red), @(green), @(blue), @(alpha)];
}

#pragma mark -- 单个颜色块
- (UIView *)colorView {
    UIView *item = [[UIView alloc] init];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(top_handleTap:)];
    [item addGestureRecognizer:tapRecognizer];
    return item;
}

- (void)top_handleTap:(UITapGestureRecognizer *)tapGesture {
    UIView *colorItem = tapGesture.view;
    [self setCurrentColor:colorItem.backgroundColor];
    [self top_changeSetting];
}

- (void)top_highlightSelectColor:(UIView *)view {
    UIColor *selectColor = view.backgroundColor;
    if (self.selectedColorItem) {
        self.selectedColorItem.transform = CGAffineTransformIdentity;
    }
    CGFloat scale = 1.3;
    self.selectedColorItem.center = view.center;
    self.selectedColorItem.backgroundColor = selectColor;
    [UIView animateWithDuration:0.3
                     animations:^{
        self.selectedColorItem.transform = CGAffineTransformScale(self.selectedColorItem.transform, scale, scale);
    } completion:^(BOOL finished) {
        
    }];
}

@end
