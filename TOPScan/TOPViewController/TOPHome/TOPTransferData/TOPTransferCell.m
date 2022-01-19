#import "TOPTransferCell.h"
#import "TOPTransferModel.h"

@interface TOPTransferCell ()
@property (nonatomic ,strong) UIImageView *icon;
@property (nonatomic ,strong) UILabel *titleLab;
@property (nonatomic ,strong) UIView *lineView;

@end

@implementation TOPTransferCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.backgroundColor = [UIColor clearColor];
        [self top_configContentView];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(205, 205, 205, 1.0)];
    self.titleLab.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
}
- (void)top_configCellWithData:(TOPTransferModel *)cellModel {
    self.titleLab.text = cellModel.title;
}

- (void)top_configContentView {
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.lineView];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(10);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(23);
        make.height.mas_equalTo(23);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(39);
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-60);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-5);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark -- lazy
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_deviceIcon"]];
    }
    return _icon;;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(205, 205, 205, 1.0)];
        _lineView.hidden = YES;
    }
    return _lineView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.font = PingFang_R_FONT_(16);
    }
    return _titleLab;
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
