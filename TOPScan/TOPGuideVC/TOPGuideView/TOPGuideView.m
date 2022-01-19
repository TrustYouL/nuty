#import "TOPGuideView.h"

@implementation TOPGuideView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imgView = [UIImageView new];
        
        _titleLab = [UILabel new];
        _titleLab.textColor = RGBA(51, 51, 51, 1.0);
        _titleLab.font = [UIFont boldSystemFontOfSize:25];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.backgroundColor = [UIColor whiteColor];
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor clearColor];
        
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
        
        [self addSubview:_imgView];
        [self addSubview:_titleLab];
        [self addSubview:_lineView];
        [self addSubview:_showText];
        [self addSubview:_enterBtn];
    }
    return self;
}

- (void)top_setMaskMyView:(CGFloat)topH{
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.top.equalTo(self).offset(topH+25);
        make.width.mas_equalTo(250);
    }];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.top.equalTo(_titleLab.mas_bottom).offset(3);
        make.size.mas_equalTo(CGSizeMake(18, 3));
    }];
    [_showText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(30);
        make.trailing.equalTo(self).offset(-30);
        make.top.equalTo(_lineView.mas_bottom).offset(40);
        make.bottom.equalTo(self).offset(-(TOPBottomSafeHeight+150));
    }];
    
    [_enterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-(TOPBottomSafeHeight+100));
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

    _titleLab.hidden = NO;
    NSMutableParagraphStyle *muParagraph = [[NSMutableParagraphStyle alloc]init];
    muParagraph.lineSpacing = 6;
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:model.contentString];
    NSRange range = NSMakeRange(0, attrStr.length);
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:muParagraph range:range];
    [attrStr addAttribute:NSBaselineOffsetAttributeName value:@(5) range:range];
    _showText.attributedText = attrStr;
    _titleLab.text = model.titleString;

    [self top_setImg:model.index];
}
- (void)top_setImg:(NSInteger)index{
    NSLog(@"TOPScreenHeight==%f deviceVersion==%@",TOPScreenHeight,[TOPAppTools deviceVersion]);
    CGFloat topH = 0.0;
    NSString * imgName = [NSString new];
    if (TOPScreenHeight == 667) {
        imgName = @"top_750-1334";
        topH = 300;
    }
    if (TOPScreenHeight == 736) {
        imgName = @"top_1242-2208";
        topH = (980*TOPScreenWidth)/1242;
    }
    if (TOPScreenHeight == 812) {
        if ([[TOPAppTools deviceVersion] isEqualToString:@"iPhone 12 mini"]) {
            imgName = @"top_1080-2340";
            topH = (860*TOPScreenWidth)/1080;
        }else{
            imgName = @"top_1125-2436";
            topH = (890*TOPScreenWidth)/1125;
        }
    }
    
    if (TOPScreenHeight == 844) {
        imgName = @"top_1170-2532";
        topH = (930*TOPScreenWidth)/1170;

    }
    
    if (TOPScreenHeight == 896) {
        if ([[TOPAppTools deviceVersion] isEqualToString:@"iPhone 11 Pro Max"]) {
            imgName = @"top_1242-2688";
            topH = (980*TOPScreenWidth)/1242;
        }else{
            imgName = @"top_828-1792";
            topH = (650*TOPScreenWidth)/828;

        }
    }
    
    if (TOPScreenHeight == 926) {
        imgName = @"top_1284-2778";
        topH = (1010*TOPScreenWidth)/1284;
    }
    
    if (TOPScreenHeight == 1344) {
        imgName = @"top_1242-2688";
        topH = (980*TOPScreenWidth)/1242;
    }
    
    NSLog(@"topH==%f",topH);
    [self top_setMaskMyView:topH];
    _imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%ld",imgName,index]];
}

- (void)top_clickEnterAction{
    if (self.top_lastPageEnterAction) {
        self.top_lastPageEnterAction();
    }
}

@end
