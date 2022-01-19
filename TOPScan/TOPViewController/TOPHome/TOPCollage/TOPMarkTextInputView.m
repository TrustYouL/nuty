#import "TOPMarkTextInputView.h"
#import "TOPColorMenuView.h"

@interface TOPMarkTextInputView ()<UITextFieldDelegate>
@property (strong, nonatomic) TOPColorMenuView *colorMenuView;

@end

#define InputViewHeight 288
#define SSMarginLeft 25

@implementation TOPMarkTextInputView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.opacityValue = 0.2;
        self.fontSize = 23;
        [self top_configSelf];
        [self top_configContentView];
    }
    return self;
}

- (instancetype)initWithFontSie:(CGFloat)fontsize opacity:(CGFloat)opacity {
    self = [super init];
    if (self) {
        self.opacityValue = opacity;
        self.fontSize = fontsize;
        [self top_configSelf];
        [self top_configContentView];
    }
    return self;
}

- (void)top_configSelf {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5;
    self.layer.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:RGBA(248, 248, 248, 1.0)].CGColor;
    CGFloat keyBorad_H = kIs_iPhoneX ? 350 : 295;
    self.frame = CGRectMake(20, TOPScreenHeight - keyBorad_H - TOPBottomSafeHeight - 10 - InputViewHeight, TOPScreenWidth - 20*2, InputViewHeight);
}

- (void)top_configContentView {
    [self top_inputViewTitle];
    [self addSubview:self.textFld];
    [self setColorMenuView];
    [self addSubview:[self top_opacitySliderView]];
    [self addSubview:[self top_brushSliderView]];
    [self top_actionView];
}

- (void)setCurrentColor:(UIColor *)currentColor {
    _currentColor = currentColor;
    self.textFld.textColor = _currentColor;
    self.colorMenuView.currentColor = _currentColor;
}

- (void)setColorMenuView {
    _colorMenuView = [[TOPColorMenuView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.textFld.frame), CGRectGetWidth(self.bounds), 60)];
    _colorMenuView.colorsArray = [self top_menuColors];
    _colorMenuView.currentColor = self.currentColor;
    [self addSubview:_colorMenuView];
    __weak typeof(self) weakSelf = self;
    _colorMenuView.didSelectedItemBlock = ^(UIColor * _Nonnull textColor) {
        weakSelf.textFld.textColor = textColor;
    };
}

- (void)top_beginEditing {
    [self.textFld becomeFirstResponder];
}

#pragma mark -- 取消
- (void)top_clickCancelBtn {
    [self.textFld resignFirstResponder];
    if (self.top_clickCancelBlock) {
        self.top_clickCancelBlock();
    }
}

#pragma mark -- 确定
- (void)top_clickConfirmBtn {
    [self.textFld resignFirstResponder];
    if (self.top_callTextCompleteBlock) {
        self.top_callTextCompleteBlock(self.textFld.text, self.textFld.textColor, self.fontSize, self.opacityValue);
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
}

#pragma mark -- UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self top_clickConfirmBtn];
    return YES;
}

#pragma mark -- lazy
- (UITextField *)textFld {
    if (!_textFld) {
        _textFld = [[UITextField alloc] initWithFrame:CGRectMake(SSMarginLeft, 10 + 40, CGRectGetWidth(self.bounds) - SSMarginLeft *2, 30)];
        _textFld.textAlignment = NSTextAlignmentNatural;
        _textFld.font = [UIFont systemFontOfSize:18];
        _textFld.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGB(0, 0, 0)];
        _textFld.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textFld.returnKeyType = UIReturnKeyDone;
        _textFld.delegate = self;
        _textFld.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:ViewBgColor];
        _textFld.layer.cornerRadius = 15;
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,10, 0)];
        _textFld.leftView = paddingView;
        _textFld.leftViewMode = UITextFieldViewModeAlways;
    }
    return _textFld;
}

