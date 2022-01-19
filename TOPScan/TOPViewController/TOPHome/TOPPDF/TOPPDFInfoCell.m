#import "TOPPDFInfoCell.h"

@interface TOPPDFInfoCell ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *cellContentFld;
@property (nonatomic, strong) UIButton *editBtn;

@end

#define SSMarginLeft 16

@implementation TOPPDFInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self top_configContentView];
    }
    return self;
}
- (void)top_configContentView {
    [self.contentView addSubview:self.cellContentFld];
    [self.contentView addSubview:self.editBtn];
    [self top_sd_layoutSubViews];
}
- (void)top_sd_layoutSubViews {
    UIView *contentView = self.contentView;
    [self.cellContentFld mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(contentView);
        make.leading.equalTo(contentView).offset(16);
        make.trailing.equalTo(contentView).offset(-60);
    }];
    [self.editBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.trailing.equalTo(contentView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
}
- (void)setCellContent:(NSString *)cellContent {
    _cellContent = cellContent;
    _cellContentFld.text = _cellContent;
}
- (void)top_clickEditBtn {
    [self.cellContentFld becomeFirstResponder];
}
#pragma mark -- 确定
- (void)top_clickConfirmBtn {
    [self.cellContentFld resignFirstResponder];
    if (self.top_didEditedBlock) {
        self.top_didEditedBlock(self.cellContentFld.text);
    }
}
#pragma mark -- UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self top_clickConfirmBtn];
    return YES;
}
#pragma mark -- lazy
- (UITextField *)cellContentFld {
    if (!_cellContentFld) {
        _cellContentFld = [[UITextField alloc] initWithFrame:self.bounds];
        _cellContentFld.tintColor = TOPAPPGreenColor;
        _cellContentFld.textAlignment = NSTextAlignmentNatural;
        _cellContentFld.font = PingFang_R_FONT_(16);
        _cellContentFld.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        _cellContentFld.clearButtonMode = UITextFieldViewModeWhileEditing;
        _cellContentFld.returnKeyType = UIReturnKeyDone;
        _cellContentFld.delegate = self;
    }
    return _cellContentFld;
}
- (UIButton *)editBtn {
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editBtn setImage:[UIImage imageNamed:@"top_tagFooter"] forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(top_clickEditBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}
@end
