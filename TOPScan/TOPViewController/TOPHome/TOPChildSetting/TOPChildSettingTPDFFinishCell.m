#import "TOPChildSettingTPDFFinishCell.h"
@interface TOPChildSettingTPDFFinishCell()
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UILabel * starLab;
@property (nonatomic ,strong)UIImageView * vipImg;
@property (nonatomic ,strong)UIImageView * deleteImg;
@end
@implementation TOPChildSettingTPDFFinishCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _vipImg = [UIImageView new];
        _vipImg.image = [UIImage imageNamed:@"top_vip_logo"];
        
        _deleteImg = [UIImageView new];
        _deleteImg.image = [UIImage imageNamed:@"top_childsetting_delete_pdf"];
        
        _titleLab = [UILabel new];
        _titleLab.text = NSLocalizedString(@"topscan_pdfpassword", @"");
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        
        _starLab = [UILabel new];
        _starLab.font = [UIFont systemFontOfSize:14];
        _starLab.textAlignment = NSTextAlignmentNatural;
        _starLab.textColor = RGBA(151, 151, 151, 1.0);
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:TOPAppBackgroundColor];
        
        [self.contentView addSubview:_deleteImg];
        [self.contentView addSubview:_vipImg];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_starLab];
        [self.contentView addSubview:_lineView];
        [self top_setupUI];
    }
    return self;
}
- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView).offset(-8);
        make.leading.equalTo(contentView).offset(15);
        make.height.mas_equalTo(20);
    }];
    [self.vipImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_titleLab.mas_trailing).offset(10);
        make.centerY.equalTo(_titleLab.mas_centerY);
        make.size.width.mas_equalTo(CGSizeMake(16, 16));
        make.trailing.lessThanOrEqualTo(contentView).offset(-45);
    }];
    [_starLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.centerY.equalTo(contentView).offset(17);
        make.height.mas_equalTo(12);
        make.trailing.lessThanOrEqualTo(contentView).offset(-45);
    }];
    [_deleteImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
}
- (void)setShowVip:(BOOL)showVip {
    _showVip = showVip;
    _vipImg.hidden = !showVip;
    NSLog(@"length==%ld",[[TOPScanerShare top_pdfPassword] length]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * starTitle = [NSString new];
        for (int i = 0; i<[[TOPScanerShare top_pdfPassword] length]; i++) {
            starTitle = [NSString stringWithFormat:@"%@*",starTitle];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.starLab.text = starTitle;
        });
    });
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
