#import "TOPChildMoreCollectionCell.h"

@implementation TOPChildMoreCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _iconImg = [UIImageView new];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:17];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        
        _noticeLab = [UILabel new];
        _noticeLab.font = [UIFont systemFontOfSize:14];
        _noticeLab.textColor = RGBA(150, 150, 150, 1.0);
        _noticeLab.textAlignment = NSTextAlignmentNatural;
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineMostDarkColor defaultColor:RGBA(235, 235, 235, 1.0)];
      
        [self.contentView addSubview:_iconImg];
        [self.contentView addSubview:_noticeLab];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_lineView];
        [self top_creatUI];
    }
    return self;
}

- (void)top_creatUI{
    UIView * contentView = self.contentView;

    [_iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(30);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    [_noticeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImg.mas_trailing).offset(25);
        make.trailing.equalTo(contentView).offset(-20);
        make.centerY.equalTo(contentView);
        make.height.mas_equalTo(20);
    }];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImg.mas_trailing).offset(25);
        make.centerY.equalTo(contentView);
    }];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(30);
        make.trailing.equalTo(contentView).offset(-20);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
    
    [self.vipLogoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLab.mas_trailing).offset(10);
        make.centerY.equalTo(contentView);
        make.height.width.mas_equalTo(16);
        make.trailing.lessThanOrEqualTo(contentView).offset(-20);
    }];
    
    _noticeLab.hidden = YES;
}

- (void)top_resetNoticeFream{
    UIView * contentView = self.contentView;
    [_noticeLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImg.mas_trailing).offset(25);
        make.trailing.equalTo(contentView).offset(-20);
        make.bottom.equalTo(contentView).offset(-5);
        make.height.mas_equalTo(15);
    }];
    
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImg.mas_trailing).offset(25);
        make.trailing.equalTo(contentView).offset(-20);
        make.top.equalTo(contentView).offset(5);
        make.height.mas_equalTo(20);
    }];
}

- (void)setShowTime:(NSString *)showTime{
    _showTime = showTime;
    _noticeLab.text = showTime;
}
- (void)setTitlestring:(NSString *)titlestring{
    _titlestring = titlestring;
    _titleLab.text = titlestring;
    
    if ([titlestring isEqualToString:NSLocalizedString(@"topscan_homemoredocremind", @"")]&&_showTime.length>0) {
        [self top_resetNoticeFream];
        _noticeLab.hidden = NO;
    }
}

- (void)setShowVip:(BOOL)showVip {
    _showVip = showVip;
    self.vipLogoView.hidden = !showVip;
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
