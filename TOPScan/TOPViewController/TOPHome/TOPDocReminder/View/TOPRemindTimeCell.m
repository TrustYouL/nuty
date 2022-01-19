
#import "TOPRemindTimeCell.h"

@implementation TOPRemindTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _timeTV = [TOPTextView new];
        _timeTV.backgroundColor = [UIColor clearColor];
        _timeTV.textAlignment = NSTextAlignmentNatural;
        _timeTV.editable = NO;
        _timeTV.scrollEnabled = YES;
        _timeTV.delegate = self;
        _timeTV.showsVerticalScrollIndicator = NO;
        
        _coverView = [UIView new];
        _coverView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_tapAction:)];
        [_coverView addGestureRecognizer:tap];
        [self.contentView addSubview:_timeTV];
        [self.contentView addSubview:_coverView];
        [self top_setViewFream];
    }
    return self;
}

- (void)top_setViewFream{
    
    [_timeTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setTimeString:(NSString *)timeString{
    _timeString = timeString;

    NSMutableParagraphStyle *muParagraph = [[NSMutableParagraphStyle alloc]init];
    muParagraph.lineSpacing = 5; // 行距
    
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:timeString];
    NSRange range = NSMakeRange(0, attrStr.length);//范围
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(1) range:range];//下划线宽
    [attrStr addAttribute:NSUnderlineColorAttributeName value:TOPAPPGreenColor range:range];//下划线颜色
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];//字体大小
    [attrStr addAttribute:NSForegroundColorAttributeName value:TOPAPPGreenColor range:range];//字体颜色

    _timeTV.attributedText = attrStr;
    _timeTV.textAlignment = NSTextAlignmentNatural;
}

- (void)top_tapAction:(UITapGestureRecognizer *)tap{
    if (self.top_clickAndSetTime) {
        self.top_clickAndSetTime();
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
