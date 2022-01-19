#import "TOPPhotoShowTextEditView.h"
@interface TOPPhotoShowTextEditView()<UITextViewDelegate>
@property (nonatomic ,strong)UIImageView * backImg;
@property (nonatomic ,strong)UIView * backView;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UILabel * languLab;
@property (nonatomic ,strong)UILabel * endPointLab;
@property (nonatomic ,assign) CGRect oriRect;
@property (nonatomic ,strong) UIButton * doneButton;
@end
@implementation TOPPhotoShowTextEditView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    _backImg = [UIImageView new];
    _backImg.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
    _backImg.layer.cornerRadius = 15;
    
    _titleLab = [UILabel new];
    _titleLab.textColor = [UIColor whiteColor];
    _titleLab.textAlignment = NSTextAlignmentNatural;
    _titleLab.font = [UIFont systemFontOfSize:15];
    _titleLab.text = NSLocalizedString(@"topscan_ocrocragaintitle", @"");
    
    _topRightBtn = [UIButton new];
    _topRightBtn.backgroundColor = [UIColor clearColor];
    [_topRightBtn setImage:[UIImage imageNamed:@"top_editetexttoprow"] forState:UIControlStateNormal];
    [_topRightBtn setImage:[UIImage imageNamed:@"top_editetextdwrow"] forState:UIControlStateSelected];
    [_topRightBtn addTarget:self action:@selector(top_clickTopRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _backView = [UIView new];
    _backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(240, 240, 240, 1.0)];
    
    _languLab = [UILabel new];
    _languLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(119, 119, 119, 1.0)];
    _languLab.textAlignment = NSTextAlignmentNatural;
    _languLab.font = [UIFont systemFontOfSize:15];
    _languLab.text = NSLocalizedString(@"topscan_ocrocrlanguagetitle", @"");
    
    _languBtn = [TOPImageTitleButton new];
    _languBtn.padding = CGSizeMake(2, 2);
    _languBtn.style = ETitleLeftImageRightCenter;
    _languBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _languBtn.backgroundColor = TOPAPPGreenColor;
    [_languBtn setImage:[UIImage imageNamed:@"top_edittextrow"] forState:UIControlStateNormal];
    [_languBtn addTarget:self action:@selector(top_clickLanguBtn:) forControlEvents:UIControlEventTouchUpInside];
    _languBtn.layer.masksToBounds = YES;
    _languBtn.layer.cornerRadius = 2;
    
    _endPointLab = [UILabel new];
    _endPointLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(119, 119, 119, 1.0)];
    _endPointLab.font = [UIFont systemFontOfSize:15];
    _endPointLab.text = NSLocalizedString(@"topscan_ocrocragainendpoint", @"");
    if (isRTL()) {
        _endPointLab.textAlignment = NSTextAlignmentLeft;
    }else{
        _endPointLab.textAlignment = NSTextAlignmentRight;
    }
    
    _endPointBtn = [TOPImageTitleButton new];
    _endPointBtn.padding = CGSizeMake(2, 2);
    _endPointBtn.style = ETitleLeftImageRightCenter;
    _endPointBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _endPointBtn.backgroundColor = TOPAPPGreenColor;
    [_endPointBtn setImage:[UIImage imageNamed:@"top_edittextrow"] forState:UIControlStateNormal];
    [_endPointBtn addTarget:self action:@selector(top_clickEndPointBtn:) forControlEvents:UIControlEventTouchUpInside];
    _endPointBtn.layer.masksToBounds = YES;
    _endPointBtn.layer.cornerRadius = 2;
    
    _textView = [TOPTextView new];
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.textAlignment = NSTextAlignmentNatural;
    _textView.editable = YES;
    _textView.scrollEnabled = YES;
    _textView.delegate = self;
    _textView.returnKeyType = UIReturnKeyDefault;
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.inputAccessoryView = [UIView new];

    [self addSubview:_backImg];
    [self addSubview:_titleLab];
    [self addSubview:_topRightBtn];
    [self addSubview:_backView];
    [self addSubview:_languLab];
    [self addSubview:_languBtn];
    [self addSubview:_endPointBtn];
    [self addSubview:_endPointLab];
    [self addSubview:_textView];

    [self top_setupFream];
}
 
- (void)top_setupFream{
    [_backImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(59);
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(260, 44));
    }];
    [_topRightBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-25);
        make.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [_backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(_titleLab.mas_bottom);
        make.height.mas_equalTo(49);
    }];
    [_languLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.top.equalTo(_titleLab.mas_bottom);
        make.height.mas_equalTo(49);
    }];
    [_languBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_languLab.mas_trailing).offset(5);
        make.trailing.lessThanOrEqualTo(self).offset(-150);
        make.centerY.equalTo(_languLab.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(65, 30));
    }];
    [_endPointBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-15);
        make.centerY.equalTo(_languLab.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(65, 30));
    }];
    [_endPointLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_endPointBtn.mas_leading).offset(-5);
        make.leading.lessThanOrEqualTo(self).offset(150);
        make.centerY.equalTo(_languLab.mas_centerY);
        make.height.mas_equalTo(49);
    }];
    [_textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.top.equalTo(_titleLab.mas_bottom).offset(49);
    }];
}

