#import "TOPHeadMenuCell.h"
#import "TOPHeadMenuModel.h"

@interface TOPHeadMenuCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *titleLab;
@property (nonatomic ,strong)UIImageView *vipLogoView;

@end

@implementation TOPHeadMenuCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.titleLab];
    [self top_sd_layoutSubViews];
}

- (void)top_sd_layoutSubViews {
    UIView * contentView = self.contentView;
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(59, 59));
    }];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(contentView);
        make.top.equalTo(self.iconView.mas_bottom).offset(0);
        make.bottom.equalTo(contentView);
    }];
    [self.vipLogoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(59, 59));
    }];
}

- (void)top_congfigCellWithData:(TOPHeadMenuModel *)model {
    if (model) {
        self.iconView.image = [UIImage imageNamed:model.iconName];
        self.titleLab.text = model.title;
        self.vipLogoView.hidden = !model.showVip;
    }
}

#pragma mark -- lazy
- (UIImageView *)iconView {
    if (!_iconView) {
        UIImageView *classImageView = [[UIImageView alloc] init];
        classImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView = classImageView;
    }
    return _iconView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_M_FONT_(11);
        noClassLab.text = @"";
        _titleLab = noClassLab;
    }
    return _titleLab;
}

#pragma mark -- lazy
- (UIImageView *)vipLogoView {
    if (!_vipLogoView) {
        UIImage *noClassImg = [UIImage imageNamed:@"top_vip_logo_corner"];
        UIImageView *noClass = [[UIImageView alloc] initWithImage:noClassImg];
        [self.contentView addSubview:noClass];
        noClass.hidden = YES;
        _vipLogoView = noClass;
    }
    return _vipLogoView;
}

@end
