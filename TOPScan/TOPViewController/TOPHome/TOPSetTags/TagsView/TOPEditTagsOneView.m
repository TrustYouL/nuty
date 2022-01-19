#import "TOPEditTagsOneView.h"
@interface TOPEditTagsOneView()<UITextFieldDelegate>
@property (nonatomic,strong)UIView * shadowView;
@property (nonatomic,strong)UIView * grayView;
@property (nonatomic,strong)UIImageView * picImg;
@property (nonatomic,strong)UILabel * titleLab;
@property (nonatomic,strong)UILabel * timeLab;
@property (nonatomic,strong)UIImageView * iconImg;
@property (nonatomic,strong)UILabel * tagsLab;
@property (nonatomic,strong)UIButton * cancelBtn;
@property (nonatomic,strong)UIButton * okBtn;
@end
@implementation TOPEditTagsOneView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        [self top_setupUI];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    if ([TOPDocumentHelper top_isdark]) {
        _shadowView.layer.masksToBounds = YES;
    }else{
        _shadowView.layer.masksToBounds = NO;
    }
}
- (void)top_setupUI{
    _shadowView = [UIView new];
    _shadowView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _shadowView.layer.cornerRadius = 5;
    _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    _shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    _shadowView.layer.shadowOpacity = 0.3;
    _shadowView.clipsToBounds = NO;
    if ([TOPDocumentHelper top_isdark]) {
        _shadowView.layer.masksToBounds = YES;
    }else{
        _shadowView.layer.masksToBounds = NO;
    }
    _grayView = [UIView new];
    _grayView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:RGBA(230, 230, 230, 1.0)];
    
    _picImg = [UIImageView new];
    _picImg.image = [UIImage imageNamed:@"top_docIcon"];
    
    _titleLab = [UILabel new];
    _titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    _titleLab.textAlignment = NSTextAlignmentNatural;
    _titleLab.font = [self fontsWithSize:15];
    _titleLab.backgroundColor = [UIColor clearColor];
    
    _timeLab = [[UILabel alloc] init];
    _timeLab.textColor = RGBA(153, 153, 153, 1.0);
    _timeLab.font = [self fontsWithSize:12];
    _timeLab.textAlignment = NSTextAlignmentNatural;
    
    _iconImg = [UIImageView new];
    _iconImg.image = [UIImage imageNamed:@"top_biaoqian"];

    _tagsLab = [UILabel new];
    _tagsLab.lineBreakMode = NSLineBreakByTruncatingTail;
    _tagsLab.textColor = RGBA(153, 153, 153, 1.0);
    _tagsLab.textAlignment = NSTextAlignmentNatural;
    _tagsLab.font = [self fontsWithSize:12];
    _tagsLab.backgroundColor = [UIColor clearColor];
    
    _tField = [UITextField new];
    _tField.tintColor = TOPAPPGreenColor;
    _tField.delegate=self;
    _tField.font=[UIFont systemFontOfSize:15];
    _tField.returnKeyType=UIReturnKeyDone;
    _tField.keyboardType=UIKeyboardTypeDefault;
    _tField.backgroundColor=[UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:RGBA(230, 230, 230, 1.0)];
    _tField.textAlignment = NSTextAlignmentCenter;
    _tField.inputAccessoryView = [UIView new];
    _tField.layer.cornerRadius = 5;
    [_tField becomeFirstResponder];

    _cancelBtn = [UIButton new];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_cancelBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(top_clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    
    _okBtn = [UIButton new];
    _okBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_okBtn setTitle:NSLocalizedString(@"topscan_ok", @"") forState:UIControlStateNormal];
    [_okBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [_okBtn addTarget:self action:@selector(top_clickOkBtn) forControlEvents:UIControlEventTouchUpInside];
   
    [self addSubview:_shadowView];
    [self addSubview:_tField];
    [self addSubview:_cancelBtn];
    [self addSubview:_okBtn];
    [_shadowView addSubview:_grayView];
    [_shadowView addSubview:_picImg];
    [_shadowView addSubview:_titleLab];
    [_shadowView addSubview:_timeLab];
    [_shadowView addSubview:_iconImg];
    [_shadowView addSubview:_tagsLab];
    [self top_setupFream];
}

- (void)top_setupFream{
    [_shadowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(25);
        make.size.mas_equalTo(CGSizeMake(170, 165));
    }];
    [_tField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(_shadowView.mas_bottom).offset(15);
        make.size.mas_equalTo(CGSizeMake(210, 45));
    }];
    [_cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.equalTo(self);
        make.top.equalTo(_tField.mas_bottom).offset(10);
        make.trailing.equalTo(_okBtn.mas_leading);
    }];
    [_okBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.equalTo(self);
        make.top.equalTo(_tField.mas_bottom).offset(10);
        make.width.equalTo(_cancelBtn);
    }];
    [_grayView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(_shadowView);
        make.height.mas_equalTo(100);
    }];
    [_picImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_shadowView);
        make.top.equalTo(_shadowView).offset(10);
        make.size.mas_equalTo(CGSizeMake(70, 80));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_shadowView).offset(10);
        make.trailing.equalTo(_shadowView).offset(-10);
        make.top.equalTo(_grayView.mas_bottom).offset(5);
        make.height.mas_equalTo(15);
    }];
    [_timeLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_shadowView).offset(10);
        make.trailing.equalTo(_shadowView).offset(-10);
        make.top.equalTo(_titleLab.mas_bottom).offset(5);
        make.height.mas_equalTo(15);
    }];
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_shadowView).offset(10);
        make.top.equalTo(_timeLab.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(23/2, 23/2));
    }];
    [_tagsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImg.mas_trailing).offset(5);
        make.trailing.equalTo(_shadowView).offset(-10);
        make.top.equalTo(_timeLab.mas_bottom).offset(2);
        make.height.mas_equalTo(15);
    }];
    _titleLab.text = NSLocalizedString(@"topscan_settingtemplate", @"");
    _timeLab.text = [TOPDocumentHelper top_getCurrentTime];
}
- (void)top_clickCancelBtn{
    if (self.top_clickToHide) {
        self.top_clickToHide();
    }
}

- (void)top_clickOkBtn{
    NSString *sendStr = [_tField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.top_clickToSendString) {
        self.top_clickToSendString(sendStr);
    }
}

- (void)setTagsName:(NSString *)tagsName{
    _tagsName = tagsName;
    _tagsLab.text = _tagsName;
    _tField.text = _tagsName;
}

- (void)setPlaceholder:(NSString *)placeholder{
    _tField.placeholder = placeholder;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    for (NSString * speialString in [TOPDocumentHelper top_specialStringArray]) {
        if ([string isEqualToString:speialString]) {
            return NO;
        }
    }
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (text.length>0) {
        _tagsLab.text = text;
    }else{
        _tagsLab.text = _tagsName;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *sendStr = [_tField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.top_clickToSendString) {
        self.top_clickToSendString(sendStr);
    }
    [textField resignFirstResponder];
    return YES;
}

@end
