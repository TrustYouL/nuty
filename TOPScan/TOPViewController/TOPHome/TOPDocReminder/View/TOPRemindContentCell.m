   #import "TOPRemindContentCell.h"

@implementation TOPRemindContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _textView = [UITextView new];
        _textView.tintColor = TOPAPPGreenColor;
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.textAlignment = NSTextAlignmentNatural;
        _textView.editable = YES;
        _textView.scrollEnabled = YES;
        _textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
        _textView.returnKeyType = UIReturnKeyDefault;
        _textView.keyboardType = UIKeyboardTypeDefault;
        _textView.inputAccessoryView = [UIView new];
        _textView.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:[UIColor grayColor]];
        _textView.delegate = self;
        _textView.layer.masksToBounds = YES;
        _textView.layer.cornerRadius = 10;
        _textView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:RGBA(235, 235, 235, 1.0)];
        [self.contentView addSubview:_textView];
        [self top_setViewFream];
    }
    return self;
}

- (void)top_setViewFream{
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.leading.equalTo(self.contentView).offset(20);
        make.bottom.equalTo(self.contentView).offset(-10);
        make.trailing.equalTo(self.contentView).offset(-20);
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
//开始编辑
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:_placerString]) {
        textView.text = @"";
    }
    textView.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    if (self.top_startEdit) {
        self.top_startEdit(_textView);
    }
}
//结束编辑
- (void)textViewDidEndEditing:(UITextView *)textView{
    if (self.top_sendEditcontent) {
        self.top_sendEditcontent(textView.text, _row);
    }
    
    if (textView.text.length<1) {
        textView.text = _placerString;
        textView.textColor = [UIColor grayColor];
    }
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
