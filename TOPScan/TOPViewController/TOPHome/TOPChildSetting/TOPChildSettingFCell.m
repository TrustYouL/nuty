#import "TOPChildSettingFCell.h"
@interface TOPChildSettingFCell()
@property (nonatomic ,strong)TOPImageTitleButton * tagBtn;
@property (nonatomic ,strong)TOPImageTitleButton * firstBtn;
@property (nonatomic ,strong)TOPImageTitleButton * secondBtn;
@property (nonatomic ,strong)TOPImageTitleButton * thirdBtn;
@property (nonatomic ,strong)UILabel * titleLab;

@end

@implementation TOPChildSettingFCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _firstBtn = [[TOPImageTitleButton alloc]initWithStyle:EImageTopTitleBottom];
        _firstBtn.tag = 1000+1;
        _firstBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _firstBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _firstBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_firstBtn setTitle:NSLocalizedString(@"topscan_girdviewlist", @"") forState:UIControlStateNormal];
        [_firstBtn setImage:[UIImage imageNamed:@"top_listviewicon"] forState:UIControlStateNormal];
        [_firstBtn setImage:[UIImage imageNamed:@"top_listviewselecticon"] forState:UIControlStateSelected];
        [_firstBtn setTitleColor:RGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
        [_firstBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateSelected];
        [_firstBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _secondBtn = [[TOPImageTitleButton alloc]initWithStyle:EImageTopTitleBottom];
        _secondBtn.tag = 1000+2;
        _secondBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _secondBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _secondBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_secondBtn setTitle:NSLocalizedString(@"topscan_girdview2", @"") forState:UIControlStateNormal];
        [_secondBtn setImage:[UIImage imageNamed:@"top_gird2icon"] forState:UIControlStateNormal];
        [_secondBtn setImage:[UIImage imageNamed:@"top_gird2selecticon"] forState:UIControlStateSelected];
        [_secondBtn setTitleColor:RGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
        [_secondBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateSelected];
        [_secondBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];

        _thirdBtn = [[TOPImageTitleButton alloc]initWithStyle:EImageTopTitleBottom];
        _thirdBtn.tag = 1000+3;
        _thirdBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _thirdBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _thirdBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_thirdBtn setTitle:NSLocalizedString(@"topscan_girdview2", @"") forState:UIControlStateNormal];
        [_thirdBtn setImage:[UIImage imageNamed:@"top_gird3icon"] forState:UIControlStateNormal];
        [_thirdBtn setImage:[UIImage imageNamed:@"top_gird3selecticon"] forState:UIControlStateSelected];
        [_thirdBtn setTitleColor:RGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
        [_thirdBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateSelected];
        [_thirdBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];

        _titleLab = [UILabel new];
        _titleLab.text = NSLocalizedString(@"topscan_childsettingview", @"");
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_firstBtn];
        [self.contentView addSubview:_secondBtn];
        [self.contentView addSubview:_thirdBtn];
        [self top_setupUI];
    }
    return self;
}
- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.top.equalTo(contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(150, 18));
    }];
    [_secondBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLab.mas_bottom).offset(15);
        make.centerX.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(90, 70));
    }];
    [_firstBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLab.mas_bottom).offset(15);
        make.trailing.equalTo(_secondBtn.mas_leading).offset(-10);
        make.size.mas_equalTo(CGSizeMake(90, 70));
    }];
    [_thirdBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLab.mas_bottom).offset(15);
        make.leading.equalTo(_secondBtn.mas_trailing).offset(10);
        make.size.mas_equalTo(CGSizeMake(90, 70));
    }];
    if ([TOPScanerShare top_saveChildVCListType] == TOPChildVCListTypeFirst) {
        _firstBtn.selected = YES;
        _secondBtn.selected = NO;
        _thirdBtn.selected = NO;
        _tagBtn = _firstBtn;
    }else if([TOPScanerShare top_saveChildVCListType] == TOPChildVCListTypeSecond){
        _firstBtn.selected = NO;
        _secondBtn.selected = YES;
        _thirdBtn.selected = NO;
        _tagBtn = _secondBtn;
    }else{
        _firstBtn.selected = NO;
        _secondBtn.selected = NO;
        _thirdBtn.selected = YES;
        _tagBtn = _thirdBtn;
    }
}
- (void)top_clickBtn:(UIButton *)sender{
    if (_tagBtn != sender) {
        _tagBtn.selected = NO;
        sender.selected = YES;
        TOPImageTitleButton * btn = (TOPImageTitleButton * )[self viewWithTag:sender.tag];
         _tagBtn = btn;
    }else{
        sender.selected = YES;
    }
    if (sender.tag == 1001) {
        [TOPScanerShare top_writeSaveChildVCListType:TOPChildVCListTypeFirst];
    }else if(sender.tag == 1002){
        [TOPScanerShare top_writeSaveChildVCListType:TOPChildVCListTypeSecond];
    }else{
        [TOPScanerShare top_writeSaveChildVCListType:TOPChildVCListTypeThird];
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
