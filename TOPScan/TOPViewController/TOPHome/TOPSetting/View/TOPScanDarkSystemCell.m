#import "TOPScanDarkSystemCell.h"

@implementation TOPScanDarkSystemCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        
        _contentLab = [UILabel new];
        _contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLab.font = [UIFont systemFontOfSize:14];
        _contentLab.textColor = RGBA(180, 180, 180, 1.0);
        _contentLab.textAlignment = NSTextAlignmentNatural;
        _contentLab.numberOfLines = 0;
                
        _switchBtn = [UISwitch new];
        _switchBtn.onTintColor = TOPAPPGreenColor;
        _switchBtn.thumbTintColor = [UIColor whiteColor];
        [_switchBtn addTarget:self action:@selector(top_subscribeTopic:) forControlEvents:UIControlEventValueChanged];

        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_contentLab];
        [self.contentView addSubview:_switchBtn];
        [self top_setFream];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1)];
}
- (void)top_setFream{
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(200, 15));
    }];
    [_switchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.contentView).offset(6);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
    [_contentLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(15);
        make.top.equalTo(_titleLab.mas_bottom).offset(10);
        make.trailing.equalTo(self.contentView).offset(-35);
        make.height.mas_equalTo(40);
    }];
}
- (void)setModel:(TOPSettingModel *)model{
    _model = model;
    _titleLab.text = model.myTitle;
    _contentLab.text = model.myContent;
    if (@available(iOS 13.0,*)) {
        if ([TOPScanerShare top_darkModel] == UIUserInterfaceStyleUnspecified) {
            _switchBtn.on = YES;
        }else{
            _switchBtn.on = NO;
        }
    }
}
- (void)top_subscribeTopic:(UISwitch *)sender{
    if (self.top_switchBtnAction) {
        self.top_switchBtnAction(sender.on);
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
