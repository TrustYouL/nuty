#import "TOPDocPasswordView.h"
#import "TOPTextField.h"
@interface TOPDocPasswordView()<UITextFieldDelegate>
@property (nonatomic, strong)UILabel * titleLab;
@property (nonatomic, strong)UIView * tLineView;
@property (nonatomic, strong)UIView * reLineView;
@property (nonatomic, strong)UIButton * eyeBtn;
@property (nonatomic, strong)UIButton * cancelBtn;
@property (nonatomic, strong)UIButton * okBtn;
@property (nonatomic, copy)NSString * againString;
@property (nonatomic, copy)NSString * tFieldString;

@property (nonatomic, strong)UILabel * helpLab;
@property (nonatomic, strong)UIView * helpLine;
@property (nonatomic, strong)UIButton * helpBtn;
@end
@implementation TOPDocPasswordView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.layer.cornerRadius = 10;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont boldSystemFontOfSize:20];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        
        _tField = [TOPTextField new];
        _tField.placeholder = NSLocalizedString(@"topscan_setpasswordlaceholder", @"");
        _tField.tintColor = TOPAPPGreenColor;
        _tField.delegate=self;
        _tField.font=[UIFont systemFontOfSize:12];
        _tField.returnKeyType=UIReturnKeyDone;
        _tField.keyboardType=UIKeyboardTypeNumberPad;
        _tField.backgroundColor= [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
        _tField.textAlignment = NSTextAlignmentNatural;
        _tField.inputAccessoryView = [UIView new];
        _tField.layer.cornerRadius = 5;
        _tField.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _tField.secureTextEntry = YES;
        _tField.layer.cornerRadius = 20;
        [_tField becomeFirstResponder];
        
        UITextInputAssistantItem* item = [_tField inputAssistantItem];
        item.leadingBarButtonGroups = @[];
        item.trailingBarButtonGroups = @[];
        
        _tLineView = [UIView new];
        _tLineView.backgroundColor = [UIColor clearColor];
        
        _againField = [TOPTextField new];
        _againField.placeholder = NSLocalizedString(@"topscan_resetpasswordlaceholder", @"");
        _againField.tintColor = TOPAPPGreenColor;
        _againField.delegate=self;
        _againField.font=[UIFont systemFontOfSize:12];
        _againField.returnKeyType=UIReturnKeyDone;
        _againField.keyboardType=UIKeyboardTypeNumberPad;
        _againField.backgroundColor= [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
        _againField.textAlignment = NSTextAlignmentNatural;
        _againField.inputAccessoryView = [UIView new];
        _againField.layer.cornerRadius = 5;
        _againField.secureTextEntry = YES;
        _againField.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _againField.layer.cornerRadius = 20;
        
        _reLineView = [UIView new];
        _reLineView.backgroundColor = [UIColor clearColor];
        
        _eyeBtn = [UIButton new];
        _eyeBtn.selected = NO;
        _eyeBtn.backgroundColor = [UIColor clearColor];
        [_eyeBtn setImage:[UIImage imageNamed:@"top_dismissPassword"] forState:UIControlStateNormal];
        [_eyeBtn setImage:[UIImage imageNamed:@"top_showPassword"] forState:UIControlStateSelected];
        [_eyeBtn addTarget:self action:@selector(top_eyebtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _cancelBtn = [UIButton new];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [_cancelBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(top_cancelAction) forControlEvents:UIControlEventTouchUpInside];
        
        _okBtn = [UIButton new];
        _okBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [_okBtn setTitle:NSLocalizedString(@"topscan_ok", @"") forState:UIControlStateNormal];
        [_okBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [_okBtn addTarget:self action:@selector(top_okAction) forControlEvents:UIControlEventTouchUpInside];
        
        _helpLab = [UILabel new];
        _helpLab.font = [UIFont systemFontOfSize:11];
        _helpLab.textAlignment = NSTextAlignmentNatural;
        _helpLab.textColor = TOPAPPGreenColor;
        
        _helpLine = [UIView new];
        _helpLine.backgroundColor = TOPAPPGreenColor;
        
        _helpBtn = [UIButton new];
        _helpBtn.backgroundColor = [UIColor clearColor];
        [_helpBtn addTarget:self action:@selector(top_helpAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setActionType:(NSInteger)actionType{
    _actionType = actionType;
    if (_actionType == TOPHomeMoreFunctionSetLockFirst || _actionType == TOPHomeMoreFunctionPDFPassword) {
        _titleLab.text = NSLocalizedString(@"topscan_setpasswordtitle", @"");
        if (_actionType == TOPHomeMoreFunctionPDFPassword) {
            _titleLab.text = NSLocalizedString(@"topscan_setpdfpasswordtitle", @"");
        }
        [self addSubview:_titleLab];
        [self addSubview:_tField];
        [self addSubview:_tLineView];
        [self addSubview:_againField];
        [self addSubview:_reLineView];
        [self addSubview:_eyeBtn];
        [self addSubview:_cancelBtn];
        [self addSubview:_okBtn];
        [self top_setReFream];
    }else{
        _titleLab.text = NSLocalizedString(@"topscan_resetpasswordtitle", @"");
        _helpLab.text = NSLocalizedString(@"topscan_passwordhelptip", @"");
        [self addSubview:_titleLab];
        [self addSubview:_tField];
        [self addSubview:_tLineView];
        [self addSubview:_eyeBtn];
        [self addSubview:_cancelBtn];
        [self addSubview:_okBtn];
        [self addSubview:_helpLab];
        [self addSubview:_helpLine];
        [self addSubview:_helpBtn];
        [self top_setFream];
    }
}

- (void)top_beginEditing {
    if (![_tField isFirstResponder]) {
        [_tField becomeFirstResponder];
    }
}

- (void)top_setReFream{
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(20);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
    [_tField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(30);
        make.trailing.equalTo(self).offset(-30);
        make.top.equalTo(_titleLab.mas_bottom).offset(20);
        make.height.mas_equalTo(40);
    }];
    [_tLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tField.mas_bottom).offset(3);
        make.leading.equalTo(self).offset(30);
        make.trailing.equalTo(self).offset(-30);
        make.height.mas_equalTo(1.0);
    }];
    [_eyeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_tField.mas_centerY);
        make.trailing.equalTo(self).offset(-40);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_againField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tField.mas_bottom).offset(20);
        make.leading.equalTo(self).offset(30);
        make.trailing.equalTo(self).offset(-30);
        make.height.mas_equalTo(40);
    }];
    [_reLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_againField.mas_bottom).offset(3);
        make.leading.equalTo(self).offset(30);
        make.trailing.equalTo(self).offset(-30);
        make.height.mas_equalTo(1.0);
    }];
    [_cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(_okBtn.mas_leading);
        make.bottom.equalTo(self).offset(-10);
        make.height.mas_equalTo(40);
    }];
    [_okBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self);
        make.bottom.equalTo(self).offset(-10);
        make.height.mas_equalTo(40);
        make.width.equalTo(_cancelBtn);
    }];
}

