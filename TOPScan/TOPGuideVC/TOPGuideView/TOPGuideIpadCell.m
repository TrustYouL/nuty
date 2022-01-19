#import "TOPGuideIpadCell.h"
@implementation TOPGuideIpadCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imgView = [UIImageView new];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont boldSystemFontOfSize:25];
        _titleLab.backgroundColor = [UIColor whiteColor];
        
        _showText = [TOPTextView new];
        _showText.backgroundColor = [UIColor whiteColor];
        _showText.editable = NO;
        _showText.scrollEnabled = YES;
        _showText.showsVerticalScrollIndicator = NO;
        
        _enterBtn = [UIButton new];
        _enterBtn.backgroundColor = TOPAPPGreenColor;
        [_enterBtn setTitle:NSLocalizedString(@"topscan_questioncontinue", @"") forState:UIControlStateNormal];
        [_enterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_enterBtn addTarget:self action:@selector(top_clickEnterAction) forControlEvents:UIControlEventTouchUpInside];
        _enterBtn.layer.cornerRadius = 20;
        _enterBtn.layer.borderColor = TOPAPPGreenColor.CGColor;
        _enterBtn.layer.borderWidth = 1.0;
        
        [self.contentView addSubview:_imgView];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_showText];
        [self.contentView addSubview:_enterBtn];
        [self top_setMaskMyView];
        if (IS_IPAD) {
            _titleLab.textColor = RGBA(102, 102, 102, 1.0);
            _titleLab.textAlignment = NSTextAlignmentCenter;
        }else{
            _titleLab.textColor = RGBA(51, 51, 51, 1.0);
            _titleLab.textAlignment = NSTextAlignmentNatural;
        }
    }
    return self;
}

- (void)top_setMaskMyView{
    CGFloat picW = 550;
    CGFloat picH = (588*picW)/750;
    UIView * contentView = self.contentView;
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(picW, picH));
    }];
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.bottom.equalTo(_imgView.mas_top).offset(-50);
        make.width.mas_equalTo(250);
    }];
    
    [_showText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgView.mas_bottom).offset(20);
        make.centerX.equalTo(contentView);
        make.bottom.equalTo(contentView).offset(-(TOPBottomSafeHeight+50));
        make.width.mas_equalTo(picW);
    }];
    [_enterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentView).offset(-(TOPBottomSafeHeight+30));
        make.trailing.equalTo(contentView).offset(-30);
        make.size.mas_equalTo(CGSizeMake(130, 40));
    }];
}

- (void)setModel:(TOPGuideModel *)model{
    _model = model;
    if (model.index == 3) {
        _enterBtn.hidden = NO;
    }else{
        _enterBtn.hidden = YES;
    }
    _imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"top_iPad%ld",model.index+1]];
    
    NSMutableParagraphStyle *muParagraph = [[NSMutableParagraphStyle alloc]init];
    muParagraph.lineSpacing = 6; // 行距
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:model.contentString];
    NSRange range = NSMakeRange(0, attrStr.length);
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:muParagraph range:range];
    [attrStr addAttribute:NSBaselineOffsetAttributeName value:@(5) range:range];
    if (IS_IPAD) {
        [attrStr addAttribute:NSForegroundColorAttributeName value:RGBA(102, 102, 102, 1.0) range:range];
    }else{
        [attrStr addAttribute:NSForegroundColorAttributeName value:RGBA(51, 51, 51, 1.0) range:range];
    }
    _showText.attributedText = attrStr;
    _titleLab.text = model.titleString;

}
- (void)top_clickEnterAction{
    if (self.top_lastPageEnterAction) {
        self.top_lastPageEnterAction();
    }
}

@end
