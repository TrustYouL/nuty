#import "TOPScanDarkChooseCell.h"

@implementation TOPScanDarkChooseCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _iconImg = [UIImageView new];
        _iconImg.image = [UIImage imageNamed:@"top_settingSelect"];
        _iconImg.hidden = YES;
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(230, 230, 230, 1.0)];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
       
        [self.contentView addSubview:_lineView];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_iconImg];
        [self top_setupUI];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(230, 230, 230, 1.0)];
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1)];
}
- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-60);
        make.centerY.equalTo(contentView);
        make.height.mas_equalTo(20);
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-20);
        make.centerY.equalTo(contentView);
        make.size.mas_offset(CGSizeMake(22, 22));
    }];
}
- (void)setModel:(TOPSettingModel *)model{
    _model = model;
    _titleLab.text = model.myTitle;
    if (@available(iOS 13.0,*)) {
        if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleDark) {
            if (model.settingAction == TOPSettingVCBackgroundNotStstemDarkStyle) {
                _iconImg.hidden = NO;
            }else{
                _iconImg.hidden = YES;
            }
        }
        
        if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleLight) {
            if (model.settingAction == TOPSettingVCBackgroundNotStstemWhiteStyle) {
                _iconImg.hidden = NO;
            }else{
                _iconImg.hidden = YES;
            }
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
