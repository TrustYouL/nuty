#import "TOPPhotoShowNoteView.h"
@interface TOPPhotoShowNoteView()<UITextViewDelegate>
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIButton * cancelBtn;
@property (nonatomic ,strong)UIButton * doneBtn;
@property (nonatomic ,assign)CGFloat keyboardH;
@property (nonatomic ,copy)NSString * sendString;
@end
@implementation TOPPhotoShowNoteView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5.0;
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    _textView = [UITextView new];
    _textView.tintColor = TOPAPPGreenColor;
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.textAlignment = NSTextAlignmentNatural;
    _textView.editable = YES;
    _textView.scrollEnabled = YES;
    _textView.textContainerInset = UIEdgeInsetsMake(10, 10, 25, 10);
    _textView.returnKeyType = UIReturnKeyDefault;
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.inputAccessoryView = [UIView new];
    _textView.textColor = [UIColor grayColor];
    _textView.delegate = self;
    
    _titleLab = [UILabel new];
    _titleLab.font = [UIFont boldSystemFontOfSize:18];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    _titleLab.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPBackgroundGrayColor];
    
    _cancelBtn = [UIButton new];
    _cancelBtn.backgroundColor = [UIColor clearColor];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancelBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(top_clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    
    _doneBtn = [UIButton new];
    _doneBtn.backgroundColor = [UIColor clearColor];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(top_clickDoneBtn) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:_textView];
    [self addSubview:_titleLab];
    [self addSubview:_cancelBtn];
    [self addSubview:_doneBtn];
    [self top_setupFream];
}

- (void)top_setupFream{
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    [_cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.centerY.equalTo(_titleLab.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    [_doneBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-15);
        make.centerY.equalTo(_titleLab.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    [_textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.top.equalTo(_titleLab.mas_bottom).offset(1);
    }];
    
    _cancelBtn.hidden = YES;
    _doneBtn.hidden = YES;
    [_cancelBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];

    [_doneBtn setTitle:NSLocalizedString(@"topscan_tagsdone", @"") forState:UIControlStateNormal];
    
    _titleLab.text = NSLocalizedString(@"topscan_note", @"");
    _textView.text = NSLocalizedString(@"topscan_noteplaceholder", @"");
}

- (void)top_clickCancelBtn{
    if (self.top_sendTextViewContent) {
        self.top_sendTextViewContent(self.noteString);
    }
    [self top_changeState];
}

- (void)top_clickDoneBtn{
    if (self.top_sendTextViewContent) {
        self.top_sendTextViewContent(_textView.text);
    }
    [self top_changeState];
}

#pragma mark -- 改变按钮显示状态和编辑框编辑状态
- (void)top_changeState{
    [_textView resignFirstResponder];
    _textView.scrollEnabled = YES;
    _cancelBtn.hidden = YES;
    _doneBtn.hidden = YES;
}

//开始编辑
- (void)textViewDidBeginEditing:(UITextView *)textView{
    _cancelBtn.hidden = NO;
    _doneBtn.hidden = NO;
    if ([textView.text isEqualToString:NSLocalizedString(@"topscan_noteplaceholder", @"")]) {
        textView.text = @"";
    }
    textView.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
}

//结束编辑
- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length<1) {
        textView.text = NSLocalizedString(@"topscan_noteplaceholder", @"");
        textView.textColor = [UIColor grayColor];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

- (void)setNoteString:(NSString *)noteString{
    _noteString = noteString;
    _textView.text = _noteString;
    _textView.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
}

@end
