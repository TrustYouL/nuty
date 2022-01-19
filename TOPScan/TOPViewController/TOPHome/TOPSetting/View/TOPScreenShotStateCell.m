#import "TOPScreenShotStateCell.h"

@implementation TOPScreenShotStateCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(230, 230, 230, 1.0)];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
       
        _switchBtn = [UISwitch new];
        _switchBtn.onTintColor = TOPAPPGreenColor;
        _switchBtn.thumbTintColor = [UIColor whiteColor];
        [_switchBtn addTarget:self action:@selector(top_subscribeTopic:) forControlEvents:UIControlEventValueChanged];
        
        [self.contentView addSubview:_lineView];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_switchBtn];
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
        make.trailing.equalTo(contentView).offset(-80);
        make.centerY.equalTo(contentView);
    }];
    [_switchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-18);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
    _switchBtn.on = ![TOPScanerShare top_screenshotEventState];
}
- (void)top_subscribeTopic:(UISwitch *)sender{
    if (sender.on) {
        [TOPScanerShare top_writeScreenshotEventState:NO];
    }else{
        [TOPScanerShare top_writeScreenshotEventState:YES];
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
