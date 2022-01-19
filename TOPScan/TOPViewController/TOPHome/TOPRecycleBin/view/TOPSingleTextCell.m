#import "TOPSingleTextCell.h"
#import "TOPSettingCellModel.h"

@interface TOPSingleTextCell ()
@property (nonatomic ,strong) UILabel *titleLab;
@property (nonatomic ,strong) UILabel *contentLab;
@property (nonatomic ,strong) UIView *lineView;

@end

@implementation TOPSingleTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.contentLab];
    
    UIView * contentView = self.contentView;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(_contentLab.mas_leading).offset(-20);
        make.centerY.equalTo(contentView);
    }];
    [_contentLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-18);
        make.centerY.equalTo(contentView);
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
}

- (void)setSeparatorLine:(BOOL)separatorLine {
    _separatorLine = separatorLine;
    self.lineView.hidden = !separatorLine;
}

- (void)setModel:(TOPSettingCellModel *)model {
    _model = model;
    self.titleLab.text = model.title;
    self.contentLab.text = model.content;
    self.lineView.hidden = !model.showLine;
}


#pragma mark -- lazy
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(230, 230, 230, 1.0)];
        _lineView.hidden = YES;
    }
    return _lineView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
    }
    return _titleLab;
}

- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [UILabel new];
        _contentLab.font = [UIFont systemFontOfSize:14];
        _contentLab.textColor = kTopicBlueColor;
        _contentLab.textAlignment = NSTextAlignmentNatural;
        // 水平方向不拉伸
        [_contentLab setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _contentLab;
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
