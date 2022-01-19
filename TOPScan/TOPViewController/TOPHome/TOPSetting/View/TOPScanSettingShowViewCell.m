#import "TOPScanSettingShowViewCell.h"

@implementation TOPScanSettingShowViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        
        _iconImg = [UIImageView new];

        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_iconImg];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(250, 20));
    }];
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
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
