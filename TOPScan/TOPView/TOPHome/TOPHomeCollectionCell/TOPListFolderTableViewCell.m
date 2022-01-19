#import "TOPListFolderTableViewCell.h"
#import "TOPFileTargetModel.h"

@interface TOPListFolderTableViewCell()
@property (nonatomic, strong)UIImageView  *imgV;
@property (nonatomic, strong)UILabel      *titleLabel;
@property (nonatomic, strong)UILabel      *numLabel;
@property (nonatomic, strong)UIButton     *selectBtn;
@property (strong, nonatomic)UIImageView  *redPin;

@end
@implementation TOPListFolderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _imgV = [[UIImageView alloc] init];
        _imgV.image = [UIImage imageNamed:@"top_wenjianjia_icon"];
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(235, 235, 235, 1.0)];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _titleLabel.font = [self fontsWithSize:16];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = RGBA(153, 153, 153, 1.0f);
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.font = [self fontsWithSize:13];
        _numLabel.layer.masksToBounds = YES;
        _numLabel.layer.cornerRadius = 2;
        _numLabel.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
        _numLabel.layer.borderWidth = 1;
        
        _choseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _choseBtn.hidden = YES;
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllNormal"] forState:UIControlStateNormal];
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllSelect"] forState:UIControlStateSelected];
        [_choseBtn addTarget:self action:@selector(top_selectAction:) forControlEvents:UIControlEventTouchUpInside];

        [self.contentView addSubview:_choseBtn];
        [self.contentView addSubview:_imgV];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_numLabel];
        [self.contentView addSubview:_lineView];
        [self.contentView addSubview:self.redPin];
        [self top_createUI];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(235, 235, 235, 1.0)];
    _titleLabel.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
}
- (void)top_createUI{
    UIView * contentView = self.contentView;
    [_choseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(10);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_imgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(25, 22));
    }];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.leading.equalTo(_imgV.mas_trailing).offset(20);
        make.trailing.equalTo(contentView).offset(-65);
        make.height.mas_equalTo(25);
    }];
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.trailing.equalTo(contentView).offset(-20);
        make.size.mas_equalTo(CGSizeMake(45, 15));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-15);
        make.top.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
    [self.redPin mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(9, 20));
    }];
}

- (void)top_isEditingView{
    UIView * contentView = self.contentView;
    [_imgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_choseBtn.mas_trailing).offset(10);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(24, 21));
    }];
}


- (void)top_showSelectBtn{
    self.choseBtn.hidden = NO;
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
    
    if (!_choseBtn.hidden) {
        [self top_isEditingView];
    }else{
        [self top_createUI];
    }
    
    CGSize numSize = [TOPAppTools getLabelFrameWithString:_numLabel.text font:_numLabel.font sizeMake:CGSizeMake((100), (14))].size;

    if (numSize.width > (14)) {
        _numLabel.frame = CGRectMake(self.frame.size.width - (10) - numSize.width, CGRectGetMaxY(_titleLabel.frame)+ (5), numSize.width, (14));
    }
    
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-20);
        make.size.mas_equalTo(CGSizeMake([TOPDocumentHelper top_getSizeWithStr:model.number Height:15 Font:13].width+10, 15));
    }];
}

- (void)top_configCellWithData:(TOPFileTargetModel *)fileTargetModel {
    [self top_createUI];
    _titleLabel.text = fileTargetModel.targetFileName;
    _numLabel.hidden = YES;
    _choseBtn.hidden = YES;
    _imgV.hidden = NO;
    if (fileTargetModel.isAllDoc) {
        _imgV.image = [UIImage imageNamed:@"top_homeIcon"];
    }else{
        _imgV.image = [UIImage imageNamed:@"top_wenjianjia_icon"];
    }
    
    if (fileTargetModel.isCurrentFile) {
        _titleLabel.textColor = kCommonRedTextColor;
        self.redPin.hidden = NO;
    } else {
        _titleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        self.redPin.hidden = YES;
    }
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

#pragma mark -- lazy
- (UIImageView *)redPin {
    if (!_redPin) {
        _redPin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_red_pin"]];
        _redPin.hidden = YES;
    }
    return _redPin;;
}

@end