- (void)top_setFream{
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(20);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
    [_tLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(25);
        make.leading.equalTo(self).offset(30);
        make.trailing.equalTo(self).offset(-30);
        make.height.mas_equalTo(1.0);
    }];
    [_tField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(30);
        make.trailing.equalTo(self).offset(-30);
        make.bottom.equalTo(_tLineView.mas_top).offset(-15);
        make.height.mas_equalTo(40);
    }];
    [_eyeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_tField.mas_centerY);
        make.trailing.equalTo(self).offset(-40);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    CGFloat textW = [TOPDocumentHelper top_getSizeWithStr:_helpLab.text Height:11 Font:11].width;
    [_helpLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(45);
        make.top.equalTo(_tField.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(textW+10, 11));
    }];
    [_helpLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(45);
        make.top.equalTo(_helpLab.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(textW, 0.8));
    }];
    [_helpBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(45);
        make.top.equalTo(_tField.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(textW+10, 30));
    }];
    [_cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(_okBtn.mas_leading);
        make.bottom.equalTo(self).offset(-10);
        make.height.mas_equalTo(40);
    }];
    [_okBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self);
        make.bottom.equalTo(self).offset(-10);
        make.height.mas_equalTo(40);
        make.width.equalTo(_cancelBtn);
    }];
}

- (void)top_eyebtnAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    _tField.secureTextEntry = !sender.selected;
    _againField.secureTextEntry = !sender.selected;
    
    if (_tField.isFirstResponder) {
        [_tField becomeFirstResponder];
    }
    
    if (_againField.isFirstResponder) {
        [_againField becomeFirstResponder];
    }
}

- (void)top_cancelAction{
    [self top_hiddenkeyboard];
    if (self.top_clickToHide) {
        self.top_clickToHide();
    }
}

- (void)top_okAction{
    if (_tField.text.length>0) {
        [self top_hiddenkeyboard];
        if (_actionType == TOPHomeMoreFunctionSetLockFirst || _actionType == TOPHomeMoreFunctionPDFPassword) {
            if ([_tField.text isEqualToString:_againField.text]) {
                if (self.top_sendPassword) {
                    self.top_sendPassword(_tField.text, _actionType,NO);
                }
            }else{
                [[TOPCornerToast shareInstance]makeToast:NSLocalizedString(@"topscan_writetwopasswordfail", @"") duration:1];
            }
        }else{
            if (self.top_sendPassword) {
                self.top_sendPassword(_tField.text, _actionType,YES);
            }
        }
    }
}

- (void)top_helpAction{
    if (self.top_clickToHelp) {
        self.top_clickToHelp();
    }
}
- (void)top_hiddenkeyboard {
    if ([_tField isFirstResponder]) {
        [_tField resignFirstResponder];
    }
    if ([_againField isFirstResponder]) {
        [_againField resignFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == _tField) {
        _tFieldString = text;
    }

    if (textField == _againField) {
        _againString = text;
    }
    
    if (_actionType != TOPHomeMoreFunctionSetLockFirst && _actionType != TOPHomeMoreFunctionPDFPassword) {
        if (self.top_sendPassword) {
            self.top_sendPassword(text, _actionType,NO);
        }
    }
    
    return YES;
}

@end
