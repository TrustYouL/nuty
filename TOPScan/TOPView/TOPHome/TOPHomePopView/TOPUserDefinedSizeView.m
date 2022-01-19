#import "TOPUserDefinedSizeView.h"

@interface TOPUserDefinedSizeView ()<UITextFieldDelegate>
@property (strong, nonatomic) UIImageView *logoImgView;//logo
@property (strong, nonatomic) UILabel *titleLab;//标题
@property (strong, nonatomic) UILabel *sizeDesLab;//文件大小描述
@property (strong, nonatomic) UITextField *txtField;//输入框
@property (strong, nonatomic) UIButton *reslutBtn;//确定按钮
@property (strong, nonatomic) UIButton *cancelBtn;//取消按钮
@property (strong, nonatomic) UIView *cancelBtnBGView;

@end

@implementation TOPUserDefinedSizeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        self.fileSize = 0;
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    [self addSubview:self.cancelBtnBGView];
    [self addSubview:self.logoImgView];
    [self addSubview:self.titleLab];
    [self addSubview:self.sizeDesLab];
    [self addSubview:self.txtField];
    [self addSubview:self.reslutBtn];
    [self addSubview:self.cancelBtn];

    [self top_sd_layoutSubViews];
    [self.txtField becomeFirstResponder];
}

- (void)top_sd_layoutSubViews {
    UIView * contentView = self;
    [self.cancelBtnBGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(contentView);
        make.height.mas_equalTo(TOPNavBarAndStatusBarHeight);
    }];
    [self.cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(10);
        make.top.equalTo(contentView).offset(TOPStatusBarHeight);
        make.size.mas_equalTo(CGSizeMake(58, 44));
    }];
    [self.logoImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(self.cancelBtnBGView.mas_bottom).offset(36);
        make.size.mas_equalTo(CGSizeMake(77, 94));
    }];
    [self.titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImgView.mas_bottom).offset(35);
        make.leading.equalTo(contentView).offset(60);
        make.trailing.equalTo(contentView).offset(-60);
        make.height.mas_equalTo(50);
    }];
    [self.reslutBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLab.mas_bottom).offset(22);
        make.trailing.equalTo(contentView).offset(-52);
        make.size.mas_equalTo(CGSizeMake(57, 35));
    }];
    [self.txtField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLab.mas_bottom).offset(22);
        make.leading.equalTo(contentView).offset(52);
        make.trailing.equalTo(self.reslutBtn.mas_leading).offset(-5);
        make.height.mas_equalTo(35);
    }];
    [self.sizeDesLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.txtField.mas_bottom).offset(5);
        make.leading.equalTo(contentView).offset(52);
        make.trailing.equalTo(contentView).offset(-52);
        make.height.mas_equalTo(20);
    }];
}

- (void)setPercentValue:(NSInteger)percentValue {
    _percentValue = percentValue;
    self.txtField.text = [NSString stringWithFormat:@"%@",@(self.percentValue)];
}

- (void)setFileSize:(CGFloat)fileSize {
    _fileSize = fileSize;
    if (!_fileSize) {
        self.sizeDesLab.hidden = YES;
    } else {
        self.sizeDesLab.hidden = NO;
        self.sizeDesLab.text = [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"topscan_about", @""),[TOPDocumentHelper top_memorySizeStr:(self.fileSize * self.percentValue / 100.0)]];
    }
}

#pragma mark -- btn action
- (void)clickResultBtn {
    [self.txtField resignFirstResponder];
    if (self.top_clickResultBtnBlock) {
        self.top_clickResultBtnBlock(self.percentValue);
    }
}

- (void)top_clickCancelBtn {
    [self.txtField resignFirstResponder];
    if (self.top_clickCancelBtnBlock) {
        self.top_clickCancelBtnBlock();
    }
}

#pragma mark -- textField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField.text containsString:@"0"] && string.length > 0) {
        return NO;
    }
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([text integerValue] > 99) {
        return NO;
    }
    _percentValue = !text.length ? 0 : [text integerValue];//置空表示0，取消自定义文件大小这个选项
    self.sizeDesLab.text = [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"topscan_about", @""),[TOPDocumentHelper top_memorySizeStr:(self.fileSize * self.percentValue / 100.0)]];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -- lazy
- (UIImageView *)logoImgView {
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] init];
        _logoImgView.contentMode = UIViewContentModeScaleAspectFill;
        _logoImgView.image = [UIImage imageNamed:@"top_user_filesize"];
    }
    return _logoImgView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLab.numberOfLines = 1;
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        _titleLab.font = PingFang_M_FONT_(17);
        _titleLab.text = NSLocalizedString(@"topscan_userdefinedsize", @"");
    }
    return _titleLab;
}

- (UILabel *)sizeDesLab {
    if (!_sizeDesLab) {
        _sizeDesLab = [[UILabel alloc] init];
        _sizeDesLab.lineBreakMode = NSLineBreakByTruncatingTail;
        _sizeDesLab.numberOfLines = 1;
        _sizeDesLab.textAlignment = NSTextAlignmentNatural;
        _sizeDesLab.textColor = kCommonBlackTextColor;
        _sizeDesLab.font = PingFang_R_FONT_(13);
        _sizeDesLab.text = [NSString stringWithFormat:@"%@(%fM)",NSLocalizedString(@"topscan_about", @""),self.fileSize];
    }
    return _sizeDesLab;
}

- (UITextField *)txtField {
    if (!_txtField) {
        UITextField * titleField = [[UITextField alloc]init];
        titleField.delegate = self;
        titleField.placeholder = NSLocalizedString(@"topscan_filecompressiontitle", @"");
        titleField.font = PingFang_R_FONT_(16);
        titleField.returnKeyType = UIReturnKeyDone;
        titleField.keyboardType = UIKeyboardTypeNumberPad;
        titleField.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewSecondDarkColor defaultColor:kCommonGrayWhiteBgColor];
        titleField.textAlignment = NSTextAlignmentCenter;
        titleField.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        titleField.tintColor = kTopicBlueColor;
        UILabel *percentLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
        percentLab.font = PingFang_R_FONT_(14);
        percentLab.text = @"%  ";
        percentLab.textAlignment = NSTextAlignmentNatural;
        percentLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        titleField.rightView = percentLab;
        titleField.rightViewMode = UITextFieldViewModeAlways;
        titleField.layer.cornerRadius = 5.0;
        _txtField = titleField;
    }
    return _txtField;
}

- (UIButton *)reslutBtn {
    if (!_reslutBtn) {
        _reslutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reslutBtn setTitle:NSLocalizedString(@"topscan_ok", @"") forState:UIControlStateNormal];
        [_reslutBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
        [_reslutBtn setBackgroundColor:kTopicBlueColor];
        _reslutBtn.layer.cornerRadius = 5.0;
        [_reslutBtn addTarget:self action:@selector(clickResultBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reslutBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
        [_cancelBtn setBackgroundColor:[UIColor clearColor]];
        [_cancelBtn addTarget:self action:@selector(top_clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIView *)cancelBtnBGView {
    if (!_cancelBtnBGView) {
        _cancelBtnBGView = [[UIView alloc] init];
        _cancelBtnBGView.backgroundColor = kCommonBlackTextColor;
    }
    return _cancelBtnBGView;
}

@end
