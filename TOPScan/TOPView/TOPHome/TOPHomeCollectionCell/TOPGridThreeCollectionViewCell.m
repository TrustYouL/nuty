#import "TOPGridThreeCollectionViewCell.h"
#import "TOPPictureProcessTool.h"
#import "TOPDataModelHandler.h"
#import "UIImageView+AsyncCover.h"

@interface TOPGridThreeCollectionViewCell()
@property (nonatomic, strong)UIImageView  *imgV;
@property (nonatomic, strong)UILabel      *titleLabel;
@property (nonatomic, strong)UILabel      *dateLabel;
@property (nonatomic, strong)UIImageView  *gaussianImg;
@property (nonatomic, strong)UILabel      *numLabel;
@property (nonatomic, strong)UILabel      *memoryLabel;
@property (nonatomic, strong)UIImageView  *tagImg;
@property (nonatomic, strong)UILabel      *tagLab;
@property (nonatomic, strong)UIImageView  *collectionImg;
@property (nonatomic, assign)CGFloat leftW;
@end
@implementation TOPGridThreeCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;

        _imgV = [[UIImageView alloc] init];
        _imgV.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        _imgV.contentMode = UIViewContentModeScaleAspectFill;
        _imgV.clipsToBounds = YES;
    
        _gaussianImg = [UIImageView new];

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

        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = RGBA(153, 153, 153, 1.0);
        _dateLabel.font = [self fontsWithSize:9];
        
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = UIColor.grayColor;
        _numLabel.layer.cornerRadius = 2;
        _numLabel.textAlignment = NSTextAlignmentNatural;
        _numLabel.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
        _numLabel.layer.borderWidth = 0.2;
        _numLabel.layer.masksToBounds = YES;
        _numLabel.font = [self fontsWithSize:13];
        
        _memoryLabel = [[UILabel alloc] init];
        _memoryLabel.textColor = RGBA(153, 153, 153, 1.0);
        _memoryLabel.hidden = NO;
        _memoryLabel.textAlignment = NSTextAlignmentCenter;
        _memoryLabel.font = [self fontsWithSize:11];
        _memoryLabel.layer.masksToBounds = YES;
        _memoryLabel.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
        _memoryLabel.layer.borderWidth = 1;
        _memoryLabel.layer.cornerRadius = 2;
        
        _tagImg = [UIImageView new];
        _tagImg.image = [UIImage imageNamed:@"top_biaoqian"];
        
        _collectionImg = [UIImageView new];
        _collectionImg.image = [UIImage imageNamed:@"top_collectionicon"];
        _collectionImg.hidden = YES;
        
        _tagLab = [[UILabel alloc] init];
        _tagLab.textColor = RGBA(153, 153, 153, 1.0);
        _tagLab.hidden = NO;
        _tagLab.textAlignment = NSTextAlignmentNatural;
        _tagLab.font = [self fontsWithSize:10];
        _tagLab.lineBreakMode = NSLineBreakByTruncatingTail;
         
        [self.contentView addSubview:_imgV];
        [self.contentView addSubview:_gaussianImg];
        [self.contentView addSubview:_choseBtn];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_memoryLabel];
        [self.contentView addSubview:_tagImg];
        [self.contentView addSubview:_tagLab];
        [self.contentView addSubview:_collectionImg];

        [self top_createUI];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _imgV.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    _titleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
}
- (void)top_createUI{
    UIView * contentView = self.contentView;
    [_imgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(contentView);
        make.height.mas_equalTo(_imgV.mas_width);
    }];
    [_gaussianImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_imgV);
        make.size.mas_equalTo(CGSizeMake(15, 20));
    }];
    [_choseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView);
        make.trailing.equalTo(contentView).offset(-5);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
}

