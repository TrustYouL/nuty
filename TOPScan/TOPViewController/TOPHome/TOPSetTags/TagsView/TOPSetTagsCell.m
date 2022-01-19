#import "TOPSetTagsCell.h"

@implementation TOPSetTagsCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _img = [UIImageView new];
        _img.layer.masksToBounds = YES;
        _img.layer.cornerRadius = 25/2;
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = TOPAPPGreenColor;
       
        [self.contentView addSubview:_img];
        [self.contentView addSubview:_titleLab];
    }
    return self;
}

- (void)setTagModel:(TOPTagsModel *)tagModel{
    _tagModel = tagModel;
    [_img mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentView);
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentView);
    }];
    
    _titleLab.text = tagModel.name;
    if (tagModel.selectStatus) {
        _img.backgroundColor = TOPAPPGreenColor;
        _titleLab.textColor = [UIColor whiteColor];
    }else{
        _img.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(230, 230, 230, 1.0)];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    }
}
@end
