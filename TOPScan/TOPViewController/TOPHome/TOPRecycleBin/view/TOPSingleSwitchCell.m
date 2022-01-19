#import "TOPSingleSwitchCell.h"
#import "TOPSettingCellModel.h"

@interface TOPSingleSwitchCell ()
@property (nonatomic ,strong) UISwitch *switchBtn;
@property (nonatomic ,strong) UILabel *titleLab;
@property (nonatomic ,strong) UIView *lineView;

@end

@implementation TOPSingleSwitchCell

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
    [self.contentView addSubview:self.switchBtn];
    
    UIView * contentView = self.contentView;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-80);
        make.centerY.equalTo(contentView);
    }];
    [_switchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-18);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(50, 30));
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
    self.switchBtn.on = model.isOpen;
    self.lineView.hidden = !model.showLine;
}

- (void)top_switchValueChange:(UISwitch *)sender {
    if (self.top_changeSwitchValueBlock) {
        self.top_changeSwitchValueBlock(sender.on);
    }
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

- (UISwitch *)switchBtn {
    if (!_switchBtn) {
        _switchBtn = [UISwitch new];
        _switchBtn.onTintColor = kTopicBlueColor;
        _switchBtn.thumbTintColor = [UIColor whiteColor];
        [_switchBtn addTarget:self action:@selector(top_switchValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchBtn;
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