- (void)setModel:(DocumentModel *)model{
    _model = model;
    NSString * textString = [NSString new];
    if ([TOPWHCFileManager top_isExistsAtPath:_model.ocrPath]) {
        textString = [TOPDocumentHelper top_getTxtContent:_model.ocrPath];
    }else{
        textString = @"";
    }
    [self setAttributedTextState:2 textContent:textString];
}

- (void)setAttributedTextState:(CGFloat)lineSpacing textContent:(NSString *)textString{
    NSMutableParagraphStyle *muParagraph = [[NSMutableParagraphStyle alloc]init];
    muParagraph.lineSpacing = lineSpacing; // 行距

    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[textString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType } documentAttributes:nil error:nil];
    NSRange range = NSMakeRange(0, attrStr.length);
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] range:range];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:muParagraph range:range];
    [attrStr addAttribute:NSBaselineOffsetAttributeName value:@(-lineSpacing) range:range];
    _textView.attributedText = attrStr;
}

- (void)setNetWorkState:(NSString *)netWorkState{
    NSDictionary * dic = [TOPScanerShare top_saveOcrLanguage];
    if (![TOPScanerShare top_googleConnection]||[netWorkState isEqualToString:@"0"]) {
        if ([[TOPDocumentHelper top_getGoogleLanguageData] containsObject:dic]) {
            NSDictionary * dic = @{@"English - eng":@"eng"};
            [TOPScanerShare top_writeSaveOcrLanguage:dic];
        }
        dic = [TOPScanerShare top_saveOcrLanguage];
    }
    if (dic.allKeys.count>0) {
        NSString * lang = dic.allValues[0];
        [_languBtn setTitle:lang.uppercaseString forState:UIControlStateNormal];
        
        CGFloat languBtnW = [TOPDocumentHelper top_getSizeWithStr:lang.uppercaseString Height:30 Font:16].width;
        if (languBtnW>65) {
            languBtnW = languBtnW+15;
        }else{
            languBtnW = 65;
        }
        [_languBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_languLab.mas_trailing).offset(5);
            make.trailing.lessThanOrEqualTo(self).offset(-150);
            make.centerY.equalTo(_languLab.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(languBtnW, 30));
        }];
        NSString * endpointString = [TOPDocumentHelper top_getEndPoint:dic];
        _endpointString = endpointString;
        [self setupEndpointTitle:_endpointString];
    }
}
- (void)setLanguBtnTitle:(NSString *)languBtnTitle{
    [_languBtn setTitle:languBtnTitle forState:UIControlStateNormal];
    
    CGFloat languBtnW = [TOPDocumentHelper top_getSizeWithStr:languBtnTitle Height:30 Font:16].width;
    if (languBtnW>65) {
        languBtnW = languBtnW+15;
    }else{
        languBtnW = 65;
    }
    [_languBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_languLab.mas_trailing).offset(5);
        make.trailing.lessThanOrEqualTo(self).offset(-150);
        make.centerY.equalTo(_languLab.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(languBtnW, 30));
    }];
}

- (void)setEndpointString:(NSString *)endpointString{
    _endpointString = endpointString;
    [self setupEndpointTitle:_endpointString];
}

- (void)setupEndpointTitle:(NSString *)endpointString{
    if (endpointString == nil) {
        [_endPointBtn setTitle:NSLocalizedString(@"topscan_ocrocrgooglepoint", @"") forState:UIControlStateNormal];
    }else{
        if ([TOPScanerShare top_saveOcrEndpoint] == nil) {
            for (NSDictionary * tempDic in [TOPDocumentHelper top_getEndpointData]) {
                if (tempDic.allKeys.count>0) {
                    if ([tempDic.allValues[0] isEqualToString:endpointString]) {
                        [_endPointBtn setTitle:tempDic.allKeys[0] forState:UIControlStateNormal];
                    }
                }
            }
        }else{
            NSDictionary * endpointDic = [TOPScanerShare top_saveOcrEndpoint];
            if (endpointDic.allKeys.count>0) {
                [_endPointBtn setTitle:endpointDic.allKeys[0] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)top_clickTopRightBtn:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.top_clickRightBtnChangeFream) {
        self.top_clickRightBtnChangeFream(sender.selected,_textView.isFirstResponder);
    }
}

- (void)top_clickLanguBtn:(UIButton *)sender{
    if (self.top_clickShowLanguageView) {
        self.top_clickShowLanguageView();
    }
}

- (void)top_clickEndPointBtn:(UIButton *)sender{
    if (self.top_clickShowEndPointView) {
        self.top_clickShowEndPointView(_endpointString);
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.top_sendBackText) {
        self.top_sendBackText(textView.text);
    }
}


@end
