#import "TOPQuestionTypeCell.h"

@implementation TOPQuestionTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        
        _titleLab = [[UILabel alloc]init];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        
        _showImg = [UIImageView new];
        if (isRTL()) {
            _showImg.image = [UIImage imageNamed:@"top_suggestionReverArrow"];
        }else{
            _showImg.image = [UIImage imageNamed:@"top_suggestionDefaultArrow"];
        }
        
        _backView = [UIView new];
        _backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _backView.layer.masksToBounds = YES;
        _backView.layer.cornerRadius = 10;
        
        [self.contentView addSubview:_backView];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_showImg];
        [self top_setViewFream];
    }
    return self;
}

- (void)top_setViewFream{
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, 15, 0, 15));
    }];
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(30);
        make.trailing.equalTo(self.contentView).offset(-55);
        make.top.equalTo(self.contentView).offset(10);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    [_showImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-(15+15));
        make.size.mas_equalTo(CGSizeMake(13, 13));
    }];
}

- (void)setSelectState:(BOOL)selectState{
    _selectState = selectState;
    if (selectState) {
        _showImg.image = [UIImage imageNamed:@"top_suggestionShowArrow"];
    }else{
        if (isRTL()) {
            _showImg.image = [UIImage imageNamed:@"top_suggestionReverArrow"];
        }else{
            _showImg.image = [UIImage imageNamed:@"top_suggestionDefaultArrow"];
        }
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
