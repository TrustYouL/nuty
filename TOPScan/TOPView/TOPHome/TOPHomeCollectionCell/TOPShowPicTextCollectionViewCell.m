#define Bottom_H 60
#import "TOPShowPicTextCollectionViewCell.h"
#import "TOPTextView.h"
@implementation TOPShowPicTextCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _whiteCoverView = [UIView new];
        _whiteCoverView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        
        _iconImg = [UIImageView new];
        _iconImg.image = [UIImage imageNamed:@"top_textIcon"];

        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.text = NSLocalizedString(@"topscan_textblankprompt", @"");
        
        _recognizeBtn = [UIButton new];
        _recognizeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _recognizeBtn.backgroundColor = TOPAPPGreenColor;
        [_recognizeBtn setTitle:NSLocalizedString(@"topscan_recognizetitle", @"") forState:UIControlStateNormal];
        [_recognizeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_recognizeBtn addTarget:self action:@selector(top_clickBtn) forControlEvents:UIControlEventTouchUpInside];
        _recognizeBtn.layer.cornerRadius = 4;
        _recognizeBtn.layer.masksToBounds = YES;
        
        _textView = [TOPTextView new];
        _textView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _textView.editable = NO;
        _textView.scrollEnabled = YES;
        _textView.delegate = self;
        _textView.showsVerticalScrollIndicator = NO;
        
        [self.contentView addSubview:_whiteCoverView];
        [self.contentView addSubview:_iconImg];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_recognizeBtn];
        [self.contentView addSubview:_textView];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_whiteCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];
    
    [_iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(93, 78));
    }];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(_iconImg.mas_bottom).offset(15);
        make.size.mas_equalTo(CGSizeMake(250, 40));
    }];
    
    [_recognizeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(_titleLab.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(220, 47));
    }];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(contentView);
        make.top.equalTo(contentView).offset(TOPNavBarAndStatusBarHeight);
        make.bottom.equalTo(contentView).offset(-(TOPBottomSafeHeight+60));
    }];
}

- (void)setModel:(DocumentModel *)model{
    _model = model;
    if ([TOPWHCFileManager top_isExistsAtPath:_model.ocrPath]) {
        _whiteCoverView.hidden = YES;
        _textView.hidden = NO;
    }else{
        _whiteCoverView.hidden = NO;
        _textView.hidden = YES;
    }
   
    NSMutableParagraphStyle *muParagraph = [[NSMutableParagraphStyle alloc]init];
    muParagraph.lineSpacing = 5; 
    
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[[TOPDocumentHelper top_getTxtContent:_model.ocrPath] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType } documentAttributes:nil error:nil];
    NSRange range = NSMakeRange(0, attrStr.length);
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor top_textColor:[UIColor whiteColor] defaultColor:[UIColor blackColor]] range:range];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:muParagraph range:range];
    [attrStr addAttribute:NSBaselineOffsetAttributeName value:@(-5) range:range];

    _textView.attributedText = attrStr;
}
- (void)top_clickBtn{
    if (self.top_clickToOcr) {
        self.top_clickToOcr();
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.top_scrollBeginHide) {
        self.top_scrollBeginHide();
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.top_scrollEndShow) {
        self.top_scrollEndShow();
    }
}
@end
