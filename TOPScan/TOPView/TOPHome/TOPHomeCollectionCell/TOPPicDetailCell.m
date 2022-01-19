#import "TOPPicDetailCell.h"

@implementation TOPPicDetailCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:17];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        
        NSTextAlignment textAlignment;
        if (isRTL()) {
            textAlignment = NSTextAlignmentLeft;
        }else{
            textAlignment = NSTextAlignmentRight;
        }
        _contentLab = [UILabel new];
        _contentLab.font = [UIFont systemFontOfSize:14];
        _contentLab.textColor = RGBA(150, 150, 150, 1.0);
        _contentLab.textAlignment = textAlignment;
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineMostDarkColor defaultColor:RGBA(235, 235, 235, 1.0)];
      
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_contentLab];
        [self.contentView addSubview:_lineView];
        [self top_creatUI];
    }
    return self;
}
- (void)top_creatUI{
    UIView * contentView = self.contentView;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.centerY.equalTo(contentView);
    }];
    [_contentLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-15);
        make.centerY.equalTo(contentView);
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(contentView);
        make.height.mas_offset(1.0);
    }];
}
- (void)setPicDic:(NSDictionary *)picDic{
    _picDic = picDic;
    if ([picDic allKeys].count) {
        _titleLab.text = [picDic allKeys][0];
        _contentLab.text = [picDic allValues][0];
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
