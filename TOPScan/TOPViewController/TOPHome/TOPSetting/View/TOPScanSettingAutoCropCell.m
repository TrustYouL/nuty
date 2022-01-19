#import "TOPScanSettingAutoCropCell.h"

@implementation TOPScanSettingAutoCropCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];

        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(230, 230, 230, 1.0)];

        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1)];
        _titleLab.textAlignment = NSTextAlignmentNatural;

        _contentLab = [UILabel new];
        _contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLab.font = [UIFont systemFontOfSize:14];
        _contentLab.textColor = RGBA(180, 180, 180, 1.0);
        _contentLab.textAlignment = NSTextAlignmentNatural;
        _contentLab.numberOfLines = 0;

        _switchBtn = [UISwitch new];
        _switchBtn.onTintColor = TOPAPPGreenColor;
        _switchBtn.thumbTintColor = [UIColor whiteColor];
        [_switchBtn addTarget:self action:@selector(top_subscribeTopic:) forControlEvents:UIControlEventValueChanged];
        
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_contentLab];
        [self.contentView addSubview:_switchBtn];
        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (void)setModel:(TOPSettingModel *)model{
    UIView * contentView = self.contentView;
    _model = model;
    CGFloat contentH = 0;
    CGSize labSize = [TOPDocumentHelper top_getSizeWithStr:model.myContent Width:(TOPScreenWidth - 100) Font:14];
    contentH = labSize.height + 15;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-85);
        make.top.equalTo(contentView);
        make.bottom.equalTo(contentView).offset(-(8+contentH));
    }];
    [_contentLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-85);
        make.bottom.equalTo(contentView).offset(-8);
        make.height.mas_equalTo(contentH);
    }];
    [_switchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-20);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
   
    _titleLab.text = model.myTitle;
    _contentLab.text = model.myContent;
    
    if ([TOPScanerShare top_saveBatchImage] == TOPSettingSaveYES) {
        _switchBtn.on = YES;
    }else{
        _switchBtn.on = NO;
    }
}

- (void)top_subscribeTopic:(UISwitch *)sender{
    if (sender.on) {
        [TOPScanerShare top_writeSaveBatchImage:TOPSettingSaveYES];
    }else{
        [TOPScanerShare top_writeSaveBatchImage:TOPSettingSaveNO];
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
