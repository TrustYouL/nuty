#import "TOPChildSettingTPDFCell.h"
@interface TOPChildSettingTPDFCell()
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIImageView * rowImg;
@property (nonatomic ,strong)UIImageView * vipImg;
@end
@implementation TOPChildSettingTPDFCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString * rowIcon = [NSString new];
        if (isRTL()) {
            rowIcon = @"top_reverpushVCRow";
        }else{
            rowIcon = @"top_pushVCRow";
        }
        _rowImg = [UIImageView new];
        _rowImg.image = [UIImage imageNamed:rowIcon];
        
        _vipImg = [UIImageView new];
        _vipImg.image = [UIImage imageNamed:@"top_vip_logo"];
        
        _titleLab = [UILabel new];
        _titleLab.text = NSLocalizedString(@"topscan_pdfpassword", @"");
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:TOPAppBackgroundColor];
        
        [self.contentView addSubview:_vipImg];
        [self.contentView addSubview:_rowImg];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_lineView];
        [self top_setupUI];
    }
    return self;
}
- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.leading.equalTo(contentView).offset(15);
        make.height.mas_equalTo(25);
    }];
    [self.vipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_titleLab.mas_trailing).offset(10);
        make.centerY.equalTo(contentView);
        make.size.width.mas_equalTo(CGSizeMake(16, 16));
        make.trailing.lessThanOrEqualTo(contentView).offset(-35);
    }];
    [_rowImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(7, 12));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
}
- (void)setShowVip:(BOOL)showVip {
    _showVip = showVip;
    _vipImg.hidden = !showVip;
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
