#import "TOPChildSettingFourthCell.h"
@interface TOPChildSettingFourthCell()
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UISwitch * switchBtn;
@end
@implementation TOPChildSettingFourthCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _titleLab = [UILabel new];
        _titleLab.text = NSLocalizedString(@"topscan_hidepagedetails", @"");
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        
        _switchBtn = [UISwitch new];
        _switchBtn.onTintColor = TOPAPPGreenColor;
        _switchBtn.thumbTintColor = [UIColor whiteColor];
        [_switchBtn addTarget:self action:@selector(top_switchAction:) forControlEvents:UIControlEventValueChanged];
        
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_switchBtn];
        [self top_setupUI];
    }
    return self;
}
- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.leading.equalTo(contentView).offset(15);
        make.height.mas_equalTo(20);
    }];
    [_switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(9);
        make.trailing.equalTo(contentView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(60, 35));
    }];
    if ([TOPScanerShare top_childHideDetailType] == 1) {
        _switchBtn.on = NO;
    }else{
        _switchBtn.on = YES;
    }
}
- (void)top_switchAction:(UISwitch *)sender{
    if ([TOPScanerShare top_childHideDetailType] == 1) {
        [TOPScanerShare top_writeChildHideDetailType:2];
    }else{
        [TOPScanerShare top_writeChildHideDetailType:1];
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
