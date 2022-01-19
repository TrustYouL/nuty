#import "TOPListTableViewCell.h"
#import "TOPFileTargetModel.h"
#import "TOPDataModelHandler.h"
#import "UIImageView+AsyncCover.h"

@interface TOPListTableViewCell()
@property (nonatomic, strong)UIImageView  *backImgV;
@property (nonatomic, strong)UIImageView  *imgV;
@property (nonatomic, strong)UILabel      *titleLabel;
@property (nonatomic, strong)UILabel      *dateLabel;
@property (nonatomic, strong)UIImageView  *gaussianImg;
@property (nonatomic, strong)UIImageView  *folderIcon;
@property (nonatomic, strong)UILabel      *numLabel;
@property (strong, nonatomic)UIImageView  *redPin;
@property (strong, nonatomic)UIView       *folderTag;
@property (strong, nonatomic)UILabel      *docIdLab;


@end
@implementation TOPListTableViewCell 

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _backImgV = [UIImageView new];
        _backImgV.image = [UIImage imageNamed:@"top_tabbackImg"];
       
        _imgV = [[UIImageView alloc] init];
        _imgV.contentMode = UIViewContentModeScaleAspectFill;
        _imgV.clipsToBounds = YES;
        _imgV.layer.cornerRadius = 2;
        _imgV.layer.borderWidth = 1;
        _imgV.layer.borderColor = RGBA(243, 247, 252, 1.00).CGColor;
        
        _gaussianImg = [UIImageView new];

        _choseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _choseBtn.hidden = YES;
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllNormal"] forState:UIControlStateNormal];
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllSelect"] forState:UIControlStateSelected];
        [_choseBtn addTarget:self action:@selector(top_selectAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _titleLabel.font = [self fontsWithSize:15];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentNatural;
    
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = RGBA(153, 153, 153, 1.0);
        _dateLabel.font = [self fontsWithSize:12];
        
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = UIColor.grayColor;
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.font = [self fontsWithSize:13];
        _numLabel.layer.masksToBounds = YES;
        _numLabel.layer.cornerRadius = 2;
        _numLabel.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
        _numLabel.layer.borderWidth = 1;
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(235, 235, 235, 1.0)];

        _folderIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_folderTag_white"]];

        [self.contentView addSubview:_choseBtn];
        [self.contentView addSubview:_backImgV];
        [self.contentView addSubview:_imgV];
        [self.contentView addSubview:_gaussianImg];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_numLabel];
        [self.contentView addSubview:_lineView];
        [self.contentView addSubview:self.redPin];
        [self.contentView addSubview:self.docIdLab];
        [_imgV addSubview:self.folderTag];
        [self.folderTag addSubview:_folderIcon];
        [self top_createUI];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _titleLabel.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(235, 235, 235, 1.0)];
}
- (void)top_createUI{
    UIView * contentView = self.contentView;
    [_backImgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(84, 80));
    }];
    [_imgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(79, 79));
    }];
    [_gaussianImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_imgV.mas_centerX);
        make.centerY.equalTo(_imgV.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(15, 20));
    }];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_imgV.mas_trailing).offset(10);
        make.top.equalTo(contentView).offset(20);
        make.size.mas_equalTo(CGSizeMake(230, 40));
    }];
    [_dateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_imgV.mas_trailing).offset(10);
        make.top.equalTo(_titleLabel.mas_bottom).offset(8);
        make.height.mas_equalTo(14);
    }];
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_dateLabel.mas_trailing).offset(15);
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(15, 45));
    }];
    [_choseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(10);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
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
    [self.folderTag mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.imgV);
        make.leading.trailing.equalTo(self.imgV);
        make.height.mas_equalTo(17);
    }];
    [_folderIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.folderTag);
        make.size.mas_equalTo(CGSizeMake(14, 12));
    }];
    [self.docIdLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(16.5);
        make.leading.equalTo(_imgV.mas_trailing).offset(10);
        make.size.mas_equalTo(CGSizeMake(200, 9));
    }];
}

- (void)top_isEditingView{
    UIView * contentView = self.contentView;
    [_backImgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_choseBtn.mas_trailing).offset(10);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(84, 80));
    }];
    [_imgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_choseBtn.mas_trailing).offset(10);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(79, 79));
    }];
}
 
- (void)top_showSelectBtn{
    _choseBtn.hidden = NO;
}

