#import "TOPCollageTemplateCell.h"
#import "TOPCollageTemplateModel.h"

@interface TOPCollageTemplateCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *titleLab;

@end

@implementation TOPCollageTemplateCell

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
    [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(61, 66));
    }];
    [self.titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(contentView);
        make.top.equalTo(self.iconView.mas_bottom).offset(4);
        make.height.mas_equalTo(15);
    }];
}

- (void)top_congfigCellWithData:(TOPCollageTemplateModel *)model {
    if (model) {
        if (model.isSelected) {
            self.iconView.image = [UIImage imageNamed:model.selectedIconName];
        } else {
            self.iconView.image = [UIImage imageNamed:model.iconName];
        }
        self.titleLab.text = model.title;
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
        noClassLab.textColor = kWhiteColor;
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_M_FONT_(10);
        noClassLab.text = @"";
        noClassLab.adjustsFontSizeToFitWidth = YES;
        _titleLab = noClassLab;
    }
    return _titleLab;
}

@end
