#import "TOPSettingEmailAgainView.h"
#import "TOPSettingEmailModel.h"
@interface TOPSettingEmailAgainView()<UITextFieldDelegate>
@property (nonatomic ,copy)NSString * tFString;

@property (nonatomic ,strong)TOPSettingEmailModel * emailModel;
@end

@implementation TOPSettingEmailAgainView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.emailModel = [TOPSettingEmailModel new];
        self.emailModel = [NSKeyedUnarchiver unarchiveObjectWithFile:TOPSettingEmail_Path];
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        [self top_creatUI];
    }
    return self;
}

- (void)top_creatUI{
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, self.bounds.size.width-30, 20)];
    titleLab.font = [UIFont boldSystemFontOfSize:18];
    titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    titleLab.textAlignment = NSTextAlignmentNatural;
    titleLab.text = NSLocalizedString(@"topscan_myselfemailshow", @"");
   
    UITextField * titleField = [[UITextField alloc]initWithFrame:CGRectMake(15, titleLab.bounds.origin.y+titleLab.frame.size.height+15, self.bounds.size.width-30, 20)];
    titleField.delegate=self;
    titleField.placeholder = NSLocalizedString(@"topscan_email", @"");
    titleField.font=[UIFont systemFontOfSize:16];
    titleField.returnKeyType=UIReturnKeyDone;
    titleField.keyboardType=UIKeyboardTypeDefault;
    titleField.backgroundColor=[UIColor clearColor];
    titleField.textAlignment = NSTextAlignmentNatural;
    titleField.tintColor = TOPAPPGreenColor;
    titleField.inputAccessoryView = [UIView new];
    
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(15, titleField.bounds.origin.y+titleField.frame.size.height+3, self.bounds.size.width-30, 1)];
    lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(158, 158, 158, 1.0)];
    
    UILabel * warnLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, lineView.bounds.origin.y+1+15, self.bounds.size.width-30, (40))];
    warnLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    warnLabel.numberOfLines = 2;
    warnLabel.textAlignment = NSTextAlignmentNatural;
    warnLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    warnLabel.font = [self fontsWithSize:16];
    warnLabel.text = NSLocalizedString(@"topscan_emailsettingguide", @"");
   
    //ok按钮
    UIButton * saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-90, warnLabel.bounds.origin.y+warnLabel.frame.size.height+15, 80, 60)];
    saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [saveBtn setTitle:[NSLocalizedString(@"topscan_batchsave", @"") uppercaseString] forState:UIControlStateNormal];
    [saveBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(top_clickSaveBtn) forControlEvents:UIControlEventTouchUpInside];
    
    //cancel按钮
    UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-90-90, warnLabel.bounds.origin.y+warnLabel.frame.size.height+15, 80, 60)];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [cancelBtn setTitle:[NSLocalizedString(@"topscan_cancel", @"") uppercaseString] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(top_clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:titleLab];
    [self addSubview:titleField];
    [self addSubview:lineView];
    [self addSubview:warnLabel];
    [self addSubview:saveBtn];
    [self addSubview:cancelBtn];
    [titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.top.equalTo(self).offset(15);
        make.height.mas_equalTo(20);
    }];
    [titleField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.trailing.equalTo(self).offset(-15);
        make.top.equalTo(titleLab.mas_bottom).offset(15);
        make.height.mas_equalTo(20);
    }];
    [lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.trailing.equalTo(self).offset(-15);
        make.top.equalTo(titleField.mas_bottom).offset(3);
        make.height.mas_equalTo(1);
    }];
    [warnLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.trailing.equalTo(self).offset(-15);
        make.top.equalTo(lineView.mas_bottom).offset(15);
        make.height.mas_equalTo(40);
    }];
    [saveBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-10);
        make.top.equalTo(warnLabel.mas_bottom).offset(15);
        make.size.mas_equalTo(CGSizeMake(80, 60));
    }];
    [cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(saveBtn.mas_leading).offset(-10);
        make.top.equalTo(warnLabel.mas_bottom).offset(15);
        make.size.mas_equalTo(CGSizeMake(80, 60));
    }];
}

- (void)top_clickSaveBtn{
    TOPSettingEmailModel * model = [TOPSettingEmailModel new];
    model = self.emailModel;
    if (self.contentType == 1) {
        if ([TOPDocumentHelper top_validateEmail:self.tFString]) {
            model.toEmail = self.tFString;
            self.emailModel = model;
            BOOL saveState = [NSKeyedArchiver archiveRootObject:self.emailModel toFile:TOPSettingEmail_Path];
            if (saveState) {
                NSLog(@"成功");
                if (self.top_sendBackEmail) {
                    self.top_sendBackEmail(self.tFString);
                }
            }
        }
    }
    if (self.contentType == 2) {
        if ([TOPDocumentHelper top_validateEmail:self.tFString]) {
            model.myselfEmail = self.tFString;
            self.emailModel = model;
            BOOL saveState = [NSKeyedArchiver archiveRootObject:self.emailModel toFile:TOPSettingEmail_Path];
            if (saveState) {
                NSLog(@"成功");
                if (self.top_sendBackEmail) {
                    self.top_sendBackEmail(self.tFString);
                }
            }
        }
    }
    if (self.top_returnEdit) {
        self.top_returnEdit(); 
    }
    
    if (![TOPDocumentHelper top_validateEmail:self.tFString]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topscan_questioninvalidemail", @"")];
        [SVProgressHUD dismissWithDelay:1];
    }
}

- (void)top_clickCancelBtn{
    if (self.top_returnEdit) {
        self.top_returnEdit();
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];

    self.tFString = text;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self top_clickSaveBtn];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
