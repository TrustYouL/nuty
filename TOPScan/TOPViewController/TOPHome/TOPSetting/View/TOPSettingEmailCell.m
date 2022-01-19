#import "TOPSettingEmailCell.h"

@implementation TOPSettingEmailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _titleLab = [UILabel new];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.font = [UIFont boldSystemFontOfSize:18];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        
        _titleField = [UITextField new];
        _titleField.delegate=self;
        _titleField.font=[UIFont systemFontOfSize:15];
        _titleField.returnKeyType=UIReturnKeyDone;
        _titleField.keyboardType=UIKeyboardTypeDefault;
        _titleField.backgroundColor=[UIColor clearColor];
        _titleField.textAlignment = NSTextAlignmentNatural;
        _titleField.tintColor = TOPAPPGreenColor;
        _titleField.inputAccessoryView = [UIView new];
        
        _textView = [UITextView new];
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.textAlignment = NSTextAlignmentNatural;
        _textView.editable = YES;
        _textView.scrollEnabled = YES;
        _textView.returnKeyType = UIReturnKeyDefault;
        _textView.keyboardType = UIKeyboardTypeDefault;
        _textView.inputAccessoryView = [UIView new];
        _textView.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:[UIColor grayColor]];
        _textView.delegate = self;
        _textView.tintColor = TOPAPPGreenColor;
        _textView.contentInset = UIEdgeInsetsMake(0, -5, 0, 0);
        _textView.showsVerticalScrollIndicator = NO;
        _textView.backgroundColor = [UIColor clearColor];
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(234, 234, 234, 1.0)];

        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_titleField];
        [self.contentView addSubview:_textView];
        [self.contentView addSubview:_lineView];

    }
    return self;
}

- (void)setModel:(TOPSettingEmailModel *)model{
    _model = model;
}

- (void)setRow:(NSInteger)row{
    UIView * contentView = self.contentView;
    _row = row;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(20);
        make.top.equalTo(contentView).offset(10);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
    [_titleField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(20);
        make.trailing.equalTo(contentView).offset(-20);
        make.bottom.equalTo(contentView).offset(-3);
        make.height.mas_equalTo(20);
    }];
    [_textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(20);
        make.trailing.equalTo(contentView).offset(-20);
        make.bottom.equalTo(contentView).offset(-3);
        make.top.equalTo(_titleLab.mas_bottom).offset(5);
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(20);
        make.trailing.equalTo(contentView).offset(-20);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
    
    if (_row == 0) {
        _titleLab.text = [NSLocalizedString(@"topscan_myselfemailshow", @"")  stringByAppendingString:@" :"];
        _titleField.text = _model.myselfEmail;
        _titleField.placeholder = [NSLocalizedString(@"topscan_email", @"") stringByAppendingString:@" :"];
        _textView.hidden = YES;
        _titleField.hidden = NO;
        _lineView.hidden = NO;
    }else if (_row == 1){
        _titleLab.text = NSLocalizedString(@"topscan_toemailtitle", @"");
        _titleField.text = _model.toEmail;
        _titleField.placeholder = NSLocalizedString(@"topscan_email", @"");
        _textView.hidden = YES;
        _titleField.hidden = NO;
        _lineView.hidden = NO;
    }else if (_row == 2){
        _titleLab.text = [NSLocalizedString(@"topscan_subjectplaceholder", @"") stringByAppendingString:@" :"];
        _titleField.text = _model.subject;
        _titleField.placeholder = NSLocalizedString(@"topscan_subjectplaceholder", @"");
        _textView.hidden = YES;
        _titleField.hidden = NO;
        _lineView.hidden = NO;
    }else{
        _titleLab.text = [NSLocalizedString(@"topscan_bodyplaceholder", @"")  stringByAppendingString:@" :"];
        _titleField.text = _model.body;
        _titleField.placeholder = NSLocalizedString(@"topscan_bodyplaceholder", @"");
        _textView.hidden = NO;
        _titleField.hidden = YES;
        _lineView.hidden = YES;
        if (!_model.body.length) {
            _textView.text = NSLocalizedString(@"topscan_bodyplaceholder", @"");
            _textView.textColor = [UIColor grayColor];
        }else{
            _textView.text = _model.body;
            _textView.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        }
    }
}

- (void)setIsKeyBoardShow:(BOOL)isKeyBoardShow{
    _isKeyBoardShow = isKeyBoardShow;
    if (_isKeyBoardShow) {
        if (_row == 0) {
            [_titleField becomeFirstResponder];
        }
    }
}

- (void)setIsKeyBoardHide:(BOOL)isKeyBoardHide{
    _isKeyBoardHide = isKeyBoardHide;
    if (_isKeyBoardHide) {
        [_textView resignFirstResponder];
        [_titleField resignFirstResponder];
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
    if (self.top_beginEdit)
    {
        self.top_beginEdit(_row);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.top_sendTextFieldText)
    {
        self.top_sendTextFieldText(text,_row);
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.top_returnEdit) {
        self.top_returnEdit();
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [_titleField resignFirstResponder];
    if (self.top_returnEdit) {
        self.top_returnEdit();
    }
    return YES;
}

#pragma mark -- textViewDelegate
//开始编辑
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:NSLocalizedString(@"topscan_bodyplaceholder", @"")]) {
        textView.text = @"";
    }
    textView.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    [textView becomeFirstResponder];
}

//结束编辑
- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length<1) {
        textView.text = NSLocalizedString(@"topscan_bodyplaceholder", @"");
        textView.textColor = [UIColor grayColor];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString * sendStr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (self.top_sendTextFieldText)
    {
        self.top_sendTextFieldText(sendStr,_row);
    }
    return YES;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