- (void)top_setChangeViewLocation{
    UIView * contentView = self.contentView;
    
    CGFloat memoryW = 0;
    if ([_model.number integerValue]>999) {
        _memoryLabel.text = @"999+";
        _memoryLabel.font = [self fontsWithSize:7];
        memoryW = [TOPDocumentHelper top_getSizeWithStr:_model.number Height:13 Font:8].width+6;
    }else if([_model.number integerValue]>99){
        _memoryLabel.text = _model.number;
        _memoryLabel.font = [self fontsWithSize:9];
        memoryW = [TOPDocumentHelper top_getSizeWithStr:_model.number Height:13 Font:11].width+5;
    }else{
        _memoryLabel.text = _model.number;
        _memoryLabel.font = [self fontsWithSize:11];
        memoryW = [TOPDocumentHelper top_getSizeWithStr:_model.number Height:13 Font:11].width+8;
    }
    
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(5);
        make.trailing.equalTo(contentView).offset(-5);
        make.top.equalTo(_imgV.mas_bottom).offset(5);
        make.height.mas_equalTo(30);
    }];
    [_memoryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-4);
        make.top.equalTo(_titleLabel.mas_bottom).offset(5-2);
        make.size.mas_equalTo(CGSizeMake(memoryW, 13));
    }];
    [_dateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(5);
        make.trailing.equalTo(_memoryLabel.mas_leading).offset(-5);
        make.top.equalTo(_titleLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(10);
    }];
    [_collectionImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(5);
        make.top.equalTo(_dateLabel.mas_bottom).offset(3);
        make.size.mas_equalTo(CGSizeMake(24/2, 24/2));
    }];
    [_tagImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(_leftW);
        make.top.equalTo(_dateLabel.mas_bottom).offset(3);
        make.size.mas_equalTo(CGSizeMake(23/2, 23/2));
    }];
    [_tagLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_tagImg.mas_trailing).offset(2);
        make.trailing.equalTo(contentView).offset(-5);
        make.top.equalTo(_dateLabel.mas_bottom).offset(3);
        make.height.mas_equalTo(23/2);
    }];
}

- (void)top_showSelectBtn{
    _choseBtn.hidden = NO;
}

- (void)setModel:(DocumentModel *)model{
    _model = model;
    _choseBtn.hidden = ![TOPScanerShare shared].isEditing;
    _titleLabel.text = model.name;
    _dateLabel.text = model.createDate;
    _gaussianImg.image = [UIImage imageNamed:@"top_gaussianblur"];

    if ([model.type isEqualToString:@"1"]) {
        _numLabel.hidden = YES;
        _memoryLabel.hidden = NO;
        _memoryLabel.text = model.number;
        _choseBtn.selected = model.selectStatus;
    }else{
        _numLabel.text = model.number;
        CGSize numSize = [TOPAppTools getLabelFrameWithString:_numLabel.text font:_numLabel.font sizeMake:CGSizeMake((100), (14))].size;
        if (numSize.width > (14)) {
            _numLabel.frame = CGRectMake(self.frame.size.width - (10) - numSize.width, CGRectGetMaxY(_titleLabel.frame)+ (5), numSize.width, (14));
        }
    }

    if ([TOPWHCFileManager top_isExistsAtPath:model.docPasswordPath]) {
        _gaussianImg.hidden = NO;
    }else{
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

    NSArray * tagsArray = model.tagsArray;
    if (tagsArray.count>0) {
        _tagImg.hidden = NO;
        _tagLab.hidden = NO;
        NSString * allString = [NSString new];
        for (TOPTagsModel * tagModel in tagsArray) {
            allString = [NSString stringWithFormat:@"%@ | %@",allString,tagModel.name];
        }
        if (allString.length>2) {
            _tagLab.text = [allString substringFromIndex:2];
        }
    }else{
        _tagImg.hidden = YES;
        _tagLab.hidden = YES;
    }
    if (model.collectionstate) {
        _collectionImg.hidden = NO;
        _leftW = 5+12+3;
    }else{
        _collectionImg.hidden = YES;
        _leftW = 5;
    }
    [self top_setChangeViewLocation];
}


- (void)top_selectAction:(UIButton*)btn{
    btn.selected = !btn.selected;

    if (self.top_ChoseBtnBlock) {
          self.top_ChoseBtnBlock(btn.selected);
      }
    
}
@end
