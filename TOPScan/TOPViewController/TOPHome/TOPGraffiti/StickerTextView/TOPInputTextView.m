#import "TOPInputTextView.h"
#import "TOPColorMenuView.h"

@interface TOPInputTextView()<UIGestureRecognizerDelegate, UITextViewDelegate>
@property (strong, nonatomic) TOPColorMenuView *colorMenuView;

@end

@implementation TOPInputTextView
#define InputViewHeight 160
- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 14;
        self.layer.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(248, 248, 248, 1.0)].CGColor;
        CGFloat keyBorad_H = 0.0;
        if (IS_IPAD) {
            keyBorad_H = 430;
        }else{
            keyBorad_H = kIs_iPhoneX ? 350 : 295;
        }
        self.frame = CGRectMake(20, TOPScreenHeight - keyBorad_H - TOPBottomSafeHeight - 10 - InputViewHeight, TOPScreenWidth - 20*2, InputViewHeight);
        [self top_configContentView];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.layer.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(248, 248, 248, 1.0)].CGColor;
}
- (void)top_configContentView {
    [self addSubview:self.textFld];
    [self setColorMenuView];
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
        self.top_callTextCompleteBlock(self.textFld.text, self.textFld.textColor);
    }
}

#pragma mark -- lazy
- (UITextView *)textFld {
    if (!_textFld) {
        _textFld = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(self.bounds) - 40, 30)];
        _textFld.textAlignment = NSTextAlignmentNatural;
        _textFld.font = [UIFont systemFontOfSize:18];
        _textFld.tintColor = TOPAPPGreenColor;
        _textFld.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:[UIColor blackColor]];
        _textFld.layer.cornerRadius = 15;
        _textFld.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:ViewBgColor];
        _textFld.delegate = self;
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

#pragma mark -- 取消、确定按钮
- (void)top_actionView {
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:[NSLocalizedString(@"topscan_cancel", @"") uppercaseString] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
    [self addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(top_clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmlBtn setTitle:NSLocalizedString(@"topscan_ok", @"") forState:UIControlStateNormal];
    confirmlBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [confirmlBtn setTitleColor:kTopicBlueColor forState:UIControlStateNormal];
    [self addSubview:confirmlBtn];
    [confirmlBtn addTarget:self action:@selector(top_clickConfirmBtn) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    confirmlBtn.frame = CGRectMake(width - 80, height - 40, 80, 40);
    cancelBtn.frame = CGRectMake(width -  80 - CGRectGetWidth(confirmlBtn.frame), CGRectGetMinY(confirmlBtn.frame), 80, 40);
    
    [confirmlBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).with.offset(0);
        make.bottom.equalTo(self).with.offset(0);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(80);
    }];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(confirmlBtn.mas_leading).with.offset(5);
        make.bottom.equalTo(self).with.offset(0);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(80);
    }];
     
}

#pragma mark -- textview delegate
- (void)textViewDidChange:(UITextView *)textView {
    [self getTextViewHeightWithText:textView.text];
}

#pragma mark -- textView Height
- (void)getTextViewHeightWithText:(NSString *)text {
    CGFloat viewH = [TOPAppTools sizeLineFeedWithFont:18 textSizeWidht:CGRectGetWidth(self.bounds) - 40 text:text];
    if (viewH < 30) {
        viewH = 30;
    }
    [self updateAllSubViewsLayout:viewH];
}

#pragma mark -- 更新各子视图的位置
- (void)updateAllSubViewsLayout:(CGFloat)viewH {
    CGRect frame = self.frame;
    frame.size.height = InputViewHeight - 30 + viewH;
    
    CGFloat keyBorad_H = 0.0;
    if (IS_IPAD) {
        keyBorad_H = 430;
    }else{
        keyBorad_H = kIs_iPhoneX ? 350 : 295;

    }
    frame.origin.y = TOPScreenHeight - keyBorad_H - TOPBottomSafeHeight - 10 - InputViewHeight - (viewH - 30);
    self.frame = frame;
    
    CGRect textFrame = self.textFld.frame;
    textFrame.size.height = viewH;
    self.textFld.frame = textFrame;
    
    CGRect menuFrame = self.colorMenuView.frame;
    menuFrame.origin.y = CGRectGetMaxY(self.textFld.frame);
    self.colorMenuView.frame = menuFrame;
}

@end
