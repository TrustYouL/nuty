#import "TOPOcrTypeShowCell.h"

@implementation TOPOcrTypeShowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        
        _tipLab = [[UILabel alloc] init];
        _tipLab.font = [UIFont systemFontOfSize:14];
        _tipLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _tipLab.textAlignment = NSTextAlignmentCenter;
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(240, 240, 240, 1.0)];
        
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_lineView];
        [self top_configSubViewsLayout];
    }
    return self;
}

- (void)top_configSubViewsLayout {
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.contentView);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(40);
        make.trailing.equalTo(self.contentView).offset(-40);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(self.contentView).offset(-1);
    }];
    [self.vipLogoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLab.mas_trailing).offset(5);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)setRow:(NSInteger)row{
    self.lineView.hidden = !row ? NO : YES;
    CGFloat width = self.contentView.frame.size.width;
    if (!row) {
        self.titleLab.preferredMaxLayoutWidth = width - 50*2;
    } else {
        self.titleLab.preferredMaxLayoutWidth = width - 10*2;
        self.titleLab.numberOfLines = 3;
    }
}

#pragma mark -- lazy
- (UIImageView *)vipLogoView {
    if (!_vipLogoView) {
        UIImage *noClassImg = [UIImage imageNamed:@"top_vip_logo"];
        UIImageView *noClass = [[UIImageView alloc] initWithImage:noClassImg];
        [self.contentView addSubview:noClass];
        noClass.hidden = YES;
        _vipLogoView = noClass;
    }
    return _vipLogoView;
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