- (void)setModel:(DocumentModel *)model{
    _model = model;
    _titleLabel.text = _model.name;
    _choseBtn.hidden = ![TOPScanerShare shared].isEditing;
    _choseBtn.selected = _model.selectStatus;
    _numLabel.text = _model.number;
    _dateLabel.text = _model.createDate;
    _gaussianImg.image = [UIImage imageNamed:@"top_gaussianblur"];

    if (!_choseBtn.hidden) {
        [self top_isEditingView];
    }else{
        [self top_createUI];
    }
    
    if ([TOPWHCFileManager top_isExistsAtPath:model.docPasswordPath]) {
        _gaussianImg.hidden = NO;
    } else {
        _gaussianImg.hidden = YES;
    }
    [self.imgV top_createCoverImage:model.imagePath atPath:model.coverImagePath complete:^(UIImage * _Nonnull img) {
        if (img) {
            UIImage * bluImg = [UIImage new];
            if ([TOPWHCFileManager top_isExistsAtPath:model.docPasswordPath]) {
                if ([TOPWHCFileManager top_isExistsAtPath:model.gaussianBlurPath]) {
                    bluImg = [UIImage imageWithContentsOfFile:model.gaussianBlurPath];//显示高斯模糊图片
                } else {
                    bluImg = [TOPDocumentHelper top_blurryImage:img withBlurLevel:60];
                    if (bluImg) {
                        [TOPDocumentHelper top_saveImage:bluImg atPath:model.gaussianBlurPath];//保存高斯模糊图片到本地
                    }
                }
            } else {
                bluImg = img;
            }
            self.imgV.image = bluImg;
        }
    }];

    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_dateLabel.mas_trailing).offset(15);
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([TOPDocumentHelper top_getSizeWithStr:model.number Height:15 Font:13].width+8, 15));
    }];
}

- (void)top_configCellWithData:(TOPFileTargetModel *)fileTargetModel {
    [self top_createUI];
    _titleLabel.text = fileTargetModel.targetFileName;
    _choseBtn.hidden = YES;
    _numLabel.text = fileTargetModel.number;
    _dateLabel.text = fileTargetModel.createDate;
    _gaussianImg.image = [UIImage imageNamed:@"top_gaussianblur"];
    
    if ([TOPWHCFileManager top_isExistsAtPath:fileTargetModel.docPasswordPath]) {
        _gaussianImg.hidden = NO;
    } else {
        _gaussianImg.hidden = YES;
    }
    [self.imgV top_createCoverImage:fileTargetModel.imagePath atPath:fileTargetModel.coverImagePath complete:^(UIImage * _Nonnull img) {
        if (img) {
            UIImage * bluImg = [UIImage new];
            if ([TOPWHCFileManager top_isExistsAtPath:fileTargetModel.docPasswordPath]) {
                if ([TOPWHCFileManager top_isExistsAtPath:fileTargetModel.gaussianBlurPath]) {
                    bluImg = [UIImage imageWithContentsOfFile:fileTargetModel.gaussianBlurPath];//显示高斯模糊图片
                } else {
                    bluImg = [TOPDocumentHelper top_blurryImage:img withBlurLevel:60];
                    if (bluImg) {
                        [TOPDocumentHelper top_saveImage:bluImg atPath:fileTargetModel.gaussianBlurPath];//保存高斯模糊图片到本地
                    }
                }
            } else {
                bluImg = img;
            }
            self.imgV.image = bluImg;
        }
    }];
    
    if (fileTargetModel.isCurrentFile) {
        _titleLabel.textColor = kCommonRedTextColor;
        _dateLabel.textColor = kCommonRedTextColor;
        _numLabel.textColor = kCommonRedTextColor;
        _numLabel.layer.masksToBounds = YES;
        _numLabel.layer.cornerRadius = 2;
        _numLabel.layer.borderColor = kCommonRedTextColor.CGColor;
        _numLabel.layer.borderWidth = 1;
        self.redPin.hidden = NO;
    } else {
        _titleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        _dateLabel.textColor = kTabbarNormal;
        _numLabel.textColor = kTabbarNormal;
        _numLabel.layer.masksToBounds = YES;
        _numLabel.layer.cornerRadius = 2;
        _numLabel.layer.borderColor = kTabbarNormal.CGColor;
        _numLabel.layer.borderWidth = 1;
        self.redPin.hidden = YES;
    }
    
    self.folderTag.hidden = fileTargetModel.isFile;
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_dateLabel.mas_trailing).offset(15);
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([TOPDocumentHelper top_getSizeWithStr:fileTargetModel.number Height:15 Font:13].width+8, 15));
    }];
}
- (UIImageView *)currentImageView{
    return self.imgV;
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

}

#pragma mark -- lazy
- (UIImageView *)redPin {
    if (!_redPin) {
        _redPin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_red_pin"]];
        _redPin.hidden = YES;
    }
    return _redPin;;
}

- (UIView *)folderTag {
    if (!_folderTag) {
        _folderTag = [[UIView alloc] init];
        _folderTag.backgroundColor = TOPAPPGreenColor;
        _folderTag.hidden = YES;
    }
    return _folderTag;
}

- (UILabel *)docIdLab {
    if (!_docIdLab) {
        _docIdLab = [[UILabel alloc] init];
        _docIdLab.textColor = kCommonRedTextColor;
        _docIdLab.textAlignment = NSTextAlignmentNatural;
        _docIdLab.font = PingFang_R_FONT_(11);
        _docIdLab.text = @"Current document";
        _docIdLab.hidden = YES;
    }
    return _docIdLab;
}

@end
