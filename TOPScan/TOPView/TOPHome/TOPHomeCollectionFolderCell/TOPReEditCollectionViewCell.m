#import "TOPReEditCollectionViewCell.h"

@implementation TOPReEditCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.layer.cornerRadius = 10;
        self.layer.borderColor = TOPAPPGreenColor.CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.masksToBounds = YES;
        
        _showImg = [UIImageView new];
        _showImg.contentMode = UIViewContentModeScaleAspectFit;
        
        _titleLab = [UILabel new];
        _titleLab.backgroundColor = RGBA(51, 51, 51, 0.3);
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = [UIFont systemFontOfSize:11];
        
        [self.contentView addSubview:_showImg];
        [self.contentView addSubview:_titleLab];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_showImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(contentView);
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(contentView);
        make.height.mas_equalTo(28);
    }];
}

- (void)setModel:(TOPReEditModel *)model{
    _model = model;
    if ([model.dic[@"image"] isKindOfClass:[UIImage class]]) {
        _showImg.image = model.dic[@"image"];
    }
    
    if ([model.dic[@"image"] isKindOfClass:[NSString class]]) {
        _showImg.image = [UIImage imageWithContentsOfFile:model.dic[@"image"]];
    }

    _titleLab.text = [NSString stringWithFormat:@"%@",model.dic[@"name"]];
    if (model.isSelect) {
        _titleLab.backgroundColor = TOPAPPGreenColor;
    }else{
        _titleLab.backgroundColor = RGBA(51, 51, 51, 0.3);
    }
}
  
@end
