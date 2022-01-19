#define CornerRadius 10

#import "TOPActionCell.h"

@implementation TOPActionCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];

        _backViewF = [UIView new];
        _backViewF.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _backViewF.layer.cornerRadius = CornerRadius;
        _backViewF.layer.masksToBounds = YES;
        
        _backViewS = [UIView new];
        _backViewS.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _backViewT = [UIView new];
        _backViewT.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _titleLab = [UILabel new];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _titleLab.font = [UIFont boldSystemFontOfSize:14];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(235, 235, 235, 1.0)];
    
        _iconImg = [UIImageView new];
        _iconImg.image = [UIImage imageNamed:@"top_lzactionicon"];
        
        [self.contentView addSubview:_backViewF];
        [self.contentView addSubview:_backViewS];
        [self.contentView addSubview:_backViewT];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_lineView];
        [self.contentView addSubview:_iconImg];
         
        [self top_creatDefaultUI];
        [self top_setupUI];
    }
    return self;
}
- (void)top_creatDefaultUI{
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
}

- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.centerX.equalTo(contentView);
        make.width.mas_equalTo(180);
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(50);
        make.trailing.equalTo(contentView).offset(-50);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.trailing.equalTo(contentView).offset(-70);
        make.size.mas_equalTo(CGSizeMake(16, 11.5));
    }];
}

- (void)setRow:(NSInteger)row{
    _row = row;
    if (_row == 0) {
        _backViewS.hidden = NO;
        _backViewT.hidden = YES;
    }else if(_row == _titleArray.count-1){
        _backViewS.hidden = YES;
        _backViewT.hidden = NO;
    }else{
        _backViewS.hidden = NO;
        _backViewT.hidden = NO;
    }
}

- (void)setDrawIndex:(NSInteger)drawIndex{
    _drawIndex = drawIndex;
    
    if (_row == drawIndex) {
        _titleLab.textColor = RGBA(61, 132, 216, 1.0);
        _iconImg.hidden = NO;
    }else{
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _iconImg.hidden = YES;
    }
}

- (void)setTitleArray:(NSMutableArray *)titleArray{
    _titleArray = titleArray;
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
