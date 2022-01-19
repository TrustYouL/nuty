#import "TOPNextFolderCell.h"
@interface TOPNextFolderCell()
@property (nonatomic ,strong)UILabel * titleLabel;
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UILabel * numLabel;
@property (nonatomic ,strong) UIView * lineView;

@end
@implementation TOPNextFolderCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _titleLabel.font = [self fontsWithSize:15];
        _titleLabel.textAlignment = NSTextAlignmentNatural;
     
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = UIColor.grayColor;
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.font = [self fontsWithSize:13];
        _numLabel.layer.masksToBounds = YES;
        _numLabel.layer.cornerRadius = 2;
        _numLabel.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
        _numLabel.layer.borderWidth = 0.5;
        
        _iconImg = [UIImageView new];
        _iconImg.image = [UIImage imageNamed:@"top_wenjianjia_icon"];
        
        _choseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _choseBtn.hidden = YES;
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllNormal"] forState:UIControlStateNormal];
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllSelect"] forState:UIControlStateSelected];
        [_choseBtn addTarget:self action:@selector(top_selectAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        
        [self.contentView addSubview:_choseBtn];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_numLabel];
        [self.contentView addSubview:_iconImg];

        [self top_setupFream];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _titleLabel.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
}
- (void)top_setupFream{
    UIView * contentView = self.contentView;
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-60);
        make.top.equalTo(contentView).offset(5);
        make.height.mas_equalTo(17);
    }];
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.top.equalTo(_titleLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImg.mas_trailing).offset(20);
        make.bottom.equalTo(_iconImg.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(30, 15));
    }];
    [_choseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(10);
        make.trailing.equalTo(contentView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
}
- (void)setModel:(DocumentModel *)model{
    _model = model;
    _titleLabel.text = model.name;
    _numLabel.text = model.number;
    if (_isMerge) {
        _choseBtn.hidden = YES;
    }else{
        _choseBtn.hidden = ![TOPScanerShare shared].isEditing;
    }
    _choseBtn.selected = model.selectStatus;
    CGSize numSize = [TOPAppTools getLabelFrameWithString:_numLabel.text font:_numLabel.font sizeMake:CGSizeMake((100), (14))].size;

    if (numSize.width > (14)) {
        _numLabel.frame = CGRectMake(self.frame.size.width - (10) - numSize.width, CGRectGetMaxY(_titleLabel.frame)+ (5), numSize.width, (14));
    }
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImg.mas_trailing).offset(20);
        make.bottom.equalTo(_iconImg.mas_bottom);
        make.size.mas_equalTo(CGSizeMake([TOPDocumentHelper top_getSizeWithStr:model.number Height:15 Font:13].width+10, 15));
    }];
}
- (void)top_showSelectBtn{
    _choseBtn.hidden = NO;
}
- (void)top_selectAction:(UIButton*)btn{
    btn.selected = !btn.selected;
    if (self.top_ChoseBtnBlock) {
        self.top_ChoseBtnBlock(btn.selected);
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
