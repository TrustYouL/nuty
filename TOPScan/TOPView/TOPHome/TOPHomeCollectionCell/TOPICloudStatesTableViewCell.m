#import "TOPICloudStatesTableViewCell.h"

@implementation TOPICloudStatesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        _selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_iClound_set"]];
        self.selectImageView.layer.shadowOffset = CGSizeMake(0, 1);
        self.selectImageView.layer.shadowColor = RGBA(9, 103, 103, 0.13).CGColor ;
        self.selectImageView.layer.shadowOpacity = 1;
        self.selectImageView.layer.shadowRadius = 3;
        self.selectImageView.clipsToBounds =NO;
    
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.text = @"iClound";
   
        UILabel *lineLabel = [UILabel new];
        lineLabel.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:UIColorFromRGB(0xF0F0F0)];
        
        [self.contentView addSubview:_selectImageView];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:self.switchView];
        [self.contentView addSubview:lineLabel];
    
        [_selectImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(15);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(36, 36));
        }];
        [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_selectImageView.mas_trailing).offset(10);
            make.trailing.equalTo(self.contentView).offset(-70);
            make.bottom.top.equalTo(self.contentView);
        }];
        [_switchView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView).offset(-15);
            make.centerY.equalTo(self.contentView);
        }];
        [lineLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

- (UISwitch *)switchView{
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        _switchView.onTintColor = TOPAPPGreenColor;
        NSInteger isShow =   [[[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudOpen"] integerValue];
        if (isShow ==2) {
            _switchView.on = true;
        }else{
            _switchView.on = false;
        }
        [_switchView addTarget:self action:@selector(touchChangeStates:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (void)touchChangeStates:(UISwitch *)sender {
    if (sender.on) {
        [[NSUserDefaults standardUserDefaults ] setInteger:2 forKey:@"iCloudOpen"];
    }else{
        [[NSUserDefaults standardUserDefaults ] setInteger:1 forKey:@"iCloudOpen"];
    }
}
@end
