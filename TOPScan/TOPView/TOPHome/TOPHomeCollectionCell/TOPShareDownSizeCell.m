#define CornerRadius 10

#import "TOPShareDownSizeCell.h"

@implementation TOPShareDownSizeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _backViewF = [UIView new];
        _backViewF.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _backViewF.layer.cornerRadius = CornerRadius;
        _backViewF.layer.masksToBounds = YES;
        
        _backViewS = [UIView new];
        _backViewS.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _backViewT = [UIView new];
        _backViewT.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _titleLab = [UILabel new];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.font = [UIFont boldSystemFontOfSize:15];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        
        _numberLab = [UILabel new];
        _numberLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(120, 120, 120, 1.0)];
        _numberLab.font = [UIFont systemFontOfSize:13];
        if (isRTL()) {
            _numberLab.textAlignment = NSTextAlignmentLeft;
        }else{
            _numberLab.textAlignment = NSTextAlignmentRight;
        }

        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(235, 235, 235, 1.0)];
  
        [self.contentView addSubview:_backViewF];
        [self.contentView addSubview:_backViewS];
        [self.contentView addSubview:_backViewT];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_numberLab];
        [self.contentView addSubview:_lineView];
        [self top_createUI];
    }
    return self;
}

- (void)top_createUI{
    UIView * contentView = self.contentView;
    [_backViewF mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(contentView);
    }];
    [_backViewS mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(contentView);
        make.top.equalTo(contentView).offset(CornerRadius/2+5);
    }];
    [_backViewT mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(contentView);
        make.bottom.equalTo(contentView).offset(-(CornerRadius/2+5));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(20);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(150, 20));
    }];
    [_numberLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-40);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(20);
        make.trailing.equalTo(contentView).offset(-20);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
}

- (void)setRow:(NSInteger)row{
    _row = row;
    if (_row == 0) {
        _titleLab.text = NSLocalizedString(@"topscan_originalsize", @"");
    }else if(_row == 1){
        _titleLab.text = NSLocalizedString(@"topscan_medium", @"");
    }else if(_row == 2){
        _titleLab.text = NSLocalizedString(@"topscan_small", @"");
    }else if(_row == 3){
        _titleLab.text = NSLocalizedString(@"topscan_userdefinedsize", @"");
    }
}

- (void)setDataSourceArray:(NSMutableArray *)dataSourceArray{
    _dataSourceArray = dataSourceArray;
    if (_row == 0) {
        _backViewS.hidden = NO;
        _backViewT.hidden = YES;
        _lineView.hidden = NO;
    }else if(_row == _dataSourceArray.count-1){
        _backViewS.hidden = YES;
        _backViewT.hidden = NO;
        _lineView.hidden = YES;
    }else{
        _backViewS.hidden = NO;
        _backViewT.hidden = NO;
        _lineView.hidden = NO;
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
