#import "TOPFunctionColletionListCell.h"

@implementation TOPFunctionColletionListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _iconImg = [UIImageView new];
        _iconImg.image = [UIImage imageNamed:@"top_icloudIcon"];
        
        _titleLab = [UILabel new];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.text = NSLocalizedString(@"topscan_colletionmydevice", @"");
        
        _deviceNameLab = [UILabel new];
        _deviceNameLab.textColor = RGBA(153, 153, 153, 1.0);
        _deviceNameLab.textAlignment = NSTextAlignmentNatural;
        _deviceNameLab.font = [UIFont systemFontOfSize:11];
        
        NSString * rowIcon = [NSString new];
        if (isRTL()) {
            rowIcon = @"top_reverpushVCRow";
        }else{
            rowIcon = @"top_pushVCRow";
        }
        _rowImg = [UIImageView new];
        _rowImg.image = [UIImage imageNamed:rowIcon];
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGB(235, 235, 235)];
        
        [self.contentView addSubview:_iconImg];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_deviceNameLab];
        [self.contentView addSubview:_rowImg];
        [self.contentView addSubview:_lineView];
        [self top_setupUI];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGB(235, 235, 235)];
}
- (void)top_setupUI{
    UIView * contentView = self.contentView;
    _deviceNameLab.text = [NSString stringWithFormat:@"(%@)",[UIDevice currentDevice].name];
    CGFloat showW;
    CGFloat titleW = [TOPDocumentHelper top_getSizeWithStr:_titleLab.text Height:18 Font:16].width;
    CGFloat deviceW = [TOPDocumentHelper top_getSizeWithStr:_deviceNameLab.text Height:12 Font:11].width;
    if (titleW>=deviceW) {
        _deviceNameLab.textAlignment = NSTextAlignmentCenter;
        showW = titleW;
    }else{
        _deviceNameLab.textAlignment = NSTextAlignmentNatural;
        showW = deviceW+10;
    }
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(25, 40));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImg.mas_trailing).offset(20);
        make.top.equalTo(contentView).offset(20);
        make.size.mas_equalTo(CGSizeMake(180, 18));
    }];
    [_deviceNameLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImg.mas_trailing).offset(20);
        make.top.equalTo(_titleLab.mas_bottom).offset(2);
        make.size.mas_equalTo(CGSizeMake(showW, 12));
    }];
    [_rowImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-20);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(7, 12));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-15);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
}

- (void)setFolderPath:(NSString *)folderPath{
    if (folderPath.length == 0) {
        _iconImg.hidden = NO;
        _titleLab.hidden = NO;
        _rowImg.hidden = NO;
        _lineView.hidden = NO;
        _deviceNameLab.hidden = NO;
    }else{
        _iconImg.hidden = YES;
        _titleLab.hidden = YES;
        _rowImg.hidden = YES;
        _lineView.hidden = YES;
        _deviceNameLab.hidden = YES;
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
