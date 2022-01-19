#import "TOPSetMemberTableViewCell.h"

@implementation TOPSetMemberTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        self.bgView = [[UIView alloc] init];
        self.bgView.backgroundColor = UIColorFromRGB(0xF1DCA3);
        self.bgView.layer.cornerRadius = 10;
        [self.contentView addSubview:self.bgView];
        self.bgView.layer.shadowOffset = CGSizeMake(0, 1);
        self.bgView.layer.shadowColor = RGBA(9, 103, 103, 0.13).CGColor ;
        self.bgView.layer.shadowOpacity = 1;
        self.bgView.layer.shadowRadius = 3;
        self.bgView.clipsToBounds =NO;
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(15);
            make.trailing.equalTo(self.contentView).offset(-15);
            make.bottom.equalTo(self.contentView);
            
        }];
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_member_bg"]];
        [self.bgView addSubview:bgImageView];
        bgImageView.clipsToBounds = YES;
        bgImageView.layer.cornerRadius = 10;
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView);
            make.leading.equalTo(self.bgView);
            make.trailing.equalTo(self.bgView);
            make.bottom.equalTo(self.bgView);
        }];
        self.rowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_setting_member"]];
        [self.contentView addSubview:self.rowImg];
        [self.rowImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(25);
            make.height.mas_offset(30);
            make.width.mas_offset(32);
        }];
        
        self.buyNumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buyNumberButton setTitle:NSLocalizedString(@"topscan_upgradepremium", @"") forState:UIControlStateNormal];
        [self.buyNumberButton setTitleColor:[UIColor whiteColor ] forState:UIControlStateNormal];
        self.buyNumberButton.titleLabel.font = PingFang_M_FONT_(10);
        [self.buyNumberButton setBackgroundColor: TOPAPPGreenColor];
        self.buyNumberButton.titleLabel.numberOfLines = 2;
        self.buyNumberButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.buyNumberButton.userInteractionEnabled = NO;
        [self.contentView addSubview:self.buyNumberButton];
        self.buyNumberButton.layer.cornerRadius = 34/2;
        [self.buyNumberButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.trailing.equalTo(self.contentView.mas_trailing).offset(-35);
            make.height.mas_offset(34);
            make.width.mas_offset(88);
        }];
        
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.text = NSLocalizedString(@"topscan_upgradeaccount", @"");
        self.titleLab.font = PingFang_M_FONT_(13);
        self.titleLab.textColor = RGBA(51, 51, 51, 1.0);
        self.titleLab.textAlignment = NSTextAlignmentNatural;
        self.titleLab.numberOfLines = 0;
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.leading.equalTo(self.rowImg.mas_trailing).offset(15);
            make.trailing.mas_lessThanOrEqualTo(self.buyNumberButton.mas_leading).offset(-15);
        }];
       
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