- (NSArray *)top_menuColors {
    NSArray *colors = @[RGB(51, 151, 240),
                        RGB(112, 193, 80),
                        RGB(253, 203, 91),
                        RGB(254, 141, 53),
                        RGB(0, 0, 0),
                        RGB(255, 255, 255),
                        RGB(208, 44, 37),
                        RGB(29, 65, 246),
                        RGB(75, 42, 24),
                        RGB(236, 73, 86),
                        RGB(208, 11, 106),
                        RGB(164, 7, 186)];
    return colors;
}

#pragma mark -- 标题
- (void)top_inputViewTitle {
    UILabel *noClassLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.bounds), 30)];
    noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:TOPAPPGreenColor];
    noClassLab.textAlignment = NSTextAlignmentCenter;
    noClassLab.font = PingFang_M_FONT_(18);
    noClassLab.text = NSLocalizedString(@"topscan_addwatermark", @"");
    [self addSubview:noClassLab];
}

#pragma mark -- 取消、确定按钮
- (void)top_actionView {
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = PingFang_R_FONT_(18);
    [cancelBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
    [self addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(top_clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmlBtn setTitle:NSLocalizedString(@"topscan_ok", @"") forState:UIControlStateNormal];
    confirmlBtn.titleLabel.font = PingFang_R_FONT_(18);
    [confirmlBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
    [self addSubview:confirmlBtn];
    [confirmlBtn addTarget:self action:@selector(top_clickConfirmBtn) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    confirmlBtn.frame = CGRectMake(width - 80, height - 40, 80, 30);
    cancelBtn.frame = CGRectMake(width -  80 - CGRectGetWidth(confirmlBtn.frame) - 50, CGRectGetMinY(confirmlBtn.frame), 80, 30);
}

- (UIView *)top_opacitySliderView {
    UIView *opacityView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.colorMenuView.frame) + 60, CGRectGetWidth(self.bounds), 30)];
    opacityView.backgroundColor = [UIColor clearColor];
    UIImage *noClassImg = [UIImage imageNamed:@"top_waterMark_opacity_black"];
    UIImageView *noClass = [[UIImageView alloc] initWithImage:noClassImg];
    noClass.frame = CGRectMake(SSMarginLeft, 3, 24, 24);
    [opacityView addSubview:noClass];
    UISlider *_sizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(noClass.frame) + 20, 0, CGRectGetWidth(self.bounds) - (CGRectGetMaxX(noClass.frame) + 20 + 20), 30)];
    _sizeSlider.thumbTintColor = kTopicBlueColor;
    _sizeSlider.minimumValue = 0.0;
    _sizeSlider.maximumValue = 1.0;
    _sizeSlider.minimumTrackTintColor = kTopicBlueColor;
    _sizeSlider.maximumTrackTintColor = RGBA(0, 133, 222, 0.2);
    _sizeSlider.value = self.opacityValue;
    _sizeSlider.tag = 100;
     [_sizeSlider addTarget:self action:@selector(top_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [opacityView addSubview:_sizeSlider];
    return opacityView;
}

- (UIView *)top_brushSliderView {
    UIView *brushView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.colorMenuView.frame) + 20, CGRectGetWidth(self.bounds), 30)];
    brushView.backgroundColor = [UIColor clearColor];
    UIImage *noClassImg = [UIImage imageNamed:@"top_waterMark_font_black"];
    UIImageView *noClass = [[UIImageView alloc] initWithImage:noClassImg];
    noClass.frame = CGRectMake(SSMarginLeft, 3, 24, 24);
    [brushView addSubview:noClass];
    UISlider *_sizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(noClass.frame) + 20, 0, CGRectGetWidth(self.bounds) - (CGRectGetMaxX(noClass.frame) + 20 + 20), 30)];
    _sizeSlider.thumbTintColor = kTopicBlueColor;
    _sizeSlider.minimumValue = 10;
    _sizeSlider.maximumValue = 60;
    _sizeSlider.minimumTrackTintColor = kTopicBlueColor;
    _sizeSlider.maximumTrackTintColor = RGBA(0, 133, 222, 0.2);
    _sizeSlider.value = self.fontSize;
    _sizeSlider.tag = 101;
     [_sizeSlider addTarget:self action:@selector(top_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [brushView addSubview:_sizeSlider];
    return brushView;
}

@end
