#import "TOPSettingShowViewCell.h"

@implementation TOPSettingShowViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:[UIColor whiteColor]];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:18];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        
        _iconImg = [UIImageView new];
        _iconImg.image = [UIImage imageNamed:@"top_settingSelect"];
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineMostDarkColor defaultColor:TOPAppBackgroundColor];

        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_iconImg];
        [self.contentView addSubview:_lineView];
        [self.contentView addSubview:self.vipLogoView];
    }
    return self;
}

- (void)setModel:(TOPSettingFormatModel *)model{
    
    CGFloat titleW = [TOPDocumentHelper top_getSizeWithStr:model.formatString Height:20 Font:18].width+10;
    UIView * contentView = self.contentView;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(titleW, 20));
    }];
    CGFloat vip_w = 1.0;
    if (model.showVip) {
        vip_w = 16;
    }
    [self.vipLogoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.leading.equalTo(_titleLab.mas_trailing).offset(10);
        make.size.mas_equalTo(CGSizeMake(vip_w, 16));
    }];
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.leading.equalTo(self.vipLogoView.mas_trailing).offset(20);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(20);
        make.trailing.equalTo(contentView).offset(-20);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
    _titleLab.text = model.formatString;
    if (model.isSelect) {
        _titleLab.textColor = TOPAPPGreenColor;
        _iconImg.hidden = NO;
    }else{
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _iconImg.hidden = YES;
    }
    self.vipLogoView.hidden = !model.showVip;
}
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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


@end
