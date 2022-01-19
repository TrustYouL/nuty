#import "TOPChildSettingTLockCell.h"
@interface TOPChildSettingTLockCell()
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIImageView * lockImg;
@property (nonatomic ,strong)UIImageView * rowImg;
@end
@implementation TOPChildSettingTLockCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _lockImg = [UIImageView new];
        
        NSString * rowIcon = [NSString new];
        if (isRTL()) {
            rowIcon = @"top_reverpushVCRow";
        }else{
            rowIcon = @"top_pushVCRow";
        }
        _rowImg = [UIImageView new];
        _rowImg.image = [UIImage imageNamed:rowIcon];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        
        [self.contentView addSubview:_rowImg];
        [self.contentView addSubview:_lockImg];
        [self.contentView addSubview:_titleLab];
        [self top_setupUI];
    }
    return self;
}
- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_lockImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.trailing.equalTo(contentView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    [_rowImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(7, 12));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.leading.equalTo(contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(160, 25));
    }];
}
- (void)setPathString:(NSString *)pathString{
    _pathString = pathString;
    NSString * passwordString = [TOPDocumentHelper top_getDocPasswordPathString:pathString];
    if ([TOPWHCFileManager top_isExistsAtPath:passwordString]) {
        _titleLab.text = NSLocalizedString(@"topscan_docpasswordunlockicon", @"");
        _rowImg.hidden = YES;
        _lockImg.hidden = NO;
        _lockImg.image = [UIImage imageNamed:@"top_childsettinglock"];
    }else{
        _rowImg.hidden = NO;
        _titleLab.text = NSLocalizedString(@"topscan_docpasswordicon", @"");
        _lockImg.hidden = YES;
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
