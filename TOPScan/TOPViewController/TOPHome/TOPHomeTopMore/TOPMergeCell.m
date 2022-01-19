#import "TOPMergeCell.h"
#import "TOPFileTargetModel.h"
#import "TOPDataModelHandler.h"
@interface TOPMergeCell()
@property (nonatomic, strong)UIImageView  *imgV;
@property (nonatomic, strong)UILabel      *titleLabel;
@property (nonatomic, strong)UILabel      *dateLabel;
@property (nonatomic, strong)UIImageView  *gaussianImg;
@property (nonatomic, strong)UILabel      *numLabel;
@property (nonatomic, strong)UIView       *lineView;
@end
@implementation TOPMergeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        
        _imgV = [[UIImageView alloc] init];
        _imgV.contentMode = UIViewContentModeScaleAspectFill;
        _imgV.clipsToBounds = YES;
        
        _gaussianImg = [UIImageView new];
        
        _choseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _choseBtn.hidden = YES;
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllNormal"] forState:UIControlStateNormal];
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllSelect"] forState:UIControlStateSelected];
        [_choseBtn addTarget:self action:@selector(top_selectAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _titleLabel.font = [self fontsWithSize:15];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
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
        
        [self.contentView addSubview:_choseBtn];
        [self.contentView addSubview:_imgV];
        [self.contentView addSubview:_gaussianImg];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_numLabel];
        [self.contentView addSubview:_lineView];
        [self top_isEditingView];
    }
    return self;
}

- (void)top_isEditingView{
    UIView * contentView = self.contentView;
    [_choseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(10);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_imgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_choseBtn.mas_trailing).offset(10);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    [_gaussianImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_imgV.mas_centerX);
        make.centerY.equalTo(_imgV.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(15, 20));
    }];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_imgV.mas_trailing).offset(10);
        make.trailing.equalTo(contentView).offset(-20);
        make.top.equalTo(contentView).offset(35);
        make.height.mas_equalTo(17);
    }];
    [_dateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(10);
        make.leading.equalTo(_imgV.mas_trailing).offset(10);
        make.height.mas_equalTo(14);
    }];
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(10);
        make.leading.equalTo(_dateLabel.mas_trailing).offset(15);
        make.size.mas_equalTo(CGSizeMake(45, 15));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-15);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1);
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
    [self top_isEditingView];
    
    _numLabel.text = _model.number;
    _dateLabel.text = _model.createDate;
    if ([TOPWHCFileManager top_isExistsAtPath:model.docPasswordPath]) {
        _imgV.image = [UIImage imageWithContentsOfFile:model.gaussianBlurPath];
        _gaussianImg.hidden = NO;
    }else{
        _imgV.image = [UIImage imageWithContentsOfFile:model.coverImagePath];
        _gaussianImg.hidden = YES;
    }
    if (!_imgV.image) {
        WS(weakSelf);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [TOPDataModelHandler top_createCoverImage:model.imagePath atPath:model.coverImagePath];
            UIImage * bluImg = [UIImage new];
            if ([TOPWHCFileManager top_isExistsAtPath:model.docPasswordPath]) {
                bluImg = [TOPDocumentHelper top_blurryImage:[UIImage imageWithContentsOfFile:model.imagePath] withBlurLevel:60];
                if (bluImg) {
                    [TOPDocumentHelper top_saveImage:bluImg atPath:model.gaussianBlurPath];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *coverImage = [UIImage imageWithContentsOfFile:model.coverImagePath];
                if (!coverImage) {
                    coverImage = [UIImage imageWithContentsOfFile:model.imagePath];
                }
                if ([TOPWHCFileManager top_isExistsAtPath:model.docPasswordPath]) {
                    weakSelf.imgV.image = bluImg;
                }else{
                    weakSelf.imgV.image = coverImage;
                }
            });
        });
    }
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(10);
        make.leading.equalTo(_dateLabel.mas_trailing).offset(15);
        make.size.mas_equalTo(CGSizeMake([TOPDocumentHelper top_getSizeWithStr:model.number Height:15 Font:13].width+8, 15));
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

@end
