#import "TOPFunctionCollectionCell.h"

@implementation TOPFunctionCollectionCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _iconImg = [UIImageView new];
        
        _titleLab = [UILabel new];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.adjustsFontSizeToFitWidth = YES;
        _titleLab.font = [UIFont systemFontOfSize:11];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.numberOfLines = 0;
  
        [self.contentView addSubview:_iconImg];
        [self.contentView addSubview:_titleLab];
        [self top_setupUI];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
}
- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(contentView).offset(5);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(1);
        make.trailing.equalTo(contentView).offset(-1);
        make.top.equalTo(_iconImg.mas_bottom).offset(1);
        make.bottom.equalTo(contentView).offset(-5);
    }];
}
- (void)setModel:(TOPFunctionColletionModel *)model{
    _iconImg.image = [UIImage imageNamed:model.iconString];
    _titleLab.text = model.titleString;
}
@end
