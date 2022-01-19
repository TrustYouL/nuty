#import "TOPSettingFormatterCell.h"

@implementation TOPSettingFormatterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(15);
        make.centerY.equalTo(self.contentView);
//        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImg.mas_trailing).offset(20);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(TOPScreenWidth-130, 20));
    }];
}

- (void)setModel:(TOPSettingFormatModel *)model{
    _model = model;
    _titleLab.text = model.formatString;
    if (_model.isSelect) {
        _iconImg.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
    }else{
        _iconImg.image = [UIImage imageNamed:@"top_scamerbatch_AllNormal"];
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
