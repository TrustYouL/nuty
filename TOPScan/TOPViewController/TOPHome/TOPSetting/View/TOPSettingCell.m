#define CornerRadius 20

#import "TOPSettingCell.h"

@implementation TOPSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        
        _backViewF = [UIView new];
        _backViewF.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _backViewF.layer.cornerRadius = CornerRadius;
        _backViewF.layer.masksToBounds = YES;
        
        _backViewS = [UIView new];
        _backViewS.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _backViewT = [UIView new];
        _backViewT.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _titleImg = [UIImageView new];
        _rowImg = [UIImageView new];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:TOPAppBackgroundColor];
       
        [self.contentView addSubview:_backViewF];
        [self.contentView addSubview:_backViewS];
        [self.contentView addSubview:_backViewT];
        [self.contentView addSubview:_titleImg];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_rowImg];
        [self.contentView addSubview:_lineView];

        [self top_setupUI];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    _backViewF.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _backViewS.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _backViewT.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:TOPAppBackgroundColor];
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
}
- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_backViewF mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-15);
        make.top.bottom.equalTo(contentView);
    }];
    [_backViewS mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-15);
        make.top.equalTo(contentView).offset(CornerRadius/2+7);
        make.bottom.equalTo(contentView);
    }];
    [_backViewT mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-15);
        make.top.equalTo(contentView);
        make.bottom.equalTo(contentView).offset(-(CornerRadius/2+7));
    }];
    [_titleImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(25);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_titleImg.mas_trailing).offset(10);
        make.trailing.equalTo(contentView).offset(-30);
        make.top.bottom.equalTo(contentView);
    }];
    [_rowImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-25);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(7, 12));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(20);
        make.trailing.equalTo(contentView).offset(-20);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1);
    }];
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
    _rowImg.hidden = NO;
}

- (void)setDic:(NSDictionary *)dic{
    _titleImg.image = [UIImage imageNamed:dic[@"settingIcon"]];
    _rowImg.image = [UIImage imageNamed:dic[@"rowIcon"]];
    _titleLab.text = dic[@"title"];
    NSNumber * countNum = dic[@"arrayCount"];
    NSInteger count = [countNum integerValue];
    if (count == 1) {
        _backViewS.hidden = YES;
        _backViewT.hidden = YES;
        _lineView.hidden = YES;
    }else{
        if (_indexPath.row == 0) {
            _backViewS.hidden = NO;
            _backViewT.hidden = YES;
            _lineView.hidden = NO;
        }else if(_indexPath.row == count-1){
            _backViewS.hidden = YES;
            _backViewT.hidden = NO;
            _lineView.hidden = YES;
        }else{
            _backViewS.hidden = NO;
            _backViewT.hidden = NO;
            _lineView.hidden = NO;
        }
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
