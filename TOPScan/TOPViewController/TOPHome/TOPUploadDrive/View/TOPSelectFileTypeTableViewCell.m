#import "TOPSelectFileTypeTableViewCell.h"

@implementation TOPSelectFileTypeTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_drive_select_filetype_pdf"]];
        [self.contentView addSubview:_coverImageView];
        [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(35);
            make.height.mas_offset(39);
            make.width.mas_offset(29);
        }];
        
        _selectedIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_scamerbatch_AllNormal"]];
        [self.contentView addSubview:_selectedIconImageView];
        [_selectedIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.trailing.equalTo(self.contentView).offset(-30);
            make.height.mas_offset(16);
            make.width.mas_offset(16);
        }];
  
        _itemTitleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_itemTitleLabel];
        [_itemTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.leading.equalTo(self.coverImageView.mas_trailing).offset(20);
            make.trailing.lessThanOrEqualTo(self.selectedIconImageView.mas_leading).offset(20);
        }];
        _itemTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
        _itemTitleLabel.font = PingFang_R_FONT_(16);
        _itemTitleLabel.backgroundColor = [UIColor clearColor];

        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:UIColorFromRGB(0xf2f2f7)];
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
            make.trailing.equalTo(self.contentView);
            make.leading.lessThanOrEqualTo(self.contentView);
            make.height.mas_offset(1);
        }];
    }
    return self;
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
