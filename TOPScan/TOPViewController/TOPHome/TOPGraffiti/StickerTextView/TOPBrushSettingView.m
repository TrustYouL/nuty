#import "TOPBrushSettingView.h"
#import "TOPColorMenuView.h"

@interface TOPBrushSettingView()
@property (strong, nonatomic) TOPColorMenuView *colorMenuView;
@property (strong, nonatomic) UIView * bgView;
@end

#define BrushSettingBGHeight 180
#define Bottom_H 60

@implementation TOPBrushSettingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width, height = [UIScreen mainScreen].bounds.size.height;
        self.frame = CGRectMake(0, height, width, height - 60 - TOPBottomSafeHeight);
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
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,  CGRectGetHeight(self.bounds)- BrushSettingBGHeight, CGRectGetWidth(self.bounds), BrushSettingBGHeight)];
    bgView.backgroundColor = RGBA(38, 43, 48, 0.7);
    [self addSubview:bgView];
    self.bgView = bgView;
    [self top_brushSliderView];
    [self top_opacitySliderView];
    _colorMenuView = [[TOPColorMenuView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.bounds), 60)];
    _colorMenuView.colorsArray = [self top_menuColors];
    _colorMenuView.currentColor = self.currentColor;
    __weak typeof(self) weakSelf = self;
    _colorMenuView.didSelectedItemBlock = ^(UIColor * _Nonnull textColor) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_currentColor = textColor;
        [strongSelf top_reloadTextColor];
    };
    [bgView addSubview:_colorMenuView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(BrushSettingBGHeight);
    }];
    [_colorMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(bgView);
        make.top.equalTo(bgView).offset(100);
        make.height.mas_equalTo(60);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches  anyObject] locationInView:self];
    CGRect rect = CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight - BrushSettingBGHeight-TOPBottomSafeHeight-Bottom_H-TOPNavBarAndStatusBarHeight);
    if (CGRectContainsPoint(rect, touchPoint)) {
        [self top_dismissSelf];
    }
}

- (void)top_dismissSelf {
    self.colorMenuView.currentColor = _currentColor;
    if (self.callSetCompleteBlock) {
        self.callSetCompleteBlock(_currentColor, _brushSize, _opacityValue);
    }
}

- (void)top_reloadTextColor {
    if (self.changeTextColorBlock) {
        self.changeTextColorBlock(self.currentColor);
    }
}

- (void)setBrushSize:(CGFloat)brushSize {
    _brushSize = brushSize;
    UISlider *brushSlider = [self viewWithTag:100];
    brushSlider.value = brushSize;
}

- (void)setOpacityValue:(CGFloat)opacityValue {
    _opacityValue = opacityValue;
    UISlider *opacitySlider = [self viewWithTag:101];
    opacitySlider.value = opacityValue;
}

- (void)top_sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    if (slider.tag == 100) {
        _brushSize = slider.value;
        if (self.changeBrushValueBlock) {
            self.changeBrushValueBlock(_brushSize);
        }
    }
    if (slider.tag == 101) {
        _opacityValue = slider.value;
        if (self.changeOpacityValueBlock) {
            self.changeOpacityValueBlock(_opacityValue);
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

- (void)top_brushSliderView {
    UIView *brushView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.bounds), 30)];
    brushView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:brushView];
    
    UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 30)];
    noClassLab.textColor = kWhiteColor;
    noClassLab.textAlignment = NSTextAlignmentNatural;
    noClassLab.font = [UIFont systemFontOfSize:15];
    noClassLab.text = NSLocalizedString(@"topscan_graffitibrush", @"");
    [brushView addSubview:noClassLab];
    
    UISlider *_sizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(noClassLab.frame) + 20, 0, CGRectGetWidth(self.bounds) - (CGRectGetMaxX(noClassLab.frame) + 20 + 20), 30)];
    _sizeSlider.thumbTintColor = kTopicBlueColor;
    _sizeSlider.minimumTrackTintColor = kTopicBlueColor;
    _sizeSlider.maximumTrackTintColor = RGBA(255, 255, 255, 0.9);
    _sizeSlider.minimumValue = 1;
    _sizeSlider.maximumValue = 20;
    _sizeSlider.value = 2;
    _sizeSlider.tag = 100;
     [_sizeSlider addTarget:self action:@selector(top_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [brushView addSubview:_sizeSlider];
    
    [brushView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.bgView);
        make.top.equalTo(self.bgView).offset(20);
        make.height.mas_equalTo(30);
    }];
    
    [noClassLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(brushView).offset(20);
        make.top.equalTo(brushView);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(80);
    }];
    
    [_sizeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(noClassLab.mas_trailing).offset(20);
        make.trailing.equalTo(brushView).offset(-20);
        make.top.equalTo(brushView);
        make.height.mas_equalTo(30);
    }];
}

- (void)top_opacitySliderView {
    UIView *opacityView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.bounds), 30)];
    opacityView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:opacityView];
    
    UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 30)];
    noClassLab.textColor = kWhiteColor;
    noClassLab.textAlignment = NSTextAlignmentNatural;
    noClassLab.font = [UIFont systemFontOfSize:15];
    noClassLab.text = NSLocalizedString(@"topscan_graffitiopacity", @"");
    [opacityView addSubview:noClassLab];
    
    UISlider *_sizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(noClassLab.frame) + 20, 0, CGRectGetWidth(self.bounds) - (CGRectGetMaxX(noClassLab.frame) + 20 + 20), 30)];
    _sizeSlider.thumbTintColor = kTopicBlueColor;
    _sizeSlider.minimumTrackTintColor = kTopicBlueColor;
    _sizeSlider.maximumTrackTintColor = RGBA(255, 255, 255, 0.9);
    _sizeSlider.minimumValue = 0.0;
    _sizeSlider.maximumValue = 1.0;
    _sizeSlider.value = 0.5;
    _sizeSlider.tag = 101;
     [_sizeSlider addTarget:self action:@selector(top_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [opacityView addSubview:_sizeSlider];
    
    [opacityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.bgView);
        make.top.equalTo(self.bgView).offset(60);
        make.height.mas_equalTo(30);
    }];
    
    [noClassLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(opacityView).offset(20);
        make.top.equalTo(opacityView);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(80);
    }];
    
    [_sizeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(noClassLab.mas_trailing).offset(20);
        make.trailing.equalTo(opacityView).offset(-20);
        make.top.equalTo(opacityView);
        make.height.mas_equalTo(30);
    }];
}


@end
