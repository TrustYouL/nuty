#import "TOPClearPsdCollectionViewCell.h"

@interface TOPClearPsdCollectionViewCell ()

@end
@implementation TOPClearPsdCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    
    [self.contentView addSubview:self.iconView];
    [self top_sd_layoutSubViews];
}

- (void)top_sd_layoutSubViews {
    UIView * contentView = self.contentView;
    [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(55, 36));
    }];
}
- (void)setImageIconName:(NSString *)imageIconName
{
    _imageIconName = imageIconName;
    self.iconView.image = [UIImage imageNamed:imageIconName];
    
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
@end
