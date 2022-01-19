#import "TOPTranslationView.h"
@interface TOPTranslationView()<UITextViewDelegate>
@property (nonatomic ,strong)UIView * coverView;
@property (nonatomic ,strong)UIImageView * panImg;
@property (nonatomic ,strong)UIImageView * lanImg;
@property (nonatomic ,strong)TOPImageTitleButton * sourcelanBtn;
@property (nonatomic ,strong)TOPImageTitleButton * targetlanBtn;
@property (nonatomic ,strong)UIButton * translationBtn;
@property (nonatomic ,strong)UITextView * translationTV;
@end
@implementation TOPTranslationView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self top_setUI];
    }
    return self;
}

- (void)top_setUI{
    _coverView = [UIView new];
    _coverView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAPPGreenColor];
    
    _panImg = [UIImageView new];
    _panImg.image = [UIImage imageNamed:@"top_panImg"];
    
    _lanImg = [UIImageView new];
    _lanImg.image = [UIImage imageNamed:@"top_lanconversion"];
    
    _sourcelanBtn = [TOPImageTitleButton new];
    _sourcelanBtn.padding = CGSizeMake(3, 3);
    _sourcelanBtn.style = ETitleLeftImageRightCenter;
    _sourcelanBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _sourcelanBtn.backgroundColor = RGBA(255, 255, 255, 0.2);
    [_sourcelanBtn setImage:[UIImage imageNamed:@"top_downarrow"] forState:UIControlStateNormal];
    [_sourcelanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sourcelanBtn addTarget:self action:@selector(top_clickSourceBtn:) forControlEvents:UIControlEventTouchUpInside];
    _sourcelanBtn.layer.masksToBounds = YES;
    _sourcelanBtn.layer.cornerRadius = 5;
    
    _targetlanBtn = [TOPImageTitleButton new];
    _targetlanBtn.padding = CGSizeMake(3, 3);
    _targetlanBtn.style = ETitleLeftImageRightCenter;
    _targetlanBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _targetlanBtn.backgroundColor = RGBA(255, 255, 255, 0.2);
    [_targetlanBtn setImage:[UIImage imageNamed:@"top_downarrow"] forState:UIControlStateNormal];
    [_targetlanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_targetlanBtn addTarget:self action:@selector(top_clickTargetBtn:) forControlEvents:UIControlEventTouchUpInside];
    _targetlanBtn.layer.masksToBounds = YES;
    _targetlanBtn.layer.cornerRadius = 5;
    
    _translationBtn = [UIButton new];
    _translationBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _translationBtn.backgroundColor = TOPAPPGreenColor;
    [_translationBtn setTitle:NSLocalizedString(@"topscan_ocrtexttranslation", @"") forState:UIControlStateNormal];
    [_translationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_translationBtn addTarget:self action:@selector(top_clickTranBtn) forControlEvents:UIControlEventTouchUpInside];
    _translationBtn.layer.cornerRadius = 5;
    
    _translationTV = [UITextView new];
    _translationTV.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    _translationTV.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    _translationTV.font = [UIFont systemFontOfSize:16];
    _translationTV.textAlignment = NSTextAlignmentNatural;
    _translationTV.editable = NO;
    _translationTV.scrollEnabled = YES;
    _translationTV.delegate = self;
    _translationTV.inputAccessoryView = [UIView new];
    
    [self addSubview:_coverView];
    [self addSubview:_panImg];
    [self addSubview:_targetlanBtn];
    [self addSubview:_lanImg];
    [self addSubview:_sourcelanBtn];
    [self addSubview:_translationBtn];
    [self addSubview:_translationTV];
    [self top_setupUI];
}
- (void)top_setupUI{
    [_coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(70);
    }];
    [_panImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(18, 8));
    }];
    [_targetlanBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(_panImg.mas_bottom).offset(8);
        make.size.mas_equalTo(CGSizeMake(90, 35));
    }];
    [_lanImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_targetlanBtn.mas_leading).offset(-8);
        make.centerY.equalTo(_targetlanBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    [_sourcelanBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_lanImg.mas_leading).offset(-8);
        make.centerY.equalTo(_targetlanBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(95, 35));
    }];
    [_translationBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-20);
        make.centerY.equalTo(_targetlanBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(80, 35));
    }];
    [_translationTV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.top.equalTo(self).offset(70);
    }];
    [_sourcelanBtn setTitle:NSLocalizedString(@"topscan_ocrautomatic", @"") forState:UIControlStateNormal];
    [_targetlanBtn setTitle:NSLocalizedString(@"topscan_ocrdefaultlanguage", @"") forState:UIControlStateNormal];
    [_translationBtn setTitle:NSLocalizedString(@"topscan_ocrtexttranslation", @"") forState:UIControlStateNormal];
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    [_translationTV resignFirstResponder];
}
- (void)setTranslationString:(NSString *)translationString{
    _translationString = translationString;
    NSMutableParagraphStyle *muParagraph = [[NSMutableParagraphStyle alloc]init];
    muParagraph.lineSpacing = 2; // 行距
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[translationString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType } documentAttributes:nil error:nil];
    NSRange range = NSMakeRange(0, attrStr.length);
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] range:range];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:muParagraph range:range];
    [attrStr addAttribute:NSBaselineOffsetAttributeName value:@(-2) range:range];
    self.translationTV.attributedText = attrStr;
}
- (void)top_clickSourceBtn:(UIButton *)sender{
    if (self.top_showSourceLanguageBlock) {
        self.top_showSourceLanguageBlock();
    }
}
- (void)top_clickTargetBtn:(UIButton *)sender{
    if (self.top_showTargetLanguageBlock) {
        self.top_showTargetLanguageBlock();
    }
}
- (void)top_clickTranBtn{
    if (self.top_beginTranslateBlock) {
        self.top_beginTranslateBlock();
    }
}
- (void)setSourceTitle:(NSString *)sourceTitle {
    [_sourcelanBtn setTitle:sourceTitle forState:UIControlStateNormal];
}
- (void)setTargetTitle:(NSString *)targetTitle {
    [_targetlanBtn setTitle:targetTitle forState:UIControlStateNormal];
}

@end
