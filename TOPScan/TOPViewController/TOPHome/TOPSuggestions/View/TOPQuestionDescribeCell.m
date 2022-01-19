#import "TOPQuestionDescribeCell.h"

@implementation TOPQuestionDescribeCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];

        _textView = [UITextView new];
        _textView.tintColor = TOPAPPGreenColor;
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.textAlignment = NSTextAlignmentNatural;
        _textView.editable = YES;
        _textView.scrollEnabled = YES;
        _textView.textContainerInset = UIEdgeInsetsMake(11, 10, 10, 10);
        _textView.returnKeyType = UIReturnKeyDefault;
        _textView.keyboardType = UIKeyboardTypeDefault;
        _textView.inputAccessoryView = [UIView new];
        _textView.textColor = [UIColor grayColor];
        _textView.delegate = self;
        _textView.layer.masksToBounds = YES;
        _textView.layer.cornerRadius = 10;
        _textView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        [self.contentView addSubview:_textView];
        [self top_setViewFream];
    }
    return self;
}

- (void)top_setViewFream{
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(15);
        make.trailing.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-5);
    }];
}

- (void)setRow:(NSInteger)row{
    _row = row;
}

- (void)setTextContent:(NSString *)textContent{
    _textContent = textContent;
    _textView.text = textContent;
    _textView.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];

}
- (void)setPlacerString:(NSString *)placerString{
    _placerString = placerString;
    if (_textContent.length == 0) {
        _textView.text = placerString;
        _textView.textColor = [UIColor grayColor];
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:_placerString]) {
        textView.text = @"";
    }
    textView.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    if (self.top_startEdit) {
        self.top_startEdit(_textView);
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if (self.top_sendEditcontent) {
        self.top_sendEditcontent(textView.text, _row);
    }
    
    if (textView.text.length<1) {
        textView.text = _placerString;
        textView.textColor = [UIColor grayColor];
    }
}

@end
