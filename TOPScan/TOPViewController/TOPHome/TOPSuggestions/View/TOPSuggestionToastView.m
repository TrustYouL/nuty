#import "TOPSuggestionToastView.h"
@interface TOPSuggestionToastView()
@end
@implementation TOPSuggestionToastView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    self.backgroundColor = RGBA(51, 51, 51, 0.3);

    UIView * backView = [UIView new];
    backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    backView.layer.cornerRadius = 7;
    backView.layer.masksToBounds = YES;

    [self addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(340, 425));
    }];
    
    UIImageView * topimg = [UIImageView new];
    topimg.image = [UIImage imageNamed:@"top_suggestionToast"];
    
    UIImageView * bugImg = [UIImageView new];
    bugImg.image = [UIImage imageNamed:@"top_suggestionBug"];
    
    UILabel * contentLab = [UILabel new];
    contentLab.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    contentLab.textAlignment = NSTextAlignmentCenter;
    contentLab.font = [UIFont systemFontOfSize:15];
    contentLab.backgroundColor = [UIColor clearColor];
    contentLab.numberOfLines = 0;

    UIImageView * setRaw = [UIImageView new];
    if (isRTL()) {
        setRaw.image = [UIImage imageNamed:@"top_suggestionRawRT"];
    }else{
        setRaw.image = [UIImage imageNamed:@"top_suggestionRaw"];
    }
 
    UILabel * setLab = [UILabel new];
    setLab.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    setLab.textAlignment = NSTextAlignmentCenter;
    setLab.font = [UIFont boldSystemFontOfSize:14];
    setLab.text = NSLocalizedString(@"topscan_questionsetting", @"");
    
    UILabel * disLab = [UILabel new];
    disLab.numberOfLines = 0;
    disLab.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    disLab.textAlignment = NSTextAlignmentCenter;
    disLab.font = [UIFont boldSystemFontOfSize:14];
    disLab.text = NSLocalizedString(@"topscan_settingusersuggestion", @"");
    
    UIButton * continueBtn = [UIButton new];
    continueBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [continueBtn setTitle:NSLocalizedString(@"topscan_questioncontinue", @"") forState:UIControlStateNormal];
    [continueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueBtn setBackgroundColor:TOPAPPGreenColor];
    [continueBtn addTarget:self action:@selector(top_clickBtn) forControlEvents:UIControlEventTouchUpInside];
    continueBtn.layer.cornerRadius = 50/2;
    continueBtn.layer.masksToBounds = YES;
    
    [backView addSubview:topimg];
    [backView addSubview:bugImg];
    [backView addSubview:contentLab];
    [backView addSubview:setRaw];
    [backView addSubview:setLab];
    [backView addSubview:disLab];
    [backView addSubview:continueBtn];

    [topimg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(backView).offset(9);
        make.trailing.equalTo(backView).offset(-9);
        make.top.equalTo(backView).offset(15);
        make.height.mas_equalTo(102);
    }];
    [bugImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.equalTo(backView);
        make.size.mas_equalTo(CGSizeMake(222, 250));
    }];
    [contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(backView).offset(20);
        make.trailing.equalTo(backView).offset(-20);
        make.top.equalTo(topimg.mas_bottom).offset(20);
        make.height.mas_equalTo(90);
    }];
    [setRaw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentLab.mas_bottom).offset(35);
        make.centerX.equalTo(backView);
        make.size.mas_equalTo(CGSizeMake(24, 14));
    }];
    [setLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(setRaw);
        make.trailing.equalTo(setRaw.mas_leading).offset(-25);
        make.size.mas_equalTo(CGSizeMake(70, 16));
    }];
    [disLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(setRaw);
        make.leading.equalTo(setRaw.mas_trailing).offset(25);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    [continueBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(setRaw.mas_bottom).offset(45);
        make.centerX.equalTo(backView);
        make.size.mas_equalTo(CGSizeMake(210, 50));
    }];
    
    NSMutableParagraphStyle *muParagraph = [[NSMutableParagraphStyle alloc]init];
    muParagraph.lineSpacing = 5; // 行距
    [muParagraph setAlignment:NSTextAlignmentCenter];

    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[NSLocalizedString(@"topscan_questiontypetoast", @"") dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType } documentAttributes:nil error:nil];
    NSRange range = NSMakeRange(0, attrStr.length);
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:range];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:muParagraph range:range];
    contentLab.attributedText = attrStr;
    
    UIButton * cancelBtn = [UIButton new];
    [cancelBtn setImage:[UIImage imageNamed:@"top_suggestionCancel"] forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor clearColor]];
    [cancelBtn addTarget:self action:@selector(top_clickCancel) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(backView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
}

- (void)top_clickCancel{
    if (self.top_clickHideView) {
        self.top_clickHideView();
    }
}
- (void)top_clickBtn{
    if (self.top_clickContinue) {
        self.top_clickContinue();
    }
}

@end
