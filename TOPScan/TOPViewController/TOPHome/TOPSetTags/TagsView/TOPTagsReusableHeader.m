#import "TOPTagsReusableHeader.h"

@implementation TOPTagsReusableHeader

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    _titleLab = [UILabel new];
    _titleLab.font = [UIFont systemFontOfSize:18];
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    _titleLab.textAlignment = NSTextAlignmentNatural;

    [self addSubview:_titleLab];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(200, 35));
    }];
}

@end
