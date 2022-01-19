#import "TOPPDFSignatureCell.h"

@implementation SSPDFSignatureModel

@end
@interface TOPPDFSignatureCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UIImageView *statusView;
@end

@implementation TOPPDFSignatureCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.masksToBounds = YES;
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.statusView];
    [self top_sd_layoutSubViews];
}

- (void)top_sd_layoutSubViews {
    UIView * contentView = self.contentView;
    [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(54, 49));
    }];
    [self.statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(1.0);
        make.leading.equalTo(contentView).offset(1.0);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
}

- (void)top_congfigCellWithData:(SSPDFSignatureModel *)model {
    if (model) {
        self.iconView.image = [UIImage imageWithContentsOfFile:model.imagePath];
        self.statusView.hidden = !model.isEditing;
    }
}

#pragma mark -- lazy
- (UIImageView *)iconView {
    if (!_iconView) {
        UIImageView *classImageView = [[UIImageView alloc] init];
        classImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView = classImageView;
    }
    return _iconView;
}

- (UIImageView *)statusView {
    if (!_statusView) {
        UIImageView *classImageView = [[UIImageView alloc] init];
        classImageView.contentMode = UIViewContentModeScaleAspectFit;
        classImageView.hidden = YES;
        classImageView.image = [UIImage imageNamed:@"top_pdf_delete_btn"];
        _statusView = classImageView;
    }
    return _statusView;
}

@end
