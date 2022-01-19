#import "TOPRemindSwitchCell.h"

@implementation TOPRemindSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        
        _switchBtn = [UISwitch new];
        _switchBtn.onTintColor = TOPAPPGreenColor;
        _switchBtn.thumbTintColor = [UIColor whiteColor];
        [_switchBtn addTarget:self action:@selector(top_subscribeTopic:) forControlEvents:UIControlEventValueChanged];
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(238, 238, 238, 1.0)];
        
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_switchBtn];
        [self.contentView addSubview:_lineView];
        [self top_setViewFream];
    }
    return self;
}

- (void)top_setViewFream{
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    [_switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(7);
        make.trailing.equalTo(self.contentView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(60, 35));
    }];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(1.0);
    }];
    
    _titleLab.text = NSLocalizedString(@"topscan_homemoredocremind", @"");
}

- (void)setNoticeState:(BOOL)noticeState{
    _noticeState = noticeState;
    _switchBtn.on = noticeState;
}
- (void)top_subscribeTopic:(UISwitch *)sender{
    if (self.top_sendNoticeState) {
        self.top_sendNoticeState(sender.on);
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
