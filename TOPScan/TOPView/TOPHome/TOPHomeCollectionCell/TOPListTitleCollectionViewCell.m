#import "TOPListTitleCollectionViewCell.h"

@implementation TOPListTitleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont boldSystemFontOfSize:18];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.lineBreakMode = NSLineBreakByTruncatingHead;
        
        [self.contentView addSubview:_titleLab];
        [self top_setUI];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:TOPAPPGreenColor];
}
- (void)top_setUI{
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(10);
        make.trailing.equalTo(self.contentView).offset(-10);
        make.top.bottom.equalTo(self.contentView);
    }];
}
@end
