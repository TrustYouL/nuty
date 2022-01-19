#import "TOPGirdThreeFolderCollectionViewCell.h"
@interface TOPGirdThreeFolderCollectionViewCell()
@property (nonatomic, strong)UIImageView  *backImg;
@property (nonatomic, strong)UIImageView  *imgV;
@property (nonatomic, strong)UILabel      *numLabel;
@property (nonatomic, strong)UILabel      *titleLabel;
@property (nonatomic, strong)UIButton     *selectBtn;

@end
@implementation TOPGirdThreeFolderCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
       
        _backImg = [UIImageView new];
        _backImg.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:RGBA(230, 230, 230, 1.0)];
        
        _imgV = [[UIImageView alloc] init];
        _imgV.image = [UIImage imageNamed:@"top_wenjianjia_icon"];
        
        _choseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _choseBtn.hidden = YES;
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllNormal"] forState:UIControlStateNormal];
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllSelect"] forState:UIControlStateSelected];
        [_choseBtn addTarget:self action:@selector(top_selectAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentNatural;
        _titleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _titleLabel.font = [self fontsWithSize:12];
        
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = RGBA(153, 153, 153, 1.0f);
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.font = [self fontsWithSize:11];
        _numLabel.layer.masksToBounds = YES;
        _numLabel.layer.cornerRadius = 2;
        _numLabel.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
        _numLabel.layer.borderWidth = 1;
        
        [self.contentView addSubview:_backImg];
        [self.contentView addSubview:_imgV];
        [self.contentView addSubview:_choseBtn];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_numLabel];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _backImg.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:RGBA(230, 230, 230, 1.0)];
    _titleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
}
- (void)top_createUI{
    UIView * contentView = self.contentView;
    [_backImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(contentView);
        make.height.mas_equalTo(contentView.mas_width);
    }];
    
    CGSize imgSize = CGSizeMake(0, 0);
    if (IS_IPAD) {
        imgSize = CGSizeMake(70, 70);
    }else{
        imgSize = CGSizeMake(44.5, 44.5);
    }
    [_imgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_backImg);
        make.size.mas_equalTo(imgSize);
    }];
    [_choseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView);
        make.trailing.equalTo(contentView).offset(-5);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(5);
        make.trailing.equalTo(contentView).offset(-5);
        make.top.equalTo(_backImg.mas_bottom).offset(5);
        make.height.mas_equalTo(30);
    }];
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(5);
        make.top.equalTo(_titleLabel.mas_bottom).offset(2);
        make.size.mas_equalTo(CGSizeMake([TOPDocumentHelper top_getSizeWithStr:_model.number Height:14 Font:11].width+8, 16));
    }];
}

- (void)top_showSelectBtn{
    _choseBtn.hidden = NO;
}

- (void)setModel:(DocumentModel *)model{
    _model = model;
    if (_isMerge) {
        _choseBtn.hidden = YES;
    }else{
        _choseBtn.hidden = ![TOPScanerShare shared].isEditing;
    }
    _titleLabel.text = model.name;
    _numLabel.text = model.number;
    _choseBtn.selected = model.selectStatus;
    CGSize numSize = [TOPAppTools getLabelFrameWithString:_numLabel.text font:_numLabel.font sizeMake:CGSizeMake((100), (14))].size;
    if (numSize.width > (14)) {
        _numLabel.frame = CGRectMake((5) , CGRectGetMaxY(_titleLabel.frame)+ (5), numSize.width, (14));
    }
    [self top_createUI];
}

- (void)top_selectAction:(UIButton*)btn{
    btn.selected = !btn.selected;
    if (self.top_ChoseBtnBlock) {
          self.top_ChoseBtnBlock(btn.selected);
      }
}
@end
