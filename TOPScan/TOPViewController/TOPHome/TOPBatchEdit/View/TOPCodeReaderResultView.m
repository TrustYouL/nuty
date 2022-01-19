#import "TOPCodeReaderResultView.h"
@interface TOPCodeReaderResultView()<UITextViewDelegate>
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIButton * cancelBtn;//取消
@property (nonatomic ,strong)UIButton * codeCopyBtn;//复制
@property (nonatomic ,strong)UIButton * shareBtn;//分享
@property (nonatomic ,strong)UIButton * openURLBtn;
@property (nonatomic ,strong)UIButton * showBtn;
@property (nonatomic ,strong)UITextView * urlTV;
@end
@implementation TOPCodeReaderResultView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        _iconImg = [UIImageView new];
        
        _titleLab = [UILabel new];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.font = [UIFont systemFontOfSize:14];
        _titleLab.textAlignment = NSTextAlignmentLeft;
        
        _urlTV = [UITextView new];
        _urlTV.editable = NO;
        _urlTV.delegate = self;
        _urlTV.scrollEnabled = NO;
        _urlTV.textColor = TOPAPPGreenColor;
        _urlTV.textAlignment = NSTextAlignmentLeft;
        _urlTV.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
        _urlTV.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _urlTV.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _shareBtn = [UIButton new];
        _shareBtn.tag = 1000+1;
        [_shareBtn setImage:[UIImage imageNamed:@"top_codeShare"] forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _codeCopyBtn = [UIButton new];
        _codeCopyBtn.tag = 1000+2;
        [_codeCopyBtn setImage:[UIImage imageNamed:@"top_codeCopy"] forState:UIControlStateNormal];
        [_codeCopyBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _cancelBtn = [UIButton new];
        _cancelBtn.tag = 1000+3;
        [_cancelBtn setImage:[UIImage imageNamed:@"top_codeDelete"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _showBtn = [UIButton new];
        [_showBtn setImage:[UIImage imageNamed:@"top_codeResultShow"] forState:UIControlStateNormal];
        [_showBtn addTarget:self action:@selector(top_clickShowBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _openURLBtn = [UIButton new];
        _openURLBtn.tag = 1000+4;
        _openURLBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_openURLBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [_openURLBtn setTitle:NSLocalizedString(@"topscan_barcodeopenurl", @"") forState:UIControlStateNormal];
        [_openURLBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_iconImg];
        [self addSubview:_titleLab];
        [self addSubview:_cancelBtn];
        [self addSubview:_codeCopyBtn];
        [self addSubview:_shareBtn];
        [self addSubview:_openURLBtn];
        [self addSubview:_showBtn];
        [self addSubview:_urlTV];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImg.mas_right).offset(5);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(180, 15));
    }];
    [_cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [_codeCopyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_cancelBtn.mas_left).offset(-10);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [_shareBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_codeCopyBtn.mas_left).offset(-10);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [_openURLBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.bottom.equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(80, 20));
    }];
    [_showBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(5);
        make.bottom.equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    [_urlTV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(_shareBtn.mas_bottom).offset(10);
        make.bottom.equalTo(_openURLBtn.mas_top).offset(-17);
    }];
}

- (void)setResultString:(NSString *)resultString{
    _resultString = resultString;
    _titleLab.text = NSLocalizedString(@"topscan_barcoderesult", @"");
    _iconImg.image = [UIImage imageNamed:@"top_codeReaderIcon"];

    NSMutableParagraphStyle *muParagraph = [[NSMutableParagraphStyle alloc]init];
    muParagraph.lineSpacing = 5; // 行距
    
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:resultString];
    NSRange range = NSMakeRange(0, attrStr.length);//范围
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:range];//字体大小
    [attrStr addAttribute:NSForegroundColorAttributeName value:TOPAPPGreenColor range:range];//字体颜色
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(1) range:range];//下划线宽
    [attrStr addAttribute:NSUnderlineColorAttributeName value:TOPAPPGreenColor range:range];//下划线颜色
    _urlTV.attributedText = attrStr;
    
    CGFloat getH = [TOPDocumentHelper top_getSizeWithStr:resultString Height:14 Font:13].width;
    if (getH>(TOPScreenWidth-30)*2) {
        _showBtn.hidden = NO;
    }else{
        _showBtn.hidden = YES;
    }

}

#pragma mark --富文本的点击的回调
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    if (self.top_clickBtnAction) {
        self.top_clickBtnAction(4, self.resultString);
    }
    return YES;
}

- (void)top_clickBtn:(UIButton *)sender{
    if (self.top_clickBtnAction) {
        self.top_clickBtnAction(sender.tag-1000, self.resultString);
    }
}

- (void)top_clickShowBtn:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.top_clickShowBtnAction) {
        self.top_clickShowBtnAction(sender.selected);
    }
}

@end
