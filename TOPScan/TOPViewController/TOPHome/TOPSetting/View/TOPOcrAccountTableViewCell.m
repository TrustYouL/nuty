#import "TOPOcrAccountTableViewCell.h"

@implementation TOPOcrAccountTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];

        self.ocrContentLab = [[UILabel alloc] init];
        self.ocrContentLab.font = PingFang_R_FONT_(16);
        self.ocrContentLab.numberOfLines = 0;
        self.ocrContentLab.textAlignment = NSTextAlignmentNatural;
        self.ocrContentLab.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
        [self.contentView addSubview:self.ocrContentLab];
        [self.ocrContentLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(15);
            make.trailing.mas_lessThanOrEqualTo(self.contentView).offset(-15);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:UIColorFromRGB(0xf2f2f7)];
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
            make.leading.equalTo(self.contentView);
            make.trailing.equalTo(self.contentView);
            make.height.mas_offset(1);
        }];
    }
    return self;
}

@end
